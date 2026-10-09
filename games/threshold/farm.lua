-- Threshold farm v6.1 integration adapter. Original source is immutable in archive/threshold-context.
-- Eli/Scrow mechanics preserved; only loader owns teleport queue/session flags.
local context=...
assert(type(context)=='table','THRESHOLD_FARM_CONTEXT_REQUIRED')
assert(type(context.RegisterCleanup)=='function' and type(context.IsCancelled)=='function','THRESHOLD_FARM_LIFECYCLE_REQUIRED')
local resume=context.Resume
assert(type(resume)=='table' and type(resume.Enabled)=='function'
 and type(resume.GetFarmState)=='function' and type(resume.SaveFarmState)=='function'
 and type(resume.DisarmFarm)=='function' and type(resume.GetSelection)=='function','THRESHOLD_FARM_RESUME_REQUIRED')
local ctl={Version='PELICAN_THRESHOLD_FARM_V6_1_ADAPTER'}
local cleanupImpl,cleanupConfirmed,stopRequested,stopReported,disarmed=nil,false,false,false,false
local notified=false
function ctl.Stop(reason)
 stopRequested=true
 if cleanupImpl then return cleanupImpl(reason) end
 -- No resources have been acquired yet. A synchronous loader cancellation
 -- during RegisterCleanup can safely prevent the rest of initialization.
 cleanupConfirmed=true
 return true
end
function ctl.IsStopped() return cleanupConfirmed end
context.RegisterCleanup(ctl.Stop)
assert(not stopRequested and not context.IsCancelled(),'THRESHOLD_FARM_CANCELLED')
assert(game.PlaceId==78453398695059 or game.PlaceId==129085487311457,'UNSUPPORTED_PLACE')
assert(resume.Enabled()==true,'LOADER_TELEPORT_RESUME_UNAVAILABLE')
assert(resume.GetSelection().farm==true,'THRESHOLD_FARM_NOT_SELECTED')
local RUN_SOURCE = [====[
local context = ...
-- PELICAN | THRESHOLD embedded run v3.2
-- Execute INSIDE ChaseMap "eli". Starts after the parent farm confirms map and character readiness.
-- Moves your character to live key prompts, confirms replicated progress,
-- Faces each prompt throughout interaction and acknowledgement,
-- then tries the exit gate. ONE run only; no purchases or reward-roll calls.
-- Automatically copies/saves a focused report on completion or failure.
-- SAVE stops movement and exports. Red dot exports then destroys all resources.
-- Native prompt API: https://create.roblox.com/docs/reference/engine/classes/ProximityPrompt
-- v3.1: searches the whole ChaseWorld for key pickups, waits for late/enabled
-- keys, and reports incomplete key spawns. Does not force-enable game prompts.
local Players = game:GetService('Players')
local RS = game:GetService('ReplicatedStorage')
local Http = game:GetService('HttpService')
local PPS = game:GetService('ProximityPromptService')
local RunService = game:GetService('RunService')
local player = Players.LocalPlayer
assert(player, 'Run this on the client, inside the map.')
local pg = player:FindFirstChildOfClass('PlayerGui')
assert(pg, 'Wait for the map to load.')
local env = type(getgenv) == 'function' and getgenv() or _G
local GLOBAL = '__PELICAN_THRESHOLD_RUN_V3_1'
for _, key in ipairs({GLOBAL, '__PELICAN_THRESHOLD_RUN_V3', '__PELICAN_THRESHOLD_RUN_V2', '__PELICAN_THRESHOLD_DUMP_V1'}) do
    local prior = env[key]
    if type(prior) == 'table' then
        assert(type(prior.destroy)=='function','PRIOR_RUNNER_HAS_NO_CLEANUP: '..key)
        local ok,result=pcall(prior.destroy)
        if ok and type(prior.IsStopped)=='function' then
            local checked,stopped=pcall(prior.IsStopped);result=checked and stopped==true
        end
        assert(ok and result==true,'PRIOR_RUNNER_CLEANUP_UNCONFIRMED: '..key)
    end
end
local ctl = {}; env[GLOBAL] = ctl
local alive, running, exporting = true, true, false
local started = os.clock()
local worker, held, gui, label, savedText
local ownedInstances = {}
local aimBound = false
local cleanupErrors = {}
local observers, buttons = {}, {}
local runEnded, fatal
local aim, releaseAim
local AIM_BINDING = GLOBAL .. '_Camera'
local CONFIG = {maxSeconds = 140, missingKeyWait = 0, keyAttempts = 3, gateAttempts = 5, settle = 0.25, retrySettle = 0.75, startupWait = 0.25, ackWait = 2.5}
local report = {schema='threshold-run/3.5', placeId=game.PlaceId, placeVersion=game.PlaceVersion,
    utc=os.date('!%Y-%m-%dT%H:%M:%SZ'), events={}, snapshots={}, config=CONFIG,
    purpose='Single automated key/gate run. Server confirmation required; replay/reward loop not yet enabled.'}
local function elapsed() return math.floor((os.clock()-started)*100)/100 end
local function finite(n) return n==n and math.abs(n)~=math.huge end
local function vec(v) return {v.X,v.Y,v.Z} end
local function path(i) return i and i:GetFullName() or '<nil>' end
local function safe(v, depth, seen)
    depth,seen=depth or 0,seen or {}
    local k=typeof(v)
    if k=='nil' then return '<nil>' end
    if k=='number' then return finite(v) and v or tostring(v) end
    if k=='boolean' then return v end
    if k=='string' then
        local ok,n=pcall(utf8.len,v)
        if not ok or not n then return '<binary:'..#v..' bytes>' end
        if #v<=1000 then return v end
        local cut=1000
        while string.byte(v,cut+1)>=128 and string.byte(v,cut+1)<192 do cut=cut-1 end
        return v:sub(1,cut)..'<truncated>'
    end
    if k=='Vector3' then return vec(v) end
    if k=='CFrame' then return {position=vec(v.Position),look=vec(v.LookVector)} end
    if k=='Instance' then return {path=path(v),class=v.ClassName} end
    if k~='table' then return tostring(v) end
    if depth>=4 then return '<depth>' end
    if seen[v] then return '<cycle>' end
    seen[v]=true
    local out,n={},0
    for key,value in pairs(v) do
        n=n+1; if n>60 then out._truncated=true;break end
        out[tostring(key)]=safe(value,depth+1,seen)
    end
    seen[v]=nil;return out
end
local function log(kind,data)
    if #report.events<220 then table.insert(report.events,{t=elapsed(),kind=kind,data=safe(data)}) end
end
local function observe(signal,fn,isUI)
    local c=signal:Connect(function(...)
        if not alive or (not isUI and not running) then return end
        local ok,err=pcall(fn,...)
        if not ok then log('listener_error',tostring(err)) end
    end)
    table.insert(isUI and buttons or observers,c)
end
local function disconnect(list)
    for i=#list,1,-1 do
        local c=list[i]
        local ok,err=pcall(function() c:Disconnect() end)
        if ok then table.remove(list,i) else cleanupErrors.disconnect=tostring(err) end
    end
    return #list==0
end
local function world() return workspace:FindFirstChild('ChaseWorld') end
local function gate() local w=world();return w and w:FindFirstChild('ExitGate') end
local function character()
    local c=player.Character
    return c,c and c:FindFirstChild('HumanoidRootPart'),c and c:FindFirstChildOfClass('Humanoid')
end
local function keys() return tonumber(player:GetAttribute('Keys')) or 0 end
local function gateState() local g=gate();return g and g:GetAttributes() or {} end
local function countFound()
    local g=gateState()
    return math.max(keys(),tonumber(g.KeysFound) or 0,tonumber(g.KeysIn) or 0)
end
local function promptPosition(p)
    local parent=p and p.Parent
    if not parent then return nil end
    if parent:IsA('Attachment') then return parent.WorldPosition end
    if parent:IsA('BasePart') then return parent.Position end
    if parent:IsA('Model') then return parent:GetPivot().Position end
end
local function promptData(p)
    local pos=promptPosition(p)
    return {path=path(p),position=pos and vec(pos),enabled=p.Enabled,hold=p.HoldDuration,
        range=p.MaxActivationDistance,action=p.ActionText,attributes=safe(p:GetAttributes())}
end
local function keyName(name)
    name=name:lower()
    return name=='key' or name=='key__key' or name=='maintenancekey'
        or name=='maintenance_key' or name:match('^keyspawn_')~=nil
end
local function keyReason(p,w,spawns)
    local action=p.ActionText:lower()
    if action:find('search',1,true) or action:find('open',1,true) then return nil end
    if spawns and p:IsDescendantOf(spawns) then return 'key_spawn_tree' end
    local node=p.Parent
    while node and node~=w do
        if keyName(node.Name) then return 'key_ancestor' end
        node=node.Parent
    end
    local action=p.ActionText:lower()
    if action:find('key',1,true) and not action:find('keypad',1,true)
        and (action:find('pick',1,true) or action:find('take',1,true) or action:find('collect',1,true)) then
        return 'key_pickup_action'
    end
end
local function keyPrompts(includeDisabled)
    local w=world();local out={};local seen={}
    if not w then return out end
    local spawns=w:FindFirstChild('KeySpawns')
    for _,p in ipairs(w:GetDescendants()) do
        if p:IsA('ProximityPrompt') and keyReason(p,w,spawns)
            and (includeDisabled or (p.Enabled and promptPosition(p))) then
            local identity=p.Parent or p;local ancestor=p.Parent
            while ancestor and ancestor~=w do
                if keyName(ancestor.Name) then identity=ancestor end
                ancestor=ancestor.Parent
            end
            if includeDisabled or not seen[identity] then table.insert(out,p);seen[identity]=true end
        end
    end
    return out
end
-- HasKey is sufficient evidence to attempt a container; pickup replication may lag.
local function hiddenKeyBoxes()
    local w=world();local boxes={};local seen={}
    if not w then return boxes end
    local spawns=w:FindFirstChild('KeySpawns')
    for _,box in ipairs(w:GetDescendants()) do
        if box:GetAttribute('HasKey')==true and box:GetAttribute('Opened')~=true then
            local branch=spawns and spawns:FindFirstChild(box.Name)
            local pickup,live=nil,false
            if branch then
                for _,p in ipairs(branch:GetDescendants()) do
                    if p:IsA('ProximityPrompt') and keyReason(p,w,spawns) and promptPosition(p) then
                        if p.Enabled then live=true else pickup=p end
                    end
                end
            end
            local search
            for _,p in ipairs(box:GetDescendants()) do
                if p:IsA('ProximityPrompt') and promptPosition(p) then
                    local action=p.ActionText:lower()
                    if action:find('search',1,true) or action:find('open',1,true) then
                        if not search or (p.Enabled and not search.Enabled) then search=p end
                    end
                end
            end
            if search and not live and not seen[search] then
                seen[search]=true
                table.insert(boxes,{box=box,pickup=pickup,search=search})
            end
        end
    end
    return boxes
end
local function hiddenBoxData(boxes)
    local out={}
    for _,item in ipairs(boxes) do
        table.insert(out,{box=path(item.box),attributes=safe(item.box:GetAttributes()),
            pickup=item.pickup and promptData(item.pickup),search=promptData(item.search)})
    end
    return out
end

local function keyInventory(reason)
    local w=world();local spawns=w and w:FindFirstChild('KeySpawns')
    local result={reason=reason,t=elapsed(),found=countFound(),localKeys=keys(),
        gate=safe(gateState()),streamingEnabled=workspace.StreamingEnabled,
        spawnFolderPresent=spawns~=nil,candidates={},spawnBranches={},otherKeyObjects={}}
    for _,p in ipairs(keyPrompts(true)) do
        if #result.candidates>=60 then result.candidatesCapped=true;break end
        local row=promptData(p);row.match=keyReason(p,w,spawns)
        row.usable=p.Enabled and promptPosition(p)~=nil
        table.insert(result.candidates,row)
    end
    if spawns then
        result.spawnFolderAttributes=safe(spawns:GetAttributes())
        for _,branch in ipairs(spawns:GetChildren()) do
            if #result.spawnBranches>=80 then result.branchesCapped=true;break end
            local row={path=path(branch),class=branch.ClassName,attributes=safe(branch:GetAttributes()),
                descendants=#branch:GetDescendants(),children={}}
            for _,child in ipairs(branch:GetChildren()) do
                if #row.children>=12 then break end
                table.insert(row.children,{name=child.Name,class=child.ClassName})
            end
            table.insert(result.spawnBranches,row)
        end
    end
    if w then
        for _,node in ipairs(w:GetDescendants()) do
            if keyName(node.Name) and not (spawns and node:IsDescendantOf(spawns)) then
                if #result.otherKeyObjects>=40 then break end
                local row={path=path(node),class=node.ClassName,attributes=safe(node:GetAttributes())}
                if node:IsA('BasePart') then row.position=vec(node.Position) end
                table.insert(result.otherKeyObjects,row)
            end
        end
    end
    report.keySearches=report.keySearches or {}
    if #report.keySearches<8 then table.insert(report.keySearches,result) end
    return result
end
-- Read-only evidence from the loaded map, before abandoning a short-key round.
-- Containers are never opened by this audit; names alone are not loot proof.
local function containerAudit()
    local w=world()
    local audit={t=elapsed(),worldAttributes=w and safe(w:GetAttributes()),prompts={},nodes={},valueHints={},
        note='Client-visible container metadata only. No container opened; contents may exist only on the server.'}
    if not w then return audit end
    local deadline=os.clock()+0.2
    local seen={}
    local function nodeInfo(node)
        if seen[node] then return end
        if #audit.nodes>=320 then audit.nodesCapped=true;return end
        seen[node]=true
        local row={path=path(node),class=node.ClassName,attributes=safe(node:GetAttributes()),children={}}
        for _,child in ipairs(node:GetChildren()) do
            if #row.children>=24 then row.childrenCapped=true;break end
            local item={name=child.Name,class=child.ClassName}
            if child:IsA('ValueBase') then item.value=safe(child.Value) end
            table.insert(row.children,item)
        end
        if node:IsA('ValueBase') then row.value=safe(node.Value) end
        table.insert(audit.nodes,row)
    end
    local descendants=w:GetDescendants()
    for _,p in ipairs(descendants) do
        if os.clock()>deadline then audit.timeCapped=true;break end
        if p:IsA('ProximityPrompt') then
            local action=(p.ActionText or ''):lower()
            local fullname=path(p):lower()
            local searchable=action:find('search',1,true) or (action:find('open',1,true)
                and (fullname:find('container',1,true) or fullname:find('box',1,true)
                    or fullname:find('case',1,true) or fullname:find('drawer',1,true)
                    or fullname:find('barrel',1,true)))
            if searchable then
                if #audit.prompts>=100 then audit.promptsCapped=true;break end
                local row=promptData(p);row.object=p.ObjectText;row.ancestors={}
                local parent=p.Parent
                for _=1,8 do
                    if not parent or parent==w then break end
                    table.insert(row.ancestors,path(parent));nodeInfo(parent);parent=parent.Parent
                end
                table.insert(audit.prompts,row)
            end
        end
    end
    -- Value objects can carry replicated item names even when no key model exists.
    for _,node in ipairs(descendants) do
        if os.clock()>deadline then audit.timeCapped=true;break end
        if node:IsA('ValueBase') then
            local name=node.Name:lower();local value=tostring(node.Value):lower()
            if name:find('key',1,true) or name:find('loot',1,true) or name:find('content',1,true)
                or value:find('maintenance',1,true) or value:find('key',1,true) then
                if #audit.valueHints>=80 then audit.hintsCapped=true;break end
                table.insert(audit.valueHints,{path=path(node),class=node.ClassName,value=safe(node.Value),attributes=safe(node:GetAttributes())})
            end
        end
    end
    return audit
end

local function snapshot(name)
    local c,r,h=character()
    local data={name=name,t=elapsed(),player=safe(player:GetAttributes()),gate=safe(gateState()),
        position=r and vec(r.Position),health=h and h.Health,keys={}}
    for _,p in ipairs(keyPrompts()) do table.insert(data.keys,promptData(p)) end
    table.insert(report.snapshots,data)
    return data
end
local function inspectExit()
    local out={};local w=world()
    if not w then return out end
    for _,name in ipairs({'ExitGate','Exit'}) do
        local container=w:FindFirstChild(name)
        if container then
            table.insert(out,{path=path(container),attributes=safe(container:GetAttributes())})
            for _,i in ipairs(container:GetDescendants()) do
                if #out>=100 then break end
                if i:IsA('ProximityPrompt') then table.insert(out,promptData(i))
                elseif i:IsA('BasePart') and (i.Name:lower():find('trigger') or i.Name:lower():find('touch') or i.Name:lower():find('door')) then
                    table.insert(out,{path=path(i),position=vec(i.Position),size=vec(i.Size),
                        collide=i.CanCollide,touch=i.CanTouch,attributes=safe(i:GetAttributes())})
                end
            end
        end
    end
    return out
end
local function endUI()
    local out={}
    for _,name in ipairs({'ChaseRunEnd','ChaseObjective','ChaseCatchHud','ChaseLives'}) do
        local root=pg:FindFirstChild(name)
        if root then
            table.insert(out,{path=path(root),enabled=root:IsA('ScreenGui') and root.Enabled})
            for _,i in ipairs(root:GetDescendants()) do
                if #out>=90 then break end
                if i:IsA('TextLabel') or i:IsA('GuiButton') then
                    local row={path=path(i),class=i.ClassName,visible=i.Visible,ancestors={}}
                    if i:IsA('TextLabel') or i:IsA('TextButton') then row.text=safe(i.Text);row.textTransparency=i.TextTransparency end
                    local parent=i.Parent
                    while parent and parent~=root do
                        if parent:IsA('GuiObject') then
                            table.insert(row.ancestors,{name=parent.Name,visible=parent.Visible})
                        end
                        parent=parent.Parent
                    end
                    table.insert(out,row)
                end
            end
        end
    end
    return out
end
local function release()
    if not held then return true end
    local p=held
    local ok,err=pcall(function() p:InputHoldEnd() end)
    if ok then held=nil else cleanupErrors.prompt=tostring(err) end
    return ok
end
local function halt()
    running=false;release();if releaseAim then releaseAim() end;disconnect(observers)
    local t=worker
    if t==coroutine.running() then worker=nil
    elseif t then
        local dead,st=pcall(coroutine.status,t)
        if dead and st=='dead' then worker=nil
        else
            local ok,err=pcall(task.cancel,t)
            if ok then worker=nil else cleanupErrors.worker=tostring(err) end
        end
    end
end
local function destroyResources()
    alive=false;halt();disconnect(buttons)
    for i=#ownedInstances,1,-1 do
        local ok,err=pcall(function() ownedInstances[i]:Destroy() end)
        if ok then table.remove(ownedInstances,i) else cleanupErrors.ui=tostring(err) end
    end
    if #ownedInstances==0 then gui=nil end
    local clean=held==nil and aim==nil and not aimBound and worker==nil
        and #observers==0 and #buttons==0 and #ownedInstances==0
    ctl.cleanupErrors=cleanupErrors
    if clean and env[GLOBAL]==ctl then env[GLOBAL]=nil end
    return clean
end
-- Available before UI/listener creation so a partial initialization can be stopped.
ctl.destroy=destroyResources
ctl.IsStopped=function() return not alive and held==nil and aim==nil and not aimBound
    and worker==nil and #observers==0 and #buttons==0 and #ownedInstances==0 end
local function make(class,props,parent)
    local i=Instance.new(class);table.insert(ownedInstances,i);for k,v in pairs(props) do i[k]=v end;i.Parent=parent;return i
end
gui=make('ScreenGui',{Name='PelicanThresholdRun',ResetOnSpawn=false,DisplayOrder=100001},pg)
local panel=make('Frame',{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-34,0,5),Size=UDim2.fromOffset(282,105),BackgroundColor3=Color3.fromRGB(20,23,29),BorderSizePixel=0},gui)
make('UICorner',{CornerRadius=UDim.new(0,8)},panel)
label=make('TextLabel',{Size=UDim2.new(1,-12,0,58),Position=UDim2.fromOffset(6,3),BackgroundTransparency=1,TextColor3=Color3.new(1,1,1),Font=Enum.Font.Code,TextSize=13,TextWrapped=true,Text='THRESHOLD RUN TEST v3.2\nStarting when ready...'},panel)
local save=make('TextButton',{Position=UDim2.fromOffset(7,66),Size=UDim2.fromOffset(176,31),BackgroundColor3=Color3.fromRGB(37,105,85),TextColor3=Color3.new(1,1,1),Font=Enum.Font.Code,TextSize=13,Text='STOP + COPY'},panel)
local view=make('TextButton',{Position=UDim2.fromOffset(190,66),Size=UDim2.fromOffset(85,31),TextColor3=Color3.new(1,1,1),BackgroundColor3=Color3.fromRGB(53,59,70),Font=Enum.Font.Code,TextSize=12,Text='VIEW'},panel)
local red=make('TextButton',{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-6,0,7),Size=UDim2.fromOffset(20,20),BackgroundColor3=Color3.fromRGB(228,53,62),Text='',BorderSizePixel=0},gui)
make('UICorner',{CornerRadius=UDim.new(1,0)},red)
local box=make('TextBox',{Visible=false,Position=UDim2.fromScale(0.05,0.32),Size=UDim2.fromScale(0.9,0.58),BackgroundColor3=Color3.fromRGB(25,29,35),TextColor3=Color3.new(1,1,1),Font=Enum.Font.Code,TextSize=11,TextWrapped=true,MultiLine=true,ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,Text=''},gui)
local page=1
local function showPage()
    local text=savedText or ''
    local pages=math.max(1,math.ceil(#text/16000))
    if page>pages then page=1 end
    box.Text=text:sub((page-1)*16000+1,page*16000)
    view.Text='PAGE '..page..'/'..pages
end
local filename='threshold_run_v3_1_'..os.date('%Y%m%d_%H%M%S')..'.txt'
local function finish(reason)
    if not alive or exporting then return end
    exporting=true;halt()
    if not savedText then
        report.outcome=reason or 'manual_stop';report.duration=elapsed()
        local ok,err=pcall(function()
            snapshot('final');report.exitFinal=inspectExit();report.endUI=endUI();keyInventory('final')
        end)
        if not ok then report.finalSnapshotError=tostring(err) end
        local success,text=pcall(function() return Http:JSONEncode(report) end)
        if not success then
            label.Text='Export error: '..tostring(text):sub(1,130);exporting=false;return
        end
        savedText=text;ctl.reportText=text
    end
    local copy=env.setclipboard or setclipboard or env.toclipboard or toclipboard
    local write=env.writefile or writefile
    local copied=type(copy)=='function' and pcall(copy,savedText)
    local written=type(write)=='function' and pcall(write,filename,savedText)
    label.Text='STOPPED: '..tostring(report.outcome)..'\n'..(copied and 'Report auto-copied' or 'Use VIEW to copy')..(written and ' | file saved' or '')
    save.Text='COPY AGAIN';showPage()
    if not copied and not written then box.Visible=true end
    print('[PELICAN] '..report.outcome..' | '..filename..' | '..#savedText..' bytes')
    exporting=false
end
ctl.destroy=function()
    if alive and not savedText then pcall(finish,'red_button_stop') end
    -- Keep the native final report available to the parent after UI removal.
    return destroyResources()
end
ctl.export=function() finish('manual_stop') end
observe(red.Activated,ctl.destroy,true)
observe(save.Activated,ctl.export,true)
observe(view.Activated,function()
    if not savedText then finish('manual_stop') end
    if box.Visible then page=page+1 end
    box.Visible=true;showPage()
end,true)
local function guard()
    if not alive or not running or (context and context.IsCancelled and context.IsCancelled()) then error('STOPPED',0) end
    if elapsed()>CONFIG.maxSeconds then error('RUN_TIMEOUT',0) end
    if fatal then error(fatal,0) end
    if not runEnded then
        local _,r,h=character()
        if not r or not h or h.Health<=0 then error('CHARACTER_UNAVAILABLE',0) end
    end
end
local function waitFor(seconds,predicate)
    local untilTime=os.clock()+seconds
    repeat
        guard()
        if runEnded or (predicate and predicate()) then return true end
        if os.clock()>=untilTime then break end
        task.wait(0.08)
    until false
    return runEnded~=nil or (predicate and predicate()) or false
end
-- The v2 body rotation did not rotate the player's camera. Own the camera only
-- during an interaction, including its acknowledgement window, and update after
-- the game's normal camera callbacks so the custom prompt stays in the center.
releaseAim=function()
    local state=aim
    if state then state.releasing=true end
    local unbound,err=pcall(function() RunService:UnbindFromRenderStep(AIM_BINDING) end)
    if unbound then aimBound=false else cleanupErrors.aim=tostring(err) end
    if state then
        for camera,original in pairs(state.cameras) do
            local ok,restoreError=pcall(function()
                if camera.CameraType==Enum.CameraType.Scriptable then
                    camera.CameraType=original.cameraType
                    camera.Focus=original.focus
                    if original.cameraType==Enum.CameraType.Scriptable then camera.CFrame=original.cframe end
                end
            end)
            if ok then state.cameras[camera]=nil else cleanupErrors.camera=tostring(restoreError) end
        end
        if next(state.cameras)==nil and unbound then
            aim=nil;log('camera_released',{frames=state.frames,prompt=state.path})
        end
    end
    return unbound and aim==nil
end
local function facePrompt(p)
    assert(releaseAim(),'PRIOR_CAMERA_CLEANUP_UNCONFIRMED')
    local state={prompt=p,path=path(p),frames=0,centeredFrames=0,cameras={}}
    aim=state
    local function update()
        if aim~=state or state.releasing or not alive or not running
            or (context and context.IsCancelled and context.IsCancelled()) then return end
        if runEnded or not p:IsDescendantOf(workspace) then releaseAim();return end
        local camera=workspace.CurrentCamera
        local c,root=character()
        local target=promptPosition(p)
        if not camera or not root or not target then state.centeredFrames=0;return end
        if not state.cameras[camera] then
            state.cameras[camera]={cameraType=camera.CameraType,cframe=camera.CFrame,focus=camera.Focus}
        end
        local head=c:FindFirstChild('Head')
        local origin=head and head.Position+Vector3.new(0,0.15,0) or root.Position+Vector3.new(0,1.6,0)
        if (target-origin).Magnitude<0.1 then state.centeredFrames=0;return end
        camera.CameraType=Enum.CameraType.Scriptable
        camera.CFrame=CFrame.lookAt(origin,target)
        camera.Focus=CFrame.new(target)
        local screen,onScreen=camera:WorldToViewportPoint(target)
        local size=camera.ViewportSize
        local dot=camera.CFrame.LookVector:Dot((target-origin).Unit)
        local centered=onScreen and screen.Z>0 and size.X>0 and size.Y>0
            and math.abs(screen.X/size.X-0.5)<0.06 and math.abs(screen.Y/size.Y-0.5)<0.06 and dot>0.995
        state.centeredFrames=centered and state.centeredFrames+1 or 0
        state.frames=state.frames+1
        state.sample={onScreen=onScreen,dot=dot,screen=vec(screen),eye=vec(origin),target=vec(target)}
    end
    local function render()
        local ok,err=pcall(update)
        if not ok then
            state.error=tostring(err)
            releaseAim()
        end
    end
    aimBound=true
    RunService:BindToRenderStep(AIM_BINDING,Enum.RenderPriority.Last.Value+1,render)
    render()
    waitFor(0.8,function() return state.centeredFrames>=3 or state.error~=nil end)
    local ready=aim==state and state.centeredFrames>=3 and not state.error
    log('camera_alignment',{ready=ready,prompt=state.path,sample=state.sample,error=state.error})
    if not ready then releaseAim() end
    return ready
end
local function standPoint(p)
    local c,r,h=character();local target=promptPosition(p)
    if not target then return nil,'PROMPT_POSITION_MISSING' end
    local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances={c};params.RespectCanCollide=true
    local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Exclude
    overlap.FilterDescendantsInstances={c};overlap.RespectCanCollide=true
    local clearance=h.HipHeight+r.Size.Y/2
    local best,bestScore
    for index=0,7 do
        local angle=index*math.pi/4
        local offset=Vector3.new(math.cos(angle)*3,0,math.sin(angle)*3)
        local hit=workspace:Raycast(target+offset+Vector3.new(0,2,0),Vector3.new(0,-12,0),params)
        if hit and hit.Normal.Y>0.65 then
            local point=hit.Position+Vector3.new(0,clearance+0.1,0)
            if (point-target).Magnitude<p.MaxActivationDistance-0.3 then
                local colliders=workspace:GetPartBoundsInBox(CFrame.new(point),Vector3.new(2.2,3.8,2.2),overlap)
                local clear=true
                for _,part in ipairs(colliders) do if part.CanCollide then clear=false;break end end
                local score=(point-r.Position).Magnitude
                if clear and (not bestScore or score<bestScore) then best,bestScore=point,score end
            end
        end
    end
    return best,best and nil or 'NO_CLEAR_STANDING_POINT'
end
local function approach(p,attempt)
    guard();if runEnded then return false end
    local _,r=character();local target=promptPosition(p)
    if not target then return false end
    if (r.Position-target).Magnitude<=math.min(4,p.MaxActivationDistance-0.5) then return true end
    local point,why=standPoint(p)
    if not point then log('approach_failed',{prompt=path(p),reason=why});return false end
    log('move',{prompt=path(p),from=vec(r.Position),to=vec(point)})
    r.CFrame=CFrame.lookAt(point,Vector3.new(target.X,point.Y,target.Z))
    r.AssemblyLinearVelocity=Vector3.zero;r.AssemblyAngularVelocity=Vector3.zero
    waitFor(attempt and attempt>1 and CONFIG.retrySettle or CONFIG.settle)
    if runEnded then return false end
    local _,current=character()
    local distance=(current.Position-target).Magnitude
    log('movement_check',{distance=distance,position=vec(current.Position)})
    if distance>p.MaxActivationDistance-0.1 then error('MOVEMENT_NOT_RETAINED',0) end
    return true
end
local function activate(p,attempt)
    guard();if runEnded or not p.Parent or not p.Enabled then return false end
    if not approach(p,attempt) then return false end
    if not facePrompt(p) or runEnded or not p.Parent or not p.Enabled then releaseAim();return false end
    local fire=env.fireproximityprompt or fireproximityprompt
    local method=attempt>=2 and type(fire)=='function' and 'executor_prompt' or 'native_hold'
    log('interact',{prompt=promptData(p),attempt=attempt,method=method})
    if method=='executor_prompt' then
        local ok,err=pcall(fire,p,p.HoldDuration)
        if not ok then releaseAim();log('prompt_error',tostring(err));return false end
    else
        held=p
        local ok,err=pcall(function() p:InputHoldBegin() end)
        if not ok then release();releaseAim();log('prompt_error',tostring(err));return false end
        waitFor(math.max(0.15,p.HoldDuration+0.2));release()
    end
    return true
end
observe(player.AttributeChanged,function(name)
    if name=='Keys' or name=='EliChasing' or name=='ChaseLives' or name=='InCase'
        or name=='XP' or name=='Level' or name:lower():find('cash') or name:lower():find('reward') then
        log('player_attribute',{name=name,value=player:GetAttribute(name)})
    end
end)
observe(player.CharacterAdded,function() fatal='RESPAWN_DURING_TEST' end)
local startLives=tonumber(player:GetAttribute('ChaseLives'))
observe(player:GetAttributeChangedSignal('ChaseLives'),function()
    local lives=tonumber(player:GetAttribute('ChaseLives'))
    if startLives and lives and lives<startLives then fatal='LIFE_LOST_DURING_TEST' end
end)
observe(PPS.PromptTriggered,function(p,who)
    if who and who~=player then return end
    log('prompt_triggered',{path=path(p)})
end)
local remotes=RS:FindFirstChild('ChaseRemotes')
for _,entry in ipairs({{remotes,'RunEnded'},{RS,'ChaseKeyEvent'},{RS,'DropRoll'}}) do
    local folder,name=entry[1],entry[2]
    local remote=folder and folder:FindFirstChild(name)
    if remote and remote:IsA('RemoteEvent') then
        observe(remote.OnClientEvent,function(...)
            local args=table.pack(...)
            log('server_event',{name=name,args=args})
            if name=='RunEnded' then
                runEnded=safe(args);report.runEnded=runEnded
                release();releaseAim()
            end
        end)
    end
end
local g=gate()
if g then observe(g.AttributeChanged,function(name) log('gate_attribute',{name=name,value=g:GetAttribute(name)}) end) end
worker=task.defer(function()
    local ok,outcome=pcall(function()
        guard()
        assert(game.PlaceId==129085487311457,'WRONG_PLACE')
        assert(player:GetAttribute('ChaseMap')=='eli','WRONG_MAP: expected eli')
        assert(world() and gate(),'MAP_NOT_LOADED')
        assert(player:GetAttribute('InCase')==true,'NOT_IN_ACTIVE_ROUND')
        assert(gateState().RunStarted==true,'ROUND_NOT_STARTED')
        local c,r,h=character()
        assert(not r.Anchored and not h.Sit,'CHARACTER_BUSY')
        report.capabilities={fireproximityprompt=type(env.fireproximityprompt or fireproximityprompt)=='function',
            clipboard=type(env.setclipboard or setclipboard or env.toclipboard or toclipboard)=='function'}
        report.initial=snapshot('start');report.exitInitial=inspectExit();keyInventory('start')
        waitFor(CONFIG.startupWait)
        local needed=tonumber(gateState().KeysNeeded) or 3
        local available=keyPrompts()
        local alreadyFound=countFound()
        local hidden=hiddenKeyBoxes()
        report.preflight={t=elapsed(),found=alreadyFound,liveKeys=#available,hiddenKeys=#hidden,hiddenBoxes=hiddenBoxData(hidden),needed=needed,
            enough=alreadyFound+#available+#hidden>=needed,worldAttributes=safe(world():GetAttributes())}
        log('key_preflight',report.preflight)
        -- Search identified containers BEFORE deciding whether this round lacks keys.
        if #hidden>0 or not report.preflight.enough then
            report.containerAudit=containerAudit()
            report.containerResults={}
        end
        for _,item in ipairs(hidden) do
            if countFound()+#keyPrompts()>=needed or runEnded then break end
            label.Text='Opening key box: '..item.box.Name
            local beforeTotal=countFound()+#keyPrompts()
            local function availableNow()
                return (item.pickup and item.pickup:IsDescendantOf(workspace) and item.pickup.Enabled and promptPosition(item.pickup)~=nil)
                    or countFound()+#keyPrompts()>beforeTotal
            end
            local confirmed=availableNow()
            for attempt=1,2 do
                if confirmed or runEnded then break end
                -- Do not re-search an opened box while waiting for its pickup to enable.
                if item.box:GetAttribute('Opened')~=true then
                    if not item.search.Enabled then
                        approach(item.search,attempt)
                        waitFor(1.5,function() return item.search.Enabled end)
                    end
                    activate(item.search,attempt)
                end
                waitFor(3,availableNow)
                release();releaseAim()
                confirmed=availableNow()
            end
            local result={box=path(item.box),opened=item.box:GetAttribute('Opened'),
                confirmed=confirmed,pickup=item.pickup and promptData(item.pickup)}
            table.insert(report.containerResults,result);log('container_result',result)
            if runEnded then break end
            if not confirmed then
                keyInventory('container_key_not_ready')
                error('MISSING_KEY_CONTAINER_NOT_READY',0)
            end
        end
        report.afterContainerCheck={found=countFound(),liveKeys=#keyPrompts(),needed=needed}
        if not runEnded and countFound()+#keyPrompts()<needed then
            keyInventory('insufficient_after_container_check')
            error('MISSING_KEY_PREFLIGHT_INSUFFICIENT',0)
        end
        local processed=0
        while not runEnded and countFound()<needed and processed<6 do
            guard()
            local prompts=keyPrompts()
            if #prompts==0 then
                release();releaseAim()
                keyInventory('missing_key_search_started')
                log('key_search_wait',{found=countFound(),needed=needed,seconds=CONFIG.missingKeyWait})
                local deadline=os.clock()+CONFIG.missingKeyWait
                while #prompts==0 and not runEnded and countFound()<needed and os.clock()<deadline do
                    label.Text='Waiting for missing key: '..countFound()..'/'..needed
                        ..'\nRescanning map: '..math.ceil(deadline-os.clock())..'s'
                    waitFor(math.min(1,math.max(0,deadline-os.clock())),function() return countFound()>=needed end)
                    prompts=keyPrompts()
                end
                if runEnded or countFound()>=needed then break end
                keyInventory(#prompts>0 and 'missing_key_recovered' or 'missing_key_timeout')
                log('key_search_result',{activePrompts=#prompts,found=countFound()})
                assert(#prompts>0,'MISSING_KEY_NO_LIVE_PROMPTS')
            end
            local _,root=character()
            table.sort(prompts,function(a,b)
                return (promptPosition(a)-root.Position).Magnitude<(promptPosition(b)-root.Position).Magnitude
            end)
            local target=prompts[1]
            local before=countFound();local confirmed=false
            label.Text='Collecting keys: '..before..'/'..needed
            for attempt=1,CONFIG.keyAttempts do
                if runEnded then break end
                if not target:IsDescendantOf(workspace) then
                    waitFor(1,function() return countFound()>before end);break
                end
                activate(target,attempt)
                waitFor(CONFIG.ackWait,function() return countFound()>before end)
                releaseAim()
                if countFound()>before then confirmed=true;break end
            end
            if runEnded then break end
            confirmed=confirmed or countFound()>before
            log('key_result',{confirmed=confirmed,before=before,after=countFound(),localKeys=keys()})
            assert(confirmed,'KEY_PICKUP_NOT_CONFIRMED')
            processed=processed+1
        end
        if not runEnded then
            assert(countFound()>=needed,'NOT_ENOUGH_KEYS')
            snapshot('keys_complete')
            local gatePrompt=gate():FindFirstChild('GatePrompt',true)
            assert(gatePrompt and gatePrompt:IsA('ProximityPrompt'),'GATE_PROMPT_MISSING')
            for attempt=1,CONFIG.gateAttempts do
                if runEnded then break end
                local before=Http:JSONEncode(safe(gateState()))
                label.Text='Keys confirmed. Unlocking exit...\nGate attempt '..attempt
                if gateState().DoorOpen==true then break end
                if not gatePrompt.Parent or not gatePrompt.Enabled then break end
                activate(gatePrompt,attempt)
                waitFor(3,function() return Http:JSONEncode(safe(gateState()))~=before end)
                releaseAim()
                log('gate_after_attempt',gateState())
                -- Allow completion animation/server acknowledgement to arrive.
                if gateState().LockOpen==true or gateState().DoorOpen==true then waitFor(3) end
            end
        end
        if not runEnded then
            label.Text='Waiting for the run-end result...'
            waitFor(8)
        end
        if runEnded then
            -- Observe post-run UI/reward notifications; never click an offer.
            local untilTime=os.clock()+3
            while alive and running and os.clock()<untilTime do task.wait(0.1) end
            return 'RUN_ENDED_RECEIVED'
        end
        return 'GATE_TEST_FINISHED_NO_RUN_END'
    end)
    release()
    if alive and running then
        if not ok then log('run_error',outcome);outcome=tostring(outcome) end
        finish(outcome)
    end
end)
print('[PELICAN] Embedded run starts after readiness checks. Red dot stops, exports, and cleans up.')


return ctl
]====]
local SCROW_SOURCE = [====[
local context = ...
-- PELICAN | THRESHOLD embedded run v3.2
-- Execute INSIDE ChaseMap "eli". Starts after the parent farm confirms map and character readiness.
-- Moves your character to live key prompts, confirms replicated progress,
-- Faces each prompt throughout interaction and acknowledgement,
-- then tries the exit gate. ONE run only; no purchases or reward-roll calls.
-- Automatically copies/saves a focused report on completion or failure.
-- SAVE stops movement and exports. Red dot exports then destroys all resources.
-- Native prompt API: https://create.roblox.com/docs/reference/engine/classes/ProximityPrompt
-- v3.1: searches the whole ChaseWorld for key pickups, waits for late/enabled
-- keys, and reports incomplete key spawns. Does not force-enable game prompts.
local Players = game:GetService('Players')
local RS = game:GetService('ReplicatedStorage')
local Http = game:GetService('HttpService')
local PPS = game:GetService('ProximityPromptService')
local RunService = game:GetService('RunService')
local player = Players.LocalPlayer
assert(player, 'Run this on the client, inside the map.')
local pg = player:FindFirstChildOfClass('PlayerGui')
assert(pg, 'Wait for the map to load.')
local env = type(getgenv) == 'function' and getgenv() or _G
local GLOBAL = '__PELICAN_THRESHOLD_SCROW_RUN_V1'
for _, key in ipairs({GLOBAL, '__PELICAN_THRESHOLD_RUN_V3', '__PELICAN_THRESHOLD_RUN_V2', '__PELICAN_THRESHOLD_DUMP_V1'}) do
    local prior = env[key]
    if type(prior) == 'table' then
        assert(type(prior.destroy)=='function','PRIOR_RUNNER_HAS_NO_CLEANUP: '..key)
        local ok,result=pcall(prior.destroy)
        if ok and type(prior.IsStopped)=='function' then
            local checked,stopped=pcall(prior.IsStopped);result=checked and stopped==true
        end
        assert(ok and result==true,'PRIOR_RUNNER_CLEANUP_UNCONFIRMED: '..key)
    end
end
local ctl = {}; env[GLOBAL] = ctl
local alive, running, exporting = true, true, false
local started = os.clock()
local worker, held, gui, label, savedText
local ownedInstances = {}
local aimBound = false
local cleanupErrors = {}
local observers, buttons = {}, {}
local runEnded, fatal
local aim, releaseAim
local AIM_BINDING = GLOBAL .. '_Camera'
local CONFIG = {maxSeconds = 140, missingKeyWait = 0, keyAttempts = 3, gateAttempts = 5, settle = 0.25, retrySettle = 0.75, startupWait = 0.25, ackWait = 2.5}
local report = {schema='threshold-scrow-run/1.1', placeId=game.PlaceId, placeVersion=game.PlaceVersion,
    utc=os.date('!%Y-%m-%dT%H:%M:%SZ'), events={}, snapshots={}, config=CONFIG,
    purpose='Scrow real clues and keypad. Confirm server progress; no anti-death modifications.'}
local function elapsed() return math.floor((os.clock()-started)*100)/100 end
local function finite(n) return n==n and math.abs(n)~=math.huge end
local function vec(v) return {v.X,v.Y,v.Z} end
local function path(i) return i and i:GetFullName() or '<nil>' end
local function safe(v, depth, seen)
    depth,seen=depth or 0,seen or {}
    local k=typeof(v)
    if k=='nil' then return '<nil>' end
    if k=='number' then return finite(v) and v or tostring(v) end
    if k=='boolean' then return v end
    if k=='string' then
        local ok,n=pcall(utf8.len,v)
        if not ok or not n then return '<binary:'..#v..' bytes>' end
        if #v<=1000 then return v end
        local cut=1000
        while string.byte(v,cut+1)>=128 and string.byte(v,cut+1)<192 do cut=cut-1 end
        return v:sub(1,cut)..'<truncated>'
    end
    if k=='Vector3' then return vec(v) end
    if k=='CFrame' then return {position=vec(v.Position),look=vec(v.LookVector)} end
    if k=='Instance' then return {path=path(v),class=v.ClassName} end
    if k~='table' then return tostring(v) end
    if depth>=4 then return '<depth>' end
    if seen[v] then return '<cycle>' end
    seen[v]=true
    local out,n={},0
    for key,value in pairs(v) do
        n=n+1; if n>60 then out._truncated=true;break end
        out[tostring(key)]=safe(value,depth+1,seen)
    end
    seen[v]=nil;return out
end
local function log(kind,data)
    if #report.events<220 then table.insert(report.events,{t=elapsed(),kind=kind,data=safe(data)}) end
end
local function observe(signal,fn,isUI)
    local c=signal:Connect(function(...)
        if not alive or (not isUI and not running) then return end
        local ok,err=pcall(fn,...)
        if not ok then log('listener_error',tostring(err)) end
    end)
    table.insert(isUI and buttons or observers,c)
end
local function disconnect(list)
    for i=#list,1,-1 do
        local c=list[i]
        local ok,err=pcall(function() c:Disconnect() end)
        if ok then table.remove(list,i) else cleanupErrors.disconnect=tostring(err) end
    end
    return #list==0
end
local function world() return workspace:FindFirstChild('ChaseWorld') end
local function gate() local w=world();return w and w:FindFirstChild('ExitGate') end
local function character()
    local c=player.Character
    return c,c and c:FindFirstChild('HumanoidRootPart'),c and c:FindFirstChildOfClass('Humanoid')
end
local function keys() return tonumber(player:GetAttribute('Keys')) or 0 end
local function gateState() local g=gate();return g and g:GetAttributes() or {} end
local function countFound()
    local g=gateState()
    return math.max(keys(),tonumber(g.KeysFound) or 0,tonumber(g.KeysIn) or 0)
end
local function promptPosition(p)
    local parent=p and p.Parent
    if not parent then return nil end
    if parent:IsA('Attachment') then return parent.WorldPosition end
    if parent:IsA('BasePart') then return parent.Position end
    if parent:IsA('Model') then return parent:GetPivot().Position end
end
local function promptData(p)
    local pos=promptPosition(p)
    return {path=path(p),position=pos and vec(pos),enabled=p.Enabled,hold=p.HoldDuration,
        range=p.MaxActivationDistance,action=p.ActionText,attributes=safe(p:GetAttributes())}
end
local function digits()
    local value=player:GetAttribute('MallDigits')
    return type(value)=='string' and value or ''
end
local function papers()
    local folder=workspace:FindFirstChild('MallCode');local out={};local indices={}
    if not folder then return out end
    for _,model in ipairs(folder:GetChildren()) do
        local index=tonumber(model:GetAttribute('DigitIndex'))
        if model:GetAttribute('Decoy')~=true and model.Name~='OldCodePaper'
            and index and index>=1 and index<=6 and index%1==0 then
            local prompt=model:FindFirstChild('ReadPrompt',true)
            if prompt and prompt:IsA('ProximityPrompt') and promptPosition(prompt) then
                assert(not indices[index],'DUPLICATE_REAL_CLUE_INDEX');indices[index]=true
                local digit
                for _,node in ipairs(model:GetDescendants()) do
                    if node:IsA('TextLabel') then
                        local text=node.Text:gsub('<[^>]->',''):match('^%s*(%d)%s*$')
                        if text then
                            assert(not digit or digit==text,'AMBIGUOUS_CLUE_DIGIT');digit=text
                        end
                    end
                end
                table.insert(out,{model=model,prompt=prompt,index=index,digit=digit})
            end
        end
    end
    table.sort(out,function(a,b) return a.index<b.index end)
    return out
end
local function snapshot(name)
    local _,root=character()
    local data={name=name,t=elapsed(),player=safe(player:GetAttributes()),position=root and vec(root.Position),papers={}}
    for _,item in ipairs(papers()) do
        table.insert(data.papers,{index=item.index,digit=item.digit,prompt=promptData(item.prompt)})
    end
    table.insert(report.snapshots,data);return data
end
local function inspectExit()
    local exit=workspace:FindFirstChild('MallExit')
    return exit and {attributes=safe(exit:GetAttributes())} or {}
end

local function endUI()
    local out={}
    for _,name in ipairs({'ChaseMallCode','ChaseMallKeypad','ChaseSpectate','DropRollUI'}) do
        local root=pg:FindFirstChild(name)
        if root then
            table.insert(out,{path=path(root),enabled=root:IsA('ScreenGui') and root.Enabled})
            for _,i in ipairs(root:GetDescendants()) do
                if #out>=90 then break end
                if i:IsA('TextLabel') or i:IsA('GuiButton') then
                    local row={path=path(i),class=i.ClassName,visible=i.Visible,ancestors={}}
                    if i:IsA('TextLabel') or i:IsA('TextButton') then row.text=safe(i.Text);row.textTransparency=i.TextTransparency end
                    local parent=i.Parent
                    while parent and parent~=root do
                        if parent:IsA('GuiObject') then
                            table.insert(row.ancestors,{name=parent.Name,visible=parent.Visible})
                        end
                        parent=parent.Parent
                    end
                    table.insert(out,row)
                end
            end
        end
    end
    return out
end
local function release()
    if not held then return true end
    local p=held
    local ok,err=pcall(function() p:InputHoldEnd() end)
    if ok then held=nil else cleanupErrors.prompt=tostring(err) end
    return ok
end
local function halt()
    running=false;release();if releaseAim then releaseAim() end;disconnect(observers)
    local t=worker
    if t==coroutine.running() then worker=nil
    elseif t then
        local dead,st=pcall(coroutine.status,t)
        if dead and st=='dead' then worker=nil
        else
            local ok,err=pcall(task.cancel,t)
            if ok then worker=nil else cleanupErrors.worker=tostring(err) end
        end
    end
end
local function destroyResources()
    alive=false;halt();disconnect(buttons)
    for i=#ownedInstances,1,-1 do
        local ok,err=pcall(function() ownedInstances[i]:Destroy() end)
        if ok then table.remove(ownedInstances,i) else cleanupErrors.ui=tostring(err) end
    end
    if #ownedInstances==0 then gui=nil end
    local clean=held==nil and aim==nil and not aimBound and worker==nil
        and #observers==0 and #buttons==0 and #ownedInstances==0
    ctl.cleanupErrors=cleanupErrors
    if clean and env[GLOBAL]==ctl then env[GLOBAL]=nil end
    return clean
end
-- Available before UI/listener creation so a partial initialization can be stopped.
ctl.destroy=destroyResources
ctl.IsStopped=function() return not alive and held==nil and aim==nil and not aimBound
    and worker==nil and #observers==0 and #buttons==0 and #ownedInstances==0 end
local function make(class,props,parent)
    local i=Instance.new(class);table.insert(ownedInstances,i);for k,v in pairs(props) do i[k]=v end;i.Parent=parent;return i
end
gui=make('ScreenGui',{Name='PelicanScrowRun',ResetOnSpawn=false,DisplayOrder=100001},pg)
local panel=make('Frame',{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-34,0,5),Size=UDim2.fromOffset(282,105),BackgroundColor3=Color3.fromRGB(20,23,29),BorderSizePixel=0},gui)
make('UICorner',{CornerRadius=UDim.new(0,8)},panel)
label=make('TextLabel',{Size=UDim2.new(1,-12,0,58),Position=UDim2.fromOffset(6,3),BackgroundTransparency=1,TextColor3=Color3.new(1,1,1),Font=Enum.Font.Code,TextSize=13,TextWrapped=true,Text='SCROW RUN v1\nStarting when ready...'},panel)
local save=make('TextButton',{Position=UDim2.fromOffset(7,66),Size=UDim2.fromOffset(176,31),BackgroundColor3=Color3.fromRGB(37,105,85),TextColor3=Color3.new(1,1,1),Font=Enum.Font.Code,TextSize=13,Text='STOP + COPY'},panel)
local view=make('TextButton',{Position=UDim2.fromOffset(190,66),Size=UDim2.fromOffset(85,31),TextColor3=Color3.new(1,1,1),BackgroundColor3=Color3.fromRGB(53,59,70),Font=Enum.Font.Code,TextSize=12,Text='VIEW'},panel)
local red=make('TextButton',{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-6,0,7),Size=UDim2.fromOffset(20,20),BackgroundColor3=Color3.fromRGB(228,53,62),Text='',BorderSizePixel=0},gui)
make('UICorner',{CornerRadius=UDim.new(1,0)},red)
local box=make('TextBox',{Visible=false,Position=UDim2.fromScale(0.05,0.32),Size=UDim2.fromScale(0.9,0.58),BackgroundColor3=Color3.fromRGB(25,29,35),TextColor3=Color3.new(1,1,1),Font=Enum.Font.Code,TextSize=11,TextWrapped=true,MultiLine=true,ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,Text=''},gui)
local page=1
local function showPage()
    local text=savedText or ''
    local pages=math.max(1,math.ceil(#text/16000))
    if page>pages then page=1 end
    box.Text=text:sub((page-1)*16000+1,page*16000)
    view.Text='PAGE '..page..'/'..pages
end
local filename='threshold_scrow_run_v1_'..os.date('%Y%m%d_%H%M%S')..'.txt'
local function finish(reason)
    if not alive or exporting then return end
    exporting=true;halt()
    if not savedText then
        report.outcome=reason or 'manual_stop';report.duration=elapsed()
        local ok,err=pcall(function()
            snapshot('final');report.exitFinal=inspectExit();report.endUI=endUI()
        end)
        if not ok then report.finalSnapshotError=tostring(err) end
        local success,text=pcall(function() return Http:JSONEncode(report) end)
        if not success then
            label.Text='Export error: '..tostring(text):sub(1,130);exporting=false;return
        end
        savedText=text;ctl.reportText=text
    end
    local copy=env.setclipboard or setclipboard or env.toclipboard or toclipboard
    local write=env.writefile or writefile
    local copied=type(copy)=='function' and pcall(copy,savedText)
    local written=type(write)=='function' and pcall(write,filename,savedText)
    label.Text='STOPPED: '..tostring(report.outcome)..'\n'..(copied and 'Report auto-copied' or 'Use VIEW to copy')..(written and ' | file saved' or '')
    save.Text='COPY AGAIN';showPage()
    if not copied and not written then box.Visible=true end
    print('[PELICAN] '..report.outcome..' | '..filename..' | '..#savedText..' bytes')
    exporting=false
end
ctl.destroy=function()
    if alive and not savedText then pcall(finish,'red_button_stop') end
    -- Keep the native final report available to the parent after UI removal.
    return destroyResources()
end
ctl.export=function() finish('manual_stop') end
observe(red.Activated,ctl.destroy,true)
observe(save.Activated,ctl.export,true)
observe(view.Activated,function()
    if not savedText then finish('manual_stop') end
    if box.Visible then page=page+1 end
    box.Visible=true;showPage()
end,true)
local function guard()
    if not alive or not running or (context and context.IsCancelled and context.IsCancelled()) then error('STOPPED',0) end
    if elapsed()>CONFIG.maxSeconds then error('RUN_TIMEOUT',0) end
    if fatal then error(fatal,0) end
    if not runEnded then
        local _,r,h=character()
        if not r or not h or h.Health<=0 then error('CHARACTER_UNAVAILABLE',0) end
    end
end
local function waitFor(seconds,predicate)
    local untilTime=os.clock()+seconds
    repeat
        guard()
        if runEnded or (predicate and predicate()) then return true end
        if os.clock()>=untilTime then break end
        task.wait(0.08)
    until false
    return runEnded~=nil or (predicate and predicate()) or false
end
-- The v2 body rotation did not rotate the player's camera. Own the camera only
-- during an interaction, including its acknowledgement window, and update after
-- the game's normal camera callbacks so the custom prompt stays in the center.
releaseAim=function()
    local state=aim
    if state then state.releasing=true end
    local unbound,err=pcall(function() RunService:UnbindFromRenderStep(AIM_BINDING) end)
    if unbound then aimBound=false else cleanupErrors.aim=tostring(err) end
    if state then
        for camera,original in pairs(state.cameras) do
            local ok,restoreError=pcall(function()
                if camera.CameraType==Enum.CameraType.Scriptable then
                    camera.CameraType=original.cameraType
                    camera.Focus=original.focus
                    if original.cameraType==Enum.CameraType.Scriptable then camera.CFrame=original.cframe end
                end
            end)
            if ok then state.cameras[camera]=nil else cleanupErrors.camera=tostring(restoreError) end
        end
        if next(state.cameras)==nil and unbound then
            aim=nil;log('camera_released',{frames=state.frames,prompt=state.path})
        end
    end
    return unbound and aim==nil
end
local function facePrompt(p)
    assert(releaseAim(),'PRIOR_CAMERA_CLEANUP_UNCONFIRMED')
    local state={prompt=p,path=path(p),frames=0,centeredFrames=0,cameras={}}
    aim=state
    local function update()
        if aim~=state or state.releasing or not alive or not running
            or (context and context.IsCancelled and context.IsCancelled()) then return end
        if runEnded or not p:IsDescendantOf(workspace) then releaseAim();return end
        local camera=workspace.CurrentCamera
        local c,root=character()
        local target=promptPosition(p)
        if not camera or not root or not target then state.centeredFrames=0;return end
        if not state.cameras[camera] then
            state.cameras[camera]={cameraType=camera.CameraType,cframe=camera.CFrame,focus=camera.Focus}
        end
        local head=c:FindFirstChild('Head')
        local origin=head and head.Position+Vector3.new(0,0.15,0) or root.Position+Vector3.new(0,1.6,0)
        if (target-origin).Magnitude<0.1 then state.centeredFrames=0;return end
        camera.CameraType=Enum.CameraType.Scriptable
        camera.CFrame=CFrame.lookAt(origin,target)
        camera.Focus=CFrame.new(target)
        local screen,onScreen=camera:WorldToViewportPoint(target)
        local size=camera.ViewportSize
        local dot=camera.CFrame.LookVector:Dot((target-origin).Unit)
        local centered=onScreen and screen.Z>0 and size.X>0 and size.Y>0
            and math.abs(screen.X/size.X-0.5)<0.06 and math.abs(screen.Y/size.Y-0.5)<0.06 and dot>0.995
        state.centeredFrames=centered and state.centeredFrames+1 or 0
        state.frames=state.frames+1
        state.sample={onScreen=onScreen,dot=dot,screen=vec(screen),eye=vec(origin),target=vec(target)}
    end
    local function render()
        local ok,err=pcall(update)
        if not ok then
            state.error=tostring(err)
            releaseAim()
        end
    end
    aimBound=true
    RunService:BindToRenderStep(AIM_BINDING,Enum.RenderPriority.Last.Value+1,render)
    render()
    waitFor(0.8,function() return state.centeredFrames>=3 or state.error~=nil end)
    local ready=aim==state and state.centeredFrames>=3 and not state.error
    log('camera_alignment',{ready=ready,prompt=state.path,sample=state.sample,error=state.error})
    if not ready then releaseAim() end
    return ready
end
local function standPoint(p)
    local c,r,h=character();local target=promptPosition(p)
    if not target then return nil,'PROMPT_POSITION_MISSING' end
    local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances={c};params.RespectCanCollide=true
    local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Exclude
    overlap.FilterDescendantsInstances={c};overlap.RespectCanCollide=true
    local clearance=h.HipHeight+r.Size.Y/2
    local best,bestScore,probe
    local stats={tested=0,floors=0,boundsBlocked=0,exactClear=0,blockedSamples={}}
    local bodySize=Vector3.new(2.2,3.8,2.2)
    local ok,err=pcall(function()
        for _,radius in ipairs({1.75,3,4.5,6}) do
            for index=0,15 do
                stats.tested=stats.tested+1
                local angle=index*math.pi/8
                local offset=Vector3.new(math.cos(angle)*radius,0,math.sin(angle)*radius)
                local hit=workspace:Raycast(target+offset+Vector3.new(0,2,0),Vector3.new(0,-14,0),params)
                if hit and hit.Normal.Y>0.65 then
                    local point=hit.Position+Vector3.new(0,clearance+0.1,0)
                    if (point-target).Magnitude<p.MaxActivationDistance-0.4 then
                        stats.floors=stats.floors+1
                        local colliders=workspace:GetPartBoundsInBox(CFrame.new(point),bodySize,overlap)
                        local clear=true
                        for _,part in ipairs(colliders) do if part.CanCollide then clear=false;break end end
                        if not clear then
                            stats.boundsBlocked=stats.boundsBlocked+1
                            -- Mesh bounding boxes can span empty space; confirm against collision geometry.
                            if not probe then
                                probe=Instance.new('Part');table.insert(ownedInstances,probe);probe.Name='PelicanScrowClearanceProbe'
                                probe.Size=bodySize;probe.Anchored=true;probe.Transparency=1
                                probe.CanCollide=false;probe.CanTouch=false;probe.CanQuery=false
                                probe.Parent=workspace
                            end
                            probe.CFrame=CFrame.new(point)
                            local exact=workspace:GetPartsInPart(probe,overlap);clear=true
                            for _,part in ipairs(exact) do
                                if part~=probe and part.CanCollide then
                                    clear=false
                                    if #stats.blockedSamples<6 then table.insert(stats.blockedSamples,path(part)) end
                                    break
                                end
                            end
                            if clear then stats.exactClear=stats.exactClear+1 end
                        end
                        local score=(point-r.Position).Magnitude+radius*0.1
                        if clear and (not bestScore or score<bestScore) then best,bestScore=point,score end
                    end
                end
            end
        end
    end)
    if probe then
        local destroyed,problem=pcall(function() probe:Destroy() end)
        if destroyed then
            for i=#ownedInstances,1,-1 do if ownedInstances[i]==probe then table.remove(ownedInstances,i);break end end
        else cleanupErrors.probe=tostring(problem);error('CLEARANCE_PROBE_CLEANUP_FAILED',0) end
    end
    stats.prompt=path(p);stats.target=vec(target);stats.chosen=best and vec(best)
    log('standing_search',stats)
    if not ok then error(err,0) end
    return best,best and nil or 'NO_CLEAR_STANDING_POINT'
end

local function approach(p,attempt)
    guard();if runEnded then return false end
    local _,r=character();local target=promptPosition(p)
    if not target then return false end
    if (r.Position-target).Magnitude<=math.min(4,p.MaxActivationDistance-0.5) then return true end
    local point,why=standPoint(p)
    if not point then log('approach_failed',{prompt=path(p),reason=why});error('SCROW_APPROACH_FAILED: '..tostring(why),0) end
    log('move',{prompt=path(p),from=vec(r.Position),to=vec(point)})
    r.CFrame=CFrame.lookAt(point,Vector3.new(target.X,point.Y,target.Z))
    r.AssemblyLinearVelocity=Vector3.zero;r.AssemblyAngularVelocity=Vector3.zero
    waitFor(attempt and attempt>1 and CONFIG.retrySettle or CONFIG.settle)
    if runEnded then return false end
    local _,current=character()
    local distance=(current.Position-target).Magnitude
    log('movement_check',{distance=distance,position=vec(current.Position)})
    if distance>p.MaxActivationDistance-0.1 then error('MOVEMENT_NOT_RETAINED',0) end
    return true
end
local function activate(p,attempt)
    guard();if runEnded or not p.Parent or not p.Enabled then return false end
    if not approach(p,attempt) then return false end
    if not facePrompt(p) or runEnded or not p.Parent or not p.Enabled then releaseAim();return false end
    local fire=env.fireproximityprompt or fireproximityprompt
    local method=attempt>=2 and type(fire)=='function' and 'executor_prompt' or 'native_hold'
    log('interact',{prompt=promptData(p),attempt=attempt,method=method})
    if method=='executor_prompt' then
        local ok,err=pcall(fire,p,p.HoldDuration)
        if not ok then releaseAim();log('prompt_error',tostring(err));return false end
    else
        held=p
        local ok,err=pcall(function() p:InputHoldBegin() end)
        if not ok then release();releaseAim();log('prompt_error',tostring(err));return false end
        waitFor(math.max(0.15,p.HoldDuration+0.2));release()
    end
    return true
end
observe(player.AttributeChanged,function(name)
    if name=='MallDigits' or name=='InMall' or name=='MallDeath' or name=='ChaseLives' or name=='InCase'
        or name=='XP' or name=='Level' or name:lower():find('cash') or name:lower():find('reward') then
        log('player_attribute',{name=name,value=player:GetAttribute(name)})
    end
end)
observe(player.CharacterAdded,function() fatal='RESPAWN_DURING_TEST' end)
local startLives=tonumber(player:GetAttribute('ChaseLives'))
observe(player:GetAttributeChangedSignal('ChaseLives'),function()
    local lives=tonumber(player:GetAttribute('ChaseLives'))
    if startLives and lives and lives<startLives then fatal='LIFE_LOST_DURING_TEST' end
end)
observe(PPS.PromptTriggered,function(p,who)
    if who and who~=player then return end
    log('prompt_triggered',{path=path(p)})
end)
local remotes=RS:FindFirstChild('ChaseRemotes')
for _,entry in ipairs({{remotes,'RunEnded'},{RS,'DropRoll'}}) do
    local folder,name=entry[1],entry[2]
    local remote=folder and folder:FindFirstChild(name)
    if remote and remote:IsA('RemoteEvent') then
        observe(remote.OnClientEvent,function(...)
            local args=table.pack(...)
            log('server_event',{name=name,args=args})
            if name=='RunEnded' then
                runEnded=safe(args);report.runEnded=runEnded
                release();releaseAim()
            end
        end)
    end
end
local function findUI(path)
    local node=pg
    for name in path:gmatch('[^.]+') do node=node and node:FindFirstChild(name) end
    return node
end
local function visible(node)
    if not node or not node:IsDescendantOf(pg) then return false end
    local p=node
    while p and p~=pg do
        if p:IsA('GuiObject') and not p.Visible then return false end
        if p:IsA('LayerCollector') and not p.Enabled then return false end
        p=p.Parent
    end
    return true
end
local KEYPAD='ChaseMallKeypad.Shade.Keypad'
local function display()
    local window=findUI(KEYPAD..'.Window')
    if not window then return nil end
    for _,node in ipairs(window:GetDescendants()) do
        if node:IsA('TextLabel') then return (node.Text:gsub('<[^>]->',''):gsub('%D','')) end
    end
end
local function press(name,ack)
    if ack() then return end
    local button=findUI(KEYPAD..'.Keys.'..name)
    assert(button and visible(button) and button.Active,'KEYPAD_BUTTON_MISSING: '..name)
    local fire=env.firesignal or firesignal
    assert(type(fire)=='function','KEYPAD_FIRESIGNAL_UNAVAILABLE')
    for _,method in ipairs({'Activated','MouseButton1Click'}) do
        guard();if ack() then return end
        log('keypad_click',{button=name,method=method,display=display()})
        local ok,err=pcall(fire,button[method])
        if not ok then log('keypad_input_error',tostring(err)) end
        if waitFor(ok and 1.5 or 0.1,ack) then return end
    end
    error('KEYPAD_INPUT_NOT_ACKNOWLEDGED: '..name,0)
end
local result,opened
local mallFolder=RS:FindFirstChild('ChaseRemotes')
local mallRemote=mallFolder and mallFolder:FindFirstChild('MallCode')
assert(mallRemote and mallRemote:IsA('RemoteEvent'),'MALL_CODE_EVENT_MISSING')
observe(mallRemote.OnClientEvent,function(action,...)
    local args=table.pack(...);log('mall_code',{action=action,args=safe(args)})
    if action=='result' then result=args[1] end
    if action=='opened' then opened=true end
end)
observe(player:GetAttributeChangedSignal('MallDeath'),function() fatal='LIFE_LOST_DURING_TEST' end)
worker=task.defer(function()
    local ok,outcome=pcall(function()
        guard()
        assert(game.PlaceId==129085487311457 and player:GetAttribute('InMall')==true,'NOT_IN_SCROW')
        snapshot('start')
        local list=papers();assert(#list>0,'SCROW_CLUES_NOT_LOADED')
        for i,item in ipairs(list) do assert(i==item.index,'INCOMPLETE_CLUE_INDEX_LIST') end
        local needed=#list
        local processed=0
        while not runEnded and processed<needed do
            guard();local missing={}
            for _,item in ipairs(list) do
                local known=digits():sub(item.index,item.index)
                if not known:match('^%d$') then table.insert(missing,item) end
            end
            if #missing==0 then break end
            local _,root=character()
            table.sort(missing,function(a,b)
                return (promptPosition(a.prompt)-root.Position).Magnitude<(promptPosition(b.prompt)-root.Position).Magnitude
            end)
            local item=missing[1]
            label.Text='Scrow: reading real clue '..item.index..'/'..needed
            local function confirmed()
                local digit=digits():sub(item.index,item.index)
                return digit:match('^%d$')~=nil and (not item.digit or digit==item.digit)
            end
            for attempt=1,3 do
                if confirmed() or runEnded then break end
                activate(item.prompt,attempt)
                waitFor(2.5,confirmed);releaseAim()
            end
            if runEnded then break end
            assert(confirmed(),'CLUE_READ_NOT_CONFIRMED: '..item.index)
            log('clue_confirmed',{index=item.index,digits=digits()});processed=processed+1
        end
        if runEnded then return 'RUN_ENDED_RECEIVED' end
        local code=digits()
        assert(#code==needed and code:match('^%d+$'),'MALL_CODE_INCOMPLETE')
        report.code=code;snapshot('code_complete')
        local exit=workspace:FindFirstChild('MallExit')
        local prompt=exit and exit:FindFirstChild('KeypadPrompt',true)
        assert(prompt and prompt:IsA('ProximityPrompt'),'MALL_KEYPAD_PROMPT_MISSING')
        for attempt=1,3 do
            if visible(findUI(KEYPAD)) or runEnded then break end
            label.Text='Scrow: opening loading-bay keypad'
            activate(prompt,attempt)
            waitFor(2.5,function() return visible(findUI(KEYPAD)) end);releaseAim()
        end
        if runEnded then return 'RUN_ENDED_RECEIVED' end
        assert(visible(findUI(KEYPAD)),'KEYPAD_DID_NOT_OPEN')
        assert(display()~=nil,'KEYPAD_DISPLAY_MISSING')
        press('Key_CLR',function() return display()=='' end)
        for i=1,#code do
            local wanted=code:sub(1,i)
            press('Key_'..code:sub(i,i),function() return display()==wanted end)
            assert(display()==wanted,'KEYPAD_DISPLAY_MISMATCH')
        end
        result=nil;opened=false
        press('Key_ENT',function() return result~=nil or opened or runEnded~=nil end)
        assert(result~=false,'KEYPAD_CODE_REJECTED')
        assert(waitFor(8,function() return opened==true end),'KEYPAD_OPEN_NOT_CONFIRMED')
        -- The capture confirms RunEnded ~3 seconds after code acceptance, without another prompt.
        label.Text='Scrow: exit accepted; waiting for completion'
        assert(waitFor(20,function() return runEnded~=nil end),'SCROW_END_NOT_CONFIRMED')
        return 'RUN_ENDED_RECEIVED'
    end)
    if alive then
        release();releaseAim()
        finish(ok and outcome or tostring(outcome))
    end
end)
print('[PELICAN] Scrow: real clues -> verified keypad -> exit. No anti-death bypass enabled.')


return ctl
]====]
-- Missing-key auto-rejoin disabled for container diagnosis; successful rounds still replay.
local env=type(getgenv)=='function' and getgenv() or _G
local Players=game:GetService('Players')
local Http=game:GetService('HttpService')
local Teleports=game:GetService('TeleportService')
local player=Players.LocalPlayer
assert(player,'Wait for your player to load.')
local pg=player:FindFirstChildOfClass('PlayerGui')
assert(pg,'Wait for PlayerGui to load.')
local GLOBAL='__PELICAN_THRESHOLD_FARM_V6_1'
local CHILD='__PELICAN_THRESHOLD_RUN_V3_1'
local SCROW_CHILD='__PELICAN_THRESHOLD_SCROW_RUN_V1'
for _,key in ipairs({GLOBAL,'__PELICAN_THRESHOLD_FARM_V6','__PELICAN_THRESHOLD_FARM_V5_7','__PELICAN_THRESHOLD_SCROW_PROBE_V1','__PELICAN_THRESHOLD_SCROW_RUN_V1','__PELICAN_THRESHOLD_FARM_V5_6','__PELICAN_THRESHOLD_FARM_V5_5','__PELICAN_THRESHOLD_FARM_V5_4','__PELICAN_THRESHOLD_FARM_V5_3','__PELICAN_THRESHOLD_FARM_V5_2','__PELICAN_THRESHOLD_FARM_V5_1','__PELICAN_THRESHOLD_FARM_V5',CHILD,'__PELICAN_THRESHOLD_TRANSITION_V4','__PELICAN_THRESHOLD_RUN_V3','__PELICAN_THRESHOLD_RUN_V2'}) do
 local old=env[key]
 if type(old)=='table' then
  assert(type(old.destroy)=='function','PRIOR_FARM_HAS_NO_CLEANUP: '..key)
  local ok,result=pcall(old.destroy)
  if ok and type(old.IsStopped)=='function' then
   local checked,stopped=pcall(old.IsStopped);result=checked and stopped==true
  end
  assert(ok and result==true,'PRIOR_FARM_CLEANUP_UNCONFIRMED: '..key)
 end
end
local write=env.writefile or writefile
local copy=env.setclipboard or setclipboard or env.toclipboard or toclipboard
local fire=env.firesignal or firesignal
local CHASE,LOBBY=129085487311457,78453398695059
local report
local savedOK,saved=pcall(resume.GetFarmState)
local restored
if savedOK and type(saved)=='string' then
 local decoded,value=pcall(function() return Http:JSONDecode(saved) end)
 if decoded then restored=value end
end
if type(restored)=='table' and restored.schema=='threshold-farm/6.1'
 and type(restored.token)=='string' and restored.token:match('^[%w_]+$')
 and type(restored.events)=='table' and type(restored.runs)=='table'
 and type(restored.sessions)=='number' and restored.sessions>=0
 and type(restored.completed)=='number' and restored.completed>=0 then
 report=restored
end
report=report or {schema='threshold-farm/6.1',token=tostring(os.time())..'_'..tostring(math.random(100000,999999)),started=os.time(),completed=0,sessions=0,events={},runs={}}
report.sessions=report.sessions+1
local token=report.token
local file='threshold_farm_v6_1_'..token..'.txt'
env[GLOBAL]=ctl
local alive,running=true,true
local connections={}
local uiConnections={}
local ownedInstances={}
local cleanupErrors={}
local checkpointResult={copied=false,written=false,persisted=false}
local worker,gui,label,box,child
local entryHumanoid
local function cancelEntryMovement()
 local h=entryHumanoid
 if not h then return true end
 local ok,err=pcall(function()
  h:Move(Vector3.zero,false)
  local r=h.Parent and h.Parent:FindFirstChild('HumanoidRootPart')
  if r then h:MoveTo(r.Position) end
 end)
 if ok then entryHumanoid=nil else cleanupErrors.movement=tostring(err) end
 return ok
end
local t0=os.clock()
local teleporting=false
local recovering=false
local teleportFailure
report.skipped=report.skipped or 0
report.inputMethods=type(report.inputMethods)=='table' and report.inputMethods or {}
-- Captured reward flow responds to MouseButton1Click, unlike the lobby buttons.
if report.inputMethods['finish reward']==nil then report.inputMethods['finish reward']=2 end
local function log(kind,data)
 table.insert(report.events,{session=report.sessions,t=math.floor((os.clock()-t0)*100)/100,kind=kind,data=data})
 if #report.events>180 then table.remove(report.events,1) end
end
local function find(path)
 local p=pg
 for name in path:gmatch('[^.]+') do p=p and p:FindFirstChild(name) end
 return p
end
local function visible(p)
 if not p or not p:IsDescendantOf(pg) then return false end
 local a=p
 while a and a~=pg do
  if a:IsA('GuiObject') and not a.Visible then return false end
  if a:IsA('LayerCollector') and not a.Enabled then return false end
  if a:IsA('CanvasGroup') and a.GroupTransparency>=0.98 then return false end
  a=a.Parent
 end
 return true
end
local function ready(path)
 local p
 if type(path)=='string' then p=find(path) else p=path end
 if typeof(p)=='Instance' and p:IsA('GuiButton') and visible(p) and p.Active and p.AbsoluteSize.X>1 and p.AbsoluteSize.Y>1 then return p end
end
local function words(p)
 local texts={}
 if p and (p:IsA('TextButton') or p:IsA('TextLabel')) then table.insert(texts,p.Text) end
 if p then for _,d in ipairs(p:GetDescendants()) do if d:IsA('TextLabel') then table.insert(texts,d.Text) end end end
 return table.concat(texts,' '):gsub('<[^>]->',''):gsub('%s+',''):upper()
end
local function screen()
 local out={place=game.PlaceId,attributes=player:GetAttributes(),buttons={},texts={}}
 for _,p in ipairs(pg:GetDescendants()) do
  if not p:IsDescendantOf(gui) and visible(p) then
   if p:IsA('GuiButton') and #out.buttons<80 then
    table.insert(out.buttons,{path=p:GetFullName(),active=p.Active,text=words(p)})
   elseif p:IsA('TextLabel') and p.Text~='' and #out.texts<60 then
    table.insert(out.texts,{path=p:GetFullName(),text=p.Text:sub(1,400)})
   end
  end
 end
 return out
end
local function checkpoint(reason)
 checkpointResult={copied=false,written=false,persisted=false}
 ctl.checkpointResult=checkpointResult
 report.reason=reason;report.place=game.PlaceId
 report.integration={version=ctl.Version,resumeOwner='LOADER',cleanupErrors=cleanupErrors}
 local ok,s=pcall(function() return Http:JSONEncode(report) end)
 if not ok then warn('[PELICAN] Report encoding failed: '..tostring(s));return nil,false end
 ctl.reportText=s
 if type(write)=='function' then checkpointResult.written=pcall(write,file,s) end
 if type(copy)=='function' then checkpointResult.copied=pcall(copy,s) end
 local stored,result=pcall(resume.SaveFarmState,s)
 checkpointResult.persisted=stored and result==true
 if not checkpointResult.persisted then
  report.persistenceError=stored and 'SAVE_FARM_STATE_UNCONFIRMED' or tostring(result)
 end
 ctl.checkpointResult=checkpointResult
 return s,checkpointResult.persisted
end
local function collectChild()
 if child and child.reportText and child.reportText~=ctl.lastChild then
  ctl.lastChild=child.reportText
  local ok,r=pcall(function() return Http:JSONDecode(child.reportText) end)
  if ok then
   if r.preflight and r.preflight.enough==false then
    report.lastShortKeyRound={session=report.sessions,preflight=r.preflight,containerAudit=r.containerAudit,keySearches=r.keySearches}
   end
   if r.preflight and (r.preflight.hiddenKeys or 0)>0 then
    report.lastContainerRound={session=report.sessions,preflight=r.preflight,containerAudit=r.containerAudit,
        containerResults=r.containerResults,outcome=r.outcome,keySearches=r.keySearches}
   end
   if r.schema=='threshold-scrow-run/1.0' or r.schema=='threshold-scrow-run/1.1' then report.lastScrowRun=r end
   table.insert(report.runs,r);if #report.runs>3 then table.remove(report.runs,1) end;return r end
 end
end
local function stopChild()
 -- Also catches an embedded runner whose initialization failed before launchRunner returned.
 if not child then child=env[SCROW_CHILD] or env[CHILD] end
 if child and not child.reportText and type(child.export)=='function' then pcall(child.export) end
 collectChild()
 if child then
  local ok,result=pcall(child.destroy)
  if ok and result==true then child=nil
  else cleanupErrors.child=ok and 'CHILD_CLEANUP_UNCONFIRMED' or tostring(result) end
 end
 return child==nil
end
local function disconnect(list)
 for i=#list,1,-1 do
  local ok,err=pcall(function() list[i]:Disconnect() end)
  if ok then table.remove(list,i) else cleanupErrors.disconnect=tostring(err) end
 end
 return #list==0
end
local function stopWorker()
 local thread=worker
 if thread==coroutine.running() then worker=nil
 elseif thread then
  local dead,st=pcall(coroutine.status,thread)
  if dead and st=='dead' then worker=nil
  else
   local ok,err=pcall(task.cancel,thread)
   if ok then worker=nil else cleanupErrors.worker=tostring(err) end
  end
 end
end
local function notifyStopped(reason)
 if reason=='REEXECUTE' or reason=='TELEPORT' then return true end
 if not disarmed then
  local ok,result=pcall(resume.DisarmFarm,reason)
  disarmed=ok and result==true
  if not disarmed then cleanupErrors.disarm=ok and 'DISARM_UNCONFIRMED' or tostring(result) end
 end
 if not notified and type(context.OnFeatureStopped)=='function' then
  notified=true;pcall(context.OnFeatureStopped,'farm',reason)
 end
 return disarmed
end
local lastStopReason
local function stop(reason)
 reason=tostring(reason or 'FARM_STOPPED')
 lastStopReason=lastStopReason or reason
 running=false;stopRequested=true
 notifyStopped(lastStopReason)
 cancelEntryMovement();stopChild();disconnect(connections);stopWorker()
 if not stopReported then
  stopReported=true;log('stopped',reason)
  local ok,s=pcall(screen);if ok then report.finalScreen=s end
 end
 checkpoint(lastStopReason)
 if label then pcall(function()
  label.Text='STOPPED: '..lastStopReason..'\n'..(checkpointResult.copied and 'COPIED ✓' or (checkpointResult.written and 'File saved' or 'Copy unavailable'))..' | '..report.completed
 end) end
end
cleanupImpl=function(reason)
 stop(reason or 'red_button_stop');alive=false
 disconnect(connections);disconnect(uiConnections)
 for i=#ownedInstances,1,-1 do
  local ok,err=pcall(function() ownedInstances[i]:Destroy() end)
  if ok then table.remove(ownedInstances,i) else cleanupErrors.ui=tostring(err) end
 end
 if #ownedInstances==0 then gui=nil;label=nil end
 cleanupConfirmed=(lastStopReason=='REEXECUTE' or lastStopReason=='TELEPORT' or disarmed)
  and child==nil and worker==nil and entryHumanoid==nil
  and #connections==0 and #uiConnections==0 and #ownedInstances==0
 if cleanupConfirmed and env[GLOBAL]==ctl then env[GLOBAL]=nil end
 return cleanupConfirmed
end
ctl.destroy=function() return ctl.Stop('red_button_stop') end
ctl.GetReport=function()
 checkpoint(report.reason or 'report_requested')
 return ctl.reportText or 'THRESHOLD_FARM_REPORT_UNAVAILABLE'
end
local function connect(sig,fn)
 table.insert(connections,sig:Connect(function(...) if alive and running then fn(...) end end))
end
local function make(class,props,parent)
 local i=Instance.new(class);table.insert(ownedInstances,i);for k,v in pairs(props) do i[k]=v end;i.Parent=parent;return i
end
gui=make('ScreenGui',{Name='PelicanThresholdFarm',ResetOnSpawn=false,DisplayOrder=100004},pg)
-- Keep controls away from the game's top-right lobby buttons.
label=make('TextLabel',{Position=UDim2.fromOffset(5,38),Size=UDim2.fromOffset(255,42),BackgroundTransparency=0.2,BackgroundColor3=Color3.fromRGB(20,23,29),TextColor3=Color3.new(1,1,1),Font=Enum.Font.Code,TextSize=12,TextWrapped=true,Text='THRESHOLD FARM v6.1 | preparing...'},gui)
local red=make('TextButton',{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-6,0,7),Size=UDim2.fromOffset(20,20),Text='',BackgroundColor3=Color3.fromRGB(228,53,62)},gui)
make('UICorner',{CornerRadius=UDim.new(1,0)},red)
local export=make('TextButton',{Position=UDim2.fromOffset(5,82),Size=UDim2.fromOffset(100,24),Text='COPY REPORT',TextSize=11,BackgroundColor3=Color3.fromRGB(37,105,85),TextColor3=Color3.new(1,1,1)},gui)
-- UI controls stay usable after a recoverable stop; destroy disconnects these too.
if context.CentralKillSwitch then red.Visible=false end
local function connectUI(signal,fn)
 table.insert(uiConnections,signal:Connect(function(...)
  if not alive then return end
  local ok,err=pcall(fn,...)
  if not ok then cleanupErrors.uiCallback=tostring(err) end
 end))
end
connectUI(red.Activated,ctl.destroy)
connectUI(export.Activated,function()
 checkpoint(report.reason or 'manual_copy')
 export.Text=checkpointResult.copied and 'COPIED ✓' or (checkpointResult.written and 'FILE SAVED' or 'COPY FAILED')
end)
local function check()
 if not alive or not running or stopRequested or context.IsCancelled() then error('STOPPED',0) end
end
local function waitUntil(seconds,predicate,description)
 local deadline=os.clock()+seconds
 repeat
  check()
  if predicate() then return true end
  if os.clock()>=deadline then return false end
  if description then label.Text=description..'\nCompleted: '..report.completed end
  task.wait(0.15)
 until false
end
-- Prefer the input previously acknowledged for this step, across teleports.
-- Retry other signals and virtual input only if the UI does not change.
-- Each attempt must be acknowledged by a DIFFERENT game UI state.
local function trigger(button,method)
 if method<=2 then
  assert(type(fire)=='function','FIRESIGNAL_UNAVAILABLE')
  if method==1 then fire(button.Activated) else fire(button.MouseButton1Click) end
 else
  local vi=game:GetService('UserInputService'):CreateVirtualInput()
  local pos=button.AbsolutePosition+button.AbsoluteSize/2
  local ok,err=pcall(function()
   vi:SendMouseButton(pos,Enum.UserInputType.MouseButton1,true,0)
   vi:SendMouseButton(pos,Enum.UserInputType.MouseButton1,false,0)
  end)
  if not ok then pcall(function() vi:SendMouseButton(pos,Enum.UserInputType.MouseButton1,false,0) end);error(err) end
 end
end
local function clickStep(name,getButton,ack,seconds)
 if ack() then return end
 assert(waitUntil(seconds or 25,function() return ready(getButton())~=nil or ack() end,'Waiting: '..name),'UI_MISSING: '..name)
 if ack() then return end
 local preferred=report.inputMethods[name]
 if preferred~=1 and preferred~=2 and preferred~=3 then preferred=1 end
 local methods={preferred}
 for m=1,3 do if m~=preferred then table.insert(methods,m) end end
 for _,method in ipairs(methods) do
  check();if ack() then return end
  local b=ready(getButton())
  if b then
   log('click',{step=name,path=b:GetFullName(),method=method})
   local ok,err=pcall(trigger,b,method)
   if not ok then log('input_error',tostring(err)) end
   if waitUntil(ok and 5 or 0.2,ack,'Waiting for '..name) then
    if ok then report.inputMethods[name]=method end
    log('ui_ack',{step=name,method=method});checkpoint(name);return
   end
  else
   if waitUntil(8,ack,'Waiting for '..name) then checkpoint(name);return end
   break
  end
 end
 error('UI_NOT_ACKNOWLEDGED: '..name,0)
end
local P={continue='ChaseMallChoice.Panel.Continue',claim='ChaseMallChoice.Panel.Claim',reward='DropRollUI.Stage.Reward.Go',home='ChaseSpectate.Root.Panel.Lobby',notice='DevNotice.Card.Close',start='LobbyMenu.Dock.Stage.Rail.Start.Button',tab='LobbyBrowser.Holder.Stage.Page.ChaseTab',create='LobbyBrowser.Holder.Stage.Page.Create',solo='LobbyBrowser.Holder.Stage.ChaseSetup.Card.Seats1',confirm='ChaseSelect.Stage.Confirm',list='LobbyBrowser.Holder.Stage.Page.List'}
local function getter(path) return function() return find(path) end end
local function ownStart()
 local list=find(P.list);local matches={}
 if list then for _,b in ipairs(list:GetDescendants()) do
  if b:IsA('GuiButton') and ready(b) and words(b)=='STARTCHASE' then table.insert(matches,b) end
 end end
 assert(#matches<=1,'MULTIPLE_START_CHASE_BUTTONS')
 return matches[1]
end
local function createIsChase() local b=ready(P.create);return b and words(b):find('CREATECHASELOBBY',1,true)~=nil end
local function lobby()
 assert(waitUntil(45,function() return ready(P.notice) or ready(P.start) or ready(P.tab) or ready(P.solo) or ready(P.confirm) or ownStart() end,'Waiting for lobby UI...'),'LOBBY_LOAD_TIMEOUT')
 if ready(P.notice) then clickStep('close notice',getter(P.notice),function() return not visible(find(P.notice)) end) end
 if not ownStart() and not ready(P.confirm) and not ready(P.solo) then
  clickStep('open lobby browser',getter(P.start),function() return ready(P.tab)~=nil end)
  clickStep('select Chase',getter(P.tab),createIsChase)
  clickStep('create Chase lobby',getter(P.create),function() return ready(P.solo)~=nil or ready(P.confirm)~=nil end)
 end
 if not ownStart() and not ready(P.confirm) then
  clickStep('solo seat',getter(P.solo),function() return ready(P.confirm)~=nil end)
 end
 if not ownStart() then
  -- The recorded solo flow used the default Chase selection, which arrived at
  -- map eli. Validate the actual destination map again before starting movement.
  clickStep('confirm Chase',getter(P.confirm),function() return ownStart()~=nil end)
 end
 clickStep('start Chase',ownStart,function() return teleporting end,30)
 assert(waitUntil(60,function() return false end,'Teleporting into Chase...'),'CHASE_TELEPORT_TIMEOUT')
end
local function endingVisible() return ready(P.continue) or ready(P.reward) or ready(P.home) end
local function scrowBodyReady()
 local c=player.Character;local r=c and c:FindFirstChild('HumanoidRootPart');local h=c and c:FindFirstChildOfClass('Humanoid')
 return player:GetAttribute('InMall')==true and r and r.Position.Y<-120
  and not r.Anchored and h and h.Health>0 and not h.Sit
  and math.abs(r.AssemblyLinearVelocity.Y)<5
end
local function scrowTalking()
 if player:GetAttribute('ScrowIntro')=='done' then return true end
 local code=player:GetAttribute('MallDigits')
 if type(code)=='string' and code:find('%d') then return true end
 local line=find('ScrowSubtitle.Line')
 -- The intro-arrival remote fires before the player walks inside; wait for actual speech.
 return line and visible(line) and line:IsA('TextLabel')
  and line.Text:gsub('<[^>]->',''):match('^%s*Scrow%s*:')~=nil
end
local function scrowReady()
 return scrowBodyReady() and scrowTalking()
  and workspace:FindFirstChild('MallCode') and workspace:FindFirstChild('MallExit')
end
local function enterScrow()
 local steadySince,lastLandingPosition
 assert(waitUntil(60,function()
  if scrowReady() then return true end
  local c=player.Character;local r=c and c:FindFirstChild('HumanoidRootPart')
  if scrowBodyReady() and r.Position.Y<-140 then
   local position=r.Position
   if lastLandingPosition then
    local dx=position.X-lastLandingPosition.X;local dy=position.Y-lastLandingPosition.Y;local dz=position.Z-lastLandingPosition.Z
    if dx*dx+dy*dy+dz*dz>0.5625 then steadySince=nil end
   end
   lastLandingPosition=position;steadySince=steadySince or os.clock()
  else steadySince=nil;lastLandingPosition=nil end
  return steadySince and os.clock()-steadySince>=0.4
 end,'Scrow: waiting to land...'),'SCROW_LANDING_TIMEOUT')
 if scrowReady() then return end
 local c=player.Character;local root=c and c:FindFirstChild('HumanoidRootPart');local humanoid=c and c:FindFirstChildOfClass('Humanoid')
 assert(root and humanoid,'SCROW_CHARACTER_MISSING')
 -- Grounded by the successful manual run: arrival (172,-146.84,-88),
 -- then the open concourse at (178.65,-146.80,-40.91) where the intro plays.
 local destination=Vector3.new(178.65,root.Position.Y,-40.91)
 entryHumanoid=humanoid
 log('scrow_entry_walk',{from={root.Position.X,root.Position.Y,root.Position.Z},to={destination.X,destination.Y,destination.Z}})
 local lastCommand=-math.huge
 local entered=waitUntil(12,function()
  if scrowReady() then return true end
  if not scrowBodyReady() then return false end
  if os.clock()-lastCommand>=1 then
   lastCommand=os.clock();humanoid:MoveTo(destination)
  end
  return false
 end,'Scrow: walking inside until he starts talking...')
 cancelEntryMovement()
 assert(entered,'SCROW_SPEECH_NOT_STARTED')
 log('scrow_early_start',{intro=player:GetAttribute('ScrowIntro'),subtitle=find('ScrowSubtitle.Line') and find('ScrowSubtitle.Line').Text})
 checkpoint('scrow_early_start')
end

local function launchRunner(source,global,ui)
 assert(stopChild(),'PRIOR_RUNNER_CLEANUP_UNCONFIRMED');ctl.lastChild=nil
 local launch,err=loadstring(source);assert(launch,err)
 local ok,result=pcall(launch,context)
 child=env[global]
 assert(ok,result);assert(child and result==child,'RUNNER_NOT_CREATED: '..global)
 local childGUI=pg:FindFirstChild(ui);if childGUI then childGUI.Enabled=false end
end
local function chase()
 assert(waitUntil(60,function()
  if endingVisible() or player:GetAttribute('InMall')==true then return true end
  local w=workspace:FindFirstChild('ChaseWorld');local g=w and w:FindFirstChild('ExitGate')
  local c=player.Character;local r=c and c:FindFirstChild('HumanoidRootPart');local h=c and c:FindFirstChildOfClass('Humanoid')
  return player:GetAttribute('InCase')==true and player:GetAttribute('ChaseMap')~=nil and g and g:GetAttribute('RunStarted')==true and r and not r.Anchored and h and h.Health>0 and not h.Sit
 end,'Waiting for Chase to load...'),'ROUND_LOAD_TIMEOUT')
 assert(player:GetAttribute('ChaseMap')=='eli','WRONG_CHASE_MAP')
 local stage=player:GetAttribute('InMall')==true and 'scrow_wait' or 'eli'
 local scrowFinished=false;local lifeRestarts=0
 if stage=='eli' and not endingVisible() then launchRunner(RUN_SOURCE,CHILD,'PelicanThresholdRun') end
 local start=os.clock();local counted=false
 while running and os.clock()-start<480 do
  check()
  local result=collectChild()
  if result and result.outcome~='RUN_ENDED_RECEIVED' and not endingVisible() then
   local reason=tostring(result.outcome)
   local death=reason:find('LIFE_LOST_DURING_TEST',1,true) or reason:find('RESPAWN_DURING_TEST',1,true)
   if stage=='scrow' and death and player:GetAttribute('InMall')==true and (tonumber(player:GetAttribute('ChaseLives')) or 0)>0 then
    assert(stopChild(),'PRIOR_RUNNER_CLEANUP_UNCONFIRMED');lifeRestarts=lifeRestarts+1;report.scrowDeaths=(report.scrowDeaths or 0)+1
    assert(lifeRestarts<=6,'SCROW_RECOVERY_LIMIT')
    log('scrow_life_recovery',{lives=player:GetAttribute('ChaseLives'),digits=player:GetAttribute('MallDigits')})
    checkpoint('scrow_life_recovery')
    -- Wait for the death transition; never rewrite health/lives or suppress game events.
    waitUntil(3,function() return false end,'Scrow: waiting after life loss...')
    stage='scrow_wait'
   elseif reason:find('MISSING_KEY_',1,true) then
    error('MISSING_KEY_PAUSED: '..reason..' | automatic missing-key rejoin is OFF',0)
   else error('RUN_STOPPED: '..reason,0) end
  elseif result and stage=='scrow' and result.outcome=='RUN_ENDED_RECEIVED' then
   scrowFinished=true;stage='ending';checkpoint('scrow_completed')
  end
  if ready(P.continue) and player:GetAttribute('InMall')~=true then
   assert(stopChild(),'PRIOR_RUNNER_CLEANUP_UNCONFIRMED')
   clickStep('continue to Scrow',getter(P.continue),function() return player:GetAttribute('InMall')==true end)
   stage='scrow_wait';checkpoint('entered_scrow')
  end
  if player:GetAttribute('InMall')==true and stage=='scrow_wait' then
   assert(stopChild(),'PRIOR_RUNNER_CLEANUP_UNCONFIRMED');stage='scrow_wait'
   enterScrow()
   launchRunner(SCROW_SOURCE,SCROW_CHILD,'PelicanScrowRun');stage='scrow'
   log('scrow_started',{digits=player:GetAttribute('MallDigits'),lives=player:GetAttribute('ChaseLives')})
  end
  if ready(P.reward) then
   assert(words(find(P.reward))=='LOBBY' or words(find(P.reward))=='CONTINUE','UNEXPECTED_REWARD_BUTTON')
   clickStep('finish reward',getter(P.reward),function() return teleporting or not visible(find(P.reward)) end)
  elseif ready(P.home) and not visible(find('DropRollUI.Stage')) then
   local b=find(P.home)
   clickStep('return to lobby',getter(P.home),function()
    return teleporting or not ready(b) or visible(find('DropRollUI.Stage'))
   end)
  end
  if player:GetAttribute('ChaseOut')==true and not counted and scrowFinished then
   counted=true
   report.completed=report.completed+1;log('round_completed',report.completed);checkpoint('round_completed')
  end
  if teleporting then
   stopChild();checkpoint('returning_to_lobby')
   assert(waitUntil(60,function() return false end,'Returning to lobby...'),'LOBBY_TELEPORT_TIMEOUT')
  end
  label.Text='Eli + Scrow | '..stage..'\nCompleted: '..report.completed..' | Scrow lives lost: '..(report.scrowDeaths or 0)
  task.wait(0.25)
 end
 error('ROUND_OR_END_UI_TIMEOUT',0)
end

worker=task.defer(function()
 local ok,err=pcall(function()
  check()
  assert(game.PlaceId==CHASE or game.PlaceId==LOBBY,'UNSUPPORTED_PLACE')
  assert(resume.Enabled()==true,'LOADER_TELEPORT_RESUME_UNAVAILABLE')
  assert(resume.GetSelection().farm==true,'THRESHOLD_FARM_NOT_SELECTED')
  local _,persisted=checkpoint('loader_resume_prepared')
  assert(persisted,'LOADER_FARM_STATE_SAVE_FAILED')
  connect(player.OnTeleport,function(state,destination)
   log('teleport',{state=tostring(state),destination=destination})
   if state==Enum.TeleportState.Failed then
    teleporting=false;teleportFailure='OnTeleport.Failed'
    if recovering then checkpoint('recovery_teleport_failed') else ctl.Stop('TELEPORT_FAILED') end
    return
   end
   if destination~=CHASE and destination~=LOBBY then ctl.Stop('UNEXPECTED_TELEPORT_DESTINATION');return end
   teleporting=true;cancelEntryMovement();stopChild();checkpoint('teleport')
  end)
  connect(Teleports.TeleportInitFailed,function(who,result,message,destination)
   if who~=player then return end
   log('teleport_init_failed',{result=tostring(result),message=tostring(message),destination=destination})
   teleporting=false;teleportFailure=tostring(result)..': '..tostring(message)
   if recovering then checkpoint('recovery_teleport_failed') else ctl.Stop('TELEPORT_INIT_FAILED') end
  end)
  log('session_ready',{place=game.PlaceId,firesignal=type(fire)=='function'})
  if game.PlaceId==LOBBY then lobby() else chase() end
 end)
 if not ok and alive and running then ctl.Stop(tostring(err)) end
end)
print('[PELICAN] Farm v6.1: Eli keys + Continue + Scrow clues/keypad + reward + solo replay. Red dot fully stops it.')

return ctl
