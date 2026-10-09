-- Maintained adapter; immutable originals and provenance remain in archive/threshold-context.
local context = ... or {}
assert(type(context) == "table", "Threshold roller requires a lifecycle context")
local MODE = "ui"
local VERSION = "PELICAN_THRESHOLD_UI_V6_2_ADAPTER"
local KEY = "__PELICAN_GODSPEED_AUTOROLL"
local ENV = (getgenv and getgenv()) or _G
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
assert(game.PlaceId == 78453398695059, "Threshold rollers are lobby-only (observed PlaceId)")
assert(LP, "LocalPlayer is not ready")
local PG = LP:FindFirstChild("PlayerGui")
assert(PG, "PlayerGui is not ready")
local old = ENV[KEY]
if old then
    local stop = old.Stop or old.shutdown
    assert(type(stop) == "function", "Older roller has no safe shutdown; restart Roblox before rolling")
    local ok, confirmed = pcall(stop, "replaced")
    assert(ok and confirmed == true, "Older roller has not confirmed shutdown")
end
for _, otherKey in ipairs({ "__PELICAN_FAST_GODSPEED", "__PELICAN_THRESHOLD_FARM_V6_1",
    "__PELICAN_THRESHOLD_FARM_V6", "__PELICAN_THRESHOLD_FARM_V5_7", "__PELICAN_THRESHOLD_FARM_V5_6",
    "__PELICAN_THRESHOLD_FARM_V5_5", "__PELICAN_THRESHOLD_FARM_V5_4", "__PELICAN_THRESHOLD_FARM_V5_3",
    "__PELICAN_THRESHOLD_FARM_V5_2", "__PELICAN_THRESHOLD_FARM_V5_1", "__PELICAN_THRESHOLD_FARM_V5",
    "__PELICAN_THRESHOLD_RUN_V3_1", "__PELICAN_THRESHOLD_SCROW_RUN_V1", "__PELICAN_THRESHOLD_RUN_V3", "__PELICAN_THRESHOLD_RUN_V2" }) do
    local other = ENV[otherKey]
    if other then
        local ok, stopped = false, false
        if type(other.IsStopped) == "function" then ok, stopped = pcall(other.IsStopped) end
        assert(ok and stopped == true, "Another farm/roller exists; stop it or restart Roblox before rolling")
    end
end
-- Shared by both maintained adapters. Uncertain transactions must never be retried automatically.
local guard = ENV.__PELICAN_THRESHOLD_ROLL_GUARD
if type(guard) ~= "table" then
    guard = { Locked = ENV.__PELICAN_GODSPEED_LOCK == true, InFlight = false, Uncertain = false }
    ENV.__PELICAN_THRESHOLD_ROLL_GUARD = guard
end
guard.Locked = guard.Locked == true or ENV.__PELICAN_GODSPEED_LOCK == true
assert(not guard.Owner and not guard.InFlight, "A different roller is still mounted or its request is in flight")
local S = { active = false, locked = guard.Locked == true, inFlight = false,
    stopped = false, generation = 0, state = "IDLE", rolls = 0, attempts = 0,
    spent = 0, budget = 10, lastResult = "-", reason = "Tap START to authorize rolling",
    connections = {}, gui = nil, notified = false, workers = 0 }
local C = { Version = VERSION }
local Start, Info, Budget
local finishStop, refresh
local function cancelled()
    return type(context.IsCancelled) == "function" and context.IsCancelled() == true
end
local function norm(v)
    return string.lower(tostring(v or "")):gsub("[%s_%-%p]", "")
end
local function godspeed(v) return type(v) == "string" and norm(v) == "godspeed" end
local function finiteNumber(v)
    return type(v) == "number" and v == v and v ~= math.huge and v ~= -math.huge and v >= 0 and v % 1 == 0
end
local function snapshot()
    return { cash = LP:GetAttribute("Cash"), rolls = LP:GetAttribute("PerkRolls"), perk = LP:GetAttribute("TitlePerk") }
end
local function report()
    return table.concat({ VERSION, "mode=" .. MODE, "state=" .. S.state,
        "reason=" .. tostring(S.reason), "slot=3 observed_cost=400",
        "budget_rolls=" .. S.budget .. " maximum_nominal_spend=" .. S.budget * 400,
        "attempts=" .. S.attempts .. " confirmed_rolls=" .. S.rolls .. " confirmed_spend=" .. S.spent,
        "in_flight=" .. tostring(S.inFlight) .. " uncertain=" .. tostring(guard.Uncertain),
        "target_locked=" .. tostring(guard.Locked) .. " last_result=" .. tostring(S.lastResult),
        "TitlePerk=" .. tostring(LP:GetAttribute("TitlePerk")),
        "Live Roblox integration remains unverified; STOP cannot unsend a paid request." }, "\n")
end
local function notifyStopped()
    if S.notified or not S.stopped or S.inFlight or S.workers > 0 or #S.connections > 0 or S.gui then return end
    S.notified = true
    if type(context.OnFeatureStopped) == "function" then pcall(context.OnFeatureStopped, "perks-ui", S.reason) end
end
local function disconnect()
    local retained = {}
    for _, connection in ipairs(S.connections) do
        local ok = pcall(function() connection:Disconnect() end)
        if not ok then retained[#retained + 1] = connection end
    end
    S.connections = retained
end
function C.Stop(reason)
    S.stopped = true
    S.active = false
    S.generation = S.generation + 1
    S.reason = tostring(reason or "Stopped by user")
    if not S.locked then S.state = S.inFlight and "STOP_PENDING_REQUEST" or "STOPPED" end
    disconnect()
    if S.gui then
        local ok = pcall(function() S.gui:Destroy() end)
        if ok then S.gui = nil end
    end
    if not S.inFlight and S.workers == 0 and #S.connections == 0 and not S.gui then
        if guard.Owner == C then guard.Owner = nil end
        if ENV[KEY] == C then ENV[KEY] = nil end
        notifyStopped()
        return true
    end
    return false
end
function C.IsStopped() return S.stopped and not S.inFlight and S.workers == 0 and #S.connections == 0 and S.gui == nil end
function C.GetReport() return report() end
-- Registration precedes globals, GUI, listeners and task side effects.
if type(context.RegisterCleanup) == "function" then context.RegisterCleanup(C.Stop) end
if cancelled() then C.Stop("Cancelled before startup"); return C end
ENV[KEY] = C
-- Compatibility aliases are explicit controllers, never a GUI-only singleton.
C.shutdown = C.Stop
C.active = false
C.__ThresholdAdapter = true
C._Guard = guard
-- _Guard is shared lifecycle state, not a remote API or spending override.
guard.Owner = C
refresh = function()
    if S.stopped or not S.gui or not Info or not Info.Parent then return end
    local snap = snapshot()
    Info.Text = S.state .. " • " .. tostring(snap.perk or "unknown") ..
        "\n$400 observed/roll • cash $" .. tostring(snap.cash) ..
        "\nRolls " .. S.rolls .. "/" .. S.budget .. " • spent $" .. S.spent ..
        "\n" .. tostring(S.reason)
    Start.Text = S.locked and "LOCKED" or (guard.Uncertain and "UNCERTAIN" or (S.active and "STOP" or "START"))
    Start.Active = not S.locked and not guard.Uncertain
    pcall(function() Start.Interactable = Start.Active end)
end
local function lockTarget(reason)
    S.active = false
    S.locked = true
    S.state = "LOCKED_GODSPEED"
    S.reason = tostring(reason)
    guard.Locked = true
    ENV.__PELICAN_GODSPEED_LOCK = true
    -- Do not clear InFlight: this observation cannot unsend the request.
    refresh()
end
local function checkTarget(reason)
    if S.locked or guard.Locked or ENV.__PELICAN_GODSPEED_LOCK == true then lockTarget(reason or "Previously verified Godspeed"); return true end
    if godspeed(LP:GetAttribute("TitlePerk")) then lockTarget(reason or "Authoritative TitlePerk"); return true end
    return false
end
local function fail(reason, uncertain)
    S.active = false
    S.reason = tostring(reason)
    if uncertain then guard.Uncertain = true end
    if not S.locked then S.state = uncertain and "UNCERTAIN_NO_RETRY" or "PAUSED" end
    refresh()
end
finishStop = function()
    S.inFlight = false
    guard.InFlight = false
    if S.stopped then C.Stop(S.reason) else refresh() end
end
local function connect(signal, callback)
    local connection = signal:Connect(function(...)
        if S.stopped or guard.Owner ~= C or cancelled() then return end
        callback(...)
    end)
    S.connections[#S.connections + 1] = connection
    return connection
end
local function live(generation)
    return not S.stopped and S.active and not S.locked and not guard.Locked and not guard.Uncertain
        and S.generation == generation and guard.Owner == C and not cancelled()
end
local function preflight()
    if checkTarget("Before request: TitlePerk/terminal lock") then return nil end
    if guard.Uncertain or S.inFlight or guard.InFlight then fail("Previous request is pending or uncertain", false); return nil end
    if game.PlaceId ~= 78453398695059 then fail("Left observed Threshold lobby", false); return nil end
    local snap = snapshot()
    if not finiteNumber(snap.cash) or not finiteNumber(snap.rolls) or type(snap.perk) ~= "string" or snap.perk == "" then
        fail("Cash, PerkRolls or TitlePerk is unavailable", false); return nil
    end
    if guard.Last and (snap.cash ~= guard.Last.cash or snap.rolls ~= guard.Last.rolls or norm(snap.perk) ~= norm(guard.Last.perk)) then
        fail("Attributes have not reconciled with last acknowledged roll", false); return nil
    end
    if snap.cash < 400 then fail("Not enough cash for observed $400 cost", false); return nil end
    if S.rolls >= S.budget then fail("Authorized budget complete; tap START for a new budget", false); return nil end
    return snap
end
local function buildUI()
    local parent = PG
    if type(gethui) == "function" then local ok, value = pcall(gethui); if ok and value then parent = value end end
    local gui = Instance.new("ScreenGui")
    S.gui = gui
    gui.Name = MODE == "fast" and "PelicanGodspeedFastRoller" or "PelicanGodspeedRoller"
    gui.ResetOnSpawn = false
    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(224, 140)
    frame.AnchorPoint = Vector2.new(0.5, 0)
    frame.Position = UDim2.new(0.5, 0, 0, 64)
    frame.BackgroundColor3 = Color3.fromRGB(17, 17, 20)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    local title = Instance.new("TextLabel")
    title.Size = UDim2.fromOffset(198, 18)
    title.Position = UDim2.fromOffset(6, 4)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Text = MODE == "fast" and "GODSPEED • DIRECT" or "GODSPEED • GAME UI"
    title.Parent = frame
    Info = Instance.new("TextLabel")
    Info.Size = UDim2.fromOffset(212, 70)
    Info.Position = UDim2.fromOffset(6, 24)
    Info.BackgroundTransparency = 1
    Info.TextColor3 = Color3.fromRGB(225, 225, 225)
    Info.Font = Enum.Font.Gotham
    Info.TextSize = 10
    Info.TextWrapped = true
    Info.TextXAlignment = Enum.TextXAlignment.Left
    Info.TextYAlignment = Enum.TextYAlignment.Top
    Info.Parent = frame
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromOffset(85, 18)
    label.Position = UDim2.fromOffset(6, 96)
    label.BackgroundTransparency = 1
    label.Text = "Max rolls ($400 each)"
    label.TextSize = 9
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Parent = frame
    Budget = Instance.new("TextBox")
    Budget.Name = "RollBudget"
    Budget.Size = UDim2.fromOffset(40, 25)
    Budget.Position = UDim2.fromOffset(88, 98)
    Budget.Text = "10"
    Budget.ClearTextOnFocus = false
    Budget.TextSize = 12
    Budget.Parent = frame
    Start = Instance.new("TextButton")
    Start.Name = "StartRoller"
    Start.Size = UDim2.fromOffset(80, 25)
    Start.Position = UDim2.fromOffset(134, 98)
    Start.BackgroundColor3 = Color3.fromRGB(46, 125, 171)
    Start.TextColor3 = Color3.new(1, 1, 1)
    Start.TextSize = 12
    Start.Text = "START"
    Start.Parent = frame
    local close = Instance.new("TextButton")
    close.Name = "CloseRoller"
    close.AnchorPoint = Vector2.new(1, 0)
    close.Position = UDim2.new(1, -4, 0, 2)
    close.Size = UDim2.fromOffset(18, 18)
    close.BackgroundColor3 = Color3.fromRGB(205, 45, 45)
    close.Text = "×"
    close.TextColor3 = Color3.new(1, 1, 1)
    close.Parent = frame
    local copy = Instance.new("TextButton")
    copy.Name = "CopyRollerReport"
    copy.Position = UDim2.fromOffset(6, 120)
    copy.Size = UDim2.fromOffset(120, 17)
    copy.Text = "COPY REPORT"
    copy.TextSize = 9
    copy.Parent = frame
    connect(close.Activated, function() C.Stop("Closed by user") end)
    connect(copy.Activated, function()
        local clipboard = setclipboard or toclipboard
        if type(clipboard) ~= "function" then copy.Text = "Clipboard unavailable"; return end
        local ok = pcall(clipboard, report())
        copy.Text = ok and "COPIED ✓" or "Copy failed"
    end)
    gui.Parent = parent
end
buildUI()
for _, attribute in ipairs({ "TitlePerk", "PerkRolls", "Cash" }) do
    connect(LP:GetAttributeChangedSignal(attribute), function()
        if not checkTarget("Authoritative attribute update") then refresh() end
    end)
end
-- Preserved UI-v6.2 path: invoke the game's one live MouseButton1Click handler.
-- This adapter does not InvokeServer or inspect odds/background perk-list text.
local function objectVisible(object)
    if not object or not object:IsA("GuiObject") or object.Visible == false then return false end
    local node = object.Parent
    while node and node ~= PG do
        if node:IsA("GuiObject") and node.Visible == false then return false end
        if node:IsA("LayerCollector") and node.Enabled == false then return false end
        node = node.Parent
    end
    return node == PG
end
local function buttonText(button)
    local pieces = {}
    if button:IsA("TextButton") then pieces[#pieces + 1] = button.Text or "" end
    for _, descendant in ipairs(button:GetDescendants()) do
        if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then pieces[#pieces + 1] = descendant.Text or "" end
    end
    return norm(table.concat(pieces, " "))
end
local function findRollButton()
    local screen = PG:FindFirstChild("PerkScreen")
    if not screen then return nil end
    local holder = screen:FindFirstChild("Holder")
    local stage = holder and holder:FindFirstChild("Stage")
    local centre = stage and stage:FindFirstChild("CentreColumn")
    local exact = centre and centre:FindFirstChild("Roll")
    if exact and exact:IsA("GuiButton") then return exact end
    -- Preserve conservative v6.2 fallback, but reject ambiguous duplicate buttons.
    local found
    for _, descendant in ipairs(screen:GetDescendants()) do
        if descendant:IsA("GuiButton") and norm(descendant.Name) == "roll" and objectVisible(descendant) then
            if found then return nil end
            found = descendant
        end
    end
    return found
end
local function findConfirmation()
    local found
    for _, descendant in ipairs(PG:GetDescendants()) do
        if descendant:IsA("GuiButton") and objectVisible(descendant) and buttonText(descendant) == "rollanyway" then
            if found then return nil, "Multiple visible ROLL ANYWAY buttons; resolve manually" end
            found = descendant
        end
    end
    return found
end
local function confirmationContext(button)
    local node = button.Parent
    for _ = 1, 6 do
        if not node or node == PG or node.Name == "PerkScreen" or node:IsA("LayerCollector") then break end
        local roll, keep = false, false
        for _, descendant in ipairs(node:GetDescendants()) do
            if descendant:IsA("GuiButton") and objectVisible(descendant) then
                local text = buttonText(descendant)
                if text == "rollanyway" then roll = true elseif text == "keepit" then keep = true end
            end
        end
        if roll and keep then return node end
        node = node.Parent
    end
    return nil
end
local function modalRisk(button)
    local modal = confirmationContext(button)
    if not modal then return true, "Cannot identify the narrow confirmation modal; resolve manually" end
    for _, descendant in ipairs(modal:GetDescendants()) do
        if (descendant:IsA("TextLabel") or descendant:IsA("TextButton")) and objectVisible(descendant)
            and string.find(norm(descendant.Text), "godspeed", 1, true) then
            return true, "Confirmation mentions Godspeed; no confirmation sent"
        end
    end
    return false
end
local function liveHandlers(signal)
    if type(getconnections) ~= "function" then return nil end
    local ok, connections = pcall(getconnections, signal)
    if not ok or type(connections) ~= "table" then return nil end
    local count = 0
    for _, connection in ipairs(connections) do
        local disabled = false
        pcall(function() disabled = connection.Enabled == false or connection.Connected == false end)
        if not disabled then count = count + 1 end
    end
    return count
end
local function chooseHandler(button, isRoll)
    if type(firesignal) ~= "function" then return nil, "firesignal unavailable; nothing activated" end
    local mouse = liveHandlers(button.MouseButton1Click)
    if mouse and mouse > 0 then return button.MouseButton1Click end
    if not isRoll then
        local activated = liveHandlers(button.Activated)
        if activated and activated > 0 then return button.Activated end
    end
    return nil, "No detectable live " .. (isRoll and "Roll.MouseButton1Click" or "confirmation") .. " handler"
end
local function ready(button)
    if not button or not button.Parent or not objectVisible(button) or button.Active == false or button.Interactable == false then return false end
    local text = buttonText(button)
    return string.find(text, "rollperk", 1, true) ~= nil and string.find(text, "rolling", 1, true) == nil
end
local function waitReady(generation)
    local deadline, stable = os.clock() + 12, nil
    while live(generation) and os.clock() < deadline do
        if checkTarget("Waiting for ready button") then return nil end
        local confirm, ambiguous = findConfirmation()
        if confirm or ambiguous then fail(ambiguous or "Existing confirmation must be resolved manually before START", false); return nil end
        local button = findRollButton()
        if ready(button) then
            stable = stable or os.clock()
            if os.clock() - stable >= 0.45 then return button end
        else stable = nil end
        task.wait(0.05)
    end
    if live(generation) then fail("Roll button was not stably ready in 12s; no activation sent", false) end
    return nil
end
local function transactionSnapshot(before)
    local now = snapshot()
    if finiteNumber(now.cash) and finiteNumber(now.rolls) and type(now.perk) == "string" and now.perk ~= ""
        and now.cash == before.cash - 400 and now.rolls == before.rolls + 1 then return now end
    return nil
end
local function observeTransaction(before, generation)
    local deadline, settled, acknowledged, confirmationSent = os.clock() + 8, nil, nil, false
    -- Remain an owner until the result is reconciled even after STOP/GUI removal.
    while os.clock() < deadline do
        if checkTarget("Awaiting server-backed UI result") then return nil, true end
        local current = transactionSnapshot(before)
        if current then
            if not acknowledged or current.perk ~= acknowledged.perk then acknowledged, settled = current, os.clock() end
            if os.clock() - settled >= 0.55 then return acknowledged end
        else acknowledged, settled = nil, nil end
        local now = snapshot()
        -- A paid-state change can precede PerkRolls. Never confirm another modal
        -- during that unsettled interval just because full reconciliation is late.
        local unchanged = now.cash == before.cash and now.rolls == before.rolls and norm(now.perk) == norm(before.perk)
        if live(generation) and not confirmationSent and unchanged then
            local confirm, ambiguous = findConfirmation()
            if ambiguous then fail(ambiguous, true); return nil end
            if confirm then
                local risky, reason = modalRisk(confirm)
                if risky then fail(reason, true); return nil end
                if checkTarget("Before ROLL ANYWAY") or not live(generation) then return nil, S.locked end
                local handler, why = chooseHandler(confirm, false)
                if not handler then fail(why .. "; paid outcome unresolved", true); return nil end
                -- Mark before dispatch; failed signal dispatch may still have called a handler.
                confirmationSent = true
                S.state, S.reason = "CONFIRMING", "One ROLL ANYWAY activation for this owned roll"
                refresh()
                local ok, err = pcall(firesignal, handler)
                if not ok then fail("Confirmation error; no retry: " .. tostring(err), true); return nil end
            end
        end
        task.wait(0.04)
    end
    fail("No reconciled +1 roll/$400 result in 8s; spending outcome unresolved, no retry", true)
    return nil
end
local function rollOnce(generation)
    if not preflight() or not live(generation) then return false end
    S.state, S.reason = "WAITING_READY", "Open PERKS; waiting for stable ROLL PERK"
    refresh()
    local button = waitReady(generation)
    if not button or not live(generation) then return false end
    local handler, why = chooseHandler(button, true)
    if not handler then fail(why .. "; nothing activated", false); return false end
    local before = preflight()
    if not before or not live(generation) then return false end
    S.inFlight, guard.InFlight = true, true
    S.attempts = S.attempts + 1
    S.state, S.reason = "ONE_UI_ACTIVATION_PENDING", "Sent game handler; STOP prevents further confirmations/rolls"
    refresh()
    local ok, err = pcall(firesignal, handler)
    local accepted, target
    if ok then accepted, target = observeTransaction(before, generation)
    else
        target = checkTarget("After failed signal activation")
        if not target then fail("Activation error; spending outcome unknown, no retry: " .. tostring(err), true) end
    end
    if accepted then
        guard.Last = accepted
        S.rolls, S.spent, S.lastResult = S.rolls + 1, S.spent + 400, accepted.perk
    end
    finishStop()
    if target or not accepted or not live(generation) then return false end
    -- Preserve UI-v6.2 hard cooldown and visibly stable ready checks.
    S.state, S.reason = "COOLDOWN", "Acknowledged result; minimum 2.5s game-UI cooldown"
    refresh()
    local deadline = os.clock() + 2.5
    while live(generation) and os.clock() < deadline do
        if checkTarget("UI cooldown") then return false end
        task.wait(0.05)
    end
    return live(generation)
end
local function run(generation)
    while live(generation) do
        if not rollOnce(generation) then break end
        task.wait(0.12)
    end
    if not S.stopped and S.generation == generation then S.active = false; refresh() end
end
local function start()
    if S.stopped or cancelled() or guard.Owner ~= C then return end
    if S.active then
        S.active = false
        S.generation = S.generation + 1
        S.reason = S.inFlight and "Paused; sent activation still being reconciled" or "Paused by user"
        S.state = S.locked and "LOCKED_GODSPEED" or "PAUSED"
        refresh()
        return
    end
    if checkTarget("START preflight") or guard.Uncertain or S.inFlight or guard.InFlight then refresh(); return end
    if type(firesignal) ~= "function" or type(getconnections) ~= "function" then fail("firesignal/getconnections unavailable; no activation sent", false); return end
    local budget = tonumber(Budget.Text)
    if not finiteNumber(budget) or budget < 1 or budget > 250 then fail("Max rolls must be a whole number from 1 to 250", false); return end
    S.budget = S.rolls + budget
    if not preflight() then return end
    S.generation = S.generation + 1
    local generation = S.generation
    S.active, S.state = true, "ARMED"
    S.reason = "Authorized " .. budget .. " rolls; nominal maximum $" .. budget * 400
    refresh()
    S.workers = S.workers + 1
    task.spawn(function()
        local ok, err = pcall(run, generation)
        if not ok then
            fail("Worker error: " .. tostring(err), S.inFlight)
            finishStop()
            if type(context.ReportRuntimeError) == "function" then pcall(context.ReportRuntimeError, tostring(err)) end
        end
        S.workers = S.workers - 1
        if S.stopped or cancelled() then C.Stop(S.stopped and S.reason or "Lifecycle cancelled") end
    end)
end
connect(Start.Activated, start)
if not checkTarget("Startup: authoritative TitlePerk or preserved lock") then
    if guard.Uncertain then S.state, S.reason = "UNCERTAIN_NO_RETRY", "Previous spending outcome unresolved; rolling disabled"
    else S.reason = "Open PERKS; START authorizes at most 10 rolls / nominal $4,000" end
    refresh()
end
return C
