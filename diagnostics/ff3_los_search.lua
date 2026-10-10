-- PELICAN_FF3_LOS_SEARCH_V3: bounded public-instance inspection, no game requests.
-- V15.2 predicates below are diagnostic comparisons, not new accepted LOS rules.
-- Starts without Yuna; stops an existing Pelican Auto QB and never restarts it.
local VERSION,KEY='PELICAN_FF3_LOS_SEARCH_V3','PELICAN_FF3_LOS_SEARCH'
if game.PlaceId~=82866880824588 then error('Pelican LOS search requires the observed FF3 live place') end
local env=type(getgenv)=='function' and getgenv() or _G
local old=env[KEY]
if old and (type(old.Stop)~='function' or old.Stop('REPLACED')~=true) then error('Previous LOS search cleanup failed') end
local Players,Run=game:GetService('Players'),game:GetService('RunService')
local me=Players.LocalPlayer; local pg=me and me:FindFirstChild('PlayerGui')
if not pg then error('Pelican LOS search: PlayerGui not ready') end
local controller={Version=VERSION,IsStopped=false}
local connections,records,byObject,history,errors={},{},setmetatable({}, {__mode='k'}),{},{}
local limits={FOCUS=8,GROUND=4,PART=64,BEAM=24,GUI=16,VALUE=24}
for kind in pairs(limits) do records[kind]={} end
local stopped,cleanupComplete,busy=false,false,false
local gui,status,copyButton,scanButton,reportButton
local started,lastTick,nextSave,nextRefresh,nextUI=os.clock(),-math.huge,0,0,0
local sweep,completed,totalVisited,nextSweep=0,0,0,0
local scan,ground,id,refreshCursor=nil,nil,0,1
local considered,dropped,incrementalDrops,maxTick=0,0,0,0
local copyResult,fileResult,autoState,stopReason='NOT_REQUESTED','NOT_REQUESTED','NOT_PRESENT','NONE'
local copyAPI,copyError,readback='NONE','NONE','NOT_ATTEMPTED'
local initialAutoReport='NONE'
local V=Vector3.new
local function safe(x,n) return tostring(x):gsub('[\r\n|]',' '):sub(1,n or 180) end
local function num(x) return type(x)=='number' and string.format('%.3f',x) or 'NONE' end
local function vec(v) return v and num(v.X)..','..num(v.Y)..','..num(v.Z) or 'NONE' end
local function vec2(v) return v and num(v.X)..','..num(v.Y) or 'NONE' end
local function rgb(c) return c and num(c.R)..','..num(c.G)..','..num(c.B) or 'NONE' end
local function path(o) return safe(o:GetFullName(),240) end
local function role(c)
    if c.B>.65 and c.B>c.R+.3 and c.R<.4 and c.G<.85 then return 'BLUE' end
    if c.R>.75 and c.G>.45 and c.B<.4 then return 'YELLOW' end
end
local function hint(name)
    local s=name:lower()
    return s:find('scrim',1,true) or s:find('firstdown',1,true) or s:find('first_down',1,true)
        or s:find('first down',1,true) or s:find('yard',1,true) or s:find('line',1,true)
        or s=='los' or s=='down' or s=='status' or s=='throwable' or s:find('possession',1,true)
        or s:find('direction',1,true) or s:find('playclock',1,true)
end
local function log(text)
    if #history>=96 then table.remove(history,1) end
    history[#history+1]=string.format('%.2f',os.clock()-started)..'|'..text
end
local function failure(list,ok,reason) if not ok then list[#list+1]=reason end end
local function verdict(list) return #list==0 and 'PASS' or 'REJECT '..table.concat(list,',') end
local function groundShape(o)
    if not o:IsA('BasePart') or not o.Anchored then return false end
    local s,c=o.Size,o.CFrame
    return math.abs(s.X-225)<.6 and math.abs(s.Y-1)<.3 and math.abs(s.Z-420)<.6
        and (o.Position-V(0,2.5,0)).Magnitude<1.5 and c.UpVector.Y>.999
        and math.abs(c.RightVector.X)>.999 and math.abs(c.LookVector.Z)>.999
end
local function partData(o)
    local s,c,p=o.Size,o.CFrame,o.Position; local width,thin=math.max(s.X,s.Z),math.min(s.X,s.Z)
    local r=role(o.Color); local discovery,active={},{}
    failure(discovery,o.Anchored,'UNANCHORED'); failure(discovery,s.Y<=3,'SIZE_Y_GT_3')
    failure(discovery,thin<=5,'MIN_XZ_GT_5'); failure(discovery,width>=30 and width<=175,'WIDTH_NOT_30_175')
    failure(discovery,math.abs(p.X)<=85,'WORLD_X_OUTSIDE_85'); failure(discovery,math.abs(p.Z)<=153,'WORLD_Z_OUTSIDE_153')
    failure(discovery,math.abs(p.Y-3)<4,'WORLD_Y_OUTSIDE_PLANE'); failure(discovery,c.UpVector.Y>=.98,'UP_Y_LT_098')
    failure(active,o.Anchored,'UNANCHORED'); failure(active,o.Transparency<=.65,'HIDDEN_TRANSPARENCY')
    failure(active,c.UpVector.Y>=.98,'UP_Y_LT_098'); failure(active,o:IsDescendantOf(workspace),'NOT_IN_WORKSPACE')
    local localp,dx,dz
    if ground and ground.Parent then
        failure(active,groundShape(ground),'GROUND_SHAPE_CHANGED')
        local cf=ground.CFrame; localp=cf:PointToObjectSpace(p)
        dx=math.abs(c.RightVector:Dot(cf.RightVector))*s.X+math.abs(c.LookVector:Dot(cf.RightVector))*s.Z
        dz=math.abs(c.RightVector:Dot(cf.LookVector))*s.X+math.abs(c.LookVector:Dot(cf.LookVector))*s.Z
        failure(active,dx>=30 and dx<=175,'PROJECTED_WIDTH_NOT_30_175'); failure(active,dz<=5,'PROJECTED_DEPTH_GT_5')
        failure(active,s.Y<=3,'HEIGHT_GT_3'); failure(active,math.abs(localp.X)<=85,'LOCAL_X_OUTSIDE_85')
        failure(active,math.abs(localp.Y-.5)<=4,'LOCAL_Y_OUTSIDE_PLANE'); failure(active,math.abs(localp.Z)<=153,'LOCAL_Z_OUTSIDE_153')
        if not r and o.Color.R>.7 and o.Color.G>.7 and o.Color.B>.7
            and math.abs(math.abs(localp.Z)-150)<.6 and math.abs(dx-160)<1 and math.abs(dz-.25)<.1 then r='GOAL' end
    else active[#active+1]='GROUND_NOT_FOUND' end
    failure(active,r~=nil,'COLOR_NOT_BLUE_YELLOW_OR_GOAL')
    local text='class='..o.ClassName..'; p='..vec(p)..'; size='..vec(s)..'; rgb='..rgb(o.Color)
        ..'; anchored='..tostring(o.Anchored)..'; alpha='..num(o.Transparency)..'; localAlpha='..num(o.LocalTransparencyModifier)
        ..'; upY='..num(c.UpVector.Y)..'; local='..vec(localp)..'; dx='..num(dx)..'; dz='..num(dz)..'; role='..(r or 'NONE')
    return text,verdict(discovery),verdict(active),r,#active==0
end
local function beamData(o)
    local discovery,active={},{}; local a,b=o.Attachment0,o.Attachment1
    failure(discovery,a~=nil and b~=nil,'MISSING_ATTACHMENTS')
    failure(discovery,math.abs(o.CurveSize0)<=.1 and math.abs(o.CurveSize1)<=.1,'CURVED_BEAM')
    for _,v in ipairs(discovery) do active[#active+1]=v end
    failure(active,o.Enabled,'DISABLED'); failure(active,o:IsDescendantOf(workspace),'NOT_IN_WORKSPACE')
    local r,colors,alphas=nil,{},{}
    for _,k in ipairs(o.Color.Keypoints) do
        local current=role(k.Value); colors[#colors+1]=rgb(k.Value)
        failure(active,current~=nil and (not r or r==current),'COLOR_NOT_UNIFORM_BLUE_YELLOW')
        r=r or current
    end
    failure(active,r~=nil,'NO_LINE_COLOR')
    for _,k in ipairs(o.Transparency.Keypoints) do alphas[#alphas+1]=num(k.Value); failure(active,k.Value<=.65,'HIDDEN_TRANSPARENCY') end
    local ap,bp,localp,dx,dz,height
    if a and b then
        ap,bp=a.WorldPosition,b.WorldPosition; local d,p=bp-ap,(ap+bp)*.5
        failure(discovery,math.abs(d.X)>=30 and math.abs(d.X)<=175,'WORLD_WIDTH_NOT_30_175')
        failure(discovery,math.abs(d.Z)<=5,'WORLD_DEPTH_GT_5'); failure(discovery,math.abs(d.Y)<=3,'HEIGHT_GT_3')
        failure(discovery,math.abs(p.X)<=85,'WORLD_X_OUTSIDE_85'); failure(discovery,math.abs(p.Z)<=153,'WORLD_Z_OUTSIDE_153')
        failure(discovery,math.abs(p.Y-3)<4,'WORLD_Y_OUTSIDE_PLANE')
        for _,endpoint in ipairs({a,b}) do
            local at=endpoint.Parent
            for _=1,6 do
                if not at or at==workspace then break end
                failure(active,not (at:IsA('BasePart') and not at.Anchored),'MOVING_ENDPOINT_PARENT')
                failure(active,not (at:IsA('Model') and at:FindFirstChildOfClass('Humanoid')),'CHARACTER_ENDPOINT')
                at=at.Parent
            end
        end
        if ground and ground.Parent then
            failure(active,groundShape(ground),'GROUND_SHAPE_CHANGED')
            local cf=ground.CFrame; localp=cf:PointToObjectSpace(p); d=cf:VectorToObjectSpace(bp-ap)
            dx,dz,height=math.abs(d.X),math.abs(d.Z),math.abs(d.Y)
            failure(active,dx>=30 and dx<=175,'PROJECTED_WIDTH_NOT_30_175'); failure(active,dz<=5,'PROJECTED_DEPTH_GT_5')
            failure(active,height<=3,'HEIGHT_GT_3'); failure(active,math.abs(localp.X)<=85,'LOCAL_X_OUTSIDE_85')
            failure(active,math.abs(localp.Y-.5)<=4,'LOCAL_Y_OUTSIDE_PLANE'); failure(active,math.abs(localp.Z)<=153,'LOCAL_Z_OUTSIDE_153')
        else active[#active+1]='GROUND_NOT_FOUND' end
    else failure(active,ground~=nil,'GROUND_NOT_FOUND') end
    local text='enabled='..tostring(o.Enabled)..'; a='..vec(ap)..'; b='..vec(bp)..'; curve='..num(o.CurveSize0)..','..num(o.CurveSize1)
        ..'; rgbKeys='..table.concat(colors,'/')..'; alphaKeys='..table.concat(alphas,',')
        ..'; width='..num(o.Width0)..','..num(o.Width1)..'; local='..vec(localp)..'; dx='..num(dx)..'; dz='..num(dz)..'; h='..num(height)
    return text,verdict(discovery),verdict(active),r,#active==0
end
local function data(o,kind)
    if kind=='FOCUS' then
        local parent=o.Parent
        local suffix='; parent='..(parent and path(parent)..' ['..parent.ClassName..']' or 'NONE')
        local text,discovery,active,r,qualifies
        if o:IsA('BasePart') then text,discovery,active,r,qualifies=partData(o)
        elseif o:IsA('Beam') then text,discovery,active,r,qualifies=beamData(o)
        elseif o:IsA('ValueBase') then text,discovery,active=data(o,'VALUE')
        elseif o:IsA('GuiObject') or o:IsA('LayerCollector') or o:IsA('Decal') or o:IsA('Texture') then text,discovery,active=data(o,'GUI')
        else
            local children=o:GetChildren(); local names={}
            for i=1,math.min(8,#children) do
                local child=children[i]; local detail=safe(child.Name)..' ['..child.ClassName..']'
                if child:IsA('BasePart') then detail=detail..' p='..vec(child.Position)..' size='..vec(child.Size)..' rgb='..rgb(child.Color) end
                names[#names+1]=detail
            end
            text='class='..o.ClassName..'; children='..#children..'; samples='..table.concat(names,' / ')
            discovery,active='NOT_APPLICABLE','CONTEXT_ONLY'
        end
        return text..suffix,discovery,active,r,qualifies
    end
    if kind=='PART' or kind=='GROUND' then return partData(o) end
    if kind=='BEAM' then return beamData(o) end
    if kind=='VALUE' then return 'value='..safe(o.Value,96),'NOT_APPLICABLE','CONTEXT_ONLY' end
    local text='class='..o.ClassName
    if o:IsA('GuiObject') then
        text=text..'; visible='..tostring(o.Visible)..'; absolute='..vec2(o.AbsolutePosition)..'; pixels='..vec2(o.AbsoluteSize)
            ..'; bg='..rgb(o.BackgroundColor3)..'; bgAlpha='..num(o.BackgroundTransparency)
    end
    if o:IsA('TextLabel') or o:IsA('TextButton') then text=text..'; text='..safe(o.Text,96)
    elseif o:IsA('ImageLabel') or o:IsA('ImageButton') then text=text..'; image='..safe(o.Image,96)..'; tint='..rgb(o.ImageColor3)
    elseif o:IsA('SurfaceGui') or o:IsA('BillboardGui') then
        text=text..'; enabled='..tostring(o.Enabled)..'; adornee='..(o.Adornee and path(o.Adornee) or 'NONE')..'; face='..safe(o.Face)
    elseif o:IsA('Decal') or o:IsA('Texture') then text=text..'; texture='..safe(o.Texture,96)..'; rgb='..rgb(o.Color3)..'; alpha='..num(o.Transparency) end
    return text,'NOT_APPLICABLE','CONTEXT_ONLY'
end
local function sample(record,now)
    local o=record.object
    if not o.Parent then record.current='REMOVED'; record.active=false; record.live='REMOVED'; return end
    local text,discovery,active,r,qualifies=data(o,record.kind)
    local signature=text..'|initial='..discovery..'|active='..active
    if record.signature~=signature then
        if record.signature then log('CHANGE|'..record.id..'|'..safe(signature,600)) end
        record.signature=signature; record.changed=now; record.changes=record.changes+1
    end
    record.current=text; record.discovery=discovery; record.live=active; record.role=r; record.active=qualifies==true
    if qualifies and not record.firstActive then record.firstActive=now; record.firstActiveGeometry=signature end
    if qualifies then record.lastActive=signature; record.lastActiveAt=now end
    if not record.first then record.first=signature end
end
local function consider(o,kind,score)
    considered=considered+1
    local record=byObject[o]; local list=records[kind]
    if record then sample(record,os.clock()); record.score=score; return end
    local index=#list+1
    if #list>=limits[kind] then
        local worst=1
        for i,r in ipairs(list) do if not r.object.Parent or r.score<list[worst].score then worst=i end end
        if list[worst].object.Parent and list[worst].score>=score then dropped=dropped+1; return end
        byObject[list[worst].object]=nil; index=worst; dropped=dropped+1
    end
    id=id+1; record={object=o,id=kind:sub(1,1)..id,kind=kind,score=score,name=path(o),seen=os.clock(),changes=0}
    list[index]=record; byObject[o]=record
    sample(record,os.clock()); log('FOUND|'..record.id..'|'..record.name..'|'..record.discovery)
end
local function inspect(o)
    -- User identifies LineDown as the blue LOS. Pin it even if V15.2 rejects
    -- its shape; runtime class/path and dimensions still need inspection.
    if o.Name:lower()=='linedown' then consider(o,'FOCUS',10000); return end
    if o:IsA('BasePart') then
        local s,p=o.Size,o.Position; local width,thin=math.max(s.X,s.Z),math.min(s.X,s.Z)
        if groundShape(o) then ground=o; consider(o,'GROUND',2000); return end
        local r=role(o.Color); local shape=width>=20 and thin<=12 and s.Y<=12
        if r or shape or hint(o.Name) then
            local score=(shape and 600 or 0)+(r and 250 or 0)+(hint(o.Name) and 100 or 0)
                +((math.abs(p.X)<=100 and math.abs(p.Y-3)<12 and math.abs(p.Z)<250) and 200 or 0)
            consider(o,'PART',score)
        elseif width>=180 and thin>=180 and s.Y<=10 then consider(o,'GROUND',100) end
    elseif o:IsA('Beam') then
        local colored=false
        for _,k in ipairs(o.Color.Keypoints) do if role(k.Value) then colored=true end end
        local a,b=o.Attachment0,o.Attachment1; local wide=false
        if a and b then local d=b.WorldPosition-a.WorldPosition; wide=math.abs(d.X)>=20 and math.abs(d.Z)<=12 end
        consider(o,'BEAM',(wide and 700 or 0)+(colored and 200 or 0)+(hint(o.Name) and 100 or 0))
    elseif o:IsA('ValueBase') and hint(o.Name) then consider(o,'VALUE',100)
    elseif o:IsA('TextLabel') or o:IsA('TextButton') then
        local t=o.Text or ''; local down=t:gsub('<[^>]*>',''):lower():match('^[1-4]%a%a%s*&')
        if down or hint(o.Name) then consider(o,'GUI',down and 1000 or 100) end
    elseif o:IsA('GuiObject') then
        local c=o:IsA('ImageLabel') or o:IsA('ImageButton'); c=c and o.ImageColor3 or o.BackgroundColor3
        local sz=o.AbsoluteSize; local stripe=c and role(c) and sz.X>=30 and sz.Y<=16
        if stripe or hint(o.Name) then consider(o,'GUI',stripe and 800 or 150) end
    elseif o:IsA('SurfaceGui') or o:IsA('BillboardGui') or o:IsA('Decal') or o:IsA('Texture') then
        consider(o,'GUI',hint(o.Name) and 500 or 80)
    end
end
local rootServices={workspace,pg,game:GetService('ReplicatedStorage')}
local coreOK,core=pcall(function() return game:GetService('CoreGui') end)
if coreOK and core then rootServices[#rootServices+1]=core end
local rootSet={}; for _,r in ipairs(rootServices) do rootSet[r]=true end
local function startSweep()
    sweep=sweep+1
    local roots={}; for i,r in ipairs(rootServices) do roots[i]=r end
    scan={q=roots,i=1,tail=#roots,stack={},seen=setmetatable({}, {__mode='k'}),visited=0,classes={}}
    log('SWEEP|'..sweep)
end
local function scanChunk()
    if scan and scan.complete then return end
    if not scan then if os.clock()>=nextSweep then startSweep() else return end end
    local work,deadline=0,os.clock()+.0015
    while work<80 and os.clock()<deadline do
        local frame=scan.stack[#scan.stack]; local o
        if frame then
            if frame.i<=frame.n then o=frame.children[frame.i]; frame.children[frame.i]=nil; frame.i=frame.i+1
            else scan.stack[#scan.stack]=nil end
        else
            o=scan.q[scan.i]
            if not o then
                completed=sweep; nextSweep=os.clock()+3; scan.complete=true; scan.q={}; scan.tail=0; scan.i=1
                return
            end
            scan.q[scan.i]=nil; scan.i=scan.i+1
        end
        work=work+1
        if o and not scan.seen[o] and o~=gui and (rootSet[o] or o.Parent) then
            scan.seen[o]=true; scan.visited=scan.visited+1; totalVisited=totalVisited+1
            scan.classes[o.ClassName]=(scan.classes[o.ClassName] or 0)+1
            local ok,err=pcall(inspect,o)
            if not ok and not errors[o.ClassName] then errors[o.ClassName]=safe(err); log('INSPECT_ERROR|'..o.ClassName..'|'..safe(err)) end
            local children=o:GetChildren()
            if #children>0 then scan.stack[#scan.stack+1]={children=children,n=#children,i=1} end
        end
    end
end
local function refreshChunk()
    local list={}
    for _,kind in ipairs({'FOCUS','GROUND','PART','BEAM','GUI','VALUE'}) do for _,r in ipairs(records[kind]) do list[#list+1]=r end end
    for _=1,8 do
        if #list==0 then break end
        if refreshCursor>#list then refreshCursor=1 end
        local r=list[refreshCursor]; refreshCursor=refreshCursor+1
        local ok,err=pcall(sample,r,os.clock())
        if not ok and not errors.REFRESH then errors.REFRESH=safe(err); log('REFRESH_ERROR|'..safe(err)) end
    end
end
local function summary()
    local blue,yellow=0,0
    for _,kind in ipairs({'FOCUS','PART','BEAM'}) do for _,r in ipairs(records[kind]) do
        if r.active then if r.role=='BLUE' then blue=blue+1 elseif r.role=='YELLOW' then yellow=yellow+1 end end
    end end
    return blue,yellow
end
function controller.GetReport()
    local blue,yellow=summary()
    local rows={VERSION,'PLACE|'..tostring(game.PlaceId),'GAME_ID|'..tostring(game.GameId),
        'STATE|'..(stopped and 'STOPPED' or 'RUNNING'),'STOP_REASON|'..stopReason,'CLEANUP_CONFIRMED|'..tostring(cleanupComplete),
        'AUTO_QB_STOP|'..autoState,'AUTO_QB_BEFORE_STOP|'..initialAutoReport,
        'SWEEP|'..sweep,'COMPLETED_SWEEPS|'..completed,'CURRENT_SWEEP_VISITED|'..(scan and scan.visited or 0),
        'TOTAL_VISITED|'..totalVisited,'SCAN_COMPLETE|'..tostring(scan and scan.complete==true),
        'GROUND|'..(ground and ground.Parent and path(ground) or 'NONE'),'CANDIDATE_ACTIVE_BLUE|'..blue,'CANDIDATE_ACTIVE_YELLOW|'..yellow,
        'CONSIDERED|'..considered,'RECORDS_REPLACED_OR_DROPPED|'..dropped,'INCREMENTAL_DROPS|'..incrementalDrops,
        'MAX_TICK_SECONDS|'..num(maxTick),'COPY_RESULT|'..copyResult,'COPY_API|'..copyAPI,
        'COPY_ERROR|'..copyError,'CLIPBOARD_READBACK|'..readback,'FILE_RESULT|'..fileResult,
        'POLICY|READ_PUBLIC_INSTANCES_ONLY; NO_THROW; NO_REMOTE_CALL; NO_YUNA_HOOK; NO_AUTO_RESUME',
        'COMPARISON|FF3_AUTO_QB_FF3_V15.2_INITIAL_DISCOVERY_AND_ACTIVE_GEOMETRY',
        'LIMITS|80_SCAN_WORK_OR_1.5MS_PER_40MS; 8_RETAINED_REFRESHES_PER_80MS; RECORDS_RANKED_AND_BOUNDED',
        'LIMITATION|Qualified individual geometry is not proof of a unique LOS pair, direction, or in-game throwing; samples are not frame-complete'}
    local root=me.Character and me.Character:FindFirstChild('HumanoidRootPart')
    if root then rows[#rows+1]='LOCAL_QB_POSITION|'..vec(root.Position) end
    if scan then local classes={}; for name in pairs(scan.classes) do classes[#classes+1]=name end; table.sort(classes)
        for _,name in ipairs(classes) do rows[#rows+1]='CLASS|'..name..'|'..scan.classes[name] end end
    for _,kind in ipairs({'FOCUS','GROUND','PART','BEAM','GUI','VALUE'}) do
        rows[#rows+1]='RECORD_COUNT|'..kind..'|'..#records[kind]
        for _,r in ipairs(records[kind]) do
            rows[#rows+1]='OBJECT|'..r.id..'|'..r.kind..'|'..r.name..'|rank='..r.score
            rows[#rows+1]='CURRENT|'..r.id..'|'..(r.current or 'NONE')
            rows[#rows+1]='V15_2_INITIAL_DISCOVERY|'..r.id..'|'..(r.discovery or 'NONE')
            rows[#rows+1]='V15_2_ADDED_DISCOVERY|'..r.id..'|'..(r.kind=='BEAM' and r.live or r.discovery or 'NONE')
            rows[#rows+1]='V15_2_ACTIVE_GEOMETRY|'..r.id..'|'..(r.live or 'NONE')
            rows[#rows+1]='FIRST_OBSERVED|'..r.id..'|'..(r.first or 'NONE')
            rows[#rows+1]='FIRST_ACTIVE_GEOMETRY|'..r.id..'|'..(r.firstActiveGeometry or 'NONE')
            rows[#rows+1]='LAST_ACTIVE_GEOMETRY|'..r.id..'|'..(r.lastActive or 'NONE')
            rows[#rows+1]='TIMING|'..r.id..'|first='..num(r.seen-started)..'; changed='..num((r.changed or r.seen)-started)
                ..'; changes='..r.changes..'; firstActive='..(r.firstActive and num(r.firstActive-started) or 'NONE')
        end
    end
    for _,line in ipairs(history) do rows[#rows+1]='EVENT|'..line end
    return table.concat(rows,'\n')
end
function controller.GetFocusReport()
    local rows={VERSION,'FOCUS|USER_IDENTIFIES_LineDown_AS_BLUE_LOS; NAME_ALONE_NOT_GEOMETRY_PROOF',
        'STATE|'..(stopped and 'STOPPED' or 'RUNNING'),'NAMED_OBJECTS|'..#records.FOCUS,
        'SCANNED|'..totalVisited,'COMPLETED_SWEEPS|'..completed,'GROUND|'..(ground and ground.Parent and path(ground) or 'NONE'),
        'COPY_RESULT|'..copyResult,'COPY_API|'..copyAPI,'COPY_ERROR|'..copyError,'CLIPBOARD_READBACK|'..readback}
    for _,r in ipairs(records.FOCUS) do
        rows[#rows+1]='OBJECT|'..r.id..'|'..r.name
        rows[#rows+1]='CURRENT|'..(r.current or 'NONE')
        rows[#rows+1]='V15_2_DISCOVERY|'..(r.discovery or 'NONE')
        rows[#rows+1]='V15_2_ACTIVE|'..(r.live or 'NONE')
        rows[#rows+1]='FIRST_OBSERVED|'..(r.first or 'NONE')
        rows[#rows+1]='LAST_ACTIVE_GEOMETRY|'..(r.lastActive or 'NONE')
    end
    if #records.FOCUS==0 then rows[#rows+1]='NOTE|LineDown not recorded yet. Continue searching or open FULL for other candidates.' end
    return table.concat(rows,'\n')
end
local function copySnapshot(payload)
    local fn=setclipboard
    copyAPI=type(fn)=='function' and 'setclipboard' or 'NONE'
    if type(fn)~='function' and type(toclipboard)=='function' then fn=toclipboard; copyAPI='toclipboard' end
    copyError='NONE'; readback='UNAVAILABLE'
    if type(fn)~='function' then copyResult='UNAVAILABLE'; return end
    -- One call, before any file I/O. A false return is a failed operation.
    local ok,result=pcall(fn,payload)
    if not ok or result==false then copyResult='FAILED'; copyError=ok and 'RETURNED_FALSE' or safe(result,600); return end
    copyResult='API_RETURNED_NO_READBACK'
    if type(getclipboard)=='function' then
        local readOK,value=pcall(getclipboard)
        if not readOK then readback='FAILED'
        elseif value==payload then readback='MATCHED'; copyResult='READBACK_MATCHED'
        else readback='MISMATCH'; copyResult='READBACK_MISMATCH' end
    end
end
local function preserve(copy)
    if copy then copySnapshot(controller.GetFocusReport()) end
    if type(writefile)~='function' then fileResult='UNAVAILABLE' end
    local report=controller.GetReport()
    if type(writefile)=='function' then fileResult=pcall(writefile,'PELICAN_FF3_LOS_SEARCH_REPORT.txt',report) and 'API_ACCEPTED' or 'FAILED' end
    env.PELICAN_FF3_LOS_SEARCH_REPORT=controller.GetReport()
end
function controller.Copy(payload)
    if stopped then return 'STOPPED' end
    copySnapshot(payload or controller.GetFocusReport()); preserve(false)
    if copyResult~='READBACK_MATCHED' and controller.ShowReport then controller.ShowReport() end
    return copyResult
end
function controller.Rescan() if stopped then return false end; startSweep(); return true end
function controller.Stop(reason)
    if cleanupComplete then return true end
    stopped=true; controller.IsStopped=true; stopReason=safe(reason or 'USER_END')
    local remaining={}
    for _,c in ipairs(connections) do if not pcall(function() c:Disconnect() end) then remaining[#remaining+1]=c end end
    connections=remaining
    if gui then if pcall(function() gui:Destroy() end) then gui=nil end end
    cleanupComplete=#connections==0 and gui==nil
    if cleanupComplete and scan then scan.stack={}; scan.q={}; scan.seen={} end
    preserve(true)
    if cleanupComplete and env[KEY]==controller then env[KEY]=nil end
    return cleanupComplete
end
local function connect(signal,fn) local c=signal:Connect(fn); connections[#connections+1]=c; return c end
local auto=env.PELICAN_FF3_AUTO_QB
if auto then
    if type(auto.GetReport)=='function' then
        local ok,report=pcall(auto.GetReport)
        if ok and type(report)=='string' then
            local fields={}
            for _,name in ipairs({'GATE','LOS_STATUS','LOS_MARKER_CANDIDATES','LOS_SCAN_VISITED','ATTEMPTS'}) do
                fields[#fields+1]=name..'='..(report:match('\n'..name..'|([^\n]+)') or 'NONE')
            end
            initialAutoReport=table.concat(fields,'; ')
        end
    end
    local ok,clean=pcall(function() return auto.Stop('LOS_DIAGNOSTIC') end)
    if not ok or clean~=true then error('Pelican LOS search: Auto QB cleanup unconfirmed; stop it with its red X first') end
    autoState='CONFIRMED_STOPPED'
end
env[KEY]=controller
local built,buildError=pcall(function()
    gui=Instance.new('ScreenGui'); gui.Name=VERSION; gui.ResetOnSpawn=false; gui.DisplayOrder=1001; gui.Parent=pg
    local function button(name,text,x,width,y)
        local b=Instance.new('TextButton'); b.Name=name; b.Text=text; b.TextSize=10; b.Font=Enum.Font.GothamMedium
        b.Position=UDim2.new(1,x,0,y); b.Size=UDim2.fromOffset(width,22); b.BackgroundColor3=Color3.fromRGB(25,33,40)
        b.TextColor3=Color3.new(1,1,1); b.ClipsDescendants=true; b.Parent=gui; return b
    end
    status=button('Status','LOS SEARCH',-166,138,62)
    local kill=button('Kill','X',-26,22,62); kill.BackgroundColor3=Color3.fromRGB(195,40,40)
    copyButton=button('Copy','COPY',-166,79,87); scanButton=button('Rescan','RESCAN',-84,80,87)
    reportButton=button('Report','REPORT / MANUAL COPY',-166,162,112)
    copyButton.Visible=false; scanButton.Visible=false; reportButton.Visible=false
    local viewer=Instance.new('Frame'); viewer.Name='ReportViewer'; viewer.Size=UDim2.fromOffset(282,218)
    viewer.Position=UDim2.new(1,-290,0,137); viewer.BackgroundColor3=Color3.fromRGB(22,28,34); viewer.Visible=false; viewer.Parent=gui
    local modeButton=button('ReportMode','LineDown',0,84,0); modeButton.Parent=viewer; modeButton.Position=UDim2.fromOffset(4,0)
    local help=Instance.new('TextLabel'); help.Name='CopyHelp'; help.Size=UDim2.fromOffset(158,22); help.Position=UDim2.fromOffset(90,0)
    help.Text='Hold text to select / copy'; help.TextSize=10; help.BackgroundTransparency=1; help.TextColor3=Color3.new(1,1,1); help.Parent=viewer
    local close=button('CloseReport','X',0,24,0); close.Parent=viewer; close.Position=UDim2.fromOffset(254,0)
    local scroll=Instance.new('ScrollingFrame'); scroll.Name='ReportScroll'; scroll.Size=UDim2.fromOffset(274,164)
    scroll.Position=UDim2.fromOffset(4,24); scroll.BackgroundTransparency=1; scroll.ScrollBarThickness=4; scroll.Parent=viewer
    local text=Instance.new('TextBox'); text.Name='ReportText'; text.Position=UDim2.fromOffset(2,0); text.Size=UDim2.new(1,-8,0,164)
    text.ClearTextOnFocus=false; text.MultiLine=true; text.TextEditable=true; text.TextWrapped=true; text.TextSize=11
    text.Font=Enum.Font.Code; text.TextXAlignment=Enum.TextXAlignment.Left; text.TextYAlignment=Enum.TextYAlignment.Top
    text.BackgroundTransparency=1; text.TextColor3=Color3.new(1,1,1); text.Parent=scroll
    local prev=button('ReportPrevious','<',0,24,0); prev.Parent=viewer; prev.Position=UDim2.fromOffset(4,192)
    local pageLabel=Instance.new('TextLabel'); pageLabel.Name='ReportPage'; pageLabel.Size=UDim2.fromOffset(44,22); pageLabel.Position=UDim2.fromOffset(30,192)
    pageLabel.BackgroundTransparency=1; pageLabel.TextSize=10; pageLabel.TextColor3=Color3.new(1,1,1); pageLabel.Parent=viewer
    local select=button('SelectReport','SELECT',0,60,0); select.Parent=viewer; select.Position=UDim2.fromOffset(76,192)
    local copyPage=button('CopyReportPage','COPY PAGE',0,106,0); copyPage.Parent=viewer; copyPage.Position=UDim2.fromOffset(140,192)
    local nextPage=button('ReportNext','>',0,24,0); nextPage.Parent=viewer; nextPage.Position=UDim2.fromOffset(250,192)
    local mode,pages,page='FOCUS',{},1
    local function paginate(snapshot)
        pages={}; local start=1
        while start<=#snapshot do
            local last=math.min(#snapshot,start+2999)
            if last<#snapshot then
                local cut
                for n in snapshot:sub(start,last):gmatch('()\n') do cut=n end
                if cut and cut>1 then last=start+cut-1
                else
                    while last>=start do local b=snapshot:byte(last+1); if not b or b<128 or b>=192 then break end; last=last-1 end
                end
            end
            pages[#pages+1]=snapshot:sub(start,last); start=last+1
        end
        if #pages==0 then pages={''} end
    end
    local function renderPage()
        pcall(function() text:ReleaseFocus() end)
        page=math.max(1,math.min(page,#pages)); text.Text=pages[page]
        local lineCount=1; for _ in text.Text:gmatch('\n') do lineCount=lineCount+1 end
        local height=math.max(164,(lineCount+math.ceil(#text.Text/35))*14)
        text.Size=UDim2.new(1,-8,0,height); scroll.CanvasSize=UDim2.fromOffset(0,height); scroll.CanvasPosition=Vector2.new(0,0)
        pageLabel.Text=page..' / '..#pages; modeButton.Text=mode=='FOCUS' and 'LineDown' or 'FULL'
        prev.Visible=#pages>1; nextPage.Visible=#pages>1; copyPage.Text='COPY PAGE'
    end
    function controller.ShowReport(requestedMode)
        if stopped or not gui then return false end
        if viewer.Visible and requestedMode==nil then return true end
        mode=requestedMode=='FULL' and 'FULL' or 'FOCUS'
        paginate(mode=='FULL' and controller.GetReport() or controller.GetFocusReport()); page=1; renderPage(); viewer.Visible=true
        return true
    end
    connect(modeButton.Activated,function() controller.ShowReport(mode=='FOCUS' and 'FULL' or 'FOCUS') end)
    connect(close.Activated,function() viewer.Visible=false; pcall(function() text:ReleaseFocus() end) end)
    connect(prev.Activated,function() page=page-1; renderPage() end)
    connect(nextPage.Activated,function() page=page+1; renderPage() end)
    connect(select.Activated,function() pcall(function() text:CaptureFocus(); text.CursorPosition=#text.Text+1; text.SelectionStart=1 end) end)
    connect(copyPage.Activated,function()
        controller.Copy(pages[page]); copyPage.Text=copyResult=='READBACK_MATCHED' and 'VERIFIED' or copyResult=='API_RETURNED_NO_READBACK' and 'SENT?' or 'USE SELECT'
    end)
    connect(status.Activated,function()
        copyButton.Visible=not copyButton.Visible; scanButton.Visible=copyButton.Visible; reportButton.Visible=copyButton.Visible
        if not copyButton.Visible then viewer.Visible=false; pcall(function() text:ReleaseFocus() end) end
    end)
    connect(reportButton.Activated,function()
        if viewer.Visible then viewer.Visible=false; pcall(function() text:ReleaseFocus() end) else controller.ShowReport() end
    end)
    connect(copyButton.Activated,function()
        controller.Copy(); copyButton.Text=copyResult=='READBACK_MATCHED' and 'VERIFIED' or copyResult=='API_RETURNED_NO_READBACK' and 'SENT?' or 'VIEW TEXT'
    end)
    connect(scanButton.Activated,function() controller.Rescan() end)
    connect(kill.Activated,function() controller.Stop('USER_END') end)
    local stop=Instance.new('BindableEvent'); stop.Name='Stop'; stop.Parent=gui; connect(stop.Event,function() controller.Stop('EXTERNAL_STOP') end)
    if me.OnTeleport then connect(me.OnTeleport,function() controller.Stop('TELEPORT') end) end
    local function added(o)
        if stopped or not scan or not (o:IsA('BasePart') or o:IsA('Beam') or o:IsA('ValueBase') or o:IsA('GuiObject')) then return end
        if o:IsDescendantOf(gui) then return end
        if scan.tail-scan.i>=512 then incrementalDrops=incrementalDrops+1; return end
        if scan.seen[o] then return end
        scan.tail=scan.tail+1; scan.q[scan.tail]=o; scan.complete=false
    end
    for _,root in ipairs(rootServices) do connect(root.DescendantAdded,added) end
    startSweep()
    -- Cheap direct lookup gives a root-level LineDown report immediately.
    -- Nested instances are still discovered by the bounded full traversal.
    for _,root in ipairs(rootServices) do
        local named=root:FindFirstChild('LineDown')
        if named then local ok,err=pcall(inspect,named); if not ok then log('FOCUS_ERROR|'..safe(err)) end end
    end
    connect(Run.Heartbeat,function()
        local now=os.clock(); if stopped or busy or now-lastTick<.04 then return end
        lastTick=now; busy=true; local began=os.clock()
        local ok,err=pcall(function()
            if scan and scan.complete and now>=nextSweep then startSweep() end
            scanChunk()
            if now>=nextRefresh then nextRefresh=now+.08; refreshChunk() end
            if now>=nextUI then
                nextUI=now+.25; local blue,yellow=summary()
                status.Text=completed>0 and 'WATCH B'..blue..' Y'..yellow or 'SEARCH '..(scan and scan.visited or 0)
            end
            if now>=nextSave then nextSave=now+5; preserve(false) end
        end)
        maxTick=math.max(maxTick,os.clock()-began); busy=false
        if not ok then log('TICK_ERROR|'..safe(err)); controller.Stop('RUNTIME_ERROR') end
    end)
end)
if not built then controller.Stop('INIT_FAILED'); error('Pelican LOS search: '..safe(buildError)) end
preserve(false)
return controller
