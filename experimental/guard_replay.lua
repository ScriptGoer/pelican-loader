-- Generated analytic risk replay. No Roblox/network/native calls.
return function(shot,receiver,defenders,context)
 local V=Vector3.new
 local function flat(v)return V(v.X,0,v.Z)end
 local function clamp(x,a,b)return math.max(a,math.min(b,x))end
 local function finite(x)return type(x)=='number'and x==x and math.abs(x)<1e8 end
 local inputs=assert(context.GuardInputs,'Missing pre-grade guard inputs')
 local os={clock=function()return inputs.ClockEnd or inputs.Clock end}
 local workspace={Gravity=context.WorldGravity}
 local lines={forward=V(context.ForwardX,0,context.ForwardZ)}
 local controller={coverageMath={grades=0,verticalBands=0},coverageWindows={enabled=context.CoverageWindows},
  league={mode=context.Profile},safety={enabled=context.SafetyReads}}
 local touch={enabled=context.CloseBullet.Enabled,comfort=context.CloseBullet.Comfort,quick=context.CloseBullet.Quick,full=context.CloseBullet.FullPowerYards}
local CFG = {Interval=.12, DiscoveryInterval=2, MaxRoster=64,
    Gravity=28,
    ThrowMargin=6, ThrowLane=4, Settle=0, MinPlayAge=0, MinDownfieldYards=6,
    MinMoveSpeed=2, MinMotionAge=.65, MotionWindow=.8, MinMotionTravel=2.4, FieldDiscoverySeconds=20, PlanCalls=6, PlanSeconds=.008, CacheAge=.36, SafeGap=.4, ReceiverSwitchYards=5}
local riskPolicy={profiles={SAFE={margin=6,lane=4},
    MOD={margin=2,lane=CFG.ThrowLane,race=.08,lateral=3,turn=.25,arrivalSlack=.05},
    TRUST={margin=-2,lane=-4,race=-.02,lateral=6,turn=.5,arrivalSlack=.1}}}
-- Deliberate contest policy, not a measured FF3 catch radius/probability.
riskPolicy.burn={gap=4,contestFraction=.25,contestSeconds=.25}
function touch.fullAllowed(shot)
    if shot.screen and controller.league.mode=='LEAGUE' then shot.powerReason='EXPLICIT_ARMED_SCREEN_RECEIVER_PREPARED';return true end
    if not touch.enabled then return true end
    local power=shot.power or shot.velocity and shot.velocity.Magnitude
    local minimum=power and power>=94.5 and touch.comfort or shot.variant=='SoftBullet' and touch.comfort*.95 or touch.quick
    shot.minimumFlight=minimum
    if not finite(shot.time) or shot.time<minimum then shot.powerReason='NATIVE_FLIGHT_TOO_FAST';return false end
    if power and power<94.5 then shot.powerReason='NATIVE_FLIGHT_COMFORT_CHECKED';return true end
    -- Distance/actual flight policy; a changed mode label cannot bypass it.
    local yards=shot.passYards or shot.arrival and shot.origin and flat(shot.arrival-shot.origin).Magnitude/3
    local allowed=not touch.full or yards~=nil and yards>=touch.full
    shot.powerReason=allowed and 'FULL_POWER_DISTANCE_AND_FLIGHT_CHECKED' or 'FULL_POWER_TOO_CLOSE'
    return allowed
end
local function predict(s,t) return s.p+s.v*t end
-- Inherited vertical/horizontal reach estimates remain uncalibrated. Search
-- actual vertical flight intervals against a speed-bounded defender pursuit disk.
-- Instant direction changes favor the defender; this is not a catch guarantee.
local function linearMinimum(rx,rz,vx,vz,lo,hi,k)
    local vv=vx*vx+vz*vz; local at=hi
    if vv>k*k+1e-9 then
        local dot=rx*vx+rz*vz; local tc=-dot/vv
        local perp=math.max(0,rx*rx+rz*rz-dot*dot/vv)
        at=clamp(tc+k*math.sqrt(perp/(vv*(vv-k*k))),lo,hi)
    end
    local x,z=rx+vx*at,rz+vz*at
    return math.sqrt(x*x+z*z)-k*at
end
local function runSpeed(s)
    local speed=math.max(flat(s.v).Magnitude,s.observedSpeed or 0)
    if s.hum and finite(s.hum.WalkSpeed) then speed=math.max(speed,s.hum.WalkSpeed) end
    return speed
end
local function lane(shot,d,direct,both,earlyUntil)
    controller.coverageMath.verticalBands=controller.coverageMath.verticalBands+1
    local o,v,t=shot.origin,shot.velocity,shot.time
    local reach=12.2
    if d.hum and finite(d.hum.JumpPower) then reach=clamp(d.hum.JumpPower^2/(2*workspace.Gravity)+5,12.2,24) end
    local bottom,top=d.p.Y-2,d.p.Y+reach
    local disc=v.Y*v.Y-2*CFG.Gravity*(bottom-o.Y)
    if disc<0 then return 45,both and 45 or nil,earlyUntil and 45 or nil end
    local r=math.sqrt(disc); local lo,hi=math.max(0,(v.Y-r)/CFG.Gravity),math.min(t,(v.Y+r)/CFG.Gravity)
    if hi<lo then return 45,both and 45 or nil,earlyUntil and 45 or nil end
    local bodyRadius=4.5+d.turn*3
    local function interval(a,b)
        if b<a then return 45,both and 45 or nil,earlyUntil and 45 or nil end
        local vx,vz=v.X,v.Z
        if direct then vx,vz=vx-d.v.X,vz-d.v.Z end
        local first=linearMinimum(o.X-d.p.X,o.Z-d.p.Z,vx,vz,a,b,direct and 0 or runSpeed(d))-bodyRadius
        if both then
            local early=earlyUntil and (a<=earlyUntil and linearMinimum(o.X-d.p.X,o.Z-d.p.Z,v.X-d.v.X,v.Z-d.v.Z,a,math.min(b,earlyUntil),0)-bodyRadius or 45)
            return first,linearMinimum(o.X-d.p.X,o.Z-d.p.Z,v.X-d.v.X,v.Z-d.v.Z,a,b,0)-bodyRadius,early
        end
        return first
    end
    local high=v.Y*v.Y-2*CFG.Gravity*(top-o.Y)
    if high<=0 then return interval(lo,hi) end
    r=math.sqrt(high)
    local enter,leave=(v.Y-r)/CFG.Gravity,(v.Y+r)/CFG.Gravity
    local early,earlyDirect,earlyContest=interval(lo,math.min(hi,enter))
    local late,lateDirect,lateContest=interval(math.max(lo,leave),hi)
    return math.min(early,late),both and math.min(earlyDirect,lateDirect) or nil,
        earlyUntil and math.min(earlyContest,lateContest) or nil
end
function riskPolicy.BurnStart(shot,receiver)
    shot.trustBurn=nil
    if riskPolicy.mode~='TRUST' or (shot.mode~='Bullet' and shot.mode~='Dime')
        or shot.jumpBullet or shot.nativeCoverageJump or shot.magTrial or shot.screen then return end
    local motion=flat(receiver.v)
    if not lines.forward or motion.Magnitude<CFG.MinMoveSpeed or motion.Unit:Dot(lines.forward)<.5
        or flat(shot.arrival-receiver.p):Dot(motion)<=0 then return end
    shot.trustBurn={Allowed=false,Reason='NO_TRAILING_THREAT',Threats=0,Route=motion.Unit,
        Horizon=shot.time+math.max(0,shot.networkPing or 0),
        EarlyUntil=shot.time-math.min(shot.time*riskPolicy.burn.contestFraction,riskPolicy.burn.contestSeconds)}
end
function riskPolicy.BurnEarlyUntil(shot,receiver,d)
    local b=shot.trustBurn
    if not b then return end
    local gap=math.min(flat(receiver.p-d.p):Dot(b.Route),
        flat(predict(receiver,b.Horizon)-predict(d,b.Horizon)):Dot(b.Route))
    local closing=math.max(1,flat(shot.velocity-d.v):Dot(b.Route))
    -- More separation makes the ball pass the trailing corner earlier. Move
    -- the same contest boundary back so a bigger burn cannot grade worse.
    return math.max(0,b.EarlyUntil-math.max(0,gap-riskPolicy.burn.gap)/closing)
end
function riskPolicy.BurnGrade(shot,receiver,d,clearance,path,earlyDirect)
    local b=shot.trustBurn
    if not b or clearance>=CFG.ThrowMargin and path>=CFG.ThrowLane then return end
    b.Threats=b.Threats+1
    local relative=flat(receiver.p-d.p)
    local future=flat(predict(receiver,b.Horizon)-predict(d,b.Horizon))
    local gap,futureGap=relative:Dot(b.Route),future:Dot(b.Route)
    local side=(relative-b.Route*gap).Magnitude
    b.Gap=math.min(b.Gap or math.huge,gap)
    b.ProjectedGap=math.min(b.ProjectedGap or math.huge,futureGap)
    b.EarlyLane=math.min(b.EarlyLane or math.huge,earlyDirect or -math.huge)
    -- Only trailing corners get the contest allowance. Other lane/endpoint
    -- threats still veto it. Permit the final catch contest, not an earlier
    -- direct interception. Reuse lane()'s actual reachable-height intervals.
    if gap<riskPolicy.burn.gap-1e-6 or relative:Dot(lines.forward)<=0
        or side>riskPolicy.profiles.TRUST.lateral then b.Blocked='DEFENDER_NOT_TRAILING'
    elseif futureGap<riskPolicy.burn.gap-1e-6 then b.Blocked='BURN_CLOSING'
    elseif not earlyDirect or earlyDirect<=0 then b.Blocked='EARLY_INTERCEPTION_PATH' end
end
function riskPolicy.BurnFinish(shot)
    local b=shot.trustBurn
    if not b then return end
    local p=riskPolicy.profiles.TRUST
    b.Reason=b.Blocked or (shot.safetyOverTop or shot.safetyRead and shot.safetyRead.High) and 'SAFETY_OVER_TOP'
        or (shot.routeLateral or math.huge)>p.lateral and 'ROUTE_CORRECTION'
        or (shot.receiverTurn or 1)>p.turn and 'ROUTE_UNSTABLE'
        or (shot.receiverETA or math.huge)>shot.time+p.arrivalSlack and 'RECEIVER_LATE'
        or b.Threats==0 and 'NO_TRAILING_THREAT' or 'TRAILING_CORNER_ADVANTAGE'
    b.Allowed=b.Reason=='TRAILING_CORNER_ADVANTAGE'
    b.Route=nil -- retain scalar diagnostics only
end
local function risk(shot,receiver,defenders)
    controller.coverageMath.grades=controller.coverageMath.grades+1
    local margin,laneMargin,wideMargin,wideLane=45,45,45,45; local t=shot.time
    local pingBudget=finite(shot.networkPing) and math.max(0,shot.networkPing) or 0
    local firstDB,directLane=math.huge,45
    local enhanced=controller.coverageWindows.enabled or controller.league.mode=='LEAGUE'
    local layers=enhanced and {Underneath=0,Deeper=0,LaneThreats=0,CatchThreats=0} or nil
    local flight=flat(shot.arrival-shot.origin)
    -- The scene read uses a common ordinary-Bullet horizon, not the elevated
    -- candidate's different lead point. It is policy geometry, not role proof
    -- or a calibrated percentage of the game's catch hitbox.
    local read
    if controller.safety.enabled and lines.forward then
        local reference=shot.variant=='Bullet' and shot or receiver.chestReference
        if reference and reference.at and os.clock()-reference.at>CFG.CacheAge then reference=nil end
        local horizon=reference and reference.time or math.max(.05,flat(receiver.p-shot.origin).Magnitude/95)
        local motion=flat(receiver.v);local along=motion:Dot(lines.forward)
        read={State='NO_HIGH_SAFETY',High=false,Dropping=false,Contested=false,
            Slant=along>=CFG.MinMoveSpeed and (motion-lines.forward*along).Magnitude>=CFG.MinMoveSpeed,Horizon=horizon}
        receiver.dropHistory=receiver.dropHistory or setmetatable({}, {__mode='k'})
    end
    shot.safetyRead=read;shot.contestedChestThreat=false
    local route=flat(receiver.v)
    route=route.Magnitude>0 and lines.forward and route:Dot(lines.forward)>0 and route.Unit or nil
    shot.safetyOverTop,shot.safetyName=false,nil
    shot.marginDB,shot.laneDB,shot.marginActor,shot.laneActor=nil,nil,nil,nil
    riskPolicy.BurnStart(shot,receiver)
    for _,d in ipairs(defenders) do
        -- Instant turning at observed/normal run speed is optimistic for the DB.
        -- A trailing defender must cover the actual distance before arrival;
        -- a stationary prevent defender can move instead of staying frozen.
        local distance=flat(shot.arrival-d.p).Magnitude
        local speed=runSpeed(d)
        local baseClearance=distance-speed*t-(4.5+d.turn*3)
        local clearance=baseClearance-(enhanced and speed*pingBudget or 0)
        local eta=speed>0 and math.max(0,distance-(4.5+d.turn*3))/speed or (distance<=4.5+d.turn*3 and 0 or math.huge)
        firstDB=math.min(firstDB,eta)
        local basePath,directPath,earlyDirect=lane(shot,d,false,riskPolicy.mode~='SAFE',riskPolicy.BurnEarlyUntil(shot,receiver,d))
        if directPath then directLane=math.min(directLane,directPath-(enhanced and speed*pingBudget or 0)) end
        if clearance<margin then margin=clearance;shot.marginDB=d.name;shot.marginActor=d end
        local pathClearance=basePath-(enhanced and speed*pingBudget or 0)
        riskPolicy.BurnGrade(shot,receiver,d,clearance,pathClearance,earlyDirect)
        if read then
            local relative=flat(d.p-receiver.p);local depth=relative:Dot(lines.forward)
            local later=relative+flat(d.v-receiver.v)*(read.Horizon+pingBudget)
            local laterDepth=later:Dot(lines.forward)
            local radius=4.5+d.turn*3 -- inherited model envelope; not a verified catch radius
            local side=(relative-lines.forward*depth).Magnitude
            local laterSide=(later-lines.forward*laterDepth).Magnitude
            local relevant=side<=speed*(read.Horizon+pingBudget)+radius or laterSide<=radius
            local key=d.model or d
            local dropping=relevant and depth>0 and flat(d.v):Dot(lines.forward)<=-CFG.MinMoveSpeed
                and flat(d.v):Dot(-relative)>0
            if dropping then receiver.dropHistory[key]=os.clock();read.Dropping=true end
            local recent=receiver.dropHistory[key] and os.clock()-receiver.dropHistory[key]<=CFG.MotionWindow
            local catchClearance=flat(receiver.p+flat(receiver.v)*(read.Horizon+pingBudget)-d.p).Magnitude
                -speed*(read.Horizon+pingBudget)-radius
            if recent and relevant and catchClearance<CFG.ThrowMargin then receiver.dropHistory[key]=os.clock() end
            if relevant and depth>radius and laterDepth>radius and not dropping and not (recent and catchClearance<CFG.ThrowMargin) then read.High=true end
            if relevant and read.Slant and (dropping or recent) and catchClearance<CFG.ThrowMargin then
                read.Contested=true
                if shot.variant=='Bullet' and clearance<CFG.ThrowMargin then shot.contestedChestThreat=true end
            end
        end
        -- Reuse this exact grade for the over-top check instead of rebuilding
        -- the same defender vertical intervals in coverage().
        if route and not shot.safetyOverTop then
            local relative=flat(d.p-receiver.p);local along=relative:Dot(route)
            if along>=0 and relative:Dot(lines.forward)>0 and (relative-route*along).Magnitude<=speed*t+(4.5+d.turn*3)
                and (baseClearance<CFG.ThrowMargin or basePath<CFG.ThrowLane) then shot.safetyOverTop=true;shot.safetyName=d.name end
        end
        if layers then
            local fraction=flight.Magnitude>0 and flat(d.p-shot.origin):Dot(flight)/(flight.Magnitude*flight.Magnitude) or 0
            if lines.forward and flat(d.p-receiver.p):Dot(lines.forward)>0 then layers.Deeper=layers.Deeper+1
            elseif fraction>0 and fraction<1 then layers.Underneath=layers.Underneath+1 end
            if pathClearance<CFG.ThrowLane then layers.LaneThreats=layers.LaneThreats+1 end
            if clearance<CFG.ThrowMargin then layers.CatchThreats=layers.CatchThreats+1 end
        end
        wideMargin=math.min(wideMargin,clearance-(enhanced and 0 or speed*pingBudget))
        wideLane=math.min(wideLane,pathClearance-(enhanced and 0 or speed*pingBudget))
        if pathClearance<laneMargin then laneMargin=pathClearance;shot.laneDB=d.name;shot.laneActor=d end
    end
    if read then
        read.State=read.High and 'SAFETY_HIGH_BULLET_ONLY' or read.Contested and 'DROPPING_SLANT_CONTEST'
            or read.Dropping and 'SAFETY_FLOATING_AUTO_ARC' or 'NO_HIGH_SAFETY'
    end
    shot.coverageLayers=layers
    shot.margin,shot.lane,shot.defenderETA=margin,laneMargin,firstDB
    shot.wideMargin,shot.wideLane=wideMargin,wideLane
    shot.powerAllowed=touch.fullAllowed(shot)
    if shot.mode=='Fit' then shot.fitAllowed=false end
    if riskPolicy.mode~='SAFE' then
        local speed=runSpeed(receiver)
        shot.receiverETA=speed>0 and math.max(0,flat(shot.arrival-receiver.p).Magnitude-4.5)/speed or math.huge
        shot.raceAdvantage=firstDB-shot.receiverETA;shot.directLane=directLane
        local movement=flat(receiver.v)
        local residual=flat(shot.arrival-predict(receiver,t))
        shot.routeLateral=movement.Magnitude>0 and (residual-movement.Unit*residual:Dot(movement.Unit)).Magnitude or math.huge
        shot.receiverTurn=receiver.routeTurn or receiver.turn
    end
    riskPolicy.BurnFinish(shot)
    -- Once both clearances have a useful safety surplus, extra empty space
    -- must not make a slow floating arc beat an already-safe direct throw.
    shot.score=math.min(margin,CFG.ThrowMargin*2)*1.8+math.min(laneMargin,CFG.ThrowLane*2)*1.5-t*3-receiver.turn*12-(shot.receiverResidual or 0)*.25
    return shot
end

 riskPolicy.mode=context.mode
 receiver.chestReference=inputs.ChestReference
 receiver.dropHistory={}
 for _,d in ipairs(defenders)do d.model=d;local at=inputs.Drops and inputs.Drops[d.name];if at then receiver.dropHistory[d]=at end end
 risk(shot,receiver,defenders)
 return shot
end
