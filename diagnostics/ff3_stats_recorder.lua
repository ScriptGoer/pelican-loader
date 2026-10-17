-- Read-only FF3 teammate/stat GUI recorder. No remote invokes, UI activation,
-- blacklist decisions, server leaving or executor startup installation.
local options=... or {}
assert(type(options)=='table','Recorder options must be a table')
local Players,Run=game:GetService('Players'),game:GetService('RunService')
local me=Players.LocalPlayer
assert(me and game.PlaceId==82866880824588,'FF3 live place required')
local env=type(getgenv)=='function' and getgenv() or _G
local KEY='PELICAN_FF3_STATS_RECORDER'
if env[KEY] then assert(type(env[KEY].Stop)=='function' and env[KEY].Stop('REPLACED')==true,'Previous recorder cleanup unconfirmed') end
local pg=assert(me:FindFirstChild('PlayerGui'),'PlayerGui required')
local coreOK,core=pcall(function() return game:GetService('CoreGui') end)
if not coreOK then core=nil end
local duration=options.Duration or 90
assert(type(duration)=='number' and duration>=5 and duration<=300,'Duration must be 5 to 300 seconds')
local controller={Version='PELICAN_FF3_STATS_RECORDER_V1',IsStopped=false}
local dataConnections,uiConnections={},{}
local started,lastWork,nextSnapshot=os.clock(),-math.huge,0
local endedAt
local recording,clean,gui,caption,panel,box,pageLabel=true,false
local rows,totalChars,snapshots={},0,0
local queue,index,visited={},1,0
local texts=setmetatable({}, {__mode='k'})
local images=setmetatable({}, {__mode='k'})
local yunaRoots=setmetatable({}, {__mode='k'})
local candidateCount,capped,lastSignature=0,false,nil
local scanComplete,copyResult,fileResult,fatal=false,'NOT_REQUESTED','NOT_REQUESTED','NONE'
local reportPage=1
local function text(v,n) return tostring(v):gsub('[\r\n|]',' '):sub(1,n or 180) end
local function add(kind,value)
    local line=kind..'|'..text(value,1600)
    if totalChars+#line>180000 then capped=true;return end
    rows[#rows+1]=line;totalChars=totalChars+#line+1
end
local function path(o)
    local names={}
    for _=1,14 do if not o then break end;table.insert(names,1,text(o.Name,60));o=o.Parent end
    return table.concat(names,'.'):sub(-350)
end
local function visible(o)
    if not o.Parent or not(o:IsDescendantOf(pg) or core and o:IsDescendantOf(core)) then return false end
    for _=1,20 do
        if not o then return true end
        if o:IsA('GuiObject') and not o.Visible or o:IsA('LayerCollector') and not o.Enabled then return false end
        o=o.Parent
    end
    return false
end
local function screenRoot(o)
    for _=1,20 do if not o then return end;if o:IsA('ScreenGui') then return o end;o=o.Parent end
end
local function normalized(value) return value:gsub('<[^>]*>',''):gsub('^%s+',''):gsub('%s+$',''):gsub('^@',''):lower() end
local function scope(o)
    local at=o.Parent
    for _=1,12 do
        if not at or at==pg or at==core then break end
        local name=at.Name:lower()
        if name:find('chat',1,true) then return end
        if name:find('stat',1,true) or name:find('profile',1,true) or name:find('career',1,true) then return at end
        at=at.Parent
    end
end
function controller.GetReport()
    local head={controller.Version,'STATE|'..(recording and 'RECORDING' or controller.IsStopped and 'STOPPED' or 'FINISHED'),
        'PLACE|'..tostring(game.PlaceId),'JOB|'..text(game.JobId or 'UNAVAILABLE'),
        'CAPTURE_SECONDS|'..string.format('%.2f',(endedAt or os.clock())-started),'SNAPSHOTS|'..snapshots,
        'SCAN_VISITED|'..visited,'SCAN_COMPLETE|'..tostring(scanComplete),'CAPPED|'..tostring(capped),
        'COPY_RESULT|'..copyResult,'FILE_RESULT|'..fileResult,'FATAL_ERROR|'..fatal,
        'MATCH_POLICY|EXACT_CURRENT_TEAM_USERNAME_ONLY; DISPLAY_NAMES_NOT_IDENTITY',
        'STAT_SCHEMA|UNVERIFIED; RAW_LABELS_AND_VALUES_ONLY',
        'CONSISTENCY|REPEATED_SNAPSHOTS_ARE_NOT_SEPARATE_MATCHES',
        'ACTIONS|NO_BLACKLIST; NO_LEAVE; NO_BUTTON_ACTIVATION; NO_REMOTE_REQUEST',
        'CLEANUP_CONFIRMED|'..tostring(clean)}
    for _,r in ipairs(rows) do head[#head+1]=r end
    return table.concat(head,'\n')
end
local function save(copy)
    env.PELICAN_FF3_STATS_REPORT=controller.GetReport()
    if type(writefile)=='function' then
        local ok=pcall(writefile,'PELICAN_FF3_STATS_REPORT.txt',controller.GetReport())
        fileResult=ok and 'API_ACCEPTED' or 'WRITE_FAILED'
    else fileResult='UNAVAILABLE' end
    if copy then
        if type(setclipboard)=='function' then local ok=pcall(setclipboard,controller.GetReport());copyResult=ok and 'API_ACCEPTED_NO_READBACK' or 'FAILED'
        else copyResult='UNAVAILABLE' end
    end
    env.PELICAN_FF3_STATS_REPORT=controller.GetReport()
end
local function disconnect(list)
    local remaining={}
    for _,c in ipairs(list) do local ok=pcall(function() c:Disconnect() end);if not ok then remaining[#remaining+1]=c end end
    return remaining
end
local function finish(reason)
    if recording then recording=false;endedAt=os.clock();add('FINISH',reason) end
    dataConnections=disconnect(dataConnections)
    if caption then caption.Text='STATS COPY' end
    save(true)
end
function controller.Stop(reason)
    if clean then return true end
    finish(reason or 'USER_END')
    uiConnections=disconnect(uiConnections)
    if gui then local ok=pcall(function() gui:Destroy() end);if ok then gui=nil end end
    clean=#dataConnections==0 and #uiConnections==0 and gui==nil
    controller.IsStopped=true;save(true)
    if clean and env[KEY]==controller then env[KEY]=nil end
    return clean
end
local function scan()
    if index>#queue then
        queue={pg};if core then queue[#queue+1]=core end
        index=1;visited=0;scanComplete=false
    end
    local deadline=os.clock()+.001
    local work=0
    while index<=#queue and work<96 and os.clock()<deadline do
        local o=queue[index];queue[index]=false;index=index+1;work=work+1;visited=visited+1
        if visited>20000 then capped=true;index=#queue+1;break end
        if o and (o==pg or o==core or o.Parent) and not(gui and (o==gui or o:IsDescendantOf(gui))) then
            if o:IsA('TextLabel') or o:IsA('TextButton') then
                local label=normalized(o.Text)
                local root=screenRoot(o)
                if root and (label:find('yuna',1,true) or root.Name:lower():find('yuna',1,true)) then yunaRoots[root]=true end
                local relevant=scope(o) or label=='disconnect' or label=='qb aimbot' or label=='auto throw type'
                if relevant and not texts[o] then
                    if candidateCount>=512 then
                        for old in pairs(texts) do if not old.Parent then texts[old]=nil;candidateCount=candidateCount-1 end end
                    end
                    if candidateCount<512 then texts[o]=true;candidateCount=candidateCount+1 else capped=true end
                end
            elseif o:IsA('ImageButton') and yunaRoots[screenRoot(o)] then
                images[o]=true
            end
            local children=o:GetChildren()
            if #children>4096 or #queue+#children>20000 then capped=true else for _,child in ipairs(children) do queue[#queue+1]=child end end
        end
    end
    scanComplete=index>#queue
end
local function snapshot()
    local roster,byName,byDisplay={}, {},{}
    for _,p in ipairs(Players:GetPlayers()) do
        if #roster>=64 then capped=true;break end
        if p~=me and me.Team and not me.Neutral and not p.Neutral and p.Team==me.Team then
            roster[#roster+1]=p;byName[p.Name:lower()]=p
            local key=(p.DisplayName or p.Name):lower();byDisplay[key]=byDisplay[key] or {};table.insert(byDisplay[key],p)
        end
    end
    table.sort(roster,function(a,b) return a.Name<b.Name end)
    local data={}
    local function item(k,v) data[#data+1]=k..'|'..text(v,1500) end
    for _,p in ipairs(roster) do
        item('TEAMMATE',tostring(p.UserId)..' '..p.Name..' display='..(p.DisplayName or p.Name))
        local folder=p:FindFirstChild('leaderstats')
        if folder then
            for i,value in ipairs(folder:GetChildren()) do
                if i>64 then capped=true;break end
                if value:IsA('NumberValue') or value:IsA('IntValue') or value:IsA('StringValue') then
                    item('LEADERSTAT',tostring(p.UserId)..' '..p.Name..' '..path(value)..' class='..value.ClassName..' raw='..text(value.Value,100))
                end
            end
        end
    end
    for o in pairs(texts) do
        if visible(o) then
            local raw=text(o.Text,300);local key=normalized(raw);local owner=byName[key];local container=scope(o)
            if container then
                item('GUI_STAT_TEXT',path(container)..' node='..path(o)..' raw='..raw)
                if owner then item('USERNAME_MATCH','userId='..tostring(owner.UserId)..' username='..owner.Name..' scope='..path(container)..' node='..path(o))
                elseif byDisplay[key] then item('DISPLAY_ONLY_UNASSIGNED','text='..raw..' matches='..#byDisplay[key]..' scope='..path(container)) end
            end
            local lower=raw:lower()
            if lower=='disconnect' or lower=='qb aimbot' or lower=='auto throw type' then item('STARTUP_CONTROL_TEXT',path(o)..' raw='..raw..' class='..o.ClassName) end
        end
    end
    local imageCount=0
    for o in pairs(images) do
        if visible(o) and yunaRoots[screenRoot(o)] then
            imageCount=imageCount+1;if imageCount>96 then capped=true;break end
            local asset=type(o.Image)=='string' and o.Image:match('^rbxassetid://%d+$') or 'NON_ASSET_URL'
            item('YUNA_IMAGE_BUTTON',path(o)..' asset='..asset..' x='..text(o.AbsolutePosition.X,20)..' y='..text(o.AbsolutePosition.Y,20))
        end
    end
    table.sort(data)
    local signature=table.concat(data,'\n')
    if signature~=lastSignature then
        snapshots=snapshots+1;add('SNAPSHOT',snapshots..' t='..string.format('%.2f',os.clock()-started))
        for _,line in ipairs(data) do local kind,value=line:match('^([^|]+)|(.*)$');add(kind,value) end
        lastSignature=signature;save(false)
    end
end
local function connect(list,signal,fn) local c=signal:Connect(fn);list[#list+1]=c;return c end
local function render()
    if not box then return end
    local report=controller.GetReport();local pages=math.max(1,math.ceil(#report/5000));reportPage=math.max(1,math.min(pages,reportPage))
    box.Text=report:sub((reportPage-1)*5000+1,reportPage*5000);pageLabel.Text=reportPage..'/'..pages
end
local ok,problem=pcall(function()
    gui=Instance.new('ScreenGui');gui.Name='PELICAN_FF3_STATS_RECORDER_V1';gui.ResetOnSpawn=false;gui.DisplayOrder=1001;gui.Parent=pg
    local function button(label,x,width)
        local b=Instance.new('TextButton');b.Text=label;b.Size=UDim2.fromOffset(width,20);b.Position=UDim2.fromOffset(x,164)
        b.TextSize=10;b.Font=Enum.Font.GothamMedium;b.BackgroundColor3=Color3.fromRGB(27,37,34);b.TextColor3=Color3.new(1,1,1);b.Parent=gui;return b
    end
    caption=button('STATS REC',8,88);local view=button('VIEW',98,40);local stop=button('X',140,20)
    panel=Instance.new('Frame');panel.Size=UDim2.fromOffset(288,202);panel.Position=UDim2.fromOffset(8,188);panel.Parent=gui;panel.Visible=false
    box=Instance.new('TextBox');box.Size=UDim2.fromOffset(280,168);box.Position=UDim2.fromOffset(4,4);box.TextSize=10;box.MultiLine=true;box.TextEditable=false;box.ClearTextOnFocus=false;box.TextWrapped=true;box.Parent=panel
    pageLabel=Instance.new('TextLabel');pageLabel.Size=UDim2.fromOffset(80,20);pageLabel.Position=UDim2.fromOffset(100,176);pageLabel.Parent=panel
    local prev,nextPage=button('<',8,36),button('>',48,36);prev.Parent=panel;nextPage.Parent=panel;prev.Position=UDim2.fromOffset(8,176);nextPage.Position=UDim2.fromOffset(48,176)
    connect(uiConnections,prev.Activated,function() reportPage=reportPage-1;render() end)
    connect(uiConnections,nextPage.Activated,function() reportPage=reportPage+1;render() end)
    connect(uiConnections,view.Activated,function() panel.Visible=not panel.Visible;render() end)
    connect(uiConnections,caption.Activated,function() save(true);render() end)
    connect(uiConnections,stop.Activated,function() controller.Stop('USER_END') end)
    if me.OnTeleport then connect(dataConnections,me.OnTeleport,function() controller.Stop('TELEPORT') end) end
    connect(dataConnections,Run.Heartbeat,function()
        if not recording then return end
        local now=os.clock();if now-lastWork<.2 then return end;lastWork=now
        local worked,err=pcall(function()
            scan()
            if now>=nextSnapshot then nextSnapshot=now+5;snapshot() end
            if now-started>=duration or capped and totalChars>=179000 then finish('CAPTURE_COMPLETE');render() end
        end)
        if not worked then fatal=text(err);finish('RUNTIME_ERROR');panel.Visible=true;render() end
    end)
end)
if not ok then fatal=text(problem);controller.Stop('STARTUP_ERROR');error(problem) end
env[KEY]=controller
add('START','Open teammate Receiver/Corner stats; GUI stays untouched; save before leaving Roblox')
return controller
