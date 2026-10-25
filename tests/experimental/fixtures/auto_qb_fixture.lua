-- Source-shaped native Yuna fixture; no Roblox/server simulation claims.
local originalClock=os.clock
local source=assert(io.open('experimental/auto_qb.lua')):read('*a')
local function setup(options)
    options=options or {}; os.clock=originalClock
    options.ff3=options.ff3 or {}
    if options.ff3.SafetyReads==nil and not options.newSafetyDefaults then options.ff3.SafetyReads=false end -- historical coverage contract; safety suite exercises production read
    if options.ff3.ReactiveWindows==nil and not options.newReactiveDefaults then options.ff3.ReactiveWindows=false end -- historical planning cadence; reactive suite tests production default
    if options.ff3.CoverageWindows==nil and not options.newSharedCoverageDefaults then options.ff3.CoverageWindows=false end -- historical casual Fit contract; shared suite exercises production default
    if options.ff3.JumpDelaySeconds==nil and not options.newJumpTimingDefaults then options.ff3.JumpDelaySeconds=0 end -- legacy immediate packet contracts; timing suite exercises real default
    if options.ff3.NativeJump==nil and not options.newNativeJumpDefaults then options.ff3.NativeJump=false end -- legacy custom branch contracts; native suite exercises replacement default
    if options.ff3.OpenComfort==nil and not options.newComfortDefaults then options.ff3.OpenComfort=false end -- historical mode-policy fixtures; comfort suite exercises real default ON
    if options.ff3.AdaptiveAngle==nil and not options.newAngleDefaults then options.ff3.AdaptiveAngle=false end -- legacy native packet tests; adaptive suite exercises real default ON
    if options.ff3.WideOpenJump==nil and not options.newPassPlanDefaults then options.ff3.WideOpenJump=false end -- legacy packet/mode equivalence; new plan tests exercise default ON
    dofile('tests/experimental/fixtures/runtime_mock.lua')
    local env={}; getgenv=function() return env end
    local normalType=typeof
    typeof=function(v)
        if type(v)=='table' and v._nativeVector then return 'vector' end
        if type(v)=='table' and v._nativeLead then return 'Vector2' end
        return normalType(v)
    end
    local function signal()
        local s={connections={}}
        function s:Connect(fn)
            local c={Connected=true,Enabled=true,Function=fn}; function c:Disconnect() self.Connected=false end
            self.connections[#self.connections+1]=c; return c
        end
        function s:Fire(...) for _,c in ipairs(self.connections) do if c.Connected and c.Enabled then c.Function(...) end end end
        return s
    end
    Mock.services.UserInputService.InputBegan=signal()
    local me=Mock.services.Players.LocalPlayer
    function me:GetNetworkPing() return options.ping or 0 end
    local function head(player)
        player.Character.PrimaryPart=player.Character:FindFirstChild('HumanoidRootPart')
        local h=Instance.new('Part'); h.Name='Head'; h.Position=player.Character.PrimaryPart.Position+Vector3.new(0,2.5,0); h.Parent=player.Character
    end
    head(me)
    Enum.Material={Air='Air',Ground='Ground'}
    Enum.HumanoidStateType={Running='Running',Jumping='Jumping',Freefall='Freefall'}
    Enum.AnimationPriority={Action='Action'}
    Mock.qhum.FloorMaterial=Enum.Material.Ground;Mock.qhum.Jump=false
    Mock.humState=Enum.HumanoidStateType.Running
    function Mock.qhum:GetState() return Mock.humState end
    function Mock.qhum:GetStateEnabled() return not options.jumpDisabled end
    if options.changeState then
        function Mock.qhum:ChangeState(state)
            if options.changeStateError then error('Injected normal jump state exception') end
            Mock.changeStateCalls=(Mock.changeStateCalls or 0)+1
            if state==Enum.HumanoidStateType.Jumping and options.stateJumpWorks then Mock.stateJumpRequested=true end
        end
    end
    local animationTracks={}
    function Mock.qhum:GetPlayingAnimationTracks()
        local tracks={};for _,track in ipairs(Mock.playingTracks or {}) do tracks[#tracks+1]=track end
        for _,track in ipairs(animationTracks) do if track.IsPlaying then tracks[#tracks+1]=track end end
        return tracks
    end
    local nativeAnimationBindings
    if options.animation then
        local animator=Instance.new('Animator');animator.Parent=Mock.qhum
        local asset=Instance.new('Animation');asset.Name='Throw';asset.AnimationId='rbxassetid://123456789'
        -- Synthetic asset ID stays in private tests; runtime never invents IDs.
        nativeAnimationBindings={Throw=asset}
        function animator:LoadAnimation(value)
            if options.animationLoadError then error('Injected animation load error') end
            local track=Instance.new('AnimationTrack');track.Animation=value;track.Priority=Enum.AnimationPriority.Action
            track.IsPlaying=false;track.TimePosition=0;track.Length=.6
            function track:Play()
                if options.animationPlayError then error('Injected animation play error') end
                self.IsPlaying=true;self.TimePosition=0;Mock.animationPlays=(Mock.animationPlays or 0)+1
                if options.afterAnimation then options.afterAnimation() end
            end
            function track:Stop() self.IsPlaying=false;self.StopCount=(self.StopCount or 0)+1 end
            function track:Destroy() self.IsPlaying=false;self.Destroyed=true;self.Parent=nil end
            animationTracks[#animationTracks+1]=track
            if options.afterAnimationLoad then options.afterAnimationLoad() end
            return track
        end
    end
    local a,ar=Mock.makePlayer('OpenWR',Mock.team,Vector3.new(15,6,45),Vector3.new(6,0,0)); head(a)
    local b,br=Mock.makePlayer('OtherWR',Mock.team,Vector3.new(-15,6,45),Vector3.new(-6,0,0)); head(b)
    a.UserId=101; b.UserId=102
    local db,dr=Mock.makePlayer('DB',Mock.other,Vector3.new(0,6,-60),Vector3.new()); head(db)
    me.OnTeleport=signal()
    local ground,blue,yellow,down
    local function makePart(name,pos,size,color)
        local p=Instance.new('Part'); p.Name=name; p.Position=pos; p.CFrame=Mock.cf(pos,Vector3.new(1,0,0),Vector3.new(0,1,0),Vector3.new(0,0,-1))
        p.Size=size; p.Color=color; p.Parent=workspace; return p
    end
    if not options.noLines then
        ground=makePart('ObservedGround',Vector3.new(0,2.5,0),Vector3.new(225,1,420),Color3.new(0,.5,0))
        blue=makePart('ObservedBlue',Vector3.new(0,2.95,70),Vector3.new(160,.1,.25),Color3.new(0,0,1)); blue.Transparency=.2
        yellow=makePart('ObservedYellow',Vector3.new(0,2.95,40),Vector3.new(160,.1,.25),Color3.new(1,1,0)); yellow.Transparency=.2
        down=Instance.new('TextLabel'); down.Name='CurrentDown'; down.Text='1st & 10'; down.Parent=me:FindFirstChild('PlayerGui')
    end
    local tool=Instance.new('Tool'); tool.Name='Football'; tool.Parent=me.Character
    local handle=Instance.new('Part'); handle.Name='Handle'; handle.Parent=tool
    local remote=Instance.new('RemoteEvent'); remote.Parent=handle
    local requests={}
    local q={Enabled=true,MouseAimbot={Enabled=false},AutoThrowType={Enabled=options.nativeAuto~=false,Mode='Mag'},
        SelectedType=options.selectedType or 'Dime',Angle=options.angleDegrees and 45 or .3,Power=80,ManualType='Angle',Locked=false,SmartPass=true,
        AntiOOB={Enabled=true,XTolerance=0,ZTolerance=0}}
    local function lead(x,y) local v=Vector2.new(x,y); v._nativeLead=true; return v end
    local leads=options.leads or {Bullet=lead(3,0),Fit=lead(6,8),Jump=lead(0,9),Dime=lead(3,7.1),Dive=lead(6,7.1)}
    -- FireServer only captures source lock state; it does not invoke game/server code.
    function remote:FireServer(...)
        requests[#requests+1]={args={...},target=q.LockedOnto,mode=Mock.lastMode,selectedType=q.SelectedType,
            at=Mock.time,qbY=Mock.qroot.Position.Y,qbVy=Mock.qroot.AssemblyLinearVelocity.Y,
            jumpRequested=Mock.qhum.Jump==true,changeStateCalls=Mock.changeStateCalls,
            animationPlaying=animationTracks[#animationTracks] and animationTracks[#animationTracks].IsPlaying,
            animation=animationTracks[#animationTracks] and animationTracks[#animationTracks].TimePosition}
        if options.remoteError then error('Ambiguous network error') end
    end
    local status=Instance.new('StringValue'); status.Value='InPlay'
    local throwable=Instance.new('BoolValue'); throwable.Value=true
    local gameState={Status=status,Throwable=throwable}
    local wrapper={gameState}
    if options.stateFolder then
        local folder=Instance.new('Folder'); folder.Name='ActualCapturedValues'
        status.Name='Status'; throwable.Name='Throwable'; status.Parent=folder; throwable.Parent=folder
        wrapper[1]=folder
    end
    local cards={}
    for _,k in ipairs({'Player','Time','Angle','Type'}) do cards[k]={CardText=Instance.new('TextLabel')} end
    local normal=a.Character
    local function selector()
        if q.Locked then
            -- Native lock branch has one return. It must not be mistaken for
            -- the unlocked (Model, mouse distance) pair used by the old wrapper.
            return q.LockedOnto
        end
        return normal,31
    end
    local nativeGetter=selector
    local function solver(angle,selectedType)
        if Mock.inNativePreview then Mock.previewSolverCalls=(Mock.previewSolverCalls or 0)+1
        else Mock.nativeSolverCalls=(Mock.nativeSolverCalls or 0)+1 end
        if options.solverError and not Mock.inNativePreview then error('Injected native solver exception') end
        local model=nativeGetter()
        if not model then return end
        local root=model.PrimaryPart
        -- Native fn37 reads this shared setting when automatic mode is disabled.
        local mode=q.SelectedType
        if options.onlyNativeMode and mode~=options.onlyNativeMode then return end
        if options.nativeModes and not options.nativeModes[mode] then return end
        local selectedLead=leads[mode] -- Captures the source-shaped lead table for discovery.
        if q.AutoThrowType.Enabled then
            local dot=root.AssemblyLinearVelocity.Unit:Dot((root.Position-me.Character.PrimaryPart.Position).Unit)
            if dot>.97 then mode=q.AutoThrowType.Mode=='High Arc' and 'Dive' or 'Fit'
            elseif dot>.8 then mode=q.AutoThrowType.Mode=='High Arc' and 'Dime' or 'Jump'
            else mode='Bullet' end
        end
        cards.Player.CardText.Text=model.Name; cards.Type.CardText.Text=mode
        cards.Time.CardText.Text='1.0s'; cards.Angle.CardText.Text='5' -- intentionally stale initial-angle display
        local origin=me.Character:FindFirstChild('Head').Position
        if options.nativeOriginShift then
            local horizontal=Vector3.new(root.Position.X-origin.X,0,root.Position.Z-origin.Z)
            if horizontal.Magnitude>0 then origin=origin+horizontal.Unit*options.nativeOriginShift end
        end
        local t=1; local aim,velocity
        local lift=selectedLead.Y
        -- Optional synthetic reproduction of fn34's conditional-height branch.
        -- This flag represents a lateral route, not a newly assumed dot cutoff.
        if options.sidewaysNoLift and mode~='Jump' then lift=0 end
        local manualPower=options.manualValue and angle or q.Power
        local angleRadians=options.angleDegrees and math.rad(angle) or q.Angle
        if options.nativeAngleCorrectionDegrees and q.ManualType=='Angle' and mode~='Bullet' and mode~='Fit' then angleRadians=angleRadians-math.rad(options.nativeAngleCorrectionDegrees) end
        local modelSpeed=options.nativePower and q.ManualType=='Power' and mode~='Bullet' and mode~='Fit' and manualPower or 95
        for i=1,12 do
            aim=model:FindFirstChild('Head').Position+root.AssemblyLinearVelocity*t
            if options.nativePower then
                local flatV=Vector3.new(root.AssemblyLinearVelocity.X,0,root.AssemblyLinearVelocity.Z)
                aim=aim+Vector3.new(0,lift,0)+(flatV.Magnitude>0 and flatV.Unit*selectedLead.X or Vector3.new())
            end
            local delta=aim-origin; local flat=Vector3.new(delta.X,0,delta.Z); local r=flat.Magnitude
            if options.nativeAngle and q.ManualType=='Angle' and mode~='Bullet' and mode~='Fit' then
                -- Audited fn16 Angle-mode formula. Synthetic fixed origin;
                -- this does not execute the original paid native source.
                local denominator=2*math.cos(angleRadians)^2*(r*math.tan(angleRadians)-delta.Y)
                if denominator<=0 then return end
                modelSpeed=math.max(1,math.min(95,math.sqrt(28*r*r/denominator)))
            end
            local disc=modelSpeed^4-28*(28*r*r+2*delta.Y*modelSpeed^2)
            if disc<0 then return end
            local high=options.nativePower and mode~='Bullet' and mode~='Fit' and (q.PreferHighArc or options.ignoreLowArc)
            local radians=options.nativeAngle and q.ManualType=='Angle' and mode~='Bullet' and mode~='Fit' and angleRadians
                or math.atan((modelSpeed^2+(high and 1 or -1)*math.sqrt(disc))/(28*r))
            velocity=flat.Unit*(modelSpeed*math.cos(radians))+Vector3.new(0,modelSpeed*math.sin(radians),0)
            t=r/(modelSpeed*math.cos(radians))
        end
        if options.arrival then
            aim=options.arrival; t=1; velocity=aim-origin+Vector3.new(0,14,0)
        end
        local power=velocity.Magnitude
        if options.ignoreRequestedPower and options.nativePower and q.ManualType=='Power' then power=95 end
        if options.modeShots then
            -- Synthetic geometry only: no FF3 catch-window calibration claim.
            local shot=options.modeShots(mode,model,origin)
            if not shot then return end
            velocity,t=shot.velocity,shot.time
            power=shot.power or velocity.Magnitude
            aim=shot.aimpoint or origin+velocity*t-Vector3.new(0,14*t*t,0)
        end
        if options.badTuple then velocity=Vector3.new(0/0,0,0) end
        if options.preVerticalAimpoint and options.nativePower and not options.modeShots then aim=aim-Vector3.new(0,lift,0) end
        Mock.lastMode,Mock.lastVelocity,Mock.lastOrigin,Mock.lastTime=mode,velocity,origin,t
        Mock.lastAimpoint,Mock.lastPower=aim,power
        if not Mock.inNativePreview then
            Mock.nativeSolveHistory=Mock.nativeSolveHistory or {}
            Mock.nativeSolveHistory[#Mock.nativeSolveHistory+1]={mode=mode,target=model,at=Mock.time,time=t,power=power,
                origin=origin,velocity=velocity,aimpoint=aim,lead=selectedLead,manualType=q.ManualType}
        end
        if options.duringSolve then options.duringSolve() end
        local dir,endpoint=(aim-origin).Unit,origin+velocity*t
        if options.nativeVectors then
            origin={_nativeVector=true,x=origin.X,y=origin.Y,z=origin.Z}
            velocity={_nativeVector=true,x=velocity.X,y=velocity.Y,z=velocity.Z}
        end
        return dir,origin,endpoint,power,t,velocity,aim,angle,mode
    end
    local previewGetter=selector
    local function preview()
        Mock.inNativePreview=true
        Mock.previewTarget=previewGetter()
        if q.Enabled and q.MouseAimbot and cards then solver(q.Angle,q.SelectedType) end
        Mock.inNativePreview=false
    end
    local function release(input,processed)
        Mock.nativeAnimationBindingObserved=nativeAnimationBindings~=nil
        if not processed and input and wrapper[1].Status.Value=='InPlay' then solver(q.Angle,q.SelectedType) end
        Mock.inputs=(Mock.inputs or 0)+1
    end
    local metadata={
        [selector]={'LockedOnto','LockedOntoName','GetMouseLocation','GetPlayers'},
        [solver]={'AutoThrowType','CardText','CardName','Player','Time','Type','Head'},
        [preview]={'Angle','SelectedType','MouseAimbot','Enabled'},
        [release]={'Clicked','RemoteEvent','FireServer','TimePosition',70000000},
    }
    getconstants=function(fn) return metadata[fn] or {} end
    local pc,rc
    local function startYuna()
        pc=Mock.services.RunService.Heartbeat:Connect(preview)
        rc=Mock.services.UserInputService.InputBegan:Connect(release)
    end
    if not options.late then startYuna() end
    local cleanupHooks={}
    local function cleanup()
        local clean=true
        for i=#cleanupHooks,1,-1 do local ok,result=pcall(cleanupHooks[i]);clean=clean and ok and result==true end
        return clean
    end
    -- Legacy selector/lifecycle fixtures deliberately omit the native power
    -- model. Keep power policy off in those fixtures; enabled-policy suites
    -- explicitly use nativePower=true and exercise current default settings.
    local ff3={};for k,v in pairs(options.ff3 or {}) do ff3[k]=v end
    if not options.nativePower and ff3.CloseBullet==nil then ff3.CloseBullet=false end
    local context={FF3Options=ff3,RegisterCleanup=function(fn) cleanupHooks[#cleanupHooks+1]=fn end,IsCancelled=function() return options.cancelled==true end,
        SourceMode=options.sourceMode,Sources=options.sources,BaseUrl=options.baseUrl,Ref=options.ref}
    local c
    local function run() c=assert(load(options.source or source,'@games/ff3/auto_qb.lua'))(context); return c end
    local function advance(dt)
        dt=dt or .13; Mock.time=Mock.time+dt
        local nativeBefore=Mock.nativeSolverCalls or 0
        if options.simulateJump then
            if Mock.qhum.Jump or Mock.stateJumpRequested then
                local stateRequested=Mock.stateJumpRequested;Mock.stateJumpRequested=false
                Mock.qhum.Jump=false
                if (not options.jumpFailure or stateRequested) and not Mock.jumpActive then
                    Mock.jumpActive=true;Mock.qroot.AssemblyLinearVelocity=Vector3.new(Mock.qroot.AssemblyLinearVelocity.X,options.jumpSpeed or 50,Mock.qroot.AssemblyLinearVelocity.Z)
                    Mock.jumpCount=(Mock.jumpCount or 0)+1
                end
            end
            if Mock.jumpActive then
                local root=Mock.qroot;local v=root.AssemblyLinearVelocity
                root.Position=root.Position+Vector3.new(0,v.Y*dt-.5*workspace.Gravity*dt*dt,0)
                local vy=v.Y-workspace.Gravity*dt
                if root.Position.Y<=6 and vy<0 then
                    root.Position=Vector3.new(root.Position.X,6,root.Position.Z);vy=0;Mock.jumpActive=false
                end
                root.AssemblyLinearVelocity=Vector3.new(v.X,vy,v.Z)
            end
            Mock.qhum.FloorMaterial=Mock.jumpActive and Enum.Material.Air or Enum.Material.Ground
            Mock.humState=Mock.jumpActive and (Mock.qroot.AssemblyLinearVelocity.Y>0 and Enum.HumanoidStateType.Jumping or Enum.HumanoidStateType.Freefall) or Enum.HumanoidStateType.Running
        end
        for _,track in ipairs(animationTracks) do
            if track.IsPlaying and not options.animationFrozen then
                track.TimePosition=math.min(track.Length,track.TimePosition+dt)
                if track.TimePosition>=track.Length then track.IsPlaying=false end
            end
        end
        for _,p in ipairs(Mock.roster) do
            local root=p.Character.PrimaryPart
            if not options.freezeReceivers or p.Team~=Mock.team or p==me then root.Position=root.Position+(p==me and options.simulateJump and Vector3.new(root.AssemblyLinearVelocity.X,0,root.AssemblyLinearVelocity.Z) or root.AssemblyLinearVelocity)*dt end
            p.Character:FindFirstChild('Head').Position=root.Position+Vector3.new(0,2.5,0)
        end
        Mock.services.RunService.Heartbeat:Fire()
        Mock.nativeSolverCallsLastStep=(Mock.nativeSolverCalls or 0)-nativeBefore
        return Mock.nativeSolverCallsLastStep
    end
    return {run=run,advance=advance,q=q,a=a,b=b,db=db,ar=ar,br=br,dr=dr,me=me,env=env,
        tool=tool,remote=remote,requests=requests,solver=solver,selector=selector,preview=preview,
        animationTracks=animationTracks,nativeAnimationBindings=nativeAnimationBindings,cards=cards,state=gameState,startYuna=startYuna,cleanup=function() return cleanup() end,
        metadata=metadata,signal=signal,connections=function() return pc,rc end,
        blue=blue,yellow=yellow,ground=ground,down=down,makePart=makePart,options=options,leads=leads}
end

return setup
