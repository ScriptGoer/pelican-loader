-- PELICAN_FF3_V19: coverage-aware native receiver/mode planning alongside Yuna.
-- Native mode overrides exist only inside protected synchronous solves. Normal
-- Yuna automatic/manual settings are restored before returning to game input.
-- Integration contract comes from the supplied readable QB source, fn13/fn37 and
-- InputBegan release. Read-only closure discovery; no getter replacement/hooks.
-- Catch windows and current server acceptance remain unverified in Roblox.
local context = ... or {}
local VERSION, KEY = 'PELICAN_FF3_V19', 'PELICAN_FF3_AUTO_QB'
local CFG = {Interval=.12, DiscoveryInterval=2, MaxRoster=64,
    Gravity=28, MaxFlight=4.5, MaxRange=330, SelectMargin=3, SelectLane=2,
    ThrowMargin=6, ThrowLane=4, Settle=.24, MinPlayAge=2, MinDownfieldYards=6,
    MinMoveSpeed=2, MinMotionAge=.65, MotionWindow=.8, MinMotionTravel=2.4, FieldDiscoverySeconds=20, PlanCalls=6, PlanSeconds=.008, CacheAge=.36, SafeGap=.4, ReceiverSwitchYards=5,
    AnimationRelease=.19, AnimationTimeout=1.25}
local Players, Run, Input = game:GetService('Players'), game:GetService('RunService'), game:GetService('UserInputService')
local me = Players.LocalPlayer
if not me or game.PlaceId ~= 82866880824588 then error('PELICAN V19 requires the observed FF3 live place') end
local env = type(getgenv)=='function' and getgenv() or _G
local prior = env[KEY]
if prior and (type(prior.Stop)~='function' or prior.Stop('REPLACED')~=true) then error('PELICAN: previous Auto QB cleanup failed') end
local pg = me:FindFirstChild('PlayerGui')
if not pg then error('PELICAN: PlayerGui not ready') end
local coreOK,core=pcall(function() return game:GetService('CoreGui') end)
if not coreOK then core=nil end
-- A standalone V13/probe may have a getter replacement. Require its acknowledgement.
for _, name in ipairs({'PELICAN_FF3_LIVE','PELICAN_YUNA_RETURN_TRACE','PELICAN_YUNA_CONTROL_TEST'}) do
    local old = pg:FindFirstChild(name)
    if old then
        local stop = old:FindFirstChild('Stop')
        if stop and stop:IsA('BindableEvent') then stop:Fire() end
        if old:GetAttribute('WrapperAbsent')~=true then error('PELICAN: legacy getter cleanup unconfirmed: '..name) end
        old:Destroy()
    end
end
local controller = {Version=VERSION, IsStopped=false}
local connections, events, counts, samples = {}, {}, {}, {}
local profile, lease, choice, pending, gui, status, autoButton, throwButton, copyButton
local receiverButton, paceButton, receiverMenu, renderReceivers
local blacklist=env.PELICAN_FF3_WR_BLACKLIST
if type(blacklist)~='table' or getmetatable(blacklist)~=nil then blacklist={}; env.PELICAN_FF3_WR_BLACKLIST=blacklist end
local stopped, cleanupComplete, inTick, auto, throwing, expanded = false, false, false, true, true, false
local lastTick, nextDiscovery, nextSave, cursor = -math.huge, 0, 0, 1
local gate, copyResult, fileResult = 'WAIT_YUNA', 'NOT_REQUESTED', 'NOT_REQUESTED'
local fatalError, stopReason = 'NONE', 'NONE'
local attempts, sent, ambiguous, relinquishments, nativeCalls = 0, 0, 0, 0, 0
local receiverRejects={}
local arrivalRejects={}
local opportunities, shotCache, modeChecks = {}, {}, {}
local planRound, planDeferred, maxPlanCalls = 0, 0, 0
local modeTransaction
local lastDecision, decisionHistory, candidateEvidence = nil, {}, {}
local sequence, ownedAnimation, observedThrow
local cancelSequence, disposeAnimation
local animationStatus, animationSource = 'NOT_REQUESTED', 'NONE'
local lastSequenceOutcome='NONE'
local frameCalls,maxFrameCalls,maxHeartbeat = 0,0,0
local maxTick=0
local fieldWaitSince, fieldWaitSeconds, initialFieldDiscovered, failureNotified = nil, 0, false, false
local function resetFieldWait() fieldWaitSince=nil; fieldWaitSeconds=0 end
local usedTools = setmetatable({}, {__mode='k'})
local possession = {tool=nil, model=nil, wasReady=false, epoch=0, since=0}
local lines={status='SEARCHING',ground=nil,los=nil,forward=nil,at=0,since=0,generation=0,
    parts=setmetatable({}, {__mode='k'}),markerCount=0,labels={},
    scan={q={workspace,pg,core},tail=core and 3 or 2,i=1,stack={},
        queued=setmetatable({}, {__mode='k'}),seen=setmetatable({}, {__mode='k'}),visited=0},
    complete=false,capped=false,negativeText=setmetatable({}, {__mode='k'})}
local V = Vector3.new
local function clean(x) return tostring(x):gsub('[\r\n|]', ' '):sub(1,180) end
local function log(kind, value)
    if #events>=32 then table.remove(events,1) end
    events[#events+1]=kind..'|'..clean(value)
end
local function setGate(value)
    if stopped then return end
    counts[value]=(counts[value] or 0)+1
    if gate~=value then gate=value; log('GATE',value) end
    if status then status.Text=(choice and choice.player.Name..' ' or '')..value:gsub('_',' '):sub(1,24) end
end
local function finite(x) return type(x)=='number' and x==x and math.abs(x)<1e8 end
local ff3Options=context.FF3Options or {}
if type(ff3Options)~='table' then error('PELICAN: FF3 options must be a table') end
for _,key in ipairs({'ReceiverSwitchYards'}) do
    local value=ff3Options[key]
    if value~=nil then
        if not finite(value) or value<1 or value>100 then error('PELICAN: '..key..' must be 1 to 100 yards') end
        CFG[key]=value
    end
end
local function nativeVector(x)
    if x==nil then return end
    local kind=typeof(x)
    if kind=='vector' then
        if finite(x.x) and finite(x.y) and finite(x.z) then return V(x.x,x.y,x.z) end
    elseif kind=='Vector3' or type(x)=='table' then
        if finite(x.X) and finite(x.Y) and finite(x.Z) then return x end
    end
end
local function vector(x) return nativeVector(x)~=nil end
local function flat(v) return V(v.X,0,v.Z) end
local function clamp(x,a,b) return math.max(a,math.min(b,x)) end
local function instance(v,k)
    return typeof(v)=='Instance' and v:IsA(k)
end
local function body(player)
    local model=player and player.Character
    if not model or not model:IsDescendantOf(workspace) then return end
    local hum,root,head=model:FindFirstChildOfClass('Humanoid'),model:FindFirstChild('HumanoidRootPart'),model:FindFirstChild('Head')
    if not hum or hum.Health<=0 or not root or not head or not vector(root.Position) or not vector(head.Position) then return end
    return model,root,head,hum
end
local function receiverKey(player)
    if type(player.UserId)=='number' and player.UserId>0 and player.UserId<1e15 and player.UserId==math.floor(player.UserId) then
        return 'UID:'..tostring(player.UserId)
    end
    return 'NAME:'..player.Name
end
function controller.IsBlacklisted(player) return blacklist[receiverKey(player)]==true end
local function teammate(player)
    if player==me or not me.Team or me.Neutral or player.Neutral or player.Team~=me.Team then return false end
    if controller.IsBlacklisted(player) then return false end
    return body(player)~=nil and Players:GetPlayerFromCharacter(player.Character)==player
end
local function ownsLock()
    if not lease then return false end
    local q=lease.q
    return rawget(q,'Locked')==true and rawget(q,'LockedOnto')==lease.model and rawget(q,'LockedOntoName')==lease.name
end
local function restoreLock()
    if not lease then return end
    if ownsLock() then
        rawset(lease.q,'Locked',lease.before[1]); rawset(lease.q,'LockedOnto',lease.before[2]); rawset(lease.q,'LockedOntoName',lease.before[3])
    else relinquishments=relinquishments+1; log('LOCK','External edit preserved') end
    lease=nil
end
local function lock(player)
    if stopped or not profile or not teammate(player) then return false end
    local q=profile.q
    if lease and (lease.q~=q or not ownsLock()) then restoreLock(); return false end
    if not lease then
        -- Deliberate native/manual locks belong to the user. AUTO must not steal them.
        if q.Locked then return false end
        lease={q=q,before={rawget(q,'Locked'),rawget(q,'LockedOnto'),rawget(q,'LockedOntoName')}}
    end
    lease.model,lease.name=player.Character,player.Name
    rawset(q,'LockedOnto',lease.model); rawset(q,'LockedOntoName',lease.name); rawset(q,'Locked',true)
    return true
end
local function clearWindows()
    candidateEvidence={}
    for k in pairs(opportunities) do opportunities[k]=nil end
    for k in pairs(shotCache) do shotCache[k]=nil end
end
local function restoreModeTransaction()
    local m=modeTransaction
    if not m then return true end
    modeTransaction=nil
    local q=m.q
    local owned=q.AutoThrowType==m.auto and rawget(m.auto,'Enabled')==false and rawget(q,'SelectedType')==m.mode
    if rawget(m.auto,'Enabled')==false then rawset(m.auto,'Enabled',m.enabled) end
    if rawget(q,'SelectedType')==m.mode then rawset(q,'SelectedType',m.selected) end
    if m.worker and coroutine.status(m.worker)=='suspended' and type(coroutine.close)=='function' then pcall(coroutine.close,m.worker) end
    if not owned then log('MODE','External edit preserved during solve') end
    return owned
end
local function releaseChoice(keepWindows)
    if cancelSequence then cancelSequence('SELECTION_RELEASED') end
    choice=nil; restoreModeTransaction(); restoreLock(); if not keepWindows then clearWindows() end
end
function controller.SetBlacklisted(player,value)
    if stopped or not instance(player,'Player') or player==me then return false end
    local key=receiverKey(player)
    blacklist[key]=value==true and true or nil
    log('BLACKLIST',player.Name..' '..tostring(value==true))
    opportunities[player]=nil; shotCache[player]=nil
    if value and choice and choice.player==player then releaseChoice() end
    if renderReceivers then renderReceivers() end
    return true
end

-- LOS geometry is preserved from the earlier FF3 reports: the observed ground
-- and full-width blue/yellow strips (or straight Beams). Direction is never
-- inferred from camera facing, receiver movement, team names, or the QB spawn.
local function groundIssue(o)
    if not o then return 'MISSING' end
    if not instance(o,'BasePart') then return 'NOT_BASEPART' end
    if not o.Parent or not o:IsDescendantOf(workspace) then return 'DETACHED' end
    if not o.Anchored then return 'NOT_ANCHORED' end
    local s=o.Size
    if math.abs(s.X-225)>=.6 or math.abs(s.Y-1)>=.3 or math.abs(s.Z-420)>=.6 then return 'SIZE_MISMATCH' end
    local c=o.CFrame
    if (o.Position-V(0,2.5,0)).Magnitude>=1.5 then return 'WORLD_POSITION_MISMATCH' end
    if c.UpVector.Y<=.999 or math.abs(c.RightVector.X)<=.999 or math.abs(c.LookVector.Z)<=.999 then return 'ORIENTATION_MISMATCH' end
    return 'ACCEPTED'
end
local function groundShape(o) return groundIssue(o)=='ACCEPTED' end
local function observedGround()
    -- Exact path confirmed by the earlier live G166 report; a name never
    -- substitutes for the same current geometry/ancestry validation.
    local models=workspace:FindFirstChild('Models')
    if not models then return nil,'MISSING_MODELS' end
    local field=models:FindFirstChild('Field')
    if not field then return nil,'MISSING_FIELD' end
    local ground=field:FindFirstChild('Ground')
    return ground,groundIssue(ground)
end
local function retainObservedGround()
    local observed,why=observedGround()
    lines.knownGroundIssue=why
    if why=='ACCEPTED' and (not lines.ground or not groundShape(lines.ground)) then
        lines.ground=observed; lines.groundSource='OBSERVED_PATH'
    end
end
local function groundReason()
    if lines.groundAmbiguous then return 'AMBIGUOUS_GROUND_REFERENCES' end
    if not lines.ground then return 'NOT_DISCOVERED' end
    return groundIssue(lines.ground)
end
local function describeGround(o)
    if not o then return 'NONE' end
    if not instance(o,'BasePart') then return 'class='..clean(o.ClassName) end
    return string.format('class=%s size=%.3f,%.3f,%.3f position=%.3f,%.3f,%.3f anchored=%s',
        o.ClassName,o.Size.X,o.Size.Y,o.Size.Z,o.Position.X,o.Position.Y,o.Position.Z,tostring(o.Anchored))
        ..string.format(' upY=%.4f rightX=%.4f lookZ=%.4f',o.CFrame.UpVector.Y,o.CFrame.RightVector.X,o.CFrame.LookVector.Z)
end
local observedLineNames={'LineDown','LineTogo'}
local function observedLine(o)
    -- V2 live evidence identifies these root-level Parts. Names retain candidates
    -- before replication finishes; current geometry still decides acceptance.
    return instance(o,'BasePart') and o.Parent==workspace and (o.Name=='LineDown' or o.Name=='LineTogo')
end
local function retainObservedLines()
    -- Two direct lookups recover late configuration/replacement without a new
    -- global sweep, per-Part listeners, or depending on the scan's seen set.
    for _,name in ipairs(observedLineNames) do
        local o=workspace:FindFirstChild(name)
        if observedLine(o) then lines.parts[o]=true end
    end
end
local function partCandidate(o)
    if not instance(o,'BasePart') or not o.Anchored then return false end
    local s=o.Size; local width=math.max(s.X,s.Z)
    return s.Y<=3 and math.min(s.X,s.Z)<=5 and width>=30 and width<=175 and math.abs(o.Position.X)<=85
        and math.abs(o.Position.Z)<=153 and math.abs(o.Position.Y-3)<4 and o.CFrame.UpVector.Y>=.98
end
local function colorRole(c)
    if c.B>.65 and c.B>c.R+.3 and c.R<.4 and c.G<.85 then return 'BLUE' end
    if c.R>.75 and c.G>.45 and c.B<.4 then return 'YELLOW' end
end
local function markerCandidate(o)
    -- Retain plausible strip geometry even while hidden or using another color;
    -- marker() rechecks current color/visibility every read, without extra listeners.
    if partCandidate(o) then return true end
    if not instance(o,'Beam') or not o.Attachment0 or not o.Attachment1
        or math.abs(o.CurveSize0)>.1 or math.abs(o.CurveSize1)>.1 then return false end
    local a,b=o.Attachment0.WorldPosition,o.Attachment1.WorldPosition
    local d,p=b-a,(a+b)*.5
    return math.abs(d.X)>=30 and math.abs(d.X)<=175 and math.abs(d.Z)<=5 and math.abs(d.Y)<=3
        and math.abs(p.X)<=85 and math.abs(p.Z)<=153 and math.abs(p.Y-3)<4
end
local function enqueueLine(o)
    local scan=lines.scan
    if scan.seen[o] or scan.queued[o] then return end
    scan.tail=scan.tail+1; scan.q[scan.tail]=o; scan.queued[o]=true; lines.complete=false
end
local function scanLines()
    local scan=lines.scan; local work=0; local deadline=os.clock()+.0015
    while work<96 and os.clock()<deadline do
        local frame=scan.stack[#scan.stack]; local o
        if frame then
            if frame.i<=frame.n then
                o=frame.children[frame.i]; frame.children[frame.i]=nil; frame.i=frame.i+1
            else scan.stack[#scan.stack]=nil end
        else
            o=scan.q[scan.i]
            if not o then lines.complete=true; lines.initialComplete=true; scan.q={}; scan.i=1; scan.tail=0; break end
            scan.q[scan.i]=nil; scan.i=scan.i+1; scan.queued[o]=nil
        end
        work=work+1
        if o and not scan.seen[o] then
            scan.seen[o]=true; scan.visited=scan.visited+1
            if o==workspace or o.Parent then
                if groundShape(o) then
                    if lines.ground and groundShape(lines.ground) and lines.ground~=o then lines.groundAmbiguous=true; lines.ambiguousGround=describeGround(o)
                    else lines.ground=o; lines.groundSource='SCAN' end
                elseif observedLine(o) or markerCandidate(o) then
                    lines.parts[o]=true
                elseif instance(o,'TextLabel') or instance(o,'TextButton') then
                    if not (gui and o:IsDescendantOf(gui)) then
                        if #lines.labels<256 then lines.labels[#lines.labels+1]=o
                        elseif o.Text:lower():match('^[1-4]%a%a%s*&%s*') then
                            for i,old in ipairs(lines.labels) do
                                if not old.Parent or lines.negativeText[old] then lines.labels[i]=o; break end
                            end
                        end
                    end
                end
                if not instance(o,'Humanoid') and not (instance(o,'Model') and o:FindFirstChildOfClass('Humanoid')) then
                    local children=o:GetChildren()
                    if #children>0 then scan.stack[#scan.stack+1]={children=children,n=#children,i=1} end
                end
            end
        end
    end
end
local function marker(o,ground)
    if not o.Parent or not o:IsDescendantOf(workspace) then return end
    local cf=ground.CFrame; local center,dx,dz,height,role
    if instance(o,'BasePart') then
        role=colorRole(o.Color)
        local white=o.Color.R>.7 and o.Color.G>.7 and o.Color.B>.7
        if not role and not white or not o.Anchored or o.Transparency>.65 or o.CFrame.UpVector.Y<.98 then return end
        local sz,c=o.Size,o.CFrame
        dx=math.abs(c.RightVector:Dot(cf.RightVector))*sz.X+math.abs(c.LookVector:Dot(cf.RightVector))*sz.Z
        dz=math.abs(c.RightVector:Dot(cf.LookVector))*sz.X+math.abs(c.LookVector:Dot(cf.LookVector))*sz.Z
        center,height=o.Position,sz.Y
    else
        if not o.Enabled or not o.Attachment0 or not o.Attachment1 or math.abs(o.CurveSize0)>.1 or math.abs(o.CurveSize1)>.1 then return end
        for _,endpoint in ipairs({o.Attachment0,o.Attachment1}) do
            local at=endpoint.Parent
            for _=1,6 do
                if not at or at==workspace then break end
                if instance(at,'BasePart') and not at.Anchored or instance(at,'Model') and at:FindFirstChildOfClass('Humanoid') then return end
                at=at.Parent
            end
        end
        for _,k in ipairs(o.Color.Keypoints) do local r=colorRole(k.Value); if not r or role and r~=role then return end; role=r end
        for _,k in ipairs(o.Transparency.Keypoints) do if k.Value>.65 then return end end
        local a,b=o.Attachment0.WorldPosition,o.Attachment1.WorldPosition
        local d=cf:VectorToObjectSpace(b-a); center=(a+b)*.5; dx,dz,height=math.abs(d.X),math.abs(d.Z),math.abs(d.Y)
    end
    local p=cf:PointToObjectSpace(center)
    if dx<30 or dx>175 or dz>5 or height>3 or math.abs(p.X)>85 or math.abs(p.Y-.5)>4 or math.abs(p.Z)>153 then return end
    if not role then
        if math.abs(math.abs(p.Z)-150)<.6 and math.abs(dx-160)<1 and math.abs(dz-.25)<.1 then role='GOAL' else return end
    end
    return role,p.Z,p.X-dx/2,p.X+dx/2
end
local function downReading()
    local result
    for _,o in ipairs(lines.labels) do
        if o.Parent and lines.negativeText[o]~=o.Text then
            local raw=o.Text
            local text=raw:gsub('<[^>]*>',''):gsub('^%s+',''):gsub('%s+$','')
            local yards=text:match('^[1-4]%a%a%s*&%s*(%d+)$')
            yards=yards and tonumber(yards)
            if text:lower():match('^[1-4]%a%a%s*&%s*goal$') then yards='GOAL' end
            if yards=='GOAL' or type(yards)=='number' and yards>=1 and yards<=30 then
                local shown=o:IsDescendantOf(pg) or core and o:IsDescendantOf(core); local at=o
                for _=1,16 do
                    if not at then break end
                    if instance(at,'GuiObject') and not at.Visible or instance(at,'LayerCollector') and not at.Enabled then shown=false; break end
                    at=at.Parent
                end
                local cam=workspace.CurrentCamera
                if shown and (not cam or o.AbsolutePosition.Y<cam.ViewportSize.Y*.4) then
                    if result and result~=yards then return nil,'CONFLICTING_DOWN_HUD' end
                    result=yards
                end
            else lines.negativeText[o]=raw end
        end
    end
    return result
end
local function readLines(now)
    retainObservedGround()
    retainObservedLines()
    local ground=lines.ground
    local function missing(reason)
        lines.status=reason; lines.los=nil; lines.forward=nil; lines.since=0; return false
    end
    -- The bound applies to actual marker geometry, never the number of visited
    -- map objects or unrelated Beams. It recovers as markers disappear/hide.
    lines.capped=false; lines.markerCount=0
    if not ground or not groundShape(ground) or lines.groundAmbiguous then return missing('LOS_GROUND_UNKNOWN') end
    if not lines.initialComplete then return missing('LOS_SEARCHING') end
    local clusters={BLUE={},YELLOW={},GOAL={}}; local inspected=0
    for o in pairs(lines.parts) do
        inspected=inspected+1
        if inspected>512 then lines.capped=true; return missing('LOS_CANDIDATE_LIMIT') end
        local role,z,lo,hi
        if not o.Parent or not o:IsDescendantOf(workspace) then lines.parts[o]=nil
        else role,z,lo,hi=marker(o,ground) end
        if role then
            lines.markerCount=lines.markerCount+1
            if lines.markerCount>128 then lines.capped=true; return missing('LOS_MARKER_LIMIT') end
            local groups=clusters[role]; local group
            for _,g in ipairs(groups) do if math.abs(g.z-z)<.3 then group=g; break end end
            if not group then group={z=z,segments={}}; groups[#groups+1]=group end
            group.segments[#group.segments+1]={lo=lo,hi=hi}
        end
    end
    local valid={BLUE={},YELLOW={},GOAL={}}
    for role,groups in pairs(clusters) do
        for _,g in ipairs(groups) do
            table.sort(g.segments,function(a,b) return a.lo<b.lo end)
            local lo,hi=g.segments[1].lo,g.segments[1].hi; local continuous=true
            for i=2,#g.segments do local s=g.segments[i]; if s.lo>hi+2 then continuous=false end; hi=math.max(hi,s.hi) end
            if continuous and hi-lo>=130 and hi-lo<=175 and math.abs((hi+lo)/2)<5 then valid[role][#valid[role]+1]=g end
        end
    end
    if #valid.BLUE~=1 then return missing('LOS_BLUE_MISSING_OR_AMBIGUOUS') end
    local blue,yellow=valid.BLUE[1],valid.YELLOW[1]
    local yards,conflict=downReading()
    if conflict then return missing(conflict) end
    if yards=='GOAL' and math.abs(blue.z)>=120 and math.abs(blue.z)<150 then
        yellow=nil
        for _,g in ipairs(valid.GOAL) do if g.z*blue.z>0 then if yellow then return missing('LOS_GOAL_AMBIGUOUS') end; yellow=g end end
        if not yellow then return missing('LOS_GOAL_UNKNOWN') end
    elseif #valid.YELLOW~=1 then return missing('LOS_YELLOW_MISSING_OR_AMBIGUOUS') end
    local delta=yellow.z-blue.z
    local minGap,maxGap=yards=='GOAL' and .5 or 2,yards=='GOAL' and 31 or 90
    if math.abs(delta)<minGap or math.abs(delta)>maxGap then return missing('LOS_LINE_DISTANCE_INVALID') end
    if type(yards)=='number' and math.abs(math.abs(delta)/3-yards)>.8 then return missing('LOS_DOWN_HUD_MISMATCH') end
    local cf=ground.CFrame
    local los=ground.Position+cf.UpVector*.5-cf.LookVector*blue.z
    local forward=cf.LookVector*(delta>0 and -1 or 1)
    local same=lines.los and flat(lines.los-los).Magnitude<.05 and lines.forward:Dot(forward)>.99
    local sameMeaning=lines.confirmedLos and flat(lines.confirmedLos-los).Magnitude<.05
        and lines.confirmedForward:Dot(forward)>.99 and math.abs(lines.confirmedTargetZ-yellow.z)<.05
        and lines.confirmedGround==ground
    if not sameMeaning then
        lines.generation=lines.generation+1
        log('LOS',string.format('z=%.2f forwardZ=%.0f',los.Z,forward.Z))
    end
    if not same or not sameMeaning then lines.since=now end
    lines.confirmedLos,lines.confirmedForward,lines.confirmedTargetZ,lines.confirmedGround=los,forward,yellow.z,ground
    lines.los,lines.forward,lines.at=los,forward,now
    lines.status=now-lines.since>=.25 and 'OBSERVED_LINES_STABLE' or 'LOS_SETTLING'
    return lines.status=='OBSERVED_LINES_STABLE'
end
local function downfield(point)
    return lines.los and lines.forward and flat(point-lines.los):Dot(lines.forward) or -math.huge
end
local function onField(point)
    if not lines.ground then return false end
    local p=lines.ground.CFrame:PointToObjectSpace(point)
    return math.abs(p.X)<=80 and math.abs(p.Z)<=180
end
local function onLineAdded(o)
    if stopped then return end
    if observedLine(o) then lines.parts[o]=true end
    if groundShape(o) or partCandidate(o) then enqueueLine(o)
    elseif instance(o,'Beam') then
        -- Ignore Yuna's constantly recreated trajectory visuals. Only observed
        -- field-spanning marker geometry joins the long-lived discovery queue.
        if lines.ground and marker(o,lines.ground) then enqueueLine(o) end
    elseif instance(o,'TextLabel') or instance(o,'TextButton') then
        -- Read after the bounded scan resumes, so Parent-before-Text creation
        -- still discovers a newly recreated scoreboard. No per-label listeners.
        if not (gui and o:IsDescendantOf(gui)) then enqueueLine(o) end
    elseif instance(o,'Folder') or instance(o,'Model') then
        if not (gui and o:IsDescendantOf(gui)) then enqueueLine(o) end
    end
end
function controller.GetReport()
    local rows={VERSION,'PLACE|'..tostring(game.PlaceId),'STATE|'..(stopped and 'STOPPED' or 'RUNNING'),
        'GATE|'..gate,'AUTO|'..tostring(auto),'THROW|'..tostring(throwing),'CLEANUP_CONFIRMED|'..tostring(cleanupComplete),
        'STOP_REASON|'..stopReason,'FATAL_ERROR|'..fatalError,'ERROR_POLICY|STOP_AND_PRESERVE_NO_RETRY',
        'PROFILE|'..(profile and 'SHARED_LOCK_NATIVE_SOLVER_LIVE_INPUT' or 'NONE'),
        'TARGET|'..(choice and choice.player.Name or 'NONE'),'MODE|'..(choice and choice.shot.mode or 'NONE'),
        'ATTEMPTS|'..attempts,'REQUEST_SENT|'..sent,'AMBIGUOUS_REQUESTS|'..ambiguous,
        'NATIVE_SOLVER_CALLS|'..nativeCalls,'EXTERNAL_LOCK_EDITS|'..relinquishments,'MAX_TICK_SECONDS|'..string.format('%.6f',maxTick),
        'COPY_RESULT|'..copyResult,'FILE_RESULT|'..fileResult,
        'LOS_STATUS|'..lines.status,'LOS_WORLD_Z|'..(lines.los and string.format('%.2f',lines.los.Z) or 'NONE'),
        'ATTACK_FORWARD_Z|'..(lines.forward and string.format('%.0f',lines.forward.Z) or 'NONE'),
        'LOS_SCAN_COMPLETE|'..tostring(lines.complete),'LOS_SCAN_CAPPED|'..tostring(lines.capped),
        'LOS_MARKER_CANDIDATES|'..lines.markerCount,'LOS_SCAN_VISITED|'..lines.scan.visited,
        'LOS_SCAN_PENDING_ROOTS|'..math.max(0,lines.scan.tail-lines.scan.i+1),
        'LOS_DISCOVERY_PROFILE|V15.4.2_OBSERVED_GROUND_PATH_NATIVE_MODES',
        'GROUND_REASON|'..groundReason(),'GROUND_SOURCE|'..(lines.groundSource or 'NONE'),
        'GROUND_CACHED|'..describeGround(lines.ground),
        'GROUND_AMBIGUITY_OTHER|'..(lines.ambiguousGround or 'NONE'),
        'GROUND_KNOWN_PATH|workspace.Models.Field.Ground',
        'GROUND_KNOWN_REASON|'..select(2,observedGround()),
        'GROUND_KNOWN|'..describeGround((observedGround())),
        'INITIAL_FIELD_DISCOVERED|'..tostring(initialFieldDiscovered),
        'FIELD_DISCOVERY_DEADLINE_SECONDS|'..CFG.FieldDiscoverySeconds,
        'FIELD_WAIT_POLICY|READY_QB_POSSESSION_ONLY; NO_PREGAME_STARTUP_COUNTDOWN',
        'FIELD_WAIT_ARMED|'..tostring(fieldWaitSince~=nil),
        'FIELD_WAIT_ACTIVE_SECONDS|'..string.format('%.2f',fieldWaitSeconds),
        'NATIVE_MODE_OWNERSHIP|PROTECTED_SOLVE_ONLY; YUNA_AUTO_RESTORED_BETWEEN_CALLS',
        'RELEASE_VERSION|ff3-v19','MODE_SCOPE_ACTIVE|'..tostring(modeTransaction~=nil),
        'DEFENDER_MODEL|SPEED_BOUNDED_PURSUIT; INHERITED_UNCALIBRATED_REACH',
        'SAFE_OPEN_SECONDS|'..CFG.Settle,'MODEL_MAX_FLIGHT_SECONDS|'..CFG.MaxFlight,'MODEL_MAX_RANGE_STUDS|'..CFG.MaxRange,
        'MAX_HEARTBEAT_SECONDS|'..string.format('%.6f',maxHeartbeat),'MAX_NATIVE_CALLS_FRAME|'..maxFrameCalls,
        'DEEP_THROW_YARDS|REMOVED','RECEIVER_POLICY|CLEAR_BURN_FIRST; SHORT_COMPLETIONS_OTHERWISE',
        'RECEIVER_SWITCH_YARDS|'..CFG.ReceiverSwitchYards,'AUTO_JUMP_REQUESTS|0',
        'AUTO_JUMP_POLICY|REMOVED; NO_APEX_GATE',
        'BURN_RELEASE_POLICY|NO_PLAY_AGE_OR_SAFE_HOLD_OR_ANIMATION_DELAY; FRESH_SAFETY_RECHECK',
        'RELEASE_PREPARED|'..tostring(sequence~=nil),'RELEASE_PREPARE_OUTCOME|'..lastSequenceOutcome,'THROW_ANIMATION_STATUS|'..animationStatus,'THROW_ANIMATION_SOURCE|'..animationSource,
        'THROW_ANIMATION_PLAYING|'..tostring(ownedAnimation~=nil and ownedAnimation.track.IsPlaying==true),
        'THROW_ANIMATION_ASSET|'..(ownedAnimation and clean(ownedAnimation.asset) or 'NONE'),
        'WINDOW|'..(choice and choice.shot.window or 'NONE'),'PLANNER_MAX_CALLS|'..maxPlanCalls,'PLANNER_DEFERRED|'..planDeferred,
        'MIN_PLAY_SECONDS|'..CFG.MinPlayAge,'MIN_DOWNFIELD_YARDS|'..CFG.MinDownfieldYards,
        'POSSESSION_AGE_SECONDS|'..(possession.epoch>0 and string.format('%.2f',math.max(0,os.clock()-possession.since)) or 'NONE'),
        'TARGET_DEPTH_YARDS|'..(choice and string.format('%.2f',downfield(choice.sample.p)/3) or 'NONE'),
        'OPEN_HOLD_SECONDS|'..(choice and choice.openSince and string.format('%.2f',os.clock()-choice.openSince) or 'NONE'),
        'RECEIVER_READINESS|CURRENT_POSITION_BEYOND_LOS; OBSERVED_RECENT_CONTINUOUS_MOVEMENT',
        'RUNTIME_VALIDATION|UNVERIFIED_IN_ROBLOX','JUMP_CATCH_CALIBRATION|MISSING; NO_ADDED_JUMP_BULLET',
        'RELEASE|SOURCE_NATIVE_SOLVER_OUTPUT; ONE_REQUEST_PER_POSSESSION; NO_AUTOMATIC_RETRY'}
    for _,name in ipairs(observedLineNames) do
        local o=workspace:FindFirstChild(name)
        rows[#rows+1]='LOS_NAMED_LINE|'..name..' class='..(o and o.ClassName or 'MISSING')
            ..' retained='..tostring(o~=nil and lines.parts[o]==true)
    end
    if profile then
        rows[#rows+1]='NATIVE_CURRENT_SETTINGS|autoType='..tostring(profile.q.AutoThrowType.Enabled)
            ..' selectedType='..clean(profile.q.SelectedType)..' angle='..clean(profile.q.Angle)
            ..' manual='..clean(profile.q.ManualType)..' power='..clean(profile.q.Power)
            ..' locked='..tostring(profile.q.Locked)..' lockedName='..clean(profile.q.LockedOntoName)
    end
    for _,mode in ipairs({'Bullet','Fit','Dime','Jump'}) do rows[#rows+1]='MODE_EVALUATIONS|'..mode..' '..(modeChecks[mode] or 0) end
    for i,decision in ipairs(decisionHistory) do
        rows[#rows+1]='THROW_EVIDENCE|'..i..' '..decision.summary
        rows[#rows+1]='THROW_TRAJECTORY|'..i..' '..decision.trajectory
        rows[#rows+1]='THROW_RELEASE|'..i..' '..decision.release
        for _,candidate in ipairs(decision.candidates) do rows[#rows+1]='THROW_COMPARISON|'..i..' '..candidate end
        for _,actor in ipairs(decision.actors) do rows[#rows+1]='THROW_ACTOR|'..i..' '..actor end
    end
    for mode,receipt in pairs(arrivalRejects) do
        rows[#rows+1]=string.format('NATIVE_ARRIVAL_REJECT|%s %s t=%.3f arrival=%.3f,%.3f,%.3f aim=%.3f,%.3f,%.3f',mode,receipt.target,receipt.time,receipt.arrival.X,receipt.arrival.Y,receipt.arrival.Z,receipt.aim.X,receipt.aim.Y,receipt.aim.Z)
    end
    for _,candidate in ipairs(candidateEvidence) do rows[#rows+1]='CURRENT_COMPARISON|'..candidate end
    if pending then rows[#rows+1]='LAST_REQUEST|'..pending.target..' '..pending.mode..' '..pending.outcome end
    local blocked={}; for k,v in pairs(blacklist) do if v then blocked[#blocked+1]=k end end; table.sort(blocked)
    rows[#rows+1]='BLACKLIST|'..table.concat(blocked,',')
    for name,reason in pairs(receiverRejects) do rows[#rows+1]='RECEIVER_REJECT|'..clean(name)..' '..reason end
    local keys={}; for k in pairs(counts) do keys[#keys+1]=k end; table.sort(keys)
    for _,k in ipairs(keys) do rows[#rows+1]='GATE_COUNT|'..k..' '..counts[k] end
    for _,line in ipairs(events) do rows[#rows+1]=line end
    return table.concat(rows,'\n')
end
local function preserve(copy)
    if copy then
        copyResult='UNAVAILABLE'
        if type(setclipboard)=='function' then local ok=pcall(setclipboard,controller.GetReport()); copyResult=ok and 'API_ACCEPTED' or 'FAILED' end
    end
    fileResult='UNAVAILABLE'
    if type(writefile)=='function' then
        fileResult='API_ACCEPTED'
        local ok=pcall(writefile,'PELICAN_FF3_AUTO_QB_REPORT.txt',controller.GetReport())
        if not ok then fileResult='FAILED' end
    end
    env.PELICAN_FF3_LAST_REPORT=controller.GetReport()
end
function controller.Stop(reason)
    if cleanupComplete then return true end
    if not stopped then stopReason=clean(reason or 'USER_END') end
    stopped=true; controller.IsStopped=true; fieldWaitSince=nil
    releaseChoice()
    if disposeAnimation then disposeAnimation() end
    local remaining={}
    for _,connection in ipairs(connections) do
        local ok=pcall(function() connection:Disconnect() end)
        if not ok then remaining[#remaining+1]=connection end
    end
    connections=remaining; log('STOP',reason or 'USER_END'); gate='STOPPED'
    if gui then local ok=pcall(function() gui:Destroy() end); if ok then gui=nil end end
    cleanupComplete=#remaining==0 and gui==nil and lease==nil and modeTransaction==nil and sequence==nil and ownedAnimation==nil
    preserve(true)
    if cleanupComplete and env[KEY]==controller then env[KEY]=nil end
    -- The loader's init pcall cannot see a later heartbeat failure. Notify it
    -- after cleanup so its retained error/report view stays visible. Reentry
    -- during loader rollback is idempotent and never resubmits this notice.
    if fatalError~='NONE' and not failureNotified then
        failureNotified=true
        local message=stopReason..': '..fatalError
        if type(context.ReportRuntimeError)=='function' then pcall(context.ReportRuntimeError,message)
        elseif type(warn)=='function' then pcall(warn,'PELICAN stopped: '..message..'; report saved') end
    end
    return cleanupComplete
end
function controller.SetAuto(value)
    auto=value==true
    if not auto then resetFieldWait(); releaseChoice() end
    if autoButton then autoButton.Text=auto and 'AUTO ON' or 'AUTO OFF' end
    log('AUTO',auto)
end
function controller.SetThrow(value)
    throwing=value==true
    if not throwing and cancelSequence then cancelSequence('THROW_OFF') end
    if throwButton then throwButton.Text=throwing and 'THR ON' or 'THR OFF' end
    log('THROW',throwing)
end
if context.RegisterCleanup then context.RegisterCleanup(function() return controller.Stop('LOADER_CLEANUP') end) end
if context.IsCancelled and context.IsCancelled() then controller.Stop('CANCELLED'); return controller end
env[KEY]=controller

-- Bounded read-only discovery. A final solver must be shared by a live preview
-- connection and the source-shaped input release, and capture the same settings
-- table as the native selector. No fixed upvalue indexes or callable guesses.
local getUV=getupvalues or (debug and debug.getupvalues)
local getK=getconstants or (debug and debug.getconstants)
local function constants(fn)
    local ok,values=pcall(getK,fn); local result={}
    if ok and type(values)=='table' then for _,v in pairs(values) do if type(v)=='string' or type(v)=='number' then result[v]=true end end end
    return result
end
local function has(c,...)
    for i=1,select('#',...) do if not c[select(i,...)] then return false end end
    return true
end
local function values(fn)
    local ok,v=pcall(getUV,fn); return ok and type(v)=='table' and v or {}
end
local modes={Bullet=true,Fit=true,Jump=true,Dive=true,Dime=true}
local function settings(t)
    return type(t)=='table' and getmetatable(t)==nil and type(rawget(t,'Enabled'))=='boolean'
        and type(rawget(t,'MouseAimbot'))=='table' and type(rawget(t,'AutoThrowType'))=='table'
        and modes[rawget(t,'SelectedType')]==true and finite(rawget(t,'Angle'))
        and (rawget(t,'ManualType')=='Angle' or rawget(t,'ManualType')=='Power')
end
local function leadTable(t)
    if type(t)~='table' or getmetatable(t)~=nil then return false end
    for _,name in ipairs({'Bullet','Fit','Dime','Jump','Dive'}) do
        local v=rawget(t,name)
        if typeof(v)~='Vector2' or not finite(v.X) or not finite(v.Y) then return false end
    end
    return true
end
local function hud(t)
    if type(t)~='table' or getmetatable(t)~=nil then return false end
    for _,key in ipairs({'Player','Time','Angle','Type'}) do
        local card=rawget(t,key)
        if type(card)~='table' or not instance(rawget(card,'CardText'),'TextLabel') then return false end
    end
    return true
end
local function state(t)
    local statusValue,throwableValue
    if typeof(t)=='Instance' then
        statusValue,throwableValue=t:FindFirstChild('Status'),t:FindFirstChild('Throwable')
    elseif type(t)=='table' and getmetatable(t)==nil then
        statusValue,throwableValue=rawget(t,'Status'),rawget(t,'Throwable')
    end
    if instance(statusValue,'StringValue') and instance(throwableValue,'BoolValue') then
        return {Status=statusValue,Throwable=throwableValue}
    end
end
local function tables(uv)
    local result,seen={},{}
    local function add(t,depth)
        if seen[t] or #result>=80 then return end
        if typeof(t)=='Instance' then seen[t]=true; result[#result+1]=t; return end
        if type(t)~='table' or getmetatable(t)~=nil then return end
        seen[t]=true; result[#result+1]=t
        if depth>0 then
            local n=0
            for _,v in pairs(t) do n=n+1; if n>40 then break end; add(v,depth-1) end
        end
    end
    for _,v in pairs(uv) do add(v,2) end
    return result
end
local function graph(root)
    local list,seen={{fn=root,depth=0}},{}
    local at=1
    while at<=#list and at<=64 do
        local node=list[at]; at=at+1
        seen[node.fn]=true; node.uv=values(node.fn); node.k=constants(node.fn)
        if node.depth<3 then
            for _,v in pairs(node.uv) do
                if type(v)=='function' and not seen[v] and #list<64 then seen[v]=true; list[#list+1]={fn=v,depth=node.depth+1} end
            end
        end
    end
    return list
end
local function nativeLeads(fn)
    local found
    for _,node in ipairs(graph(fn)) do
        for _,t in ipairs(tables(node.uv)) do
            if leadTable(t) then if found and found~=t then return nil end; found=t end
        end
    end
    return found
end
local function aliveConnection(c)
    local ok,result=pcall(function() return c.Connected~=false and c.Enabled~=false end)
    return ok and result
end
local function roots(signal,kind)
    local ok,all=pcall(getconnections,signal); local out={}
    if not ok or type(all)~='table' then return out end
    local checked=0
    for _,connection in pairs(all) do
        checked=checked+1; if checked>160 then break end
        local got,fn=pcall(function() return connection.Function end)
        if got and type(fn)=='function' and aliveConnection(connection) then
            local c=constants(fn)
            local matches=kind=='preview' and has(c,'Angle','SelectedType','MouseAimbot','Enabled')
                or kind=='release' and has(c,'Clicked','RemoteEvent','FireServer','TimePosition',70000000)
            if matches then out[#out+1]={connection=connection,fn=fn,nodes=graph(fn)} end
        end
    end
    return out
end
local function discover()
    if type(getconnections)~='function' or type(getUV)~='function' or type(getK)~='function' then return nil,'EXECUTOR_REFLECTION_MISSING' end
    local previews,releases=roots(Run.Heartbeat,'preview'),roots(Input.InputBegan,'release')
    local matches={}; local seen={}; local missingLeads=false
    for _,p in ipairs(previews) do
        for _,n in ipairs(p.nodes) do
            if has(n.k,'AutoThrowType','CardText','CardName','Player','Time','Type','Head') then
                local q,h,selector
                for _,t in ipairs(tables(n.uv)) do if settings(t) then if q and q~=t then q=false; break end; q=t end end
                if q then
                    for _,t in ipairs(tables(n.uv)) do if hud(t) then h=t end end
                    for _,fn in pairs(n.uv) do
                        if type(fn)=='function' and has(constants(fn),'LockedOnto','LockedOntoName','GetMouseLocation','GetPlayers') then
                            for _,t in ipairs(tables(values(fn))) do if t==q then selector=fn end end
                        end
                    end
                end
                if q and h and selector then
                    for _,r in ipairs(releases) do
                        local same=false; for _,rn in ipairs(r.nodes) do if rn.fn==n.fn then same=true end end
                        local leads=nativeLeads(n.fn)
                        if same and not leads then missingLeads=true end
                        local s; for _,t in ipairs(tables(values(r.fn))) do local found=state(t); if found then s=found end end
                        if same and s and leads and not seen[n.fn] then
                            seen[n.fn]=true; matches[#matches+1]={q=q,hud=h,selector=selector,solve=n.fn,state=s,preview=p.connection,release=r.connection,leads=leads}
                        end
                    end
                end
            end
        end
    end
    if #matches~=1 then return nil,#matches==0 and (missingLeads and 'NATIVE_LEAD_TABLE_MISSING_OR_AMBIGUOUS' or 'WAIT_YUNA_SOURCE_PROFILE') or 'AMBIGUOUS_YUNA_INSTANCES' end
    return matches[1]
end
local function equipped(model)
    local found
    for _,child in ipairs(model:GetChildren()) do
        if child:IsA('Tool') then
            local handle=child:FindFirstChild('Handle'); local remote=handle and handle:FindFirstChild('RemoteEvent')
            if remote and remote:IsA('RemoteEvent') then if found then return end; found={tool=child,remote=remote} end
        end
    end
    return found
end
-- Resolve an existing game Throw asset, never an invented animation ID and
-- never Tool:Activate() (which could also submit an uncontrolled native throw).
local function throwAsset(value,role)
    if instance(value,'AnimationTrack') then
        local asset=value.Animation
        if instance(asset,'Animation') and (role or value.Name=='Throw' or asset.Name=='Throw') then
            return asset,value.Priority
        end
    elseif instance(value,'Animation') and (role or value.Name=='Throw') then return value end
end
local function findThrowAsset(ball)
    local found,priority,source,ambiguous
    local function add(value,role,why)
        local asset,p=throwAsset(value,role)
        if not asset then return end
        local id=asset.AnimationId
        if type(id)~='string' or not id:match('^rbxassetid://%d+$') and not id:match('^https?://[^%s]+[?&]id=%d+') then return end
        if found and found.AnimationId~=id then ambiguous=true; return end
        found,priority,source=asset,p or priority,why
    end
    -- A native Throw track observed on this very character is strongest evidence.
    if observedThrow and observedThrow.model==ball.model then
        add(observedThrow.track,true,'OBSERVED_CURRENT_CHARACTER_THROW')
        if found then return found,priority,source end
    end
    -- Inspect captures, not callable guesses. Only the already-qualified native
    -- release and actual equipped tool's Activated closures are considered.
    local rootsToInspect={profile.release.Function}
    if type(getconnections)=='function' then
        local ok,connectionsForTool=pcall(getconnections,ball.tool.Activated)
        if ok and type(connectionsForTool)=='table' then
            local n=0
            for _,connection in pairs(connectionsForTool) do
                n=n+1; if n>16 then break end
                local got,fn=pcall(function() return connection.Function end)
                if got and type(fn)=='function' and aliveConnection(connection) then rootsToInspect[#rootsToInspect+1]=fn end
            end
        end
    end
    for _,fn in ipairs(rootsToInspect) do
        if type(fn)=='function' then
            for _,node in ipairs(graph(fn)) do
                for _,value in pairs(node.uv) do add(value,false,'QUALIFIED_RELEASE_OR_TOOL_CAPTURE') end
                for _,t in ipairs(tables(node.uv)) do
                    add(t,false,'QUALIFIED_RELEASE_OR_TOOL_CAPTURE')
                    if type(t)=='table' and getmetatable(t)==nil then
                        add(rawget(t,'Throw'),true,'QUALIFIED_THROW_TABLE_ENTRY')
                    end
                end
            end
        end
    end
    if ambiguous then return nil,nil,'AMBIGUOUS_CAPTURED_THROW_ASSETS' end
    if found then return found,priority,source end
    -- Bounded local asset search. No world scan and no remote/function invocation.
    local rootsToScan={ball.model}
    local replicated=game:GetService('ReplicatedStorage')
    for _,child in ipairs(replicated:GetChildren()) do
        if child.Name:lower():find('anim',1,true) then rootsToScan[#rootsToScan+1]=child end
    end
    local stack={}; for _,root in ipairs(rootsToScan) do stack[#stack+1]=root end
    local visited=0
    while #stack>0 and visited<256 do
        local object=table.remove(stack); visited=visited+1
        add(object,object.Parent and object.Parent.Name=='Throw','LOCAL_OR_REPLICATED_ANIMATION_ASSET')
        local children=object:GetChildren()
        if #children+#stack>256 then return nil,nil,'LOCAL_ANIMATION_SEARCH_LIMIT' end
        for _,child in ipairs(children) do stack[#stack+1]=child end
    end
    if #stack>0 then return nil,nil,'LOCAL_ANIMATION_SEARCH_LIMIT' end
    if ambiguous then return nil,nil,'AMBIGUOUS_LOCAL_THROW_ASSETS' end
    return found,priority,source or 'NATIVE_THROW_ASSET_NOT_FOUND'
end
disposeAnimation=function()
    if not ownedAnimation then return true end
    local track=ownedAnimation.track
    local ok=pcall(function() if track.IsPlaying then track:Stop() end; track:Destroy() end)
    if ok then ownedAnimation=nil end
    return ok
end
cancelSequence=function(reason)
    local old=sequence; sequence=nil
    if not old then return end
    lastSequenceOutcome=reason or 'CANCELLED'
    if old.animation and old.animation.track.IsPlaying then
        local ok,err=pcall(function() old.animation.track:Stop() end)
        if not ok then animationStatus='OWNED_ANIMATION_CLEANUP_FAILED'; log('ANIMATION_CLEANUP_ERROR',err) end
    end
    log('RELEASE_CANCEL',reason or 'CANCELLED')
end
local function startAnimation(ball,now)
    if ownedAnimation and (ownedAnimation.model~=ball.model or ownedAnimation.hum~=ball.hum) then
        if not disposeAnimation() then error('Owned throw animation cleanup failed') end
    end
    if not ownedAnimation then
        local asset,priority,why=findThrowAsset(ball)
        animationSource=why or 'NONE'
        if not asset then
            -- Preserve the user-confirmed V17 release when no actual asset is
            -- exposed. Report the limitation explicitly instead of guessing one.
            animationStatus=why or 'NATIVE_THROW_ASSET_NOT_FOUND'
            log('ANIMATION_UNAVAILABLE',animationStatus); return nil
        end
        local animator=ball.hum:FindFirstChildOfClass('Animator')
        if not animator then animationStatus='CURRENT_ANIMATOR_MISSING'; log('ANIMATION_UNAVAILABLE',animationStatus); return nil end
        local track=animator:LoadAnimation(asset)
        if not instance(track,'AnimationTrack') then error('Native Throw asset did not return an AnimationTrack') end
        ownedAnimation={track=track,model=ball.model,hum=ball.hum,source=animationSource,asset=asset.AnimationId}
        track.Name='PELICAN_AUTO_THROW'; track.Looped=false
        track.Priority=priority or Enum.AnimationPriority.Action
    end
    local track=ownedAnimation.track
    if track.IsPlaying then track:Stop() end
    track:Play()
    animationStatus='OWN_NATIVE_THROW_STARTED'; animationSource=ownedAnimation.source
    return {track=track,at=now}
end
local function animationReady(now)
    if not sequence.animation then return true end
    local track=sequence.animation.track
    if finite(track.TimePosition) and track.TimePosition>=CFG.AnimationRelease then return true end
    if now-sequence.animation.at>=CFG.AnimationTimeout then
        fatalError='Native Throw animation did not reach its source-observed release time'
        controller.Stop('THROW_ANIMATION_NOT_ADVANCING')
    end
    return false
end

local function ready()
    if stopped or (context.IsCancelled and context.IsCancelled()) then return nil,'STOPPED' end
    if not auto then return nil,'AUTO_OFF' end
    if not profile then return nil,'WAIT_YUNA_SOURCE_PROFILE' end
    local q=profile.q
    if not q.Enabled then return nil,'ENABLE_YUNA_QB_AIMBOT' end
    if q.MouseAimbot.Enabled then return nil,'YUNA_MOUSE_AIM_ACTIVE' end
    if q.AutoThrowType.Enabled~=true then return nil,'ENABLE_YUNA_AUTO_THROW_TYPE' end
    if profile.state.Status.Value~='InPlay' or profile.state.Throwable.Value~=true then return nil,'WAIT_THROWABLE_PLAY' end
    if not me.Team or me.Neutral then return nil,'WAIT_TEAM' end
    local model,root,head,hum=body(me)
    if not model then return nil,'WAIT_QB_ALIVE' end
    local ball=equipped(model)
    if not ball then return nil,'WAIT_EQUIPPED_BALL' end
    -- Same native animation observation as readable fn26. Manual Yuna input
    -- owns a throw already in progress; AUTO must not submit a competing one.
    local observed,tracks=pcall(function() return hum:GetPlayingAnimationTracks() end)
    if not observed or type(tracks)~='table' then return nil,'NATIVE_ANIMATION_OBSERVATION_FAILED' end
    for _,track in ipairs(tracks) do
        if track.Name=='Throw' and track.IsPlaying then
            ball.nativeThrow=true; observedThrow={model=model,track=track}; break
        end
    end
    ball.model,ball.root,ball.head,ball.hum=model,root,head,hum
    return ball
end
local function sample(player,now)
    local model,root,head,hum=body(player)
    if not model then samples[player]=nil; return end
    local velocity=root.AssemblyLinearVelocity
    if not vector(velocity) or flat(velocity).Magnitude>55 then return end
    local s=samples[player]
    if not s or s.model~=model or now-s.at>.35 then
        s={model=model,p=root.Position,v=velocity,at=now,n=1,turn=0,path={},motionSince=nil,observedSpeed=0}; samples[player]=s
    else
        local dt=now-s.at
        if dt>0 then
            local observed=(root.Position-s.p)/dt
            -- A teleport makes interception estimates stale, rather than a route ban.
            if observed.Magnitude>100 then s.n=0; s.path={}; s.motionSince=nil end
            s.observedSpeed=flat(observed).Magnitude
            if s.observedSpeed>=CFG.MinMoveSpeed and flat(velocity).Magnitude>=CFG.MinMoveSpeed and observed.Magnitude<=100 then
                s.motionSince=s.motionSince or s.at
            else s.motionSince=nil end
            s.turn=clamp((velocity-s.v).Magnitude/30,0,1)
            s.p,s.v,s.at,s.n=root.Position,velocity,now,s.n+1
        end
    end
    s.path[#s.path+1]={at=now,p=root.Position}
    while #s.path>1 and now-s.path[1].at>CFG.MotionWindow do table.remove(s.path,1) end
    s.hum,s.head,s.name=hum,head,player.Name
    return s
end
local function receiverReady(player,s,now,point)
    if controller.IsBlacklisted(player) then return false,'BLACKLISTED' end
    if not teammate(player) then return false,'NOT_CURRENT_TEAMMATE' end
    if not lines.los or lines.status~='OBSERVED_LINES_STABLE' or now-lines.at>.3 then return false,'LOS_UNVERIFIED' end
    if not s or s.n<2 or now-s.at>.3 then return false,'MOVEMENT_UNVERIFIED' end
    local model,root=body(player)
    if not model or model~=s.model then return false,'MOVEMENT_UNVERIFIED' end
    if not onField(root.Position) then return false,'OFF_FIELD' end
    if downfield(root.Position)<CFG.MinDownfieldYards*3 then return false,'INSIDE_OR_TOO_CLOSE_TO_LOS' end
    if not vector(root.AssemblyLinearVelocity) or flat(root.AssemblyLinearVelocity).Magnitude<CFG.MinMoveSpeed then return false,'IDLE_OR_ROUTE_NOT_READY' end
    if not s.motionSince or now-s.motionSince<CFG.MinMotionAge or s.observedSpeed<CFG.MinMoveSpeed then return false,'IDLE_OR_ROUTE_NOT_READY' end
    local travel=0
    for i=2,#s.path do travel=travel+flat(s.path[i].p-s.path[i-1].p).Magnitude end
    if travel<CFG.MinMotionTravel then return false,'INSUFFICIENT_RECENT_MOVEMENT' end
    if point and (downfield(point)<CFG.MinDownfieldYards*3 or not onField(point)) then return false,'ARRIVAL_INSIDE_LOS_OR_OFF_FIELD' end
    return true
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
local function lane(shot,d)
    local o,v,t=shot.origin,shot.velocity,shot.time
    local reach=12.2
    if d.hum and finite(d.hum.JumpPower) then reach=clamp(d.hum.JumpPower^2/(2*workspace.Gravity)+5,12.2,24) end
    local bottom,top=d.p.Y-2,d.p.Y+reach
    local disc=v.Y*v.Y-2*CFG.Gravity*(bottom-o.Y)
    if disc<0 then return 45 end
    local r=math.sqrt(disc); local lo,hi=math.max(0,(v.Y-r)/CFG.Gravity),math.min(t,(v.Y+r)/CFG.Gravity)
    if hi<lo then return 45 end
    local function interval(a,b)
        if b<a then return 45 end
        return linearMinimum(o.X-d.p.X,o.Z-d.p.Z,v.X,v.Z,a,b,runSpeed(d))-(4.5+d.turn*3)
    end
    local high=v.Y*v.Y-2*CFG.Gravity*(top-o.Y)
    if high<=0 then return interval(lo,hi) end
    r=math.sqrt(high)
    local enter,leave=(v.Y-r)/CFG.Gravity,(v.Y+r)/CFG.Gravity
    return math.min(interval(lo,math.min(hi,enter)),interval(math.max(lo,leave),hi))
end
local function risk(shot,receiver,defenders)
    local margin,laneMargin=45,45; local t=shot.time
    for _,d in ipairs(defenders) do
        -- Instant turning at observed/normal run speed is optimistic for the DB.
        -- A trailing defender must cover the actual distance before arrival;
        -- a stationary prevent defender can move instead of staying frozen.
        local distance=flat(shot.arrival-d.p).Magnitude
        local clearance=distance-runSpeed(d)*t-(4.5+d.turn*3)
        margin=math.min(margin,clearance)
        laneMargin=math.min(laneMargin,lane(shot,d))
    end
    shot.margin,shot.lane=margin,laneMargin
    -- Once both clearances have a useful safety surplus, extra empty space
    -- must not make a slow floating arc beat an already-safe direct throw.
    shot.score=math.min(margin,CFG.ThrowMargin*2)*1.8+math.min(laneMargin,CFG.ThrowLane*2)*1.5-t*3-receiver.turn*12-(shot.receiverResidual or 0)*.25
    return shot
end
local lastNativeInputs
local function refreshNativeInputs()
    local q=profile.q
    local data={q.Angle,q.Power,q.ManualType,tostring(q.PreferHighArc),tostring(q.AutoCorrect)}
    for _,mode in ipairs({'Bullet','Fit','Dime','Jump'}) do
        local lead=profile.leads[mode]
        if typeof(lead)~='Vector2' then return false end
        data[#data+1]=lead.X; data[#data+1]=lead.Y
    end
    local smart=q.SmartPass
    data[#data+1]='smart:'..type(smart)..':'..tostring(smart)
    if type(smart)=='table' then
        data[#data+1]=tostring(smart.Enabled); data[#data+1]=tostring(smart.FitOnly); data[#data+1]=tostring(smart.MaxRange)
    end
    local oob=q.AntiOOB
    data[#data+1]='oob:'..type(oob)..':'..tostring(oob)
    if type(oob)=='table' then
        data[#data+1]=tostring(oob.Enabled); data[#data+1]=tostring(oob.XTolerance); data[#data+1]=tostring(oob.ZTolerance)
    end
    local signature=table.concat(data,':')
    if lastNativeInputs and lastNativeInputs~=signature then clearWindows(); if choice then choice.openSince=nil end end
    lastNativeInputs=signature
    return true
end
local function receivePossible(shot,s)
    local lead=profile.leads[shot.mode]
    if typeof(lead)~='Vector2' or not finite(lead.X) or not finite(lead.Y) then return false,'NATIVE_LEAD_CHANGED' end
    local ping=me:GetNetworkPing()
    if not finite(ping) or ping<0 then return false,'NETWORK_PREDICTION_UNVERIFIED' end
    local speed=math.max(flat(s.v).Magnitude,s.observedSpeed or 0)
    if s.hum and finite(s.hum.WalkSpeed) then speed=math.max(speed,s.hum.WalkSpeed) end
    local distance=flat(shot.arrival-s.p).Magnitude
    -- Necessary optimistic travel bound only. Native source uses time+ping and
    -- its configurable horizontal lead. No invented catch radius or jump zone.
    local budget=speed*(shot.time+ping)+math.abs(lead.X)
    shot.receiverResidual=flat(shot.arrival-predict(s,shot.time+ping)).Magnitude
    if distance>budget+math.max(.01,budget*.0001) then return false,'RECEIVER_CANNOT_REACH_NATIVE_ARRIVAL' end
    return true
end
local function safetyAhead(s,defenders,time)
    local v=flat(s.v)
    if v.Magnitude<=0 or not lines.forward or v:Dot(lines.forward)<=0 then return false end
    local route=v.Unit
    for _,d in ipairs(defenders) do
        local relative=flat(d.p-s.p)
        local along=relative:Dot(route)
        if along>=0 and relative:Dot(lines.forward)>0 then
            local lateral=(relative-route*along).Magnitude
            if lateral<=runSpeed(d)*time+(4.5+d.turn*3) then return true,d.name end
        end
    end
    return false
end
local function coverage(shot,s,defenders)
    local forward=lines.forward and flat(s.v):Dot(lines.forward)>0
    shot.safetyOverTop,shot.safetyName=safetyAhead(s,defenders,shot.time)
    local ahead=flat(shot.arrival-s.p):Dot(flat(s.v))>0
    shot.clearBurn=forward and ahead and not shot.safetyOverTop
        and shot.margin>=CFG.ThrowMargin and shot.lane>=CFG.ThrowLane or false
end
local function throwable(shot)
    return shot.margin>=CFG.ThrowMargin and shot.lane>=CFG.ThrowLane
        and (not shot.safetyOverTop or shot.mode=='Bullet')
end
local function better(a,b)
    if not b then return true end
    -- A selectable but unreleasable endpoint cannot monopolize the decision.
    local ar,br=throwable(a),throwable(b)
    if ar~=br then return ar end
    if a.clearBurn~=b.clearBurn then return a.clearBurn==true end
    if a.score~=b.score then return a.score>b.score end
    return downfield(a.arrival)>downfield(b.arrival)
end
local function receiverBetter(a,b)
    if not b then return true end
    local ar,br=throwable(a.shot),throwable(b.shot)
    if ar~=br then return ar end
    if a.shot.clearBurn~=b.shot.clearBurn then return a.shot.clearBurn==true end
    if ar and a.shot.passYards~=b.shot.passYards then return a.shot.passYards<b.shot.passYards end
    return better(a.shot,b.shot)
end
local function classify(shot,s,defenders)
    local speed=flat(s.v).Magnitude
    if speed<=0 then shot.window='OPEN'; return end
    local route=flat(s.v).Unit
    local nearest,nearDist
    for _,d in ipairs(defenders) do
        local db=predict(d,shot.time)
        local dist=flat(db-shot.arrival).Magnitude
        if not nearDist or dist<nearDist then nearest,nearDist=db,dist end
    end
    if not nearest then shot.window='OPEN'
    elseif flat(shot.arrival-nearest):Dot(route)>0 and route:Dot(lines.forward)>0 then shot.window='BURN_WINDOW'
    elseif flat(nearest-shot.arrival):Dot(lines.forward)>0 then shot.window='UNDERNEATH_WINDOW'
    else shot.window='LATERAL_WINDOW' end
end
local function solve(player,mode)
    if frameCalls>=8 then return nil,'NATIVE_FRAME_BUDGET' end
    if not lock(player) then return nil,'NATIVE_LOCK_BUSY' end
    if not teammate(player) or profile.selector()~=player.Character then return nil,'NATIVE_TARGET_MISMATCH' end
    local q=profile.q
    -- fn37's tuple is not the displayed HUD angle. In particular tuple #8 is an
    -- initial angle; #6 is the final velocity after native lead/solver iterations.
    local inputs=lastNativeInputs
    if getmetatable(q.AutoThrowType)~=nil or modeTransaction or q.AutoThrowType.Enabled~=true then return nil,'NATIVE_MODE_SCOPE_BUSY' end
    -- fn34 independently reads SelectedType when automatic mode is disabled.
    -- Never leave Auto Throw Type OFF between solves or during pregame/setup.
    modeTransaction={q=q,auto=q.AutoThrowType,enabled=rawget(q.AutoThrowType,'Enabled'),
        selected=rawget(q,'SelectedType'),mode=mode}
    rawset(q.AutoThrowType,'Enabled',false); rawset(q,'SelectedType',mode)
    nativeCalls=nativeCalls+1; frameCalls=frameCalls+1; maxFrameCalls=math.max(maxFrameCalls,frameCalls); modeChecks[mode]=(modeChecks[mode] or 0)+1
    local worker=coroutine.create(profile.solve); modeTransaction.worker=worker
    local ok,dir,origin,endpoint,power,time,velocity,aimpoint,initialAngle,returnedMode=coroutine.resume(worker,q.Angle,mode)
    local yielded=coroutine.status(worker)=='suspended'
    local modeOwned=restoreModeTransaction()
    if yielded and not stopped then
        fatalError='Native calculator yielded; automatic settings restored and calculation cancelled'
        controller.Stop('NATIVE_SOLVER_YIELDED'); return nil,'NATIVE_SOLVER_YIELDED'
    end
    if stopped then return nil,'STOPPED' end
    if not ok then
        fatalError=clean(dir); log('SOLVER_ERROR',dir)
        controller.Stop('NATIVE_SOLVER_ERROR'); return nil,'NATIVE_SOLVER_ERROR'
    end
    if not modeOwned or q.AutoThrowType.Enabled~=true or returnedMode~=nil and returnedMode~=mode then
        fatalError='Native mode changed during protected solve'
        controller.Stop('NATIVE_MODE_SCOPE_CONFLICT'); return nil,'NATIVE_MODE_SCOPE_CONFLICT'
    end
    if not ownsLock() or not teammate(player) or profile.selector()~=player.Character then return nil,'NATIVE_TARGET_MISMATCH' end
    if not refreshNativeInputs() or lastNativeInputs~=inputs then return nil,'NATIVE_SETTINGS_CHANGED_DURING_SOLVE' end
    origin,velocity=nativeVector(origin),nativeVector(velocity)
    if not vector(origin) or not vector(velocity) or not finite(time) or time<.05
        or not finite(power) or power<=0 or power>100 or velocity.Magnitude<1 or not modes[returnedMode] then return nil,'NATIVE_SOLVER_INVALID' end
    if time>CFG.MaxFlight then return nil,'NATIVE_FLIGHT_OUTSIDE_MODEL_HORIZON' end
    if flat(player.Character:FindFirstChild('HumanoidRootPart').Position-origin).Magnitude>CFG.MaxRange then return nil,'NATIVE_RANGE' end
    local arrival=origin+velocity*time-V(0,.5*CFG.Gravity*time*time,0)
    aimpoint=nativeVector(aimpoint)
    if not vector(aimpoint) then return nil,'NATIVE_AIMPOINT_INVALID' end
    -- #7 precedes native vertical lead and AntiOOB. Only compare X/Z and
    -- reproduce the observed native clamp; this is arithmetic consistency,
    -- not an invented catch-height or catch-radius calibration.
    local target=aimpoint
    local oob=q.AntiOOB
    if type(oob)=='table' and oob.Enabled then
        if not finite(oob.XTolerance) or not finite(oob.ZTolerance) then return nil,'NATIVE_ANTIOOB_CONFIG_UNVERIFIED' end
        target=V(clamp(target.X,-75+oob.XTolerance,75+oob.XTolerance),target.Y,
            clamp(target.Z,-175+oob.ZTolerance,175+oob.ZTolerance))
    end
    if flat(arrival-target).Magnitude>math.max(.01,flat(target-origin).Magnitude*.0001) then
        arrivalRejects[mode]={target=player.Name,origin=origin,velocity=velocity,time=time,arrival=arrival,aim=target}
        return nil,'NATIVE_ARRIVAL_AIMPOINT_MISMATCH'
    end
    return {origin=origin,velocity=velocity,power=power,time=time,mode=mode,arrival=arrival,
        passYards=flat(arrival-origin).Magnitude/3,at=os.clock()}
end
local plannerModes={'Bullet','Fit','Dime','Jump'}
local function evaluate(receivers,indices,defenders,now)
    local groups={}
    for _,index in ipairs(indices) do
        local r=receivers[index]
        local cache=shotCache[r.player]
        if not cache or cache.model~=r.sample.model or cache.epoch~=possession.epoch or cache.generation~=lines.generation then
            cache={model=r.sample.model,epoch=possession.epoch,generation=lines.generation,shots={},rotation=0}
            shotCache[r.player]=cache
        end
        groups[#groups+1]={r=r,cache=cache,tried={}}
    end
    local calls,started,limited=0,os.clock(),false
    -- Interleave receivers before trying a second/third mode. A slow native
    -- solve cannot consume every frame's allowance on the same receiver.
    for pass=1,3 do
        for offset=1,#groups do
            local index=(offset+planRound-1)%#groups+1
            local g=groups[index]
            if calls>=CFG.PlanCalls or os.clock()-started>=CFG.PlanSeconds then limited=true; break end
            -- Advance only after an actual solve. Even if a single native
            -- call consumes the whole time allowance, every mode gets a turn.
            local mode
            for _=1,#plannerModes do
                g.cache.rotation=g.cache.rotation%#plannerModes+1
                local nextMode=plannerModes[g.cache.rotation]
                if not g.tried[nextMode] then mode=nextMode; break end
            end
            g.tried[mode]=true
            local shot,why=solve(g.r.player,mode); calls=calls+1
            if stopped then return end
            if shot then g.cache.shots[mode]=shot
            else
                g.cache.shots[mode]=nil
                receiverRejects[g.r.player.Name..'/'..mode]=why
                if why=='NATIVE_SETTINGS_CHANGED_DURING_SOLVE' then return end
            end
        end
        if calls>=CFG.PlanCalls or os.clock()-started>=CFG.PlanSeconds then
            if pass<3 then limited=true end
            break
        end
    end
    if limited then planDeferred=planDeferred+1 end
    maxPlanCalls=math.max(maxPlanCalls,calls)
    local best,incumbent
    candidateEvidence={}
    for _,g in ipairs(groups) do
        local r,bestShot=g.r,nil
        for _,mode in ipairs(plannerModes) do
            local shot=g.cache.shots[mode]
            if shot and now-shot.at<=CFG.CacheAge then
                local eligible,rejection=receiverReady(r.player,r.sample,now,shot.arrival)
                if eligible then eligible,rejection=receivePossible(shot,r.sample) end
                if eligible then
                    risk(shot,r.sample,defenders); coverage(shot,r.sample,defenders)
                    candidateEvidence[#candidateEvidence+1]=string.format('%s %s t=%.3f p=%.2f margin=%.2f lane=%.2f release=%s clearBurn=%s safetyOverTop=%s',r.player.Name,mode,shot.time,shot.power,shot.margin,shot.lane,tostring(throwable(shot)),tostring(shot.clearBurn),tostring(shot.safetyOverTop))
                    if shot.margin>=CFG.SelectMargin and shot.lane>=CFG.SelectLane and (not shot.safetyOverTop or shot.mode=='Bullet') and better(shot,bestShot) then bestShot=shot end
                else receiverRejects[r.player.Name..'/'..mode]=rejection end
            end
        end
        if bestShot then
            r.shot=bestShot; g.cache.preferred=bestShot.mode
            local old=opportunities[r.player]
            if throwable(bestShot) then
                local continuous=old and old.model==r.sample.model and old.epoch==possession.epoch
                    and old.generation==lines.generation and now-old.checked<=CFG.SafeGap
                r.openSince=continuous and old.since or now
                opportunities[r.player]={since=r.openSince,checked=now,model=r.sample.model,
                    epoch=possession.epoch,generation=lines.generation}
            else opportunities[r.player]=nil end
            if choice and r.player==choice.player and r.sample.model==choice.model then incumbent=r end
            if not best or receiverBetter(r,best) then best=r end
        else opportunities[r.player]=nil end
    end
    if best and incumbent and best.player~=incumbent.player then
        local bReady,iReady=throwable(best.shot),throwable(incumbent.shot)
        if iReady and not (best.shot.clearBurn and not incumbent.shot.clearBurn)
            and (not bReady or incumbent.shot.passYards-best.shot.passYards<CFG.ReceiverSwitchYards) then
            best=incumbent
        elseif not bReady and not iReady then best=incumbent end
    end
    return best
end
local function currentDefenders(player,now)
    local defenders={}
    local roster=Players:GetPlayers()
    if #roster>CFG.MaxRoster then return nil,nil,'ROSTER_LIMIT' end
    for _,p in ipairs(roster) do
        if p~=me and not p.Neutral and p.Team and body(p) and (p==player or p.Team~=me.Team) then
            local s=sample(p,now)
            if not s or s.n<2 then return nil,nil,'SAMPLING_PLAYERS' end
            local model,root,head,hum=body(p)
            if not model or model~=s.model or not vector(root.AssemblyLinearVelocity) then return nil,nil,'PLAYER_OBSERVATION_CHANGED' end
            -- sample() can be called twice with the same tick timestamp. Refresh
            -- actual pose/velocity even then; the final safety check is not a cache.
            s.turn=math.max(s.turn,clamp((root.AssemblyLinearVelocity-s.v).Magnitude/30,0,1))
            s.p,s.v,s.head,s.hum=root.Position,root.AssemblyLinearVelocity,head,hum
            if p.Team~=me.Team then defenders[#defenders+1]=s end
        end
    end
    return samples[player],defenders
end

local function releaseNow(ball,selected,defenders,now)
    if not sequence or sequence.player~=selected.player or sequence.epoch~=possession.epoch then return end
    if usedTools[ball.tool]==possession.epoch then setGate('REQUEST_ALREADY_ATTEMPTED'); return end
    if receiverMenu and receiverMenu.Visible then setGate('RECEIVER_MENU_OPEN'); return end
    local current,reason=ready()
    if not current or current.tool~=ball.tool then setGate(reason or 'POSSESSION_CHANGED'); return end
    if current.nativeThrow then setGate('NATIVE_MANUAL_THROW_IN_PROGRESS'); return end
    if not readLines(now) then setGate(lines.status); return end
    if downfield(current.root.Position)>.5 then setGate('QB_PAST_LOS'); return end
    local eligible,rejection=receiverReady(selected.player,selected.sample,now)
    if not eligible then releaseChoice(); setGate(rejection); return end
    local shot,why=solve(selected.player,selected.shot.mode)
    if not shot then setGate(why); return end
    if stopped then return end
    if os.clock()-now>.28 then setGate('DECISION_STALE_AFTER_NATIVE_SOLVER'); return end
    if not readLines(os.clock()) then releaseChoice(); setGate(lines.status); return end
    eligible,rejection=receiverReady(selected.player,selected.sample,os.clock(),shot.arrival)
    if not eligible then releaseChoice(); setGate(rejection); return end
    eligible,rejection=receivePossible(shot,selected.sample)
    if not eligible then releaseChoice(); setGate(rejection); return end
    risk(shot,selected.sample,defenders); coverage(shot,selected.sample,defenders)
    if sequence.fastBurn and not shot.clearBurn then setGate('BURN_COVERAGE_CHANGED'); return end
    if shot.safetyOverTop and shot.mode~='Bullet' then setGate('SAFETY_OVER_TOP'); return end
    if not shot.clearBurn and now-possession.since<CFG.MinPlayAge then setGate('LET_ROUTES_DEVELOP'); return end
    if shot.margin<CFG.ThrowMargin or shot.lane<CFG.ThrowLane then setGate('DEFENDER_INTERCEPTION_RISK'); return end
    if not throwing or not auto or not ownsLock() or not teammate(selected.player) or receiverMenu and receiverMenu.Visible then return end
    current,reason=ready()
    if not current or current.tool~=ball.tool or current.remote~=ball.remote then setGate(reason or 'POSSESSION_CHANGED'); return end
    if current.nativeThrow then setGate('NATIVE_MANUAL_THROW_IN_PROGRESS'); return end
    if downfield(current.root.Position)>.5 then releaseChoice(); setGate('QB_PAST_LOS'); return end
    local unit=shot.velocity.Unit
    -- Readable live InputBegan request, exactly: Vector3.new(70000000) is X only.
    -- No retry: FireServer acceptance does not confirm a throw or server state.
    usedTools[ball.tool]=possession.epoch; attempts=attempts+1
    pending={tool=ball.tool,model=ball.model,target=selected.player.Name,mode=shot.mode,at=now,outcome='REQUESTING'}
    classify(shot,selected.sample,defenders)
    local evidence=string.format('%s %s %s t=%.3f power=%.2f arrival=%.2f,%.2f,%.2f margin=%.2f lane=%.2f residual=%.2f',
        selected.player.Name,shot.mode,shot.window,shot.time,shot.power,shot.arrival.X,shot.arrival.Y,shot.arrival.Z,
        shot.margin,shot.lane,shot.receiverResidual)
    lastDecision={summary=evidence,actors={},release=string.format('distanceYards=%.2f clearBurn=%s safetyOverTop=%s qbY=%.3f qbVy=%.3f animation=%s',shot.passYards,tostring(shot.clearBurn),tostring(shot.safetyOverTop),current.root.Position.Y,current.root.AssemblyLinearVelocity.Y,animationStatus)}
    local function actor(name,s)
        return string.format('%s p=%.2f,%.2f,%.2f v=%.2f,%.2f,%.2f runSpeed=%.2f',
            name,s.p.X,s.p.Y,s.p.Z,s.v.X,s.v.Y,s.v.Z,runSpeed(s))
    end
    lastDecision.actors[1]=actor('WR',selected.sample)
    lastDecision.trajectory=string.format('origin=%.3f,%.3f,%.3f velocity=%.3f,%.3f,%.3f gravity=%.2f',shot.origin.X,shot.origin.Y,shot.origin.Z,shot.velocity.X,shot.velocity.Y,shot.velocity.Z,CFG.Gravity)
    lastDecision.candidates={}
    for _,candidate in ipairs(candidateEvidence) do lastDecision.candidates[#lastDecision.candidates+1]=candidate end
    for i,d in ipairs(defenders) do lastDecision.actors[#lastDecision.actors+1]=actor('DB'..i..':'..clean(d.name),d) end
    decisionHistory[#decisionHistory+1]=lastDecision
    if #decisionHistory>6 then table.remove(decisionHistory,1) end
    log('REQUEST',evidence)
    local ok,err=pcall(function()
        ball.remote:FireServer('Clicked',shot.origin-unit*5+V(70000000,0,0),shot.origin+unit*10000,shot.power,1)
    end)
    if ok then sent=sent+1; pending.outcome='API_ACCEPTED_UNCONFIRMED'; setGate('REQUEST_SENT_UNCONFIRMED')
    else
        ambiguous=ambiguous+1; pending.outcome='AMBIGUOUS_NO_RETRY'; fatalError=clean(err)
        log('REQUEST_ERROR',err); controller.Stop('REQUEST_AMBIGUOUS_NO_RETRY'); return
    end
    preserve(false)
end
local function driveSequence(now)
    local seq=sequence
    if not seq then return end
    local ball,why=ready()
    if not ball or ball.nativeThrow or not throwing or not choice or choice.player~=seq.player
        or seq.model~=seq.player.Character or seq.qbModel~=ball.model or seq.hum~=ball.hum
        or seq.epoch~=possession.epoch or seq.tool~=ball.tool
        or not teammate(seq.player) or receiverMenu and receiverMenu.Visible then
        cancelSequence(why or 'RELEASE_CONTEXT_CHANGED'); return
    end
    if not seq.animationStarted then
        seq.animation=startAnimation(ball,now); seq.animationStarted=true
    end
    -- A no-safety burn is released immediately; animation still plays, but its
    -- cosmetic windup cannot hold an already verified fleeting opening.
    if not seq.fastBurn and not animationReady(now) then setGate('WAIT_NATIVE_THROW_ANIMATION'); return end
    if stopped or sequence~=seq then return end
    local receiver,defenders,rejection=currentDefenders(seq.player,now)
    if not receiver or not defenders then cancelSequence(rejection or 'RECEIVER_OBSERVATION_LOST'); setGate(rejection or 'RECEIVER_OBSERVATION_LOST'); return end
    seq.selected.sample=receiver
    releaseNow(ball,seq.selected,defenders,now)
    if stopped or sequence~=seq then return end
    if usedTools[ball.tool]==possession.epoch then
        -- Let the owned animation finish normally after a successful API call.
        sequence=nil; lastSequenceOutcome='API_ACCEPTED_UNCONFIRMED'
    else
        cancelSequence('FINAL_RELEASE_CHECK_BLOCKED')
        opportunities[seq.player]=nil; shotCache[seq.player]=nil
    end
end
local function submit(ball,selected,defenders,now)
    local fastBurn=selected.shot.clearBurn==true
    if sequence and (sequence.player~=selected.player or sequence.model~=selected.player.Character
        or sequence.epoch~=possession.epoch or sequence.fastBurn~=fastBurn) then cancelSequence('TARGET_OR_DISTANCE_CHANGED') end
    if not sequence then
        sequence={player=selected.player,model=selected.player.Character,qbModel=ball.model,hum=ball.hum,tool=ball.tool,epoch=possession.epoch,
            selected=selected,fastBurn=fastBurn,started=now}
        lastSequenceOutcome='PREPARING'
        log('PREPARE',selected.player.Name..' '..(fastBurn and 'CLEAR_BURN_IMMEDIATE' or 'NATIVE_RELEASE'))
    else sequence.selected=selected end
    driveSequence(now)
end

local function tick(now)
    if stopped or inTick or now-lastTick<CFG.Interval then return end
    inTick=true; lastTick=now
    local begun=os.clock()
    local ok,err=pcall(function()
        if context.IsCancelled and context.IsCancelled() then controller.Stop('CANCELLED'); return end
        scanLines()
        -- Field context exists for every role. Discover/refresh it before any
        -- Yuna, active-play, equipped-ball, or already-attempted return below.
        local lineReady=readLines(now)
        if not initialFieldDiscovered and lines.initialComplete and groundReason()=='ACCEPTED' then
            initialFieldDiscovered=true
        end
        if renderReceivers and receiverMenu and receiverMenu.Visible then renderReceivers(now) end
        if profile and (not aliveConnection(profile.preview) or not aliveConnection(profile.release)) then
            releaseChoice(); profile=nil; nextDiscovery=0; log('PROFILE','Disconnected; rediscovering')
        end
        if not profile and now>=nextDiscovery then
            nextDiscovery=now+CFG.DiscoveryInterval
            local why; profile,why=discover()
            if not profile then resetFieldWait(); setGate(why); return end
            log('PROFILE','Shared selector settings + native final solver + live release matched')
        end
        -- A continuous equipped/throwable possession permits exactly one request.
        -- A later authoritative play transition or actual change of equipped
        -- ball/character permits a new attempt, including reuse of the same Tool.
        local nativeReady=profile and profile.state.Status.Value=='InPlay' and profile.state.Throwable.Value==true
        local currentModel=body(me)
        local currentBall=currentModel and equipped(currentModel)
        local currentTool=currentBall and currentBall.tool
        if nativeReady and currentTool then
            if not possession.wasReady or possession.tool~=currentTool or possession.model~=currentModel then
                possession.epoch=possession.epoch+1
                possession.tool,possession.model=currentTool,currentModel
                possession.since=now
                resetFieldWait(); releaseChoice()
                log('POSSESSION',possession.epoch)
            end
            possession.wasReady=true
        else
            if pending and possession.wasReady then pending.outcome='POSSESSION_ENDED; THROW_NOT_VERIFIED' end
            possession.wasReady=false
        end
        local ball,why=ready()
        if not ball then resetFieldWait(); releaseChoice(); setGate(why); return end
        if not refreshNativeInputs() then resetFieldWait(); releaseChoice(); setGate('NATIVE_LEAD_CHANGED'); return end
        if ball.nativeThrow and usedTools[ball.tool]~=possession.epoch then
            usedTools[ball.tool]=possession.epoch
            pending={tool=ball.tool,model=ball.model,target=choice and choice.player.Name or 'NATIVE',
                mode=choice and choice.shot.mode or 'NATIVE',at=now,outcome='NATIVE_MANUAL_THROW_UNCONFIRMED'}
            log('MANUAL','Native Throw animation owns this possession; no competing AUTO request')
        end
        if pending and usedTools[ball.tool]==possession.epoch then
            resetFieldWait()
            setGate(pending.outcome=='NATIVE_MANUAL_THROW_UNCONFIRMED' and pending.outcome
                or pending.outcome=='AMBIGUOUS_NO_RETRY' and 'REQUEST_AMBIGUOUS_NO_RETRY' or 'REQUEST_SENT_UNCONFIRMED')
            -- Do not keep a lock invisibly after a rejected/unknown request.
            if now-pending.at>1 then releaseChoice() end
            return
        end
        if lease and not ownsLock() then resetFieldWait(); releaseChoice(); setGate('EXTERNAL_NATIVE_LOCK_EDIT'); return end
        if profile.q.Locked and not lease then resetFieldWait(); setGate('USER_NATIVE_LOCK_ACTIVE'); return end
        if not lineReady and receiverMenu and receiverMenu.Visible then
            resetFieldWait(); releaseChoice(); setGate('RECEIVER_MENU_OPEN'); return
        end
        if not lineReady then
            -- Readiness above requires Yuna enabled, a live throwable play,
            -- local equipped ball, and no native/manual request owning the play.
            -- Pregame, missing Yuna/ball, dead plays and AUTO OFF never consume
            -- this timer. Each new possession starts with the full allowance.
            fieldWaitSince=fieldWaitSince or now
            fieldWaitSeconds=math.max(0,now-fieldWaitSince)
            if fieldWaitSeconds>=CFG.FieldDiscoverySeconds then
                fatalError=clean('Field readiness timeout during throwable QB possession; status='..lines.status
                    ..'; ground='..groundReason()..'; scanComplete='..tostring(lines.initialComplete==true))
                log('FIELD_DISCOVERY_ERROR',fatalError); controller.Stop('FIELD_DISCOVERY_TIMEOUT'); return
            end
            releaseChoice(); setGate(lines.status); return
        end
        resetFieldWait()
        if possession.lineGeneration~=lines.generation then
            possession.lineGeneration=lines.generation; possession.since=now; releaseChoice()
        end
        if downfield(ball.root.Position)>.5 then releaseChoice(); setGate('QB_PAST_LOS'); return end
        local roster=Players:GetPlayers()
        if #roster>CFG.MaxRoster then releaseChoice(); setGate('ROSTER_LIMIT'); return end
        local receivers,defenders,seenRoster={},{},{}
        receiverRejects={}
        local observationMissing=false
        for _,player in ipairs(roster) do
            seenRoster[player]=true
            if player~=me and not player.Neutral and player.Team and body(player) then
                local s=sample(player,now)
                if not s or s.n<2 then
                    if player.Team~=me.Team then observationMissing=true end
                    receiverRejects[player.Name]='MOVEMENT_UNVERIFIED'; opportunities[player]=nil; shotCache[player]=nil
                elseif player.Team==me.Team then
                    local eligible,rejection=receiverReady(player,s,now)
                    -- The qualified native lock accepts a teammate independently
                    -- of cursor/camera position. Read the field, not just the view.
                    if eligible then
                        local estimate=clamp(flat(s.p-ball.head.Position).Magnitude/95,.05,CFG.MaxFlight)
                        receivers[#receivers+1]={player=player,sample=s,estimate=estimate,rank=0}
                    else receiverRejects[player.Name]=rejection; opportunities[player]=nil; shotCache[player]=nil end
                elseif player.Team~=me.Team then defenders[#defenders+1]=s end
            end
        end
        for player in pairs(samples) do if not seenRoster[player] then samples[player]=nil; opportunities[player]=nil; shotCache[player]=nil end end
        if observationMissing then releaseChoice(); setGate('SAMPLING_PLAYERS'); return end
        if receiverMenu and receiverMenu.Visible then releaseChoice(); setGate('RECEIVER_MENU_OPEN'); return end
        for _,r in ipairs(receivers) do
            local separation=45
            for _,d in ipairs(defenders) do separation=math.min(separation,flat(predict(r.sample,r.estimate)-predict(d,r.estimate)).Magnitude) end
            r.rank=separation-r.estimate*3
            r.burnLook=flat(r.sample.v):Dot(lines.forward)>0 and not safetyAhead(r.sample,defenders,r.estimate)
        end
        table.sort(receivers,function(a,b) if a.burnLook~=b.burnLook then return a.burnLook end; if a.estimate~=b.estimate then return a.estimate<b.estimate end; if a.rank==b.rank then return a.player.Name<b.player.Name end; return a.rank>b.rank end)
        if #receivers==0 then releaseChoice(); setGate('NO_ACTIVE_DOWNFIELD_RECEIVER'); return end
        planRound=planRound+1
        local incumbent
        if choice then for i,r in ipairs(receivers) do if r.player==choice.player then incumbent=i; break end end end
        local indices={incumbent or 1}
        if #receivers>1 then
            local challengers={}
            for i=1,#receivers do if i~=indices[1] then challengers[#challengers+1]=i end end
            cursor=1+(cursor-1)%#challengers
            if planRound%2==0 then indices[2]=challengers[1]
            else indices[2]=challengers[cursor]; cursor=cursor+1 end
        end
        local best=evaluate(receivers,indices,defenders,now)
        if stopped then return end
        if not best then releaseChoice(true); setGate('NO_SAFE_NATIVE_TRAJECTORY'); return end
        local previous=choice
        local stable=previous and previous.player==best.player and previous.model==best.player.Character
        best.since=stable and choice.since or now; best.model=best.player.Character
        choice=best
        -- The last candidate may differ from the winner; settle the actual shared
        -- native lock and final preview on the winner before any release.
        local final,failed=solve(best.player,best.shot.mode)
        if not final then
            if shotCache[best.player] then shotCache[best.player].shots[best.shot.mode]=nil end
            opportunities[best.player]=nil; releaseChoice(true); setGate(failed); return end
        best.shot=final
        if shotCache[best.player] then shotCache[best.player].shots[final.mode]=best.shot end
        local eligible,rejection=receiverReady(best.player,best.sample,now,final.arrival)
        if not eligible then releaseChoice(); setGate(rejection); return end
        eligible,rejection=receivePossible(best.shot,best.sample)
        if not eligible then shotCache[best.player]=nil; opportunities[best.player]=nil; releaseChoice(); setGate(rejection); return end
        risk(best.shot,best.sample,defenders); coverage(best.shot,best.sample,defenders)
        if not throwable(best.shot) then
            best.openSince=nil; opportunities[best.player]=nil
            if shotCache[best.player] then shotCache[best.player].shots[best.shot.mode]=nil end
        end
        classify(best.shot,best.sample,defenders)
        if not stable then log('SELECT',best.player.Name..' '..best.shot.mode) end
        if not throwing then setGate('SELECT_ONLY'); return end
        if receiverMenu and receiverMenu.Visible then setGate('RECEIVER_MENU_OPEN'); return end
        if not best.shot.clearBurn then
            if now-possession.since<CFG.MinPlayAge then setGate('LET_ROUTES_DEVELOP'); return end
            if not best.openSince or now-best.openSince+1e-6<CFG.Settle then setGate('WAIT_STABLE_OPEN_RECEIVER'); return end
        end
        submit(ball,best,defenders,now)
    end)
    inTick=false
    maxTick=math.max(maxTick,os.clock()-begun)
    if not ok then
        fatalError=clean(err); log('TICK_ERROR',err); controller.Stop('RUNTIME_ERROR'); return
    end
    if not stopped and now>=nextSave then nextSave=now+10; preserve(false) end
end
local function connect(signal,fn)
    local connection=signal:Connect(fn); connections[#connections+1]=connection; return connection
end
local function button(text,x,width,y)
    local b=Instance.new('TextButton'); b.Size=UDim2.fromOffset(width,22)
    b.Position=UDim2.new(1,x,0,y or 62); b.Text=text; b.TextSize=10; b.Font=Enum.Font.GothamMedium
    b.BackgroundColor3=Color3.fromRGB(28,37,34); b.BackgroundTransparency=.2; b.TextColor3=Color3.new(1,1,1)
    b.ClipsDescendants=true
    if Enum.TextTruncate then b.TextTruncate=Enum.TextTruncate.AtEnd end
    b.Parent=gui; return b
end
local built,buildError=pcall(function()
    gui=Instance.new('ScreenGui'); gui.Name='PELICAN_FF3_AUTO_QB_V19'; gui.ResetOnSpawn=false; gui.DisplayOrder=1000; gui.Parent=pg
    status=button('WAIT YUNA',-166,138)
    local kill=button('X',-26,22); kill.BackgroundColor3=Color3.fromRGB(195,40,40)
    autoButton=button('AUTO ON',-166,58,87); throwButton=button('THR ON',-105,51,87); copyButton=button('COPY',-51,47,87)
    receiverButton=button('WR LIST',-166,78,112); receiverButton.Name='Receivers'
    paceButton=button('WAIT 2s',-85,81,112); paceButton.Name='Pace'
    receiverMenu=Instance.new('Frame'); receiverMenu.Name='ReceiverList'; receiverMenu.Size=UDim2.fromOffset(162,134)
    receiverMenu.Position=UDim2.new(1,-166,0,137); receiverMenu.BackgroundColor3=Color3.fromRGB(24,30,28); receiverMenu.Parent=gui
    local title=Instance.new('TextLabel'); title.Name='Title'; title.Size=UDim2.fromOffset(158,22); title.Position=UDim2.fromOffset(2,0)
    title.Text='Tap receiver to block / allow'; title.TextSize=10; title.TextColor3=Color3.new(1,1,1); title.BackgroundTransparency=1; title.Parent=receiverMenu
    local rows,rowPlayers={},{}; local page=1; local lastRender=-math.huge
    for i=1,3 do
        local index=i; local row=button('',0,158,0); row.Name='Receiver'..i; row.Parent=receiverMenu
        row.Position=UDim2.fromOffset(2,22+(i-1)*28); row.Size=UDim2.fromOffset(158,28); rows[i]=row
        connect(row.Activated,function() local p=rowPlayers[index]; if p then controller.SetBlacklisted(p,not controller.IsBlacklisted(p)) end end)
    end
    local prev,nextPage=button('<',0,28,0),button('>',0,28,0)
    prev.Name='Previous'; nextPage.Name='Next'; prev.Parent=receiverMenu; nextPage.Parent=receiverMenu
    prev.Position=UDim2.fromOffset(2,108); nextPage.Position=UDim2.fromOffset(132,108)
    local pageLabel=Instance.new('TextLabel'); pageLabel.Name='Page'; pageLabel.Size=UDim2.fromOffset(100,22)
    pageLabel.Position=UDim2.fromOffset(31,108); pageLabel.TextSize=10; pageLabel.TextColor3=Color3.new(1,1,1); pageLabel.BackgroundTransparency=1; pageLabel.Parent=receiverMenu
    renderReceivers=function(now)
        if stopped or now and now-lastRender<.5 then return end
        lastRender=now or os.clock()
        local list={}
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=me and me.Team and not p.Neutral and p.Team==me.Team then list[#list+1]=p end
        end
        table.sort(list,function(a,b) return a.Name<b.Name end)
        local pages=math.max(1,math.ceil(#list/3)); page=clamp(page,1,pages)
        for i,row in ipairs(rows) do
            local p=list[(page-1)*3+i]; rowPlayers[i]=p; row.Visible=p~=nil
            if p then row.Text=(controller.IsBlacklisted(p) and '[X] @' or '[ ] @')..p.Name end
        end
        pageLabel.Text=#list==0 and 'No teammates' or tostring(page)..' / '..pages
        prev.Visible=pages>1; nextPage.Visible=pages>1
    end
    connect(prev.Activated,function() page=math.max(1,page-1); renderReceivers() end)
    connect(nextPage.Activated,function() page=page+1; renderReceivers() end)
    connect(receiverButton.Activated,function()
        receiverMenu.Visible=not receiverMenu.Visible; if cancelSequence then cancelSequence('RECEIVER_MENU') end; clearWindows(); if choice then choice.openSince=nil end
        if receiverMenu.Visible then renderReceivers() end
    end)
    connect(paceButton.Activated,function() CFG.MinPlayAge=CFG.MinPlayAge>=4 and 2 or CFG.MinPlayAge+1; paceButton.Text='WAIT '..CFG.MinPlayAge..'s'; log('PACE',CFG.MinPlayAge) end)
    autoButton.Visible=false; throwButton.Visible=false; copyButton.Visible=false; receiverButton.Visible=false; paceButton.Visible=false; receiverMenu.Visible=false
    connect(status.Activated,function()
        expanded=not expanded; autoButton.Visible=expanded; throwButton.Visible=expanded; copyButton.Visible=expanded
        receiverButton.Visible=expanded; paceButton.Visible=expanded
        if not expanded then if receiverMenu.Visible and choice then choice.openSince=nil end; receiverMenu.Visible=false end
    end)
    connect(autoButton.Activated,function() controller.SetAuto(not auto) end)
    connect(throwButton.Activated,function() controller.SetThrow(not throwing) end)
    connect(copyButton.Activated,function() preserve(true); copyButton.Text=copyResult=='API_ACCEPTED' and 'SENT' or 'FAIL' end)
    connect(kill.Activated,function()
        if context.RequestStop then context.RequestStop('USER_END') else controller.Stop('USER_END') end
    end)
    local stop=Instance.new('BindableEvent'); stop.Name='Stop'; stop.Parent=gui; connect(stop.Event,function() controller.Stop('EXTERNAL_STOP') end)
    if me.OnTeleport then connect(me.OnTeleport,function(state)
        local value=tostring(state)
        if value:find('Started',1,true) or value:find('InProgress',1,true) then controller.Stop('TELEPORT')
        else preserve(true) end
    end) end
    connect(workspace.DescendantAdded,onLineAdded)
    connect(pg.DescendantAdded,onLineAdded)
    if core and core.DescendantAdded then connect(core.DescendantAdded,onLineAdded) end
    connect(Run.Heartbeat,function()
        if stopped then return end
        local now=os.clock(); frameCalls=0
        local ok,err=pcall(function() driveSequence(now) end)
        if not ok then fatalError=clean(err); log('RELEASE_ERROR',err); controller.Stop('RELEASE_SEQUENCE_ERROR'); return end
        tick(now)
        maxHeartbeat=math.max(maxHeartbeat,os.clock()-now)
    end)
end)
if not built then controller.Stop('STARTUP_ERROR'); error(buildError) end
log('START','Native modes; clear burn with no safety releases without yardage/jump/hold delay')
return controller
