-- Source-shaped native outputs reproduce an advisory crash on QB acquisition.
-- Geometry is synthetic; it does not simulate a server safety or prove a catch.
local setup=dofile('tests/experimental/fixtures/ff3_league_fixture.lua')
local checks=0
local function check(value,label)checks=checks+1;assert(value,label)end
local function read(path)local f=assert(io.open(path));local s=f:read('*a');f:close();return s end
local pipe=assert(io.popen('git show experimental-unified-b4.1:experimental/auto_qb.lua'))
local old=pipe:read('*a');pipe:close()
local current=read('experimental/auto_qb.lua')
local function scene(source,noDefenders)
 source=source:gsub('local built,buildError=pcall%(function%(%)',[[controller.GuideAudit={
    Cache=function(player)return shotCache[player]end,
    Sample=function(player)return samples[player]end,
    State=function()return possession,assistance end,
};local built,buildError=pcall(function()]],1)
 local t
 local options={source=source,newSafetyDefaults=true,newSharedCoverageDefaults=true,
  nativeModes={Bullet=true,Dime=true},unreachable=true,
  ff3={Profile='CASUAL',RiskMode='TRUST',AdaptiveAngle=false}}
 options.modeShots=function(mode,model,origin)
  local root=model.PrimaryPart
  local lead=t.leads[mode]
  local motion=Vector3.new(root.AssemblyLinearVelocity.X,0,root.AssemblyLinearVelocity.Z)
  local time=1;local aim,velocity
  -- Same low ballistic solve for both stages. Only the native target's lateral
  -- displacement changes: first it is unreachable by the actual WR, then it
  -- follows that WR normally. Both tuples remain finite/coherent and <=95.
  for _=1,12 do
   aim=model:FindFirstChild('Head').Position+motion*time
       +(motion.Magnitude>0 and motion.Unit*lead.X or Vector3.new())
       +Vector3.new(options.unreachable and 60 or 0,lead.Y,0)
   local delta=aim-origin;local flat=Vector3.new(delta.X,0,delta.Z)
   local range=flat.Magnitude;local speed=95
   local disc=speed^4-28*(28*range*range+2*delta.Y*speed*speed)
   if disc<0 or range<=0 then return end
   local angle=math.atan((speed*speed-math.sqrt(disc))/(28*range))
   velocity=flat.Unit*(speed*math.cos(angle))+Vector3.new(0,speed*math.sin(angle),0)
   time=range/(speed*math.cos(angle))
  end
  -- Native #7 is the pre-vertical-lead point, independent of actual arrival.
  return {time=time,power=95,velocity=velocity,aimpoint=aim-Vector3.new(0,lead.Y,0)}
 end
 t=setup(options)
 t.ar.Position=Vector3.new(0,6,-20);t.ar.AssemblyLinearVelocity=Vector3.new(0,0,-12)
 t.dr.Position=Vector3.new(70,6,170);t.dr.AssemblyLinearVelocity=Vector3.new()
 if noDefenders then t.db.Neutral=true end
 t.tool.Parent=nil -- execute before becoming QB
 local c=t.run();t.steps(8)
 return t,c
end

local t,c=scene(old)
check(not c.IsStopped and #t.requests==0,'published B4.1 is alive before QB acquisition')
t.tool.Parent=t.me.Character;t.steps(12)
local report=c.GetReport()
check(c.IsStopped and report:find('STOP_REASON|GUIDE_RUNTIME_ERROR',1,true),'published B4.1 reproduces the advisory crash after equipping the ball')
check(report:find('attempt to compare number',1,true),'old failure is the missing numeric coverage comparison')
check(report:find('COVERAGE_GRADES|0',1,true),'old crash occurs before any valid coverage grade')
check(report:find('RECEIVER_CANNOT_REACH_NATIVE_ARRIVAL',1,true),'native tuples were rejected for WR reach rather than graded')
check(#t.requests==0,'old crash sends no automatic request')
check(c.Stop('OLD_GUIDE_CRASH'),'published crash cleanup remains confirmed')

t,c=scene(current)
check(not c.IsStopped and #t.requests==0,'current controller remains alive before QB acquisition')
t.tool.Parent=t.me.Character;local maximum=t.steps(12)
report=c.GetReport()
check(not c.IsStopped,'ungraded native cache cannot stop current QB automation')
check(report:find('RECEIVER_CANNOT_REACH_NATIVE_ARRIVAL',1,true),'current fixture exercises the same reach rejection')
check(report:find('COVERAGE_GRADES|0',1,true),'raw outputs are not assigned fabricated coverage grades')
check(report:find('GUIDE_VISIBLE|false',1,true),'an ungraded trajectory produces no misleading movement arrow')
check(#t.requests==0,'no unsafe throw is sent while all native targets are unreachable')
local cache=c.GuideAudit.Cache(t.a);local sample=c.GuideAudit.Sample(t.a)
check(cache and sample and (cache.shots.Bullet or cache.shots.Dime),'finite raw native tuple remains available as planning evidence')
local raw=cache.shots.Bullet or cache.shots.Dime
check(raw.margin==nil and raw.lane==nil and raw.unified==nil,'raw tuple is demonstrably ungraded, not a rejected score disguised as ready')
local missing=c.unified.Guard(raw)
check(not missing.Allowed and missing.Reason=='COVERAGE_GRADE_MISSING','public native guard fails closed on a real raw cached tuple')
check(raw.margin==nil and raw.lane==nil and raw.unified==nil,'guard does not manufacture missing coverage values')
check(not c.groundGuide.SelectShot({player=t.a,sample=sample,shot=raw},Mock.time),'guide selection refuses an ungraded primary and raw cached alternatives')
local possession=c.GuideAudit.State();local epoch=possession.epoch
-- Recover through actual planning/native/final checks with the same equipped
-- ball, without restarting the script, changing teams or toggling automation.
t.options.unreachable=false
for _=1,30 do maximum=math.max(maximum,t.advance(.13));t.drain();if #t.requests>0 then break end end
local after=c.GuideAudit.State()
check(not c.IsStopped and after.epoch==epoch,'same controller and possession recover when a real native opportunity becomes reachable')
check(#t.requests==1,'normal automatic release still works after the raw-cache advisory path')
check(c.bad.current.Final and c.bad.current.Final.Checks.Status=='ALL_RELEASE_GUARDS_PASSED','recovery uses actual final native/context/coverage checks')
check(maximum<=8,'guide readiness repair adds no native calls beyond the existing cap')
check(t.q.AutoThrowType.Enabled and t.q.ManualType=='Angle' and t.q.Power==95,'native automatic mode and scoped controls remain restored after recovery')
check(c.Stop('GUIDE_READINESS'),'current guide/readiness cleanup remains confirmed')
-- An infinite defender ETA is normal when there are no reachable defenders;
-- readiness must validate the graded path fields rather than reject that fact.
t,c=scene(current,true);t.options.unreachable=false;t.tool.Parent=t.me.Character
t.steps(16)
check(not c.IsStopped and #t.requests==1,'graded no-defender opportunity remains throwable')
check(c.bad.current.Final.Result.Guard.NoReachableDefender,'no-defender grade preserves its explicit infinite-ETA meaning')
check(c.Stop('NO_DEFENDER_GRADE'),'no-defender readiness cleanup')
print('PASS guide readiness',checks,'checks (native mock; no claim about live safety prevention or catchability)')
