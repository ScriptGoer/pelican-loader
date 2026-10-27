-- Full-controller regressions, using the existing source-shaped native mock.
-- These establish scheduling/ownership behavior, not live catch performance.
local setup=dofile('tests/experimental/fixtures/ff3_league_fixture.lua')
local path=os.getenv('PELICAN_RELEASE_SOURCE') or 'experimental/auto_qb.lua'
local source=assert(io.open(path)):read('*a')
local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
local function scene(src,mode)
 local t=setup({source=src,simulateJump=true,newJumpTimingDefaults=true,newSharedCoverageDefaults=true,newSafetyDefaults=true,
  nativeModes={[mode or 'Dime']=true},ff3={Profile='CASUAL',RiskMode='TRUST',CloseBullet=false}})
 Mock.qhum.UseJumpPower=true;Mock.qhum.JumpPower=50
 t.ar.Position=Vector3.new(0,6,-30);t.ar.AssemblyLinearVelocity=Vector3.new(0,0,-10)
 t.dr.Position=Vector3.new(70,6,170)
 local c=t.run();c.SetThrow(false);t.steps(12)
 return t,c
end

-- Previously a scheduling omission entered PREJUMP_WINDOW_CHANGED and discarded
-- the sequence before a jump. Keep the same preparation and solve it next time.
local needle='    local shot;shot,why,receipt.failure=solve(selected.player,selected.shot.variant or selected.shot.mode)'
for _,reason in ipairs({'NATIVE_FRAME_BUDGET','QB_LAUNCH_POSE_CHANGED_REPLAN','DECISION_STALE_AFTER_NATIVE_SOLVER'})do
 local at=assert(source:find(needle,1,true))
 local injection=[[    if preJump and not controller.unified.testPreJumpDeferred then
        controller.unified.testPreJumpDeferred=true
        setGate(']]..reason..[[');return
    end
]]
 local src=source:sub(1,at-1)..injection..source:sub(at)
 local t,c=scene(src)
 local deferred=0;local original=c.bad.prejump
 function c.bad:prejump(passed)
  if not passed then deferred=deferred+1 end
  return original(self,passed)
 end
 c.SetThrow(true)
 for _=1,90 do t.advance(1/60);t.drain();if #t.requests>0 then break end end
 check(c.unified.testPreJumpDeferred and deferred==1,reason..' exercised once')
 check(#t.requests==1,reason..' releases exactly once after fresh retry')
 check(Mock.jumpCount==1 and t.requests[1].qbVy>0,reason..' retains one observed rising jump')
 check(not c.GetReport():find('PREJUMP_WINDOW_CHANGED',1,true),reason..' does not become a coverage cancellation')
 check(t.payload().JumpObservedDelay>=.075 and t.payload().JumpObservedDelay<.12,reason..' retains observed release offset')
 check(t.q.AutoThrowType.Enabled==true and t.q.ManualType=='Angle',reason..' restores native controls')
 check(c.Stop('RELEASE_DEFER_TEST'),reason..' cleanup succeeds')
end

-- An actual closed final window still cancels without a jump or request.
local at=assert(source:find(needle,1,true))
local src=source:sub(1,at-1)..[[    if preJump then
        controller.unified.testCoverageBlocked=true;setGate('DEFENDER_INTERCEPTION_RISK');return
    end
]]..source:sub(at)
src=src:gsub('local function driveSequence%(now%)',"controller.unified.TestCache=function(player)return shotCache[player]end\nlocal function driveSequence(now)",1)
local t,c=scene(src);c.SetThrow(true)
for _=1,20 do t.advance(1/60);t.drain()end
check(c.unified.testCoverageBlocked and #t.requests==0,'unsafe preflight cannot send')
check((Mock.jumpCount or 0)==0,'unsafe preflight cannot jump')
check(c.unified.TestCache(t.a)==nil,'fresh unsafe preflight invalidates the optimistic cache rather than reusing it')
check(c.GetReport():find('PREJUMP_WINDOW_CHANGED',1,true),'actual failed coverage cancels')
check(c.Stop('UNSAFE_PREFLIGHT_TEST'),'unsafe-window cleanup')

-- Real os.clock() advances inside one Heartbeat; the old time-based cleanup
-- cleared Jump in the guide tail before the next physics turn. The general
-- fixture freezes time during a callback, so explicitly exercise that gap.
local expose='drawGuide=function(now)'
at=assert(source:find(expose,1,true))
src=source:sub(1,at-1)..'controller.unified.TestJumpCleanup=updateJump\n'..source:sub(at)
t,c=scene(src);c.SetThrow(true)
for _=1,60 do t.advance(1/60);t.drain();if Mock.qhum.Jump then break end end
check(Mock.qhum.Jump==true,'ordinary jump requested before next physics turn')
check(#t.requests==0,'no packet before observed takeoff')
Mock.time=Mock.time+.001
c.unified.TestJumpCleanup(Mock.time)
check(Mock.qhum.Jump==true,'sub-frame clock progress cannot clear owned jump')
t.advance(1/60);t.drain()
check((Mock.jumpCount or 0)==1 and Mock.qroot.AssemblyLinearVelocity.Y>0,'next physics turn observes requested jump')
for _=1,30 do t.advance(1/60);t.drain();if #t.requests>0 then break end end
check(#t.requests==1 and t.requests[1].qbVy>0,'same jump releases exactly once while rising')
check(c.Stop('SUBFRAME_JUMP_TEST'),'sub-frame jump cleanup')

-- Direct ordinary Bullets need one fresh final solve, not preview + final.
-- After warming selection-only caches, request count is still zero. The
-- winner-to-release section incurs exactly one native call and sends its tuple.
local marker='        local final,failed,failure'
at=assert(source:find(marker,1,true))
src=source:sub(1,at-1)..'        controller.unified.testBeforeWinner=Mock.nativeSolverCalls or 0\n'..source:sub(at)
t,c=scene(src,'Bullet')
check(#t.requests==0,'selection-only warming never releases')
c.SetThrow(true)
for _=1,30 do t.advance(1/60);t.drain();if #t.requests>0 then break end end
check(#t.requests==1,'auto Bullet releases after enabling throw')
check((Mock.nativeSolverCalls or 0)-c.unified.testBeforeWinner==1,'ordinary auto Bullet uses one final native solve instead of duplicate preview')
check((Mock.jumpCount or 0)==0,'ordinary Bullet does not jump')
check(c.unified.ReleaseDeferred('NATIVE_FRAME_BUDGET'),'exact budget defers')
check(not c.unified.ReleaseDeferred('DEFENDER_INTERCEPTION_RISK'),'coverage rejection never defers')
check(not c.unified.ReleaseDeferred('RECEIVER_CANNOT_REACH_NATIVE_ARRIVAL'),'unreachable receiver never defers')
check(t.q.AutoThrowType.Enabled==true,'final automatic solve restores automatic settings')
check(c.Stop('BULLET_FRESH_TEST'),'Bullet cleanup')

-- A refusal reports the actual normal-jump restriction, instead of only a
-- generic label which cannot distinguish disabled jumping from posture.
t,c=scene(source)
local shot={mode='Dime',unified={Allowed=true,Guard={Allowed=true}}}
local allowed,why,details=c.unified.AutoJumpAllowed(shot,{},Mock.qhum)
check(allowed and details.PhysicsKnown and details.JumpingEnabled,'normal readiness records actual jump support')
check(details.FloorMaterial and details.State and details.VerticalVelocity~=nil,'readiness preserves floor, state and vertical velocity')
t.options.jumpDisabled=true
allowed,why,details=c.unified.AutoJumpAllowed(shot,{},Mock.qhum)
check(not allowed and why=='NORMAL_JUMP_UNAVAILABLE' and details.JumpingEnabled==false,'disabled jumping has an explicit diagnostic')
t.options.jumpDisabled=false;Mock.qhum.Sit=true
allowed,why,details=c.unified.AutoJumpAllowed(shot,{},Mock.qhum)
check(not allowed and details.Sit==true,'sitting refusal records posture')
Mock.qhum.Sit=false;Mock.qhum.PlatformStand=true
allowed,why,details=c.unified.AutoJumpAllowed(shot,{},Mock.qhum)
check(not allowed and details.PlatformStand==true,'platform-standing refusal records posture')
check(c.Stop('JUMP_READINESS_EVIDENCE'),'jump readiness diagnostic cleanup')
print('PASS release-pipeline checks',checks,'(synthetic; live Roblox unverified)')
