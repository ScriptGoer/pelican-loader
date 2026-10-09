-- PELICAN FF3 PRACTICE V13: preserved V3 held-target/manual-release control.
-- Proven baseline: supplied practice V3 115/115 HUD agreement; throw destination unverified.
-- No automatic activation, synthetic taps, remotes, global hooks or anti-tamper changes.
-- Only the positively controlled historical target4/getter14 practice layout is enabled.
local loaderContext=...
local VERSION='PELICAN_FF3_V13'
if game.PlaceId~=81310542478972 or game.GameId~=9908641400 then
 error('PELICAN practice route requires exact known FF3 practice place/universe')
end
local function cancelled()
 return loaderContext and type(loaderContext.IsCancelled)=='function' and loaderContext.IsCancelled()
end
local function runtimeError(message)
 if loaderContext and type(loaderContext.ReportRuntimeError)=='function' then
  pcall(loaderContext.ReportRuntimeError,tostring(message))
 end
end
local Players=game:GetService('Players')
local Run=game:GetService('RunService')
local me=Players.LocalPlayer
local pg=me and me:FindFirstChild('PlayerGui')
local readyDeadline=os.clock()+10
while not pg and os.clock()<readyDeadline and not cancelled() do
 task.wait(.1);pg=me and me:FindFirstChild('PlayerGui')
end
if not pg or cancelled() then error('PELICAN practice PlayerGui readiness cancelled/unavailable') end
-- Stop prior instrumented probes and require their cleanup acknowledgement.
local previousNames={'PELICAN_YUNA_RETURN_TRACE','PELICAN_YUNA_CONTROL_TEST',
 'PELICAN_FF3_PRACTICE_V13','PELICAN_FF3_LIVE_V13','PELICAN_FF3_LIVE'}
for i=1,12 do previousNames[#previousNames+1]='PELICAN_FF3_LIVE_V'..i end
for _,oldName in ipairs(previousNames) do
 local previous=pg:FindFirstChild(oldName)
 if previous then
  local e=previous:FindFirstChild('Stop')
  if e and e:IsA('BindableEvent') then e:Fire();task.wait(.15) end
  if previous:GetAttribute('WrapperAbsent')~=true then
   error('PELICAN previous selector cleanup unverified; practice start cancelled')
  end
  previous:Destroy()
 end
end
for _,name in ipairs({'PELICAN_YUNA_SELECTOR_TRACE','PELICAN_YUNA_INPUT_INSPECT','PELICAN_PRACTICE_TARGET_TEST'}) do
 local old=pg:FindFirstChild(name)
 if old then
  local e=old:FindFirstChild('Stop');if e and e:IsA('BindableEvent') then e:Fire() end
  old:Destroy()
 end
end
if cancelled() then error('PELICAN practice start cancelled') end
local gui=Instance.new('ScreenGui');gui.Name='PELICAN_FF3_PRACTICE_V13';gui.ResetOnSpawn=false;gui.DisplayOrder=1000
local guiDestroyed=false
local function destroyGui()
 if not guiDestroyed then guiDestroyed=true;gui:Destroy() end
end
-- Register before any visible UI/capture side effects. The full restore hook
-- registered below executes first when the loader runs its cleanup stack LIFO.
if loaderContext and type(loaderContext.RegisterCleanup)=='function' then
 loaderContext.RegisterCleanup(function()
  if gui:GetAttribute('WrapperAbsent')==false then return false end
  destroyGui();return true
 end)
end
local event=Instance.new('BindableEvent');event.Name='Stop';event.Parent=gui
local reportValue=Instance.new('StringValue');reportValue.Name='Report';reportValue.Parent=gui
local surface=Instance.new('Frame');surface.Name='Surface';surface.Size=UDim2.fromOffset(138,22)
surface.Position=UDim2.new(1,-148,0,126);surface.BackgroundTransparency=1;surface.Parent=gui
local pill=Instance.new('TextButton');pill.Name='Status';pill.Size=UDim2.fromOffset(112,22)
pill.BackgroundColor3=Color3.fromRGB(25,35,30);pill.TextColor3=Color3.new(1,1,1)
pill.TextSize=10;pill.Font=Enum.Font.GothamMedium;pill.Text='PRACTICE WAIT';pill.Parent=surface
local button=Instance.new('TextButton');button.Name='End';button.Size=UDim2.fromOffset(22,22)
button.Position=UDim2.fromOffset(116,0);button.BackgroundColor3=Color3.fromRGB(155,30,30)
button.TextColor3=Color3.new(1,1,1);button.TextSize=9;button.Font=Enum.Font.GothamMedium
button.Text='END';button.Parent=surface
local panel=Instance.new('Frame');panel.Name='FinalReport';panel.Size=UDim2.fromOffset(318,224)
panel.Position=UDim2.new(1,-328,0,154);panel.BackgroundColor3=Color3.fromRGB(20,24,22)
panel.Visible=false;panel.Parent=gui
local finalStatus=Instance.new('TextLabel');finalStatus.Size=UDim2.fromOffset(306,40)
finalStatus.Position=UDim2.fromOffset(6,4);finalStatus.BackgroundTransparency=1
finalStatus.TextColor3=Color3.new(1,1,1);finalStatus.Font=Enum.Font.GothamMedium
finalStatus.TextSize=10;finalStatus.TextWrapped=true;finalStatus.Parent=panel
local finalText=Instance.new('TextBox');finalText.Size=UDim2.fromOffset(306,168)
finalText.Position=UDim2.fromOffset(6,48);finalText.BackgroundTransparency=1
finalText.TextColor3=Color3.new(1,1,1);finalText.Font=Enum.Font.Code;finalText.TextSize=9
finalText.TextXAlignment=Enum.TextXAlignment.Left;finalText.TextYAlignment=Enum.TextYAlignment.Top
finalText.TextWrapped=true;finalText.ClearTextOnFocus=false;finalText.MultiLine=true
finalText.TextEditable=false;finalText.Parent=panel
gui.Parent=pg
local uv=type(getupvalues)=='function' and getupvalues or (debug and debug.getupvalues)
local setuv=type(setupvalue)=='function' and setupvalue or (debug and debug.setupvalue)
local conns=type(getconnections)=='function' and getconnections
local constants=debug and debug.getconstants or getconstants
local pack=table.pack or function(...)return {n=select('#',...),...}end
local unpackValues=table.unpack or unpack
local started=os.clock();local stopped=false;local finishing=false;local outcome='RUNNING'
local roots={pg};local scanQueue={};local scanHead=1;local scanSeen={};local labels={};local labelSet={};local watchers={};local hud=nil
local candidates={};local byFn={};local anchor=nil;local marker=nil
local labelCursor=1;local candidateCursor=1;local bindSweep={}
local lines={};local bytes=0;local omitted=0;local limits={connections=0}
local original=nil;local wrapper=nil;local installedAt=nil;local writeAttempted=false;local writeInFlight=false
local restoreState='NOT_INSTALLED';local wrapperAbsent=true
local calls,returns,captureErrors=0,0,0
local latest=nil;local serial=0;local lastCaptured=-math.huge;local processed=0;local lastProcessed=0
local lastHud=nil;local hudChanges=0
local practiceMode=true -- strict route assertion above; policy never enters live
local phase='FINDING';local phaseAt=nil;local numericMode=nil;local locked=nil;local glow=nil
local calibration={n=0,min=math.huge,max=-math.huge,actors={},owners={},actorCount=0,modes={},examples=0}
local observed={};local teamRejects={};local overrideCalls=0;local differentCalls=0;local hudChecks=0;local hudHits=0
local normalDifferentChecks=0;local normalDifferentHits=0;local firstHudConfirmed=nil
local tupleErrors=0;local lastNormal=nil;local lastNormalName=nil;local overrideReason=nil
local targetReason='NOT_LOCKED';local pauseEvents=0;local lastForcedAt=nil;local lastDifferentHudAt=nil
local ballParts={};local ballSet={};local ballBorn={};local ballCapHits=0;local ballErrors=0
local lastHeldPosition=nil;local ballContext=nil;local possessionAfter=nil
local heldBall=nil;local lastHeldAt=nil;local flight=nil;local ballRows={};local ballSamples=0
local ballot='NO_RELEASE_OBSERVED';local nextBallFind=0;local nextBallSample=0
local modeDefs={{id='ROOT_SCREEN_RAW',part='HumanoidRootPart',projection='screen',offset=false}}
local Input=game:GetService('UserInputService')
local clipboardState='NOT_ATTEMPTED';local fileState='NOT_ATTEMPTED';local clipboardAttempts=0;local fileAttempts=0
local reportPath='PELICAN_FF3_PRACTICE_V13.txt'
local function ascii(s)return tostring(s or ''):gsub('[^\n\r -~]','?')end
local function clean(s)return ascii(s):gsub('[\r\n|]',' '):sub(1,100)end
local function norm(s)return tostring(s or ''):lower():gsub('%s+','')end
local function log(kind,s)
 local line=kind..'|'..string.format('%.3f',os.clock()-started)..'|'..s
 if #lines>=220 or bytes+#line>22000 then omitted=omitted+1;return end
 lines[#lines+1]=line;bytes=bytes+#line+1
end
local function readAll(fn)
    local ok,t=pcall(uv,fn);if ok and type(t)=='table' then return t end
end
local function read(fn)local t=readAll(fn);return t~=nil,t and rawget(t,4)end
local function eligible(fn)
    if type(fn)~='function' then return false end
    if type(islclosure)=='function' then local ok,v=pcall(islclosure,fn);if ok and not v then return false end end
    if type(isexecutorclosure)=='function' then local ok,v=pcall(isexecutorclosure,fn);if ok and not v then return false end end
    return true
end
local function actor(v)
    if typeof(v)~='Instance' then return end
    local owner,model
    if v:IsA('Player') then owner=v;model=v.Character
    else
        local cur=v
        for _=1,6 do
            if not cur then break end
            if cur:IsA('Model') and cur:FindFirstChildOfClass('Humanoid') then model=cur;break end
            cur=cur.Parent
        end
        if model then owner=Players:GetPlayerFromCharacter(model) end
    end
    if not model then return end
    local hum=model:FindFirstChildOfClass('Humanoid')
    if not hum then return end
    local aliases={}
    local function alias(s)if s and s~='' then aliases[norm(s)]=true end end
    alias(model.Name);alias(hum.DisplayName)
    if owner then alias(owner.Name);alias(owner.DisplayName) end
    return {model=model,value=v,name=owner and owner.Name or model.Name,
        bot=not owner and norm(model.Name):match('^bot%d+$')~=nil,owner=owner,
        aliases=aliases,hum=hum,class=v.ClassName}
end
local function matches(a,s)return a and a.aliases[norm(s)]==true end
local function shown(o)
    local c=o
    while c do
        if c:IsA('GuiObject') and not c.Visible then return false end
        if c:IsA('LayerCollector') and not c.Enabled then return false end
        c=c.Parent
    end
    return o.AbsoluteSize.X>0 and o.AbsoluteSize.Y>0
end
local function isText(o)return o:IsA('TextLabel') or o:IsA('TextButton')end
local function inGuiRoots(o)
 return o and o.Parent and (o:IsDescendantOf(pg) or (roots[2] and o:IsDescendantOf(roots[2])))
end
local function addLabel(o)
    if stopped or labelSet[o] or not isText(o) or not inGuiRoots(o) or o:IsDescendantOf(gui) then return end
    if #labels>=3000 then
        local kept={};labelSet={}
        for _,x in ipairs(labels) do if inGuiRoots(x) then kept[#kept+1]=x;labelSet[x]=true end end
        labels=kept
    end
    if #labels<3000 then labels[#labels+1]=o;labelSet[o]=true end
end
local function txt(o)return o.ContentText:match('^%s*(.-)%s*$')end
local function hudState()
    if not inGuiRoots(hud) then return 'MISSING',nil end
    if not shown(hud) then return 'HIDDEN',nil end
    local s=txt(hud)
    if s=='' then return 'EMPTY',nil end
    return 'LIVE',s
end
local function knownName(s)
    if norm(s):match('^bot%d+$') then return true end
    for _,p in ipairs(Players:GetPlayers()) do
        if norm(s)==norm(p.Name) or norm(s)==norm(p.DisplayName) then return true end
    end
    return false
end
local function locate()
    for _=1,32 do
        if labelCursor>#labels then labelCursor=1;return end
        local o=labels[labelCursor];labelCursor=labelCursor+1
        if stopped then return end
        if inGuiRoots(o) and txt(o)=='Player' then
            local parent=o.Parent
            for _=1,4 do
                if not parent or parent==pg or parent==roots[2] then break end
                local ds={};local queue={parent};local head=1
                while head<=#queue and #queue<=150 do
                 local node=queue[head];head=head+1
                 for _,child in ipairs(node:GetChildren()) do
                  if #queue>=151 then break end
                  queue[#queue+1]=child;ds[#ds+1]=child
                 end
                end
                if #queue<=150 then
                    local caps={}
                    for _,x in ipairs(ds) do if isText(x) then caps[txt(x)]=x end end
                    if caps.Player and caps.Type and caps.Time and caps.Angle then
                        local cap=caps.Player;local cx=cap.AbsolutePosition.X+cap.AbsoluteSize.X/2
                        local best,dist=nil,math.huge
                        for _,x in ipairs(ds) do
                            if isText(x) and x~=cap and knownName(txt(x)) then
                                local dx=math.abs(x.AbsolutePosition.X+x.AbsoluteSize.X/2-cx)
                                local dy=cap.AbsolutePosition.Y-x.AbsolutePosition.Y-x.AbsoluteSize.Y/2
                                if dx<60 and dy>0 and dy<100 and dx+dy<dist then best=x;dist=dx+dy end
                            end
                        end
                        if best then hud=best;log('HUD_BOUND','four-card Player value');return end
                    end
                end
                parent=parent.Parent
            end
        end
    end
end
local function discover()
    local ok,list=pcall(conns,Run.Heartbeat)
    if not ok or type(list)~='table' then log('DISCOVERY','Heartbeat unavailable');return end
    for _,c in ipairs(candidates) do c.active=false end
    if #list>512 then limits.connections=limits.connections+1 end
    for i=1,math.min(#list,512) do
        local c=list[i]
        local good,fn=pcall(function()
            if c.ForeignState==true or c.LuaConnection==false or c.Enabled==false or c.Connected==false then return end
            return c.Function
        end)
        if good and eligible(fn) then
            local record=byFn[fn]
            if not record and #candidates<512 then
                record={fn=fn,id='H'..(#candidates+1),history={},lastLabel=nil,switches=0}
                candidates[#candidates+1]=record;byFn[fn]=record
            end
            if record then record.active=true end
        end
    end
    log('DISCOVERY','Heartbeat='..#list..'|eligible='..#candidates)
end
local function agreement(c)
    local hits=0;for _,yes in ipairs(c.history) do if yes then hits=hits+1 end end
    return #c.history>=20 and hits/#c.history>=0.95 and c.switches>=2,hits,#c.history
end

local function bind()
 local state,label=hudState();if state~='LIVE' then return end
 for _=1,32 do
  if candidateCursor>#candidates then
   candidateCursor=1
   -- Complete a sweep before installing; never pick the first of two valid sites.
   if #bindSweep==1 then
    local candidate=bindSweep[1]
    local good,value=read(candidate.fn)
    local a=good and actor(value)
    if candidate.active and a and value:IsA('Attachment') and value.Name=='wrAtt' and matches(a,label) then
     anchor=candidate;marker=value
     local _,hits,n=agreement(anchor)
     log('ANCHOR_BOUND',anchor.id..'|agreement='..hits..'/'..n..'|switches='..anchor.switches)
    end
   end
   bindSweep={};return
  end
  local c=candidates[candidateCursor];candidateCursor=candidateCursor+1
  local ok,v=read(c.fn);local a=ok and actor(v)
  local hit=a and v:IsA('Attachment') and v.Name=='wrAtt' and matches(a,label) or false
  c.history[#c.history+1]=hit;if #c.history>80 then table.remove(c.history,1) end
  if hit then if c.lastLabel and c.lastLabel~=norm(label) then c.switches=c.switches+1 end;c.lastLabel=norm(label) end
  if agreement(c) and hit and c.active then bindSweep[#bindSweep+1]=c end
 end
end

local function readSlot()
 if not anchor then return false,nil end
 local t=readAll(anchor.fn);return t~=nil,t and rawget(t,14)
end
local function restore()
 if writeInFlight then restoreState='INSTALL_PENDING';wrapperAbsent=false;return end
 if not writeAttempted then restoreState='NOT_INSTALLED';wrapperAbsent=true;return end
 local readable,current=readSlot()
 if not readable then restoreState='READBACK_FAILED';wrapperAbsent=false;return end
 if current==wrapper then
  local ok=pcall(setuv,anchor.fn,14,original)
  local verified,value=readSlot()
  if verified and value==original then restoreState='RESTORED';wrapperAbsent=true
  elseif verified and value~=wrapper then restoreState='NEWER_VALUE_PRESERVED';wrapperAbsent=true
  else restoreState=ok and 'RESTORE_NOT_CONFIRMED' or 'RESTORE_WRITE_FAILED';wrapperAbsent=false end
 elseif current==original then restoreState='ORIGINAL_PRESENT';wrapperAbsent=true
 else restoreState='NEWER_VALUE_PRESERVED';wrapperAbsent=true end
end
local function report(final)
 local out={'PELICAN_FF3_PRACTICE_V13','STATE|'..(final and 'FINAL' or 'RUNNING'),
 'PLACE|'..game.PlaceId,'OUTCOME|'..outcome,'PHASE|'..phase,'ANCHOR|'..(anchor and anchor.id or 'NONE'),
 'VERSION|'..VERSION,
 'SCOPE|V3 held-target control; naturally observed practice receivers; manual throwing only',
 'AUTOMATIC_PASSING|UNIMPLEMENTED_IN_PRACTICE',
 'LAYOUT|HISTORICAL_TARGET4_GETTER14_ONLY',
 'BASELINE|V3 supplied in-game report HUD115/115; differentNormal108/108; throw unverified',
 'EXPORT_STATUS_SCOPE|Last completed attempt before this snapshot; current attempt shown in END panel and GetReport',
 'CLIPBOARD_STATUS|'..clipboardState,'FILE_STATUS|'..fileState,'REPORT_FILE|'..reportPath,
 'EXPORT_ATTEMPTS|clipboard='..clipboardAttempts..'|file='..fileAttempts,
 'CANDIDATE_POLICY|'..(practiceMode and 'TEAMLESS_PRACTICE_OBSERVED_RECEIVERS' or 'LIVE_TEAMMATES_ONLY'),
 'LIMITATION|HUD control is distinct from throw destination and receiver quality; ball rows are observations, not proof of destination',
 'WRITE_ATTEMPTED|'..tostring(writeAttempted),'RESTORE|'..restoreState,'WRAPPER_ABSENT|'..tostring(wrapperAbsent),
 'CALLS|'..calls,'SUCCESSFUL_RETURNS|'..returns,'CAPTURE_ERRORS|'..captureErrors,'TUPLE_ERRORS|'..tupleErrors,
 'NUMERIC_MODE|'..(numericMode and numericMode.id or 'UNCONFIRMED'),
 'FORMULA_VERIFICATION|samples='..calibration.n..'|distinctActors='..calibration.actorCount..'|minR2='..calibration.min..'|maxR2='..calibration.max,
 'LOCKED|'..(locked and clean(locked.name) or 'NONE'),'OVERRIDE_CALLS|'..overrideCalls,
 'NORMAL_TARGET_DIFFERENT_CALLS|'..differentCalls,'HUD_AGREEMENT|'..hudHits..'/'..hudChecks,
 'HUD_WITH_DIFFERENT_NORMAL_TARGET|'..normalDifferentHits..'/'..normalDifferentChecks,
 'HUD_CONFIRMED_AT|'..(firstHudConfirmed and string.format('%.3f',firstHudConfirmed-started) or 'NONE'),
 'TARGET_REASON|'..targetReason,'PAUSE_EVENTS|'..pauseEvents,
 'BALL_STATUS|'..ballot,'BALL_SAMPLES|'..ballSamples,'BALL_PART_CAP_HITS|'..ballCapHits,'BALL_ERRORS|'..ballErrors,
 'BALL_RELEASE_CONTEXT|'..(ballContext or 'NONE'),'POSSESSION_AFTER_RELEASE|'..(possessionAfter or 'NONE'),
 'OMITTED_LINES|'..omitted,
 'BOUNDS|Wait for Yuna until END; 64 discovery nodes/tick; 32 candidate and 32 label checks/tick; 15s receiver acquisition after install; 3 matching numeric samples; 60s override; <=78s installed; numeric sampling<=10Hz; 64 football parts; 120 ball samples',
 'B_FORMAT|time|ballXYZ|lockedRootXYZ|normalRootXYZ; origin SAME_PART or CLONE_CANDIDATE is reported separately'}
 for _,def in ipairs(modeDefs) do
  local m=calibration.modes[def.id]
  if m then out[#out+1]='NUMERIC_FIT|'..def.id..'|hits='..m.hits..'/'..m.n..'|meanAbsError='..string.format('%.4f',m.error/math.max(1,m.n))..'|maxError='..string.format('%.4f',m.maxError) end
 end
 local observedCount=0;for _ in pairs(observed) do observedCount=observedCount+1 end
 out[#out+1]='ELIGIBLE_OBSERVED_MODELS|'..observedCount
 for reason,n in pairs(teamRejects) do out[#out+1]='TEAM_REJECTION|'..reason..'|'..n end
 for _,line in ipairs(lines) do out[#out+1]=line end
 for _,line in ipairs(ballRows) do out[#out+1]=line end
 out[#out+1]='REPORT_END';return ascii(table.concat(out,'\n'))
end
local function copy(final)
 -- Status in the exported text records the previous completed export. GetReport/UI
 -- records this attempt; successful API return is never called OS readback.
 local s=report(final)
 if type(writefile)=='function' then
  fileAttempts=fileAttempts+1
  local ok=pcall(writefile,reportPath,s);fileState=ok and 'SENT_NO_READBACK' or 'FAILED'
  if ok and type(readfile)=='function' then
   local readOk,value=pcall(readfile,reportPath)
   fileState=readOk and value==s and 'READBACK_MATCHED' or 'READBACK_UNCONFIRMED'
  end
 else fileState='UNAVAILABLE' end
 if type(setclipboard)=='function' then
  clipboardAttempts=clipboardAttempts+1
  local ok=pcall(setclipboard,s);clipboardState=ok and 'SENT_NO_READBACK' or 'FAILED'
  if ok and type(getclipboard)=='function' then
   local readOk,value=pcall(getclipboard)
   clipboardState=readOk and value==s and 'READBACK_MATCHED' or 'READBACK_UNCONFIRMED'
  end
 else clipboardState='UNAVAILABLE' end
 if not guiDestroyed then reportValue.Value=report(final) end
 if final and not guiDestroyed then
  panel.Visible=true;pill.Text=wrapperAbsent and 'PRACTICE ENDED' or 'RESTORE RETRY'
  finalStatus.Text='Cleanup '..(wrapperAbsent and 'confirmed' or 'UNVERIFIED')..' | Clipboard '..clipboardState..'\nFile '..fileState..'; END retries cleanup/export. Save before leaving.'
  -- Screenshot fallback is a short factual summary, not a claimed durable report.
  finalText.Text='PELICAN_FF3_PRACTICE_V13\nOutcome: '..outcome..'\nRestore: '..restoreState..'\nWrapper absent: '..tostring(wrapperAbsent)
   ..'\nLocked: '..(locked and clean(locked.name) or 'NONE')..'\nOverrides: '..overrideCalls..'\nHUD: '..hudHits..'/'..hudChecks
   ..'\nDifferent normal HUD: '..normalDifferentHits..'/'..normalDifferentChecks..'\nBall: '..ballot
   ..'\nAutomatic passing: unimplemented\nFile: '..reportPath..'\nFull in-session report: GUI Report StringValue'
 end
 return clipboardState,fileState
end
local function finish(reason)
 if finishing then return false end;finishing=true
 local first=not stopped;stopped=true
 if glow then glow:Destroy();glow=nil end
 if first then outcome=reason end
 restore();if not guiDestroyed then gui:SetAttribute('WrapperAbsent',wrapperAbsent) end
 local pending={}
 for _,connection in ipairs(watchers)do
  local ok,why=pcall(function()connection:Disconnect()end)
  if not ok then pending[#pending+1]=connection;log('DISCONNECT_ERROR',clean(why))end
 end
 watchers=pending
 if first then log('END',outcome..'|restore='..restoreState)else log('CLEANUP_RECHECK',restoreState)end
 if not guiDestroyed then gui:SetAttribute('CleanupConfirmed',wrapperAbsent and #watchers==0 and glow==nil) end
 local copied,copyError=pcall(copy,true)
 finishing=false
 if not copied then
  log('REPORT_ERROR',clean(copyError))
  if not guiDestroyed then
   pcall(function()
    panel.Visible=true
    finalStatus.Text='Cleanup '..(wrapperAbsent and 'confirmed' or 'UNVERIFIED')..' | Report failed; tap END to retry before leaving.'
   end)
  end
  -- Export failure after restoration is retryable through END. Escalating it
  -- to loader shutdown would remove that retry panel and can reenter Stop.
 end
 return wrapperAbsent and #watchers==0 and glow==nil
end
button.Activated:Connect(function()finish('USER_END')end)
event.Event:Connect(function()finish('REPLACED_BY_NEW_SCRIPT')end)
if loaderContext and type(loaderContext.RegisterCleanup)=='function' then
 loaderContext.RegisterCleanup(function(reason)return finish(reason or 'LOADER_CLEANUP')end)
end
local function selftest()
 if type(uv)~='function' or type(setuv)~='function' or type(conns)~='function' or type(constants)~='function' then
  log('CAPABILITY','Required reflection API missing');return false
 end
 local first=function()return 117 end
 local second=function()return 229 end
 local cell=first
 local function fixture(...)return cell(...)end
 local t=readAll(fixture);local slot=nil
 if t then for k,v in next,t do if v==first then slot=k;break end end end
 if type(slot)~='number' then log('CAPABILITY','Own closure capture unreadable');return false end
 local wrote=pcall(setuv,fixture,slot,second)
 local good,value=pcall(fixture)
 local reset=pcall(setuv,fixture,slot,first)
 local restored,value2=pcall(fixture)
 local pass=wrote and good and value==229 and reset and restored and value2==117
 log('CAPABILITY','Own closure replace/restore='..(pass and 'PASS' or 'FAIL'))
 return pass
end
local function fingerprint(fn)
 if not eligible(fn) then return false end
 local ok,t=pcall(constants,fn);if not ok or type(t)~='table' then return false end
 local found={};local n=0
 for _,v in next,t do n=n+1;if n>512 then return false end;if type(v)=='string' then found[v]=true end end
 for _,name in ipairs({'GetMouseLocation','WorldToScreenPoint','GetPlayers','Team','Health','Magnitude'}) do
  if not found[name] then log('FINGERPRINT_MISSING',name);return false end
 end
 if debug and type(debug.info)=='function' then
  local good,n,vararg=pcall(debug.info,fn,'a')
  if good and (n~=0 or vararg) then log('FINGERPRINT_MISSING','Expected zero arguments');return false end
 end
 log('FINGERPRINT','U14 input/player symbols match prior report');return true
end

local function finite(v)return type(v)=='number' and v==v and math.abs(v)<1e8 end
local function eligibleReceiver(model)
 local a=actor(model)
 if not a or a.model~=model or not model:IsDescendantOf(workspace) then return nil,'INVALID_MODEL' end
 local previousOwner=calibration.owners[model]
 if previousOwner and previousOwner.Character~=model then return nil,'OLD_PLAYER_CHARACTER' end
 if model==me.Character or a.owner==me then return nil,'SELF' end
 if a.hum.Health<=0 then return nil,'DEAD' end
 if a.owner and (a.owner.Character~=model or a.hum.Health<=0) then return nil,'INVALID_OR_DEAD_PLAYER' end
 -- Natural returns establish the practice pool; assigned opponent teams stay excluded.
 if not calibration.actors[model] then return nil,'NOT_NATURALLY_OBSERVED' end
 if me.Team and not me.Neutral then
  if a.owner then
   if a.owner.Team~=me.Team or a.owner.Neutral then return nil,'NOT_CURRENT_TEAMMATE' end
  else
   local team=model:GetAttribute('Team') or model:GetAttribute('TeamName')
   if team~=me.Team.Name then return nil,'BOT_TEAM_UNVERIFIED' end
  end
 end
 return a
end
local function distanceFor(model,def,mouse,cam)
 local part=model and model:FindFirstChild('HumanoidRootPart')
 if not part or not part:IsA('BasePart') or not cam then return end
 local screen,onScreen=cam:WorldToScreenPoint(part.Position)
 if not onScreen or screen.Z<=0 then return end
 return (Vector2.new(screen.X,screen.Y)-mouse).Magnitude
end
local function geometry(model,def)
 return distanceFor(model,def,Input:GetMouseLocation(),workspace.CurrentCamera)
end
local function calibrate(values,now)
 if values.n~=2 or typeof(values[1])~='Instance' or not values[1]:IsA('Model') or not finite(values[2]) or values[2]<0 then return end
 local model=values[1];local a=actor(model);if not a then return end
 local cam=workspace.CurrentCamera;if not cam then return end
 local mouse=Input:GetMouseLocation()
 local predicted={};local available=false
 for _,def in ipairs(modeDefs) do
  local value=distanceFor(model,def,mouse,cam)
  if finite(value) then predicted[def.id]=value;available=true end
 end
 if not available then return end
 calibration.n=calibration.n+1
 calibration.min=math.min(calibration.min,values[2]);calibration.max=math.max(calibration.max,values[2])
 if not calibration.actors[model] then
  calibration.actors[model]=true;calibration.owners[model]=a.owner;calibration.actorCount=calibration.actorCount+1
 end
 local eligibleActor,reason=eligibleReceiver(model)
 if eligibleActor then observed[model]={name=eligibleActor.name,time=now} end
 if reason then teamRejects[reason]=(teamRejects[reason] or 0)+1 end
 for _,def in ipairs(modeDefs) do
  local value=predicted[def.id]
  if value then
   local m=calibration.modes[def.id] or {n=0,hits=0,error=0,maxError=0,streak=0};calibration.modes[def.id]=m
   local error=math.abs(value-values[2]);m.n=m.n+1;m.error=m.error+error;m.maxError=math.max(m.maxError,error)
   if error<=.05 then m.hits=m.hits+1;m.streak=m.streak+1 else m.streak=0 end
  end
 end
 if calibration.examples<8 then
  calibration.examples=calibration.examples+1
  local row={};for _,def in ipairs(modeDefs) do if predicted[def.id] then row[#row+1]=def.id..'='..string.format('%.2f',predicted[def.id]) end end
  log('R2_SAMPLE',clean(a.name)..'|actual='..string.format('%.2f',values[2])..'|'..table.concat(row,','))
 end
end
local function chooseNumericMode()
 local m=calibration.modes.ROOT_SCREEN_RAW
 if m and m.streak>=3 then return modeDefs[1] end
end
local function targetStillValid()
 if not locked then return false,'NOT_LOCKED',true end
 local a,reason=eligibleReceiver(locked.model)
 if not a then return false,reason or 'INELIGIBLE',true end
 local cam=workspace.CurrentCamera;local root=locked.model:FindFirstChild('HumanoidRootPart')
 if not cam then return false,'NO_CAMERA',false end
 if not root then return false,'NO_ROOT',false end
 local point,visible=cam:WorldToScreenPoint(root.Position)
 if point.Z<=0 then return false,'BEHIND_CAMERA',false end
 if not visible then return false,'OFFSCREEN',false end
 return true,'VISIBLE',false
end
local function apply(values)
 local now=os.clock()
 if phase=='OVERRIDE' and now-phaseAt>=60 then phase='DONE';return values end
 local out=values;local changed=false
 if phase=='OVERRIDE' and numericMode and targetStillValid() then
  if values.n==2 and (values[1]==nil or (typeof(values[1])=='Instance' and values[1]:IsA('Model'))) and type(values[2])=='number' then
   local distance=geometry(locked.model,numericMode)
   if finite(distance) and distance>=0 then
    out={n=2,[1]=locked.model,[2]=distance};changed=true;overrideCalls=overrideCalls+1;lastForcedAt=now
    if values[1]~=locked.model then differentCalls=differentCalls+1 end
   end
  else tupleErrors=tupleErrors+1 end
 end
 if now-lastCaptured>=.1 then
  lastCaptured=now;serial=serial+1
  if phase=='VERIFY' then calibrate(values,now) end
  latest={t=now,id=serial,normal=values[1],number=values[2],out=out[1],outNumber=out[2],forced=changed}
 end
 return out
end
local function makeWrapper(fn)
 return function(...)
  if stopped then return fn(...) end
  calls=calls+1;local values=pack(fn(...));returns=returns+1
  if not stopped then
   local ok,out=pcall(apply,values)
   if ok and type(out)=='table' then values=out else captureErrors=captureErrors+1 end
  end
  return unpackValues(values,1,values.n)
 end
end
local function install()
 local readable,current=readSlot()
 if not readable or not fingerprint(current) then finish('SELECTOR_FINGERPRINT_MISMATCH');return end
 local t=readAll(anchor.fn)
 if stopped then return end
 if not t or rawget(t,4)~=marker or rawget(t,14)~=current then finish('ANCHOR_CHANGED');return end
 original=current;wrapper=makeWrapper(original)
 writeAttempted=true;wrapperAbsent=false;restoreState='WRAPPER_INSTALLING';gui:SetAttribute('WrapperAbsent',false)
 writeInFlight=true
 local ok=pcall(setuv,anchor.fn,14,wrapper)
 writeInFlight=false
 local good,after=readSlot()
 -- A write API may yield. If a stop raced with it, recheck cleanup now.
 if stopped then finish('STOP_DURING_INSTALL');return end
 if not ok or not good or after~=wrapper then finish('INSTALL_NOT_CONFIRMED');return end
 installedAt=os.clock();phaseAt=installedAt;phase='VERIFY';restoreState='WRAPPER_PRESENT'
 log('INSTALLED','target4/getter14; ROOT_SCREEN_RAW verification; <=78s installed')
end

local function beginOverride()
 local current=latest and latest.normal;local choice=nil;local choiceDistance=math.huge
 for model,entry in pairs(observed) do
  if model~=current and os.clock()-entry.time<=16 then
   local a=eligibleReceiver(model)
   local root=model:FindFirstChild('HumanoidRootPart');local cam=workspace.CurrentCamera
   if a and root and cam then
    local point,visible=cam:WorldToScreenPoint(root.Position)
    if visible and point.Z>0 then
     local value=geometry(model,numericMode)
     if finite(value) and value<choiceDistance then choice={model=model,name=a.name};choiceDistance=value end
    end
   end
  end
 end
 if not choice then return false end
 locked=choice;phase='OVERRIDE';phaseAt=os.clock()
 glow=Instance.new('Highlight');glow.Name='PELICAN_CONTROL_TARGET';glow.Adornee=choice.model
 glow.FillColor=Color3.fromRGB(0,255,80);glow.OutlineColor=Color3.fromRGB(0,255,80);glow.FillTransparency=.55
 glow.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop;glow.Parent=gui
 log('OVERRIDE_BEGIN',clean(choice.name)..'|model='..clean(choice.model.Name)..'|numeric='..numericMode.id)
 return true
end
local function observeReturn()
 local state,label=hudState();local key=state..'|'..clean(label)
 if key~=lastHud then hudChanges=hudChanges+1;lastHud=key;log('HUD',key) end
 local sample=latest;if not sample or sample.id==lastProcessed then return end
 lastProcessed=sample.id;processed=processed+1
 local normal=actor(sample.normal)
 if normal and normal.name~=lastNormalName then lastNormalName=normal.name;log('NORMAL_TARGET',clean(normal.name)) end
 if normal then lastNormal=normal.model end
 if phase=='VERIFY' then
  local mode=chooseNumericMode()
  if mode then
   if not numericMode then numericMode=mode;log('KNOWN_FORMULA_VERIFIED',mode.id) end
   beginOverride()
  end
 elseif phase=='OVERRIDE' and state=='LIVE' and sample.forced and os.clock()-sample.t<.25 then
  local a=actor(locked.model)
  hudChecks=hudChecks+1;local hit=matches(a,label)
  if hit then hudHits=hudHits+1 end
  if sample.normal~=locked.model then normalDifferentChecks=normalDifferentChecks+1;if hit then normalDifferentHits=normalDifferentHits+1;lastDifferentHudAt=os.clock() end end
  if not firstHudConfirmed and normalDifferentChecks>=5 and normalDifferentHits/normalDifferentChecks>=.95 then
   firstHudConfirmed=os.clock();log('HUD_CONTROL_CONFIRMED',clean(locked.name)..'|normal target differs')
  end
 end
end
local function vec(v)return string.format('%.2f,%.2f,%.2f',v.X,v.Y,v.Z)end
local function rootPosition(model)
 local root=model and model:FindFirstChild('HumanoidRootPart');return root and vec(root.Position) or 'NONE'
end
local function footballPart(part,char)
 if not part:IsA('BasePart') then return false end
 if part.Name=='Football' then return true end
 local parent=part.Parent
 for _=1,3 do
  if not parent or parent==char then break end
  if parent.Name=='Football' then return true end
  parent=parent.Parent
 end
 return false
end

local function addBall(part)
 if stopped or ballSet[part] or not footballPart(part,me.Character) then return end
 if #ballParts>=64 then
  local keep={};ballSet={}
  for _,old in ipairs(ballParts) do if old.Parent then keep[#keep+1]=old;ballSet[old]=true else ballBorn[old]=nil end end
  ballParts=keep
 end
 if #ballParts>=64 then ballCapHits=ballCapHits+1;return end
 ballParts[#ballParts+1]=part;ballSet[part]=true;ballBorn[part]=os.clock()
end
local function carrier(part)
 local a=actor(part);if a then return a end
 local ok,list=pcall(function()return part:GetConnectedParts(false)end)
 if ok and type(list)=='table' then
  for i=1,math.min(#list,16) do local owner=actor(list[i]);if owner then return owner end end
 end
end
local function seedBalls()
 local watched,c=pcall(function()return workspace.DescendantAdded:Connect(addBall)end)
 if watched then watchers[#watchers+1]=c end
 local children=workspace:GetChildren()
 for i=1,math.min(#children,256) do
  local obj=children[i];addBall(obj)
  if obj.Name=='Football' then
   local ds=obj:GetDescendants();for j=1,math.min(#ds,64) do addBall(ds[j]) end
  end
 end
end
local function throwReady(now)
 return phase=='OVERRIDE' and firstHudConfirmed and lastDifferentHudAt and now-lastDifferentHudAt<.4
  and lastForcedAt and now-lastForcedAt<.25 and targetStillValid()
end
local function startFlight(part,now,origin)
 local recent=latest and latest.forced and now-latest.t<.3
 local different=latest and latest.normal~=locked.model
 local _,label=hudState()
 ballContext='origin='..origin..';recentForced='..tostring(recent)..';normalDifferent='..tostring(different)
  ..';HUD='..clean(label)..';locked='..clean(locked.name)
 flight={part=part,started=now,origin=origin,lockedModel=locked.model,normalModel=latest and latest.normal}
 ballot='RELEASE_CANDIDATE'
 log('BALL_RELEASE_CANDIDATE',ballContext)
end
local function observeBall(now)
 if now>=nextBallFind then
  nextBallFind=now+.2
  local char=me.Character
  if char then
   local ds=char:GetDescendants()
   for i=1,math.min(#ds,400) do addBall(ds[i]) end
  end
  local root=char and char:FindFirstChild('HumanoidRootPart')
  if root then
   for _,part in ipairs(ballParts) do
    if part.Parent and (part.Position-root.Position).Magnitude<18 then
     local owner=carrier(part)
     if owner and owner.model==char then heldBall=part;lastHeldAt=now;lastHeldPosition=part.Position;break end
    end
   end
  end
 end
 if phase=='OVERRIDE' and firstHudConfirmed and not flight and heldBall and lastHeldAt and now-lastHeldAt<=.75 then
  -- A run with the ball remains carried, even if its position or velocity changes.
  local oldOwner=heldBall.Parent and carrier(heldBall)
  if not oldOwner then
   if heldBall.Parent and heldBall.AssemblyLinearVelocity.Magnitude>35 then
    startFlight(heldBall,now,'SAME_PART')
   elseif lastHeldPosition then
    local choice=nil;local closest=30
    for _,part in ipairs(ballParts) do
     if part.Parent and part~=heldBall and (ballBorn[part] or 0)>=lastHeldAt-.15 and part.AssemblyLinearVelocity.Magnitude>35 then
      local distance=(part.Position-lastHeldPosition).Magnitude
      if distance<closest and not carrier(part) then closest=distance;choice=part end
     end
    end
    if choice then startFlight(choice,now,'CLONE_CANDIDATE') end
   end
  end
 end
 if flight and now>=nextBallSample and ballSamples<120 then
  nextBallSample=now+.05
  local part=flight.part
  if not part.Parent or now-flight.started>6 then return end
  local owner=carrier(part)
  if owner then
   if not possessionAfter then
    possessionAfter=clean(owner.name);log('BALL_CARRIER_AFTER_RELEASE',possessionAfter..'|origin='..flight.origin)
    ballot=owner.model==flight.lockedModel and 'LOCKED_RECEIVER_POSSESSION_OBSERVED' or 'OTHER_RECEIVER_POSSESSION_OBSERVED'
   end
   return
  end
  ballSamples=ballSamples+1
  ballRows[#ballRows+1]='B|'..string.format('%.3f',now-started)..'|'..vec(part.Position)..'|'..rootPosition(flight.lockedModel)..'|'..rootPosition(flight.normalModel)
 end
end
local function summarize()
 if firstHudConfirmed then return 'HUD_CONTROL_CONFIRMED_THROW_UNVERIFIED' end
 if overrideCalls>0 then return 'OVERRIDE_SENT_HUD_UNCONFIRMED' end
 if numericMode then return 'NUMERIC_CONFIRMED_NO_VERIFIED_TARGET' end
 return 'NUMERIC_RETURN_UNCONFIRMED'
end
task.spawn(function()
 while not stopped do
  local ok,err=pcall(function()
   local now=os.clock()
   if phase=='DONE' or (phase=='OVERRIDE' and now-phaseAt>=60) then finish(summarize());return end
   if phase=='VERIFY' and now-phaseAt>=15 then finish(summarize());return end
   if installedAt and now-installedAt>=78 then finish(summarize());return end
   if cancelled() then finish('LOADER_CANCELLED');return end
  end)
  if not ok then runtimeError(err);finish('WATCHDOG_ERROR');return end
  task.wait(0.2)
 end
end)
task.spawn(function()
 while not stopped do
  local ok,err=pcall(copy,false)
  if not ok then runtimeError(err);finish('REPORT_ERROR');return end
  task.wait(8)
 end
end)
task.spawn(function()
 local ok,err=pcall(function()
  if not selftest() then finish('CAPABILITY_SELFTEST_FAILED');return end
  local ballOk=pcall(seedBalls);if not ballOk then ballErrors=ballErrors+1 end
  local got,core=pcall(function()return game:GetService('CoreGui')end);if got then roots[#roots+1]=core end
  local function enqueue(o)
   if stopped or not o or scanSeen[o] or o==gui or o:IsDescendantOf(gui) then return end
   if #scanQueue>=6000 then limits.scanCap=(limits.scanCap or 0)+1;return end
   scanSeen[o]=true;scanQueue[#scanQueue+1]=o
  end
  for _,root in ipairs(roots) do
   local watched,c=pcall(function()return root.DescendantAdded:Connect(function(o)addLabel(o);addBall(o);enqueue(o)end)end)
   if watched then watchers[#watchers+1]=c end
   enqueue(root)
  end
  local function scanTick()
   for _=1,64 do
    if stopped or scanHead>#scanQueue then break end
    local o=scanQueue[scanHead];scanQueue[scanHead]=false;scanHead=scanHead+1
    if o and (o.Parent or o==pg or o==roots[2]) then
     addLabel(o);addBall(o)
     local kids=o:GetChildren()
     for i=1,math.min(#kids,512) do enqueue(kids[i]) end
    end
   end
   if scanHead>#scanQueue then scanQueue={};scanHead=1;scanSeen={} end
  end
  local nextLocate,nextDiscovery,nextStatus=0,0,0
  while not stopped do
   local now=os.clock()
   if cancelled() then finish('LOADER_CANCELLED');return end
   scanTick()
   if not anchor then
    if now>=nextDiscovery then discover();nextDiscovery=os.clock()+8 end
    if not inGuiRoots(hud) and now>=nextLocate then locate();nextLocate=os.clock()+.2 end
    if stopped then return end
    bind()
    if anchor then install() end
   elseif installedAt then
    local readable,current=readSlot()
    if not readable then finish('ANCHOR_READ_FAILED');return end
    if current~=wrapper then finish('CALL_SITE_CHANGED');return end
    local t=readAll(anchor.fn)
    if not t then finish('ANCHOR_READ_FAILED');return end
    local currentTarget=rawget(t,4)
    if currentTarget~=nil and (typeof(currentTarget)~='Instance' or not currentTarget:IsA('Attachment') or currentTarget.Name~='wrAtt') then
     finish('TARGET_CAPTURE_SHAPE_CHANGED');return
    end
    if phase=='OVERRIDE' then
     local valid,reason,hard=targetStillValid()
     if reason~=targetReason then
      targetReason=reason;log('TARGET_STATE',reason)
      if not valid then pauseEvents=pauseEvents+1 end
      if glow then glow.FillColor=valid and Color3.fromRGB(0,255,80) or Color3.fromRGB(255,190,0) end
     end
     if hard then finish('LOCKED_TARGET_'..reason);return end
    end
    observeReturn()
    local ballOk=pcall(observeBall,now);if not ballOk then ballErrors=ballErrors+1 end
   end
   if stopped then return end
   if now>=nextStatus then
    local status='WAIT YUNA / AIM A-B-A'
    if phase=='VERIFY' then status=numericMode and 'AIM TWO RECEIVERS' or ('R2 '..calibration.n..'/3')
    elseif phase=='OVERRIDE' then
     local left=math.max(0,math.ceil(60-(now-phaseAt)))
     if targetReason~='VISIBLE' then status='PAUSED '..targetReason..': bring '..clean(locked.name)..' into view'
     elseif throwReady(now) then status='THROW '..clean(locked.name)
     else status='LOCK '..clean(locked.name)..': aim at another receiver; keep green in view' end
     status=status..' / '..left..'s'
    end
    pill.Text=status:sub(1,24)
    nextStatus=now+0.5
   end
   task.wait(0.1)
  end
 end)
 if not ok then runtimeError(err);finish('SCRIPT_ERROR') end
end)

local controller={Version=VERSION,Route='ff3-practice'}
controller.Stop=function(reason)
 if guiDestroyed and stopped and wrapperAbsent and #watchers==0 and glow==nil then return true end
 local clean=finish(reason or 'CONTROLLER_STOP')
 if clean then destroyGui() end
 return clean
end
controller.GetReport=function()return report(stopped)end
controller.IsStopped=function()return stopped end
controller.IsClean=function()return stopped and not finishing and wrapperAbsent and #watchers==0 and glow==nil end
return controller
