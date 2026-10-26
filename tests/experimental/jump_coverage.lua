local setup=dofile('tests/experimental/fixtures/ff3_league_fixture.lua')
local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
for _,ref in ipairs({'experimental-unified-b3.4','CURRENT'})do
 local src
 if ref=='CURRENT'then src=assert(io.open('experimental/auto_qb.lua')):read('*a')else local p=assert(io.popen('git show '..ref..':experimental/auto_qb.lua'));src=p:read('*a');p:close()end
 local t=setup({source=src,simulateJump=true,newJumpTimingDefaults=true,nativeModes={Dime=true},ff3={Profile='CASUAL',RiskMode='TRUST',PassPlan='DEEP',CloseBullet=false}})
 Mock.qhum.UseJumpPower=true;Mock.qhum.JumpPower=50
 t.ar.Position=Vector3.new(0,6,-30);t.ar.AssemblyLinearVelocity=Vector3.new(0,0,-10)
 t.dr.Position=Vector3.new(70,6,170)
 local c=t.run();local preflights=0;local originalPrejump=c.bad.prejump
 function c.bad:prejump(ok)preflights=preflights+1;return originalPrejump(self,ok)end
 c.SetThrow(false);t.steps(12);c.SetThrow(true)
 for i=1,50 do t.advance(1/60);t.drain();if (Mock.jumpCount or 0)>0 then break end end
 t.ar.AssemblyLinearVelocity=Vector3.new(10,0,-2)
 for i=1,12 do t.advance(1/60);t.drain()end
 check(#t.requests==1,'safe current route releases within the observed jump')
 check((c.GetReport():find('BURN_CANCEL|',1,true)~=nil)==(ref~='CURRENT'),'only old lifecycle cancels on route direction without fresh trajectory evidence')
 if ref=='CURRENT' then
 check(preflights==1,'airborne state does not repeatedly run grounded jump preflight')
 check(Mock.jumpCount==1,'route turn does not trigger another jump')
 check(t.payload().JumpObservedDelay>=.075 and t.payload().JumpObservedDelay<.12,'release uses observed short takeoff offset')
 check(t.requests[1].qbVy>0,'route-turn release remains ascending')
 check(not c.bad.current.PreJump or c.bad.current.PreJump.Status=='PREJUMP_VERIFIED','preflight evidence retained')
 end
 c.Stop('TEST')
end

-- Coverage layer labels require an actual native-path or catch-point threat.
-- No named role or LOS proximity exempts a rusher from interception guards.
local src=assert(io.open('experimental/auto_qb.lua')):read('*a')
src=src:gsub('local built,buildError=pcall%(function%(%)',[[
controller.Audit={risk=risk,coverage=coverage,allowed=throwable}
local built,buildError=pcall(function()]],1)
local t=setup({source=src,newSharedCoverageDefaults=true,ff3={Profile='CASUAL',RiskMode='SAFE'}})
local c=t.run();c.SetThrow(false);t.steps(12)
local function actor(x,z,vx,vz)
 return {name='Opponent',p=Vector3.new(x,6,z),v=Vector3.new(vx,0,vz),turn=0,observedSpeed=16,hum={WalkSpeed=16,JumpPower=50}}
end
local wr=actor(0,-60,0,0)
local function shot()
 return {mode='Bullet',variant='Bullet',power=80,origin=Vector3.new(0,8,0),arrival=Vector3.new(0,8,-60),velocity=Vector3.new(0,14,-60),time=1,networkPing=0,at=Mock.time}
end
local clear=shot();c.Audit.risk(clear,wr,{actor(50,-5,-16,0)})
check(clear.coverageLayers.Underneath==0,'off-lane pressure is not labeled underneath coverage merely by downfield fraction')
check(clear.coverageLayers.LaneThreats==0,'unreachable rusher is not a trajectory threat')
local blocked=shot();c.Audit.risk(blocked,wr,{actor(0,-5,0,16)});c.Audit.coverage(blocked,wr,{})
check(blocked.coverageLayers.Underneath==1,'rusher physically in ball path remains an underneath threat')
check(blocked.coverageLayers.LaneThreats==1,'near-release blocker keeps whole-path interception exposure')
check(not c.Audit.allowed(blocked),'rushing label cannot authorize a blocked throw')
check(c.Stop('COVERAGE_TEST'),'coverage cleanup')
-- Exhausting one final-solve heartbeat must preserve takeoff, not blacklist WR.
local retry=assert(io.open('experimental/auto_qb.lua')):read('*a')
local needle='    local shot;shot,why,receipt.failure=solve(selected.player,selected.shot.variant or selected.shot.mode)'
local at=assert(retry:find(needle,1,true))
retry=retry:sub(1,at-1)..[[    if not preJump and not controller.unified.testBudget then
        controller.unified.testBudget=true;setGate('NATIVE_FRAME_BUDGET');return
    end
]]..retry:sub(at)
local t=setup({source=retry,simulateJump=true,newJumpTimingDefaults=true,nativeModes={Dime=true},ff3={Profile='CASUAL',RiskMode='TRUST',PassPlan='DEEP',CloseBullet=false}})
Mock.qhum.UseJumpPower=true;Mock.qhum.JumpPower=50
t.ar.Position=Vector3.new(0,6,-30);t.ar.AssemblyLinearVelocity=Vector3.new(0,0,-10);t.dr.Position=Vector3.new(70,6,170)
local c=t.run();c.SetThrow(false);t.steps(12);c.SetThrow(true)
for i=1,40 do t.advance(1/60);t.drain();if #t.requests>0 then break end end
check(c.unified.testBudget and #t.requests==1,'transient final native budget recovers with exactly one packet')
check(Mock.jumpCount==1 and t.requests[1].qbVy>0,'budget recovery retains same observed rising jump')
check(not c.GetReport():find('FINAL_RELEASE_CHECK_BLOCKED',1,true),'budget omission does not become a blocked receiver')
check(c.Stop('BUDGET_TEST'),'budget-recovery cleanup')
print('PASS jump/coverage regression checks',checks,'(synthetic; no live outcome claim)')
