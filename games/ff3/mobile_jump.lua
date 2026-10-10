-- Opt-in local touch layout only. Keeps Roblox's native jump input handler.
-- No synthesized jumps, remotes, Yuna dependency, or Auto QB changes.
local KEY, VERSION = 'PELICAN_FF3_MOBILE_JUMP', 'PELICAN_FF3_MOBILE_JUMP_V1'
local env = type(getgenv)=='function' and getgenv() or _G
local old = env[KEY]
if old and (type(old.Stop)~='function' or old.Stop('REPLACED')~=true) then
    error('PELICAN: previous mobile jump cleanup failed')
end
local Players, Run = game:GetService('Players'), game:GetService('RunService')
local me = Players.LocalPlayer
if game.PlaceId~=82866880824588 or not me then error('PELICAN: mobile jump requires FF3 live') end
if not game:GetService('UserInputService').TouchEnabled then error('PELICAN: touch controls unavailable') end
local pg = me:FindFirstChildOfClass('PlayerGui')
if not pg then error('PELICAN: PlayerGui not ready') end

local c = {Version=VERSION, IsStopped=false}
local connections, buttonConnections = {}, {}
local button, gui, toggle, originalSize, originalPosition, appliedSize, appliedPosition
local busy, wide, clean = false, true, false
local state, reason, fatal = 'WAIT_JUMP_BUTTON', 'NONE', 'NONE'
local waitingSince, lastCheck = os.clock(), -math.huge
local function text(v) return tostring(v):gsub('[\r\n|]',' '):sub(1,240) end
function c.GetReport()
    return table.concat({VERSION,'STATE|'..state,'STOP_REASON|'..reason,'ERROR|'..fatal,
        'CLEANUP_CONFIRMED|'..tostring(clean),'WIDE|'..tostring(wide),
        'PATH|PlayerGui.TouchGui.TouchControlFrame.JumpButton',
        'LAYOUT|WIDTH_2X_LEFTWARD; HEIGHT_AND_RIGHT_EDGE_PRESERVED',
        'INPUT|EXISTING_NATIVE_HANDLER','RUNTIME_VALIDATION|UNVERIFIED_IN_ROBLOX'},'\n')
end
local function save()
    env.PELICAN_FF3_MOBILE_JUMP_REPORT=c.GetReport()
    if type(writefile)=='function' then
        pcall(writefile,'PELICAN_FF3_MOBILE_JUMP_REPORT.txt',c.GetReport())
    end
end
local function disconnect(list)
    local remaining={}
    for _,v in ipairs(list) do
        local ok=pcall(function() v:Disconnect() end)
        if not ok then remaining[#remaining+1]=v end
    end
    return remaining
end
local function releaseButton()
    busy=true
    buttonConnections=disconnect(buttonConnections)
    local ok,err=pcall(function()
        if button and button.Parent then
            -- Restore only properties still owned by this helper. Preserve a
            -- subsequent layout write if another owner has already changed it.
            if button.Size==appliedSize then button.Size=originalSize end
            if button.Position==appliedPosition then button.Position=originalPosition end
        end
    end)
    busy=false
    if ok then button=nil end
    return ok and #buttonConnections==0,err
end
function c.Stop(why)
    if clean then return true end
    if not c.IsStopped then reason=text(why or 'USER_END') end
    c.IsStopped=true; state='STOPPED'
    connections=disconnect(connections)
    local restored,err=releaseButton()
    if not restored then fatal=text(err or 'BUTTON_LISTENER_CLEANUP_FAILED') end
    if gui then
        local ok=pcall(function() gui:Destroy() end)
        if ok then gui=nil end
    end
    clean=restored and #connections==0 and gui==nil
    save()
    if clean and env[KEY]==c then env[KEY]=nil end
    return clean
end
local function guarded(fn)
    return function(...)
        if c.IsStopped or busy then return end
        local ok,err=pcall(fn,...)
        if not ok then
            fatal=text(err); c.Stop('RUNTIME_ERROR')
            warn('PELICAN mobile jump stopped: '..fatal)
        end
    end
end
local function connect(list,signal,fn)
    list[#list+1]=signal:Connect(guarded(fn))
end
local function apply()
    if not button then return end
    -- UDim arithmetic keeps the original right edge fixed for every anchor and
    -- parent size, including scale-based layouts and orientation changes.
    local s,p=originalSize,originalPosition
    local extra=wide and 1 or 0
    local left=1-button.AnchorPoint.X
    appliedSize=UDim2.new(s.X.Scale*(1+extra),s.X.Offset*(1+extra),s.Y.Scale,s.Y.Offset)
    appliedPosition=UDim2.new(p.X.Scale-s.X.Scale*extra*left,
        p.X.Offset-s.X.Offset*extra*left,p.Y.Scale,p.Y.Offset)
    busy=true
    button.Size=appliedSize; button.Position=appliedPosition
    busy=false
    state=wide and 'JUMP_WIDE' or 'JUMP_ORIGINAL'
end
local function bind()
    if button then return end
    local touch=pg:FindFirstChild('TouchGui')
    local controls=touch and touch:FindFirstChild('TouchControlFrame')
    local found=controls and controls:FindFirstChild('JumpButton')
    if not found then return end
    if not found:IsA('GuiButton') then error('JumpButton is not a native GuiButton') end
    for _,v in ipairs(found:GetChildren()) do
        if v:IsA('UIAspectRatioConstraint') or v:IsA('UISizeConstraint') then
            error('JumpButton has a sizing constraint; layout not modified')
        end
    end
    button=found; originalSize=button.Size; originalPosition=button.Position
    connect(buttonConnections,button:GetPropertyChangedSignal('Size'),function()
        if button.Size~=appliedSize then originalSize=button.Size; apply() end
    end)
    connect(buttonConnections,button:GetPropertyChangedSignal('Position'),function()
        if button.Position~=appliedPosition then originalPosition=button.Position; apply() end
    end)
    connect(buttonConnections,button:GetPropertyChangedSignal('AnchorPoint'),apply)
    connect(buttonConnections,button.AncestryChanged,function()
        if not button:IsDescendantOf(pg) then
            local ok,err=releaseButton(); if not ok then error(err or 'Jump cleanup failed') end
            waitingSince=os.clock(); state='WAIT_JUMP_BUTTON'
        end
    end)
    apply(); save()
end
local function start()
    gui=Instance.new('ScreenGui'); gui.Name=VERSION; gui.ResetOnSpawn=false
    gui.DisplayOrder=1000; gui.Parent=pg
    local function control(label,x,width)
        local b=Instance.new('TextButton'); b.Size=UDim2.fromOffset(width,22)
        b.Position=UDim2.new(1,x,0,34); b.Text=label; b.TextSize=10
        b.BackgroundColor3=Color3.fromRGB(28,37,34); b.BackgroundTransparency=.2
        b.TextColor3=Color3.new(1,1,1); b.Parent=gui; return b
    end
    toggle=control('JUMP x2',-96,68)
    local kill=control('X',-26,22); kill.BackgroundColor3=Color3.fromRGB(195,40,40)
    connect(connections,toggle.Activated,function()
        wide=not wide; apply(); toggle.Text=wide and 'JUMP x2' or 'JUMP x1'; save()
    end)
    connect(connections,kill.Activated,function() c.Stop('USER_END') end)
    if me.OnTeleport then connect(connections,me.OnTeleport,function() c.Stop('TELEPORT') end) end
    connect(connections,Run.Heartbeat,function()
        if button or os.clock()-lastCheck<.25 then return end
        lastCheck=os.clock(); bind()
        if not button and os.clock()-waitingSince>=10 then
            fatal='Standard JumpButton not found within 10 seconds'
            c.Stop('JUMP_BUTTON_NOT_FOUND'); warn('PELICAN mobile jump stopped: '..fatal)
        end
    end)
    bind()
end
env[KEY]=c
local ok,err=pcall(start)
if not ok then fatal=text(err); c.Stop('STARTUP_ERROR'); error('PELICAN mobile jump stopped: '..fatal) end
return c
