-- Rounded, constructed coverage scenes; no private report or live catch claim.
local setup=dofile('tests/experimental/fixtures/ff3_league_fixture.lua')
local checks=0
local function check(ok,label)checks=checks+1;assert(ok,label)end
local current=assert(io.open('experimental/auto_qb.lua')):read('*a')
local pipe=assert(io.popen('git show experimental-unified-b3.6:experimental/auto_qb.lua'));local old=pipe:read('*a');pipe:close()
local function run(source,kind,ease)
 local options={source=source,newSafetyDefaults=true,newSharedCoverageDefaults=true,newJumpTimingDefaults=true,newReactiveDefaults=true,nativeModes={Bullet=true,Dime=true},ff3={Profile='CASUAL',RiskMode=kind=='SAFE' and 'SAFE' or 'TRUST',CloseBullet=false}}
 local t=setup(options)
 Mock.qroot.Position=Vector3.new(38,6,125)
 t.ar.Position=Vector3.new(46,6,-6);t.ar.AssemblyLinearVelocity=Vector3.new(7,0,-19)
 t.dr.Position=Vector3.new(39,6,-3);t.dr.AssemblyLinearVelocity=Vector3.new(10,0,-17)
 local _,second=t.addDB('Trailing',Vector3.new(43,6,1),Vector3.new(3,0,-20),20)
 if kind=='OPEN' then
  t.dr.Position=Vector3.new(-70,6,170);second.Position=Vector3.new(-65,6,170)
 elseif kind=='HIGH' then
  t.dr.Position=Vector3.new(46,6,-60);t.dr.AssemblyLinearVelocity=Vector3.new()
  second.Position=Vector3.new(-65,6,170)
 end
 local c=t.run();c.SetThrow(false);if ease==false then c.SetOpenComfort(false)end
 t.steps(8);c.SetThrow(true);t.steps(4)
 return t,c,t.payload()
end
local t,c,p=run(old,'CONTEST')
check(p and p.Mode=='Bullet','old controller selects low Bullet over less-exposed admitted Dime')
check(c.Stop('OLD_COMPARE'),'old comparison cleanup')
for _,ease in ipairs({true,false})do
 t,c,p=run(current,'CONTEST',ease)
 check(p and p.Mode=='Dime','current controller prioritizes native path clearance before catch-height comfort')
 check(math.abs(p.Lead[2]-7.1)<1e-5,'selected Dime preserves configured Y lead')
 check(c.bad.current.Final.Native.EffectiveYLead>7,'returned Dime actually honors requested positive height')
 check(c.bad.current.Final.Result.Score.RiskDebt==c.bad.current.Final.Result.RiskScore,'rank uses existing computed clearance debt with no new weight')
 check(#t.requests==1 and t.payload().Risk=='TRUST','TRUST and one-request safeguards remain functional')
 check(c.Stop('CONTEST'),'current contest cleanup')
end
for _,kind in ipairs({'OPEN','HIGH','SAFE'})do
 t,c,p=run(current,kind)
 if kind=='OPEN'then
  check(p and p.Mode=='Bullet','wide-open deep throw retains comfortable flat native option')
  check(c.bad.current.Final.Result.Score.RiskDebt==0,'wide-open paths have no debt bonus for extra loft')
 elseif kind=='HIGH'then
  check(not p or p.Mode=='Bullet','high-safety policy cannot be bypassed by lower modeled path debt')
 else
  check(not p,'ranking change does not authorize SAFE mode contest throws')
 end
 check(c.Stop(kind),'scenario cleanup')
end
-- Isolate ranking without Roblox: safety admission wins before any debt score.
local E=dofile('experimental/decision_engine.lua')
local low={unified={Allowed=true,Score={RiskTier=1,RiskDebt=20,Development=0,RouteStability=0,ComfortDeficit=0,CatchHeight=0,ExcessLoft=0,RelativeSpeed=75,ContestGap=-5,PassDistance=54,Flight=1.76}}}
local elevated={unified={Allowed=true,Score={RiskTier=1,RiskDebt=9,Development=0,RouteStability=0,ComfortDeficit=0,CatchHeight=7.1,ExcessLoft=0,RelativeSpeed=74,ContestGap=-5,PassDistance=54,Flight=1.80}}}
check(E.better(elevated,low) and not E.better(low,elevated),'same-risk-tier native exposure beats automatic low-height preference')
elevated.unified.Allowed=false
check(E.better(low,elevated),'a rejected elevated path never wins by score')
elevated.unified.Allowed=true;low.unified.Score.RiskTier=0;low.unified.Score.RiskDebt=0
check(E.better(low,elevated),'strict clear completion outranks a less-exposed contested alternative')
print('PASS trajectory-ranking regression checks',checks,'(synthetic; live Dime safety/catchability unverified)')
