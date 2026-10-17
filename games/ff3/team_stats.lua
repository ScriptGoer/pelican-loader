-- Row-based FF3 stat reader and conservative policy. Qualified game stats
-- handlers can populate data while idle. No invented remotes, Yuna startup
-- automation, OVR judgments or fabricated corner denominators.
local context=... or {}
local options=context.Options or {}
assert(type(options)=='table','TeamStats options must be a table')
local Players,Run=game:GetService('Players'),game:GetService('RunService')
local me=assert(Players.LocalPlayer,'LocalPlayer required')
assert(game.PlaceId==82866880824588,'Team stats requires the observed FF3 live place')
local env=type(getgenv)=='function' and getgenv() or _G
local ctl={Version='PELICAN_FF3_TEAM_STATS_V1',IsStopped=false}
local enabled=options.Enabled~=false
local policy={MinTargets=80,MinExtraTargets=10,MaxCatchUpper=.30,MinAllowedLower=.70,
    SevereTargets=250,SevereCatchUpper=.15,SevereAllowedLower=.85,
    MinTeamSize=3,MinBadFraction=.67,TeamStableSeconds=10,GraceSeconds=20,RetentionSeconds=600}
for _,name in ipairs({'Enabled','AutoBlacklist','AutoLeave','AutoInspect'}) do assert(options[name]==nil or type(options[name])=='boolean','TeamStats '..name..' must be boolean') end
for key,default in pairs(policy) do
    local value=options[key]
    if value~=nil then
        assert(type(value)=='number' and value==value and value>0 and value<1e6,'Invalid TeamStats '..key)
        if default<1 then assert(value<1,'TeamStats fraction must be below one') end
        policy[key]=value
    end
end
assert(policy.SevereTargets>=policy.MinTargets and policy.SevereCatchUpper<=policy.MaxCatchUpper and policy.SevereAllowedLower>=policy.MinAllowedLower,'Extreme policy must be stricter than the ordinary policy')
local ledger=env.PELICAN_FF3_TEAM_EVIDENCE
if type(ledger)~='table' or getmetatable(ledger)~=nil then ledger={};env.PELICAN_FF3_TEAM_EVIDENCE=ledger end
local connection,inputConnection,clean,stopped,lastScan=nil,nil,false,false,-math.huge
local started,status,fatal=os.clock(),'WAIT_STATS_UI','NONE'
local lastSave=-math.huge
local receipts,grades,rosterSignature,rosterSince={}, {},'',os.clock()
local stableSignature,stableSince,lastRows='',os.clock(),{}
local lastScope,lastRole,closedServer,visibleStats='NONE','NONE',false,false
local leaveAttempted,lastLeave,scans,rowsRead=false,'NONE',0,0
local ui={phase='IDLE',nextAt=0,serial=0,source='PASSIVE_UI',status='WAIT_IDLE'}
local rowHistory={}
local function text(v,n) return tostring(v):gsub('[\r\n|]',' '):sub(1,n or 180) end
local function note(kind,value)
    receipts[#receipts+1]=kind..'|'..text(value,800)
    if #receipts>100 then table.remove(receipts,1) end
end
local function is(o,k) return typeof(o)=='Instance' and o:IsA(k) end
local function normalized(s) return s:gsub('<[^>]*>',''):gsub('^%s+',''):gsub('%s+$','') end
local function key(s) return normalized(s):lower():gsub('[^%a]','') end
local function username(s) return normalized(s):gsub('^%d+[%.%)%-%:]%s*',''):gsub('^@',''):lower() end
local function integer(n) return type(n)=='number' and n==n and n>=0 and n<=1e9 and n==math.floor(n) end
local function userId(n) return type(n)=='number' and n==n and n>0 and n<1e15 and n==math.floor(n) end
local function wilson(n,d)
    if not integer(n) or not integer(d) or d==0 or n>d then return end
    local z=1.9599639845401;local z2=z*z;local p=n/d
    local center=(p+z2/(2*d))/(1+z2/d)
    local radius=z*math.sqrt(p*(1-p)/d+z2/(4*d*d))/(1+z2/d)
    return math.max(0,center-radius),math.min(1,center+radius)
end
local function ratio(raw)
    local n,d=raw:match('%(%s*(%d+)%s*/%s*(%d+)%s*%)')
    n,d=tonumber(n),tonumber(d)
    if not integer(n) or not integer(d) or n>d then return end
    local percent=tonumber(raw:match('([%d%.]+)%%'))
    if percent and d>0 and math.abs(percent-100*n/d)>1.1 then return end
    return n,d
end
local function roster()
    local all,byName,aliases,teammates={}, {},{},{}
    for _,p in ipairs(Players:GetPlayers()) do
        if #all>=64 then error('TEAM_STATS_ROSTER_LIMIT') end
        if userId(p.UserId) then
            all[#all+1]=p;byName[p.Name:lower()]=p
            for _,s in ipairs({p.Name,p.DisplayName or p.Name}) do
                local a=s:lower();aliases[a]=aliases[a] or {};aliases[a][p.UserId]=p
            end
            if p~=me and me.Team and not me.Neutral and not p.Neutral and p.Team==me.Team then teammates[#teammates+1]=p end
        end
    end
    return all,byName,aliases,teammates
end
local function visibleWithin(o,root)
    for _=1,12 do
        if not o or o==root then return o==root end
        if is(o,'GuiObject') and not o.Visible then return false end
        o=o.Parent
    end
    return false
end
local function cells(parent,root)
    local result={}
    local children=parent:GetChildren();if #children>128 then error('TEAM_STATS_COLUMN_LIMIT') end
    for _,o in ipairs(children) do
        if (is(o,'TextLabel') or is(o,'TextButton')) and visibleWithin(o,root) then
            local x,w=o.AbsolutePosition.X,o.AbsoluteSize.X
            if type(x)~='number' or type(w)~='number' or w<=0 then return end
            result[#result+1]={object=o,raw=normalized(o.Text),x=x+w/2}
        end
    end
    return result
end
local function scopeSignature(stats)
    local tabs=stats:FindFirstChild('StatsType');if not tabs then return 'NO_SCOPE_CONTROLS' end
    local result={}
    for _,name in ipairs({'game','global','me','server'}) do
        local o=tabs:FindFirstChild(name)
        if not o then return 'MISSING_SCOPE_CONTROL' end
        local function color(c) return c and string.format('%.3f,%.3f,%.3f',c.R,c.G,c.B) or '?' end
        result[#result+1]=name..':'..color(o.BackgroundColor3)..':'..color(o.TextColor3)..':'..tostring(o.BackgroundTransparency)
    end
    -- Opaque UI-state identity: no invented interpretation of selected colors.
    return table.concat(result,';')
end
local function read()
    local pg=me:FindFirstChildOfClass('PlayerGui')
    local main=pg and pg:FindFirstChild('MainGui');local stats=main and main:FindFirstChild('Stats')
    if not stats then return nil,'WAIT_STATS_UI' end
    local info,scroll=stats:FindFirstChild('Info'),stats:FindFirstChild('ScrollingFrame')
    if not info or not scroll then return nil,'WAIT_STATS_TABLE' end
    local headers=cells(info,stats)
    if not headers or #headers<2 or #headers>16 then return nil,'WAIT_STATS_HEADERS' end
    table.sort(headers,function(a,b) return a.x<b.x end)
    local playerColumn,ratioColumn,role,minGap=nil,nil,nil,math.huge
    local wrSignature=false
    for i,h in ipairs(headers) do
        h.key=key(h.raw)
        if h.key=='intsallowed' then wrSignature=true end
        if i>1 then minGap=math.min(minGap,h.x-headers[i-1].x) end
        if h.key=='player' then if playerColumn then return nil,'DUPLICATE_PLAYER_COLUMN' end;playerColumn=i end
        if h.key=='catchtarget' or h.key=='catchtargets' then
            if ratioColumn then return nil,'AMBIGUOUS_RATIO_COLUMNS' end;ratioColumn=i;role='WR'
        elseif h.key=='completionsallowedtargets' or h.key=='completionsallowedtarget' or h.key=='compallowedtargets' or h.key=='compallowedtarget' or h.key=='catchesallowedtargets' then
            if ratioColumn then return nil,'AMBIGUOUS_RATIO_COLUMNS' end;ratioColumn=i;role='CB'
        end
    end
    if not playerColumn then return nil,'PLAYER_COLUMN_UNKNOWN' end
    if role=='WR' and (ui.page=='CB' or not wrSignature and ui.page~='WR') or role=='CB' and ui.page=='WR' then role=nil end
    if not role then
        local labels={};for _,h in ipairs(headers) do labels[#labels+1]=h.raw end
        note('UNVERIFIED_HEADERS',table.concat(labels,','))
        role='UNKNOWN'
    end
    if minGap<=1 then return nil,'OVERLAPPING_HEADERS' end
    local all,byName,aliases,team=roster()
    local rows,ids,allResolved={}, {},true
    local children=scroll:GetChildren();if #children>128 then error('TEAM_STATS_ROW_LIMIT') end
    for ordinal,row in ipairs(children) do
        if row.Name=='Template' and is(row,'GuiObject') and visibleWithin(row,stats) then
            local fields=cells(row,stats)
            if fields and #fields==#headers then
                local mapped,valid={},true
                for _,field in ipairs(fields) do
                    local best,distance
                    for i,h in ipairs(headers) do if not distance or math.abs(field.x-h.x)<distance then best,distance=i,math.abs(field.x-h.x) end end
                    if distance>minGap*.35 or mapped[best] then valid=false;break end
                    mapped[best]=field
                end
                if valid then
                    local name=username(mapped[playerColumn].raw)
                    local owner=byName[name];local confidence=owner and 'EXACT_USERNAME' or nil
                    if aliases[name] then
                        local count,candidate=0,nil
                        for _,p in pairs(aliases[name]) do candidate=p;count=count+1 end
                        if count~=1 then owner=nil;confidence='AMBIGUOUS_SERVER_LABEL'
                        elseif not owner then owner=candidate;confidence='UNIQUE_DISPLAY_CANDIDATE' end
                    end
                    local n,d
                    if ratioColumn then n,d=ratio(mapped[ratioColumn].raw) end
                    local raw={};for i,h in ipairs(headers) do raw[#raw+1]=h.raw..'='..text(mapped[i].raw,80) end
                    rows[#rows+1]={player=owner,confidence=confidence,name=mapped[playerColumn].raw,n=n,d=d,role=role,ordinal=ordinal,raw=table.concat(raw,';')}
                    if not owner or ids[owner.UserId] then allResolved=false else ids[owner.UserId]=true end
                else allResolved=false;note('ROW_REJECT','column alignment '..ordinal) end
            else allResolved=false end
        end
    end
    local closed=allResolved and #all>=2 and #rows==#all
    for _,p in ipairs(all) do if not ids[p.UserId] then closed=false end end
    for _,r in ipairs(rows) do
        if r.confidence=='UNIQUE_DISPLAY_CANDIDATE' and closed then r.confidence='CLOSED_SERVER_ROSTER_DISPLAY'
        elseif r.confidence=='UNIQUE_DISPLAY_CANDIDATE' then r.player=nil;r.confidence='DISPLAY_ONLY_UNASSIGNED' end
    end
    local scope=scopeSignature(stats)
    if scope=='NO_SCOPE_CONTROLS' or scope=='MISSING_SCOPE_CONTROL' then return nil,'WAIT_STATS_SCOPE' end
    return {rows=rows,team=team,role=role,scope=scope,closed=closed,visible=stats.Visible==true},role=='UNKNOWN' and 'UNKNOWN_ROLE_OR_DENOMINATOR' or 'READ_OK'
end
local function poor(role,n,d)
    local low,high=wilson(n,d);if not low then return false end
    return role=='WR' and high<policy.MaxCatchUpper or role=='CB' and low>policy.MinAllowedLower
end
local function cancelJob()
    if ui.thread and coroutine.status(ui.thread)~='dead' then
        local ok,problem=pcall(task.cancel,ui.thread)
        if not ok then return false,problem end
    end
    ui.thread=nil;return true
end
local function restoreVisibility()
    if ui.stats and ui.stats.Parent and ui.serial==ui.startSerial and ui.originalVisible~=nil
        and ui.stats.Visible~=ui.originalVisible then ui.stats.Visible=ui.originalVisible end
end
local function nativeHandler(button,expected)
    if not is(button,'TextButton') or key(button.Text or '')~=key(expected) then return nil,'BUTTON_SCHEMA_UNVERIFIED' end
    local ok,list=pcall(getconnections,button.MouseButton1Click)
    if not ok or type(list)~='table' or #list>16 then return nil,'BUTTON_CONNECTIONS_UNAVAILABLE' end
    local fn
    for _,c in ipairs(list) do
        if (c.Connected==true or c.Enabled==true) and c.Enabled~=false and type(c.Function)=='function' then
            if fn and fn~=c.Function then return nil,'BUTTON_HANDLERS_AMBIGUOUS' end
            fn=c.Function
        end
    end
    return fn,fn and 'MATCHED_NATIVE_MOUSE_CLICK' or 'NO_NATIVE_MOUSE_CLICK_HANDLER'
end
local function launch(fn,nextPhase)
    ui.phase='JOB';ui.done=false;ui.problem=nil;ui.nextPhase=nextPhase;ui.deadline=os.clock()+5
    ui.thread=task.spawn(function()
        local ok,problem=pcall(fn)
        local restored,restoreError=pcall(restoreVisibility)
        if not restored then ok=false;problem=restoreError end
        ui.problem=not ok and problem or nil;ui.done=true
    end)
    assert(type(ui.thread)=='thread','Stats inspection task did not return a cancellable thread')
end
local function inspect()
    if options.AutoInspect==false then ui.status='DISABLED';return false end
    if type(getconnections)~='function' or not task or type(task.spawn)~='function' or type(task.cancel)~='function' then ui.status='PASSIVE_ONLY_CAPABILITY_UNAVAILABLE';return false end
    local allowed=type(context.CanInspect)=='function' and context.CanInspect()
    if ui.phase=='IDLE' and ui.stats and ui.stats.Visible and ui.serial~=ui.startSerial then ui.source='PASSIVE_UI';ui.page=nil end
    if ui.phase~='IDLE' and (not allowed or not ui.stats.Parent or ui.serial~=ui.startSerial and ui.stats.Visible) then
        assert(cancelJob());restoreVisibility();ui.phase='IDLE';ui.nextAt=os.clock()+30;ui.status='CANCELLED_FOR_PLAY_USER_OR_REPLACED_UI';stableSignature=''
        if not ui.stats.Parent then ui.page=nil;ui.source='PASSIVE_UI' end
        return false
    end
    if ui.phase=='IDLE' then
        if not allowed or os.clock()<ui.nextAt then return false end
        ui.nextAt=os.clock()+30
        local pg=me:FindFirstChildOfClass('PlayerGui');local main=pg and pg:FindFirstChild('MainGui')
        local stats=main and main:FindFirstChild('Stats')
        if not stats or stats.Visible then ui.status='WAIT_HIDDEN_STATS';return false end
        local categories,tabs=stats:FindFirstChild('Category'),stats:FindFirstChild('StatsType')
        local server,why=nativeHandler(tabs and tabs:FindFirstChild('server'),'Server')
        local wr,wrWhy=nativeHandler(categories and categories:FindFirstChild('wr'),'Receiver')
        local cb,cbWhy=nativeHandler(categories and categories:FindFirstChild('db'),'Corner')
        if not server or not wr then ui.status=not server and why or wrWhy;return false end
        local prior=read();ui.restorePage=prior and prior.role=='CB' and cb and 'CB' or 'WR';ui.restoreRole=ui.restorePage=='CB' and cb or wr
        ui.stats,ui.wr,ui.cb,ui.server=stats,wr,cb,server;ui.startSerial=ui.serial;ui.originalVisible=stats.Visible
        ui.unreadable=false
        ui.status=cb and 'NATIVE_SERVER_WR_CB' or 'NATIVE_SERVER_WR; CORNER='..tostring(cbWhy)
        stableSignature='';launch(server,'START_WR');return true
    end
    if ui.phase=='JOB' then
        if not ui.done then assert(os.clock()<ui.deadline,'Native stats handler timed out; no automatic retry');return true end
        assert(not ui.problem,ui.problem)
        ui.thread=nil;ui.phase=ui.nextPhase;ui.deadline=os.clock()+5
        if ui.phase=='READ_WR' then ui.page='WR' elseif ui.phase=='READ_CB' then ui.page='CB' elseif ui.phase=='DONE' then ui.page=ui.restorePage end
        if ui.stats.Parent and ui.serial==ui.startSerial and ui.stats.Visible~=ui.originalVisible then ui.stats.Visible=ui.originalVisible end
    end
    if ui.phase=='START_WR' then ui.source='NATIVE_SERVER_HANDLER';launch(ui.wr,'READ_WR');return true end
    if ui.phase=='START_CB' then launch(ui.cb,'READ_CB');return true end
    if ui.phase=='RESTORE' then launch(ui.restoreRole,'DONE');return true end
    if ui.phase=='DONE' then ui.phase='IDLE';ui.nextAt=os.clock()+30;ui.status=ui.unreadable and 'NO_READABLE_DATA_NO_ACTION' or 'INSPECTED';return false end
    if (ui.phase=='READ_WR' or ui.phase=='READ_CB') and os.clock()>=ui.deadline then
        ui.unreadable=true;ui.phase='RESTORE';ui.status='NO_READABLE_DATA_NO_ACTION';return true
    end
    return false
end
local function assess(r,scope)
    local uid=tostring(r.player.UserId);local id=uid..':'..r.role
    local old=ledger[id]
    local stream=tostring(game.JobId or 'NO_JOB')..':'..scope
    if type(old)~='table' or getmetatable(old)~=nil or old.stream~=stream or not integer(old.n) or not integer(old.d)
        or not integer(old.baseN) or not integer(old.baseD) or old.baseN>old.n or old.baseD>old.d
        or r.d<old.d or r.n<old.n or r.n-old.n>r.d-old.d then
        if not ledger[id] then local size=0;for _ in pairs(ledger) do size=size+1 end;if size>=512 then ledger[next(ledger)]=nil end end
        old={stream=stream,n=r.n,d=r.d,baseN=r.n,baseD=r.d,bad=false};ledger[id]=old
    end
    if r.d>=old.baseD+policy.MinExtraTargets then
        local totalPoor=r.d>=policy.MinTargets and poor(r.role,r.n,r.d)
        local windowPoor=poor(r.role,r.n-old.baseN,r.d-old.baseD)
        old.bad=totalPoor and windowPoor
        old.hasFreshWindow=true
        old.baseN,old.baseD=r.n,r.d
        note('FRESH_WINDOW',uid..' '..r.role..' bad='..tostring(old.bad)..' total='..r.n..'/'..r.d)
    end
    if r.d<policy.MinTargets or not poor(r.role,r.n,r.d) then old.bad=false end
    local low,high=wilson(r.n,r.d)
    local severe=r.d>=policy.SevereTargets and (r.role=='WR' and high<policy.SevereCatchUpper or r.role=='CB' and low>policy.SevereAllowedLower)
    if severe and not old.hasFreshWindow then old.bad=true end
    old.n,old.d=r.n,r.d
    return {bad=old.bad==true,role=r.role,n=r.n,d=r.d,
        verdict=r.d<policy.MinTargets and 'INSUFFICIENT_SAMPLE' or old.bad and (severe and not old.hasFreshWindow and 'EXTREME_AGGREGATE' or 'CONFIRMED_POOR') or poor(r.role,r.n,r.d) and 'WATCH_NEEDS_FRESH_POOR_WINDOW' or 'NOT_POOR',
        confidence=r.confidence,at=os.clock()}
end
local function notify(player,role,grade)
    if type(context.OnGrade)=='function' then context.OnGrade(player,role,grade) end
end
function ctl.GetReport()
    local rows={ctl.Version,'STATE|'..(stopped and 'STOPPED' or enabled and status or 'OFF'),
        'ENABLED|'..tostring(enabled),'CLEANUP_CONFIRMED|'..tostring(clean),'FATAL_ERROR|'..fatal,
        'SCANS|'..scans,'ROWS_READ|'..rowsRead,'ROLE|'..lastRole,'CLOSED_SERVER_ROSTER|'..tostring(closedServer),
        'AUTO_INSPECT|'..ui.status,'INSPECT_PHASE|'..ui.phase,'DATA_SOURCE|'..ui.source,
        'STATS_VISIBLE|'..tostring(visibleStats),'SCOPE_FINGERPRINT|'..lastScope,
        'MIN_TARGETS|'..policy.MinTargets,'MIN_NEW_TARGETS|'..policy.MinExtraTargets,'RETENTION_SECONDS|'..policy.RetentionSeconds,
        'WR_POLICY|95_PERCENT_WILSON_UPPER_BELOW_'..policy.MaxCatchUpper..'; TOTAL_AND_FRESH_WINDOW_POOR',
        'EXTREME_POLICY|AT_LEAST_'..policy.SevereTargets..'_TARGETS; WR_UPPER_BELOW_'..policy.SevereCatchUpper..'; CB_LOWER_ABOVE_'..policy.SevereAllowedLower..'; FRESH_RECOVERY_TAKES_PRIORITY',
        'CB_POLICY|EXPLICIT_COMPLETIONS_ALLOWED_DENOMINATOR_ONLY; LOWER_ABOVE_'..policy.MinAllowedLower,
        'CONSISTENCY|UNCHANGED_POLLS_NEVER_COUNT_AS_NEW_PERFORMANCE; NO_INFERRED_MATCHES',
        'SOURCE|LIVE_GUI_ROW_OBJECTS; COLUMN_ALIGNMENT; UI_ONLY_NOT_SERVER_SYNC_PROOF',
        'AUTO_BLACKLIST|'..tostring(options.AutoBlacklist~=false),'AUTO_LEAVE|'..tostring(options.AutoLeave~=false),
        'LEAVE_ATTEMPTED|'..tostring(leaveAttempted),'LEAVE_RESULT|'..lastLeave}
    for uid,roles in pairs(grades) do for role,g in pairs(roles) do rows[#rows+1]='GRADE|'..uid..' '..role..' '..g.verdict..' '..g.n..'/'..g.d..' '..g.confidence end end
    for _,row in ipairs(lastRows) do rows[#rows+1]='ROW|'..row end
    for role,snapshot in pairs(rowHistory) do for _,row in ipairs(snapshot) do rows[#rows+1]='LAST_'..role..'_ROW|'..row end end
    for _,line in ipairs(receipts) do rows[#rows+1]=line end
    return table.concat(rows,'\n')
end
local function save(copy)
    if not copy and os.clock()-lastSave<5 then return end
    lastSave=os.clock()
    env.PELICAN_FF3_TEAM_STATS_REPORT=ctl.GetReport()
    if type(writefile)=='function' then pcall(writefile,'PELICAN_FF3_TEAM_STATS_REPORT.txt',ctl.GetReport()) end
    if copy and type(setclipboard)=='function' then pcall(setclipboard,ctl.GetReport()) end
end
local function resetApplied()
    local _,_,_,team=roster()
    for _,p in ipairs(team) do notify(p,'WR',{bad=false,verdict='OFF_OR_STALE'});notify(p,'CB',{bad=false,verdict='OFF_OR_STALE'}) end
end
function ctl.SetEnabled(value)
    enabled=value==true
    if not enabled then assert(cancelJob());restoreVisibility();ui.phase='IDLE';ui.nextAt=os.clock()+30;resetApplied() end
    note('ENABLED',enabled);save(false)
end
function ctl.Stop(reason)
    if clean then return true end
    stopped=true;ctl.IsStopped=true
    local jobOK,jobError=cancelJob()
    if not jobOK then fatal=text(jobError,400) end
    local restoreOK,restoreError=pcall(restoreVisibility)
    if not restoreOK then fatal=text(restoreError,400) end
    local ok=not connection or pcall(function() connection:Disconnect() end)
    if ok then connection=nil end
    local inputOK=not inputConnection or pcall(function() inputConnection:Disconnect() end)
    if inputOK then inputConnection=nil end
    local resetOK,problem=pcall(resetApplied)
    if not resetOK then fatal=text(problem,400) end
    clean=connection==nil and inputConnection==nil and jobOK and restoreOK and resetOK;note('STOP',reason);save(true);return clean
end
local function tick()
    if stopped or not enabled or os.clock()-lastScan<1 then return end
    lastScan=os.clock();scans=scans+1
    local _,_,_,team=roster();local signature={}
    local current={};for _,p in ipairs(team) do current[tostring(p.UserId)]=p end
    for uid,roles in pairs(grades) do
        for role,g in pairs(roles) do if not current[uid] or os.clock()-g.at>policy.RetentionSeconds then
            notify(g.player,role,{bad=false,verdict='STALE_OR_LEFT_TEAM'});roles[role]=nil
        end end
        if not next(roles) then grades[uid]=nil end
    end
    if inspect() then status='INSPECTING_NATIVE_STATS';save(false);return end
    local result,why=read();status=why
    for _,p in ipairs(team) do signature[#signature+1]=tostring(p.UserId) end;table.sort(signature);signature=table.concat(signature,',')
    if signature~=rosterSignature then rosterSignature=signature;rosterSince=os.clock() end
    if not result then
        save(false);return
    end
    result.scope=result.scope..':'..ui.source
    lastRole,lastScope,closedServer,visibleStats=result.role,result.scope,result.closed,result.visible
    local stable={result.role,result.scope};lastRows={}
    for _,r in ipairs(result.rows) do
        local uid=r.player and tostring(r.player.UserId) or 'UNASSIGNED'
        stable[#stable+1]=uid..':'..r.name..':'..tostring(r.n)..'/'..tostring(r.d)
        lastRows[#lastRows+1]=uid..' '..r.role..' '..text(r.confidence)..' '..r.raw
    end
    table.sort(stable);stable=table.concat(stable,'\n');rowsRead=#result.rows
    if stable~=stableSignature then stableSignature=stable;stableSince=os.clock();status='WAIT_STABLE_ROWS';save(false);return end
    if os.clock()-stableSince<1 then return end
    rowHistory[result.role=='UNKNOWN' and ui.phase=='READ_CB' and 'CB_UNVERIFIED' or result.role]=lastRows
    for _,r in ipairs(result.rows) do
        if r.role~='UNKNOWN' and r.player and r.player~=me and r.player.Team==me.Team and not r.player.Neutral and not me.Neutral and integer(r.n) and integer(r.d) and r.d>0 then
            local grade=assess(r,result.scope);local uid=tostring(r.player.UserId)
            grade.player=r.player
            grades[uid]=grades[uid] or {};grades[uid][r.role]=grade
            local applied={bad=grade.bad and options.AutoBlacklist~=false,verdict=grade.verdict,n=r.n,d=r.d,confidence=r.confidence}
            notify(r.player,r.role,applied)
        end
    end
    local inspected=ui.source=='NATIVE_SERVER_HANDLER' and (ui.phase=='READ_WR' or ui.phase=='READ_CB')
    if options.AutoLeave~=false and not leaveAttempted and result.role~='UNKNOWN' and (result.visible or inspected) and result.closed and #team>=policy.MinTeamSize
        and os.clock()-started>=policy.GraceSeconds and os.clock()-rosterSince>=policy.TeamStableSeconds then
        local known,bad=0,0
        for _,p in ipairs(team) do
            local roles=grades[tostring(p.UserId)];local fresh,poorPlayer=false,false
            for _,g in pairs(roles or {}) do if os.clock()-g.at<=3 and g.d>=policy.MinTargets then fresh=true;poorPlayer=poorPlayer or g.bad end end
            if fresh then known=known+1 end
            if poorPlayer and not (context.IsExempt and context.IsExempt(p)) then bad=bad+1 end
        end
        if known==#team and bad/#team>=policy.MinBadFraction and (not context.CanLeave or context.CanLeave()) then
            leaveAttempted=true;lastLeave='REQUESTING';note('LEAVE',bad..'/'..#team..' teammates repeatedly poor');save(true)
            local ok,value=pcall(context.RequestLeave,bad..'/'..#team..' teammates repeatedly poor')
            lastLeave=ok and value==true and 'API_ACCEPTED_UNCONFIRMED' or 'FAILED_NO_RETRY'
            if not ok then fatal=text(value,400) end
            save(true)
        end
    end
    if not stopped then
        if ui.phase=='READ_WR' then ui.phase=ui.cb and 'START_CB' or 'RESTORE'
        elseif ui.phase=='READ_CB' then ui.phase='RESTORE' end
    end
    save(false)
end
local Input=game:GetService('UserInputService')
if Input and Input.InputBegan then inputConnection=Input.InputBegan:Connect(function() ui.serial=ui.serial+1 end) end
connection=Run.Heartbeat:Connect(function()
    local before=scans
    local ok,err=pcall(tick)
    if not ok then fatal=text(err,400);status='ERROR';ctl.Stop('RUNTIME_ERROR');save(true)
        if type(context.OnError)=='function' then context.OnError(fatal) end
    elseif scans~=before and type(context.OnStatus)=='function' then
        local summary=not enabled and 'OFF' or ui.phase~='IDLE' and 'SCAN' or status~='READ_OK' and (lastRole=='UNKNOWN' and 'DATA ?' or 'WAIT') or lastRole
        local reported,problem=pcall(context.OnStatus,summary)
        if not reported then fatal=text(problem,400);ctl.Stop('STATUS_ERROR');if context.OnError then context.OnError(fatal) end end
    end
end)
if context.RegisterCleanup then context.RegisterCleanup(ctl.Stop) end
return ctl
