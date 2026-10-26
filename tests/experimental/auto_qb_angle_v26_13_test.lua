-- Native-shaped arithmetic and safety checks; no Roblox/server catch proof.
local helpers=dofile('tests/experimental/fixtures/ff3_history_fixture.lua')
local checks=0
local function check(v,msg) checks=checks+1;assert(v,msg) end
local function has(c,s) return c.GetReport():find(s,1,true)~=nil end
local function scene(options)
    options=options or {};options.newAngleDefaults=true
    options.nativePower=true;options.nativeAngle=options.nativeAngle~=false;options.angleDegrees=true
    options.manualValue=true;options.preVerticalAimpoint=true
    options.ff3=options.ff3 or {};options.ff3.RiskMode=options.ff3.RiskMode or 'SAFE';options.ff3.CloseBullet=false;options.ff3.WideOpenJump=false
    local t=helpers.setup(nil,options)
    t.q.Power=95;t.ar.Position=Vector3.new(0,6,-30);t.ar.AssemblyLinearVelocity=Vector3.new(0,0,-10)
    t.br.AssemblyLinearVelocity=Vector3.new();t.dr.Position=Vector3.new(65,6,-160);t.dr.AssemblyLinearVelocity=Vector3.new()
    t.a.Character:FindFirstChildOfClass('Humanoid').WalkSpeed=20;t.db.Character:FindFirstChildOfClass('Humanoid').WalkSpeed=20
    function t.steps(n)
        local max,restored=0,true
        for _=1,n or 16 do
            max=math.max(max,t.advance(.13));t.drain()
            restored=restored and t.q.Angle==45 and t.q.AutoThrowType.Enabled and t.q.ManualType==(options.powerMode and 'Power' or 'Angle')
        end
        check(restored,'native angle/type/automatic fields restored at every frame boundary')
        return max
    end
    function t.payload()
        for _,r in ipairs(t.env.PELICAN_FF3_HISTORY_V1.data.Records) do if r.Kind=='throw' then return r.Payload end end
    end
    if options.powerMode then t.q.ManualType='Power' end
    return t
end
local function request(c,t,key)
    return c.angle.Request(t.a,key or 'Probe',t.leads.Dime)
end
local t=scene();local c=t.run();c.SetThrow(false);local max=t.steps()
check(c.angle.enabled and max<=8,'unconfigured real default enables adaptive angle inside existing call budget')
local low=request(c,t)
check(low and low.reason=='LOW_CLEAR_LANE' and low.requested<45,'clear lane chooses computed lower angle instead of repeating 45')
local varied=false;local first
for _,r in ipairs(Mock.nativeSolveHistory or {}) do
    if r.mode=='Dime' then
        local angle=math.deg(math.atan(r.velocity.Y/Vector3.new(r.velocity.X,0,r.velocity.Z).Magnitude))
        check(angle<45 and r.manualType=='Angle','actual native Dime velocity follows lower requested angle')
        varied=varied or first and math.abs(angle-first)>.01;first=first or angle
    end
end
check(varied,'actual native angles change as the receiver develops downfield')
local estimates=c.angle.requests
local a=request(c,t,'Cache');for _=1,10 do check(request(c,t,'Cache')==a,'same physics frame reuses the exact estimator result') end
check(c.angle.requests==estimates+1,'ten repeated reads add only one bounded estimate')

t.dr.Position=Vector3.new(0,6,20);local loft=request(c,t,'LaneBlocker')
check(loft and loft.reason=='LOFT_OVER_PROJECTED_LANE_BLOCKER' and loft.requested>low.requested,'projected underneath lane blocker raises requested loft')
t.dr.Position=Vector3.new(16,6,20);t.dr.AssemblyLinearVelocity=Vector3.new(-20,0,0)
local entering=request(c,t,'Entering');check(entering and entering.blockers>0,'defender moving into the lane can justify loft')
t.dr.Position=Vector3.new(8,6,20);t.dr.AssemblyLinearVelocity=Vector3.new(20,0,0)
local leaving=request(c,t,'Leaving');check(leaving and leaving.blockers==0,'nearby defender moving out of the trajectory does not automatically force loft')
check(c.Stop('TEST'),'geometry estimator cleanup')

-- Being outside alone does not command a high angle.
t=scene();t.ar.Position=Vector3.new(45,6,-30);c=t.run();c.SetThrow(false);t.steps()
local outside=request(c,t)
check(outside and outside.reason=='LOW_CLEAR_LANE','open outside receiver still gets the clear-lane angle')
check(c.Stop('TEST'),'outside scene cleanup')

for _,powerMode in ipairs({false,true}) do
    t=scene({powerMode=powerMode});t.dr.Position=Vector3.new(0,6,20);c=t.run();max=t.steps(24)
    local p=t.payload()
    check(#t.requests==1 and p.AdaptiveAngle and p.AngleRequest.reason=='LOFT_OVER_PROJECTED_LANE_BLOCKER','actual auto release can loft over an underneath defender')
    check(math.abs(p.ManualInput-p.ActualAngleDegrees)<.25 and p.InputKind=='ANGLE_DEGREES','metadata identifies the actual requested/returned angle units')
    check(p.LeadSettings.Dime.Y==7.1 and p.MagTrial==false and max<=8,'loft changes trajectory while retaining ordinary lead and frame budget')
    check(t.q.ManualType==(powerMode and 'Power' or 'Angle') and t.q.Angle==45 and t.q.Power==95,'configured input mode/power/angle preserved outside protected solves')
    check(c.Stop('TEST'),'loft release cleanup')
end

for _,kind in ipairs({'PREVENT','CLOSE_CB','AFK','BLACKLIST','NO_SAFE_WINDOW'}) do
    t=scene()
    if kind=='PREVENT' then t.dr.Position=Vector3.new(0,6,-60)
    elseif kind=='CLOSE_CB' then t.dr.Position=Vector3.new(0,6,50)
    elseif kind=='AFK' then t.ar.AssemblyLinearVelocity=Vector3.new()
    elseif kind=='NO_SAFE_WINDOW' then t.dr.Position=t.ar.Position;t.dr.AssemblyLinearVelocity=t.ar.AssemblyLinearVelocity
    end
    c=t.run();if kind=='BLACKLIST' then c.SetBlacklisted(t.a,true) end;t.steps(20)
    check(#t.requests==0,'adaptive angle never forces an unsafe/unqualified request: '..kind)
    check(c.Stop('TEST'),'safety cleanup '..kind)
end

-- Live records show input and final angle can differ: a source correction must
-- remain eligible if its actual returned path still passes the original checks.
t=scene({nativeAngleCorrectionDegrees=4,onlyNativeMode='Dime'});c=t.run();t.steps()
local corrected=false
for _,r in ipairs(Mock.nativeSolveHistory or {}) do
    if r.mode=='Dime' then
        corrected=true
        local actual=math.deg(math.atan(r.velocity.Y/Vector3.new(r.velocity.X,0,r.velocity.Z).Magnitude))
        check(actual<45 and t.q.Angle==45,'native corrected velocity remains separate from restored global input')
    end
end
check(corrected and #t.requests==1 and t.payload().Mode=='Dime','corrected native Dime can actually release after full safety checks')
check(math.abs(t.payload().NativeAngleAdjustment+4)<.001,'history records the real request/release difference without changing global input')
check(c.Stop('TEST'),'native angle correction cleanup')

-- Turning it off restores the original configured-angle path and preserves UI/session ownership.
t=scene({ff3={AdaptiveAngle=false}});c=t.run();c.SetThrow(false);t.steps()
local saw=false
for _,r in ipairs(Mock.nativeSolveHistory or {}) do if r.mode=='Dime' then
    saw=true;check(math.abs(math.deg(math.atan(r.velocity.Y/Vector3.new(r.velocity.X,0,r.velocity.Z).Magnitude))-45)<.001,'ARC OLD uses configured 45-degree native path')
end end
check(saw and c.angle.requests==0,'disabled feature adds no estimator/native workload')
local ui=t.me:FindFirstChild('PlayerGui'):FindFirstChild('PELICAN_FF3_AUTO_QB_V26');local button=ui:FindFirstChild('AdaptiveAngle')
check(button and not button.Visible and button.Text=='ARC OLD','new control stays folded')
button.Activated:Fire();check(c.angle.enabled and button.Text=='ARC AUTO','folded control enables adaptive scene calculation')
t.steps(5);check(t.env.PELICAN_FF3_HISTORY_V1.data.CurrentSettings.AdaptiveAngle,'current history follows adaptive policy change')
check(c.Stop('TEST'),'toggle cleanup')

for _,fault in ipairs({'ERROR','YIELD','EXTERNAL_ANGLE'}) do
    t=scene();t.dr.Position=Vector3.new(0,6,20);c=t.run();local fired=false
    t.options.duringSolve=function()
        if not fired and not Mock.inNativePreview and t.q.Angle~=45 then
            fired=true
            if fault=='ERROR' then error('Injected adaptive solver failure')
            elseif fault=='YIELD' then coroutine.yield()
            else t.q.Angle=47 end
        end
    end
    for _=1,20 do t.advance(.13);t.drain();if c.IsStopped then break end end
    check(fired and c.IsStopped and #t.requests==0,'real native adaptive failure stops before throwing '..fault)
    check(t.q.Angle==(fault=='EXTERNAL_ANGLE' and 47 or 45) and t.q.AutoThrowType.Enabled,'owned fields restored while external edits survive '..fault)
    check(c.Stop('TEST'),'failure cleanup '..fault)
end

-- A source-clamped angle cannot masquerade as a reachable estimated native request.
t=scene();c=t.run();c.SetThrow(false);t.steps();t.q.Power=5
local control,reason=request(c,t,'Unreachable')
check(not control and reason=='ANGLE_ESTIMATE_UNREACHABLE','infeasible estimate is rejected rather than replaced by a fixed 45')
Mock.time=Mock.time+.4;control,reason=request(c,t,'Stale')
check(not control and reason=='ANGLE_SCENE_UNVERIFIED','stale scene cannot produce an adaptive request')
check(c.Stop('TEST'),'invalid estimate cleanup')
print('FF3 adaptive native-angle checks passed:',checks,'(mocked; live physics, coverage and iPhone timing unverified)')
