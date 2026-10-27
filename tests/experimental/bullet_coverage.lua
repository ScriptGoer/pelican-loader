-- Rounded report-shaped geometry, no private report or live catch claim.
local setup=dofile('tests/experimental/fixtures/ff3_league_fixture.lua')
local current=assert(io.open('experimental/auto_qb.lua')):read('*a')
local h=assert(io.popen('git show experimental-unified-b4:experimental/auto_qb.lua'))
local old=h:read('*a');h:close()
local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
local function expose(source)
 local result,n=source:gsub('local built,buildError=pcall%(function%(%)',[[
controller.BulletAudit={risk=risk,coverage=coverage,allowed=throwable,
 forward=function(v)lines.forward=v end}
local built,buildError=pcall(function()]],1)
 assert(n==1);return result
end
local function actor(name,x,z,vx,vz,turn,observed)
 local p=Vector3.new(x,5.99,z)
 return {name=name,p=p,v=Vector3.new(vx,0,vz),head={Position=p+Vector3.new(0,1.5,0)},turn=turn or 0,
  routeTurn=turn or 0,observedSpeed=observed or math.sqrt(vx*vx+vz*vz),
  hum={WalkSpeed=20,JumpPower=50,FloorMaterial=Enum.Material.Ground}}
end
local function recordedBullet()
 local origin=Vector3.new(34.115,7.698,-84.549)
 local velocity=Vector3.new(31.931,14.823,88.237);local time=1.056935
 return {mode='Bullet',variant='Bullet',origin=origin,velocity=velocity,time=time,power=95,
  arrival=origin+velocity*time-Vector3.new(0,14*time*time,0),networkPing=.101,
  effectiveYLead=0,appliedLead=Vector2.new(2.8,0),receiverResidual=2.193,at=Mock.time}
end
for _,version in ipairs({'B4','CURRENT'})do
 local t=setup({source=expose(version=='B4' and old or current),newSafetyDefaults=true,newSharedCoverageDefaults=true,
  newJumpTimingDefaults=true,newReactiveDefaults=true,ff3={Profile='CASUAL',RiskMode='TRUST',CloseBullet=false}})
 local c=t.run();c.SetThrow(false);t.steps(12);local a=c.BulletAudit;a.forward(Vector3.new(0,0,1))
 local wr=actor('Runner',66.332,-16.593,1.213,19.963,.0113,20.086)
 local db=actor('CrossingDefender',62.740,-21.294,17.091,7.367,.1111,19.692)
 local shot=recordedBullet();a.risk(shot,wr,{db});a.coverage(shot,wr,{db})
 check(shot.margin<6 and shot.lane<0,'report-shaped path is not strict clear in '..version)
 check(shot.trustBurn and shot.trustBurn.Allowed and shot.trustBurn.Gap>4,'longitudinal-gap exception reproduces in '..version)
 check(shot.trustBurn.EarlyLane>0 and shot.trustBurn.EarlyPursuit<0,'crossing defender separates frozen-heading and reachable-path estimates in '..version)
 if version=='B4' then
  check(a.allowed(shot),'published B4 sends low path through the TRUST burn exception')
 else
  check(not a.allowed(shot) and shot.unified.Reason=='BULLET_REQUIRES_STRICT_COVERAGE','current refuses that actual non-strict low path')
  for _,risk in ipairs({'SAFE','MOD','TRUST'})do
   c.SetRiskMode(risk)
   for _,variant in ipairs({'Bullet','SoftBullet','QuickBullet'})do
    local s=recordedBullet();s.variant=variant;s.softBullet=variant~='Bullet'
    a.risk(s,wr,{db});a.coverage(s,wr,{db})
    check(not a.allowed(s),'ordinary and softer Bullets remain strict in '..risk..'/'..variant)
   end
  end
 end
 check(c.Stop('REPORT_SHAPED_BULLET'),'report-shaped controller cleanup '..version)
end
-- Exercise the actual native-shaped controller: strict open Bullets continue
-- automatically and contested actual elevated Dimes retain TRUST permission.
local function nativeScene(kind)
 local t=setup({source=current,newSafetyDefaults=true,newSharedCoverageDefaults=true,newJumpTimingDefaults=true,newReactiveDefaults=true,
  nativeModes=kind=='DIME' and {Dime=true} or {Bullet=true},ff3={Profile='CASUAL',RiskMode='TRUST',CloseBullet=false}})
 Mock.qroot.Position=Vector3.new(38,6,125)
 t.ar.Position=Vector3.new(46,6,-6);t.ar.AssemblyLinearVelocity=Vector3.new(7,0,-19)
 if kind=='DIME' then
  t.dr.Position=Vector3.new(39,6,-3);t.dr.AssemblyLinearVelocity=Vector3.new(10,0,-17)
  t.addDB('Trailing',Vector3.new(43,6,1),Vector3.new(3,0,-20),20)
 else t.dr.Position=Vector3.new(-70,6,170)end
 local c=t.run();c.SetThrow(false);t.steps(8);c.SetThrow(true);t.steps(12)
 return t,c,t.payload()
end
local t,c,p=nativeScene('DIME')
check(p and p.Mode=='Dime' and #t.requests==1,'a genuine elevated native Dime still automatically releases')
check(c.bad.current.Final.Native.EffectiveYLead>7 and c.bad.current.Final.Result.Guard.TrustBurn.Allowed,'elevated Dime retains qualified actual native burn evidence')
check(c.Stop('QUALIFIED_DIME'),'elevated Dime cleanup')
t,c,p=nativeScene('OPEN')
check(p and p.Mode=='Bullet' and #t.requests==1,'strict open ordinary native Bullet remains available')
check(c.bad.current.Final.Result.Guard.Strict,'open Bullet actually has strict path and arrival clearance')
check(c.Stop('STRICT_BULLET'),'strict native Bullet cleanup')
-- Admission is mode/geometry-aware, including when callers have no evaluator
-- yet. Merely renaming a flat trajectory cannot borrow the Dime allowance.
local E=dofile('experimental/decision_engine.lua')
local contest={Allowed=true,Strict=false,Reason='TRAILING_CORNER_ADVANTAGE',TrustBurn={Allowed=true}}
check(not E.admit({mode='Bullet'},contest),'missing evaluator does not waive the Bullet policy')
for _,mode in ipairs({'Dime','Fit','Jump'})do
 local shot={mode=mode,unified={FlatNative=true}}
 check(not E.admit(shot,contest) and shot.unified.Reason=='FLAT_NATIVE_REQUIRES_STRICT_COVERAGE','flat named '..mode..' requires the same strict native geometry')
 check(E.admit(shot,{Allowed=true,Strict=true}),'strict flat '..mode..' remains available')
end
local raised={mode='Dime',unified={FlatNative=false}}
check(E.admit(raised,contest),'actual elevated ordinary Dime retains qualified TRUST permission')
raised.unified.HardReason='NATIVE_BOUNDARY_ROUTE_ADJUSTMENT'
check(not E.admit(raised,contest),'elevated trajectory cannot override a placement veto')
print('PASS Bullet coverage',checks,'checks (synthetic geometry/native-shaped contracts; live catch outcome unverified)')
