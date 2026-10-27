-- Source-shaped native arithmetic: under/deep layers are geometry, not assigned roles.
local setup=dofile('tests/experimental/fixtures/ff3_league_fixture.lua')
local checks=0
local function check(v,msg) checks=checks+1;assert(v,msg) end
local function scene(profile)
    local t=setup({ff3={Profile=profile or 'LEAGUE',RiskMode='SAFE',CloseBullet=false}})
    t.ar.Position=Vector3.new(0,6,-70);t.ar.AssemblyLinearVelocity=Vector3.new(0,0,-6)
    t.dr.Position=Vector3.new(-8,6,35)
    t.addDB('LB2',Vector3.new(8,6,35))
    local _,s1=t.addDB('S1',Vector3.new(-40,6,-85));local _,s2=t.addDB('S2',Vector3.new(40,6,-85))
    t.s1,t.s2=s1,s2
    return t
end
local t=scene();local c=t.run();local max=t.steps(20);local p=t.payload()
if not p then print(c.GetReport()) end
check(p and p.Mode=='Fit' and p.FitReason=='TIMING_RESCUE','actual native Fit threads the strict window before the configured loft alternative is intercepted')
check(p.FitComparison=='LoftDime' and p.FitSecondComparison==nil,'actual release retains the proven late native loft counterfactual')
check(p.Margin>=6 and p.Lane>=4 and p.CoverageLayers.Underneath==0 and p.CoverageLayers.Deeper>=2,'safe Fit clears underneath threats; opponent depth alone does not label active coverage')
check(math.abs(p.Power-95)<1e-7 and p.Lead[1]==6 and p.Lead[2]==8,'native Fit keeps its real low-branch power and configured lead')
check(max<=8 and #t.requests==1,'fresh comparison and final native calls stay within eight per frame')
local n=#Mock.nativeSolveHistory
check(Mock.nativeSolveHistory[n].mode=='Fit' and Mock.nativeSolveHistory[n-1].mode=='Dime','fresh configured Dime comparison then actual Fit solve in final release')
check(Mock.nativeSolveHistory[n].at==Mock.nativeSolveHistory[n-1].at,'final comparison and actual Fit share the same modeled physics frame')
check(c.Stop('WINDOW'),'coverage-window cleanup')
-- This broadened Fit reason is league-only; previous casual timing rule remains.
t=scene('CASUAL');c=t.run();t.steps(20);p=t.payload()
check(not p or p.FitReason~='COVERAGE_WINDOW_BETWEEN_LAYERS','casual path does not silently gain league-only Fit eligibility')
check(c.Stop('CASUAL'),'casual comparison cleanup')
-- Pure eligibility requires supported bad alternatives, not just an open-looking pocket.
t=scene();c=t.run()
local function shot(mode,margin,lane,eta)
    return {mode=mode,variant=mode,time=1,margin=margin or 9,lane=lane or 8,defenderETA=eta or 2,safetyOverTop=false}
end
local fit=shot('Fit');local chest=shot('Bullet',8,-1);local dime=shot('Dime',-2,5)
check(c.fit.assess(fit,{chest,dime}) and fit.fitSecondVariant=='Dime','two actual unsafe modes can justify strict safe coverage Fit')
check(not c.fit.assess(fit,{chest}),'missing Dime cannot be invented as an unsafe alternative')
check(not c.fit.assess(fit,{dime}),'missing normal Bullet cannot prove a threatened chest lane')
check(not c.fit.assess(fit,{chest,shot('Dime')}),'safe Dime vetoes unnecessary coverage Fit')
check(not c.fit.assess(fit,{shot('Bullet'),dime}),'safe Bullet vetoes unnecessary coverage Fit')
check(not c.fit.assess(shot('Fit',-1,8),{chest,dime}),'unsafe Fit never qualifies from formation names')
check(c.Stop('PROOFS'),'proof checks cleanup')
for _,kind in ipairs({'SAFETY_CLOSES','LANE_DEFENDER','ALTERNATIVES_OPEN','RECEIVER_STOPS','PROFILE_CHANGED','DIME_UNSUPPORTED'}) do
    t=scene();c=t.run();local changed=false
    if kind=='DIME_UNSUPPORTED' then t.options.nativeModes={Bullet=true,Fit=true,Jump=true} end
    t.options.duringSolve=function()
        if not changed and not Mock.inNativePreview and Mock.lastMode=='Dime' and c.GetReport():find('RELEASE_PREPARED|true',1,true) then
            changed=true
            if kind=='SAFETY_CLOSES' then t.s1.Position=t.ar.Position
            elseif kind=='LANE_DEFENDER' then t.dr.Position=Vector3.new(0,6,60)
            elseif kind=='ALTERNATIVES_OPEN' then
                for _,d in ipairs(Mock.roster) do if d.Team==Mock.other then d.Character.PrimaryPart.Position=Vector3.new(70,6,-160) end end
            elseif kind=='RECEIVER_STOPS' then t.ar.AssemblyLinearVelocity=Vector3.new()
            elseif kind=='PROFILE_CHANGED' then c.SetProfile('CASUAL','USER') end
        end
    end
    max=t.steps(20);p=t.payload()
    check(not p or p.FitReason~='COVERAGE_WINDOW_BETWEEN_LAYERS','final evidence or compatibility change blocks original coverage Fit: '..kind)
    check(kind=='DIME_UNSUPPORTED' or changed,'final comparison stage actually exercised: '..kind)
    check(max<=8 and c.Stop(kind),'bounded refusal cleanup '..kind)
end
-- Ping is charged to defender pursuit in league instead of pretending zero delivery latency.
t=setup({ping=.2});c=t.run();c.SetThrow(false)
t.ar.Position=Vector3.new(0,6,0);t.ar.AssemblyLinearVelocity=Vector3.new(6,0,0);t.steps()
check(c.GetReport():find('LEAGUE_COVERAGE_POLICY|WHOLE_NATIVE_PATH_AND_ARRIVAL; DEFENDER_PING_BUDGET',1,true),'report states latency-aware geometric coverage and its model scope')
check(c.Stop('PING'),'ping scene cleanup')
-- Real released stationary-screen receipt: ping is charged once, including wide surplus.
t=setup({ping=.2});t.dr.Position=Vector3.new(30,6,75);c=t.run();t.steps();check(c.SelectScreen(t.a),'latency comparison screen armed')
t.steps();p=t.payload()
check(p and p.Screen and p.Ping==.2,'latency scene releases a valid explicitly armed screen')
local d=p.Defenders[1];local dx,dz=p.Arrival[1]-d.Position[1],p.Arrival[3]-d.Position[3]
local expected=math.sqrt(dx*dx+dz*dz)-d.WalkSpeed*(p.Time+p.Ping)-4.5
check(math.abs(p.Margin-expected)<.00001,'actual endpoint pursuit includes defender movement during delivery ping')
check(math.abs(p.WideMargin-p.Margin)<.00001 and math.abs(p.WideLane-p.Lane)<.00001,'wide-open surplus does not double charge league latency')
check(c.Stop('PING_RECEIPT'),'latency receipt cleanup')
print('FF3 league layered-coverage checks passed:',checks,'(mocked; exact server interception reach remains unverified)')
