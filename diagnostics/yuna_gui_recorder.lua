-- PELICAN Yuna GUI interaction recorder. Observes only; no input simulation,
-- callback invocation, remote requests, hooks, keylogging or TextBox values.
local options=... or {}
assert(type(options)=='table','Recorder options must be a table')
local Players,Run,Input=game:GetService('Players'),game:GetService('RunService'),game:GetService('UserInputService')
local me=assert(Players.LocalPlayer,'LocalPlayer required')
assert(game.PlaceId==82866880824588,'Observed FF3 live place required')
local pg=assert(me:FindFirstChildOfClass('PlayerGui'),'PlayerGui required')
local env=type(getgenv)=='function' and getgenv() or _G
local KEY='PELICAN_YUNA_GUI_RECORDER'
if env[KEY] then assert(type(env[KEY].Stop)=='function' and env[KEY].Stop('REPLACED')==true,'Previous recorder cleanup unconfirmed') end
local duration,waitTimeout=options.Duration or 180,options.WaitTimeout or 180
assert(type(duration)=='number' and duration>=5 and duration<=600,'Duration must be 5 to 600 seconds')
assert(type(waitTimeout)=='number' and waitTimeout>=5 and waitTimeout<=600,'WaitTimeout must be 5 to 600 seconds')
local controller={Version='PELICAN_YUNA_GUI_RECORDER_V2',IsStopped=false}
local started,endedAt,captureStart=os.clock()
local recording,clean,picking=true,false,false
local selected,generation,quietSince=nil,0,started
local dataConnections,uiConnections,rootConnections={}, {},{}
local buttonGroups,nodeIds={},setmetatable({}, {__mode='k'})
local lastProperties={}
local boundCount,events,nodes,roots=0,{}, {},{}
local pending,gestures,recentGestures={},{},{}
local queue,index,scanSeen={},1,{}
local containers,capabilities={},{}
local core,hidden,candidate,outline,pickButton
local hitCapabilities={}
local inset='UNAVAILABLE'
pcall(function() local point=game:GetService('GuiService'):GetGuiInset();inset=point.X..','..point.Y end)
local discoveryCapped=false
local gui,status,panel,box,pageLabel
local page,sequence,lastScan,lastSave,lastPrune=1,0,-math.huge,-math.huge,-math.huge
local dirty,readyHint,fatal,finishReason=true,false,'NONE','NONE'
local pickMisses=0
local copyResult,fileResult,jsonResult='NOT_REQUESTED','NOT_REQUESTED','NOT_REQUESTED'
local finish,save,snapshot,selectRoot,render
local function safe(v,n) return tostring(v):gsub('[\r\n|]',' '):sub(1,n or 140) end
local function is(o,k) return typeof(o)=='Instance' and o:IsA(k) end
local function sensitive(o)
    for _=1,6 do
        if not o then break end
        local name=o.Name:lower()
        for _,word in ipairs({'password','token','secret','license','authentication','keyinput','keybox'}) do
            if name:find(word,1,true) then return true end
        end
        o=o.Parent
    end
    return false
end
local function label(o)
    if is(o,'TextBox') or sensitive(o) then return '[REDACTED]' end
    if is(o,'TextLabel') or is(o,'TextButton') then
        local value=o.Text:gsub('<[^>]*>','')
        local lower=value:lower()
        if lower:find('license key',1,true) or lower:find('password',1,true) or lower:find('access token',1,true) then return '[REDACTED]' end
        return safe(value,100)
    end
end
local function own(o) return gui and (o==gui or o:IsDescendantOf(gui)) end
local function rootOf(o)
    for _=1,32 do if not o then return end;if is(o,'ScreenGui') then return o end;o=o.Parent end
end
local function gameMenu(root)
    if not root or not root:IsDescendantOf(pg) or root.Name~='LoadingScreen' then return false end
    local frame=root:FindFirstChild('Frame')
    return frame and frame:FindFirstChild('Play') and frame:FindFirstChild('Practice') and frame:FindFirstChild('Pro')
end
local function visible(o)
    if not o or not o.Parent then return false end
    for _=1,32 do
        if not o then return true end
        if is(o,'GuiObject') and not o.Visible or is(o,'LayerCollector') and not o.Enabled then return false end
        o=o.Parent
    end
    return false
end
local function belongs(o) return selected and o and (o==selected or o:IsDescendantOf(selected)) end
local function disconnect(list)
    local remaining={}
    for _,c in ipairs(list) do if not pcall(function() c:Disconnect() end) then remaining[#remaining+1]=c end end
    return remaining
end
local function node(o)
    if not o or not belongs(o) then return end
    if nodeIds[o] then return nodeIds[o] end
    if #nodes>=1500 then error('CONTROL_ID_LIMIT') end
    local path,at={},o
    for _=1,24 do
        if at==selected then break end
        local parent=at.Parent;if not parent then return end
        local ordinal,total=0,0
        for _,sibling in ipairs(parent:GetChildren()) do
            if sibling.Name==at.Name and sibling.ClassName==at.ClassName then
                total=total+1;if sibling==at then ordinal=total end
            end
        end
        table.insert(path,1,{name=at.Name:sub(1,256),nameTruncated=#at.Name>256,class=at.ClassName,index=ordinal,count=total})
        at=parent
    end
    if at~=selected then error('CONTROL_PATH_DEPTH_LIMIT') end
    local id=#nodes+1
    local item={id=id,generation=generation,class=o.ClassName,name=safe(o.Name,80),path=path,label=label(o)}
    if is(o,'ImageButton') or is(o,'ImageLabel') then item.image=type(o.Image)=='string' and o.Image:match('^rbxassetid://%d+$') or 'NON_ASSET_URL' end
    nodes[id]=item;nodeIds[o]=id;dirty=true;return id
end
local function event(kind,value)
    if not recording then return end
    if #events>=500 then error('EVENT_LIMIT') end
    sequence=sequence+1
    value=value or {};value.seq=sequence;value.kind=kind;value.t=math.floor((os.clock()-started)*1000+.5)/1000;value.generation=generation
    events[#events+1]=value;dirty=true;return value
end
local function color(c) return c and string.format('%.3f,%.3f,%.3f',c.R,c.G,c.B) end
local function dimensions(v)
    return {xs=v.X.Scale,xo=v.X.Offset,ys=v.Y.Scale,yo=v.Y.Offset}
end
local function properties(o)
    local p={}
    if is(o,'GuiObject') then
        p.visible=o.Visible;p.background=color(o.BackgroundColor3);p.backgroundTransparency=o.BackgroundTransparency
        p.position=dimensions(o.Position);p.size=dimensions(o.Size);p.rotation=o.Rotation
    end
    if is(o,'TextLabel') or is(o,'TextButton') then p.text=label(o);p.textColor=color(o.TextColor3) end
    if is(o,'ImageLabel') or is(o,'ImageButton') then
        p.image=type(o.Image)=='string' and o.Image:match('^rbxassetid://%d+$') or 'NON_ASSET_URL';p.imageColor=color(o.ImageColor3)
    end
    if is(o,'UIStroke') then p.color=color(o.Color);p.enabled=o.Enabled end
    return p
end
local function propertySignature(p)
    local values={}
    for _,key in ipairs({'visible','text','background','backgroundTransparency','textColor','image','imageColor','color','enabled','rotation'}) do
        values[#values+1]=key..'='..tostring(p[key])
    end
    for _,key in ipairs({'position','size'}) do
        local v=p[key];if v then values[#values+1]=key..'='..v.xs..','..v.xo..','..v.ys..','..v.yo end
    end
    return table.concat(values,';')
end
snapshot=function(target,phase,action)
    if not recording or not belongs(target) then return end
    -- Local control neighbourhood only; never dump a whole Yuna page or any
    -- TextBox value. Layout/style observations are evidence, not toggle truth.
    local scope=target
    for _=1,3 do
        if not scope.Parent or scope.Parent==selected then break end
        scope=scope.Parent
        local hasLabel=false
        for _,sibling in ipairs(scope:GetChildren()) do if is(sibling,'TextLabel') or is(sibling,'TextButton') then hasLabel=true;break end end
        if hasLabel then break end
    end
    local work={scope};local at,states=1,{}
    while at<=#work and at<=24 do
        local o=work[at];at=at+1
        if belongs(o) and not is(o,'TextBox') then
            if is(o,'GuiObject') or is(o,'UIStroke') then
                local id,p=node(o),properties(o);local signature=propertySignature(p)
                if lastProperties[id]~=signature then lastProperties[id]=signature;states[#states+1]={id=id,props=p} end
            end
            local children=o:GetChildren()
            for _,child in ipairs(children) do if #work<24 then work[#work+1]=child end end
        end
    end
    event('STATE',{action=action,phase=phase,target=node(target),nodes=states,truncated=#work>=24})
end
local function later(target,action)
    for _,p in ipairs(pending) do if p.action==action then p.target=target;p.at=os.clock();p.step=1;return end end
    if #pending>=12 then table.remove(pending,1) end
    pending[#pending+1]={target=target,action=action,at=os.clock(),step=1}
end
local function connect(list,signal,fn)
    local c=signal:Connect(function(...)
        if not recording and list~=uiConnections then return end
        local ok,err=pcall(fn,...)
        if not ok then fatal=safe(err,350);if finish then finish('RUNTIME_ERROR') end end
    end)
    list[#list+1]=c;return c
end
local function observeButton(button)
    if buttonGroups[button] or not belongs(button) then return end
    if boundCount>=512 then error('BUTTON_LISTENER_LIMIT') end
    local group={};buttonGroups[button]=group;boundCount=boundCount+1
    node(button)
    local function clicked(kind)
        if not recording or not belongs(button) or not visible(button) then return end
        local action
        for _,g in pairs(gestures) do if g.target==button or g.target:IsDescendantOf(button) then action=g.action end end
        if not action then for i=#recentGestures,1,-1 do
            local g=recentGestures[i]
            if os.clock()-g.last<=.5 and (g.target==button or g.target:IsDescendantOf(button)) then action=g.action;break end
        end end
        local e=event(kind,{target=node(button),action=action})
        if not action then snapshot(button,'SIGNAL_OBSERVED',e.seq) end
        later(button,action or e.seq)
    end
    connect(group,button.Activated,function() clicked('GUI_ACTIVATED') end)
    connect(group,button.MouseButton1Click,function() clicked('MOUSE1_CLICK') end)
end
local function enqueue(o)
    if scanSeen[o] then return end
    if #queue>=8000 then
        if selected then error('SCAN_QUEUE_LIMIT') end
        discoveryCapped=true;return
    end
    scanSeen[o]=true;queue[#queue+1]=o
end
local function clearBindings()
    rootConnections=disconnect(rootConnections)
    for o,group in pairs(buttonGroups) do
        local remaining=disconnect(group)
        if #remaining==0 then buttonGroups[o]=nil;boundCount=boundCount-1 else buttonGroups[o]=remaining end
    end
    return #rootConnections==0 and boundCount==0
end
selectRoot=function(root,source)
    assert(is(root,'ScreenGui') and root.Parent and not own(root),'Select a live Yuna ScreenGui')
    assert(not gameMenu(root),'FF3 LoadingScreen is game UI, not Yuna')
    candidate=nil;if outline then outline.Visible=false end;if pickButton then pickButton.Text='PICK' end
    if selected==root then picking=false;return true end
    assert(clearBindings(),'Old Yuna observer cleanup unconfirmed')
    selected=root;generation=generation+1;quietSince=os.clock();readyHint=false;picking=false
    captureStart=captureStart or os.clock()
    roots[#roots+1]={generation=generation,name=safe(root.Name,100),class=root.ClassName,source=source,parentClass=root.Parent.ClassName,
        ignoreGuiInset=root.IgnoreGuiInset,displayOrder=root.DisplayOrder}
    nodeIds=setmetatable({}, {__mode='k'});pending={};gestures={};recentGestures={};queue={};index=1;scanSeen={}
    event('ROOT_SELECTED',{source=source,name=safe(root.Name,100)})
    enqueue(root)
    connect(rootConnections,root.DescendantAdded,function(o) quietSince=os.clock();readyHint=false;enqueue(o) end)
    return true
end
local function addContainer(o,name)
    if not is(o,'Instance') then capabilities[#capabilities+1]=name..'=UNAVAILABLE';return end
    for _,existing in ipairs(containers) do if existing==o then return end end
    containers[#containers+1]=o;capabilities[#capabilities+1]=name..'='..o.ClassName
end
addContainer(pg,'PlayerGui')
local coreOK,coreValue=pcall(function() return game:GetService('CoreGui') end);if coreOK then core=coreValue;addContainer(core,'CoreGui') end
if type(gethui)=='function' then local ok,value=pcall(gethui);if ok and is(value,'Instance') then hidden=value;addContainer(value,'gethui') else capabilities[#capabilities+1]='gethui=FAILED' end
else capabilities[#capabilities+1]='gethui=UNAVAILABLE' end
local function layer(root)
    if hidden and (root==hidden or root:IsDescendantOf(hidden)) then return 3,'EXECUTOR_UI' end
    if core and root:IsDescendantOf(core) then return 2,'CORE_GUI' end
    if root:IsDescendantOf(pg) then return 1,'PLAYER_GUI' end
    return 0,'OTHER'
end
local function hit(input)
    local candidates,seen={},{}
    local point=input.Position
    local supported=0
    for i,container in ipairs(containers) do
        local ok,result=false,'DISCOVERY_ONLY_CONTAINER'
        if not is(container,'Folder') then ok,result=pcall(function() return container:GetGuiObjectsAtPosition(point.X,point.Y) end) end
        if ok and type(result)=='table' then
            hitCapabilities[i]=container.ClassName..'=OK; hits='..#result
            supported=supported+1
            for rank,o in ipairs(result) do
                if not seen[o] and is(o,'GuiObject') and visible(o) then
                    seen[o]=true;local root=rootOf(o)
                    if root then
                        local tier,scope=layer(root)
                        candidates[#candidates+1]={object=o,tier=tier,scope=scope,rank=rank,api=i}
                    end
                end
            end
        elseif result=='DISCOVERY_ONLY_CONTAINER' then hitCapabilities[i]=container.ClassName..'=DISCOVERY_ONLY; use ancestor hit API'
        else hitCapabilities[i]=container.ClassName..'=FAILED; '..safe(result,180) end
    end
    if supported==0 then error('GUI_HIT_TEST_UNAVAILABLE; cannot identify touches reliably') end
    -- CoreGui and PlayerGui display-order values are not comparable. Preserve
    -- each API's own hit order; prefer the executor's actual container, then
    -- CoreGui, before considering PlayerGui behind them.
    table.sort(candidates,function(a,b)
        if a.tier~=b.tier then return a.tier>b.tier end
        if a.api~=b.api then return a.api<b.api end
        return a.rank<b.rank
    end)
    if picking then
        local listed={}
        for _,entry in ipairs(candidates) do
            local root=rootOf(entry.object)
            if root and not own(entry.object) and not listed[root] then
                listed[root]=true
                event('PICK_HIT',{reason=entry.scope..' root='..safe(root.Name,100)..' displayOrder='..tostring(root.DisplayOrder)
                    ..' target='..entry.object.ClassName..':'..safe(entry.object.Name,80)..' label='..(label(entry.object) or '')})
            end
        end
    end
    for _,entry in ipairs(candidates) do
        if own(entry.object) then return nil,'OWN_HUD' end
        if picking and gameMenu(rootOf(entry.object)) then
            event('PICK_REJECTED',{reason='FF3_LOADING_SCREEN; not Yuna'})
            return nil,'GAME_MENU'
        end
        if picking or belongs(entry.object) then return entry.object end
        -- Another GUI is in front: do not attribute its input to Yuna below it.
        return nil,'OTHER_GUI'
    end
    return nil,'NO_HIT'
end
local function inputType(input)
    local name=tostring(input.UserInputType)
    return name:match('([^%.]+)$')
end
local function coordinates(input,target)
    local p,s=target.AbsolutePosition,target.AbsoluteSize
    return {x=math.floor(input.Position.X+.5),y=math.floor(input.Position.Y+.5),
        u=s.X>0 and (input.Position.X-p.X)/s.X or 0,v=s.Y>0 and (input.Position.Y-p.Y)/s.Y or 0}
end
local function beginInput(input)
    if not selected and not picking then return end
    local kind=inputType(input)
    if kind~='Touch' and kind~='MouseButton1' then return end
    local target,why=hit(input)
    if not target then
        if picking and why=='GAME_MENU' then
            candidate=nil;if outline then outline.Visible=false end;if pickButton then pickButton.Text='PICK' end
            status.Text='GAME UI'
        end
        if picking and why=='NO_HIT' then
            pickMisses=pickMisses+1;event('PICK_MISS',{reason='No GUI object returned at tap',point={x=math.floor(input.Position.X),y=math.floor(input.Position.Y),u=0,v=0}})
            if pickMisses>=3 then error('GUI_PICK_NO_HIT_AFTER_THREE_TAPS') end
        end
        return
    end
    if picking then
        candidate={root=rootOf(target),target=target}
        if outline then
            outline.Position=UDim2.fromOffset(target.AbsolutePosition.X,target.AbsolutePosition.Y)
            outline.Size=UDim2.fromOffset(math.max(8,target.AbsoluteSize.X),math.max(8,target.AbsoluteSize.Y));outline.Visible=true
        end
        if pickButton then pickButton.Text='USE' end
        status.Text='CHECK BOX'
        event('PICK_CANDIDATE',{reason='Confirm outlined Yuna control; root='..safe(candidate.root.Name,100)})
        return
    end
    if not belongs(target) then return end
    local count=0;for _ in pairs(gestures) do count=count+1 end;if count>=4 then return end
    local e=event('POINTER_BEGIN',{target=node(target),input=kind,point=coordinates(input,target)})
    local key=kind=='Touch' and input or 'MOUSE'
    gestures[key]={target=target,id=e.target,action=e.seq,last=os.clock(),moves=0}
    snapshot(target,'INPUT_OBSERVED',e.seq);later(target,e.seq)
end
local function moveInput(input)
    local kind=inputType(input);local key=kind=='Touch' and input or kind=='MouseMovement' and 'MOUSE'
    local g=key and gestures[key]
    if not g or not belongs(g.target) or g.moves>=20 or os.clock()-g.last<.1 then return end
    g.moves=g.moves+1;g.last=os.clock()
    event('POINTER_MOVE',{action=g.action,target=node(g.target),point=coordinates(input,g.target)})
end
local function endInput(input)
    local kind=inputType(input);local key=kind=='Touch' and input or kind=='MouseButton1' and 'MOUSE'
    local g=key and gestures[key];if not g then return end;gestures[key]=nil
    if not belongs(g.target) then event('POINTER_END',{action=g.action,target=g.id,detached=true});return end
    g.last=os.clock();recentGestures[#recentGestures+1]=g;if #recentGestures>4 then table.remove(recentGestures,1) end
    event('POINTER_END',{action=g.action,target=node(g.target),point=coordinates(input,g.target)})
    snapshot(g.target,'INPUT_ENDED',g.action);later(g.target,g.action)
end
local function pathText(item)
    local out={}
    for _,part in ipairs(item.path) do out[#out+1]=part.class..':'..safe(part.name,256)..'['..part.index..'/'..part.count..']'..(part.nameTruncated and '{TRUNCATED_NAME}' or '') end
    return table.concat(out,'/')
end
local function recordingData()
    return {schema=1,version=controller.Version,placeId=game.PlaceId,roots=roots,nodes=nodes,events=events,
        replay='NOT_IMPLEMENTED; OBSERVATION_ONLY',readiness='STRUCTURAL_QUIET_HINT_ONLY',textBoxValues='NEVER_RECORDED',states='INITIAL_THEN_CHANGED_NODES',
        hitAPIs=hitCapabilities,guiInset=inset}
end
function controller.GetRecording() return recordingData() end
function controller.GetReport()
    local rows={controller.Version,'STATE|'..(recording and 'RECORDING' or controller.IsStopped and 'STOPPED' or 'FINISHED'),
        'PLACE|'..game.PlaceId,'SECONDS|'..string.format('%.2f',(endedAt or os.clock())-started),
        'ROOT_GENERATIONS|'..generation,'EVENTS|'..#events,'CONTROLS|'..#nodes,'BOUND_BUTTONS|'..boundCount,'DISCOVERY_CAPPED|'..tostring(discoveryCapped),
        'READY_HINT|'..tostring(readyHint)..'; STRUCTURE_QUIET_ONLY; NOT_YUNA_INITIALIZATION_PROOF',
        'CAPABILITIES|'..table.concat(capabilities,';'),'COPY_RESULT|'..copyResult,'FILE_RESULT|'..fileResult,'JSON_RESULT|'..jsonResult,
        'HIT_APIS|'..table.concat(hitCapabilities,';'),'GUI_INSET|'..inset,
        'FATAL_ERROR|'..fatal,'FINISH|'..finishReason,'CLEANUP_CONFIRMED|'..tostring(clean),
        'INPUT_SCOPE|SELECTED_YUNA_SCREEN_GUI_ONLY; NO_KEY_CODES; NO_TEXTBOX_CONTENT',
        'ORDERING|INPUT_AND_GUI_SIGNALS_PRESERVED; SIGNALS_ARE_NOT_EXTRA_CLICKS',
        'HIT_TEST|EXECUTOR_THEN_COREGUI_THEN_PLAYERGUI; NATIVE_API_ORDER_WITHIN_LAYER',
        'SELECTION_CONFIRMED|'..tostring(selected~=nil),'PICK_CONFIRMATION_PENDING|'..tostring(candidate~=nil),
        'REPLAY|NOT_IMPLEMENTED; NO_CALLBACK_INVOCATION_OR_SYNTHETIC_INPUT'}
    for _,root in ipairs(roots) do rows[#rows+1]='ROOT|'..root.generation..' source='..root.source..' name='..root.name..' parentClass='..root.parentClass
        ..' ignoreGuiInset='..tostring(root.ignoreGuiInset)..' displayOrder='..tostring(root.displayOrder) end
    for _,item in ipairs(nodes) do rows[#rows+1]='CONTROL|'..item.id..' root='..item.generation..' path='..pathText(item)..' label='..(item.label or '')..' image='..(item.image or '') end
    for _,e in ipairs(events) do
        local line='EVENT|'..e.seq..' t='..e.t..' root='..e.generation..' kind='..e.kind..' target='..(e.target or 'NONE')..' action='..(e.action or 'NONE')
        if e.point then line=line..string.format(' x=%d y=%d u=%.4f v=%.4f',e.point.x,e.point.y,e.point.u,e.point.v) end
        if e.phase then line=line..' phase='..e.phase end
        if e.input then line=line..' input='..e.input end
        if e.detached then line=line..' detached=true' end
        if e.truncated then line=line..' localStateTruncated=true' end
        if e.source then line=line..' source='..e.source end
        if e.reason then line=line..' reason='..safe(e.reason) end
        rows[#rows+1]=line
        if e.nodes then for _,state in ipairs(e.nodes) do
            local p=state.props;local values={}
            for _,key in ipairs({'visible','text','background','backgroundTransparency','textColor','image','imageColor','color','enabled','rotation'}) do
                if p[key]~=nil then values[#values+1]=key..'='..safe(p[key]) end
            end
            for _,key in ipairs({'position','size'}) do local v=p[key];if v then values[#values+1]=key..'='..v.xs..','..v.xo..','..v.ys..','..v.yo end end
            rows[#rows+1]='UI_STATE|'..e.seq..' control='..state.id..' '..table.concat(values,';')
        end end
    end
    return table.concat(rows,'\n')
end
save=function(copy)
    env.PELICAN_YUNA_GUI_RECORDING=recordingData()
    local report=controller.GetReport()
    if #report>350000 then fatal='REPORT_SIZE_LIMIT';if recording then finish('REPORT_SIZE_LIMIT');return end end
    if type(writefile)=='function' then
        local ok=pcall(writefile,'PELICAN_YUNA_GUI_REPORT.txt',report);fileResult=ok and 'API_ACCEPTED' or 'FAILED'
        local encoded,json=pcall(function() return game:GetService('HttpService'):JSONEncode(recordingData()) end)
        if encoded then local wrote=pcall(writefile,'PELICAN_YUNA_GUI_RECORDING.json',json);jsonResult=wrote and 'API_ACCEPTED' or 'WRITE_FAILED'
        else jsonResult='ENCODE_UNAVAILABLE' end
    else fileResult='UNAVAILABLE';jsonResult='NO_FILE_API' end
    if copy then
        if type(setclipboard)=='function' then local ok=pcall(setclipboard,controller.GetReport());copyResult=ok and 'API_ACCEPTED_NO_READBACK' or 'FAILED'
        else copyResult='UNAVAILABLE' end
    end
    env.PELICAN_YUNA_GUI_REPORT=controller.GetReport();dirty=false;lastSave=os.clock()
end
finish=function(reason)
    if not recording then return end
    -- Finish pending local observations before removing all data listeners.
    local ok,err=pcall(function()
        local seen={}
        for _,p in ipairs(pending) do if not seen[p.target] then seen[p.target]=true;snapshot(p.target,'FINAL',p.action) end end
        event('FINISH',{reason=reason})
    end)
    if not ok and fatal=='NONE' then fatal=safe(err,350) end
    recording=false;endedAt=os.clock();finishReason=reason or 'USER_DONE';pending={};gestures={}
    candidate=nil;if outline then outline.Visible=false end;if pickButton then pickButton.Text='PICK' end
    dataConnections=disconnect(dataConnections);clearBindings()
    if status then status.Text=fatal=='NONE' and 'YUNA COPY' or 'YUNA ERROR' end
    save(true)
    if fatal~='NONE' and panel then panel.Visible=true;if render then render() end end
end
function controller.Finish()
    if recording and not selected then fatal='NO_CONFIRMED_YUNA_WINDOW';finish('NO_CONFIRMED_YUNA_WINDOW') else finish('USER_DONE') end
    if render then render() end;return not recording
end
function controller.Stop(reason)
    if clean then return true end
    finish(reason or 'USER_END')
    dataConnections=disconnect(dataConnections);local bindingsClean=clearBindings();uiConnections=disconnect(uiConnections)
    if gui then local ok=pcall(function() gui:Destroy() end);if ok then gui=nil end end
    clean=#dataConnections==0 and #uiConnections==0 and bindingsClean and gui==nil
    controller.IsStopped=true;save(true)
    if clean and env[KEY]==controller then env[KEY]=nil end
    return clean
end
function controller.SelectRoot(root)
    if not recording then return false end
    local ok,err=pcall(selectRoot,root,'EXPLICIT_INSTANCE')
    if not ok then fatal=safe(err,350);finish('ROOT_SELECTION_ERROR') end
    return ok
end
local function scan()
    if not selected and discoveryCapped then return end
    if index>#queue then
        queue={};index=1;scanSeen={}
        if selected then enqueue(selected) else for _,container in ipairs(containers) do enqueue(container) end end
    end
    local deadline=os.clock()+.001
    for _=1,64 do
        if index>#queue or os.clock()>deadline then break end
        local o=queue[index];queue[index]=false;index=index+1
        local containerRoot=false;for _,container in ipairs(containers) do if container==o then containerRoot=true;break end end
        if o and (o.Parent or containerRoot) and not own(o) then
            if not selected then
                local root=rootOf(o)
                local name=root and root.Name:lower()
                local title=label(o)
                if root and not candidate and not gameMenu(root) and root.Enabled and (name:find('yuna',1,true) or title and visible(o) and title:lower():match('^%s*yuna[%s%p%d]*$')) then
                    selectRoot(root,'YUNA_NAME_OR_TITLE');return
                end
            elseif belongs(o) and is(o,'GuiButton') then observeButton(o) end
            local children=o:GetChildren()
            if #children>4096 then
                if selected then error('GUI_CHILD_COUNT_LIMIT') end
                discoveryCapped=true;return
            end
            for _,child in ipairs(children) do enqueue(child) end
        end
    end
end
local function heartbeat()
    local now=os.clock()
    if selected and not selected.Parent then
        event('ROOT_LOST');assert(clearBindings(),'Detached Yuna cleanup unconfirmed');selected=nil;pending={};gestures={};queue={};index=1;scanSeen={};readyHint=false
    end
    if now-lastScan>=.1 then lastScan=now;scan() end
    if selected and not readyHint and now-quietSince>=.75 and index>#queue then readyHint=true;event('STRUCTURE_QUIET_HINT') end
    if candidate then status.Text='CHECK BOX'
    elseif selected then status.Text=picking and 'PICK YUNA' or readyHint and 'YUNA REC' or 'YUNA LOAD'
    else status.Text=(picking or discoveryCapped) and 'PICK YUNA' or 'WAIT YUNA' end
    for i=#pending,1,-1 do
        local p=pending[i];local delay=p.step==1 and .15 or .6
        if now-p.at>=delay then snapshot(p.target,p.step==1 and 'AFTER_150MS' or 'AFTER_600MS',p.action);p.step=p.step+1;if p.step>2 then table.remove(pending,i) end end
    end
    if now-lastPrune>=1 then
        lastPrune=now
        for o,group in pairs(buttonGroups) do if not belongs(o) then
            local remaining=disconnect(group)
            if #remaining==0 then buttonGroups[o]=nil;boundCount=boundCount-1 else buttonGroups[o]=remaining end
        end end
    end
    if captureStart and now-captureStart>=duration then finish('CAPTURE_COMPLETE')
    elseif not captureStart and now-started>=waitTimeout then finish('YUNA_WAIT_TIMEOUT')
    elseif dirty and now-lastSave>=.5 then save(false) end
end
render=function()
    if not box then return end
    local report=controller.GetReport();local pages=math.max(1,math.ceil(#report/5000));page=math.max(1,math.min(pages,page))
    box.Text=report:sub((page-1)*5000+1,page*5000);pageLabel.Text=page..'/'..pages
end
local built,problem=pcall(function()
    gui=Instance.new('ScreenGui');gui.Name=controller.Version;gui.ResetOnSpawn=false;gui.DisplayOrder=10020;gui.IgnoreGuiInset=true
    local hosted=false
    if hidden then hosted=pcall(function() gui.Parent=hidden end) end
    if not hosted then gui.Parent=pg end
    local function button(name,text,x,width)
        local b=Instance.new('TextButton');b.Name=name;b.Text=text;b.Size=UDim2.fromOffset(width,22);b.Position=UDim2.fromOffset(x,192)
        b.TextSize=10;b.Font=Enum.Font.GothamMedium;b.BackgroundColor3=Color3.fromRGB(27,37,34);b.TextColor3=Color3.new(1,1,1);b.Parent=gui;return b
    end
    status=button('Status','WAIT YUNA',8,82);local pick=button('Pick','PICK',92,36);pickButton=pick;local done=button('DoneCopy','DONE',130,40)
    local view=button('View','VIEW',172,36);local stop=button('Stop','X',210,22);stop.BackgroundColor3=Color3.fromRGB(195,40,40)
    panel=Instance.new('Frame');panel.Size=UDim2.fromOffset(300,210);panel.Position=UDim2.fromOffset(8,218);panel.Visible=false;panel.Parent=gui
    box=Instance.new('TextBox');box.Size=UDim2.fromOffset(292,175);box.Position=UDim2.fromOffset(4,4);box.TextSize=10;box.MultiLine=true;box.TextEditable=false;box.ClearTextOnFocus=false;box.TextWrapped=true;box.Parent=panel
    local prev,nextPage=button('Previous','<',0,32),button('Next','>',0,32);prev.Parent=panel;nextPage.Parent=panel;prev.Position=UDim2.fromOffset(4,184);nextPage.Position=UDim2.fromOffset(40,184)
    pageLabel=Instance.new('TextLabel');pageLabel.Size=UDim2.fromOffset(100,22);pageLabel.Position=UDim2.fromOffset(90,184);pageLabel.Parent=panel
    outline=Instance.new('Frame');outline.Name='PickedControl';outline.BackgroundTransparency=1;outline.BorderSizePixel=3
    outline.BorderColor3=Color3.new(0,1,0);outline.Active=false;outline.Visible=false;outline.Parent=gui
    connect(uiConnections,pick.Activated,function()
        if not recording then return end
        if candidate then
            local root=candidate.root
            assert(root.Parent and visible(root),'Selected window disappeared; PICK again')
            selectRoot(root,'USER_CONFIRMED_PICK')
        else picking=not picking;pickMisses=0;status.Text=picking and 'PICK YUNA' or selected and 'YUNA REC' or 'WAIT YUNA' end
    end)
    connect(uiConnections,done.Activated,function() controller.Finish();save(true) end)
    connect(uiConnections,status.Activated,function() save(true);render() end)
    connect(uiConnections,view.Activated,function() panel.Visible=not panel.Visible;render() end)
    connect(uiConnections,prev.Activated,function() page=page-1;render() end)
    connect(uiConnections,nextPage.Activated,function() page=page+1;render() end)
    connect(uiConnections,stop.Activated,function() controller.Stop('USER_END') end)
    connect(dataConnections,Input.InputBegan,beginInput);connect(dataConnections,Input.InputChanged,moveInput);connect(dataConnections,Input.InputEnded,endInput)
    connect(dataConnections,Run.Heartbeat,heartbeat)
    if me.OnTeleport then connect(dataConnections,me.OnTeleport,function() controller.Stop('TELEPORT') end) end
    if options.Root then selectRoot(options.Root,'EXPLICIT_OPTION') end
    save(false)
end)
if not built then fatal=safe(problem,350);controller.Stop('STARTUP_ERROR');error(problem) end
env[KEY]=controller
return controller
