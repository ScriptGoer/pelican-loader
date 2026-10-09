-- PELICAN_FF3_V15: casual live Auto QB, alongside Yuna. V14 is preserved in its
-- release tag and the private archive. Receiver policy changes only; native
-- selection lock, throw-mode settings, final solver, and request are preserved.
-- Integration contract comes from the supplied readable QB source, fn13/fn37 and
-- InputBegan release. Read-only closure discovery; no getter replacement/hooks.
-- Catch windows and current server acceptance remain unverified in Roblox.
local context = ... or {}
local VERSION, KEY = 'PELICAN_FF3_V15', 'PELICAN_FF3_AUTO_QB'
local CFG = {Interval=.12, DiscoveryInterval=2, MaxRoster=64,
    Gravity=28, MaxFlight=4.5, MaxRange=330, SelectMargin=3, SelectLane=2,
    ThrowMargin=6, ThrowLane=4, Settle=.65, MinPlayAge=3, MinDownfieldYards=6,
    MinMoveSpeed=2, MinMotionAge=.65, MotionWindow=.8, MinMotionTravel=2.4}
local Players, Run, Input = game:GetService('Players'), game:GetService('RunService'), game:GetService('UserInputService')
local me = Players.LocalPlayer
if not me or game.PlaceId ~= 82866880824588 then error('PELICAN V15 requires the observed FF3 live place') end
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
local attempts, sent, ambiguous, relinquishments, nativeCalls = 0, 0, 0, 0, 0
local receiverRejects={}
local maxTick=0
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
    counts[value]=(counts[value] or 0)+1
    if gate~=value then gate=value; log('GATE',value) end
    if status then status.Text=(choice and choice.player.Name..' ' or '')..value:gsub('_',' '):sub(1,24) end
end
local function finite(x) return type(x)=='number' and x==x and math.abs(x)<1e8 end
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
local function releaseChoice()
    choice=nil; restoreLock()
end
function controller.SetBlacklisted(player,value)
    if stopped or not instance(player,'Player') or player==me then return false end
    local key=receiverKey(player)
    blacklist[key]=value==true and true or nil
    log('BLACKLIST',player.Name..' '..tostring(value==true))
    if value and choice and choice.player==player then releaseChoice() end
    if renderReceivers then renderReceivers() end
    return true
end

-- LOS geometry is preserved from the earlier FF3 reports: the observed ground
-- and full-width blue/yellow strips (or straight Beams). Direction is never
-- inferred from camera facing, receiver movement, team names, or the QB spawn.
local function groundShape(o)
    if not instance(o,'BasePart') or not o.Parent or not o.Anchored then return false end
    local s=o.Size
    if math.abs(s.X-225)>=.6 or math.abs(s.Y-1)>=.3 or math.abs(s.Z-420)>=.6 then return false end
    local c=o.CFrame
    return (o.Position-V(0,2.5,0)).Magnitude<1.5 and c.UpVector.Y>.999
        and math.abs(c.RightVector.X)>.999 and math.abs(c.LookVector.Z)>.999
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
                    if lines.ground and lines.ground~=o then lines.groundAmbiguous=true else lines.ground=o end
                elseif markerCandidate(o) then
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
        'MIN_PLAY_SECONDS|'..CFG.MinPlayAge,'MIN_DOWNFIELD_YARDS|'..CFG.MinDownfieldYards,
        'POSSESSION_AGE_SECONDS|'..(possession.epoch>0 and string.format('%.2f',math.max(0,os.clock()-possession.since)) or 'NONE'),
        'TARGET_DEPTH_YARDS|'..(choice and string.format('%.2f',downfield(choice.sample.p)/3) or 'NONE'),
        'OPEN_HOLD_SECONDS|'..(choice and choice.openSince and string.format('%.2f',os.clock()-choice.openSince) or 'NONE'),
        'RECEIVER_READINESS|CURRENT_POSITION_BEYOND_LOS; OBSERVED_RECENT_CONTINUOUS_MOVEMENT',
        'RUNTIME_VALIDATION|UNVERIFIED_IN_ROBLOX','JUMP_CATCH_CALIBRATION|MISSING; NO_ADDED_JUMP_BULLET',
        'RELEASE|SOURCE_NATIVE_SOLVER_OUTPUT; ONE_REQUEST_PER_POSSESSION; NO_AUTOMATIC_RETRY'}
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
    stopped=true; controller.IsStopped=true
    releaseChoice()
    local remaining={}
    for _,connection in ipairs(connections) do
        local ok=pcall(function() connection:Disconnect() end)
        if not ok then remaining[#remaining+1]=connection end
    end
    connections=remaining; log('STOP',reason or 'USER_END'); gate='STOPPED'
    if gui then local ok=pcall(function() gui:Destroy() end); if ok then gui=nil end end
    cleanupComplete=#remaining==0 and gui==nil and lease==nil
    preserve(true)
    if cleanupComplete and env[KEY]==controller then env[KEY]=nil end
    return cleanupComplete
end
function controller.SetAuto(value)
    auto=value==true
    if not auto then releaseChoice() end
    if autoButton then autoButton.Text=auto and 'AUTO ON' or 'AUTO OFF' end
    log('AUTO',auto)
end
function controller.SetThrow(value)
    throwing=value==true
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
    local matches={}; local seen={}
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
                        local s; for _,t in ipairs(tables(values(r.fn))) do local found=state(t); if found then s=found end end
                        if same and s and not seen[n.fn] then
                            seen[n.fn]=true; matches[#matches+1]={q=q,hud=h,selector=selector,solve=n.fn,state=s,preview=p.connection,release=r.connection}
                        end
                    end
                end
            end
        end
    end
    if #matches~=1 then return nil,#matches==0 and 'WAIT_YUNA_SOURCE_PROFILE' or 'AMBIGUOUS_YUNA_INSTANCES' end
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
local function ready()
    if stopped or (context.IsCancelled and context.IsCancelled()) then return nil,'STOPPED' end
    if not auto then return nil,'AUTO_OFF' end
    if not profile then return nil,'WAIT_YUNA_SOURCE_PROFILE' end
    local q=profile.q
    if not q.Enabled then return nil,'ENABLE_YUNA_QB_AIMBOT' end
    if q.MouseAimbot.Enabled then return nil,'YUNA_MOUSE_AIM_ACTIVE' end
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
    for _,track in ipairs(tracks) do if track.Name=='Throw' and track.IsPlaying then ball.nativeThrow=true; break end end
    ball.model,ball.root,ball.head=model,root,head
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
    s.hum,s.head=hum,head
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
-- Existing V13 conservative interception assumptions, now applied to the actual
-- native trajectory. These are estimates, not verified FF3 catch windows.
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
        return linearMinimum(o.X-d.p.X,o.Z-d.p.Z,v.X-d.v.X,v.Z-d.v.Z,a,b,1.2)-(4.5+d.turn*3)
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
        -- Compare against the native arrival, including native lead/SmartPass.
        local db=predict(d,t)
        local separation=flat(db-shot.arrival).Magnitude
        local uncertainty=2+1.75*t+d.turn*4+receiver.turn*math.min(8,2+2*t)
        margin=math.min(margin,separation-uncertainty)
        laneMargin=math.min(laneMargin,lane(shot,d))
    end
    shot.margin,shot.lane=margin,laneMargin
    shot.score=margin*1.8+laneMargin*1.5-t*3-receiver.turn*12
    return shot
end
local function solve(player)
    if not lock(player) then return nil,'NATIVE_LOCK_BUSY' end
    if not teammate(player) or profile.selector()~=player.Character then return nil,'NATIVE_TARGET_MISMATCH' end
    local q=profile.q
    -- fn37's tuple is not the displayed HUD angle. In particular tuple #8 is an
    -- initial angle; #6 is the final velocity after native lead/solver iterations.
    nativeCalls=nativeCalls+1
    local ok,dir,origin,endpoint,power,time,velocity,aimpoint,initialAngle,mode=pcall(profile.solve,q.Angle,q.SelectedType)
    if stopped then return nil,'STOPPED' end
    if not ok then log('SOLVER_ERROR',dir); return nil,'NATIVE_SOLVER_ERROR' end
    if not ownsLock() or not teammate(player) or profile.selector()~=player.Character then return nil,'NATIVE_TARGET_MISMATCH' end
    origin,velocity=nativeVector(origin),nativeVector(velocity)
    if not vector(origin) or not vector(velocity) or not finite(time) or time<.05 or time>CFG.MaxFlight
        or not finite(power) or power<=0 or power>100 or velocity.Magnitude<1 or not modes[mode] then return nil,'NATIVE_SOLVER_INVALID' end
    if flat(player.Character:FindFirstChild('HumanoidRootPart').Position-origin).Magnitude>CFG.MaxRange then return nil,'NATIVE_RANGE' end
    local arrival=origin+velocity*time-V(0,.5*CFG.Gravity*time*time,0)
    return {origin=origin,velocity=velocity,power=power,time=time,mode=mode,arrival=arrival,at=os.clock()}
end
local function submit(ball,selected,defenders,now)
    if usedTools[ball.tool]==possession.epoch then setGate('REQUEST_ALREADY_ATTEMPTED'); return end
    if receiverMenu and receiverMenu.Visible then setGate('RECEIVER_MENU_OPEN'); return end
    local current,reason=ready()
    if not current or current.tool~=ball.tool then setGate(reason or 'POSSESSION_CHANGED'); return end
    if current.nativeThrow then setGate('NATIVE_MANUAL_THROW_IN_PROGRESS'); return end
    if now-possession.since<CFG.MinPlayAge then setGate('LET_ROUTES_DEVELOP'); return end
    if not readLines(now) then setGate(lines.status); return end
    if downfield(current.root.Position)>.5 then setGate('QB_PAST_LOS'); return end
    local eligible,rejection=receiverReady(selected.player,selected.sample,now)
    if not eligible then releaseChoice(); setGate(rejection); return end
    local shot,why=solve(selected.player)
    if not shot then setGate(why); return end
    if stopped then return end
    if os.clock()-now>.28 then setGate('DECISION_STALE_AFTER_NATIVE_SOLVER'); return end
    if not readLines(os.clock()) then releaseChoice(); setGate(lines.status); return end
    eligible,rejection=receiverReady(selected.player,selected.sample,os.clock(),shot.arrival)
    if not eligible then releaseChoice(); setGate(rejection); return end
    risk(shot,selected.sample,defenders)
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
    log('REQUEST',selected.player.Name..' '..shot.mode..' '..string.format('t=%.3f p=%.2f',shot.time,shot.power))
    local ok,err=pcall(function()
        ball.remote:FireServer('Clicked',shot.origin-unit*5+V(70000000,0,0),shot.origin+unit*10000,shot.power,1)
    end)
    if ok then sent=sent+1; pending.outcome='API_ACCEPTED_UNCONFIRMED'; setGate('REQUEST_SENT_UNCONFIRMED')
    else ambiguous=ambiguous+1; pending.outcome='AMBIGUOUS_NO_RETRY'; log('REQUEST_ERROR',err); setGate('REQUEST_AMBIGUOUS_NO_RETRY') end
    preserve(false)
end
local function tick(now)
    if stopped or inTick or now-lastTick<CFG.Interval then return end
    inTick=true; lastTick=now
    local begun=os.clock()
    local ok,err=pcall(function()
        if context.IsCancelled and context.IsCancelled() then controller.Stop('CANCELLED'); return end
        scanLines()
        if renderReceivers and receiverMenu and receiverMenu.Visible then renderReceivers(now) end
        if profile and (not aliveConnection(profile.preview) or not aliveConnection(profile.release)) then
            releaseChoice(); profile=nil; nextDiscovery=0; log('PROFILE','Disconnected; rediscovering')
        end
        if not profile and now>=nextDiscovery then
            nextDiscovery=now+CFG.DiscoveryInterval
            local why; profile,why=discover()
            if not profile then setGate(why); return end
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
                releaseChoice()
                log('POSSESSION',possession.epoch)
            end
            possession.wasReady=true
        else
            if pending and possession.wasReady then pending.outcome='POSSESSION_ENDED; THROW_NOT_VERIFIED' end
            possession.wasReady=false
        end
        local ball,why=ready()
        if not ball then releaseChoice(); setGate(why); return end
        if ball.nativeThrow and usedTools[ball.tool]~=possession.epoch then
            usedTools[ball.tool]=possession.epoch
            pending={tool=ball.tool,model=ball.model,target=choice and choice.player.Name or 'NATIVE',
                mode=choice and choice.shot.mode or 'NATIVE',at=now,outcome='NATIVE_MANUAL_THROW_UNCONFIRMED'}
            log('MANUAL','Native Throw animation owns this possession; no competing AUTO request')
        end
        if pending and usedTools[ball.tool]==possession.epoch then
            setGate(pending.outcome=='NATIVE_MANUAL_THROW_UNCONFIRMED' and pending.outcome
                or pending.outcome=='AMBIGUOUS_NO_RETRY' and 'REQUEST_AMBIGUOUS_NO_RETRY' or 'REQUEST_SENT_UNCONFIRMED')
            -- Do not keep a lock invisibly after a rejected/unknown request.
            if now-pending.at>1 then releaseChoice() end
            return
        end
        if not readLines(now) then releaseChoice(); setGate(lines.status); return end
        if possession.lineGeneration~=lines.generation then
            possession.lineGeneration=lines.generation; possession.since=now; releaseChoice()
        end
        if downfield(ball.root.Position)>.5 then releaseChoice(); setGate('QB_PAST_LOS'); return end
        if lease and not ownsLock() then releaseChoice(); setGate('EXTERNAL_NATIVE_LOCK_EDIT'); return end
        if profile.q.Locked and not lease then setGate('USER_NATIVE_LOCK_ACTIVE'); return end
        local roster=Players:GetPlayers()
        if #roster>CFG.MaxRoster then releaseChoice(); setGate('ROSTER_LIMIT'); return end
        local receivers,defenders,seenRoster={},{},{}
        receiverRejects={}
        local observationMissing=false
        for _,player in ipairs(roster) do
            seenRoster[player]=true
            if player~=me and not player.Neutral and player.Team and body(player) then
                local s=sample(player,now)
                if not s or s.n<2 then observationMissing=true
                elseif player.Team==me.Team then
                    local eligible,rejection=receiverReady(player,s,now)
                    local onScreen=true
                    if workspace.CurrentCamera then local point,on=workspace.CurrentCamera:WorldToScreenPoint(s.p); onScreen=on and point.Z>0 end
                    if eligible and onScreen then
                        local estimate=clamp(flat(s.p-ball.head.Position).Magnitude/95,.05,CFG.MaxFlight)
                        receivers[#receivers+1]={player=player,sample=s,estimate=estimate,rank=0}
                    else receiverRejects[player.Name]=rejection or 'OFF_SCREEN' end
                elseif player.Team~=me.Team then defenders[#defenders+1]=s end
            end
        end
        for player in pairs(samples) do if not seenRoster[player] then samples[player]=nil end end
        if observationMissing then releaseChoice(); setGate('SAMPLING_PLAYERS'); return end
        for _,r in ipairs(receivers) do
            local separation=45
            for _,d in ipairs(defenders) do separation=math.min(separation,flat(predict(r.sample,r.estimate)-predict(d,r.estimate)).Magnitude) end
            r.rank=separation-r.estimate*3
        end
        table.sort(receivers,function(a,b) if a.rank==b.rank then return a.player.Name<b.player.Name end; return a.rank>b.rank end)
        if #receivers==0 then releaseChoice(); setGate('NO_ACTIVE_DOWNFIELD_RECEIVER'); return end
        local best
        -- Always evaluate the best estimated candidate; rotate the other slot so
        -- a safe third receiver is reachable when the first two lanes are blocked.
        local indices={1}
        if #receivers>1 then cursor=2+(cursor-1)%(#receivers-1); indices[2]=cursor; cursor=cursor+1 end
        for _,index in ipairs(indices) do
            local r=receivers[index]; local shot,failed=solve(r.player)
            if not shot then log('CANDIDATE',r.player.Name..' '..failed)
            else
                risk(shot,r.sample,defenders)
                local eligible,rejection=receiverReady(r.player,r.sample,now,shot.arrival)
                if not eligible then receiverRejects[r.player.Name]=rejection end
                if eligible and shot.margin>=CFG.SelectMargin and shot.lane>=CFG.SelectLane and (not best or shot.score>best.shot.score) then
                    r.shot=shot; best=r
                end
            end
            if stopped then return end
        end
        if not best then releaseChoice(); setGate('NO_SAFE_NATIVE_TRAJECTORY'); return end
        local previous=choice
        local stable=previous and previous.player==best.player and previous.model==best.player.Character
        best.since=stable and choice.since or now; best.model=best.player.Character
        choice=best
        -- The last candidate may differ from the winner; settle the actual shared
        -- native lock and final preview on the winner before any release.
        local final,failed=solve(best.player)
        if not final then releaseChoice(); setGate(failed); return end
        best.shot=risk(final,best.sample,defenders)
        local eligible,rejection=receiverReady(best.player,best.sample,now,final.arrival)
        if not eligible then releaseChoice(); setGate(rejection); return end
        if best.shot.margin>=CFG.ThrowMargin and best.shot.lane>=CFG.ThrowLane then
            best.openSince=stable and previous.openSince and previous.shot.mode==best.shot.mode and previous.openSince or now
        else best.openSince=nil end
        if not stable then log('SELECT',best.player.Name..' '..best.shot.mode) end
        if not throwing then setGate('SELECT_ONLY'); return end
        if receiverMenu and receiverMenu.Visible then setGate('RECEIVER_MENU_OPEN'); return end
        if now-possession.since<CFG.MinPlayAge then setGate('LET_ROUTES_DEVELOP'); return end
        if not best.openSince or now-best.openSince+1e-6<CFG.Settle then setGate('WAIT_STABLE_OPEN_RECEIVER'); return end
        submit(ball,best,defenders,now)
    end)
    inTick=false
    maxTick=math.max(maxTick,os.clock()-begun)
    if not ok then releaseChoice(); log('TICK_ERROR',err); setGate('RUNTIME_ERROR'); preserve(false) end
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
    gui=Instance.new('ScreenGui'); gui.Name='PELICAN_FF3_AUTO_QB_V15'; gui.ResetOnSpawn=false; gui.DisplayOrder=1000; gui.Parent=pg
    status=button('WAIT YUNA',-166,138)
    local kill=button('X',-26,22); kill.BackgroundColor3=Color3.fromRGB(195,40,40)
    autoButton=button('AUTO ON',-166,58,87); throwButton=button('THR ON',-105,51,87); copyButton=button('COPY',-51,47,87)
    receiverButton=button('WR LIST',-166,78,112); receiverButton.Name='Receivers'
    paceButton=button('WAIT 3s',-85,81,112); paceButton.Name='Pace'
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
        receiverMenu.Visible=not receiverMenu.Visible; if choice then choice.openSince=nil end
        if receiverMenu.Visible then renderReceivers() end
    end)
    connect(paceButton.Activated,function() CFG.MinPlayAge=CFG.MinPlayAge>=5 and 3 or CFG.MinPlayAge+1; paceButton.Text='WAIT '..CFG.MinPlayAge..'s'; log('PACE',CFG.MinPlayAge) end)
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
    if me.OnTeleport then connect(me.OnTeleport,function() preserve(true) end) end
    connect(workspace.DescendantAdded,onLineAdded)
    connect(pg.DescendantAdded,onLineAdded)
    if core and core.DescendantAdded then connect(core.DescendantAdded,onLineAdded) end
    connect(Run.Heartbeat,function() tick(os.clock()) end)
end)
if not built then controller.Stop('STARTUP_ERROR'); error(buildError) end
log('START','Native shared lock; original Yuna throw settings preserved')
return controller
