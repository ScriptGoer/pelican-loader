-- Real controller + source-shaped native math, not game/server catch calibration.
local helpers=dofile('tests/experimental/fixtures/ff3_history_fixture.lua')
local checks=0
local function check(v,msg) checks=checks+1;assert(v,msg) end
local function scene(extra)
    local o=extra or {};o.newNativeJumpDefaults=true;o.newComfortDefaults=true;o.newAngleDefaults=true;o.newPassPlanDefaults=true
    o.nativePower=true;o.nativeAngle=true;o.angleDegrees=true;o.manualValue=true;o.preVerticalAimpoint=true
    local t=helpers.setup(nil,o);t.q.Power=80;t.leads.Jump.Y=4
    t.ar.Position=Vector3.new(0,6,-50);t.ar.AssemblyLinearVelocity=Vector3.new(6,0,0);t.br.AssemblyLinearVelocity=Vector3.new()
    t.dr.Position=Vector3.new(0,6,20);t.dr.AssemblyLinearVelocity=Vector3.new();t.db.Character:FindFirstChildOfClass('Humanoid').WalkSpeed=10
    t.steps=function(n) local max=0;for _=1,n or 24 do max=math.max(max,t.advance(.13));t.drain() end;return max end
    t.payload=function() for _,r in ipairs(t.env.PELICAN_FF3_HISTORY_V1.data.Records) do if r.Kind=='throw' then return r.Payload end end end
    return t
end
local t=scene({nativeModes={Bullet=true,Jump=true}});t.leads.Fit.Y=0
local original=t.leads.Jump;local c=t.run();local max=t.steps();local p=t.payload()
check(p and p.NativeCoverageJump and p.Mode=='Jump' and p.NativeMode=='Jump' and p.Variant=='CoverageJump','conditional native Jump actually releases through shared controller')
check(p.Power<=81 and p.Power<95 and p.Lead[1]==0 and p.Lead[2]==4,'own Jump lead and configured power ceiling used; no borrowed Fit height or forced 95')
check(p.JumpBulletReason=='FRESH_CHEST_PATH_THREAT' and p.JumpBulletChest,'fresh native chest comparison proves the conditional need')
check(p.NativeCoverageJump and not p.JumpPreferred and not p.JumpBullet,'native replacement is not the old custom Bullet label')
check(t.leads.Jump==original and t.leads.Fit.Y==0 and t.q.ManualType=='Angle' and t.q.Power==80 and t.q.AutoThrowType.Enabled,'original lead object and native global settings restored')
check(max<=8 and #t.requests==1,'normal Bullet comparison plus native Jump final respects frame and one-send limits')
local last={};for _,r in ipairs(Mock.nativeSolveHistory) do last[#last+1]=r.mode end
check(last[#last]=='Jump' and last[#last-1]=='Bullet','actual native Jump is solved last after fresh chest counterfactual')
check(t.env.PELICAN_FF3_HISTORY_V1.data.CurrentSettings.NativeJump,'history identifies native replacement default')
check(c.Stop('NATIVE'),'native replacement cleanup')
-- Open receiver stays ordinary even if old custom preference was retained in executor memory.
t=scene();t.dr.Position=Vector3.new(-65,6,-150);t.ar.Position=Vector3.new(0,6,0)
t.env.PELICAN_FF3_JUMP_BULLET=true;c=t.run();max=t.steps();p=t.payload()
check(p and p.Mode=='Bullet' and p.Variant=='SoftBullet' and p.Power<95 and p.Time>=.85,'open receiver retains a slower standing catch instead of native Jump')
check(not c.jumpBullet.enabled and not c.SetJumpBullet(true),'legacy custom branch cannot run alongside native replacement')
check(max<=8 and c.Stop('OPEN'),'open replacement cleanup')
-- A newly open chest lane cancels the higher candidate during final calculation.
t=scene({nativeModes={Bullet=true,Jump=true}});local changed=false
c=t.run();t.options.duringSolve=function()
    if not changed and not Mock.inNativePreview and Mock.lastMode=='Bullet' and c.GetReport():find('RELEASE_PREPARED|true',1,true) then
        changed=true;t.dr.Position=Vector3.new(-65,6,-150)
    end
end
max=t.steps();p=t.payload()
check(changed and (not p or not p.NativeCoverageJump),'fresh ordinary opening cancels native Jump before sending')
check(max<=8 and c.Stop('CHANGE'),'changed chest-lane cleanup')
for _,kind in ipairs({'MISSING_CHEST','NO_SAFE_JUMP','STOP','BLACKLIST','SOLVER_ERROR','YIELD','EXTERNAL_EDIT'}) do
    local modes=kind=='MISSING_CHEST' and {Jump=true} or {Bullet=true,Jump=true}
    t=scene({nativeModes=modes});if kind=='NO_SAFE_JUMP' then t.dr.Position=t.ar.Position;t.dr.AssemblyLinearVelocity=t.ar.AssemblyLinearVelocity end
    local triggered=false;c=t.run()
    if kind=='BLACKLIST' then c.SetBlacklisted(t.a,true) end
    t.options.duringSolve=function()
        if not triggered and not Mock.inNativePreview and Mock.lastMode=='Jump' then
            triggered=true
            if kind=='STOP' then c.Stop('DURING_NATIVE_JUMP')
            elseif kind=='SOLVER_ERROR' then error('Native Jump test exception')
            elseif kind=='YIELD' then coroutine.yield()
            elseif kind=='EXTERNAL_EDIT' then t.q.Angle=77 end
        end
    end
    t.steps();p=t.payload()
    check(not p or not p.NativeCoverageJump,'unsupported or cancelled native candidate never releases: '..kind)
    if kind=='SOLVER_ERROR' or kind=='YIELD' or kind=='EXTERNAL_EDIT' then check(c.IsStopped,'genuine native error stops promptly: '..kind) end
    check(c.Stop(kind),'refusal cleanup '..kind)
end
-- The existing folded slot now controls native Jump, with no extra casual HUD row.
t=scene();c=t.run();local ui=t.me:FindFirstChild('PlayerGui'):FindFirstChild('PELICAN_FF3_AUTO_QB_V26');local b=ui:FindFirstChild('NativeJump')
check(b and b.Text=='HIGH ON' and not b.Visible,'native Jump starts conditional ON in the folded former JB slot')
b.Activated:Fire();check(not c.nativeJump.enabled and b.Text=='HIGH OFF','explicit tap disables replacement')
for _,mode in ipairs(c.jumpBullet.plannerModes) do check(mode~='CoverageJump' and mode~='JumpBullet','disabled native replacement leaves no high Bullet variant') end
check(c.Stop('UI'),'native control cleanup')
c=t.run();check(not c.nativeJump.enabled,'deliberate native Jump OFF survives ordinary reload')
check(c.Stop('PERSISTENCE'),'native preference cleanup')
print('FF3 native conditional Jump checks passed:',checks,'(mocked; actual catch height still uncalibrated)')
