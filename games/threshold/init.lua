-- Threshold opt-in mobile menu. Gameplay implementations remain separate.
-- Only resume.lua queues the public loader; perk spending never resumes.
local context = ...
assert(type(context) == 'table', 'THRESHOLD_CONTEXT_REQUIRED')
local VERSION, KEY = 'PELICAN_THRESHOLD_V1', '__PELICAN_THRESHOLD_MENU_V1'
local LOBBY, CHASE = 78453398695059, 129085487311457
local env = type(getgenv) == 'function' and getgenv() or _G
local ctl = {Version = VERSION}
local stopped, clean, busy = false, false, false
local gui, status, resume, deferred, panel
local connections, slots, events, reports, cache = {}, {}, {}, {}, {}
local options = context.ThresholdOptions or {}
local copyResult, lastStatus = 'NOT_REQUESTED', 'Preparing menu'
local definitions = {
    farm = {Path = 'games/threshold/farm.lua', Version = 'PELICAN_THRESHOLD_FARM_V6_1_ADAPTER'},
    navigator = {Path = 'games/threshold/navigator.lua', Version = 'PELICAN_THRESHOLD_NAV_V3_ADAPTER'},
    ['perks-fast'] = {Path = 'games/threshold/roller_fast.lua', Version = 'PELICAN_THRESHOLD_FAST_V1_ADAPTER'},
    ['perks-ui'] = {Path = 'games/threshold/roller_ui.lua', Version = 'PELICAN_THRESHOLD_UI_V6_2_ADAPTER'},
}
local buttons = {}
local function note(kind, detail)
    events[#events + 1] = kind .. '|' .. tostring(detail or ''):sub(1, 500)
    if #events > 36 then table.remove(events, 1) end
end
local function cancelled() return stopped or context.IsCancelled() end
local function setStatus(text)
    lastStatus = text
    if status then pcall(function() status.Text = text end) end
end
local function remember(name, controller)
    if not controller or type(controller.GetReport) ~= 'function' then return end
    local ok, value = pcall(controller.GetReport)
    if ok and type(value) == 'string' then reports[name] = value else note('REPORT_ERROR', name) end
end
function ctl.GetReport()
    for name, slot in pairs(slots) do remember(name, slot.Controller) end
    local rows = {'PELICAN_THRESHOLD_REPORT', 'VERSION|' .. VERSION,
        'PLACE_ID|' .. tostring(game.PlaceId), 'GAME_ID_RUNTIME_UNVERIFIED|' .. tostring(game.GameId),
        'STOPPED|' .. tostring(stopped), 'CLEANUP_CONFIRMED|' .. tostring(clean),
        'STATUS|' .. lastStatus, 'COPY_RESULT|' .. copyResult,
        'RESUME_OWNER|LOADER_SESSION_HELPER', 'PERK_AUTO_RESUME|DISABLED'}
    for _, event in ipairs(events) do rows[#rows + 1] = event end
    if resume then rows[#rows + 1] = resume.GetReport() end
    for _, name in ipairs({'farm', 'navigator', 'perks-fast', 'perks-ui'}) do
        if reports[name] then rows[#rows + 1] = name .. '_REPORT_BEGIN\n' .. reports[name] .. '\n' .. name .. '_REPORT_END' end
    end
    return table.concat(rows, '\n')
end
function ctl.CopyReport()
    local copy = env.setclipboard or setclipboard or env.toclipboard or toclipboard
    if type(copy) ~= 'function' then copyResult = 'CLIPBOARD_UNAVAILABLE'; return false end
    local ok, problem = pcall(copy, ctl.GetReport())
    copyResult = ok and 'CALL_SUCCEEDED_NO_READBACK' or 'COPY_FAILED'
    if not ok then note('COPY_ERROR', problem) end
    setStatus(ok and 'COPIED (API accepted)' or 'Copy failed; report retained')
    return ok
end
local function stopSlot(name, reason)
    local slot = slots[name]
    if not slot then return true end
    slot.Cancelled = true
    remember(name, slot.Controller)
    local confirmed = not slot.Initializing
    if slot.Controller and type(slot.Controller.Stop) == 'function' then
        local ok, value = pcall(slot.Controller.Stop, reason)
        if not ok or value ~= true then confirmed = false; note('CLEANUP_PENDING', name .. ':' .. tostring(value)) end
        remember(name, slot.Controller)
    elseif not slot.Initializing and #slot.Rollbacks == 0 then
        confirmed = slot.NoEffects == true
    end
    local pending = {}
    for index = #slot.Rollbacks, 1, -1 do
        local callback = slot.Rollbacks[index]
        local ok, value = pcall(callback, reason)
        if not ok or value ~= true then pending[#pending + 1] = callback; confirmed = false end
    end
    slot.Rollbacks = {}
    for index = #pending, 1, -1 do slot.Rollbacks[#slot.Rollbacks + 1] = pending[index] end
    if confirmed then slots[name] = nil end
    return confirmed
end
local function removeUI()
    local pending = {}
    for _, connection in ipairs(connections) do
        local ok = pcall(function() connection:Disconnect() end)
        if not ok then pending[#pending + 1] = connection end
    end
    connections = pending
    if gui then
        local ok = pcall(function() gui:Destroy() end)
        if ok then gui, status = nil, nil end
    end
    return #connections == 0 and gui == nil
end
function ctl.Stop(reason)
    stopped = true -- Cancellation precedes every cleanup call or possible yield.
    if clean then return true end
    reason = reason or 'USER_END'
    local confirmed = true
    -- Invalidate queued resumption before waiting on a gameplay or paid request.
    if resume then
        local ok, value = pcall(resume.Stop, reason)
        if not ok or value ~= true then confirmed = false; note('RESUME_STOP_PENDING', value) end
    end
    for _, name in ipairs({'perks-fast', 'perks-ui', 'farm', 'navigator'}) do
        if not stopSlot(name, reason) then confirmed = false end
    end
    if deferred and not busy and deferred ~= coroutine.running() then
        local ok = pcall(task.cancel, deferred)
        if not ok then confirmed = false else deferred = nil end
    end
    if busy then confirmed = false end
    if not confirmed then
        setStatus('STOPPED / cleanup pending')
        if panel then panel.Visible = true end
        return false
    end
    clean = true
    setStatus('STOPPED / cleanup confirmed')
    if reason == 'USER_END' or reason == 'KILL' then ctl.CopyReport() end
    if not removeUI() then clean = false; return false end
    if env[KEY] == ctl then env[KEY] = nil end
    return true
end
function ctl.IsStopped() return stopped end
context.RegisterCleanup(ctl.Stop)
assert(game.PlaceId == LOBBY or game.PlaceId == CHASE, 'THRESHOLD_UNSUPPORTED_PLACE')
assert(type(options) == 'table', 'THRESHOLD_OPTIONS_REQUIRED')
local previous = env[KEY]
if previous and previous ~= ctl then
    assert(type(previous.Stop) == 'function', 'THRESHOLD_OLDER_INSTANCE_UNMANAGED')
    local ok, result = pcall(previous.Stop, 'REEXECUTE')
    assert(ok and result == true, 'THRESHOLD_OLDER_CLEANUP_UNCONFIRMED')
end
env[KEY] = ctl
local function fetch(path)
    if cache[path] then return cache[path] end
    local source
    if context.SourceMode == 'BUNDLED' then
        source = context.Sources and context.Sources[path]
    else
        source = game:HttpGet(context.BaseUrl .. '/' .. context.Ref .. '/' .. path)
    end
    assert(not cancelled(), 'THRESHOLD_CANCELLED_DURING_FETCH')
    assert(type(source) == 'string' and source ~= '', 'THRESHOLD_SOURCE_MISSING:' .. path)
    local chunk, problem = loadstring(source, '@' .. path)
    assert(type(chunk) == 'function', problem or ('THRESHOLD_COMPILE_FAILED:' .. path))
    cache[path] = chunk
    return chunk
end
local function updateButtons()
    local selected = resume and resume.GetSelection() or {}
    for name, button in pairs(buttons) do
        local slot = slots[name]
        local mounted = slot ~= nil and not slot.Cancelled
        local armed = selected[name] == true
        local label = name == 'farm' and 'FARM' or name == 'navigator' and 'NAV / ESP' or name == 'perks-fast' and 'FAST ROLLS' or 'UI ROLLS'
        button.Text = label .. (mounted and ' · ON' or armed and ' · ARMED' or ' · OFF')
    end
end
local function invokeFeature(name)
    local def = assert(definitions[name], 'THRESHOLD_UNKNOWN_FEATURE')
    local slot = {Rollbacks = {}, Cancelled = false, Initializing = true, NoEffects = true}
    slots[name] = slot
    local featureContext = {}
    for key, value in pairs(context) do featureContext[key] = value end
    featureContext.Resume = resume
    featureContext.CentralKill, featureContext.CentralKillSwitch = gui ~= nil, gui ~= nil
    featureContext.IsCancelled = function() return slot.Cancelled or cancelled() end
    featureContext.RegisterCleanup = function(callback)
        assert(type(callback) == 'function', 'THRESHOLD_INVALID_CLEANUP')
        slot.NoEffects = false
        slot.Rollbacks[#slot.Rollbacks + 1] = callback
        return not featureContext.IsCancelled()
    end
    featureContext.ReportRuntimeError = function(problem)
        note('FEATURE_RUNTIME_ERROR', name .. ':' .. tostring(problem))
        slot.Cancelled = true
        if resume and (name == 'farm' or name == 'navigator') then resume.SetSelection(name, false) end
        stopSlot(name, 'RUNTIME_ERROR')
        setStatus(name .. ' stopped; tap to retry cleanup')
        updateButtons()
    end
    featureContext.OnFeatureStopped = function(_, reason)
        if slots[name] ~= slot then return end
        note('FEATURE_STOP', name .. ':' .. tostring(reason))
        remember(name, slot.Controller)
        if resume and (name == 'farm' or name == 'navigator') then resume.SetSelection(name, false) end
        slot.Cancelled = true
        setStatus(name .. ' stopped')
        updateButtons()
    end
    local ok, result = pcall(function()
        local chunk = fetch(def.Path)
        slot.NoEffects = false -- Invoking unknown source requires a positive rollback acknowledgment.
        return chunk(featureContext)
    end)
    slot.Initializing = false
    if type(result) == 'table' then slot.Controller = result end
    if not ok or type(result) ~= 'table' or result.Version ~= def.Version
        or type(result.Stop) ~= 'function' or type(result.GetReport) ~= 'function' then
        note('FEATURE_INIT_ERROR', name .. ':' .. tostring(result))
        if resume and (name == 'farm' or name == 'navigator') then resume.SetSelection(name, false) end
        stopSlot(name, 'INIT_ERROR')
        return false, name .. ' initialization failed; copy report'
    end
    if featureContext.IsCancelled() then stopSlot(name, 'CANCELLED_INITIALIZATION'); return false, 'Feature cancelled' end
    local halted = type(result.IsStopped) == 'function' and result.IsStopped() or result.IsStopped == true
    if halted then stopSlot(name, 'INIT_STOPPED'); return false, name .. ' already stopped' end
    note('FEATURE_MOUNTED', name .. '|gameplay_unverified')
    return true
end
local function startFeature(name, restoring)
    if cancelled() then return false, 'Threshold stopped' end
    if not definitions[name] then return false, 'Unknown feature' end
    if busy then return false, 'Feature transition in progress' end
    busy = true
    local ok, accepted, message = pcall(function()
        if slots[name] then
            if not stopSlot(name, 'USER_FEATURE_OFF') then return false, 'Cleanup pending; no replacement started' end
            if resume and (name == 'farm' or name == 'navigator') then resume.SetSelection(name, false) end
            return true, name .. ' off'
        end
        for other, slot in pairs(slots) do
            if slot.Cancelled then
                if not stopSlot(other, 'RETRY_CLEANUP') then return false, other .. ' cleanup pending' end
            end
        end
        if name == 'perks-fast' or name == 'perks-ui' then
            if game.PlaceId ~= LOBBY then return false, 'Perk rolls are lobby-only' end
            if slots.farm or slots['perks-fast'] or slots['perks-ui'] then return false, 'Stop farm / other roller first' end
        elseif name == 'farm' then
            if slots['perks-fast'] or slots['perks-ui'] then return false, 'Stop perk roller first' end
            if not resume or not resume.Enabled() then return false, 'Farm needs working files + teleport queue' end
            if slots.navigator and options.AllowFarmNavigator ~= true then return false, 'Stop NAV first; combined mode unverified' end
            local saved = resume.SetSelection('farm', true)
            if not saved then return false, 'Farm selection could not be saved' end
        elseif name == 'navigator' then
            if slots.farm and options.AllowFarmNavigator ~= true then return false, 'Stop FARM first; combined mode unverified' end
            if game.PlaceId == LOBBY then
                local selected = resume.GetSelection().navigator
                local saved = resume.SetSelection('navigator', restoring or not selected)
                return saved, saved and 'NAV armed for Chase; no lobby ESP' or 'NAV resume unavailable; launch in Chase'
            end
            resume.SetSelection('navigator', true)
        end
        local initialized, problem = invokeFeature(name)
        if not initialized then return false, problem end
        if name == 'perks-fast' or name == 'perks-ui' then return true, 'Roller ready; START spends cash' end
        return true, name == 'navigator' and (resume.Enabled() and 'NAV / ESP on' or 'NAV on · manual-only session') or 'Farm selected'
    end)
    busy = false
    if not ok then note('MENU_ACTION_ERROR', accepted); setStatus('Action failed; copy report'); return false, tostring(accepted) end
    setStatus(message or (accepted and 'Feature ready' or 'Feature blocked'))
    updateButtons()
    if accepted and panel then panel.Visible = false end
    return accepted, message
end
ctl.SelectFeature = startFeature
local players = game:GetService('Players')
local player = players.LocalPlayer
assert(player, 'THRESHOLD_PLAYER_NOT_READY')
local started = os.clock()
local parent = player:FindFirstChildOfClass('PlayerGui')
while not parent and not cancelled() and os.clock() - started < 10 do
    task.wait(.1); parent = player:FindFirstChildOfClass('PlayerGui')
end
assert(not cancelled() and parent, 'THRESHOLD_PLAYER_GUI_NOT_READY')
gui = Instance.new('ScreenGui')
gui.Name, gui.ResetOnSpawn, gui.DisplayOrder = 'PelicanThresholdMenu', false, 100010
gui.Parent = parent
local function button(text, x, y, width, height, parentObject)
    local object = Instance.new('TextButton')
    object.Text, object.Size, object.Position = text, UDim2.fromOffset(width, height), UDim2.fromOffset(x, y)
    object.Font, object.TextSize, object.BorderSizePixel = Enum.Font.Gotham, 11, 0
    object.BackgroundColor3, object.TextColor3 = Color3.fromRGB(24, 28, 34), Color3.new(1, 1, 1)
    object.Parent = parentObject or gui
    return object
end
local title = button('THRESHOLD ▾', 5, 8, 138, 24)
panel = Instance.new('Frame')
panel.Name, panel.Size, panel.Position = 'Features', UDim2.fromOffset(182, 142), UDim2.fromOffset(5, 34)
panel.BorderSizePixel, panel.BackgroundColor3 = 0, Color3.fromRGB(24, 28, 34)
panel.Parent = gui
for index, name in ipairs({'farm', 'navigator', 'perks-fast', 'perks-ui'}) do
    local object = button(name, 3, 3 + (index - 1) * 25, 176, 23, panel)
    buttons[name] = object
    connections[#connections + 1] = object.Activated:Connect(function() startFeature(name) end)
end
local copy = button('COPY REPORT', 3, 104, 176, 23, panel)
status = Instance.new('TextLabel')
status.Text, status.Size, status.Position = 'Preparing session', UDim2.fromOffset(176, 28), UDim2.fromOffset(3, 130)
status.TextSize, status.TextWrapped, status.BackgroundTransparency = 10, true, 1
status.TextColor3, status.Parent = Color3.new(1, 1, 1), panel
panel.Size = UDim2.fromOffset(182, 161)
local kill = button('', 0, 0, 22, 22)
kill.Name, kill.AnchorPoint, kill.Position = 'Kill', Vector2.new(1, 0), UDim2.new(1, -6, 0, 7)
kill.BackgroundColor3 = Color3.fromRGB(228, 53, 62)
local corner = Instance.new('UICorner'); corner.CornerRadius, corner.Parent = UDim.new(1, 0), kill
connections[#connections + 1] = title.Activated:Connect(function() panel.Visible = not panel.Visible end)
connections[#connections + 1] = copy.Activated:Connect(ctl.CopyReport)
connections[#connections + 1] = kill.Activated:Connect(function()
    if type(context.RequestStop) == 'function' then context.RequestStop('USER_END') else ctl.Stop('USER_END') end
end)
-- Resume is a library initialized once. Initial menu construction spends nothing.
local resumeContext = {}
for key, value in pairs(context) do resumeContext[key] = value end
resumeContext.RegisterCleanup = function(callback)
    -- The menu owns the helper so individual feature teardown cannot stop it.
    context.RegisterCleanup(callback)
    return true
end
resume = fetch('games/threshold/resume.lua')(resumeContext, context.ThresholdResume)
assert(type(resume) == 'table' and type(resume.Stop) == 'function', 'THRESHOLD_RESUME_CONTROLLER_INVALID')
if cancelled() then ctl.Stop('CANCELLED_INITIALIZATION'); return ctl end
setStatus(resume.Enabled() and 'Choose a feature · session armed' or 'Manual menu · resume unavailable')
updateButtons()
local selected = resume.GetSelection()
if selected.farm or selected.navigator then
    deferred = task.defer(function()
        if not cancelled() and selected.farm then startFeature('farm', true) end
        if not cancelled() and selected.navigator and (not selected.farm or options.AllowFarmNavigator == true) then startFeature('navigator', true) end
        deferred = nil
    end)
end
note('MENU_READY', 'No newly selected feature automatically started; prior farm/nav selection only')
return ctl
