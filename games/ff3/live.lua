-- PELICAN FF3 LIVE V13 -- targeted repairs over the archived V12 source.
-- Provisional HUD-path disagreement blocks release without disqualifying a receiver.
-- CTRL in folded options holds one fresh safe receiver for a bounded, manual-only control test.
local loaderContext=...
if type(loaderContext)~='table' then loaderContext=nil end
-- Live matches only. Either startup order is supported; discovery waits for Yuna and its held-ball HUD.
-- Starts with AUTO requested; selection waits for all verification gates.
-- Tap the small status pill to reveal selection/throw/DIR controls; red dot ends and copies.
-- No manual warm-up throws: one native equipped-Tool attempt after actual target and path confirmation.
-- Physical flight profiles are fitted automatically; they do not reveal Yuna's exact solver.
-- Field/marker geometry is cached and invalidated by public property-change events.
-- Scoring includes a .55-.85s request-to-release window (V4 observed ~.75s).
-- Automatic requests freeze the intended receiver through the observed wind-up.
-- BodyForce/mass/velocity are read only; confirmed measured gravity can update the model.
-- Speed/mode mapping remains provisional; profiles identify their evidence source.
-- Scoring runs in short slices; checkpoints run every 8 seconds.
-- It then uses the equipped Tool Activate/Deactivate API once per possession/play.
-- Yuna keeps choosing its own throw mode. Unknown/unverified paths do not auto-release.
-- Mode display reads Yuna Type/Time/Angle cards; ~MODE denotes our estimated recommendation.
-- Auto release checks that actual HUD mode/angle; Yuna still owns mode selection.
-- Far diagonal Bullet is reconsidered, not forced into another Yuna mode.
-- Native Tool automatic release remains experimental; blockers appear in the report.
-- V12 keeps the verified getter delivering during a live teammate HUD/attachment handoff.
-- Target confirmation is still mandatory for release; a mismatched HUD never authorizes a throw.
-- Handoff timeout measures sustained failed delivery, resets after real confirmation, and logs gaps.
-- Manual Tool/flight observations remain diagnostics, not a prerequisite for the first auto attempt.
-- V11 ignores unrelated Beams before attaching any property/endpoint listeners.
-- Beam fallback must span the field horizontally at the ground plane with line colors.
-- Flight-path failures identify the exact rejected model constraint; they never relax it.
-- V10 revalidates changed line data before deciding whether the confirmed pair actually changed.
-- Harmless visibility/color animation and unrelated marker events cannot repeatedly reset settlement.
-- Comparable safe recommendations allow a bounded handoff interval; every score stays fresh.
-- V9 separates selector-link readiness from acknowledgement of the newly selected target.
-- A normal target change must not pause the getter that is causing that change.
-- Brief HUD handoff grace never substitutes for actual attachment/HUD confirmation before release.
-- Persistent handoff receipts retain normal/output distances and disable reasons.
-- V8 supports only the observed (target20/getter11) and prior (target4/getter14) layouts.
-- Each layout still needs HUD target transitions, exact getter signature, and return verification.
-- Hidden/no-ball HUD and missing target attachments pause control; getter replacement stops it.
-- The gameplay surface is a 112x22 status pill + 22px red END dot; options stay folded.
-- V7 verifies the known getter before binding; attachment names are not identity.
-- Binding diagnostics survive rolling logs. Unknown/ambiguous paths remain read-only.
-- LINKING / VERIFYING are not AUTO. Manual Tool learning can use an independent HUD target.
-- V6 rebinds recreated HUD cards and separately records native Activated signals.
-- Flight labels prefer the latest matching visible HUD receipt before release.
-- AUTO requires a mapped field, current team/possession, moving on-field visible
-- teammate, fresh QB/defender observations, and acceptable estimated risk.
-- When any gate fails, original Yuna selection passes through. Yellow = fallback.
-- Field matches the recorded ground and four physical boundary strips, ignoring names.
-- Inner-edge bounds are inferred from visible geometry, not official FF3 metadata.
-- Collapsed 138x22 controls. Blue/yellow field lines + yards-to-go HUD infer direction.
-- DIR is a fallback only. Automatic release requires the inferred line pair, never DIR alone.
-- END restores the selector, attempts ASCII copy, and shows screenshot-ready results.
-- COPY SENT is not OS clipboard verification; capture END results before leaving Roblox.
-- No constructed remotes, synthetic screen taps, global hooks, or bypass logic.
-- Idle/erratic motion is a temporary exclusion; misses never cause an unproven permanent ban.
-- Reflection/replacing a Yuna captured function is runtime modification, not read-only.
-- Live integration/ranking are experimental. No claim of account safety or catches.
local CFG={Interval=.12,Gravity=28,Speed=95,MaxFlight=4.5,MaxRange=330,
 IdleSeconds=1.5,SideInset=8,MinimumMargin=3,MinimumLane=2,MaxRoster=64,DecisionBudget=.002,ModesPerSlice=12,DecisionMaxAge=.28,ReleaseDelayLow=.55,ReleaseDelayHigh=.85,
 AutoThrow=true,ThrowHold=.10,ThrowMargin=6,ThrowLane=4,MarkerToleranceYards=.8}
local Players=game:GetService('Players')
local Run=game:GetService('RunService')
local me=Players.LocalPlayer
if not me then error('PELICAN: LocalPlayer unavailable') end
local pg=me:FindFirstChild('PlayerGui')
local playerGuiDeadline=os.clock()+10
while not pg and os.clock()<playerGuiDeadline do
 if loaderContext and loaderContext.IsCancelled and loaderContext.IsCancelled()then error('PELICAN: startup cancelled')end
 task.wait(.05);pg=me:FindFirstChild('PlayerGui')
end
if not pg then error('PELICAN: PlayerGui unavailable after 10 seconds')end
-- Stop prior instrumented probes and require their cleanup acknowledgement.
for _,oldName in ipairs({'PELICAN_YUNA_RETURN_TRACE','PELICAN_YUNA_CONTROL_TEST','PELICAN_FF3_LIVE','PELICAN_FF3_PRACTICE_V13'}) do
 local previous=pg:FindFirstChild(oldName)
 if previous then
  local e=previous:FindFirstChild('Stop')
  if e and e:IsA('BindableEvent') then e:Fire();task.wait(0.15) end
  if previous:GetAttribute('WrapperAbsent')~=true then
   warn('PELICAN: previous wrapper cleanup unverified; new test cancelled.');return
  end
  previous:Destroy()
 end
end
for _,name in ipairs({'PELICAN_YUNA_SELECTOR_TRACE','PELICAN_YUNA_INPUT_INSPECT','PELICAN_PRACTICE_TARGET_TEST','PELICAN_ADVISOR_V1'}) do
 local old=pg:FindFirstChild(name)
 if old then local e=old:FindFirstChild('Stop');if e and e:IsA('BindableEvent') then e:Fire() end;old:Destroy() end
end
local gui=Instance.new('ScreenGui');gui.Name='PELICAN_FF3_LIVE';gui.ResetOnSpawn=false;gui.DisplayOrder=1000
if loaderContext and loaderContext.RegisterCleanup then
 loaderContext.RegisterCleanup(function()
  if gui:GetAttribute('WrapperAbsent')==false then return false end
  gui:Destroy();return true
 end)
end
local event=Instance.new('BindableEvent');event.Name='Stop';event.Parent=gui
local function makeButton(text,x,width)
 local b=Instance.new('TextButton');b.Size=UDim2.fromOffset(width,32)
 b.Position=UDim2.new(1,x,0,62);b.BackgroundColor3=Color3.fromRGB(25,35,31);b.BackgroundTransparency=.35
 b.TextColor3=Color3.new(1,1,1);b.TextSize=10;b.TextWrapped=true;b.Font=Enum.Font.GothamMedium
 b.Text=text;b.Parent=gui;return b
end
local panel=makeButton('WAIT YUNA',-142,112);panel.Size=UDim2.fromOffset(112,22);panel.TextWrapped=false
local throwButton=makeButton('THR',-93,28)
local directionButton=makeButton('DIR',-61,28)
local button=makeButton('',-26,22);button.Size=UDim2.fromOffset(22,22);button.BackgroundColor3=Color3.fromRGB(180,35,40);button.BackgroundTransparency=.12
Instance.new('UICorner').Parent=button;Instance.new('UICorner').Parent=panel
local glow=Instance.new('Highlight');glow.Name='PELICAN_LIVE_RECEIVER';glow.Enabled=false
 glow.FillColor=Color3.fromRGB(0,255,80);glow.OutlineColor=Color3.fromRGB(0,255,80)
 glow.FillTransparency=.85;glow.OutlineTransparency=.2;glow.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop;glow.Parent=gui
 gui:SetAttribute('WrapperAbsent',true);gui.Parent=pg
local uv=type(getupvalues)=='function' and getupvalues or (debug and debug.getupvalues)
local setuv=type(setupvalue)=='function' and setupvalue or (debug and debug.setupvalue)
local conns=type(getconnections)=='function' and getconnections
local constants=debug and debug.getconstants or getconstants
local pack=table.pack or function(...)return {n=select('#',...),...}end
local unpackValues=table.unpack or unpack
local started=os.clock();local stopped=false;local finishing=false;local outcome='RUNNING'
local roots={pg};local labels={};local labelSet={};local watchers={};local hud=nil
local candidates={};local byFn={};local anchor=nil;local marker=nil
local lines={};local bytes=0;local omitted=0;local limits={connections=0}
local original=nil;local wrapper=nil;local installedAt=nil;local writeAttempted=false;local writeInFlight=false
local restoreState='NOT_INSTALLED';local wrapperAbsent=true
local calls,returns,captureErrors=0,0,0
local latest=nil;local serial=0;local lastCaptured=-math.huge;local lastProcessed=0
local phase='FINDING';local numericMode=nil
local calibration={n=0,min=math.huge,max=-math.huge,actors={},actorCount=0,modes={},examples=0}
local observed={};local teamRejects={};local overrideCalls=0;local differentCalls=0;local tupleErrors=0
local hudChecks,hudHits,normalDifferentChecks,normalDifferentHits=0,0,0,0
local autoRequested=true;local selection=nil;local selectionAt=0;local selectionEpoch=0
local gate='WAITING_FOR_YUNA';local forcedSample=nil;local lastHud=nil;local hudFailures=0
local states={};local field=nil;local fieldCap=0;local fieldDiagnostics={}
local scanQueue={};local scanIndex=1;local scanChildren=nil;local scanChildIndex=1;local scanDone=false
local mapGround=nil;local mapLines={};local mapSeen={};local nextGroundProbe=0;local nextMapRetry=0;local floorRayHits=0;local mapNodes=0
local forward=nil;local possessionStart=nil;local ownBall=nil;local ownHeld=false
local A={context={status='SEARCHING',source='NONE',los=nil,first=nil,sign=nil,yards=nil,streak=0,at=0},
 goalLines={},markerParts={},markerSeen={},markerRows={},markerMeta={},markerScan=nil,markerNodes=0,markerCap=false,
 addContextCandidate=function()end,heldTool=nil,toolConnection=nil,activation=nil,toolProofs={},possessionID=0,possessionAt=0,
 autoThrowRequested=CFG.AutoThrow,throwStatus='WAITING_FOR_BALL',throwAttempts=0,automaticReleases=0,attemptedPossession=-1,
 pendingThrow=nil,throwLock=nil,throwLockAt=0,hudSyncSince=nil,idleSkipped=0,erraticSkipped=0,perf={},downLabels={},downSeen={},downIndex=1,
 decision=nil,heldSignature=nil,toolDirty=false,overrideReady=false,overrideAt=0,pathProfiles={},pathRejected=0,
 fieldDirty=false,fieldWatchers={},markerCache={},markerWatchers={},markerRevision=0,markerGeometryCalls=0,
 contextGeometryRevision=-1,aimValues={},aimWatchers={},hudBindings=0,toolSignals=0,modeBlocks={},throwGateCounts={},autoRecords={},playerAliases={},releaseDelays={},physicsRows={},arcProfiles={},gravityProofs={},gravitySource='PROVISIONAL',linkStatus='WAITING_FOR_DISCOVERY',linkDiscovery='NOT_RUN',linkChecks=0,manualHudStatus='NOT_OBSERVED',linkTargetReady=false,capabilityReady=false,expanded=false,ignoredBeams=0,ignoredBeamSeen=setmetatable({},{__mode='k'}),hudPathFailures={},markerEvents={},contextRevalidations=0,contextChanges=0,handoffRetains=0,targetRecords={},targetAckCount=0,selectedTargetConfirmed=false,selectFault='NONE',layouts={{id='LIVE_20_11',target=20,getter=11},{id='PRIOR_4_14',target=4,getter=14}}}

-- Folded options are opened only by the status pill, never during a throw.
A.controls=Instance.new('Frame');A.controls.Name='Options';A.controls.Size=UDim2.fromOffset(190,34)
A.controls.Position=UDim2.new(1,-194,0,88);A.controls.BackgroundTransparency=.15
A.controls.BackgroundColor3=Color3.fromRGB(22,29,32);A.controls.Visible=false;A.controls.Parent=gui;Instance.new('UICorner').Parent=A.controls
A.selectButton=makeButton('SEL\nAUTO',0,58);A.selectButton.Parent=A.controls;A.selectButton.Position=UDim2.fromOffset(2,2);A.selectButton.Size=UDim2.fromOffset(58,30)
throwButton.Parent=A.controls;throwButton.Position=UDim2.fromOffset(62,2);throwButton.Size=UDim2.fromOffset(38,30)
directionButton.Parent=A.controls;directionButton.Position=UDim2.fromOffset(102,2);directionButton.Size=UDim2.fromOffset(38,30)
A.controlButton=makeButton('CTRL',0,44);A.controlButton.Parent=A.controls
A.controlButton.Position=UDim2.fromOffset(142,2);A.controlButton.Size=UDim2.fromOffset(44,30)
local ballParts={};local ballSet={};local ballBorn={};local heldBall=nil;local lastHeldAt=nil;local lastHeldPosition=nil
local flight=nil;local releaseCount=0;local lastReleasedPart=nil;local lastReleasedAt=-math.huge
local ballRows={};local omittedBall=0;local ballErrors=0;local heldSnapshot=nil
local statusCounts={};local lastStatusLog=nil;local lastRankingKey=nil;local rankings={};local updateCount=0;local maxWork=0
local sessionTeam=nil;local sessionChar=nil;local priorTick=nil;local reportCopies=0;local copyOK=false
local everAutoRequested=true;local lastAutoRequested=false;local lastRunGate='NONE';local endSummary=nil;local finalData=nil
local modeDefs={{id='ROOT_SCREEN_RAW',part='HumanoidRootPart',projection='screen',offset=false}}
local Input=game:GetService('UserInputService');local GuiService=game:GetService('GuiService')
local V=Vector3.new;local ZERO=V(0,0,0)
local function clamp(x,a,b)return math.max(a,math.min(b,x))end
local function flat(v)return V(v.X,0,v.Z)end
local function limit(v,n)return v.Magnitude>n and v.Unit*n or v end
local function ascii(s)
 return tostring(s or ''):gsub('[^\32-\126\n]',function(c)return string.format('\\x%02X',c:byte())end)
end
local function clean(s)return ascii(s):gsub('[\r\n|]',' '):sub(1,100)end
local function norm(s)return tostring(s or ''):lower():gsub('%s+','')end
local function log(kind,s)
 local line=kind..'|'..string.format('%.3f',os.clock()-started)..'|'..s
 if #lines>=180 then bytes=bytes-#table.remove(lines,1)-1;omitted=omitted+1 end
 lines[#lines+1]=line;bytes=bytes+#line+1
end
A.recordTarget=function(kind,detail)
 if #A.targetRecords>=32 then table.remove(A.targetRecords,1)end
 A.targetRecords[#A.targetRecords+1]='TARGET_HANDOFF|'..string.format('%.3f',os.clock()-started)..'|'..kind..'|'..detail
end
A.disableSelection=function(reason)
 if not autoRequested and A.selectFault~='NONE'then return end
 autoRequested=false;A.overrideReady=false;A.selectFault=reason;A.selectedTargetConfirmed=false
 A.recordTarget('DISABLED','reason='..reason);log('AUTO_DISABLED',reason)
end
A.recordAuto=function(kind,detail)
 if #A.autoRecords>=32 then table.remove(A.autoRecords,1)end
 A.autoRecords[#A.autoRecords+1]='AUTO_RECEIPT|'..string.format('%.3f',os.clock()-started)..'|'..kind..'|'..detail
end
A.measure=function(name,elapsed)
 local p=A.perf[name];if not p then p={n=0,total=0,max=0};A.perf[name]=p end
 p.n=p.n+1;p.total=p.total+elapsed;p.max=math.max(p.max,elapsed)
end
local function readAll(fn)
    local ok,t=pcall(uv,fn);if ok and type(t)=='table' then return t end
end
local function eligible(fn)
    if type(fn)~='function' then return false,'NOT_FUNCTION' end
    if type(islclosure)=='function' then local ok,v=pcall(islclosure,fn);if ok and not v then return false,'NOT_LUA_CLOSURE' end end
    if type(isexecutorclosure)=='function' then local ok,v=pcall(isexecutorclosure,fn);if ok and not v then return false,'NOT_EXECUTOR_CLOSURE' end end
    return true,'ELIGIBLE'
end
-- Only this previously verified getter shape can be installed. No unknown-slot hooks.
A.selectorSignature=function(fn)
 local allowed,reason=eligible(fn);if not allowed then return false,reason end
 local ok,t=pcall(constants,fn);if not ok or type(t)~='table'then return false,'CONSTANTS_UNREADABLE'end
 local found={};local n=0
 for _,v in next,t do n=n+1;if n>512 then return false,'CONSTANTS_CAPPED'end;if type(v)=='string'then found[v]=true end end
 local missing={}
 for _,name in ipairs({'GetMouseLocation','WorldToScreenPoint','GetPlayers','Team','Health','Magnitude'})do
  if not found[name]then missing[#missing+1]=name end
 end
 if #missing>0 then return false,'MISSING_SYMBOLS:'..table.concat(missing,',')end
 if debug and type(debug.info)=='function'then
  local good,n,vararg=pcall(debug.info,fn,'a')
  if not good then return false,'ARITY_UNREADABLE'end
  if n~=0 or vararg then return false,'ARITY_MISMATCH'end
 end
 return true,'KNOWN_SELECTOR'
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
A.inGuiRoots=function(o)
 return o and o.Parent and(o:IsDescendantOf(pg)or roots[2]and o:IsDescendantOf(roots[2]))or false
end
local function addLabel(o)
    if stopped or labelSet[o] or not isText(o) or o:IsDescendantOf(gui) then return end
    if #labels>=3000 then
        local kept={};labelSet={}
        for _,x in ipairs(labels) do if A.inGuiRoots(x)then kept[#kept+1]=x;labelSet[x]=true end end
        labels=kept
    end
    if #labels<3000 then labels[#labels+1]=o;labelSet[o]=true;A.aimDiscoveryDirty=true;if A.addDownCandidate then A.addDownCandidate(o)end end
end
local function txt(o)return o.ContentText:match('^%s*(.-)%s*$')end
local function hudState()
    if not hud or not hud.Parent or not(hud:IsDescendantOf(pg)or roots[2]and hud:IsDescendantOf(roots[2]))then return 'MISSING',nil end
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
-- Match one complete visible four-card group. A hidden retained copy is not a candidate.
-- Public UI identity is evidence; it does not identify Yuna's eventual release consumer.
A.hudPath=function(o)
 if not o then return 'NONE' end
 local ok,path=pcall(function()return o:GetFullName()end)
 return ok and ascii(path):gsub('[\r\n|]',' ') or 'UNREADABLE'
end
A.recordHudIdentity=function(status,groups,group)
 A.hudGroupStatus=status;A.hudVisibleGroups=groups;A.hudGroupPath=A.hudPath(group)
 local key=status..'|'..groups..'|'..A.hudGroupPath
 if key~=A.lastHudIdentity then
  A.lastHudIdentity=key;A.hudIdentityRows=A.hudIdentityRows or{}
  if #A.hudIdentityRows>=8 then table.remove(A.hudIdentityRows,1)end
  A.hudIdentityRows[#A.hudIdentityRows+1]='HUD_GROUP|'..string.format('%.3f',os.clock()-started)..'|status='..status..'|visibleGroups='..groups..'|path='..A.hudGroupPath
 end
end
A.matchAimValues=function(ds,caps,playerValue,visibleOnly)
 local values={Player=playerValue}
 for _,name in ipairs({'Type','Time','Angle'})do
  local cap=caps[name];if not cap then return end
  local cx=cap.AbsolutePosition.X+cap.AbsoluteSize.X/2;local best,dist,tied=nil,math.huge,false
  for _,o in ipairs(ds)do
   if isText(o)and o~=caps.Player and o~=caps.Type and o~=caps.Time and o~=caps.Angle and o~=playerValue and(not visibleOnly or shown(o))then
    local t=txt(o);local valid=name=='Type'and(t=='Fit'or t=='Bullet'or t=='Jump')
     or name=='Time'and t:match('^%d+%.?%d*%s*s$')or name=='Angle'and tonumber((t:gsub('°','')))~=nil
    local dx=math.abs(o.AbsolutePosition.X+o.AbsoluteSize.X/2-cx);local dy=cap.AbsolutePosition.Y-o.AbsolutePosition.Y-o.AbsoluteSize.Y/2
    if valid and dx<60 and dy>0 and dy<100 then
     local distance=dx+dy
     if distance<dist-.001 then best=o;dist=distance;tied=false elseif math.abs(distance-dist)<.001 then tied=true end
    end
   end
  end
  if not best or tied then return end
  values[name]=best
 end
 return values
end
local function locate()
 local groups,seen={},{}
 for i,o in ipairs(labels)do
  if stopped then return end
  if A.inGuiRoots(o)and txt(o)=='Player'and shown(o)then
   local parent=o.Parent
   for _=1,4 do
    if not parent or parent==pg or parent==roots[2]then break end
    local ds=parent:GetDescendants()
    if #ds<=150 then
     local caps={};local duplicate=false
     for _,x in ipairs(ds)do
      if isText(x)and shown(x)then
       local t=txt(x)
       if t=='Player'or t=='Type'or t=='Time'or t=='Angle'then
        if caps[t]then duplicate=true end;caps[t]=x
       end
      end
     end
     if not duplicate and caps.Player and caps.Type and caps.Time and caps.Angle then
      local cap=caps.Player;local cx=cap.AbsolutePosition.X+cap.AbsoluteSize.X/2
      local best,dist,tied=nil,math.huge,false
      for _,x in ipairs(ds)do
       if isText(x)and x~=cap and shown(x)and knownName(txt(x))then
        local dx=math.abs(x.AbsolutePosition.X+x.AbsoluteSize.X/2-cx)
        local dy=cap.AbsolutePosition.Y-x.AbsolutePosition.Y-x.AbsoluteSize.Y/2
        if dx<60 and dy>0 and dy<100 then
         local distance=dx+dy
         if distance<dist-.001 then best=x;dist=distance;tied=false elseif math.abs(distance-dist)<.001 then tied=true end
        end
       end
      end
      if best and not tied and not seen[best]then
       local values=A.matchAimValues(ds,caps,best,true)
       if values then seen[best]=true;groups[#groups+1]={group=parent,ds=ds,caps=caps,values=values}end
      end
     end
    end
    parent=parent.Parent
   end
  end
  if i%150==0 then task.wait()end
 end
 A.aimDiscoveryDirty=false
 if #groups~=1 then
  A.recordHudIdentity(#groups>1 and 'AMBIGUOUS_VISIBLE'or'NO_COMPLETE_VISIBLE',#groups,nil)
  if #groups>1 then
   hud=nil;A.aim=nil;A.aimSafety=nil;A.aimTargetKey=nil;A.heldAimReceipt=nil;A.hudEvidence=nil;A.throwLock=nil;A.hudSyncSince=nil;A.overrideReady=false
   A.hudAmbiguityPaths={};for i=1,math.min(#groups,4)do A.hudAmbiguityPaths[i]=A.hudPath(groups[i].group)end
  end
  return
 end
 local candidate=groups[1];local values=candidate.values
 A.hudAmbiguityPaths=nil;A.recordHudIdentity('UNIQUE_VISIBLE',1,candidate.group)
 local same=hud==values.Player
 for _,name in ipairs({'Player','Type','Time','Angle'})do same=same and A.aimValues[name]==values[name]end
 if same then return end
 hud=values.Player;A.bindAimHud(candidate.ds,candidate.caps,hud,candidate.group,values)
 log('HUD_BOUND','one visible four-card Player/Type/Time/Angle group')
end
-- Observers invalidate stale receipts immediately. No foreign mode callbacks are called.
A.bindAimHud=function(ds,caps,playerValue,group,values)
 for _,c in ipairs(A.aimWatchers)do c:Disconnect()end
 A.aimWatchers={};A.aimValues=values or A.matchAimValues(ds,caps,playerValue,false)or{Player=playerValue};A.aimDirty=true
 A.aimRevision=(A.aimRevision or 0)+1;A.aimChanged={};A.aimChangedAt=os.clock();A.aimGroup=group or playerValue.Parent
 A.aim=nil;A.aimTargetKey=nil;A.aimSafety=nil;A.heldAimReceipt=nil;A.hudSyncSince=nil;A.throwLock=nil;A.hudEvidence=nil;hudFailures=0;lastHud=nil;A.hudBindings=A.hudBindings+1
 A.hudGroupPath=A.hudPath(A.aimGroup);A.hudGroupStatus='UNIQUE_VISIBLE';A.hudVisibleGroups=1
 for name,o in pairs(A.aimValues)do
  local component=name;local previous=txt(o);A.aimChanged[component]=os.clock()
  A.aimWatchers[#A.aimWatchers+1]=o:GetPropertyChangedSignal('Text'):Connect(function()
   local current=txt(o);if current==previous then return end;previous=current
   A.aimDirty=true;A.aimRevision=A.aimRevision+1;A.aimChangedAt=os.clock();A.aimChanged[component]=A.aimChangedAt
   A.aim=nil;A.aimSafety=nil;A.heldAimReceipt=nil
   if component=='Player'or component=='Type'then A.aimTargetKey=nil;A.throwLock=nil;A.hudSyncSince=nil end
  end)
  A.aimWatchers[#A.aimWatchers+1]=o.AncestryChanged:Connect(function()
   A.aimDirty=true;A.aimRevision=A.aimRevision+1;A.aim=nil;A.aimTargetKey=nil;A.aimSafety=nil;A.heldAimReceipt=nil;A.aimDiscoveryDirty=true
  end)
 end
 log('MODE_HUD_BOUND','type='..tostring(A.aimValues.Type~=nil)..'|time='..tostring(A.aimValues.Time~=nil)..'|angle='..tostring(A.aimValues.Angle~=nil))
end
A.aimNeedsBinding=function()
 if not hud or not A.inGuiRoots(hud)then return true end
 for _,name in ipairs({'Player','Type','Time','Angle'})do
  local value=A.aimValues[name]
  if not value or not A.inGuiRoots(value)then return true end
 end
 return false
end
A.ensureAimHud=function(now)
 local needs=A.aimNeedsBinding()
 -- A hidden/no-ball card remains valid without costly scans. While holding a ball,
 -- audit at most once per second so a retained hidden card cannot mask a new HUD.
 local audit=ownHeld and(A.aimDiscoveryDirty or not hud or not shown(hud)or now>=(A.nextAimAudit or 0))
 if not needs and not audit then return end
 if now<(A.nextAimLocate or 0)then return end
 A.nextAimLocate=now+1;A.nextAimAudit=now+2
 if needs then A.aim=nil;A.aimSafety=nil;A.heldAimReceipt=nil;A.hudSyncSince=nil;A.throwLock=nil end
 locate()
end
A.readAimHud=function(now)
 A.hudSnapshotStatus='UNVERIFIED'
 if A.aimNeedsBinding()then A.aim=nil;A.aimTargetKey=nil;return end
 local v=A.aimValues;local player,mode,time,angle=v.Player,v.Type,v.Time,v.Angle
 if not shown(player)or not shown(mode)or not shown(time)or not shown(angle)then A.aim=nil;A.aimTargetKey=nil;A.hudSnapshotStatus='HIDDEN';return end
 local revision=A.aimRevision or 0
 -- Read each displayed value once without yielding; fence any reentrant change.
 -- This is one visible UI snapshot, not proof that the producer used one solver state.
 local name,rawMode,rawTime,rawAngle=txt(player),txt(mode),txt(time),txt(angle)
 if revision~=(A.aimRevision or 0)then A.aim=nil;A.hudSnapshotStatus='CHANGED_DURING_READ';return end
 local kind=rawMode:upper();local tv=tonumber(rawTime:match('^(%d+%.?%d*)%s*s$'));local av=tonumber((rawAngle:gsub('°','')))
 if name==''or(kind~='BULLET'and kind~='FIT'and kind~='JUMP')or not tv or tv<=0 or tv>CFG.MaxFlight+.5 or not av or av< -30 or av>80 then
  A.aim=nil;A.aimTargetKey=nil;A.heldAimReceipt=nil;A.hudSnapshotStatus='INCOMPLETE_VALUES';return
 end
 local key=norm(name)..'|'..kind
 if A.aimTargetKey~=key then A.aimTargetKey=key;A.aimStableAt=now;A.aimSafety=nil end
 local fraction=rawTime:match('%.(%d+)');local quantum=fraction and 10^(-#fraction)or 1
 A.aim={target=name,mode=kind,time=tv,angle=av,quantum=quantum,at=now,stableAt=A.aimStableAt,key=key,revision=revision,group=A.hudGroupPath,source='VISIBLE_PUBLIC_HUD_SNAPSHOT'};A.aimDirty=false
 A.hudSnapshotStatus='VISIBLE_VALUES_PRODUCER_COHERENCE_UNVERIFIED'
 if ownHeld and A.resolveHudTarget then
  local a,reason=A.resolveHudTarget(name,now);A.manualHudStatus=reason
  if a then A.heldAimReceipt={aim=A.aim,model=a.model,at=now,possession=A.possessionID,char=sessionChar,team=sessionTeam,evidence='PUBLIC_HUD_UNIQUE_TEAMMATE'}
  else A.heldAimReceipt=nil end
 end
 local logkey=key..'|'..av..'|'..tv
 if logkey~=A.lastAimLog and now>=(A.nextAimLog or 0)then
  log('YUNA_AIM',clean(name)..'|actualMode='..kind..'|angle='..av..'|time='..tv);A.lastAimLog=logkey;A.nextAimLog=now+.3
  A.hudSnapshotRows=A.hudSnapshotRows or{};if #A.hudSnapshotRows>=8 then table.remove(A.hudSnapshotRows,1)end
  local changed=A.aimChanged or{};local times={}
  for _,component in ipairs({'Player','Type','Time','Angle'})do times[#times+1]=component..'='..string.format('%.3f',(changed[component]or now)-started)end
  A.hudSnapshotRows[#A.hudSnapshotRows+1]='HUD_SNAPSHOT|'..string.format('%.3f',now-started)..'|revision='..revision..'|target='..clean(name)..'|mode='..kind..'|time='..tv..'|angle='..av..'|lastChanges='..table.concat(times,',')..'|group='..A.hudGroupPath
 end
end
local function discover()
 local ok,list=pcall(conns,Run.Heartbeat)
 if not ok or type(list)~='table'then A.linkStatus='HEARTBEAT_UNAVAILABLE';A.linkDiscovery='HEARTBEAT_UNAVAILABLE';log('DISCOVERY',A.linkStatus);return end
 for _,c in ipairs(candidates)do c.active=false end
 local counts={};local eligibleCount=0
 local function count(reason)counts[reason]=(counts[reason]or 0)+1 end
 if #list>512 then limits.connections=limits.connections+1 end
 for i=1,math.min(#list,512)do
  local c=list[i]
  local good,fn,reason=pcall(function()
   if c.ForeignState==true then return nil,'FOREIGN_STATE'end
   if c.LuaConnection==false then return nil,'NATIVE_CONNECTION'end
   if c.Enabled==false then return nil,'DISABLED_CONNECTION'end
   return c.Function
  end)
  if not good then count('CONNECTION_UNREADABLE')
  elseif reason then count(reason)
  else
   local allowed,why=eligible(fn)
   if not allowed then count(why)
   else
    eligibleCount=eligibleCount+1
    local record=byFn[fn]
    if not record and #candidates<512 then
     record={fn=fn,id='H'..(#candidates+1),history={},lastLabel=nil,switches=0,reason='NOT_SAMPLED',reads=0,readErrors=0}
     candidates[#candidates+1]=record;byFn[fn]=record
    end
    if record then record.active=true else count('CANDIDATE_CAP')end
   end
  end
 end
 local rows={'Heartbeat='..#list,'activeEligible='..eligibleCount,'retained='..#candidates,'connectionCap='..tostring(#list>512)}
 local reasons={};for reason in pairs(counts)do reasons[#reasons+1]=reason end;table.sort(reasons)
 for _,reason in ipairs(reasons)do rows[#rows+1]=reason..'='..counts[reason]end
 A.linkDiscovery=table.concat(rows,'|');A.discoveryReady=true
 if eligibleCount==0 then A.linkStatus='NO_ELIGIBLE_CALLBACKS'end
 if A.linkDiscovery~=limits.lastDiscovery then limits.lastDiscovery=A.linkDiscovery;log('DISCOVERY',A.linkDiscovery)end
end
local function agreement(c)
 local hits=0;for _,yes in ipairs(c.history)do if yes then hits=hits+1 end end
 return #c.history>=20 and hits/#c.history>=.95 and c.switches>=2,hits,#c.history
end
A.inspectLinkSlots=function(c,t,label,now)
 if now<(c.nextSlots or 0)then return end;c.nextSlots=now+8
 local shapes={};local getters={};local matched={};local checked=0;c.getterScanCapped=false
 for i=1,64 do
  local v=rawget(t,i)
  if typeof(v)=='Instance'and(v:IsA('Attachment')or v:IsA('Model')or v:IsA('Player'))then
   shapes[#shapes+1]=i..':'..v.ClassName
   local a=actor(v);if matches(a,label)then matched[#matched+1]=tostring(i)end
  elseif type(v)=='function'then
   if checked<8 then checked=checked+1;local ok=A.selectorSignature(v);if ok then getters[#getters+1]=tostring(i)end
   else c.getterScanCapped=true end
  end
 end
 c.slots=table.concat(shapes,',');c.getterSlots=table.concat(getters,',');c.hudSlots=table.concat(matched,',')
end
A.sampleLayout=function(c,t,layout,label,now)
 c.layoutEvidence=c.layoutEvidence or{};local e=c.layoutEvidence[layout.id]
 if not e then e={layout=layout,history={},lastLabel=nil,switches=0,reason='NOT_SAMPLED'};c.layoutEvidence[layout.id]=e end
 local v=t and rawget(t,layout.target);local a=t and actor(v);local hit=false
 e.uv4Type=typeof(v);e.uv4Class=typeof(v)=='Instance'and v.ClassName or 'NONE'
 e.uv4Name=typeof(v)=='Instance'and v:IsA('Attachment')and clean(v.Name)or 'NONE';e.actorName=a and clean(a.name)or 'NONE'
 if not t then e.reason='UPVALUE_READ_FAILED'
 else
  local getter=rawget(t,layout.getter)
  if e.signatureFn~=getter or now>=(e.nextSignature or 0)then
   e.signatureFn=getter;e.signatureOK,e.signatureReason=A.selectorSignature(getter);e.nextSignature=now+8
  end
  if typeof(v)~='Instance'or not v:IsA('Attachment')then e.reason='TARGET_NOT_ATTACHMENT'
  elseif not a or not a.model:IsDescendantOf(workspace)or a.owner and a.owner.Character~=a.model then e.reason='TARGET_NOT_CURRENT_ACTOR'
  elseif not matches(a,label)then e.reason='TARGET_HUD_DIFFERS'
  elseif not e.signatureOK then e.reason='GETTER_SIGNATURE_UNVERIFIED'
  else
   hit=true;e.reason='COLLECTING_AGREEMENT'
   if e.lastLabel and e.lastLabel~=norm(label)then e.switches=e.switches+1 end;e.lastLabel=norm(label)
  end
 end
 e.history[#e.history+1]=hit;if #e.history>80 then table.remove(e.history,1)end
 local ready,hits,n=agreement(e);e.hits=hits;e.samples=n;e.hit=hit;e.value=v
 if hit then e.reason=ready and 'QUALIFIED'or n>=20 and hits/n>=.95 and 'NEEDS_TARGET_CHANGES'or 'COLLECTING_AGREEMENT'end
 return e,ready and hit,a and typeof(v)=='Instance'and v:IsA('Attachment')and matches(a,label)
end
local function bind()
 A.linkChecks=A.linkChecks+1
 if not A.capabilityReady then A.linkStatus='WAITING_FOR_REFLECTION_API';return end
 local state,label=hudState()
 if state~='LIVE'then A.linkStatus=state=='HIDDEN'and 'WAITING_FOR_HELD_BALL_HUD'or 'WAITING_FOR_YUNA_HUD';return end
 local now=os.clock();local qualified={};local matching,learning,unknownGetter,activeCount=0,0,0,0
 for _,c in ipairs(candidates)do
  if c.active then
   activeCount=activeCount+1;local t=readAll(c.fn);c.reads=(c.reads or 0)+1
   if not t then c.readErrors=(c.readErrors or 0)+1 else A.inspectLinkSlots(c,t,label,now)end
   local best=nil
   for _,layout in ipairs(A.layouts)do
    local e,ready,targetMatch=A.sampleLayout(c,t,layout,label,now)
    if targetMatch then matching=matching+1 end
    if e.hit then learning=learning+1 elseif targetMatch then unknownGetter=unknownGetter+1 end
    if ready then qualified[#qualified+1]={c=c,v=e.value,e=e,layout=layout}end
    local priority=(e.hit and 10000 or targetMatch and 5000 or e.uv4Class=='Attachment'and 1000 or 0)+e.hits
    if not best or priority>best.priority then best={e=e,priority=priority}end
   end
   local e=best.e;c.layout=e.layout
   for _,name in ipairs({'history','lastLabel','switches','reason','uv4Type','uv4Class','uv4Name','actorName','signatureFn','signatureOK','signatureReason','hits','samples'})do c[name]=e[name]end
  end
 end
 A.linkMatches=matching;A.linkQualified=#qualified
 if #qualified==1 then
  local q=qualified[1];anchor=q.c;anchor.layout=q.layout;marker=q.v;A.linkTargetReady=false;A.linkStatus='ANCHOR_VERIFIED'
  log('ANCHOR_BOUND',anchor.id..'|layout='..q.layout.id..'|agreement='..q.e.hits..'/'..q.e.samples..'|switches='..q.e.switches..'|attachmentName='..clean(marker.Name))
 elseif #qualified>1 then A.linkStatus='AMBIGUOUS_CALLBACKS_OR_LAYOUTS'
 elseif learning>0 then A.linkStatus='COLLECTING_TARGET_AGREEMENT'
 elseif unknownGetter>0 then A.linkStatus='MATCHING_ACTOR_UNKNOWN_GETTER'
 elseif activeCount==0 then A.linkStatus='NO_ELIGIBLE_CALLBACKS'
 else A.linkStatus='NO_SUPPORTED_LAYOUT_HUD_MATCH'end
end
A.targetSlot=function()return anchor and anchor.layout and anchor.layout.target or 4 end
A.getterSlot=function()return anchor and anchor.layout and anchor.layout.getter or 14 end

local function readSlot()
 if not anchor then return false,nil end
 local t=readAll(anchor.fn);return t~=nil,t and rawget(t,A.getterSlot())
end
local function restore()
 if writeInFlight then restoreState='INSTALL_PENDING';wrapperAbsent=false;return end
 if not writeAttempted then restoreState='NOT_INSTALLED';wrapperAbsent=true;return end
 local readable,current=readSlot()
 if not readable then restoreState='READBACK_FAILED';wrapperAbsent=false;return end
 if current==wrapper then
  local ok=pcall(setuv,anchor.fn,A.getterSlot(),original)
  local verified,value=readSlot()
  if verified and value==original then restoreState='RESTORED';wrapperAbsent=true
  elseif verified and value~=wrapper then restoreState='NEWER_VALUE_PRESERVED';wrapperAbsent=true
  else restoreState=ok and 'RESTORE_NOT_CONFIRMED' or 'RESTORE_WRITE_FAILED';wrapperAbsent=false end
 elseif current==original then restoreState='ORIGINAL_PRESENT';wrapperAbsent=true
 else restoreState='NEWER_VALUE_PRESERVED';wrapperAbsent=true end
end
local function vec(v)return v and string.format('%.2f,%.2f,%.2f',v.X,v.Y,v.Z) or 'NONE' end
local function report(final)
 local out={'PELICAN_FF3_LIVE_V13','STATE|'..(final and 'FINAL' or 'RUNNING'),'PLACE|'..game.PlaceId,
 'GAME|'..tostring(game.GameId),'MODULE_VERSION|PELICAN_FF3_V13','LOADER_VERSION|'..clean(loaderContext and loaderContext.LoaderVersion or 'STANDALONE'),
 'SOURCE_REF|'..clean(loaderContext and loaderContext.Ref or 'LOCAL'),'ROUTE|'..clean(loaderContext and loaderContext.RouteName or 'FF3 live'),
 'SOURCE_MODE|'..clean(loaderContext and loaderContext.SourceMode or 'STANDALONE'),
 'CONTROL_TEST|'..tostring(A.controlActive or false),'CONTROL_RESULT|'..clean(A.controlResult or 'NOT_RUN'),
 'CONTROL_POLICY|Bounded fixed safe target; manual release only; preserves exact selector contract',
 'HUD_PATH_POLICY|Unverified provisional model blocks release; does not mark receiver unsafe',
 'OUTCOME|'..outcome,'PHASE|'..phase,'AUTO_REQUESTED|'..tostring(autoRequested),'GATE|'..gate,
 'POLICY|Live human teammates only; single native equipped-Tool auto release; Yuna retains automatic mode selection',
 'SELECT_FAULT|'..A.selectFault,'TARGET_ACK_COUNT|'..A.targetAckCount,'SELECTED_TARGET_CONFIRMED|'..tostring(A.selectedTargetConfirmed),'AUTO_THROW_REQUESTED|'..tostring(A.autoThrowRequested),'LAST_AUTO_THROW_REQUESTED|'..tostring(A.lastAutoThrowRequested or false),'THROW_STATUS|'..A.throwStatus,'AUTO_THROW_ATTEMPTS|'..A.throwAttempts,'AUTO_RELEASES|'..A.automaticReleases,
 'DIRECTION_SOURCE|'..A.context.source,'LINE_STATUS|'..A.context.status,'LINE_REVALIDATIONS|'..A.contextRevalidations,'LINE_MEANINGFUL_CHANGES|'..A.contextChanges,'SAFE_HANDOFF_RETAINS|'..A.handoffRetains,'LINE_CONTEXT_CONFIRMATIONS|'..tostring(A.contextProofs or 0),'LAST_CONFIRMED_LOS|'..vec(A.lastContext and A.lastContext.los),'LAST_CONFIRMED_FIRST|'..vec(A.lastContext and A.lastContext.first),'LOS|'..vec(A.context.los),'FIRST_DOWN|'..vec(A.context.first),
 'HUD_YARDS_TO_GO|'..tostring(A.context.yards or 'NONE'),'FIRST_DOWN_TARGET_ROLE|'..tostring(A.context.targetRole or 'UNKNOWN'),'DOWN|'..tostring(A.context.down or 'UNKNOWN'),'PLAY_KEY|'..clean(A.playKey),'MARKER_NODES|'..A.markerNodes,'MARKER_SCAN_CAPPED|'..tostring(A.markerCap),
 'IDLE_SKIPPED_LAST_UPDATE|'..A.idleSkipped,'ERRATIC_SKIPPED_LAST_UPDATE|'..A.erraticSkipped,
 'MODEL|95 speed/42-degree Jump remain provisional; gravity can update from independently checked force/mass/arc evidence; receiver/mode pair ranking; actual HUD angle check across release-delay endpoints',
 'LIMITATIONS|Field inference, arrival estimates and possession-start LOS proxy are not authoritative FF3 data; fallback does not filter original Yuna choices',
 'STARTUP_ORDER|Either order; waits for Yuna plus a visible held-ball HUD','SELECTED_LAYOUT|'..(anchor and anchor.layout and anchor.layout.id or 'NONE'),'SELECTED_TARGET_SLOT|'..(anchor and A.targetSlot()or 'NONE'),'SELECTED_GETTER_SLOT|'..(anchor and A.getterSlot()or 'NONE'),'LINK_TARGET_READY|'..tostring(A.linkTargetReady),'CAPABILITY_READY|'..tostring(A.capabilityReady),'UI|Collapsed 138x22; tap status for options; red dot ends','LINK_STATUS|'..A.linkStatus,'LINK_DISCOVERY|'..A.linkDiscovery,'LINK_CHECKS|'..A.linkChecks,'LINK_MATCHES|'..tostring(A.linkMatches or 0),'LINK_QUALIFIED|'..tostring(A.linkQualified or 0),'MANUAL_HUD_STATUS|'..A.manualHudStatus,
 'ANCHOR|'..(anchor and anchor.id or 'NONE'),'R2|'..(numericMode and numericMode.id or 'UNVERIFIED'),
 'RESTORE|'..restoreState,'WRAPPER_ABSENT|'..tostring(wrapperAbsent),'CALLS|'..calls,'RETURNS|'..returns,
 'CLEANUP_CONFIRMED|'..tostring(A.cleanupConfirmed and A.cleanupConfirmed(true)or false),'CLEANUP_LAST_ERROR|'..clean(A.cleanupFailure or 'NONE'),
 'CAPTURE_ERRORS|'..captureErrors,'TUPLE_ERRORS|'..tupleErrors,'OVERRIDES|'..overrideCalls,'DIFFERENT_NORMAL|'..differentCalls,
 'HUD_AGREEMENT|'..hudHits..'/'..hudChecks,'HUD_DIFFERENT_NORMAL|'..normalDifferentHits..'/'..normalDifferentChecks,
 'FIELD|'..(field and 'OBSERVED_GROUND_FOUR_BOUNDARY_STRIPS' or 'NONE'),'FIELD_SIZE|'..(field and vec(field.part.Size) or 'NONE'),
 'FIELD_INNER_HALF_XZ|'..(field and string.format('%.2f,%.2f',field.halfX,field.halfZ) or 'NONE'),
 'GROUND_RAY_HITS|'..floorRayHits,'BOUNDARY_MATCHES|'..(field and 4 or 0),
 'EVER_AUTO_REQUESTED|'..tostring(everAutoRequested),'LAST_AUTO_REQUESTED|'..tostring(lastAutoRequested),'LAST_RUN_GATE|'..lastRunGate,
 'FORWARD|'..vec(forward),'POSSESSION_START|'..vec(possessionStart),'RELEASES|'..releaseCount,
 'BALL_ERRORS|'..ballErrors,'FIELD_CAP_HITS|'..fieldCap,'UPDATES|'..updateCount,'MAX_WORK_MS|'..string.format('%.2f',maxWork*1000),
 'FIELD_SCAN_COMPLETE|'..tostring(scanDone),'FIELD_SCAN_CAPPED|'..tostring(limits.scanCap or false),
 'BALL_REGISTRY_CAPPED|'..tostring(limits.ballCap or false),
 'OMITTED_LOGS|'..omitted,'OMITTED_BALL_ROWS|'..omittedBall,'COPY_ATTEMPTS|'..reportCopies,
 'B_FORMAT|passID|time|ballXYZ|selectedRootXYZ|normalRootXYZ',
 'PERFORMANCE|Event-cached field/line geometry; cached HUD/Tool/character references; analytic pass lanes; sliced scoring; 8-second compact checkpoints',
 'PATH_LEARNING|Native ball velocity, BodyForce/mass, distance-based arcs and timestamp profiles; initial airborne segment only; exact Yuna mode solver unverified',
 'PATH_PROFILES|'..#A.pathProfiles,'PATH_REJECTED|'..A.pathRejected,
 'ACTIVE_GRAVITY|'..string.format('%.3f',CFG.Gravity),'GRAVITY_SOURCE|'..A.gravitySource,
 'RELEASE_DELAY_WINDOW|'..string.format('%.3f,%.3f',CFG.ReleaseDelayLow,CFG.ReleaseDelayHigh),
 'MARKER_GEOMETRY_CALLS|'..A.markerGeometryCalls,'FIELD_CACHE|Event invalidation plus 2-second audit',
 'ARC_PROFILES|'..#A.arcProfiles,
 'MODE_CONTROL|Yuna retains mode control; unsuitable displayed modes block auto release and reconsider the receiver',
 'AIM_HUD|Type='..tostring(A.aimValues.Type~=nil)..'|Time='..tostring(A.aimValues.Time~=nil)..'|Angle='..tostring(A.aimValues.Angle~=nil),
 'REFERENCE_POLICY|Ball-only flight calibration; Alexander interception outcomes do not tune receiver or defender models',
 'FIELD_BEAM_POLICY|Only straight full-width ground-plane blue/yellow lines; unrelated visuals have no listeners','IGNORED_NONFIELD_BEAMS|'..A.ignoredBeams,'WATCHED_MARKER_OBJECTS|'..#A.markerParts,
 'AUTO_RELEASE_POLICY|No manual warm-up; equipped enabled football Tool; once per possession; stop on activation failure',
 'HANDOFF_POLICY|Continuous target delivery independent of HUD acknowledgement; actual attachment and HUD agreement required for release',
 'OPEN_HOLD_SECONDS|'..CFG.ThrowHold,'HUD_CONFIRM_SECONDS|0.08','HUD_BINDINGS|'..A.hudBindings,'TOOL_ACTIVATED_SIGNALS|'..A.toolSignals}

 -- Durable bounded binding evidence, independent of the 180-line rolling play log.
 local diagnostic={};for _,c in ipairs(candidates)do diagnostic[#diagnostic+1]=c end
 table.sort(diagnostic,function(a,b)if(a.hits or 0)~=(b.hits or 0)then return(a.hits or 0)>(b.hits or 0)end;return a.id<b.id end)
 for i=1,math.min(24,#diagnostic)do
  local c=diagnostic[i]
  out[#out+1]='LINK_CANDIDATE|'..c.id..'|active='..tostring(c.active)..'|reason='..(c.reason or 'NOT_SAMPLED')
   ..'|reads='..(c.reads or 0)..'|readErrors='..(c.readErrors or 0)..'|layout='..(c.layout and c.layout.id or 'NONE')..'|TARGET='..(c.uv4Type or 'UNKNOWN')..':'..(c.uv4Class or 'NONE')
   ..'|attachmentName='..(c.uv4Name or 'NONE')..'|actor='..(c.actorName or 'NONE')..'|agreement='..(c.hits or 0)..'/'..(c.samples or 0)..'|changes='..c.switches
   ..'|GETTER='..(c.signatureReason or 'NOT_CHECKED')..'|instanceSlots1to64='..(c.slots or '')..'|knownGetterSlots1to64='..(c.getterSlots or '')..'|getterScanCapped='..tostring(c.getterScanCapped or false)..'|HUDMatchSlotsAtScan='..(c.hudSlots or '')
  for _,layout in ipairs(A.layouts)do
   local e=c.layoutEvidence and c.layoutEvidence[layout.id]
   if e then out[#out+1]='LINK_LAYOUT|'..c.id..'|'..layout.id..'|targetSlot='..layout.target..'|getterSlot='..layout.getter..'|reason='..e.reason..'|agreement='..e.hits..'/'..e.samples..'|changes='..e.switches..'|signature='..(e.signatureReason or 'NOT_CHECKED')end
  end
 end
 out[#out+1]='LINK_DIAGNOSTICS_OMITTED|'..math.max(0,#diagnostic-24)
 out[#out+1]='HUD_DOWN_STATUS|'..(A.downStatus or 'NOT_READ')
 out[#out+1]='HUD_DOWN_CANDIDATES|'..#A.downLabels
 out[#out+1]='HUD_GROUP_STATUS|'..(A.hudGroupStatus or 'NOT_BOUND')
 out[#out+1]='HUD_VISIBLE_GROUPS|'..tostring(A.hudVisibleGroups or 0)
 out[#out+1]='HUD_GROUP_PATH|'..(A.hudGroupPath or 'NONE')
 out[#out+1]='HUD_SNAPSHOT_STATUS|'..(A.hudSnapshotStatus or 'NOT_READ')
 out[#out+1]='HUD_SNAPSHOT_POLICY|Synchronous visible values and target/type settling; producer and release-time mode coherence unverified'
 for _,name in ipairs({'Player','Type','Time','Angle'})do out[#out+1]='HUD_VALUE_PATH|'..name..'|'..A.hudPath(A.aimValues[name])end
 for _,path in ipairs(A.hudAmbiguityPaths or{})do out[#out+1]='HUD_AMBIGUOUS_GROUP_PATH|'..path end
 for _,row in ipairs(A.hudIdentityRows or{})do out[#out+1]=row end
 for _,row in ipairs(A.hudSnapshotRows or{})do out[#out+1]=row end
 for _,alias in pairs(A.playerAliases)do out[#out+1]='PLAYER_ALIAS|'..alias end
 for reason,n in pairs(A.throwGateCounts)do out[#out+1]='THROW_GATE_COUNT|'..reason..'|'..n end
 for _,row in ipairs(A.hudPathFailures)do out[#out+1]=row end
 for name,count in pairs(A.markerEvents)do out[#out+1]='MARKER_EVENT|'..name..'|'..count end
 for _,receipt in ipairs(A.targetRecords)do out[#out+1]=receipt end
 for _,receipt in ipairs(A.autoRecords)do out[#out+1]=receipt end
 for _,line in ipairs(A.releaseDelays)do out[#out+1]=line end
 for _,line in ipairs(A.physicsRows)do out[#out+1]=line end
 for _,line in ipairs(A.arcProfiles)do out[#out+1]=line end
 for name,p in pairs(A.perf)do out[#out+1]='PERF|'..name..'|n='..p.n..'|avgMS='..string.format('%.3f',p.total/p.n*1000)..'|maxMS='..string.format('%.3f',p.max*1000)end
 for _,line in ipairs(A.pathProfiles)do out[#out+1]=line end
 for reason,n in pairs(statusCounts) do out[#out+1]='GATE_COUNT|'..reason..'|'..n end
 for _,line in ipairs(fieldDiagnostics) do out[#out+1]='FIELD_CANDIDATE|'..line end
 for _,line in ipairs(A.markerRows)do out[#out+1]='MARKER|'..line end
 for _,line in ipairs(A.lastMarkerRows or {})do out[#out+1]='LAST_MARKER|'..line end
 for _,line in ipairs(A.markerMeta)do out[#out+1]='PUBLIC_CONTEXT_HINT|'..line end
 for sig,n in pairs(A.toolProofs)do out[#out+1]='TOOL_PROOFS|'..clean(sig)..'|'..n end
 for i=final and 1 or math.max(1,#lines-35),#lines do out[#out+1]=lines[i]end
 for i=final and 1 or math.max(1,#ballRows-63),#ballRows do out[#out+1]=ballRows[i]end
 out[#out+1]='REPORT_END';return ascii(table.concat(out,'\n'))
end
-- Results open only after END. Gameplay uses a collapsed 138x22 surface.
local function showEndSummary()
 if endSummary and endSummary.Parent then endSummary.Visible=true;return end
 endSummary=Instance.new('Frame');endSummary.Name='EndResults';endSummary.Size=UDim2.fromOffset(340,238)
 endSummary.Position=UDim2.new(.5,-170,.5,-119);endSummary.BackgroundColor3=Color3.fromRGB(15,20,25);endSummary.Parent=gui
 local label=Instance.new('TextLabel');label.Position=UDim2.fromOffset(10,10);label.Size=UDim2.fromOffset(320,184)
 label.BackgroundTransparency=1;label.TextColor3=Color3.new(1,1,1);label.Font=Enum.Font.Code;label.TextSize=13
 label.TextXAlignment=Enum.TextXAlignment.Left;label.TextYAlignment=Enum.TextYAlignment.Top;label.TextWrapped=false;label.Parent=endSummary
 local resultsPage=1
 local function refresh()
  if resultsPage==2 then
   label.Text=table.concat({'PELICAN LIVE V13 | CONTEXT / THROW',
    'Direction: '..A.context.source,'Lines ever found: '..tostring((A.contextProofs or 0)>0),
    'LOS: '..vec(A.context.los),'First down: '..vec(A.context.first),
    'HUD yards to go: '..tostring(A.context.yards or 'NONE'),
    'Profiles / rejected: '..#A.pathProfiles..' / '..A.pathRejected,'Marker candidates: '..#A.markerParts,
    'Throw: '..A.throwStatus,'Auto attempts / releases: '..A.throwAttempts..' / '..A.automaticReleases,
    'Idle / erratic skipped: '..A.idleSkipped..' / '..A.erraticSkipped,
    'Observe / score max ms: '..string.format('%.1f / %.1f',(A.perf.OBSERVE and A.perf.OBSERVE.max or 0)*1000,(A.perf.SCORE_SLICE and A.perf.SCORE_SLICE.max or 0)*1000),
   'Control: '..tostring(A.controlResult or 'NOT_RUN')},'\n');return
  end
  label.Text=table.concat({'PELICAN LIVE V13 | END RESULTS',
   'Cleanup: '..restoreState,'Wrapper absent: '..tostring(wrapperAbsent),
   'Field inner half X/Z: '..(field and string.format('%.1f / %.1f',field.halfX,field.halfZ) or 'UNCONFIRMED'),
   'Ground rays / boundary strips: '..floorRayHits..' / '..(field and 4 or 0),
   'Link: '..A.linkStatus,'Phase / R2: '..phase..' / '..(numericMode and 'VERIFIED' or 'UNVERIFIED'),
   'Auto requested: '..tostring(everAutoRequested),'Last gate: '..lastRunGate,
   'Overrides / changed: '..overrideCalls..' / '..differentCalls,
   'HUD matches: '..hudHits..' / '..hudChecks,'Passes recorded: '..releaseCount,
   'Copy '..(copyOK and 'sent; OS unverified' or 'failed')},'\n')
 end
 local hide=Instance.new('TextButton');hide.Size=UDim2.fromOffset(155,28);hide.Position=UDim2.fromOffset(10,200)
 hide.Text='HIDE RESULTS';hide.Font=Enum.Font.GothamMedium;hide.TextSize=12;hide.TextColor3=Color3.new(1,1,1)
 hide.BackgroundColor3=Color3.fromRGB(50,60,70);hide.Parent=endSummary;hide.Activated:Connect(function()endSummary.Visible=false end)
 local more=Instance.new('TextButton');more.Size=UDim2.fromOffset(155,28);more.Position=UDim2.fromOffset(175,200)
 more.Text='NEXT RESULTS';more.Font=Enum.Font.GothamMedium;more.TextSize=12;more.TextColor3=Color3.new(1,1,1)
 more.BackgroundColor3=Color3.fromRGB(50,60,70);more.Parent=endSummary;more.Activated:Connect(function()resultsPage=3-resultsPage;refresh()end)
 endSummary:SetAttribute('Ready',true);refresh()
 -- A retry can change cleanup/copy status, so rebuild this summary on each END.
end
local function copy(final)
 local begun=os.clock();reportCopies=reportCopies+1;local s=report(final)
 if not finalData then finalData=Instance.new('StringValue');finalData.Name='ReportData';finalData.Parent=gui end
 finalData.Value=s
 copyOK=type(setclipboard)=='function' and pcall(setclipboard,s) or false
 if (final or not ownHeld)and type(writefile)=='function' then pcall(writefile,'PELICAN_FF3_LIVE_REPORT.txt',s)end
 A.measure('CHECKPOINT',os.clock()-begun)
 if final then
  panel.Text=copyOK and 'COPY SENT'or 'COPY FAILED';panel.BackgroundColor3=wrapperAbsent and Color3.fromRGB(15,65,35)or Color3.fromRGB(140,30,30)
  if endSummary then endSummary:Destroy();endSummary=nil end;showEndSummary()
 end
end
A.disconnectList=function(list)
 local pending={}
 for _,connection in ipairs(list or{})do
  local ok,why=pcall(function()connection:Disconnect()end)
  if not ok then pending[#pending+1]=connection;A.cleanupFailure=clean(why)end
 end
 return pending
end
A.cleanupConfirmed=function(forReport)
 if not stopped or(finishing and not forReport)or not wrapperAbsent or writeInFlight or #watchers>0
  or A.charBallConnection or A.toolConnection or #(A.toolWatchers or{})>0 or #A.fieldWatchers>0 or #A.aimWatchers>0 then return false end
 for _,list in pairs(A.markerWatchers)do if #list>0 then return false end end
 for _,record in pairs(A.markerCache)do if #(record.endpoints or{})>0 then return false end end
 return true
end
local function finish(reason)
 if A.cleanupConfirmed()then
  if reason=='USER_END'and gui.Parent then pcall(copy,true)end
  return
 end
 if finishing then return end;finishing=true
 local first=not stopped;if first then lastAutoRequested=autoRequested;lastRunGate=gate;A.lastAutoThrowRequested=A.autoThrowRequested end
 if A.controlActive and A.endControl then A.endControl(reason)end
 stopped=true;selection=nil;ownHeld=false;autoRequested=false;A.autoThrowRequested=false;A.overrideReady=false;A.decision=nil;A.controlActive=false
 if A.pendingThrow and A.pendingThrow.tool then pcall(function()A.pendingThrow.tool:Deactivate()end)end
 A.pendingThrow=nil
 if flight and A.finishPath then
  local profiled,why=pcall(A.finishPath,flight,'END');if not profiled then log('END_PROFILE_ERROR',clean(why))end
 end
 flight=nil
 if A.charBallConnection then A.charBallConnection=A.disconnectList({A.charBallConnection})[1]end
 A.toolWatchers=A.disconnectList(A.toolWatchers)
 A.fieldWatchers=A.disconnectList(A.fieldWatchers)
 A.aimWatchers=A.disconnectList(A.aimWatchers)
 for object,list in pairs(A.markerWatchers)do
  local pending=A.disconnectList(list);A.markerWatchers[object]=#pending>0 and pending or nil
 end
 for _,record in pairs(A.markerCache)do record.endpoints=A.disconnectList(record.endpoints)end
 if A.toolConnection then A.toolConnection=A.disconnectList({A.toolConnection})[1]end
 glow.Enabled=false;glow.Adornee=nil;A.controls.Visible=false;A.expanded=false
 if first then outcome=reason end
 watchers=A.disconnectList(watchers)
 restore();gui:SetAttribute('WrapperAbsent',wrapperAbsent);log(first and 'END' or 'CLEANUP_RECHECK',outcome..'|restore='..restoreState)
 button.Text='';local reported,why=pcall(copy,true)
 if not reported then copyOK=false;A.reportFailure=clean(why);panel.Text='REPORT ERROR';warn('PELICAN report: '..A.reportFailure)end
 finishing=false;gui:SetAttribute('CleanupConfirmed',A.cleanupConfirmed())
 if not A.cleanupConfirmed()then panel.Text='CLEANUP RETRY'end
end
if loaderContext and loaderContext.RegisterCleanup then
 loaderContext.RegisterCleanup(function()finish('LOADER_ROLLBACK');return A.cleanupConfirmed()end)
end
button.Activated:Connect(function()finish('USER_END')end)
event.Event:Connect(function()finish('REPLACED')end)
panel.Activated:Connect(function()if stopped then showEndSummary();return end;A.expanded=not A.expanded;A.controls.Visible=A.expanded end)
A.selectButton.Activated:Connect(function()
 if stopped then return end
 autoRequested=not autoRequested;if autoRequested then everAutoRequested=true end;selectionEpoch=selectionEpoch+1;forcedSample=nil;hudFailures=0
 A.throwLock=nil;A.hudSyncSince=nil;if autoRequested then A.selectFault='NONE'end;A.handoff=nil;A.selectedTargetConfirmed=false;A.recordTarget('USER_SELECTION_TOGGLE','requested='..tostring(autoRequested));log('AUTO_REQUEST',tostring(autoRequested))
 if A.controlActive and A.endControl then A.endControl('USER_SELECTION_TOGGLE')end
end)
throwButton.Activated:Connect(function()
 if stopped then return end;A.autoThrowRequested=not A.autoThrowRequested;A.throwLock=nil;A.hudSyncSince=nil
 if A.autoThrowRequested then A.throwFault=nil end;log('AUTO_THROW_REQUEST',tostring(A.autoThrowRequested))
end)
A.controlButton.Activated:Connect(function()
 if stopped or not A.startControl then return end
 if A.controlActive then A.endControl('USER_CANCELLED')else A.startControl(os.clock())end
end)
A.refreshCapabilities=function()
 uv=type(getupvalues)=='function'and getupvalues or(debug and debug.getupvalues)
 setuv=type(setupvalue)=='function'and setupvalue or(debug and debug.setupvalue)
 conns=type(getconnections)=='function'and getconnections
 constants=debug and debug.getconstants or getconstants
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
 local ok,reason=A.selectorSignature(fn)
 log(ok and 'FINGERPRINT'or'FINGERPRINT_MISSING',reason);return ok
end

local function finite(v)return type(v)=='number' and v==v and math.abs(v)<1e8 end
local function eligibleReceiver(model)
 local a=actor(model)
 if not a or not a.owner or a.model~=model or a.owner.Character~=model or not model:IsDescendantOf(workspace) then return nil,'NOT_CURRENT_HUMAN' end
 if a.owner==me or model==me.Character then return nil,'SELF' end
 if a.hum.Health<=0 then return nil,'DEAD' end
 if not me.Team or me.Neutral then return nil,'LOCAL_TEAM_UNKNOWN' end
 if a.owner.Neutral or a.owner.Team~=me.Team then return nil,'NOT_CURRENT_TEAMMATE' end
 return a
end
local function distanceFor(model,def,mouse,cam,inset)
 local part=model and model:FindFirstChild(def.part)
 if not part or not part:IsA('BasePart') or not cam then return end
 if def.projection=='world' then
  local root=me.Character and me.Character:FindFirstChild('HumanoidRootPart')
  if root then return (part.Position-root.Position).Magnitude end
  return
 end
 local screen,onScreen
 if def.projection=='screen' then screen,onScreen=cam:WorldToScreenPoint(part.Position)
 else screen,onScreen=cam:WorldToViewportPoint(part.Position) end
 if not onScreen or screen.Z<=0 then return end
 local pointer=def.offset and (mouse-inset) or mouse
 return (Vector2.new(screen.X,screen.Y)-pointer).Magnitude
end
local function geometry(model,def)
 local cam=workspace.CurrentCamera;if not cam then return end
 return distanceFor(model,def,Input:GetMouseLocation(),cam,def.offset and GuiService:GetGuiInset()or nil)
end
local function calibrate(values,now)
 if values.n~=2 or typeof(values[1])~='Instance' or not values[1]:IsA('Model') or not finite(values[2]) or values[2]<0 then return end
 local model=values[1];local a=actor(model);if not a then return end
 local cam=workspace.CurrentCamera;if not cam then return end
 local mouse=Input:GetMouseLocation();local inset=GuiService:GetGuiInset()
 local predicted={};local available=false
 for _,def in ipairs(modeDefs) do
  local value=distanceFor(model,def,mouse,cam,inset)
  if finite(value) then predicted[def.id]=value;available=true end
 end
 if not available then return end
 calibration.n=calibration.n+1
 calibration.min=math.min(calibration.min,values[2]);calibration.max=math.max(calibration.max,values[2])
 if not calibration.actors[model] then calibration.actors[model]=true;calibration.actorCount=calibration.actorCount+1 end
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
-- Name-free mapper for the geometry recorded on this live map.
-- Probe the floor without possession/throws; verify all four physical strips.
-- Recorded strips: X +/-82, length360,width4; Z +/-182,length168,width4.
-- Inner edges yield X +/-80, Z +/-180, excluding the X=-105 bench.
local function observedGround(obj)
 if not obj or not obj.Parent or not obj:IsA('BasePart') or not obj.Anchored then return false end
 local s,c=obj.Size,obj.CFrame
 return math.abs(s.X-225)<.6 and math.abs(s.Y-1)<.3 and math.abs(s.Z-420)<.6
  and (obj.Position-V(0,2.5,0)).Magnitude<1.5 and c.UpVector.Y>.999
  and math.abs(c.RightVector.X)>.999 and math.abs(c.LookVector.Z)>.999
end
local function boundaryStrip(obj,ground)
 if not obj or not obj.Parent or obj==ground or not obj:IsA('BasePart') or not obj.Anchored then return end
 local c,s=ground.CFrame,obj.Size;local color=obj.Color
 if obj.CFrame.UpVector.Y<.999 or s.Y>=2 or color.R<=.7 or color.G<=.7 or color.B<=.7 then return end
 local p=c:PointToObjectSpace(obj.Position)
 if math.abs(p.Y-.5)>2 then return end
 local rx=math.abs(obj.CFrame.RightVector:Dot(c.RightVector));local rz=math.abs(obj.CFrame.RightVector:Dot(c.LookVector))
 local lx=math.abs(obj.CFrame.LookVector:Dot(c.RightVector));local lz=math.abs(obj.CFrame.LookVector:Dot(c.LookVector))
 if math.max(rx,rz)<.999 or math.max(lx,lz)<.999 then return end
 local dx=rx*s.X+lx*s.Z;local dz=rz*s.X+lz*s.Z
 if math.abs(math.abs(p.X)-82)<.6 and math.abs(p.Z)<.6 and math.abs(dx-4)<.6 and math.abs(dz-360)<1 then
  return p.X<0 and 'XN' or 'XP',math.abs(p.X)-dx/2
 elseif math.abs(math.abs(p.Z)-182)<.6 and math.abs(p.X)<.6 and math.abs(dx-168)<1 and math.abs(dz-4)<.6 then
  return p.Z<0 and 'ZN' or 'ZP',math.abs(p.Z)-dz/2
 elseif math.abs(math.abs(p.Z)-150)<.6 and math.abs(p.X)<.6 and math.abs(dx-160)<1 and math.abs(dz-.25)<.1 then
  return p.Z<0 and 'GN' or 'GP',math.abs(p.Z)
 end
end
local function inspectField(obj)
 A.addContextCandidate(obj)
 if not mapGround then return end
 local key,edge=boundaryStrip(obj,mapGround)
 if key then mapLines[key]={part=obj,edge=edge} end
end
local function enqueue(obj)
 if stopped or not mapGround or field or mapSeen[obj] then return end
 if #scanQueue<4000 then scanQueue[#scanQueue+1]=obj;mapSeen[obj]=true;scanDone=false else limits.scanCap=true end
end
local function beginMap(ground)
 mapGround=ground;mapLines={};mapSeen={};scanQueue={};scanIndex=1;scanChildren=nil;scanChildIndex=1
 scanDone=false;mapNodes=0;limits.scanCap=false;nextMapRetry=os.clock()+3
 enqueue(ground);if ground.Parent then enqueue(ground.Parent)end
end
local function probeGround()
 local excluded={};for _,p in ipairs(Players:GetPlayers())do if p.Character then excluded[#excluded+1]=p.Character end end
 local rp=RaycastParams.new();rp.IgnoreWater=true
 local modern=pcall(function()rp.ExcludeInstances=excluded end)
 if not modern then rp.FilterType=Enum.RaycastFilterType.Exclude;rp.FilterDescendantsInstances=excluded end
 local hits={};local only=nil;local count=0
 for _,x in ipairs({0,-20,20})do for _,z in ipairs({0,-50,50})do
  local ok,result=pcall(function()return workspace:Raycast(V(x,25,z),V(0,-45,0),rp)end)
  if ok and result and observedGround(result.Instance)then
   if not hits[result.Instance]then count=count+1;only=result.Instance;hits[only]=0 end
   hits[result.Instance]=hits[result.Instance]+1
  end
 end end
 if count==1 and hits[only]>=2 then floorRayHits=hits[only];beginMap(only);log('GROUND_MATCH','rays='..floorRayHits..'|namesIgnored=true')end
end
local function mappedBounds()
 if not observedGround(mapGround) then return end
 local edges={}
 for _,key in ipairs({'XN','XP','ZN','ZP'})do
  local line=mapLines[key];if not line then return end
  local actual,edge=boundaryStrip(line.part,mapGround)
  if actual~=key then return end;edges[key]=edge
 end
 local hx=math.min(edges.XN,edges.XP);local hz=math.min(edges.ZN,edges.ZP)
 if math.abs(edges.XN-edges.XP)>.6 or math.abs(edges.ZN-edges.ZP)>.6
  or math.abs(hx-80)>.6 or math.abs(hz-180)>.6 then return end
 return hx,hz
end
local function scanField()
 local now=os.clock()
 if field then return end
 if mapGround and not observedGround(mapGround)then mapGround=nil;mapLines={}end
 if not mapGround then
  if now<nextGroundProbe then return end;nextGroundProbe=now+1;probeGround();if not mapGround then return end
 elseif scanDone and now>=nextMapRetry then beginMap(mapGround)end
 local work=0;local untilTime=os.clock()+.003
 while work<96 and os.clock()<untilTime do
  if mappedBounds()then scanDone=true;limits.scanCap=false;return end
  if not scanChildren then
   local obj=scanQueue[scanIndex]
   if not obj then scanDone=true;return end
   scanIndex=scanIndex+1;work=work+1;mapNodes=mapNodes+1
   if obj.Parent or obj==workspace then
    inspectField(obj)
    -- Include lines parented under BaseParts. Skip character and UI trees.
    if not obj:IsA('Humanoid') and not obj:IsA('LayerCollector') and not obj:IsA('GuiObject')
     and not (obj:IsA('Model') and obj:FindFirstChildOfClass('Humanoid'))then
     scanChildren=obj:GetChildren();scanChildIndex=1
    end
   end
  else
   local child=scanChildren[scanChildIndex]
   if child then enqueue(child);scanChildIndex=scanChildIndex+1;work=work+1
   else scanChildren=nil end
  end
 end
end
local function insideField(p,side,endInset,which)
 local f=which or field;if not f or not f.part.Parent then return false end
 local l=(f.cf or f.part.CFrame):PointToObjectSpace(p)
 return math.abs(l.Y)<=24 and math.abs(l.X)<=f.halfX-(side or CFG.SideInset)
  and math.abs(l.Z)<=f.halfZ-(endInset or 3)
end
local function fieldAxis()
 if not field then return end
 return field.axis or flat(field.part.CFrame:VectorToWorldSpace(V(0,0,1))).Unit
end
A.watchField=function()
 for _,c in ipairs(A.fieldWatchers)do c:Disconnect()end;A.fieldWatchers={}
 local function changed()
  A.fieldDirty=true;A.overrideReady=false;A.decision=nil;A.markerRevision=A.markerRevision+1
 end
 local objects={mapGround};for _,key in ipairs({'XN','XP','ZN','ZP'})do objects[#objects+1]=mapLines[key].part end
 for _,o in ipairs(objects)do
  for _,name in ipairs({'CFrame','Position','Size','Anchored','Color'})do
   A.fieldWatchers[#A.fieldWatchers+1]=o:GetPropertyChangedSignal(name):Connect(changed)
  end
  A.fieldWatchers[#A.fieldWatchers+1]=o.AncestryChanged:Connect(changed)
 end
end
local function chooseField(q)
 local now=os.clock()
 if field and field.part.Parent and not A.fieldDirty and now<(A.nextFieldAudit or 0)then return end
 A.nextFieldAudit=now+2
 local hx,hz=mappedBounds()
 if hx then
  if not field then
   field={part=mapGround,longX=false,halfX=hx,halfZ=hz};scanDone=true;limits.scanCap=false;A.watchField()
   forward=nil;possessionStart=nil;directionButton.Text='DIR'
   log('FIELD_CHOSEN','boundaryStrips=4|halfXZ='..string.format('%.2f,%.2f',hx,hz)..'|innerEdges=true|namesIgnored=true')
  else field.halfX=hx;field.halfZ=hz end
  field.cf=mapGround.CFrame;field.axis=flat(field.cf:VectorToWorldSpace(V(0,0,1))).Unit
  field.topY=mapGround.Position.Y+mapGround.Size.Y/2;A.fieldDirty=false
 elseif field then
  log('FIELD_LOST','Ground or boundary geometry changed');field=nil;forward=nil;possessionStart=nil
  directionButton.Text='DIR';if observedGround(mapGround)then beginMap(mapGround)else mapGround=nil end
 end
end
-- Read public line geometry, public ValueObjects, and the scoreboard's yards-to-go.
-- Team names alone do not encode end switches. The first-down line is ahead of LOS.
do
local function markerColor(c)
 if c.B>.65 and c.B>c.R+.3 and c.R<.4 and c.G<.85 then return 'BLUE' end
 if c.R>.75 and c.G>.45 and c.B<.4 then return 'YELLOW' end
end
local function markerGeometry(o)
 if not field or not o.Parent or not o:IsDescendantOf(workspace)then return end
 local c=field.cf or field.part.CFrame;local center,color,dx,dz,height;A.markerGeometryCalls=A.markerGeometryCalls+1
 if o:IsA('BasePart')then
  color=o.Color;if not markerColor(color)or not o.Anchored or o.Transparency>.65 then return end
  local cf=o.CFrame;if cf.UpVector.Y<.98 then return end
  local sz=o.Size;center=o.Position;height=sz.Y
  dx=math.abs(cf.RightVector:Dot(c.RightVector))*sz.X+math.abs(cf.LookVector:Dot(c.RightVector))*sz.Z
  dz=math.abs(cf.RightVector:Dot(c.LookVector))*sz.X+math.abs(cf.LookVector:Dot(c.LookVector))*sz.Z
 elseif o:IsA('Beam')then
  if not o.Enabled or not o.Attachment0 or not o.Attachment1 or math.abs(o.CurveSize0)>.1 or math.abs(o.CurveSize1)>.1 then return end
  local a,b=o.Attachment0.WorldPosition,o.Attachment1.WorldPosition;local d=c:VectorToObjectSpace(b-a)
  center=(a+b)*.5;dx=math.abs(d.X);dz=math.abs(d.Z);height=math.abs(d.Y)
  local keys=o.Color.Keypoints;color=keys[1] and keys[1].Value
  if not color then return end
  for _,k in ipairs(keys)do if markerColor(k.Value)~=markerColor(color)then return end end
  for _,k in ipairs(o.Transparency.Keypoints)do if k.Value>.65 then return end end
 else return end
 local p=c:PointToObjectSpace(center);local role=markerColor(color)
 if not role or dx<30 or dx>175 or dz>5 or height>3 or math.abs(p.X)>85
  or math.abs(p.Y-.5)>4 or math.abs(p.Z)>153 then return end
 return role,center,p.Z,p.X-dx/2,p.X+dx/2
end
A.fieldBeamCandidate=function(o,ground)
 if not ground or not ground.Parent or not o.Parent or not o:IsA('Beam')or not o.Enabled
  or not o.Attachment0 or not o.Attachment1 or not o.Attachment0.Parent or not o.Attachment1.Parent
  or math.abs(o.CurveSize0)>.1 or math.abs(o.CurveSize1)>.1 then return false end
 local cf=ground.CFrame;local a=cf:PointToObjectSpace(o.Attachment0.WorldPosition);local b=cf:PointToObjectSpace(o.Attachment1.WorldPosition)
 local top=ground.Size.Y/2
 if math.abs(a.Y-top)>1 or math.abs(b.Y-top)>1 or math.abs(a.Y-b.Y)>.25 or math.abs(a.Z-b.Z)>.25
  or math.abs((a.X+b.X)/2)>5 or math.abs((a.Z+b.Z)/2)>153 then return false end
 local lo,hi=math.min(a.X,b.X),math.max(a.X,b.X)
 if lo> -65 or hi<65 or hi-lo>175 then return false end
 for _,endpoint in ipairs({o.Attachment0,o.Attachment1})do
  local cur=endpoint.Parent
  for _=1,6 do
   if not cur or cur==workspace then break end
   if cur:IsA('BasePart')and not cur.Anchored or cur:IsA('Model')and cur:FindFirstChildOfClass('Humanoid')then return false end
   cur=cur.Parent
  end
 end
 local role=nil
 for _,key in ipairs(o.Color.Keypoints)do
  local current=markerColor(key.Value);if not current or role and current~=role then return false end;role=current
 end
 if not role then return false end
 for _,key in ipairs(o.Transparency.Keypoints)do if key.Value>.65 then return false end end
 return true
end
A.ignoreBeam=function(o)
 if not A.ignoredBeamSeen[o]then A.ignoredBeamSeen[o]=true;A.ignoredBeams=A.ignoredBeams+1 end
end
A.watchMarker=function(o)
 if A.markerCache[o]then return end
 if o:IsA('Beam')and not A.fieldBeamCandidate(o,field and field.part or mapGround)then A.ignoreBeam(o);return end
 local record={dirty=true,visibleClass=o:IsA('BasePart')and o.Transparency<=.65,colorRole=o:IsA('BasePart')and markerColor(o.Color)};A.markerCache[o]=record;A.markerWatchers[o]={};A.markerRevision=A.markerRevision+1
 local function changed(name)
  name=name or 'Endpoint';A.markerEvents[name]=(A.markerEvents[name]or 0)+1
  if o:IsA('BasePart')and name=='Transparency'then
   local visible=o.Transparency<=.65;if visible==record.visibleClass then return end;record.visibleClass=visible
  elseif o:IsA('BasePart')and name=='Color'then
   local role=markerColor(o.Color);if role==record.colorRole then return end;record.colorRole=role
  end
  -- Pause until the current geometry is read, but retain the last observed pair.
  -- updateContext clears settlement only when that pair or scoreboard meaning changes.
  record.dirty=true;A.markerRevision=A.markerRevision+1;A.context.status='MARKER_RESYNC';A.overrideReady=false
 end
 record.endpoints={}
 record.bindEndpoints=function()
  for _,c in ipairs(record.endpoints)do c:Disconnect()end;record.endpoints={}
  for _,a in ipairs({o.Attachment0,o.Attachment1})do
   if a then
    for _,name in ipairs({'Position','CFrame'})do record.endpoints[#record.endpoints+1]=a:GetPropertyChangedSignal(name):Connect(changed)end
    record.endpoints[#record.endpoints+1]=a.AncestryChanged:Connect(function()changed();record.needsEndpointBind=true end)
    local cur=a.Parent
    for _=1,4 do
     if not cur then break end
     if cur:IsA('BasePart')then record.endpoints[#record.endpoints+1]=cur:GetPropertyChangedSignal('CFrame'):Connect(changed);break end
     cur=cur.Parent
    end
   end
  end
 end
 local props=o:IsA('Beam')and{'Enabled','Color','Transparency','Attachment0','Attachment1','CurveSize0','CurveSize1'}
  or{'CFrame','Position','Size','Color','Transparency','Anchored'}
 for _,name in ipairs(props)do
  A.markerWatchers[o][#A.markerWatchers[o]+1]=o:GetPropertyChangedSignal(name):Connect(function()
   changed(name);if name=='Attachment0'or name=='Attachment1'then record.bindEndpoints()end
  end)
 end
 if o:IsA('Beam')then record.bindEndpoints()end
 A.markerWatchers[o][#A.markerWatchers[o]+1]=o.AncestryChanged:Connect(function()changed('Ancestry')end)
end
A.addContextCandidate=function(o)
 local ground=field and field.part or mapGround
 if ground then local key=boundaryStrip(o,ground);if key=='GN'or key=='GP'then A.goalLines[key]=o end end
 if A.markerSeen[o]then return end
 if o:IsA('BasePart')or o:IsA('Beam')then
  local eligible=false
  if o:IsA('Beam')then eligible=A.fieldBeamCandidate(o,ground);if not eligible then A.ignoreBeam(o)end
  else
   local sz=o.Size
   if o.Anchored and math.max(sz.X,sz.Z)>=30 and math.min(sz.X,sz.Z)<=7 then
    eligible=markerColor(o.Color)~=nil
    -- Retain field-shaped strips even when currently white/hidden: a play can
    -- move/recolor the same instances without spawning any new descendants.
    if ground and o.CFrame.UpVector.Y>.98 then
     local c=ground.CFrame;local lp=c:PointToObjectSpace(o.Position)
     local dx=math.abs(o.CFrame.RightVector:Dot(c.RightVector))*sz.X+math.abs(o.CFrame.LookVector:Dot(c.RightVector))*sz.Z
     local dz=math.abs(o.CFrame.RightVector:Dot(c.LookVector))*sz.X+math.abs(o.CFrame.LookVector:Dot(c.LookVector))*sz.Z
     if dx>=30 and dx<=175 and dz<=5 and math.abs(lp.X)<=85 and math.abs(lp.Z)<=185 and math.abs(lp.Y-.5)<=4 then eligible=true end
    end
   end
  end
  if eligible then
   if #A.markerParts>=64 then
    local kept={};for _,old in ipairs(A.markerParts)do if old.Parent then kept[#kept+1]=old else A.markerSeen[old]=nil end end;A.markerParts=kept
    if #kept>=64 then A.markerCap=true;return end
   end
   A.markerSeen[o]=true;A.markerParts[#A.markerParts+1]=o;A.watchMarker(o)
  end
 elseif #A.markerMeta<24 and o:IsA('ValueBase')then
  local n=norm(o.Name)
  if n:find('scrimmage',1,true)or n:find('firstdown',1,true)or n:find('possession',1,true)or n:find('direction',1,true)or n=='yards' or n=='down' then
   A.markerSeen[o]=true;A.markerMeta[#A.markerMeta+1]=clean(o:GetFullName())..'|class='..o.ClassName..'|value='..clean(o.Value)
  end
 end
end
local function scanContext(now)
 if not field then return end
 if A.contextField~=field.part then
  A.contextField=field.part;A.markerScan={q={field.part,field.part.Parent,workspace},seen={},i=1,children=nil,j=1};A.markerNodes=0;A.contextScanDone=false
 end
 local st=A.markerScan;if not st then return end
 if A.context.status=='PAIR_AND_HUD_STABLE'and A.goalLines.GN and A.goalLines.GP then
  A.markerScan=nil;A.contextScanDone=true;return
 end
 local work=0;local deadline=os.clock()+.001
 while work<48 and os.clock()<deadline do
  if st.children then
   local child=st.children[st.j]
   if child then
    if #st.q<5000 then st.q[#st.q+1]=child else A.markerCap=true end
    st.j=st.j+1;work=work+1
   else st.children=nil end
  else
   local o=st.q[st.i];if not o then A.markerScan=nil;A.contextScanDone=true;return end
   st.i=st.i+1;work=work+1
   if not st.seen[o]then
    st.seen[o]=true;A.markerNodes=A.markerNodes+1;A.addContextCandidate(o)
    if (o.Parent or o==workspace)and not o:IsA('LayerCollector')and not o:IsA('GuiObject')and not o:IsA('Humanoid')
     and not(o:IsA('Model')and o:FindFirstChildOfClass('Humanoid'))then st.children=o:GetChildren();st.j=1 end
   end
  end
 end
end
local function downText(o)
 local text=txt(o);local n=text:match('^[1-4]%a%a%s*&%s*(%d+)$');n=n and tonumber(n)
 if text:lower():match('^[1-4]%a%a%s*&%s*goal$')then n='GOAL'end
 if n=='GOAL'or type(n)=='number'and n>=1 and n<=30 then return n,tonumber(text:sub(1,1))end
end
A.addDownCandidate=function(o)
 if A.downSeen[o]or not o or not isText(o)then return end
 -- Unchanged non-scoreboard text needs no repeated ancestry walk or pattern parsing.
 A.downNegative=A.downNegative or setmetatable({},{__mode='k'})
 local text=txt(o);if A.downNegative[o]==text then return end
 if not A.inGuiRoots(o)then return end
 local n=downText(o);if not n then A.downNegative[o]=text;return end
 A.downNegative[o]=nil
 if #A.downLabels>=16 then
  local kept={};for _,x in ipairs(A.downLabels)do if A.inGuiRoots(x)then kept[#kept+1]=x else A.downSeen[x]=nil end end;A.downLabels=kept
 end
 if #A.downLabels<16 then
  A.downSeen[o]=true;A.downLabels[#A.downLabels+1]=o
  local previousYards,previousDown=downText(o)
  watchers[#watchers+1]=o:GetPropertyChangedSignal('Text'):Connect(function()
   local yards,down=downText(o)
   if yards==previousYards and down==previousDown then return end
   previousYards=yards;previousDown=down
   A.downDirty=true;A.context.status='HUD_RESYNC';A.overrideReady=false
  end)
 end
end
local function hudYardsToGo()
 local value,count,down=nil,0,nil;local cam=workspace.CurrentCamera;local top=cam and cam.ViewportSize.Y*.4 or 200
 A.downStatus='MISSING'
 for _,o in ipairs(A.downLabels)do
  if A.inGuiRoots(o)and shown(o)and o.AbsolutePosition.Y<top then
   local n,d=downText(o)
   if n then if value and(value~=n or down~=d)then A.downStatus='CONFLICTING_CURRENT_LABELS';return nil end;value=n;down=d;count=count+1 end
  end
 end
 if value then A.downStatus='CURRENT_ROOT_VISIBLE'end
 if not value and os.clock()>=(A.nextDownSeek or 0)then
  -- Current candidate observers stay immediate. Missing-label discovery is bounded.
  A.nextDownSeek=os.clock()+.25
  for _=1,math.min(64,#labels)do
   if A.downIndex>#labels then A.downIndex=1 end
   local o=labels[A.downIndex];A.downIndex=A.downIndex+1;A.addDownCandidate(o)
  end
 end
 return value,count,down
end
A.updateContext=function(now,q)
 A.downDirty=false
 if not field then A.context.status='NO_FIELD';A.context.streak=0;A.context.los=nil;A.context.first=nil;A.context.source='NONE';forward=nil;return end
 local seekAt=os.clock();scanContext(now);A.measure('MARKER_DISCOVERY',os.clock()-seekAt)
 local rebuild=A.contextGeometryRevision~=A.markerRevision or now>=(A.nextMarkerAudit or 0)
 local blues,yellows=A.cachedBlues or{},A.cachedYellows or{}
 if rebuild then
 local audit=now>=(A.nextMarkerAudit or 0);A.nextMarkerAudit=now+2
 local geometryAt=os.clock();local clusters={BLUE={},YELLOW={}};local collectRows=true
 if collectRows then A.markerRows={};A.nextMarkerRows=now+2 end
 for _,o in ipairs(A.markerParts)do
  local record=A.markerCache[o];if not record then A.watchMarker(o);record=A.markerCache[o]end
  if record.dirty or audit and o:IsA('Beam')or record.field~=field.part or record.cf~=field.cf then
   if record.needsEndpointBind then record.bindEndpoints();record.needsEndpointBind=false end
   local ok,role,point,z,lo,hi=pcall(markerGeometry,o)
   record.role=ok and role or nil;record.point=point;record.z=z;record.lo=lo;record.hi=hi;record.field=field.part;record.cf=field.cf;record.dirty=false
  end
  local role,point,z,lo,hi=record.role,record.point,record.z,record.lo,record.hi
  local ok=true
  if ok and role then
   local list=clusters[role];local group=nil
   for _,v in ipairs(list)do if math.abs(v.z-z)<.3 then group=v;break end end
   if not group then group={p=point,z=z,segments={}};list[#list+1]=group end
   group.segments[#group.segments+1]={lo=lo,hi=hi}
   if collectRows and #A.markerRows<24 then A.markerRows[#A.markerRows+1]=role..'|class='..o.ClassName..'|p='..vec(point)..'|localZ='..string.format('%.2f',z)..'|span='..string.format('%.1f,%.1f',lo,hi)end
  end
 end
 if #A.markerRows>0 then A.lastMarkerRows=A.markerRows end
 blues,yellows={},{}
 for role,groups in pairs(clusters)do
  for _,g in ipairs(groups)do
   table.sort(g.segments,function(a,b)return a.lo<b.lo end)
   local lo,hi=g.segments[1].lo,g.segments[1].hi;local continuous=true
   for i=2,#g.segments do local seg=g.segments[i];if seg.lo>hi+2 then continuous=false end;hi=math.max(hi,seg.hi)end
   if continuous and hi-lo>=130 and hi-lo<=175 and math.abs((hi+lo)/2)<5 then
    local list=role=='BLUE'and blues or yellows;list[#list+1]=g
   end
  end
 end
 A.cachedBlues=blues;A.cachedYellows=yellows;A.contextGeometryRevision=A.markerRevision
 A.measure('MARKER_GEOMETRY',os.clock()-geometryAt)
 end
 local hudAt=os.clock();local yards,_,down=hudYardsToGo();A.context.yards=yards;A.context.down=down;A.measure('DOWN_HUD',os.clock()-hudAt)
 local blue,yellow=blues[1],yellows[1];local goalMode=yards=='GOAL'
 local valid=#blues==1 and #yellows==1 and type(yards)=='number'
 if goalMode and #blues==1 and math.abs(blue.z)>=120 and math.abs(blue.z)<150 then
  local target=blue.z<0 and A.goalLines.GN or A.goalLines.GP
  local gn,gp=A.goalLines.GN,A.goalLines.GP
  if gn and gp and boundaryStrip(gn,field.part)=='GN'and boundaryStrip(gp,field.part)=='GP'then
   local point=target.Position;local localZ=field.part.CFrame:PointToObjectSpace(point).Z
   yellow={p=point,z=localZ};valid=math.abs(localZ-blue.z)>=.5 and math.abs(localZ-blue.z)<=31
  end
 end
 if valid then
  local delta=yellow.z-blue.z
  if not goalMode then valid=math.abs(delta)>=2 and math.abs(delta)<=90 and math.abs(math.abs(delta)/3-yards)<=CFG.MarkerToleranceYards end
  if valid then
   local sign=delta>0 and 1 or -1
   local same=A.context.sign==sign and A.context.los and (A.context.los-blue.p).Magnitude<.05
    and A.context.first and(A.context.first-yellow.p).Magnitude<.05
    and A.context.observedYards==yards and A.context.observedDown==down and A.context.observedTeam==me.Team
   if same then A.contextRevalidations=A.contextRevalidations+1 else A.contextChanges=A.contextChanges+1 end
   A.context.observedYards=yards;A.context.observedDown=down;A.context.observedTeam=me.Team
   A.context.streak=same and A.context.streak+1 or 1;A.context.los=blue.p;A.context.first=yellow.p;A.context.sign=sign;A.context.at=now
   A.context.status=A.context.streak>=3 and 'PAIR_AND_HUD_STABLE' or 'PAIR_SETTLING';A.context.targetRole=goalMode and 'GOAL_LINE' or 'FIRST_DOWN_LINE'
   if A.context.streak>=3 then
    local direction=fieldAxis()*sign
    if A.context.source~='LINES_AND_HUD'or not forward or direction:Dot(forward)<.9 then
     log('ATTACK_AUTO','LOS='..vec(blue.p)..'|first='..vec(yellow.p)..'|yards='..tostring(yards)..'|forward='..vec(direction))
    end
    A.context.source='LINES_AND_HUD';forward=direction;directionButton.Text='DIR\nAUTO'
    local playKey=tostring(me.Team)..'|'..tostring(down)..'|'..string.format('%.1f,%.1f',blue.z,yellow.z)
    if playKey~=A.playKey then A.playKey=playKey;A.releasedPlayKey=nil end
    A.context.playKey=playKey
    if A.context.streak==3 then A.contextProofs=(A.contextProofs or 0)+1;A.lastContext={los=blue.p,first=yellow.p,forward=direction,at=now}end
   end
   return
  end
 end
 A.context.status=#blues~=1 and 'BLUE_MISSING_OR_AMBIGUOUS' or goalMode and 'GOAL_LINE_UNKNOWN' or #yellows~=1 and 'FIRST_MISSING_OR_AMBIGUOUS' or not yards and 'HUD_DISTANCE_UNKNOWN' or 'PAIR_HUD_MISMATCH'
 A.context.streak=0;A.context.los=nil;A.context.first=nil;A.context.sign=nil;A.context.playKey=nil
 if A.context.source=='LINES_AND_HUD'then forward=nil;A.context.source='NONE';directionButton.Text='DIR' end
end
end -- context module
directionButton.Activated:Connect(function()
 if stopped then return end
 local axis=fieldAxis();local cam=workspace.CurrentCamera
 if not axis or not cam then log('ATTACK','Field or camera missing');return end
 local dot=flat(cam.CFrame.LookVector):Dot(axis)
 if math.abs(dot)<.3 then log('ATTACK','Look downfield before tapping');return end
 forward=axis*(dot>=0 and 1 or -1);A.context.source='MANUAL';directionButton.Text='DIR\nSET'
 log('ATTACK','User camera direction='..vec(forward))
end)
-- Session-local route predictability; no persistent blame from a miss.
A.observeRoute=function(s,now,measured)
 s.routeHistory=s.routeHistory or {};local h=s.routeHistory
 h[#h+1]={p=s.p,v=measured,t=now}
 while #h>18 or h[1]and now-h[1].t>1.8 do table.remove(h,1)end
 if #h<6 then return end
 local path,largeTurns=0,0
 for i=2,#h do
  path=path+flat(h[i].p-h[i-1].p).Magnitude
  local a,b=h[i-1].v,h[i].v
  if a.Magnitude>8 and b.Magnitude>8 and a.Unit:Dot(b.Unit)<.55 then largeTurns=largeTurns+1 end
 end
 local displacement=flat(h[#h].p-h[1].p).Magnitude
 s.routeEfficiency=path>1 and displacement/path or 1
 if path>14 and largeTurns>=3 and s.routeEfficiency<.65 then s.routeSkipUntil=now+.9 end
end
-- Player observations: positional motion is primary; engine velocity corroborates stalls.
A.jumpEnvelope=function(s,now)
 if now<(s.nextJumpAudit or 0)then return end;s.nextJumpAudit=now+2
 local hum=s.hum;local height=7.2;local gravity=workspace.Gravity
 if hum.UseJumpPower and finite(hum.JumpPower)and finite(gravity)and gravity>0 then height=hum.JumpPower*hum.JumpPower/(2*gravity)
 elseif finite(hum.JumpHeight)then height=hum.JumpHeight end
 s.catchReach=clamp(height+5,12.2,24)
end
local function samplePlayer(p,now)
 local char=p.Character;local hum=char and char:FindFirstChildOfClass('Humanoid')
 local root=char and char:FindFirstChild('HumanoidRootPart')
 if not root or not hum or hum.Health<=0 then states[p]=nil;return end
 local pos=root.Position;local raw=flat(root.AssemblyLinearVelocity)
 if not finite(pos.X) or not finite(pos.Y) or not finite(pos.Z) then states[p]=nil;return end
 local s=states[p]
 if not s or s.char~=char then
  s={p=pos,v=ZERO,a=ZERO,time=now,changed=now,moving=now,validAfter=now+.75,turn=0,samples=0,motionSamples=0,char=char,root=root,hum=hum,player=p,actor=actor(p)}
  states[p]=s;A.jumpEnvelope(s,now)
  local alias=clean(p.Name)..'|display='..clean(p.DisplayName)..'|humanoid='..clean(hum.DisplayName)..'|role='..(p==me and 'QB'or p.Team==me.Team and 'TEAMMATE'or 'DEFENDER')
  A.playerAliases[p.Name]=alias;log('PLAYER_ALIAS',alias)
  if p~=me and p.Team~=me.Team and matches(s.actor,'Alexander')then
   log('UNTRUSTED_DEFENDER_REFERENCE',alias..'|tracked as threat; interception outcomes are not calibration evidence')
  end
  return s
 end
 local dt=now-s.time;if dt<=0 then return s end
 local delta=flat(pos-s.p)
 if dt>.6 or delta.Magnitude>math.max(14,80*dt) then
  s.v=ZERO;s.a=ZERO;s.turn=1;s.samples=0;s.motionSamples=0;s.validAfter=now+.8;s.changed=now;s.routeHistory={};s.routeSkipUntil=0
 else
  local measured=delta/dt
  if delta.Magnitude>.08 then s.changed=now end
  if measured.Magnitude>2 then s.moving=now;s.motionSamples=(s.motionSamples or 0)+1 end
  if measured.Magnitude<.4 and raw.Magnitude>6 and now-s.changed>.55 then s.validAfter=now+.4 end
  local v=limit(measured,45);local turning=0
  if v.Magnitude>4 and s.v.Magnitude>4 then turning=clamp((1-v.Unit:Dot(s.v.Unit))/2,0,1) end
  local abrupt=clamp((v-s.v).Magnitude/30,0,1)
  s.turn=s.turn*.65+math.max(turning,abrupt)*.35
  s.a=s.a*.7+limit((v-s.v)/dt,35)*.3;s.v=s.v*.3+v*.7;s.samples=s.samples+1
  s.p=pos;if p~=me and p.Team==me.Team and not p.Neutral then A.observeRoute(s,now,v)end
 end
 s.p=pos;s.time=now;s.root=root;s.hum=hum;A.jumpEnvelope(s,now);return s
end
local function predict(s,t)
 local aTime=math.min(t,.25)
 return s.p+s.v*t+s.a*(.5*aTime*aTime)
end
local function fresh(s,now)
 return s and s.samples>=3 and now>=s.validAfter and now-s.time<.35
end
-- Evaluate independent receiver/trajectory pairs. This does not change Yuna's mode.
local function solve(origin,s,mode,delay)
 delay=delay or 0
 local t=clamp(flat(s.p-origin).Magnitude/85,.12,CFG.MaxFlight)
 local height=mode=='JUMP' and 4 or 3
 for _=1,14 do
  local target=predict(s,t+delay)+V(0,height,0);local d=flat(target-origin);local r=d.Magnitude
  if r<8 or r>CFG.MaxRange then return end
  local h=target.Y-origin.Y;local angle,horizontal
  if mode=='JUMP' then
   angle=math.rad(42);local u=r*math.tan(angle)-h
   if u<=0 then return end
   horizontal=r/math.sqrt(2*u/CFG.Gravity)
   local speed=horizontal/math.cos(angle)
   if speed>CFG.Speed or speed<30 then return end
  else
   local speed,g=CFG.Speed,CFG.Gravity
   local disc=speed^4-g*(g*r*r+2*h*speed*speed);if disc<0 then return end
   angle=math.atan((speed*speed-math.sqrt(disc))/(g*r))
   if mode=='BULLET'and(angle>math.rad(36)or angle<math.rad(-15))then return end
   if mode=='FIT' and (angle>math.rad(36) or angle<math.rad(-6)) then return end
   horizontal=speed*math.cos(angle)
  end
  local nextT=r/horizontal;if nextT<.08 or nextT>CFG.MaxFlight then return end
  local launch=d.Unit*horizontal+V(0,horizontal*math.tan(angle),0)
  if math.abs(nextT-t)<.012 then
   local point=origin+launch*nextT-V(0,.5*CFG.Gravity*nextT*nextT,0)
   if (point-(predict(s,nextT+delay)+V(0,height,0))).Magnitude>2.5 then return end
   return {mode=mode,time=nextT,point=point,launch=launch,delay=delay,origin=origin}
  end
  t=t*.25+nextT*.75
 end
end
-- Numeric lower bounds cover every time in the catch/lane interval.
-- After .25s, predict() has a fixed acceleration offset and linear horizontal motion.
-- Before .25s, expand uncertainty by a bound on its quadratic acceleration offset.
do
local sqrt,abs=math.sqrt,math.abs
local function linearMinimum(rx,rz,vx,vz,lo,hi,k)
 local vv=vx*vx+vz*vz;local at=hi
 if vv>k*k+1e-9 then
  local dot=rx*vx+rz*vz;local tc=-dot/vv
  local perp=math.max(0,rx*rx+rz*rz-dot*dot/vv)
  at=clamp(tc+k*sqrt(perp/(vv*(vv-k*k))),lo,hi)
 end
 local x,z=rx+vx*at,rz+vz*at
 return sqrt(x*x+z*z)-k*at
end
A.linearMinimum=linearMinimum
local function laneInterval(origin,launch,d,lo,hi,delay)
 delay=delay or 0
 if hi<lo then return 45 end
 local rx,rz=origin.X-d.p.X-d.v.X*delay,origin.Z-d.p.Z-d.v.Z*delay
 local vx,vz=launch.X-d.v.X,launch.Z-d.v.Z
 local ax,az=d.a.X,d.a.Z;local value=45
 local split=math.max(0,.25-delay)
 if lo<split then
  local last=math.min(hi,split)
  value=linearMinimum(rx,rz,vx,vz,lo,last,1.2)-.5*sqrt(ax*ax+az*az)*(last+delay)*(last+delay)
 end
 if hi>=split then value=math.min(value,linearMinimum(rx-ax*.03125,rz-az*.03125,vx,vz,math.max(lo,split),hi,1.2))end
 return math.min(45,value-(4.5+d.turn*3))
end
A.laneMargin=function(origin,launch,d,t,delay)
 delay=delay or 0
 local g=CFG.Gravity;local vy=launch.Y;local y=origin.Y
 local bottom,top=d.p.Y-2,d.p.Y+(d.catchReach or 12.2)
 local lowDisc=vy*vy-2*g*(bottom-y);if lowDisc<0 then return 45 end
 local root=sqrt(lowDisc);local lo=math.max(0,(vy-root)/g);local hi=math.min(t,(vy+root)/g)
 if hi<lo then return 45 end
 local highDisc=vy*vy-2*g*(top-y)
 if highDisc<=0 then return laneInterval(origin,launch,d,lo,hi,delay)end
 root=sqrt(highDisc);local enter,leave=(vy-root)/g,(vy+root)/g
 local risk=45
 if lo<=math.min(hi,enter)then risk=math.min(risk,laneInterval(origin,launch,d,lo,math.min(hi,enter),delay))end
 if math.max(lo,leave)<=hi then risk=math.min(risk,laneInterval(origin,launch,d,math.max(lo,leave),hi,delay))end
 return risk
end
A.catchSeparation=function(s,d,t,delay)
 delay=delay or 0;local lo,hi=math.max(.05,t+delay-.12),t+delay+.12
 local rx,rz=d.p.X-s.p.X,d.p.Z-s.p.Z
 local vx,vz=d.v.X-s.v.X,d.v.Z-s.v.Z
 local ax,az=d.a.X-s.a.X,d.a.Z-s.a.Z;local value=math.huge
 if lo<.25 then
  local last=math.min(hi,.25)
  value=linearMinimum(rx,rz,vx,vz,lo,last,0)-.5*sqrt(ax*ax+az*az)*last*last
 end
 if hi>=.25 then value=math.min(value,linearMinimum(rx+ax*.03125,rz+az*.03125,vx,vz,math.max(lo,.25),hi,0))end
 return value
end
end
local function scoreShot(origin,s,defenders,shot)
 local t,point=shot.time,shot.point;local delay=shot.delay or 0;local total=t+delay
 if field and not insideField(point,CFG.SideInset,3)then return end
 local uncertainty=1+.75*total+s.turn*math.min(8,2+2*total)
 local future,present,lane,closing,leverage=45,45,45,0,0
 local wx,wz=s.v.X,s.v.Z;local speed=math.sqrt(wx*wx+wz*wz)
 for _,d in ipairs(defenders)do
  local dx,dz=d.p.X-s.p.X,d.p.Z-s.p.Z;local dist=math.sqrt(dx*dx+dz*dz)
  present=math.min(present,dist)
  if dist>1 then closing=math.max(closing,-((d.v.X-wx)*dx+(d.v.Z-wz)*dz)/dist)end
  future=math.min(future,A.catchSeparation(s,d,t,delay)-(1+total+d.turn*4)-uncertainty)
  if speed>4 then
   local along=(dx*wx+dz*wz)/speed;local across=math.sqrt(math.max(0,dist*dist-along*along))
   if along>0 and along<speed*total+8 and across<8 then leverage=math.max(leverage,(8-across)*.4)end
  end
  lane=math.min(lane,A.laneMargin(origin,shot.launch,d,t,delay))
 end
 local value=35+clamp(future,-15,25)*1.8+clamp(lane,-15,15)*1.5
 value=value+clamp(future-present,-15,15)*.6-clamp(closing,0,18)*total*.3-leverage
 value=value-math.max(0,-lane)*5-s.turn*12-t*3
 if os.clock()-s.moving>1 then value=value-8 end
 if field and not insideField(point,CFG.SideInset+6,6)then value=value-10 end
 local safety=value;local reward=0;local gainYards=nil
 if forward then
  local base=A.context.los or possessionStart or origin
  gainYards=flat(point-base):Dot(forward)/3
  reward=clamp(gainYards,-5,40)*.12
  if A.context.status=='PAIR_AND_HUD_STABLE'and A.context.first and flat(point-A.context.first):Dot(forward)>=2 then reward=reward+3 end
  if field then
   local lp=field.part.CFrame:PointToObjectSpace(point)
   if A.context.status=='PAIR_AND_HUD_STABLE'and A.context.sign*lp.Z>=152 then reward=reward+5 end
  end
  if gainYards<-1.5 then reward=reward-4 end
 end
 local axis=fieldAxis()
 if axis and speed>4 then
  local along=math.abs(s.v.Unit:Dot(axis));local ideal=along<.35 and 'BULLET'or(along>.85 and 'FIT'or'JUMP')
  if shot.mode==ideal then value=value+5 end
 end
 shot.safetyScore=safety;shot.reward=reward;shot.gainYards=gainYards
 shot.score=value+reward;shot.future=future;shot.lane=lane;shot.closing=closing
 return shot
end
local function visible(model)
 local root=model and model:FindFirstChild('HumanoidRootPart');local cam=workspace.CurrentCamera
 if not root or not cam then return false end
 local p,on=cam:WorldToScreenPoint(root.Position);return on and p.Z>0
end
local function setGate(reason)
 gate=reason;statusCounts[reason]=(statusCounts[reason] or 0)+1
 if reason~=lastStatusLog then log('GATE',reason);lastStatusLog=reason end
end
local function clearChoice(reason)
 if A.pendingThrow and ownHeld and selection and selection.model==A.pendingThrow.model then
  A.decision=nil;A.overrideReady=false;setGate('COMMITTED_TARGET_'..reason);return
 end
 if A.controlActive and A.endControl then A.endControl(reason)end
 if selection then selectionEpoch=selectionEpoch+1 end
 selection=nil;rankings={};A.decision=nil;A.overrideReady=false;A.handoff=nil;A.selectedTargetConfirmed=false;glow.Enabled=false;glow.Adornee=nil;setGate(reason)
end
A.endControl=function(reason)
 if not A.controlActive then return end
 A.controlActive=false;A.controlResult=reason;A.controlModel=nil;A.controlButton.Text='CTRL'
 A.throwLock=nil;A.hudSyncSince=nil;A.aimSafety=nil
 A.recordTarget('CONTROL_END','reason='..reason..'|duration='..string.format('%.3f',os.clock()-(A.controlAt or os.clock())))
end
A.startControl=function(now)
 if not selection or not selection.safe or not ownHeld or not autoRequested or A.pendingThrow or phase~='RUN' or not numericMode
  or selection.future<CFG.ThrowMargin or selection.lane<CFG.ThrowLane then
  A.controlResult='NO_SAFE_CURRENT_TARGET';A.recordTarget('CONTROL_NOT_STARTED','reason='..A.controlResult);return false
 end
 A.controlActive=true;A.controlAt=now;A.controlUntil=now+6;A.controlModel=selection.model
 A.controlResult='RUNNING_MANUAL_ONLY';A.controlButton.Text='HOLD';A.throwLock=nil;A.hudSyncSince=nil
 A.recordTarget('CONTROL_START','target='..clean(selection.model.Name)..'|duration=6|manualOnly=true');return true
end
A.controlChoice=function(best,retained,now)
 if not A.controlActive then return best end
 if now>=A.controlUntil then A.endControl('WINDOW_ENDED');return best end
 local s=retained and retained.state
 if not ownHeld or not retained or retained.model~=A.controlModel or not retained.safe
  or retained.future<CFG.ThrowMargin or retained.lane<CFG.ThrowLane or not fresh(s,now)
  or s.turn>.35 or now-s.moving>.5 or(s.routeSkipUntil or 0)>now
  or not eligibleReceiver(retained.model)or not visible(retained.model)then
  A.endControl('TARGET_NO_LONGER_SAFE_FRESH_ELIGIBLE');return best
 end
 return retained
end
A.retainHandoff=function(best,retained,now)
 local h=A.handoff
 if not best or not retained or best.model==retained.model or not autoRequested or not h
  or h.epoch~=selectionEpoch or h.model~=retained.model or now-h.at>.45
  or not retained.safe or not best.safe or retained.future<CFG.ThrowMargin or retained.lane<CFG.ThrowLane then return best end
 local st=retained.state
 if not st or not fresh(st,now)or st.turn>.35 or now-st.moving>.5 or(st.routeSkipUntil or 0)>now then return best end
 if retained.future<best.future-1 or retained.lane<best.lane-1 or retained.safetyScore<best.safetyScore-4 then return best end
 A.handoffRetains=A.handoffRetains+1;return retained
end
A.chooseSafestRank=function(entries,retained)
 local safest=nil
 for _,e in ipairs(entries)do
  local margin=math.min(e.future,e.lane)
  local better=not safest or e.safe and not safest.safe
  if safest and e.safe==safest.safe then
   better=e.safetyScore>safest.safetyScore+.5 or math.abs(e.safetyScore-safest.safetyScore)<=.5
    and (margin>math.min(safest.future,safest.lane)+.1 or math.abs(margin-math.min(safest.future,safest.lane))<=.1 and e.future+e.lane>safest.future+safest.lane)
  end
  if better then safest=e end
 end
 if not safest then return end
 local best=safest
 for _,e in ipairs(entries)do
  if e.safe==safest.safe and e.future>=safest.future-.5 and e.lane>=safest.lane-.5 and e.safetyScore>=safest.safetyScore-2 then
   if e.reward>best.reward+.05 or math.abs(e.reward-best.reward)<=.05 and e.safetyScore>best.safetyScore then best=e end
  end
 end
 if retained and retained.safe==best.safe and retained.future>=best.future-.5 and retained.lane>=best.lane-.5
  and retained.safetyScore>=best.safetyScore-1 and retained.reward>=best.reward-.2 then return retained end
 return best
end
A.freezeState=function(s)
 return {p=s.p,v=s.v,a=s.a,turn=s.turn,moving=s.moving,char=s.char,root=s.root,player=s.player,live=s,time=s.time,catchReach=s.catchReach}
end
local function chooseReceiver(now,roster,q)
 local teammates,defenders={},{};A.idleSkipped=0;A.erraticSkipped=0
 for _,p in ipairs(roster) do
  if p~=me then
   local s=states[p]
   if not s and p.Character and (not p.Team or p.Neutral or p.Team~=me.Team) then
    local h=p.Character:FindFirstChildOfClass('Humanoid')
    if h and h.Health>0 then clearChoice('DEFENDER_ROOT_UNAVAILABLE');return end
   end
   if s and (not field or insideField(s.p,-10,-10)) and flat(s.p-q.p).Magnitude<CFG.MaxRange+40 then
    if not p.Team or p.Neutral then
     if not field or insideField(s.p,0,0) then clearChoice('ON_FIELD_TEAM_UNKNOWN');return end
    elseif p.Team~=me.Team then
     if not fresh(s,now) then clearChoice('DEFENDER_RESYNC');return end
     defenders[#defenders+1]=s
    elseif now-s.moving>CFG.IdleSeconds then A.idleSkipped=A.idleSkipped+1
    elseif (s.routeSkipUntil or 0)>now then A.erraticSkipped=A.erraticSkipped+1
    elseif (not A.pendingThrow or A.pendingThrow.model==s.char)and fresh(s,now) and (s.motionSamples or 0)>=2 and now-s.moving<=CFG.IdleSeconds and (not field or insideField(s.p,CFG.SideInset,3))
      and flat(s.p-q.p).Magnitude<=CFG.MaxRange and visible(s.char) then
     teammates[#teammates+1]=s
    end
   end
  end
 end
 if #defenders==0 then clearChoice('NO_DEFENDER_DATA');return end
 if #teammates==0 then clearChoice('NO_MOVING_VISIBLE_RECEIVER');return end
 local job=A.decision
 if job and now-job.at<=CFG.DecisionMaxAge and job.possession==A.possessionID and job.playKey==A.playKey and job.epoch==selectionEpoch then return end
 local frozenWR,frozenDB={},{}
 for _,s in ipairs(teammates)do frozenWR[#frozenWR+1]=A.freezeState(s)end
 for _,s in ipairs(defenders)do frozenDB[#frozenDB+1]=A.freezeState(s)end
 A.decision={at=now,teammates=frozenWR,defenders=frozenDB,index=1,mode=1,entries={},
  origin=(ownBall and ownBall.Parent and ownBall.Position)or(q.p+V(0,3,0)),
  possession=A.possessionID,playKey=A.playKey,epoch=selectionEpoch,field=field and field.part,q=A.freezeState(q),
  delays={math.max(0,CFG.ReleaseDelayLow-(A.pendingThrow and now-A.pendingThrow.at or 0)),math.max(0,CFG.ReleaseDelayHigh-(A.pendingThrow and now-A.pendingThrow.at or 0))}}
end
A.publishDecision=function(job,now)
 if A.decision~=job or now-job.at>CFG.DecisionMaxAge or job.possession~=A.possessionID or job.playKey~=A.playKey
  or job.epoch~=selectionEpoch or not ownHeld or not ownBall or not ownBall.Parent
  or not field or field.part~=job.field or(ownBall.Position-job.origin).Magnitude>3 or A.fieldDirty then
  A.decision=nil;clearChoice('DECISION_RESYNC');return
 end
 -- Reject snapshots when a route changed while this short scoring batch ran.
 for _,list in ipairs({job.teammates,job.defenders})do for _,s in ipairs(list)do
  if not fresh(s.live,now)or s.live.char~=s.char or flat(s.live.p-predict(s,now-job.at)).Magnitude>2.5
   or(s.live.routeSkipUntil or 0)>now or math.abs(s.live.turn-s.turn)>.2 then
   A.decision=nil;clearChoice('ROUTE_CHANGED_DURING_SCORE');return
  end
 end end
 rankings=job.entries;local retained=nil
 for _,e in ipairs(rankings)do if selection and selection.model==e.model then retained=e end end
 local best=A.controlChoice(A.retainHandoff(A.chooseSafestRank(rankings,retained),retained,now),retained,now)
 if not best then clearChoice('NO_FEASIBLE_RECEIVER');return end
 if not selection or selection.model~=best.model then
  selectionEpoch=selectionEpoch+1;hudFailures=0;forcedSample=nil;A.handoff=nil;A.selectedTargetConfirmed=false;A.overrideReady=false
  log('CHOICE',clean(best.player.Name)..'|bestModeEstimate='..best.best.mode..'|conservativeScore='..string.format('%.1f',best.score))
 end
 selection=best;selectionAt=job.at;glow.Adornee=best.model;glow.Enabled=true;A.decision=nil
 local reason=(limits.scanCap or fieldCap>0)and'FIELD_SCAN_LIMIT_ADVISE_ONLY'or not best.safe and'RISKY_ADVISE_ONLY'or'READY'
 setGate(reason)
 local key=best.model.Name..'|'..math.floor(now/3)
 if key~=lastRankingKey then
  lastRankingKey=key;table.sort(rankings,function(a,b)return a.score>b.score end)
  for i=1,math.min(3,#rankings)do
   local e=rankings[i];local row={}
   for _,sh in ipairs(e.shots)do row[#row+1]=sh.mode..'@delay'..string.format('%.2f',sh.delay or 0)..'='..string.format('%.1f',sh.score)..',t='..string.format('%.2f',sh.time)..',coverage='..string.format('%.1f',sh.future)..',lane='..string.format('%.1f',sh.lane)..',safety='..string.format('%.1f',sh.safetyScore)..',yards='..(sh.gainYards and string.format('%.1f',sh.gainYards)or'UNKNOWN')end
   log('RANK',clean(e.player.Name)..'|'..table.concat(row,';'))
  end
 end
 A.measure('SCORE_BATCH_LATENCY',now-job.at)
end
A.stepDecision=function(now)
 local job=A.decision;if not job then return end
 if now-job.at>CFG.DecisionMaxAge or not ownHeld or job.possession~=A.possessionID or job.playKey~=A.playKey
  or job.epoch~=selectionEpoch then A.decision=nil;clearChoice('DECISION_RESYNC');return end
 local begun=os.clock();local count=0;local modes={'BULLET','FIT','JUMP'}
 while count<CFG.ModesPerSlice and(count==0 or os.clock()-begun<CFG.DecisionBudget)do
  local s=job.teammates[job.index]
  if not s then A.publishDecision(job,now);break end
  local e=job.entry
  if not e then
   e={player=s.player,model=s.char,state=s.live,shots={},modeSafety={},safe=false};job.entry=e
  end
  local mode=modes[(job.mode-1)%3+1];local delay=job.delays[math.floor((job.mode-1)/3)+1]
  local origin=predict(job.q,delay)+(job.origin-job.q.p)
  local shot=solve(origin,s,mode,delay)
  if shot then shot=scoreShot(origin,s,job.defenders,shot)end
  if shot then
   e.shots[#e.shots+1]=shot
   local pair=e.modeSafety[mode]
   if not pair then pair={mode=mode,n=0,score=math.huge,safetyScore=math.huge,reward=math.huge,future=math.huge,lane=math.huge,shot=shot};e.modeSafety[mode]=pair end
   pair.n=pair.n+1;pair.score=math.min(pair.score,shot.score);pair.safetyScore=math.min(pair.safetyScore,shot.safetyScore)
   pair.reward=math.min(pair.reward,shot.reward);pair.future=math.min(pair.future,shot.future);pair.lane=math.min(pair.lane,shot.lane)
  end
  job.mode=job.mode+1;count=count+1
  if job.mode>6 then
   local combinations={}
   for _,pair in pairs(e.modeSafety)do
    if pair.n==2 then
     pair.safe=pair.future>=CFG.MinimumMargin and pair.lane>=CFG.MinimumLane and s.turn<.55
     combinations[#combinations+1]=pair
    end
   end
   local preferred=A.chooseSafestRank(combinations,nil)
   local routePreferred=A.routeMode and e.modeSafety[A.routeMode(s)]
   if preferred and routePreferred and routePreferred.n==2 and routePreferred.safe==preferred.safe
    and routePreferred.future>=preferred.future-.5 and routePreferred.lane>=preferred.lane-.5
    and routePreferred.safetyScore>=preferred.safetyScore-2 then preferred=routePreferred end
   if preferred then
    e.best=preferred.shot;e.score=preferred.score;e.safetyScore=preferred.safetyScore;e.reward=preferred.reward;e.future=preferred.future;e.lane=preferred.lane;e.safe=preferred.safe
    local blocked=A.modeBlocks[e.model];if blocked and now<blocked.untilAt then e.safe=false end
    job.entries[#job.entries+1]=e
   end
   job.index=job.index+1;job.mode=1;job.entry=nil
  end
 end
 if A.decision==job and job.index>#job.teammates then A.publishDecision(job,now)end
 A.measure('SCORE_SLICE',os.clock()-begun)
end
-- Ball ownership is checked independently of its movement.
local function footballPart(part)
 if not part:IsA('BasePart') then return false end
 if part.Name=='Football' then return true end
 local parent=part.Parent
 for _=1,3 do
  if not parent or parent==me.Character then break end
  if parent.Name=='Football' then return true end;parent=parent.Parent
 end
 return false
end
local function addBall(part)
 if stopped or ballSet[part] or not footballPart(part) then return end
 if #ballParts>=64 then
  local kept={};ballSet={}
  for _,old in ipairs(ballParts) do if old.Parent then kept[#kept+1]=old;ballSet[old]=true else ballBorn[old]=nil end end
  ballParts=kept
 end
 if #ballParts>=64 then limits.ballCap=true;return end
 ballParts[#ballParts+1]=part;ballSet[part]=true;ballBorn[part]=os.clock()
end
local function carrier(part)
 local a=actor(part);if a then return a end
 local ok,list=pcall(function()return part:GetConnectedParts(false)end)
 if ok and type(list)=='table' then
  for i=1,math.min(#list,16) do local owner=actor(list[i]);if owner then return owner end end
 end
end
local function rootPos(model)
 local r=model and model:FindFirstChild('HumanoidRootPart');return r and vec(r.Position) or 'NONE'
end
-- Fit ordinary outgoing flights once, outside selection/scoring callbacks.
-- Position timestamps identify physical paths even when the aimed target is unknown.
-- Read the released assembly's actual force/mass once per flight.
-- Other active movers make the simple F/m gravity estimate unverified.
A.inspectBallPhysics=function(f)
 local part=f.part;local mass=part.AssemblyMass;local worldG=workspace.Gravity
 local bodies,unsupported=0,0;local fx,fy,fz=0,0,0
 local parts={part};local seen={[part]=true}
 local connectedOK,connected=pcall(function()return part:GetConnectedParts(false)end)
 if connectedOK then
  if #connected>12 then unsupported=unsupported+1 end
  for i=1,math.min(#connected,12)do local v=connected[i];if not seen[v]then seen[v]=true;parts[#parts+1]=v end end
 end
 for _,body in ipairs(parts)do
  local children=body:GetChildren()
  for i=1,math.min(#children,24)do
   local o=children[i]
   if o:IsA('BodyForce')then local force=o.Force;fx=fx+force.X;fy=fy+force.Y;fz=fz+force.Z;bodies=bodies+1
   elseif o:IsA('BodyMover')or o:IsA('BodyVelocity')or o:IsA('BodyPosition')or o:IsA('LinearVelocity')or o:IsA('AlignPosition')or o:IsA('LineForce')then unsupported=unsupported+1
   elseif o:IsA('VectorForce')and o.Enabled then unsupported=unsupported+1 end
  end
  if #children>24 then unsupported=unsupported+1 end
 end
 local g=nil
 if finite(mass)and mass>0 and finite(worldG)and unsupported==0 and bodies>0 then
  local ax,az=fx/mass,fz/mass
  if math.sqrt(ax*ax+az*az)<.25 then local candidate=worldG-fy/mass;if finite(candidate)and candidate>=5 and candidate<=100 then g=candidate end end
 end
 f.physics={gravity=g,mass=mass,worldG=worldG,bodyForces=bodies,unsupported=unsupported}
 local velocity=part.AssemblyLinearVelocity
 local line='BALL_PHYSICS|'..f.id..'|mass='..tostring(mass)..'|worldG='..tostring(worldG)..'|force='..vec(V(fx,fy,fz))
  ..'|bodyForces='..bodies..'|unsupported='..unsupported..'|effectiveG='..tostring(g or'UNVERIFIED')..'|firstVelocity='..vec(velocity)
 if #A.physicsRows>=16 then table.remove(A.physicsRows,1)end;A.physicsRows[#A.physicsRows+1]=line
end
-- The distance-domain arc is insensitive to irregular client sample intervals.
A.finishArc=function(f)
 local rows=f.path or{};local n=#rows;if n<6 then return end
 local first,last=rows[1],rows[n];local dx,dz=last.x-first.x,last.z-first.z;local length=math.sqrt(dx*dx+dz*dz)
 if length<20 then return end
 local ux,uz=dx/length,dz/length;local s1,s2,s3,s4=0,0,0,0;local sy,sdy,sd2y=0,0,0
 local horizontal={};local crossError=0;local previous=-math.huge
 for _,r in ipairs(rows)do
  local x,z=r.x-first.x,r.z-first.z;local d=x*ux+z*uz
  if d<=previous+.01 then return end;previous=d
  local cross=x*uz-z*ux;crossError=crossError+cross*cross
  local q=d*d;local y=r.y-first.y;s1=s1+d;s2=s2+q;s3=s3+q*d;s4=s4+q*q;sy=sy+y;sdy=sdy+d*y;sd2y=sd2y+q*y
  if r.vx and r.vz then
   local h=math.sqrt(r.vx*r.vx+r.vz*r.vz)
   if h>20 and(r.vx*ux+r.vz*uz)/h>.99 then horizontal[#horizontal+1]=h end
  end
 end
 local matrix={{n,s1,s2,sy},{s1,s2,s3,sdy},{s2,s3,s4,sd2y}}
 for col=1,3 do
  local pivot=col;for row=col+1,3 do if math.abs(matrix[row][col])>math.abs(matrix[pivot][col])then pivot=row end end
  matrix[col],matrix[pivot]=matrix[pivot],matrix[col];local scale=matrix[col][col];if math.abs(scale)<1e-8 then return end
  for j=col,4 do matrix[col][j]=matrix[col][j]/scale end
  for row=1,3 do if row~=col then local a=matrix[row][col];for j=col,4 do matrix[row][j]=matrix[row][j]-a*matrix[col][j]end end end
 end
 local intercept,slope,curve=matrix[1][4],matrix[2][4],matrix[3][4];local errorY=0
 for _,r in ipairs(rows)do local d=(r.x-first.x)*ux+(r.z-first.z)*uz;local e=(r.y-first.y)-(intercept+slope*d+curve*d*d);errorY=errorY+e*e end
 local rmsY,rmsCross=math.sqrt(errorY/n),math.sqrt(crossError/n)
 if curve>=0 or rmsY>.25 or rmsCross>.5 then return end
 table.sort(horizontal);local speed=#horizontal>=math.ceil(n*.8)and horizontal[math.ceil(#horizontal/2)]or nil
 if speed and horizontal[#horizontal]-horizontal[1]>math.max(2,speed*.035)then speed=nil end
 local g=speed and-2*curve*speed*speed or nil
 local bodyG=f.physics and f.physics.gravity;local matched=g and bodyG and math.abs(g-bodyG)<=math.max(1.2,bodyG*.05)
 local quality=matched and'FORCE_MASS_VELOCITY_ARC_MATCH'or'ARC_SHAPE_ONLY'
 local line='ARC_PROFILE|'..f.id..'|n='..n..'|distance='..string.format('%.2f',length)..'|slope='..string.format('%.6f',slope)
  ..'|curvature='..string.format('%.8f',curve)..'|rmsY='..string.format('%.4f',rmsY)..'|rmsCross='..string.format('%.4f',rmsCross)
  ..'|nativeHorizontal='..tostring(speed or'UNVERIFIED')..'|gravityFromArc='..tostring(g or'UNVERIFIED')..'|quality='..quality
 if #A.arcProfiles>=16 then table.remove(A.arcProfiles,1)end;A.arcProfiles[#A.arcProfiles+1]=line
 if matched then
  A.gravityProofs[#A.gravityProofs+1]=bodyG;if #A.gravityProofs>8 then table.remove(A.gravityProofs,1)end
  if #A.gravityProofs>=2 then
   local list={};for _,v in ipairs(A.gravityProofs)do list[#list+1]=v end;table.sort(list)
   if list[#list]-list[1]<=1.5 then
    local learned=list[math.ceil(#list/2)]
    if A.gravitySource~='FORCE_MASS_ARC_VERIFIED'or math.abs(CFG.Gravity-learned)>.05 then
     CFG.Gravity=learned;A.gravitySource='FORCE_MASS_ARC_VERIFIED';A.decision=nil;A.overrideReady=false
     log('MODEL_GRAVITY','g='..string.format('%.3f',learned)..'|independentFlights='..#list)
    end
   end
  end
 end
end
A.samplePath=function(f,now)
 if not f.path then f.path={}end
 if #f.path>=32 then return end
 if f.pathClosed then return end
 local p=f.part.Position;local rows=f.path;local last=rows[#rows]
 if #rows>=6 and field and p.Y<=(field.topY or 3)+1 then f.pathClosed=true;A.finishPath(f,'FLOOR_CONTACT');return end
 if last and now-last.t<.07 then return end
 local velocity=f.part.AssemblyLinearVelocity
 rows[#rows+1]={t=now,x=p.X,y=p.Y,z=p.Z,vx=velocity.X,vy=velocity.Y,vz=velocity.Z}
end
A.finishPath=function(f,reason)
 if f.pathFinished then return end;f.pathFinished=true;A.finishArc(f)
 local rows=f.path or {};local n=#rows
 local function reject(why)
  A.pathRejected=A.pathRejected+1;log('PATH_REJECT',f.id..'|'..why..'|samples='..n)
 end
 if n<6 or rows[n].t-rows[1].t<.6 then reject('TOO_SHORT');return end
 local base=rows[1];local span=rows[n].t-base.t
 local s1,s2,s3,s4=0,0,0,0;local sx,sz,stx,stz=0,0,0,0;local sy,sty,st2y=0,0,0
 local stalled=0
 for i,r in ipairs(rows)do
  local t=r.t-base.t;local t2=t*t
  if i>1 then
   local prev=rows[i-1];local dt=r.t-prev.t
   if dt>.4 then reject('SAMPLE_GAP');return end
   local dx,dy,dz=r.x-prev.x,r.y-prev.y,r.z-prev.z
   if dx*dx+dy*dy+dz*dz<.0025 then stalled=stalled+1 end
  end
  s1=s1+t;s2=s2+t2;s3=s3+t2*t;s4=s4+t2*t2
  sx=sx+r.x-base.x;sz=sz+r.z-base.z;stx=stx+t*(r.x-base.x);stz=stz+t*(r.z-base.z)
  local y=r.y-base.y;sy=sy+y;sty=sty+t*y;st2y=st2y+t2*y
 end
 if stalled>0 then reject('STALLED_REPLICATION');return end
 local den=n*s2-s1*s1;if den<=1e-8 then reject('DEGENERATE');return end
 local vx,vz=(n*stx-s1*sx)/den,(n*stz-s1*sz)/den
 local x0,z0=(sx-vx*s1)/n,(sz-vz*s1)/n
 local matrix={{n,s1,s2,sy},{s1,s2,s3,sty},{s2,s3,s4,st2y}}
 for col=1,3 do
  local pivot=col
  for row=col+1,3 do if math.abs(matrix[row][col])>math.abs(matrix[pivot][col])then pivot=row end end
  matrix[col],matrix[pivot]=matrix[pivot],matrix[col]
  local scale=matrix[col][col];if math.abs(scale)<1e-8 then reject('DEGENERATE');return end
  for j=col,4 do matrix[col][j]=matrix[col][j]/scale end
  for row=1,3 do if row~=col then
   local amount=matrix[row][col];for j=col,4 do matrix[row][j]=matrix[row][j]-amount*matrix[col][j]end
  end end
 end
 local y0,vy,curve=matrix[1][4],matrix[2][4],matrix[3][4];local gravity=-2*curve
 local errXZ,errY=0,0
 for _,r in ipairs(rows)do
  local t=r.t-base.t;local dx=(r.x-base.x)-(x0+vx*t);local dz=(r.z-base.z)-(z0+vz*t)
  local dy=(r.y-base.y)-(y0+vy*t+curve*t*t);errXZ=errXZ+dx*dx+dz*dz;errY=errY+dy*dy
 end
 local rmsXZ,rmsY=math.sqrt(errXZ/n),math.sqrt(errY/n);local horizontal=math.sqrt(vx*vx+vz*vz)
 local speed=math.sqrt(horizontal*horizontal+vy*vy)
 if not finite(gravity)or gravity<5 or gravity>100 or horizontal<20 or horizontal>160 or rmsXZ>1.5 or rmsY>1.5 then
  reject('NON_BALLISTIC_OR_UNSYNCED');return
 end
 local angle=math.deg(math.atan(vy/horizontal))
 -- The first sample can be later than release: this is sample-start velocity/angle.
 local line='PATH_PROFILE|'..f.id..'|n='..n..'|span='..string.format('%.3f',span)..'|g='..string.format('%.2f',gravity)
  ..'|horizontal='..string.format('%.2f',horizontal)..'|sampleStartSpeed='..string.format('%.2f',speed)
  ..'|sampleStartAngle='..string.format('%.2f',angle)..'|rmsXZ='..string.format('%.3f',rmsXZ)..'|rmsY='..string.format('%.3f',rmsY)
  ..'|suggestedMode='..clean(f.suggestedMode)..'|actualHudMode='..clean(f.actualMode)..'|aimSource='..clean(f.aimSource)..'|hudAngle='..tostring(f.hudAngle or'UNKNOWN')..'|hudTime='..tostring(f.hudTime or'UNKNOWN')..'|end='..reason
 if #A.pathProfiles>=16 then table.remove(A.pathProfiles,1)end
 A.pathProfiles[#A.pathProfiles+1]=line;log('PATH_LEARNED',f.id..'|g='..string.format('%.2f',gravity)..'|rms='..string.format('%.3f,%.3f',rmsXZ,rmsY))
end
local function startFlight(part,now,origin)
 releaseCount=releaseCount+1;lastReleasedPart=part;lastReleasedAt=now
 local snap=heldSnapshot or {};local recent=snap.forcedAt and now-snap.forcedAt<.35 and snap.epoch==selectionEpoch and snap.hudAgreed
 local chosen=recent and snap.model or nil
 local act=A.activation and now-(A.activation.confirmedAt or A.activation.at)<1.1 and A.activation.possession==A.possessionID and A.activation or nil
 A.releasedPlayKey=act and act.playKey or snap.playKey or A.playKey
 if act and act.target then chosen=act.target end
 local aim=act and act.aim;local aimSource=aim and 'ACTIVATION_HUD'or 'UNKNOWN'
 local heldAim=A.heldAimReceipt
 if heldAim and heldAim.possession==A.possessionID and heldAim.model==chosen and now-heldAim.at<=.65 and heldAim.char==sessionChar and heldAim.team==sessionTeam then
  aim=heldAim.aim;aimSource='LAST_VISIBLE_PRE_RELEASE_HUD'
 end
 flight={id=releaseCount,part=part,at=now,selected=chosen,normal=snap.normal,origin=origin,rows=0,releaseActivation=act,suggestedMode=snap.mode,
  actualMode=aim and aim.mode,hudAngle=aim and aim.angle,hudTime=aim and aim.time,aimSource=aimSource}
 A.inspectBallPhysics(flight)
 if act and act.firstAt then
  local lo=lastHeldAt and math.max(0,lastHeldAt-act.firstAt)or 0;local hi=math.max(lo,now-act.firstAt)
  local pending=A.pendingThrow
  local reqLo=pending and math.max(0,(lastHeldAt or now)-pending.at)or nil;local reqHi=pending and now-pending.at or nil
  local line='RELEASE_TIMING|'..releaseCount..'|firstActivationDelay='..string.format('%.3f,%.3f',lo,hi)
   ..'|requestDelay='..(reqLo and string.format('%.3f,%.3f',reqLo,reqHi)or'UNKNOWN')
  if #A.releaseDelays>=16 then table.remove(A.releaseDelays,1)end;A.releaseDelays[#A.releaseDelays+1]=line
 end
 if A.pendingThrow and A.pendingThrow.possession==A.possessionID then
  A.automaticReleases=A.automaticReleases+1
  A.recordAuto('PHYSICAL_RELEASE','target='..clean(chosen and chosen.Name)..'|delay='..string.format('%.3f',now-A.pendingThrow.at)..'|actualHudMode='..clean(flight.actualMode))
  A.pendingThrow=nil;A.throwStatus='RELEASED'
 end
 log('RELEASE','pass='..releaseCount..'|origin='..origin..'|target='..clean(chosen and chosen.Name)..'|forcedRecently='..tostring(recent or false)..'|targetEvidence='..(act and act.target and 'TOOL_ACTIVATION_HUD' or recent and 'RECENT_SELECTOR_HUD' or 'UNKNOWN')..'|suggestedMode='..clean(snap.mode)..'|actualHudMode='..clean(flight.actualMode)..'|aimSource='..aimSource..'|normal='..clean(snap.normal and snap.normal.Name))
 -- Receiver/defender observations at the release supplement the trajectory.
 for p,s in pairs(states) do
  if not field or insideField(s.p,0,0) then
   log('P',releaseCount..'|'..clean(p.Name)..'|team='..clean(p.Team and p.Team.Name)..'|p='..vec(s.p)..'|v='..vec(s.v)..'|turn='..string.format('%.2f',s.turn))
  end
 end
end
local function observeBall(now,q)
 local wasHeld=ownHeld;ownHeld=false;ownBall=nil
 if q and heldBall and heldBall.Parent and heldBall:IsDescendantOf(me.Character)and(heldBall.Position-q.p).Magnitude<18 then
  ownHeld=true;ownBall=heldBall
 end
 if q and not ownHeld then
  for _,part in ipairs(ballParts) do
   if part.Parent and (part.Position-q.p).Magnitude<18 then
    local owner=carrier(part)
    if owner and owner.model==me.Character then ownHeld=true;ownBall=part;break end
   end
  end
 end
 if ownHeld then
  if not wasHeld then
   possessionStart=q and q.p or nil;A.possessionID=A.possessionID+1;A.possessionAt=now;A.throwLock=nil;A.hudSyncSince=nil;A.activation=nil;A.heldAimReceipt=nil
   log('POSSESSION','OWN|start='..vec(possessionStart))
   if flight and flight.part==ownBall then A.finishPath(flight,'REGAINED');flight=nil end
  end
  heldBall=ownBall;lastHeldAt=now;lastHeldPosition=ownBall.Position
  local forced=forcedSample and forcedSample.epoch==selectionEpoch and forcedSample or nil
  heldSnapshot={model=forced and forced.model or selection and selection.model,
   normal=latest and latest.normal,forcedAt=forced and forced.at,mode=selection and selection.best.mode,epoch=selectionEpoch,
   hudAgreed=forced and hud and shown(hud)and matches(actor(forced.model),txt(hud))or false,playKey=A.context.playKey}
 elseif wasHeld then log('POSSESSION','RELEASE_OR_LOSS') end
 if not ownHeld and heldBall and lastHeldAt and now-lastHeldAt<=.75 and now-lastReleasedAt>1 then
  local oldOwner=heldBall.Parent and carrier(heldBall)
  if not oldOwner then
   if heldBall.Parent and heldBall.AssemblyLinearVelocity.Magnitude>35 then startFlight(heldBall,now,'SAME_PART')
   elseif lastHeldPosition then
    local picked=nil;local nearest=30
    for _,part in ipairs(ballParts) do
     if part.Parent and part~=heldBall and (ballBorn[part] or 0)>=lastHeldAt-.15 and part.AssemblyLinearVelocity.Magnitude>35 then
      local distance=(part.Position-lastHeldPosition).Magnitude
      if distance<nearest and not carrier(part) then picked=part;nearest=distance end
     end
    end
    if picked then startFlight(picked,now,'CLONE_CANDIDATE') end
   end
  end
 end
 if flight then
  if now-flight.at>6 or not flight.part.Parent then A.finishPath(flight,'ENDED');flight=nil;return end
  local owner=carrier(flight.part)
  if owner then log('CARRIER',flight.id..'|'..clean(owner.name)..'|selected='..(flight.selected and tostring(owner.model==flight.selected)or 'UNKNOWN'));A.finishPath(flight,'CARRIED');flight=nil;return end
  A.samplePath(flight,now)
  local act=flight.releaseActivation
  if act and not flight.proofChecked then
   local point=flight.part.Position
   if not flight.proofStart then flight.proofStart=point
   else
    local travel=flat(point-flight.proofStart)
    if travel.Magnitude>=8 then
     flight.proofChecked=true;local aligned=false
     for _,catchPoint in ipairs(act.points)do
      local toward=flat(catchPoint-flight.proofStart)
      if toward.Magnitude>8 and travel.Unit:Dot(toward.Unit)>math.cos(math.rad(12))then aligned=true end
     end
     if act.automatic then
      if not aligned or not act.target or act.target~=flight.selected then
       A.autoThrowRequested=false;A.throwStatus='AUTO_HEADING_UNVERIFIED';A.throwFault=A.throwStatus;log('AUTO_THROW_DISABLED',A.throwStatus)
      else log('AUTO_HEADING_MATCH','target='..clean(act.target.Name))end
      A.recordAuto(aligned and 'HEADING_ALIGNED'or'HEADING_UNVERIFIED','target='..clean(act.target and act.target.Name)..'|pass='..flight.id)
     elseif aligned and act.target and act.target==flight.selected then
      A.toolProofs[act.signature]=(A.toolProofs[act.signature]or 0)+1
      log('TOOL_PROOF','manualActivateToRelease='..A.toolProofs[act.signature]..'|target='..clean(act.target.Name))
     else log('TOOL_PROOF_REJECT','Release did not align with the verified selected receiver')end
    end
   end
  end
  if flight.rows<60 then
   if #ballRows>=240 then table.remove(ballRows,1);omittedBall=omittedBall+1 end
   ballRows[#ballRows+1]='B|'..flight.id..'|'..string.format('%.3f',now-started)..'|'..vec(flight.part.Position)..'|'..rootPos(flight.selected)..'|'..rootPos(flight.normal)
   flight.rows=flight.rows+1
  end
 end
end
-- Keep work outside Yuna's hot selector. The wrapper only consumes a fresh decision.
local function canOverride(now)
 if installedAt and(not A.linkTargetReady or not A.linkTargetAt or now-A.linkTargetAt>.15 or hudState()~='LIVE')then return false end
 if not autoRequested or phase~='RUN'or not numericMode or (gate~='READY'and not A.pendingThrow)or not selection or not field or A.fieldDirty then return false end
 if(now-selectionAt>.35 and not A.pendingThrow)or not ownHeld or not ownBall or not ownBall.Parent or me.Character~=sessionChar or me.Team~=sessionTeam then return false end
 local q=states[me];local s=selection.state;local p=selection.player
 if not fresh(q,now)or not q.root.Parent or(ownBall.Position-q.root.Position).Magnitude>18 then return false end
 if not p or p==me or p.Character~=selection.model or p.Team~=me.Team or p.Neutral or not me.Team or me.Neutral
  or(not selection.safe and not A.pendingThrow)or not fresh(s,now)or not s.hum or s.hum.Health<=0 or not s.root.Parent then return false end
 if(s.routeSkipUntil or 0)>now or not insideField(s.root.Position,CFG.SideInset,3)or now-s.moving>CFG.IdleSeconds then return false end
 return true
end
A.refreshOverride=function(now)
 A.overrideReady=canOverride(now);A.overrideAt=now;A.overrideEpoch=selectionEpoch
 A.overrideModel=selection and selection.model;A.overrideRoot=selection and selection.state.root
end
A.watchCharacter=function(char)
 if A.charBallConnection then A.charBallConnection:Disconnect();A.charBallConnection=nil end
 if not char then return end
 A.charBallConnection=char.DescendantAdded:Connect(addBall)
 local ds=char:GetDescendants();for i=1,math.min(#ds,400)do addBall(ds[i])end
end
A.footballTool=function()
 local cur=ownBall
 for _=1,6 do
  if not cur then return end
  if cur:IsA('Tool')then if cur.Parent==me.Character then return cur end;return end
  cur=cur.Parent
 end
end
A.toolSignature=function(tool)
 local shapes={};local nodes={tool};local i=1
 while i<=#nodes and i<=32 do
  local o=nodes[i];i=i+1;shapes[#shapes+1]=o.ClassName
  for _,child in ipairs(o:GetChildren())do if #nodes<32 then nodes[#nodes+1]=child end end
 end
 table.sort(shapes)
 return clean(tool.Name)..'|'..tostring(tool.RequiresHandle)..'|'..table.concat(shapes,',')
end
-- Public target observation is independent of the selector wrapper. It never selects a player.
A.resolveHudTarget=function(name,now)
 local cached=A.publicTargetCache
 if cached and cached.name==name and now-cached.at<.10 and cached.char==sessionChar and cached.team==sessionTeam then
  local a=cached.actor;local s=a and states[a.owner]
  if not a then return nil,cached.reason end
  if eligibleReceiver(a.model)and fresh(s,now)and(not field or insideField(s.root.Position,CFG.SideInset,3))then return a,cached.reason end
 end
 local found,reason=nil,'HUD_TARGET_NOT_CURRENT_HUMAN';local roster=Players:GetPlayers()
 if #roster>CFG.MaxRoster then reason='ROSTER_CAP'
 else
  for _,p in ipairs(roster)do
   local a=actor(p.Character)
   if matches(a,name)then
    if found then found=nil;reason='AMBIGUOUS_HUD_ALIAS';break end
    found=a;reason='UNIQUE_CURRENT_TEAMMATE'
   end
  end
  if found then
   local allowed,why=eligibleReceiver(found.model);local s=states[found.owner]
   if not allowed then found=nil;reason=why
   elseif not fresh(s,now)then found=nil;reason='HUD_TARGET_STALE'
   elseif field and not insideField(s.root.Position,CFG.SideInset,3)then found=nil;reason='HUD_TARGET_OFF_FIELD'end
  end
 end
 A.publicTargetCache={name=name,at=now,actor=found,reason=reason,char=sessionChar,team=sessionTeam}
 return found,reason
end
A.bindHeldTool=function()
 local tool=A.footballTool()
 if tool==A.heldTool then
  if tool and A.toolDirty then A.heldSignature=A.toolSignature(tool);A.toolDirty=false end;return
 end
 if A.toolConnection then A.toolConnection:Disconnect();A.toolConnection=nil end
 for _,c in ipairs(A.toolWatchers or {})do c:Disconnect()end;A.toolWatchers={}
 A.heldTool=tool;A.heldSignature=nil;A.toolDirty=false
 if not tool then return end
 A.heldSignature=A.toolSignature(tool)
 for _,signal in ipairs({tool.DescendantAdded,tool.DescendantRemoving,tool:GetPropertyChangedSignal('RequiresHandle'),tool:GetPropertyChangedSignal('Name')})do
  A.toolWatchers[#A.toolWatchers+1]=signal:Connect(function()A.toolDirty=true end)
 end
 local signature=A.heldSignature;log('HELD_TOOL','class=Tool|name='..clean(tool.Name)..'|proofs='..(A.toolProofs[signature]or 0))
 A.toolConnection=tool.Activated:Connect(function()
  local now=os.clock();local proof=forcedSample;local evidence=A.hudEvidence;local signature=A.heldSignature
  A.toolSignals=A.toolSignals+1
  local pending=A.pendingThrow
  if pending and pending.possession==A.possessionID and pending.tool==tool then
   pending.signals=(pending.signals or 0)+1
   A.recordAuto('ACTIVATED_SIGNAL','ordinal='..pending.signals..'|target='..clean(pending.model and pending.model.Name)..'|elapsed='..string.format('%.3f',now-pending.at))
  end
  local target=proof and proof.model
  local hudStatus,hudLabel=hudState()
  local hudAgreed=hudStatus=='LIVE'and target and matches(actor(target),hudLabel)
   or hudStatus~='LIVE'and evidence and target==evidence.model and evidence.epoch==selectionEpoch and now-evidence.at<.25
  -- Activation can remove the held Handle/hide the HUD before our observer runs.
  -- Attribute using the immediately preceding selector + HUD receipt, never old recommendations.
  local known=autoRequested and tool==A.heldTool and sessionChar==me.Character and sessionTeam==me.Team
   and proof and now-proof.at<.2 and proof.epoch==selectionEpoch and latest and latest.forced
   and latest.out==target and latest.epoch==selectionEpoch and now-latest.t<.2 and hudAgreed
  local points={};local shots=proof and proof.shots or selection and selection.model==target and selection.shots or {}
  if known then for _,shot in ipairs(shots)do points[#points+1]=shot.point end
  elseif tool==A.heldTool and sessionChar==me.Character and sessionTeam==me.Team then
   local a,reason=nil,'HUD_'..hudStatus
   if hudStatus=='LIVE'then a,reason=A.resolveHudTarget(hudLabel,now)
   elseif A.heldAimReceipt and now-A.heldAimReceipt.at<.20 and A.heldAimReceipt.possession==A.possessionID
    and A.heldAimReceipt.char==sessionChar and A.heldAimReceipt.team==sessionTeam then
    a=eligibleReceiver(A.heldAimReceipt.model);reason=a and 'RECENT_PUBLIC_HUD_RECEIPT'or 'RECEIPT_TARGET_INVALID'
   end
   A.manualHudStatus=reason;local s=a and states[a.owner]
   if a and fresh(s,now)and(not field or insideField(s.root.Position,CFG.SideInset,3))then
    local origin=lastHeldPosition
    if origin then for _,mode in ipairs({'BULLET','FIT','JUMP'})do local shot=solve(origin,s,mode);if shot then points[#points+1]=shot.point end end end
    if #points>0 then known=true;target=a.model end
   end
  end
  local previous=A.activation;local related=previous and previous.possession==A.possessionID and previous.tool==tool and now-previous.firstAt<1.1
  if not known and related and previous.target then target=previous.target;points=previous.points end
  local aim=A.aim and now-A.aim.at<.1 and target and matches(actor(target),A.aim.target)and A.aim or related and previous.aim or nil
  A.activation={at=now,confirmedAt=known and now or related and previous.confirmedAt or nil,aim=aim,
   firstAt=related and previous.firstAt or now,possession=A.possessionID,tool=tool,signature=signature,
   target=known and target or related and previous.target or nil,points=points,playKey=A.context.playKey,
   automatic=A.pendingThrow and A.pendingThrow.possession==A.possessionID or false}
  log('TOOL_ACTIVATED','manual='..tostring(not A.activation.automatic)..'|verifiedTarget='..clean(A.activation.target and A.activation.target.Name))
 end)
end
A.routeMode=function(s)
 local axis=fieldAxis();local speed=s.v.Magnitude
 if not axis or speed<4 then return end
 local along=math.abs(s.v.Unit:Dot(axis));return along<.35 and 'BULLET'or(along>.85 and 'FIT'or'JUMP')
end
A.solveHud=function(origin,s,aim,delay,angleOffset)
 local angle=math.rad(aim.angle+(angleOffset or 0));local t=clamp(aim.time,.12,CFG.MaxFlight);local height=aim.mode=='JUMP'and 4 or 3
 if math.cos(angle)<.15 then return nil,'ANGLE_RANGE'end
 for _=1,14 do
  local target=predict(s,t+delay)+V(0,height,0);local d=flat(target-origin);local r=d.Magnitude
  if r<8 or r>CFG.MaxRange then return nil,'CATCH_RANGE:'..string.format('%.2f',r)end
  local horizontal=CFG.Speed*math.cos(angle)
  if aim.mode=='JUMP'then
   local u=r*math.tan(angle)-(target.Y-origin.Y);if u<=0 then return nil,'JUMP_GEOMETRY'end
   horizontal=r/math.sqrt(2*u/CFG.Gravity);local speed=horizontal/math.cos(angle)
   if speed>CFG.Speed+2 or speed<30 then return nil,'JUMP_POWER_RANGE:'..string.format('%.2f',speed)end
  end
  local nextT=r/horizontal;if nextT<.08 or nextT>CFG.MaxFlight then return nil,'FLIGHT_TIME_RANGE:'..string.format('%.3f',nextT)end
  if math.abs(nextT-t)<.012 then
   if math.abs(nextT-aim.time)>aim.quantum*.5+.30 then return nil,'HUD_TIME_MISMATCH:predicted='..string.format('%.3f',nextT)..',hud='..aim.time end
   local launch=d.Unit*horizontal+V(0,horizontal*math.tan(angle),0)
   local point=origin+launch*nextT-V(0,.5*CFG.Gravity*nextT*nextT,0);local wr=predict(s,nextT+delay)
   if point.Y<wr.Y-1 or point.Y>wr.Y+(s.catchReach or 12.2)-2 then return nil,'CATCH_HEIGHT_RANGE:relativeY='..string.format('%.2f',point.Y-wr.Y)end
   return {mode=aim.mode,time=nextT,point=point,launch=launch,delay=delay,origin=origin,source='YUNA_HUD_ANGLE_PROVISIONAL_SPEED'}
  end
  t=t*.25+nextT*.75
 end
 return nil,'SOLVER_NOT_CONVERGED'
end
A.recordHudPathFailure=function(now,aim,origin,receiver,delay,offset,detail)
 if now<(A.nextPathFailureReceipt or 0)then return end;A.nextPathFailureReceipt=now+.5
 if #A.hudPathFailures>=8 then table.remove(A.hudPathFailures,1)end
 A.hudPathFailures[#A.hudPathFailures+1]='HUD_PATH_FAILURE|'..string.format('%.3f',now-started)..'|reason='..clean(detail)..'|target='..clean(selection and selection.model.Name)..'|mode='..aim.mode..'|angle='..aim.angle..'|hudTime='..aim.time..'|delay='..delay..'|offset='..offset..'|origin='..vec(origin)..'|receiver='..vec(receiver.p)..'|velocity='..vec(receiver.v)
end
A.checkActualAim=function(now)
 local aim=A.aim;local s=selection and selection.state;local q=states[me]
 if not aim or now-aim.at>.08 or not s or not matches(s.actor or actor(selection.model),aim.target)then return nil,'MODE_HUD_UNVERIFIED'end
 if now-aim.stableAt<.08 then return nil,'MODE_HUD_SETTLING'end
 local range=flat(s.p-q.p).Magnitude
 local ideal=A.routeMode(s);local axis=fieldAxis();local along=axis and range>1 and math.abs(flat(s.p-q.p).Unit:Dot(axis))or 1
 if aim.mode=='BULLET'and range>60 and ideal~='BULLET'and(ideal=='JUMP'or along>.35 and along<.85)then return nil,'DIAGONAL_BULLET_GUARD'end
 local cached=A.aimSafety
 if cached and now-cached.at<.08 and cached.epoch==selectionEpoch and cached.snapshot==selectionAt and cached.key==aim.key and math.abs(cached.angle-aim.angle)<.5 and cached.hudTime==aim.time then return cached.result,cached.reason end
 local begun=os.clock();local defenders={}
 for p,d in pairs(states)do
  if p~=me and p.Team~=me.Team and (not field or insideField(d.p,-10,-10))and flat(d.p-q.p).Magnitude<CFG.MaxRange+40 then
   if not fresh(d,now)then return nil,'DEFENDER_RESYNC'end
   defenders[#defenders+1]=A.freezeState(d)
  end
 end
 if #defenders==0 then return nil,'NO_DEFENDER_DATA'end
 local receiver=A.freezeState(s);local qb=A.freezeState(q);local ballOrigin=ownBall.Position
 local result={future=math.huge,lane=math.huge,shots={},mode=aim.mode};local reason=nil
 for _,delay in ipairs({CFG.ReleaseDelayLow,CFG.ReleaseDelayHigh})do
  local origin=predict(qb,delay)+(ballOrigin-qb.p)
  for _,offset in ipairs({-.75,0,.75})do
   local shot,pathReason=A.solveHud(origin,receiver,aim,delay,offset)
   if shot then shot=scoreShot(origin,receiver,defenders,shot)end
   if not shot then
    A.recordHudPathFailure(now,aim,origin,receiver,delay,offset,pathReason or 'SCORE_REJECTED')
    reason='HUD_PATH_UNVERIFIED';break
   end
   result.shots[#result.shots+1]=shot;result.future=math.min(result.future,shot.future);result.lane=math.min(result.lane,shot.lane)
  end
  if reason then break end
 end
 if not reason and(result.future<CFG.ThrowMargin or result.lane<CFG.ThrowLane)then reason='ACTUAL_MODE_UNSAFE'end
 if reason then result=nil end
 A.aimSafety={at=now,epoch=selectionEpoch,snapshot=selectionAt,key=aim.key,angle=aim.angle,hudTime=aim.time,result=result,reason=reason}
 A.measure('ACTUAL_MODE_CHECK',os.clock()-begun);return result,reason
end
A.reconsiderMode=function(now,reason)
 if not selection then return end
 local previous=A.modeBlocks[selection.model]
 if not previous or now>=previous.untilAt or previous.reason~=reason then
  A.modeBlocks[selection.model]={untilAt=now+.45,reason=reason};A.decision=nil
  log('MODE_RECONSIDER',clean(selection.player.Name)..'|reason='..reason..'|actual='..(A.aim and A.aim.mode or 'UNKNOWN')..'|window=0.45s')
 end
end
A.updateAutoThrow=function(now)
 if A.pendingThrow and now-A.pendingThrow.at>1.15 then
  if ownHeld then
   A.autoThrowRequested=false;A.throwStatus=(A.pendingThrow.signals or 0)==0 and 'ACTIVATE_SIGNAL_MISSING'or 'ACTIVATE_NO_RELEASE';A.throwFault=A.throwStatus;log('AUTO_THROW_DISABLED',A.throwStatus)
   A.recordAuto('NO_RELEASE','target='..clean(A.pendingThrow.model and A.pendingThrow.model.Name)..'|signals='..(A.pendingThrow.signals or 0)..'|held=true|elapsed='..string.format('%.3f',now-A.pendingThrow.at))
  else
   A.recordAuto('RELEASE_UNOBSERVED','target='..clean(A.pendingThrow.model and A.pendingThrow.model.Name)..'|signals='..(A.pendingThrow.signals or 0)..'|held=false; no matched outgoing flight')
  end
  A.pendingThrow=nil
 end
 if A.controlActive then A.throwStatus='CONTROL_MANUAL_ONLY';A.throwLock=nil;A.hudSyncSince=nil;return end
 if not A.autoThrowRequested then A.throwStatus=A.throwFault or 'OFF';if throwButton.Text~='THR\nOFF'then throwButton.Text='THR\nOFF'end;return end
 if phase~='RUN'or not numericMode then
  A.throwStatus=phase=='FINDING'and 'YUNA_NOT_LINKED'or 'SELECTOR_VERIFYING';A.throwLock=nil;A.hudSyncSince=nil
  if throwButton.Text~='THR\nWAIT'then throwButton.Text='THR\nWAIT'end;return
 end
 if not autoRequested then A.throwStatus='SELECT_AUTO_OFF';A.throwLock=nil;A.hudSyncSince=nil;throwButton.Text='THR\nWAIT';return end
 if throwButton.Text~='THR\nAUTO'then throwButton.Text='THR\nAUTO'end
 if not ownHeld then A.throwStatus='WAITING_FOR_BALL';A.throwLock=nil;A.hudSyncSince=nil;return end
 A.bindHeldTool()
 if not A.heldTool or A.heldTool.Parent~=me.Character then A.throwStatus='TOOL_PATH_UNKNOWN';A.throwLock=nil;return end
 if A.releasedPlayKey and A.releasedPlayKey==A.playKey then A.throwStatus='PLAY_ALREADY_RELEASED';A.throwLock=nil;return end
 if A.attemptedPossession==A.possessionID then A.throwStatus=A.pendingThrow and 'RELEASE_PENDING' or 'ATTEMPT_USED';return end
 if not canOverride(now)then A.throwStatus='SELECTION_NOT_READY';A.throwLock=nil;A.hudSyncSince=nil;return end
 if A.context.status~='PAIR_AND_HUD_STABLE'or A.context.source~='LINES_AND_HUD'or now-A.context.at>.35 then A.throwStatus='LINES_UNVERIFIED';A.throwLock=nil;return end
 local q=states[me]
 if flat(q.root.Position-A.context.los):Dot(forward)>.5 then A.throwStatus='QB_PAST_LOS';A.throwLock=nil;return end
 if now-A.possessionAt<.20 or selection.state.turn>.35 or(selection.state.routeSkipUntil or 0)>now or now-selection.state.moving>.5 then
  A.throwStatus='WAITING_FOR_SAFE_WINDOW';A.throwLock=nil;return
 end
 if installedAt and(not A.selectedTargetConfirmed or now-(A.selectedTargetAt or 0)>.10)then A.throwStatus='TARGET_NOT_CONFIRMED';A.hudSyncSince=nil;A.throwLock=nil;return end
 local synced=forcedSample and now-forcedSample.at<.15 and forcedSample.epoch==selectionEpoch and forcedSample.model==selection.model
  and hud and shown(hud)and matches(actor(selection.model),txt(hud))
 if not synced then A.throwStatus='HUD_RESYNC';A.hudSyncSince=nil;A.throwLock=nil;return end
 A.hudSyncSince=A.hudSyncSince or now
 local actual,reason=A.checkActualAim(now)
 if not actual then
  A.throwStatus=reason;A.throwLock=nil
  if reason=='ACTUAL_MODE_UNSAFE'or reason=='DIAGONAL_BULLET_GUARD'then A.reconsiderMode(now,reason)end
  return
 end
 if A.throwLock~=selection.model then A.throwLock=selection.model;A.throwLockAt=now end
 if now-A.throwLockAt<CFG.ThrowHold or now-A.hudSyncSince<.06 then A.throwStatus='OPEN_WINDOW_SETTLING';return end
 if not A.heldTool.Enabled or not ownBall:IsDescendantOf(A.heldTool)then A.throwStatus='TOOL_NOT_READY';A.throwLock=nil;return end
 local handle=A.heldTool:FindFirstChild('Handle')
 if A.heldTool.RequiresHandle and(not handle or not handle:IsA('BasePart'))then A.throwStatus='TOOL_HANDLE_MISSING';A.throwLock=nil;return end
 A.attemptedPossession=A.possessionID;A.throwAttempts=A.throwAttempts+1
 A.pendingThrow={at=now,possession=A.possessionID,tool=A.heldTool,model=selection.model,epoch=selectionEpoch,signals=0};local tool=A.heldTool
 A.throwStatus='ACTIVATING';log('AUTO_THROW','Tool:Activate|target='..clean(selection.player.Name)..'|actualMode='..actual.mode..'|hudAngle='..A.aim.angle..'|hudTime='..A.aim.time..'|future='..string.format('%.1f',actual.future)..'|lane='..string.format('%.1f',actual.lane))
 A.recordAuto('API_REQUEST','target='..clean(selection.player.Name)..'|mode='..actual.mode..'|angle='..A.aim.angle..'|time='..A.aim.time..'|possession='..A.possessionID)
 local ok,err=pcall(function()tool:Activate()end)
 A.recordAuto('API_RETURN','ok='..tostring(ok)..'|error='..(ok and 'NONE'or clean(err)))
 if not ok then A.autoThrowRequested=false;A.pendingThrow=nil;A.throwStatus='ACTIVATE_ERROR';A.throwFault=A.throwStatus;log('AUTO_THROW_DISABLED',clean(err));return end
 task.spawn(function()task.wait(.08);if not stopped and tool.Parent==me.Character and tool.Enabled then pcall(function()tool:Deactivate()end)end end)
end
local function apply(values)
 local now=os.clock();local out=values;local changed=false
 if A.overrideReady and now-A.overrideAt<.09 and A.overrideEpoch==selectionEpoch and selection
  and A.overrideModel==selection.model and sessionChar==me.Character and sessionTeam==me.Team
  and ownHeld and ownBall and ownBall.Parent and autoRequested and selection.state.hum.Health>0
  and selection.player.Team==me.Team and not selection.player.Neutral and selection.player.Character==selection.model
  and field and field.part.Parent and not A.fieldDirty then
  if values.n==2 and (values[1]==nil or (typeof(values[1])=='Instance' and values[1]:IsA('Model'))) and finite(values[2]) then
   local root=A.overrideRoot;local cam=workspace.CurrentCamera;local distance=nil
   if root and root.Parent and cam then
    local p,on=cam:WorldToScreenPoint(root.Position)
    if on and p.Z>0 then local pointer=Input:GetMouseLocation();local dx,dy=p.X-pointer.X,p.Y-pointer.Y;distance=math.sqrt(dx*dx+dy*dy)end
   end
   if finite(distance) and distance>=0 then
    out={n=2,[1]=selection.model,[2]=distance};changed=true;overrideCalls=overrideCalls+1
    if values[1]~=selection.model then differentCalls=differentCalls+1 end
    if not forcedSample or forcedSample.model~=selection.model or forcedSample.epoch~=selectionEpoch then
     forcedSample={at=now,firstAt=now,model=selection.model,epoch=selectionEpoch,shots=selection.shots}
     A.handoff={at=now,model=selection.model,epoch=selectionEpoch,fromModel=A.linkCurrentModel or values[1],normal=values[1],normalDistance=values[2],outputDistance=distance}
     A.selectedTargetConfirmed=false
     A.recordTarget('APPLY','target='..clean(selection.model.Name)..'|normal='..clean(values[1]and values[1].Name)..'|normalDistance='..string.format('%.2f',values[2])..'|outputDistance='..string.format('%.2f',distance)..'|epoch='..selectionEpoch)
    else forcedSample.at=now;forcedSample.shots=selection.shots end
    local h=A.handoff
    if h then
     if not h.deliverySince or not h.deliveredAt or now-h.deliveredAt>.10 then h.deliverySince=now;h.deliveryCalls=0;h.deliveryGaps=(h.deliveryGaps or 0)+1 end
     h.deliveredAt=now;h.deliveryCalls=(h.deliveryCalls or 0)+1
    end
   end
  else tupleErrors=tupleErrors+1;A.disableSelection('RETURN_SCHEMA_CHANGED')end
 end
 if not changed and A.handoff then
  A.handoff.deliverySince=nil;A.handoff.deliveryCalls=0;A.handoff.fallbacks=(A.handoff.fallbacks or 0)+1
 end
 if now-lastCaptured>=.04 then
  lastCaptured=now;serial=serial+1
  if phase=='VERIFY' then calibrate(values,now) end
  latest={t=now,id=serial,normal=values[1],out=out[1],number=values[2],forced=changed,epoch=selectionEpoch}
 end
 return out
end
local function makeWrapper(fn)
 return function(...)
  if stopped then return fn(...) end
  calls=calls+1;local values=pack(fn(...));returns=returns+1
  if not stopped then
   local ok,out=pcall(apply,values)
   if ok and type(out)=='table' then values=out
   else captureErrors=captureErrors+1;A.disableSelection('SELECTOR_CAPTURE_ERROR');selection=nil end
  end
  return unpackValues(values,1,values.n)
 end
end
-- Getter identity is permanent for this installation; the target attachment is transient.
A.checkLink=function(now)
 local t=anchor and readAll(anchor.fn)
 if not t or rawget(t,A.getterSlot())~=wrapper then
  A.linkTargetReady=false;A.selectedTargetConfirmed=false;A.overrideReady=false;finish('YUNA_CALL_SITE_CHANGED');return false
 end
 local state,label=hudState();local value=rawget(t,A.targetSlot());local a=actor(value)
 local attachment=typeof(value)=='Instance'and value:IsA('Attachment')and a
  and a.model:IsDescendantOf(workspace)and(not a.owner or a.owner.Character==a.model)
 local valid=state=='LIVE'and attachment and matches(a,label)
 local h=A.handoff
 -- Once installed and calibrated, lagging output labels cannot revoke the getter's identity.
 -- Continue only through observed current-human teammate outputs; never confirm from a request.
 local handoffLive=autoRequested and ownHeld and phase=='RUN'and h and h.epoch==selectionEpoch
  and selection and h.model==selection.model and state=='LIVE'
 local transition=handoffLive and attachment and eligibleReceiver(a.model)and A.resolveHudTarget(label,now)~=nil
 A.selectedTargetConfirmed=valid and selection and a.model==selection.model and true or false
 if A.selectedTargetConfirmed then
  A.selectedTargetAt=now
  if h then h.unconfirmedSince=nil;h.confirmedAt=now end
 elseif handoffLive then
  h.unconfirmedSince=h.unconfirmedSince or now
  -- A wall-clock deadline started at the first-ever choice can falsely fail a later single-frame mismatch.
  -- Only sustained delivery with no real acknowledgement is a failed handoff.
  if(not A.controlActive or not h.controlMismatchRecorded)and now-h.unconfirmedSince>=.8 and h.deliverySince and now-h.deliverySince>=.6
   and h.deliveredAt and now-h.deliveredAt<=.10 then
   A.recordTarget('FAILED','target='..clean(h.model.Name)..'|attachment='..clean(a and a.model.Name)..'|hud='..clean(label)
    ..'|unconfirmed='..string.format('%.3f',now-h.unconfirmedSince)..'|continuousDelivery='..string.format('%.3f',now-h.deliverySince)
    ..'|calls='..(h.deliveryCalls or 0)..'|gaps='..(h.deliveryGaps or 0))
   if A.controlActive then
    if not h.controlMismatchRecorded then A.recordTarget('CONTROL_MISMATCH','attachment='..clean(a and a.model.Name)..'|hud='..clean(label));h.controlMismatchRecorded=true end
   else A.disableSelection('TARGET_HANDOFF_TIMEOUT');transition=false end
  end
 elseif h then h.unconfirmedSince=nil end
 if not valid and not transition then
  A.linkTargetReady=false;A.overrideReady=false;A.hudEvidence=nil;A.throwLock=nil;A.hudSyncSince=nil;A.linkTargetStableAt=nil
  A.linkStatus=state~='LIVE'and 'WAITING_FOR_HELD_BALL_HUD'or 'TARGET_HUD_RESYNC';return true
 end
 if A.linkCurrentTarget~=value or A.linkCurrentModel~=a.model then
  A.linkCurrentTarget=value;A.linkCurrentModel=a.model;A.linkTargetStableAt=now
 end
 A.linkTargetStableAt=A.linkTargetStableAt or now;A.linkTargetAt=now
 -- Once the getter contract is proven, target movement is its normal output lifecycle.
 -- Release still requires the actual selected receiver in both Attachment and visible HUD.
 A.linkTargetReady=phase=='RUN'or now-A.linkTargetStableAt>=.06
 A.linkStatus=transition and not valid and 'TARGET_HANDOFF_PENDING'or A.linkTargetReady and(phase=='RUN'and 'LINKED_VERIFIED'or 'VERIFYING_RETURN_CONTRACT')or 'TARGET_HUD_RESYNC'
 return true
end

local function install()
 local readable,current=readSlot()
 if not readable or not fingerprint(current) then finish('SELECTOR_FINGERPRINT_MISMATCH');return end
 local t=readAll(anchor.fn)
 if stopped then return end
 if not t or rawget(t,A.targetSlot())~=marker or rawget(t,A.getterSlot())~=current then finish('ANCHOR_CHANGED');return end
 original=current;wrapper=makeWrapper(original);writeAttempted=true;wrapperAbsent=false
 restoreState='WRAPPER_INSTALLING';gui:SetAttribute('WrapperAbsent',false);writeInFlight=true
 local ok=pcall(setuv,anchor.fn,A.getterSlot(),wrapper);writeInFlight=false
 local good,after=readSlot()
 if stopped then finish('STOP_DURING_INSTALL');return end
 if not ok or not good or after~=wrapper then finish('INSTALL_NOT_CONFIRMED');return end
 installedAt=os.clock();phase='VERIFY';A.linkStatus='VERIFYING_RETURN_CONTRACT';restoreState='WRAPPER_PRESENT'
 log('INSTALLED','layout='..anchor.layout.id..'|targetSlot='..A.targetSlot()..'|getterSlot='..A.getterSlot()..'|verify return contract before control')
end
local function observeReturn(now)
 local state,label=hudState();local key=state..'|'..clean(label)
 if key~=lastHud then log('HUD',key);lastHud=key end
 if phase=='VERIFY' then
  local mode=chooseNumericMode()
  if mode then numericMode=mode;phase='RUN';A.linkStatus='LINKED_VERIFIED';log('R2_VERIFIED',mode.id)
  elseif calibration.n>=60 then finish('KNOWN_FORMULA_MISMATCH');return end
 end
 local sample=latest
 if not sample or sample.id==lastProcessed then return end;lastProcessed=sample.id
 if sample.forced and sample.epoch==selectionEpoch and selection and state=='LIVE' and now-sample.t<.25 then
  local hit=matches(actor(sample.out),label);hudChecks=hudChecks+1
  local h=A.handoff;local settled=not h or h.epoch~=sample.epoch or h.model~=sample.out or now-h.at>=.25
  if hit then
   hudHits=hudHits+1;hudFailures=0;A.hudEvidence={at=now,model=sample.out,epoch=sample.epoch}
   if h and h.epoch==sample.epoch and h.model==sample.out and not h.hudAck then
    h.hudAck=now;A.targetAckCount=A.targetAckCount+1
    A.recordTarget('HUD_ACK','target='..clean(sample.out.Name)..'|elapsed='..string.format('%.3f',now-h.at)..'|differentNormal='..tostring(sample.normal~=sample.out)..'|attachmentConfirmed='..tostring(A.selectedTargetConfirmed))
   end
  elseif settled and autoRequested then hudFailures=hudFailures+1 end -- diagnostic only; one time-based handoff watchdog owns shutdown
  if sample.normal~=sample.out then normalDifferentChecks=normalDifferentChecks+1;if hit then normalDifferentHits=normalDifferentHits+1 end end
  -- Sample count is not elapsed time, and a HUD-only match is not attachment confirmation.
 end
end
local function update(now)
 updateCount=updateCount+1
 if sessionChar~=me.Character or sessionTeam~=me.Team then
  states={};selection=nil;selectionEpoch=selectionEpoch+1;forward=nil;possessionStart=nil;ownHeld=false;ownBall=nil
  heldBall=nil;lastHeldAt=nil;heldSnapshot=nil;forcedSample=nil;A.handoff=nil;A.selectedTargetConfirmed=false;A.selectedTargetAt=nil;if flight then A.finishPath(flight,'SESSION_RESET');flight=nil end
  sessionChar=me.Character;sessionTeam=me.Team;A.modeBlocks={};A.aimSafety=nil;A.aimTargetKey=nil;A.heldAimReceipt=nil;A.pendingThrow=nil;A.watchCharacter(sessionChar);A.decision=nil;A.overrideReady=false;directionButton.Text='DIR';A.context.source='NONE';A.context.streak=0;A.context.los=nil;A.context.first=nil;A.throwLock=nil;A.hudSyncSince=nil;A.activation=nil;A.hudEvidence=nil;log('RESET','Character or team changed')
 end
 if priorTick and now-priorTick>.6 then
  if flight then A.finishPath(flight,'CLIENT_PAUSE');flight=nil end
  A.pendingThrow=nil;A.heldAimReceipt=nil;ownHeld=false;states={};clearChoice('RESYNC_AFTER_PAUSE');ownBall=nil;heldBall=nil;lastHeldAt=nil;forcedSample=nil
 end
 priorTick=now
 local roster=Players:GetPlayers()
 if #roster>CFG.MaxRoster then clearChoice('ROSTER_CAP');return end
 local alive={}
 for _,p in ipairs(roster) do alive[p]=true;samplePlayer(p,now) end
 for p in pairs(states) do if not alive[p] then states[p]=nil end end
 local q=states[me]
 local mappedAt=os.clock();scanField();local checkAt=os.clock();chooseField(q);A.measure('FIELD_VALIDATE',os.clock()-checkAt)
 A.updateContext(now,q);A.measure('FIELD_CONTEXT',os.clock()-mappedAt)
 if not me.Team or me.Neutral then ownHeld=false;clearChoice('WAITING_FOR_TEAM');return end
 if not fresh(q,now) then ownHeld=false;clearChoice('QB_RESYNC');return end
 local ballAt=os.clock();local ballOK,err=pcall(observeBall,now,q);A.measure('BALL',os.clock()-ballAt)
 if not ballOK then ballErrors=ballErrors+1;ownHeld=false;clearChoice('BALL_OBSERVATION_ERROR');log('BALL_ERROR',clean(err));return end
 if not ownHeld then clearChoice('WAITING_FOR_YOUR_FOOTBALL');A.updateAutoThrow(now);return end
 A.bindHeldTool()
 if not field then clearChoice('FIELD_UNKNOWN_ADVISE_ONLY');return end
 if not insideField(q.p,0,0)then clearChoice('QB_OUTSIDE_FIELD');return end
 chooseReceiver(now,roster,q)
end
local function render(now)
 if stopped then return end
 local linked=phase=='RUN'and numericMode~=nil;local active=canOverride(now)
 panel.BackgroundColor3=active and Color3.fromRGB(15,65,35)or Color3.fromRGB(65,51,23)
 glow.FillColor=(active or linked and not autoRequested and gate=='READY')and Color3.fromRGB(0,255,80)or Color3.fromRGB(255,200,45)
 glow.OutlineColor=glow.FillColor
 A.selectButton.Text='SEL\n'..(autoRequested and 'AUTO'or 'ADVISE')
 local text
 if A.controlActive then text='CTRL / MANUAL'
 elseif not A.capabilityReady then text='WAIT API'
 elseif not linked then
  text=phase=='VERIFY'and 'VERIFY'or not hud and 'WAIT YUNA'or hudState()~='LIVE'and 'WAIT BALL'or 'LINKING'
 elseif not ownHeld then text=(autoRequested and 'AUTO'or 'ADVISE')..' / NO BALL'
 elseif not autoRequested then text=A.selectFault~='NONE'and 'AUTO PAUSED'or 'ADVISE'
 elseif not A.linkTargetReady then text='AUTO / HUD WAIT'
 elseif A.throwStatus=='ACTIVATING'or A.throwStatus=='RELEASE_PENDING'then text='PASS REQUESTED'
 elseif A.throwStatus=='HUD_PATH_UNVERIFIED'then text='AUTO / PATH?'
 elseif A.throwStatus=='ACTUAL_MODE_UNSAFE'or A.throwStatus=='DIAGONAL_BULLET_GUARD'then text='AUTO / AIM RISK'
 elseif A.throwStatus=='WAITING_FOR_SAFE_WINDOW'then text='AUTO / ROUTE'
 elseif A.throwStatus=='TOOL_PATH_UNKNOWN'or A.throwStatus=='TOOL_HANDLE_MISSING'or A.throwStatus=='TOOL_NOT_READY'then text='AUTO / TOOL WAIT'
 elseif A.throwStatus=='TARGET_NOT_CONFIRMED'then text='AUTO / TARGET?'
 elseif A.throwStatus=='HUD_RESYNC'then text='AUTO / HUD WAIT'
 elseif A.throwStatus=='LINES_UNVERIFIED'then text='AUTO / LINES'
 elseif A.throwFault and not A.autoThrowRequested then text='THROW FAILED'
 elseif active and selection then
  local name=selection.player.DisplayName;local cut=utf8.offset(name,8);if cut then name=name:sub(1,cut-1)end
  local mode=A.aim and matches(selection.state.actor or actor(selection.model),A.aim.target)and A.aim.mode or '~'..selection.best.mode
  text=name..' '..mode..(A.autoThrowRequested and ''or ' / OFF')
 else text='AUTO / WAIT'end
 A.uiStatus=text;panel.Text=text
end

-- Preserve meaningful reports while in Roblox; do not overwrite with an empty startup header.
task.spawn(function()
 while not stopped do
  if updateCount>=8 and (field or anchor or releaseCount>0 or A.discoveryReady or A.linkChecks>=20)then local ok=pcall(copy,false);if not ok then copyOK=false end end
  task.wait(8)
 end
end)
task.spawn(function()
 local ok,err=pcall(function()
  if game.PlaceId~=82866880824588 then finish('LIVE_PLACE_REQUIRED');return end
  A.refreshCapabilities();A.capabilityReady=selftest();if not A.capabilityReady then A.linkStatus='WAITING_FOR_REFLECTION_API'end
  local good,c=pcall(function()return workspace.DescendantAdded:Connect(function(o)addBall(o);enqueue(o);A.addContextCandidate(o)end)end)
  if good then watchers[#watchers+1]=c end
  local children=workspace:GetChildren();for i=1,math.min(#children,256) do
   local o=children[i];addBall(o)
   if o.Name=='Football' then local ds=o:GetDescendants();for j=1,math.min(#ds,64) do addBall(ds[j]) end end
  end
  local got,core=pcall(function()return game:GetService('CoreGui')end);if got then roots[#roots+1]=core end
  for _,root in ipairs(roots) do
   local watched,c2=pcall(function()return root.DescendantAdded:Connect(addLabel)end);if watched then watchers[#watchers+1]=c2 end
   local good2,ds=pcall(function()return root:GetDescendants()end)
   if good2 then for i,o in ipairs(ds) do if stopped then return end;addLabel(o);if i%150==0 then task.wait() end end end
  end
  local nextLocate,nextDiscovery,nextCheck,nextStatus,nextPhysics,nextCapabilities=0,0,0,0,0,0
  while not stopped do
   local now=os.clock()
   if loaderContext and loaderContext.IsCancelled and loaderContext.IsCancelled()then finish('LOADER_CANCELLED');return end
   if A.controlActive and now>=A.controlUntil then A.endControl('WINDOW_ENDED')end
   if not anchor then
    if not A.capabilityReady and now>=nextCapabilities then A.refreshCapabilities();A.capabilityReady=selftest();nextCapabilities=os.clock()+3 end
    if A.capabilityReady and now>=nextDiscovery then discover();nextDiscovery=os.clock()+3 end
    if (not hud or not hud.Parent) and now>=nextLocate then locate();nextLocate=os.clock()+1 end
    if stopped then return end;local bindAt=os.clock();bind();A.measure('BINDING',os.clock()-bindAt);if anchor then install() end
   elseif installedAt then
    if now>=nextCheck then
     if not A.checkLink(now)then return end
     nextCheck=now+.05
    end
    observeReturn(now)
   end
   A.ensureAimHud(now)
   A.readAimHud(now)
   if field and(A.downDirty or A.contextGeometryRevision~=A.markerRevision)then A.updateContext(now,states[me])end
   if stopped then return end
   if now>=nextPhysics then
    local begun=os.clock();local worked,why=pcall(update,now);local elapsed=os.clock()-begun;maxWork=math.max(maxWork,elapsed);A.measure('OBSERVE',elapsed)
    if not worked then A.disableSelection('ADVISOR_ERROR');clearChoice('ADVISOR_ERROR');log('ERROR',clean(why))end
    nextPhysics=os.clock()+CFG.Interval
   end
   local sliced,why=pcall(A.stepDecision,now)
   if not sliced then A.disableSelection('SCORE_ERROR');clearChoice('ADVISOR_ERROR');log('ERROR',clean(why))end
   A.refreshOverride(now)
   if ownHeld and now>=(A.nextThrowCheck or 0)then
    local checked,why=pcall(A.updateAutoThrow,now)
    if not checked then A.autoThrowRequested=false;A.throwFault='THROW_CHECK_ERROR';A.throwStatus=A.throwFault;log('THROW_ERROR',clean(why))end
    A.nextThrowCheck=now+.02
    A.throwGateCounts[A.throwStatus]=(A.throwGateCounts[A.throwStatus]or 0)+1
    if A.throwStatus~=A.lastThrowGate then
     A.lastThrowGate=A.throwStatus;log('THROW_GATE',A.throwStatus..'|target='..clean(selection and selection.player.Name)..'|actual='..(A.aim and A.aim.mode or 'UNKNOWN'))
    end
   end
   if now>=nextStatus then render(now);nextStatus=now+.3 end
   task.wait(.02)
  end
 end)
 if not ok then
  log('ERROR',clean(err));finish('SCRIPT_ERROR')
  if loaderContext and loaderContext.ReportRuntimeError then loaderContext.ReportRuntimeError(tostring(err))end
 end
end)
-- Controller interface used by the game router. END retains its results panel;
-- replacing a session destroys that panel only after confirmed restoration.
A.controller={Version='PELICAN_FF3_V13'}
A.controller.Stop=function(reason)
 finish(reason or 'CONTROLLER_STOP')
 local cleanStop=A.cleanupConfirmed()
 if cleanStop then gui:Destroy()end
 return cleanStop
end
A.controller.GetReport=function()return finalData and finalData.Value or report(stopped)end
A.controller.IsStopped=function()return stopped end
A.controller.IsClean=A.cleanupConfirmed
-- MODULE_EXPORT: test harness exercises the actual source before this return.
return A.controller
