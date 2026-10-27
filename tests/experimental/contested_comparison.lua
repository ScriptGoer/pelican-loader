-- Native comparison scheduling contracts; no live catch or interception claim.
local setup=dofile('tests/experimental/fixtures/ff3_league_fixture.lua')
local source=assert(io.open(os.getenv('PELICAN_COMPARISON_SOURCE') or 'experimental/auto_qb.lua')):read('*a')
local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
source=source:gsub('local function solve%(player,mode%)',[[local function solve(player,mode)
    if controller.unified.ComparisonProbeTrace then
        controller.unified.ComparisonProbeTrace[#controller.unified.ComparisonProbeTrace+1]=mode
    end
]],1)
source=source:gsub('local function tick%(now,cachedOnly%)',[[controller.unified.ComparisonAudit={
    Cache=function(p)return shotCache[p]end,Sample=function(p)return samples[p]end,
    SetCalls=function(n)frameCalls=n end,Calls=function()return frameCalls end,Solve=solve,
}
local function tick(now,cachedOnly)]],1)
local function scene(unsupported)
 local t=setup({source=source,newSafetyDefaults=true,newSharedCoverageDefaults=true,
  nativeModes=unsupported and {Bullet=true} or nil,ff3={Profile='CASUAL',RiskMode='TRUST',CloseBullet=false}})
 t.ar.Position=Vector3.new(0,6,-30);t.ar.AssemblyLinearVelocity=Vector3.new(0,0,-10)
 t.dr.Position=Vector3.new(70,6,170)
 local c=t.run();c.SetThrow(false);t.steps(8)
 local audit=c.unified.ComparisonAudit
 local cache=assert(audit.Cache(t.a),'warm sample has native work cache')
 local sample=assert(audit.Sample(t.a),'warm sample is eligible')
 local template=assert(cache.shots.Bullet or cache.shots.Dime,'native tuple exists')
 local fake={};for k,v in pairs(template)do fake[k]=v end
 fake.mode='Bullet';fake.variant='Bullet';fake.margin=-1;fake.lane=-1;fake.trustBurn=nil;fake.fitAllowed=false
 fake.unified={Allowed=false,Reason='REQUIRES_CHECKED_COMPARISON',Score=template.unified.Score,
  Guard={Allowed=false,Strict=false}}
 local best={player=t.a,sample=sample,shot=fake}
 cache.shots.Dime=nil;cache.modeAt.Dime=Mock.time-.133
 cache.modeAt.CoverageJump=nil;cache.modeAt.LoftDime=nil
 c.unified.ComparisonProbeTrace={};audit.SetCalls(0)
 return t,c,best,cache,audit
end

-- A core Dime rejected at the previous planning tick must be retried before
-- optional Jump/loft probes. This timing matches the captured omission without
-- redistributing raw report contents or assuming the unthrown Dime would catch.
for _,variant in ipairs({'Bullet','Fit','LoftDime'})do
 local t,c,best,cache,audit=scene(false)
 best.shot.variant=variant;best.shot.mode=variant=='LoftDime' and 'Dime' or variant
 check(c.unified.CompareLoft(best,Mock.time,{audit.Sample(t.db)}),'comparison completes for rejected '..variant)
 check(c.unified.ComparisonProbeTrace[1]=='Dime','ordinary Dime precedes optional native paths for '..variant)
 check(#c.unified.ComparisonProbeTrace==1,'strict actual ordinary Dime needs no optional loft probe for '..variant)
 check(best.shot.variant=='Dime' and best.shot.unified.Allowed and best.shot.unified.Guard.Strict,'actual validated Dime becomes admissible finalist for '..variant)
 check(math.abs(best.shot.appliedLead.Y-t.leads.Dime.Y)<.001,'Dime retains its own configured lead for '..variant)
 check(#t.requests==0,'comparison never sends a packet for '..variant)
 check(audit.Calls()==1 and t.q.AutoThrowType.Enabled and t.q.ManualType=='Angle','one native probe restores scoped controls for '..variant)
 check(c.Stop('CORE_COMPARISON'),'comparison cleanup '..variant)
end

-- The guard must distinguish permission from geometry. A comfort/plan-vetoed
-- candidate with strict geometry is still eligible for another native option.
local t,c,best,cache,audit=scene(false)
best.shot.unified.Guard.Strict=true
check(c.unified.CompareLoft(best,Mock.time,{audit.Sample(t.db)}) and c.unified.ComparisonProbeTrace[1]=='Dime','strict geometry alone cannot hide a rejected candidate comparison')
check(c.Stop('GEOMETRY_ONLY'),'geometry-only cleanup')
t,c,best,cache,audit=scene(false)
best.shot.unified.Allowed=true;best.shot.unified.Guard.Strict=true
check(c.unified.CompareLoft(best,Mock.time,{audit.Sample(t.db)}) and #c.unified.ComparisonProbeTrace==0,'an admitted strict completion receives no forced Dime delay')
check(c.Stop('ALREADY_STRICT'),'strict completion cleanup')

-- A core native tuple already regraded in the main cohort is not redundantly
-- replaced. A failed extra solve must not erase a useful current comparison.
t,c,best,cache,audit=scene(false)
local fresh=assert(audit.Solve(t.a,'Dime'))
cache.shots.Dime=fresh;cache.modeAt.Dime=Mock.time-.133
cache.modeAt.CoverageJump=Mock.time;cache.modeAt.LoftDime=Mock.time
audit.SetCalls(0);c.unified.ComparisonProbeTrace={}
check(c.unified.CompareLoft(best,Mock.time,{audit.Sample(t.db)}),'fresh already-graded Dime does not need supplementation')
check(#c.unified.ComparisonProbeTrace==0 and cache.shots.Dime==fresh,'fresh valid core retains its comparison instead of redundant native retry')
fresh.at=Mock.time-.37
audit.SetCalls(0)
check(c.unified.CompareLoft(best,Mock.time,{audit.Sample(t.db)}),'stale core can be refreshed')
check(#c.unified.ComparisonProbeTrace==1 and c.unified.ComparisonProbeTrace[1]=='Dime' and cache.shots.Dime~=fresh,'a stale native Dime is actually replaced by a checked fresh solve')
check(c.Stop('CORE_FRESHNESS'),'core freshness cleanup')

-- Repeated failures are bounded by the existing planning interval. No result
-- is manufactured safe, and optional native paths can be explicitly disabled.
t,c,best,cache,audit=scene(true)
c.nativeJump.enabled=false;c.angle.enabled=false
check(c.unified.CompareLoft(best,Mock.time,{audit.Sample(t.db)}),'unsupported Dime is recorded without forcing an option')
check(#c.unified.ComparisonProbeTrace==1 and c.unified.ComparisonProbeTrace[1]=='Dime','unsupported core consumes one bounded attempt')
check(cache.shots.Dime==nil and not best.shot.unified.Allowed and #t.requests==0,'failed Dime remains absent and cannot authorize a throw')
local row=c.bad.frame.Rows[c.bad:token(t.a.Name)..'/Dime']
check(row.NativeStatus=='SOLVER_REJECTED' and row.NativeInvoked==true,'native failure remains distinct from a budget omission')
Mock.time=Mock.time+.05;audit.SetCalls(0)
c.unified.CompareLoft(best,Mock.time,{audit.Sample(t.db)})
check(#c.unified.ComparisonProbeTrace==1,'reactive callback cannot repeatedly retry a fresh failed core')
Mock.time=Mock.time+.083;audit.SetCalls(0)
c.unified.CompareLoft(best,Mock.time,{audit.Sample(t.db)})
check(#c.unified.ComparisonProbeTrace==2,'changing opportunity can retry at existing planning cadence')
check(c.Stop('FAILED_CORE'),'failed-core cleanup')

-- A missing comparison at the native cap remains explicitly omitted; it does
-- not stamp the mode as tried, erase the prior failure, or send cached data.
t,c,best,cache,audit=scene(false)
local attemptedAt=cache.modeAt.Dime;audit.SetCalls(8)
check(not c.unified.CompareLoft(best,Mock.time,{audit.Sample(t.db)}),'native cap defers the missing core comparison')
check(#c.unified.ComparisonProbeTrace==0 and audit.Calls()==8,'omission invokes no solver beyond cap')
check(cache.modeAt.Dime==attemptedAt and not cache.shots.Dime,'omission is not a new native attempt')
row=c.bad.frame.Rows[c.bad:token(t.a.Name)..'/Dime']
check(row.Reason=='NATIVE_FRAME_BUDGET' and row.NativeStatus=='BUDGET_NOT_ATTEMPTED','budget omission is preserved through cohort finalization')
check(#t.requests==0 and c.Stop('CAP'),'budget omission cleanup without packet')
print('PASS contested ordinary-Dime comparison',checks,'checks (native mock; live trajectory/catchability unverified)')
