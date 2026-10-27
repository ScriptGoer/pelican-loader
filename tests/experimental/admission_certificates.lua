-- Constructed policy cases, not evidence of a live catch or interception.
local setup=dofile('tests/experimental/fixtures/ff3_league_fixture.lua')
local t=setup({ff3={Profile='CASUAL',RiskMode='TRUST'}})
local E=dofile('experimental/decision_engine.lua')
local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
local function score(values)
 local s={RiskTier=1,RiskDebt=10,Development=0,RouteStability=0,ComfortDeficit=0,CatchHeight=7.1,
  ExcessLoft=3,RelativeSpeed=80,ContestGap=-4,PassDistance=46,Flight=1.75}
 for k,v in pairs(values or {})do s[k]=v end
 return s
end
local function candidate(variant,guard,values)
 local s={mode='Dime',variant=variant,unified={Score=score(values)}}
 E.admit(s,guard);return s
end
-- Rounded fields reproduce the *policy conflict* in the captured B3.10 scene.
-- The native solver itself is deliberately not reconstructed from screenshots.
local contest={Allowed=true,Strict=false,Reason='TRAILING_CORNER_ADVANTAGE',Margin=-6,Lane=-10,
 TrustBurn={Allowed=true,Gap=4,ProjectedGap=4}}
local native=candidate('Dime',contest,{Flight=1.75,RiskDebt=16})
local loft=candidate('LoftDime',contest,{Flight=2.94,RiskDebt=4,ExcessLoft=20})
check(native.unified.Allowed,'ordinary native Dime preserves the verified guard permission')
check(native.unified.AdmissionKind=='QUALIFIED_TRAILING_BURN','ordinary burn has an explicit admission certificate')
check(not loft.unified.Allowed,'configured loft cannot reuse ordinary Dime trailing contest permission')
check(loft.unified.Reason=='LOFT_REQUIRES_CLEAR_WINDOW','configured loft rejection preserves a precise policy reason')
check(loft.unified.AdmissionKind=='REJECTED','unsupported loft contest is identified as rejected')
check(E.better(native,loft) and not E.better(loft,native),'unsafe loft cannot beat admitted native Dime through a lower clearance debt')
local _,reason=E.compare(native,loft)
check(reason=='RELEASE_PERMISSION','comparison can report why the finalist won')
for _,mode in ipairs({'SAFE','MOD','TRUST'})do
 local guard={Allowed=true,Strict=true,Reason='CLEAR_NATIVE_WINDOW'}
 local clear=candidate('LoftDime',guard,{RiskTier=0,RiskDebt=0})
 check(clear.unified.Allowed,'strict configured loft remains available in '..mode)
 check(clear.unified.AdmissionKind=='STRICT_CLEAR_WINDOW','strict configured loft has clear-window certificate in '..mode)
 guard.Allowed=false
 E.admit(clear,guard)
 check(not clear.unified.Allowed,'strict geometry cannot bypass another actual release check in '..mode)
end
local clear=candidate('LoftDime',{Allowed=true,Strict=true},{RiskTier=0,RiskDebt=0})
clear.unified.HardReason='NATIVE_BOUNDARY_ROUTE_ADJUSTMENT'
E.admit(clear,{Allowed=true,Strict=true})
check(not clear.unified.Allowed and clear.unified.Reason=='NATIVE_BOUNDARY_ROUTE_ADJUSTMENT','explicit invalid placement always vetoes strict loft')
local low=candidate('Bullet',contest,{Flight=1.76,RiskDebt=20,CatchHeight=0})
local elevated=candidate('Dime',contest,{Flight=1.80,RiskDebt=9,CatchHeight=7.1})
check(E.better(elevated,low),'supported native Dime retains less-exposed-path preference over a low Bullet')
local slower=candidate('Dime',contest,{Flight=2,RiskDebt=9,CatchHeight=7.1})
check(E.better(elevated,slower),'equivalent native catch trajectories prefer earlier arrival')
local open={Allowed=true,Strict=true}
local comfy=candidate('SoftBullet',open,{RiskTier=0,RiskDebt=0,Flight=1.0,CatchHeight=0,ExcessLoft=0,RelativeSpeed=60})
local laser=candidate('Bullet',open,{RiskTier=0,RiskDebt=0,Flight=.9,CatchHeight=0,ExcessLoft=0,RelativeSpeed=95})
check(E.better(comfy,laser),'wide-open delivery retains lower relative catch speed over fastest-first selection')
local immediate=candidate('Dime',contest,{Development=0})
local developing=candidate('Dime',contest,{Development=1})
check(E.better(immediate,developing),'a ready eligible opportunity beats an explicitly developing opportunity')
-- Comparator consistency over a mixed admissible/rejected finalist set.
local candidates={native,loft,low,elevated,slower,comfy,laser,immediate,developing,clear}
local irreflexive,antisymmetric,transitive=true,true,true
for _,a in ipairs(candidates)do
 irreflexive=irreflexive and not E.better(a,a)
 for _,b in ipairs(candidates)do
  antisymmetric=antisymmetric and not(E.better(a,b) and E.better(b,a))
  for _,c in ipairs(candidates)do
   transitive=transitive and (not(E.better(a,b) and E.better(b,c)) or E.better(a,c))
  end
 end
end
check(irreflexive,'ranking is irreflexive across mixed certificates')
check(antisymmetric,'ranking cannot prefer both sides across mixed certificates')
check(transitive,'ranking is transitive across mixed certificates')
print('PASS admission certificate checks',checks,'(constructed policy only; native physics and live outcomes unverified)')
