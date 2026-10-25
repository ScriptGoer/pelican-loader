local setup=dofile('tests/experimental/fixtures/ff3_league_fixture.lua')
local checks=0
local function check(v,msg) checks=checks+1;assert(v,msg) end
local function label(t,text)
    local holder=Instance.new('ScreenGui');holder.Parent=t.me:FindFirstChild('PlayerGui')
    local o=Instance.new('TextLabel');o.Text=text;o.Parent=holder;return o,holder
end
local t=setup();t.env.PELICAN_FF3_RECEIVER_FILTER='FRIENDS';t.env.PELICAN_FF3_MAG_TRIAL=true;t.env.PELICAN_FF3_COMEBACK_CHAT=true
local c=t.run();t.steps();local ui=t.ui()
check(c.league.mode=='LEAGUE' and c.receiverFilter.mode=='ANY' and not c.mag.enabled and not c.comeback.enabled,'league removes friendship restriction, mag trials and route-chat features')
check(c.receiverFilter.checks==0 and not c.SetReceiverFilter('FRIENDS') and not c.SetMagTrial(true) and not c.SetComebackChat(true),'hidden friendship/chat/trial workflows cannot be reenabled inside league')
local visible=0;local status
for _,o in ipairs(ui:GetChildren()) do if o:IsA('TextButton') and o.Visible then visible=visible+1;if o.Name~='Reload' and o.Name~='Screen' then status=o end end end
check(visible==2 and status and not ui:FindFirstChild('Screen').Visible and not ui:FindFirstChild('ThrowAway').Visible,'collapsed league HUD is QB and reload only')
status.Activated:Fire()
for _,name in ipairs({'ReceiverFilter','MagTrial','History','Receivers'}) do
    local b=ui:FindFirstChild(name);check(b and not b.Visible,'league expansion does not expose extra feature '..name)
end
check(ui:FindFirstChild('PassPlan').Visible and ui:FindFirstChild('NativeJump').Visible,'supported plan and raised-pass controls are available on PLAY')
c.unified.toolsButton.Activated:Fire();check(ui:FindFirstChild('PlayProfile').Visible,'manual profile override remains available in TOOLS')
check(c.SetProfile('CASUAL','USER') and c.receiverFilter.mode=='FRIENDS' and not c.mag.enabled and c.comeback.enabled,'leaving league restores prior casual choices')
check(c.SetProfile('LEAGUE','USER') and c.receiverFilter.mode=='ANY','reentering league resets runtime restrictions without erasing saved casual mode')
check(c.Stop('PROFILE'),'profile cleanup')
-- VIP is only an exact, visible, top-HUD private-server hint; explicit profile wins.
for _,kind in ipairs({'VISIBLE','HIDDEN','DISABLED_GUI','BOTTOM','OFFSCREEN','TRANSPARENT','NOT_EXACT','FORCED_CASUAL'}) do
    t=setup({ff3={Profile=kind=='FORCED_CASUAL' and 'CASUAL' or 'AUTO'}})
    local o,h=label(t,kind=='NOT_EXACT' and 'VIP SERVER list' or 'VIP SERVER')
    if kind=='HIDDEN' then o.Visible=false elseif kind=='DISABLED_GUI' then h.Enabled=false
    elseif kind=='BOTTOM' then o.AbsolutePosition=Vector3.new(0,600,0)
    elseif kind=='OFFSCREEN' then o.AbsolutePosition=Vector3.new(3000,0,0)
    elseif kind=='TRANSPARENT' then o.TextTransparency=1 end
    c=t.run();t.steps()
    check(c.league.mode==(kind=='VISIBLE' and 'LEAGUE' or 'CASUAL'),'VIP hint qualification: '..kind)
    if kind=='VISIBLE' then
        check(c.league.vipSeen and c.league.source=='VISIBLE_VIP_HINT_UNVERIFIED_LEAGUE','report does not call private-server text verified league identity')
        h.Enabled=false;t.steps(5);check(c.league.mode=='LEAGUE','hint does not flap when gameplay hides the banner')
        check(c.SetProfile('CASUAL','USER'),'explicit casual overrides latched VIP hint');t.steps(5);check(c.league.mode=='CASUAL','manual override persists')
    end
    check(c.Stop(kind),'VIP cleanup '..kind)
end
-- A late banner must still be discoverable after Yuna fills the bounded label cache.
t=setup({ff3={Profile='AUTO'}})
for i=1,300 do label(t,'Unrelated settings label '..i) end
c=t.run();t.steps(20);check(c.league.mode=='CASUAL','large unrelated UI does not invent league identity')
local holder=Instance.new('ScreenGui');holder.Parent=t.me:FindFirstChild('PlayerGui')
local late=Instance.new('TextLabel');late.Parent=holder;late.Text='VIP SERVER'
local maxFlood=t.steps(20)
check(c.league.mode=='LEAGUE' and c.league.vipSeen,'late exact VIP banner gets retained even when label cache is full')
check(maxFlood<=8 and c.Stop('VIP_FLOOD'),'bounded scan/native work and cleanup with a full GUI cache')
-- Explicit teammate selection permits one stationary screen, not all idle players.
t=setup();c=t.run();t.steps()
check(#t.requests==0 and not t.q.Locked,'unselected AFK receiver behind LOS is excluded')
ui=t.ui();ui:FindFirstChild('CompactQB').Activated:Fire();ui:FindFirstChild('Screen').Activated:Fire()
local menu=ui:FindFirstChild('ReceiverList')
check(menu.Visible and menu:FindFirstChild('Title').Text=='Screen: this possession only','compact screen control opens deliberate selection')
menu:FindFirstChild('Receiver1').Activated:Fire()
check(c.league.screen and c.league.screen.player==t.a and not menu.Visible,'screen row arms current teammate without trust/friend toggling')
local max=t.steps();local p=t.payload()
check(#t.requests==1 and p.Screen and p.Mode=='Bullet' and p.Variant=='SoftBullet','actual stationary behind-LOS screen releases a strict Bullet-lead native pass')
check(p.Arrival[3]>=70 and p.PowerPolicyReason=='EXPLICIT_ARMED_SCREEN_RECEIVER_PREPARED','arrival stays behind LOS and fast-screen exception is explicit in evidence')
check(max<=8 and p.Profile=='LEAGUE' and p.CoverageLayers,'screen stays inside native budget and records actual coverage')
check(not c.league.screen,'screen disarms after the single attempted pass')
t.state.Status.Value='BetweenPlays';t.steps(2);t.state.Status.Value='InPlay';t.steps()
check(#t.requests==1 and not t.q.Locked,'screen permission never survives into next possession')
check(c.Stop('SCREEN'),'screen cleanup')
-- A longer screen with no generic low-power support must not be mistaken for a deep burn.
t=setup({nativeModes={Bullet=true}});Mock.qroot.Position=Vector3.new(0,6,140)
Mock.qhum.UseJumpPower=true;Mock.qhum.JumpPower=50
c=t.run();t.steps();check(c.SelectScreen(t.a),'native-Bullet-only screen can be armed')
max=t.steps();p=t.payload()
check(p and p.Screen and p.Variant=='Bullet' and p.Time>.5,'native fallback screen releases without requiring stationary receiver to run a burn')
check(max<=8 and c.GetReport():find('AUTO_JUMP_REQUESTS|0',1,true),'screen remains independent of deep-jump route preparation')
check(c.Stop('BULLET_SCREEN'),'native Bullet screen cleanup')
-- Invalid selection and crossing LOS during the final calculation fail closed.
for _,kind in ipairs({'ENEMY','BLOCKED','DOWNFIELD','TOO_DEEP','QB_PAST','CASUAL'}) do
    t=setup({ff3={Profile=kind=='CASUAL' and 'CASUAL' or 'LEAGUE'}});c=t.run();t.steps()
    if kind=='BLOCKED' then c.SetBlacklisted(t.a,true) elseif kind=='DOWNFIELD' then t.ar.Position=Vector3.new(0,6,65)
    elseif kind=='TOO_DEEP' then t.ar.Position=Vector3.new(0,6,90) elseif kind=='QB_PAST' then Mock.qroot.Position=Vector3.new(0,6,65) end
    check(not c.SelectScreen(kind=='ENEMY' and t.db or t.a),'invalid screen selection refused: '..kind)
    check(c.Stop(kind),'invalid selection cleanup '..kind)
end
t=setup();c=t.run();t.steps();check(c.SelectScreen(t.a),'final-check screen armed')
local changed=false;t.options.duringSolve=function()
    if not changed and c.GetReport():find('RELEASE_PREPARED|true',1,true) then changed=true;t.ar.Position=Vector3.new(0,6,65) end
end
t.steps();check(changed and #t.requests==0,'screen receiver crossing LOS inside final solve cancels packet')
check(c.Stop('FINAL'),'screen final-check cleanup')
-- A selected screen is permission to evaluate, not permission to throw through a defender.
t=setup();t.dr.Position=t.ar.Position;c=t.run();t.steps();check(c.SelectScreen(t.a),'covered screen can be selected')
t.steps();check(#t.requests==0,'covered stationary screen is not forced')
check(c.Stop('COVERED'),'covered screen cleanup')
-- Lifecycle invalidation while the selected player remains covered.
for _,kind in ipairs({'AUTO_OFF','THROW_OFF','BETWEEN_PLAYS','TEAM','QB_RESPAWN','TARGET_RESPAWN','CROSS_LOS','LINE_CHANGE','BALL_LOST','BLACKLIST','STOP'}) do
    t=setup();t.dr.Position=t.ar.Position;c=t.run();t.steps();check(c.SelectScreen(t.a),'lifecycle screen armed: '..kind)
    if kind=='AUTO_OFF' then c.SetAuto(false) elseif kind=='THROW_OFF' then c.SetThrow(false)
    elseif kind=='BETWEEN_PLAYS' then t.state.Status.Value='BetweenPlays' elseif kind=='TEAM' then t.a.Team=Mock.other
    elseif kind=='QB_RESPAWN' then t.me.Character=t.b.Character elseif kind=='TARGET_RESPAWN' then t.a.Character=t.b.Character
    elseif kind=='CROSS_LOS' then t.ar.Position=Vector3.new(0,6,69)
    elseif kind=='LINE_CHANGE' then t.blue.Position=t.blue.Position+Vector3.new(0,0,-4);t.yellow.Position=t.yellow.Position+Vector3.new(0,0,-4)
    elseif kind=='BALL_LOST' then t.tool.Parent=nil elseif kind=='BLACKLIST' then c.SetBlacklisted(t.a,true)
    else c.Stop('STOP') end
    t.steps(4);check(not c.league.screen and #t.requests==0,'selection invalidated without stale throw: '..kind)
    check(c.Stop(kind),'lifecycle cleanup '..kind)
end
-- New UI actions also obey stop-and-preserve when a real action errors.
for _,kind in ipairs({'SCREEN_UI','PROFILE_UI'}) do
    t=setup();c=t.run();t.steps();ui=t.ui()
    if kind=='SCREEN_UI' then
        c.SelectScreen=function() error('Injected screen selection failure') end
        ui:FindFirstChild('Screen').Activated:Fire();ui:FindFirstChild('ReceiverList'):FindFirstChild('Receiver1').Activated:Fire()
    else
        c.SetProfile=function() error('Injected profile selection failure') end
        ui:FindFirstChild('PlayProfile').Activated:Fire()
    end
    check(c.IsStopped and c.GetReport():find('STOP_REASON|LEAGUE_UI_ERROR',1,true),'UI action error stops and preserves: '..kind)
    check(c.Stop(kind),'UI error cleanup '..kind)
end
t=setup();c=t.run();local cancel=c.receiverFilter.cancel;c.receiverFilter.cancel=function() return false end
check(not c.SetProfile('CASUAL','USER') and c.IsStopped,'failed profile-worker cleanup stops instead of continuing with mixed owners')
check(c.GetReport():find('STOP_REASON|PROFILE_CLEANUP_FAILED',1,true),'cleanup failure is explicit in report')
c.receiverFilter.cancel=cancel;check(c.Stop('RECOVER_CLEANUP'),'cleanup can confirm after cancellation becomes available')
print('FF3 league profile/screen checks passed:',checks,'(mocked; VIP layout and real screen catches unverified)')
