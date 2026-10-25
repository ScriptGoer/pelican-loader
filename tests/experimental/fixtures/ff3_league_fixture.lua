local helpers=dofile('tests/experimental/fixtures/ff3_history_fixture.lua')
local function setup(options)
    options=options or {};options.newNativeJumpDefaults=true;options.newComfortDefaults=true;options.newAngleDefaults=true;options.newPassPlanDefaults=true
    options.nativePower=true;options.nativeAngle=true;options.angleDegrees=true;options.manualValue=true;options.preVerticalAimpoint=true
    options.ff3=options.ff3 or {};if options.ff3.Profile==nil then options.ff3.Profile='LEAGUE' end
    local t=helpers.setup(nil,options);t.q.Power=95;Mock.qhum.WalkSpeed=16
    t.ar.Position=Vector3.new(0,6,75);t.ar.AssemblyLinearVelocity=Vector3.new();t.br.AssemblyLinearVelocity=Vector3.new()
    t.dr.Position=Vector3.new(65,6,-100);t.dr.AssemblyLinearVelocity=Vector3.new()
    t.a.Character:FindFirstChildOfClass('Humanoid').WalkSpeed=16;t.db.Character:FindFirstChildOfClass('Humanoid').WalkSpeed=16
    t.steps=function(n) local max=0;for _=1,n or 12 do max=math.max(max,t.advance(.13));t.drain() end;return max end
    t.ui=function() return t.me:FindFirstChild('PlayerGui'):FindFirstChild('PELICAN_FF3_AUTO_QB_V26') end
    t.payload=function() for _,r in ipairs(t.env.PELICAN_FF3_HISTORY_V1.data.Records) do if r.Kind=='throw' then return r.Payload end end end
    t.addDB=function(name,position,velocity,speed)
        local p,root,hum=Mock.makePlayer(name,Mock.other,position,velocity or Vector3.new());p.UserId=200+#Mock.roster
        p.Character.PrimaryPart=root;hum.WalkSpeed=speed or 16
        local head=Instance.new('Part');head.Name='Head';head.Position=root.Position+Vector3.new(0,2.5,0);head.Parent=p.Character
        return p,root,hum
    end
    return t
end
return setup
