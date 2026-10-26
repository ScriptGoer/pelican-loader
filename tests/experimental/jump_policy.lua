local setup=dofile('tests/experimental/fixtures/ff3_league_fixture.lua')
local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
local function scene(mode,contest)
 local t=setup({simulateJump=true,newSafetyDefaults=true,newSharedCoverageDefaults=true,newJumpTimingDefaults=true,newReactiveDefaults=true,nativeModes={[mode]=true},ff3={Profile='CASUAL',RiskMode='TRUST',CloseBullet=false}})
 Mock.qhum.UseJumpPower=true;Mock.qhum.JumpPower=50
 Mock.qroot.Position=Vector3.new(38,6,125)
 t.ar.Position=Vector3.new(46,6,-6);t.ar.AssemblyLinearVelocity=Vector3.new(7,0,-19)
 t.dr.Position=Vector3.new(-70,6,170)
 if contest then
  t.dr.Position=Vector3.new(39,6,-3);t.dr.AssemblyLinearVelocity=Vector3.new(10,0,-17)
  t.addDB('Trailing',Vector3.new(43,6,1),Vector3.new(3,0,-20),20)
 end
 local c=t.run();c.SetThrow(false);t.steps(8);c.SetThrow(true)
 for i=1,90 do t.advance(1/60);t.drain();if #t.requests>0 then break end end
 return t,c,t.payload()
end
local t,c,p=scene('Bullet',false)
check(p and p.Mode=='Bullet' and #t.requests==1,'deep Bullet still automatically releases')
check((Mock.jumpCount or 0)==0,'no automatic QB jump for deep Bullet')
check(not p.JumpObservedDelay and not c.bad.current.PreJump,'Bullet has no jump preflight or takeoff wait')
check(c.Stop('BULLET_TEST'),'Bullet cleanup')
t,c,p=scene('Dime',true)
check(p and p.Mode=='Dime' and #t.requests==1,'admitted TRUST Dime releases when jump confidence is insufficient')
check((Mock.jumpCount or 0)==0 and t.requests[1].qbVy==0,'contested Dime does not auto jump or wait for takeoff')
check(c.bad.current.PreJump.AutoJump.Allowed==false and c.bad.current.PreJump.AutoJump.Reason=='NO_STRICT_CLEAR_WINDOW','BAD evidence records why jump was skipped separately from throw permission')
check(c.Stop('CONTEST_TEST'),'contest cleanup')
t,c,p=scene('Dime',false)
check(p and p.Mode=='Dime' and (Mock.jumpCount or 0)==1,'strict clear native Dime keeps one ordinary auto jump')
check(p.JumpObservedDelay>=.075 and p.JumpObservedDelay<.12 and t.requests[1].qbVy>0,'eligible non-Bullet keeps observed short-offset ascending release')
check(c.bad.current.PreJump.AutoJump.Allowed and c.bad.current.PreJump.AutoJump.Reason=='FRESH_STRICT_NATIVE_WINDOW','jump authorization proof recorded')
local policy=c.unified.AutoJumpAllowed
for _,shot in ipairs({{mode='Bullet'},{mode='Bullet',softBullet=true},{mode='Bullet',jumpBullet=true},{mode='Jump',nativeCoverageJump=true},{mode='Dime',screen=true}})do
 shot.unified={Allowed=true,Guard={Strict=true}}
 check(not policy(shot,{}),'all Bullet and screen variants excluded even with a strict window')
end
local shot={mode='Dime',unified={Allowed=true,Guard={Strict=true}}}
check(not policy(shot,{oscillation=true}),'oscillating receiver cannot authorize a fresh auto jump')
check(not policy(shot,{routeTurn=.5}),'turning receiver cannot authorize a fresh auto jump')
shot.unified.Developing={Seconds=.18}
check(not policy(shot,{}),'developing prediction cannot authorize a fresh auto jump')
shot.unified.Developing=nil
check(not policy(shot,{},nil),'unverified normal jump physics cannot authorize auto jump')
t.options.jumpDisabled=true
check(not policy(shot,{},Mock.qhum),'disabled normal jump skips auto jump')
check(c.Stop('CLEAR_TEST'),'clear-window cleanup')
print('PASS conservative Auto Jump policy checks',checks,'(synthetic; no certainty about future gameplay)')
