-- Adapter derived from archived v3 phasefix; original bytes stay in archive.
-- Only an explicit navigator selection loads this chunk. No movement/remotes.
local context = ...
if context == nil then context = {} end
assert(type(context) == "table", "NAV_CONTEXT_MUST_BE_TABLE")
local VERSION = "PELICAN_THRESHOLD_NAV_V3_ADAPTER"
local running, generation, cleanupConfirmed = true, 1, false
local connections, ownedTasks, ownedInstances = {}, {}, {}
local originalLighting, originalEffects, originalAtmospheres = {}, {}, {}
local Lighting, env
local stopReason, runtimeError, stopNotified = "RUNNING", "", false
local pathFailureCount, phaseRevision, lastPhase = 0, 0, "STARTING"
local cleanupFailures = {}
local controller = {Version = VERSION}
local shutdown

local function isActive()
    if not running then return false end
    if type(context.IsCancelled) == "function" then
        local ok, cancelled = pcall(context.IsCancelled)
        if not ok or cancelled then return false end
    end
    return true
end

local function ownNew(class)
    local instance = Instance.new(class)
    ownedInstances[instance] = true
    return instance
end

local function destroyOwned(instance)
    if not instance then return true end
    -- Destroying a GUI also destroys its descendants. Forget those child
    -- handles after success so repeated record/turn rebuilds stay bounded.
    local descendants
    local ok, problem = pcall(function()
        descendants = instance:GetDescendants()
        instance:Destroy()
    end)
    if ok then
        ownedInstances[instance] = nil
        for _, descendant in ipairs(descendants) do ownedInstances[descendant] = nil end
    else cleanupFailures[#cleanupFailures + 1] = tostring(problem) end
    return ok
end

local function safeDisconnect(connection)
    if not connection then return true end
    local ok, problem = pcall(function()
        connection:Disconnect()
        assert(connection.Connected == false, "NAV_LISTENER_STILL_CONNECTED")
    end)
    if ok then connections[connection] = nil else cleanupFailures[#cleanupFailures + 1] = tostring(problem) end
    return ok
end

local function runtimeFailure(problem)
    runtimeError = tostring(problem)
    shutdown("RUNTIME_ERROR")
    if type(context.ReportRuntimeError) == "function" then
        pcall(context.ReportRuntimeError, VERSION .. ": " .. runtimeError)
    end
end

local function connect(signal, fn)
    local expected = generation
    local connection = signal:Connect(function(...)
        if not isActive() or expected ~= generation then return end
        local ok, problem = pcall(fn, ...)
        if not ok then runtimeFailure(problem) end
    end)
    connections[connection] = true
    return connection
end

local function startTask(kind, delay, fn)
    local expected = generation
    local ticket = {}
    ownedTasks[ticket] = true
    local function invoke()
        if isActive() and expected == generation then
            local ok, problem = pcall(fn)
            ownedTasks[ticket] = nil
            if not ok then runtimeFailure(problem) end
        else
            ownedTasks[ticket] = nil
        end
    end
    if kind == "delay" then ticket.thread = task.delay(delay, invoke)
    elseif kind == "defer" then ticket.thread = task.defer(invoke)
    else ticket.thread = task.spawn(invoke) end
    return ticket
end
local function spawnOwned(fn) return startTask("spawn", nil, fn) end
local function deferOwned(fn) return startTask("defer", nil, fn) end
local function delayOwned(delay, fn) return startTask("delay", delay, fn) end

-- Defined before any GUI, listener, lighting write, or old-instance teardown.
shutdown = function(reason)
    if cleanupConfirmed then return true end
    running = false
    generation = generation + 1
    stopReason = tostring(reason or "STOP")
    cleanupFailures = {}
    for ticket in pairs(ownedTasks) do
        if ticket.thread == coroutine.running() then
            -- This callback cannot cancel itself; the invalid generation stops it
            -- before its next owned effect and its wrapper returns immediately.
            ownedTasks[ticket] = nil
        elseif ticket.thread and type(task.cancel) == "function" then
            local ok, problem = pcall(task.cancel, ticket.thread)
            if ok then ownedTasks[ticket] = nil else cleanupFailures[#cleanupFailures + 1] = tostring(problem) end
        end
    end
    for connection in pairs(connections) do safeDisconnect(connection) end
    for instance in pairs(ownedInstances) do destroyOwned(instance) end
    if Lighting then
        for property, value in pairs(originalLighting) do
            local ok, problem = pcall(function() Lighting[property] = value end)
            if ok then originalLighting[property] = nil else cleanupFailures[#cleanupFailures + 1] = tostring(problem) end
        end
        for effect, enabled in pairs(originalEffects) do
            local ok, problem = pcall(function() if effect.Parent then effect.Enabled = enabled end end)
            if ok then originalEffects[effect] = nil else cleanupFailures[#cleanupFailures + 1] = tostring(problem) end
        end
        for atmosphere, values in pairs(originalAtmospheres) do
            local ok, problem = pcall(function()
                if atmosphere.Parent then
                    atmosphere.Density, atmosphere.Haze, atmosphere.Glare = values.Density, values.Haze, values.Glare
                end
            end)
            if ok then originalAtmospheres[atmosphere] = nil else cleanupFailures[#cleanupFailures + 1] = tostring(problem) end
        end
    end
    cleanupConfirmed = next(ownedTasks) == nil and next(connections) == nil and next(ownedInstances) == nil
        and next(originalLighting) == nil and next(originalEffects) == nil and next(originalAtmospheres) == nil
    if cleanupConfirmed then
        if env and env.__PELICAN_THRESHOLD_ESP == controller then env.__PELICAN_THRESHOLD_ESP = nil end
        if not stopNotified and type(context.OnFeatureStopped) == "function" then
            stopNotified = true
            pcall(context.OnFeatureStopped, "navigator", stopReason)
        end
    end
    return cleanupConfirmed
end
controller.Stop, controller.Shutdown = shutdown, shutdown
controller.IsStopped = function() return cleanupConfirmed end
controller.GetReport = function()
    local taskCount, connectionCount, instanceCount = 0, 0, 0
    for _ in pairs(ownedTasks) do taskCount = taskCount + 1 end
    for _ in pairs(connections) do connectionCount = connectionCount + 1 end
    for _ in pairs(ownedInstances) do instanceCount = instanceCount + 1 end
    return table.concat({VERSION, "PROVENANCE|ARCHIVED_V3_SOURCE_ONLY", "STATE|" .. stopReason,
        "PLACE_ID|" .. tostring(game.PlaceId), "PHASE|" .. lastPhase,
        "CLEANUP_CONFIRMED|" .. tostring(cleanupConfirmed), "TASKS|" .. taskCount,
        "LISTENERS|" .. connectionCount, "INSTANCES|" .. instanceCount,
        "PATH_FAILURES|" .. pathFailureCount, "RUNTIME_ERROR|" .. runtimeError,
        "CLEANUP_FAILURES|" .. table.concat(cleanupFailures, ";")}, "\n")
end
if type(context.RegisterCleanup) == "function" then context.RegisterCleanup(shutdown) end
if not isActive() then shutdown("CANCELLED_INITIALIZATION"); return controller end
assert(game.PlaceId == 129085487311457, "NAV_REQUIRES_OBSERVED_CHASE_PLACE")

-- [PELICAN] Threshold Minimal Objective Navigator v3 + Fullbright
-- Known Threshold targets + generic objective-prompt detection.
-- v3: restores hidden-container key ESP using the same HasKey/SearchPrompt model
--     as the farm, and hard-scopes monsters/exits/objectives to the CURRENT phase.
--     Scrow papers remain indexed by DigitIndex with exact ReadPrompt routing.

local Players = game:GetService("Players")
Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local PathfindingService = game:GetService("PathfindingService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
env = (getgenv and getgenv()) or _G

local previous = env.__PELICAN_THRESHOLD_ESP
if previous then
    assert(type(previous.Shutdown) == "function", "NAV_PREVIOUS_HAS_NO_SHUTDOWN")
    local ok, result = pcall(previous.Shutdown, "REEXECUTE")
    assert(ok and (result == true or env.__PELICAN_THRESHOLD_ESP ~= previous), "NAV_PREVIOUS_CLEANUP_UNCONFIRMED")
end
assert(LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui"), "NAV_PLAYER_GUI_NOT_READY")

local CONFIG = {
    ScanInterval = 0.75,
    GenericScanInterval = 2.0,
    DistanceUpdateInterval = 0.10,
    MaxGenericDistance = 5000,
    ShowDecoyPaper = false,
    ShowExit = true,
    ShowGenericObjectives = true,
    Fullbright = true,

    -- Dynamic corridor guidance. This never moves the character; it only
    -- computes a walkable path and points at the next waypoint/turn.
    RouteGuidance = true,
    RouteRepathInterval = 0.65,
    RouteAdvanceDistance = 4.75,
    RouteOffPathDistance = 11,
    RouteAgentRadius = 1.6,
    RouteAgentHeight = 5,
    RouteWaypointSpacing = 3,
    RouteGoalOffsetRadius = 6,
    RouteTurnAngle = 28,
    ShowRouteTurnMarkers = true,
    RouteTurnMarkerActivationDistance = 40,
    ShowUnreadPaperDots = true,
    ShowHiddenKeyContainerDots = true,
    MaxMonsterIndicators = 3,
    MonsterVerticalBand = 85,
}

local COLORS = {
    Monster = Color3.fromRGB(255, 75, 75),
    KeyContainer = Color3.fromRGB(255, 170, 45),
    Key = Color3.fromRGB(255, 230, 70),
    CodePaper = Color3.fromRGB(80, 220, 255),
    Decoy = Color3.fromRGB(180, 135, 255),
    Exit = Color3.fromRGB(90, 255, 135),
    Generic = Color3.fromRGB(255, 255, 255),
    Nav = Color3.fromRGB(90, 210, 255),
}

local records = {}

-- Route state. Tap any ESP label to lock navigation to it; tap AUTO to release.
local navManualTarget = nil
local navTarget = nil
local navWaypoints = {}
local navWaypointIndex = 1
local navPathLength = 0
local navLastRepath = 0
local navLastRootPosition = nil
local navLastTargetPosition = nil
local navNeedsRepath = true
local navMarkers = {}
local navMarkerGuideIndex = nil
local navComputing = false
local navPathMode = "AUTO"

local function getGuiParent()
    if gethui then
        local ok, result = pcall(gethui)
        if ok and result then
            return result
        end
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local guiParent = getGuiParent()

local screenGui = ownNew("ScreenGui")
screenGui.Name = "PelicanThresholdObjectiveESP"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999

if syn and syn.protect_gui then
    pcall(syn.protect_gui, screenGui)
end

screenGui.Parent = guiParent

local visualFolder = ownNew("Folder")
visualFolder.Name = "__PelicanThresholdObjectiveESP"
visualFolder.Parent = Workspace

local status = ownNew("TextLabel")
status.Name = "Status"
status.AnchorPoint = Vector2.new(0.5, 0)
status.Position = UDim2.new(0.5, 0, 0, 8)
status.Size = UDim2.fromOffset(340, 24)
status.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
status.BackgroundTransparency = 0.25
status.BorderSizePixel = 0
status.Font = Enum.Font.GothamBold
status.TextSize = 13
status.TextColor3 = Color3.new(1, 1, 1)
status.TextStrokeTransparency = 0.65
status.Text = "PELICAN"
status.Visible = false
status.Parent = screenGui

local kill = ownNew("TextButton")
kill.Name = "Kill"
kill.AnchorPoint = Vector2.new(1, 0)
kill.Position = UDim2.new(1, -7, 0, 7)
kill.Size = UDim2.fromOffset(22, 22)
kill.BackgroundColor3 = Color3.fromRGB(210, 45, 45)
kill.BorderSizePixel = 0
kill.AutoButtonColor = true
kill.Font = Enum.Font.GothamBold
kill.TextSize = 16
kill.TextColor3 = Color3.new(1, 1, 1)
kill.Text = "×"
kill.Parent = screenGui
kill.Visible = context.CentralKill ~= true

-- Top-center navigation HUD. The arrow rotates toward the *next walkable
-- waypoint*, not straight through the wall toward the objective.
local navFrame = ownNew("Frame")
navFrame.Name = "RouteHUD"
navFrame.AnchorPoint = Vector2.new(0.5, 0)
navFrame.Position = UDim2.new(0.5, 0, 0, 10)
navFrame.Size = UDim2.fromOffset(260, 44)
navFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
navFrame.BackgroundTransparency = 0.20
navFrame.BorderSizePixel = 0
navFrame.Visible = CONFIG.RouteGuidance
navFrame.Parent = screenGui

local navArrow = ownNew("TextLabel")
navArrow.Name = "Arrow"
navArrow.Position = UDim2.fromOffset(4, 3)
navArrow.Size = UDim2.fromOffset(38, 38)
navArrow.BackgroundTransparency = 1
navArrow.Font = Enum.Font.GothamBlack
navArrow.Text = "▲"
navArrow.TextSize = 30
navArrow.TextColor3 = COLORS.Nav
navArrow.TextStrokeTransparency = 0.35
navArrow.Parent = navFrame

local navText = ownNew("TextLabel")
navText.Name = "Text"
navText.Position = UDim2.fromOffset(43, 3)
navText.Size = UDim2.fromOffset(163, 38)
navText.BackgroundTransparency = 1
navText.Font = Enum.Font.GothamBold
navText.TextSize = 11
navText.TextColor3 = Color3.new(1, 1, 1)
navText.TextStrokeTransparency = 0.6
navText.TextXAlignment = Enum.TextXAlignment.Left
navText.TextYAlignment = Enum.TextYAlignment.Center
navText.TextWrapped = true
navText.Text = "SCANNING..."
navText.Parent = navFrame

local navAuto = ownNew("TextButton")
navAuto.Name = "Auto"
navAuto.AnchorPoint = Vector2.new(1, 0.5)
navAuto.Position = UDim2.new(1, -5, 0.5, 0)
navAuto.Size = UDim2.fromOffset(46, 28)
navAuto.BackgroundColor3 = Color3.fromRGB(35, 115, 145)
navAuto.BorderSizePixel = 0
navAuto.Font = Enum.Font.GothamBold
navAuto.TextSize = 12
navAuto.TextColor3 = Color3.new(1, 1, 1)
navAuto.Text = "AUTO"
navAuto.Parent = navFrame

local function getCharacterRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- Threshold keeps both phases in Workspace at the same time. Presence alone is
-- therefore NOT proof that a phase is active. InMall is the authoritative Scrow
-- switch; otherwise an active ChaseWorld gate/InCase means the underground phase.
local function currentThresholdPhase()
    if not isActive() then return "other" end
    if LocalPlayer:GetAttribute("InMall") == true then
        return "mall"
    end

    local chaseWorld = Workspace:FindFirstChild("ChaseWorld")
    local gate = chaseWorld and chaseWorld:FindFirstChild("ExitGate")
    local runStarted = gate and gate:GetAttribute("RunStarted") == true
    if chaseWorld and (LocalPlayer:GetAttribute("InCase") == true or runStarted) then
        return "underground"
    end

    return "other"
end

local function isUnder(inst, root)
    return root ~= nil and inst ~= nil and (inst == root or inst:IsDescendantOf(root))
end

local function isInactiveThresholdPhaseInstance(inst)
    local phase = currentThresholdPhase()
    if not inst then return false end
    if phase == "other" then return true end

    local chaseWorld = Workspace:FindFirstChild("ChaseWorld")
    local mallCode = Workspace:FindFirstChild("MallCode")
    local mallExit = Workspace:FindFirstChild("MallExit")
    local scrow = Workspace:FindFirstChild("Scrow")

    if phase == "mall" then
        return isUnder(inst, chaseWorld)
    end

    -- Underground: suppress every known Scrow-phase root even though Roblox has
    -- already replicated it below the current map.
    return isUnder(inst, mallCode) or isUnder(inst, mallExit) or isUnder(inst, scrow)
end

local function firstBasePart(inst)
    if not inst or not inst.Parent then
        return nil
    end

    if inst:IsA("BasePart") then
        return inst
    end

    if inst:IsA("Attachment") then
        local p = inst.Parent
        if p and p:IsA("BasePart") then
            return p
        end
    end

    if inst:IsA("ProximityPrompt") then
        local p = inst.Parent
        if p and p:IsA("Attachment") then
            p = p.Parent
        end
        if p and p:IsA("BasePart") then
            return p
        end
    end

    if inst:IsA("Model") and inst.PrimaryPart then
        return inst.PrimaryPart
    end

    return inst:FindFirstChildWhichIsA("BasePart", true)
end


local function promptWorldPosition(prompt)
    if not prompt or not prompt.Parent then
        return nil
    end

    local parent = prompt.Parent
    if parent:IsA("Attachment") then
        return parent.WorldPosition
    elseif parent:IsA("BasePart") then
        return parent.Position
    elseif parent:IsA("Model") then
        return parent:GetPivot().Position
    end

    local part = firstBasePart(prompt)
    return part and part.Position or nil
end

local function highlightAdornee(inst)
    if not inst or not inst.Parent then
        return nil
    end
    if inst:IsA("Model") or inst:IsA("BasePart") then
        return inst
    end
    if inst:IsA("ProximityPrompt") then
        local ancestorModel = inst:FindFirstAncestorOfClass("Model")
        if ancestorModel then
            return ancestorModel
        end
        return firstBasePart(inst)
    end
    local model = inst:FindFirstChildWhichIsA("Model", true)
    if model then
        return model
    end
    return firstBasePart(inst)
end

local function destroyRecord(target)
    local rec = records[target]
    if not rec then
        return
    end
    if rec.billboard then
        destroyOwned(rec.billboard)
    end
    if rec.highlight then
        destroyOwned(rec.highlight)
    end
    if rec.dot then
        destroyOwned(rec.dot)
    end
    if rec.selectConnection then
        safeDisconnect(rec.selectConnection)
    end
    if navManualTarget == target then
        navManualTarget = nil
        navNeedsRepath = true
    end
    if navTarget == target then
        navNeedsRepath = true
    end
    records[target] = nil
end

local function ensureRecord(target, label, color, source, priority)
    if not isActive() or not target or not target.Parent then
        return nil
    end

    local anchor = firstBasePart(target)
    if not anchor then
        return nil
    end

    local exactPosition = target:IsA("ProximityPrompt") and promptWorldPosition(target) or nil
    local exactOffset = exactPosition and (exactPosition - anchor.Position) or Vector3.zero

    local rec = records[target]
    if rec then
        if priority and (rec.priority or 0) > priority then
            return rec
        end
        rec.label = label
        rec.color = color
        rec.source = source or rec.source
        rec.priority = priority or rec.priority
        rec.anchor = anchor
        if rec.billboard then
            rec.billboard.Adornee = anchor
            rec.billboard.StudsOffsetWorldSpace = exactOffset + Vector3.new(0, 2.7, 0)
        end
        if rec.text then
            rec.text.TextColor3 = color
        end
        if rec.highlight then
            rec.highlight.FillColor = color
            rec.highlight.OutlineColor = color
        end
        return rec
    end

    local billboard = ownNew("BillboardGui")
    billboard.Name = "ObjectiveESP"
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.MaxDistance = 100000
    billboard.Size = UDim2.fromOffset(155, 26)
    billboard.StudsOffsetWorldSpace = exactOffset + Vector3.new(0, 2.7, 0)
    billboard.Adornee = anchor
    billboard.Parent = screenGui

    local text = ownNew("TextButton")
    text.BackgroundColor3 = Color3.fromRGB(9, 9, 12)
    text.BackgroundTransparency = 0.30
    text.BorderSizePixel = 0
    text.Size = UDim2.fromScale(1, 1)
    text.Font = Enum.Font.GothamBold
    text.TextSize = 10
    text.TextColor3 = color
    text.TextStrokeTransparency = 0.45
    text.TextWrapped = true
    text.AutoButtonColor = false
    text.Active = true
    text.Text = label
    text.Parent = billboard
    billboard.Active = true

    local highlight = ownNew("Highlight")
    highlight.Name = "ObjectiveHighlight"
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = color
    highlight.FillTransparency = 0.78
    highlight.OutlineColor = color
    highlight.OutlineTransparency = 0
    highlight.Adornee = highlightAdornee(target)
    highlight.Parent = visualFolder

    rec = {
        target = target,
        anchor = anchor,
        label = label,
        color = color,
        source = source or "generic",
        priority = priority or 0,
        billboard = billboard,
        text = text,
        highlight = highlight,
    }

    rec.selectConnection = connect(text.Activated, function()
        if not isActive() then
            return
        end
        if navManualTarget == target then
            navManualTarget = nil
            navPathMode = "AUTO"
        else
            navManualTarget = target
            navPathMode = "LOCKED"
        end
        phaseRevision = phaseRevision + 1
        navNeedsRepath = true
    end)

    records[target] = rec
    return rec
end

local function ensurePaperDot(rec)
    if not rec or rec.dot or not rec.anchor or not rec.anchor.Parent then
        return rec and rec.dot or nil
    end

    local dot = ownNew("BillboardGui")
    dot.Name = "PaperLocationDot"
    dot.AlwaysOnTop = true
    dot.LightInfluence = 0
    dot.MaxDistance = 100000
    dot.Size = UDim2.fromOffset(10, 10)
    local exactPosition = rec.target and rec.target:IsA("ProximityPrompt") and promptWorldPosition(rec.target) or nil
    local offset = exactPosition and (exactPosition - rec.anchor.Position) or Vector3.zero
    dot.StudsOffsetWorldSpace = offset + Vector3.new(0, 1.35, 0)
    dot.Adornee = rec.anchor
    dot.Enabled = false
    dot.Parent = screenGui

    local point = ownNew("Frame")
    point.Size = UDim2.fromScale(1, 1)
    point.BackgroundColor3 = rec.color or COLORS.CodePaper
    point.BackgroundTransparency = 0.08
    point.BorderSizePixel = 0
    point.Parent = dot

    local corner = ownNew("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = point

    local stroke = ownNew("UIStroke")
    stroke.Thickness = 1
    stroke.Transparency = 0.15
    stroke.Color = Color3.new(1, 1, 1)
    stroke.Parent = point

    rec.dot = dot
    return dot
end

local function directChildUnder(root, inst)
    if not root or not inst or not inst:IsDescendantOf(root) then
        return nil
    end
    local cur = inst
    while cur and cur.Parent ~= root do
        cur = cur.Parent
    end
    if cur and cur.Parent == root then
        return cur
    end
    return nil
end

local function pathLower(inst)
    local ok, full = pcall(function()
        return inst:GetFullName()
    end)
    return string.lower(ok and full or inst.Name)
end

local function currentObjectiveCorpus()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then
        return ""
    end

    local pieces = {}
    local count = 0

    for _, obj in ipairs(pg:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            local txt = obj.Text
            if type(txt) == "string" and #txt >= 3 then
                local low = string.lower(txt)
                local path = pathLower(obj)
                local looksObjective =
                    string.find(path, "objective", 1, true) or
                    string.find(path, "task", 1, true) or
                    string.find(path, "chasemallcode", 1, true) or
                    string.find(low, "find ", 1, true) or
                    string.find(low, "unlock", 1, true) or
                    string.find(low, "password", 1, true) or
                    string.find(low, "exit", 1, true) or
                    string.find(low, "repair", 1, true) or
                    string.find(low, "collect", 1, true)

                if looksObjective then
                    count += 1
                    pieces[count] = low
                    if count >= 18 then
                        break
                    end
                end
            end
        end
    end

    return table.concat(pieces, " ")
end

local STOPWORDS = {
    ["find"] = true, ["the"] = true, ["and"] = true, ["your"] = true,
    ["with"] = true, ["from"] = true, ["this"] = true, ["that"] = true,
    ["into"] = true, ["then"] = true, ["found"] = true, ["open"] = true,
    ["make"] = true, ["noise"] = true, ["dont"] = true, ["don't"] = true,
}

local function objectiveTokens(corpus)
    local set = {}
    for word in string.gmatch(corpus, "[%a%d_]+") do
        word = string.lower(word)
        if #word >= 4 and not STOPWORDS[word] then
            set[word] = true
        end
    end
    return set
end

local GENERIC_KEYWORDS = {
    {"password", 6}, {"keypad", 6}, {"code", 5}, {"objective", 5},
    {"maintenance key", 7}, {"key", 4}, {"clue", 5}, {"paper", 4},
    {"note", 3}, {"exit", 5}, {"gate", 4}, {"unlock", 4},
    {"fuse", 5}, {"generator", 5}, {"breaker", 5}, {"repair", 4},
    {"lever", 4}, {"switch", 4}, {"power", 3}, {"collect", 3},
    {"insert", 3}, {"pickup", 3}, {"pick up", 3}, {"read", 3},
    {"valve", 3}, {"terminal", 4}, {"panel", 2}, {"escape", 5},
}

local function isKnownCovered(inst)
    -- Exact Threshold systems are owned by scanKnown, even while their phase is
    -- inactive. This stops the generic scanner from resurrecting the lower-map
    -- keypad, old ladder gate, Scrow, or completed clue records.
    local exactRoots = {}
    local function add(root) if root then table.insert(exactRoots, root) end end
    add(Workspace:FindFirstChild("MallCode"))
    add(Workspace:FindFirstChild("MallExit"))
    add(Workspace:FindFirstChild("Scrow"))
    local chaseWorld = Workspace:FindFirstChild("ChaseWorld")
    if chaseWorld then
        add(chaseWorld:FindFirstChild("ExitGate"))
        add(chaseWorld:FindFirstChild("KeySpawns"))
    end

    for _, root in ipairs(exactRoots) do
        if isUnder(inst, root) then
            return true
        end
    end

    for target, rec in pairs(records) do
        if rec.source == "known" and target and target.Parent then
            if inst == target or inst:IsDescendantOf(target) then
                return true
            end
        end
    end
    return false
end

local MONSTER_NAME_HINTS = {
    "scrow", "eli", "monster", "entity", "enemy", "killer",
    "twin", "debira", "mascot", "creature", "stalker", "hunter",
}

local function isPlayerCharacter(model)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character == model then
            return true
        end
    end
    return false
end

local function classifyMonster(model)
    if not model or not model:IsA("Model") or not model.Parent or isPlayerCharacter(model) then
        return nil
    end

    if isInactiveThresholdPhaseInstance(model) then
        return nil
    end

    local lowName = string.lower(model.Name)
    local namedLikeMonster = false
    for _, hint in ipairs(MONSTER_NAME_HINTS) do
        if string.find(lowName, hint, 1, true) then
            namedLikeMonster = true
            break
        end
    end

    local hasRig = model:FindFirstChildOfClass("Humanoid") ~= nil or
                   model:FindFirstChildOfClass("AnimationController") ~= nil or
                   model:FindFirstChild("HumanoidRootPart") ~= nil or
                   model:FindFirstChild("RootPart") ~= nil

    local parentName = model.Parent and string.lower(model.Parent.Name) or ""
    local entityFolder = string.find(parentName, "monster", 1, true) or
                         string.find(parentName, "entit", 1, true) or
                         string.find(parentName, "enemy", 1, true)

    local hasAIState = model:GetAttribute("State") ~= nil or
                       model:GetAttribute("Target") ~= nil or
                       model:GetAttribute("Aggro") ~= nil or
                       model:GetAttribute("Chasing") ~= nil

    if not ((namedLikeMonster and hasRig) or (hasRig and entityFolder and hasAIState)) then
        return nil
    end

    -- Extra phase isolation for direct Workspace entity models that are not parented
    -- under MallCode/ChaseWorld. The two Threshold floors are ~150 studs apart, so
    -- a generous vertical band cleanly rejects monsters from the other phase.
    local phase = currentThresholdPhase()
    local root = getCharacterRoot()
    local anchor = firstBasePart(model)
    if phase ~= "other" and root and anchor then
        if math.abs(anchor.Position.Y - root.Position.Y) > CONFIG.MonsterVerticalBand then
            return nil
        end
    end

    return "MONSTER • " .. string.upper(model.Name)
end

local function classifyGenericPrompt(prompt, tokens)
    if not prompt or not prompt.Parent or not prompt:IsDescendantOf(Workspace) then
        return nil
    end

    local action = tostring(prompt.ActionText or "")
    local objectText = tostring(prompt.ObjectText or "")
    local full = pathLower(prompt)
    local corpus = string.lower(action .. " " .. objectText .. " " .. full)

    -- Threshold clutter / utility prompts that are not progression objectives.
    if string.find(corpus, "hidebarrel", 1, true) or string.lower(action) == "hide" then
        return nil
    end
    if string.find(corpus, "mallbatteries", 1, true) or string.find(string.lower(action), "battery", 1, true) then
        return nil
    end
    if string.find(corpus, "touchverbs", 1, true) then
        return nil
    end

    local score = 0
    for _, item in ipairs(GENERIC_KEYWORDS) do
        if string.find(corpus, item[1], 1, true) then
            score += item[2]
        end
    end

    if prompt:GetAttribute("RepairPrompt") == true then
        score += 2
    end
    if prompt:GetAttribute("ActionHint") == true then
        score += 1
    end

    for token in pairs(tokens) do
        if string.find(corpus, token, 1, true) then
            score += 4
        end
    end

    if score < 5 then
        return nil
    end

    local label = "OBJECTIVE"
    local color = COLORS.Generic

    if string.find(corpus, "keypad", 1, true) or string.find(corpus, "password", 1, true) or string.find(corpus, "code", 1, true) then
        label = "CODE / KEYPAD"
        color = COLORS.CodePaper
    elseif string.find(corpus, "exit", 1, true) or string.find(corpus, "gate", 1, true) or string.find(corpus, "escape", 1, true) then
        label = "EXIT"
        color = COLORS.Exit
    elseif string.find(corpus, "key", 1, true) then
        label = "KEY / KEY OBJECTIVE"
        color = COLORS.Key
    elseif string.find(corpus, "fuse", 1, true) then
        label = "FUSE"
    elseif string.find(corpus, "generator", 1, true) then
        label = "GENERATOR"
    elseif string.find(corpus, "breaker", 1, true) then
        label = "BREAKER"
    elseif string.find(corpus, "clue", 1, true) or string.find(corpus, "paper", 1, true) or string.find(corpus, "note", 1, true) or string.find(corpus, "read", 1, true) then
        label = "CLUE / PAPER"
        color = COLORS.CodePaper
    elseif action ~= "" then
        label = "OBJECTIVE • " .. string.upper(action)
    end

    return label, color, score
end

local function scanKnown()
    if not isActive() then
        return
    end

    local seen = {}
    local phase = currentThresholdPhase()
    lastPhase = phase

    local function mark(target, label, color, priority)
        if target and target.Parent then
            seen[target] = true
            ensureRecord(target, label, color, "known", priority or 100)
        end
    end

    local chaseWorld = Workspace:FindFirstChild("ChaseWorld")
    local keySpawns = chaseWorld and chaseWorld:FindFirstChild("KeySpawns")

    -- -----------------------------------------------------------------------
    -- PHASE 1: underground / Eli maintenance keys + ladder exit
    -- -----------------------------------------------------------------------
    if phase == "underground" and chaseWorld then
        local handledContainerBranch = {}

        -- This mirrors the farm's reliable hiddenKeyBoxes() logic: HasKey=true is
        -- authoritative even when pickup replication is delayed. Route/ESP targets
        -- the physical container's Search/Open prompt, not an arbitrary model part.
        for _, box in ipairs(chaseWorld:GetDescendants()) do
            if box:GetAttribute("HasKey") == true and box:GetAttribute("Opened") ~= true then
                local branch = keySpawns and keySpawns:FindFirstChild(box.Name)
                local livePickup = nil

                if branch then
                    handledContainerBranch[branch] = true
                    for _, node in ipairs(branch:GetDescendants()) do
                        if node:IsA("ProximityPrompt") then
                            local action = string.lower(tostring(node.ActionText or ""))
                            local looksPickup = not string.find(action, "search", 1, true)
                                and not string.find(action, "open", 1, true)
                                and (string.find(action, "pick", 1, true)
                                    or string.find(action, "take", 1, true)
                                    or string.find(action, "collect", 1, true)
                                    or string.find(pathLower(node), "keyspawns", 1, true))
                            if looksPickup and node.Enabled and promptWorldPosition(node) then
                                livePickup = node
                                break
                            end
                        end
                    end
                end

                if livePickup then
                    mark(livePickup, "KEY • LIVE", COLORS.Key, 1000)
                else
                    local searchPrompt = nil
                    for _, node in ipairs(box:GetDescendants()) do
                        if node:IsA("ProximityPrompt") and promptWorldPosition(node) then
                            local action = string.lower(tostring(node.ActionText or ""))
                            if string.find(action, "search", 1, true) or string.find(action, "open", 1, true) then
                                if not searchPrompt or (node.Enabled and not searchPrompt.Enabled) then
                                    searchPrompt = node
                                end
                            end
                        end
                    end

                    if searchPrompt then
                        mark(searchPrompt, "KEY CONTAINER • " .. box.Name, COLORS.KeyContainer, 990)
                    else
                        -- Rare replication fallback: HasKey still tells us the correct
                        -- physical object even if its SearchPrompt has not arrived yet.
                        mark(box, "KEY CONTAINER • " .. box.Name, COLORS.KeyContainer, 970)
                    end
                end
            end
        end

        -- Exposed keys and a fallback for a SupplyBox branch whose physical box has
        -- not replicated yet. Disabled hidden-key prompts are still useful as a
        -- location, but live prompts always win.
        if keySpawns then
            for _, branch in ipairs(keySpawns:GetChildren()) do
                local keyObj = branch:FindFirstChild("Key")
                if keyObj then
                    local prompt = keyObj:FindFirstChildWhichIsA("ProximityPrompt", true)
                    local branchName = string.lower(branch.Name)

                    if string.match(branchName, "^supplybox_") then
                        if prompt and prompt.Enabled then
                            mark(prompt, "KEY • LIVE", COLORS.Key, 1000)
                        elseif not handledContainerBranch[branch] and prompt then
                            mark(prompt, "KEY CONTAINER • " .. branch.Name, COLORS.KeyContainer, 960)
                        end
                    elseif prompt then
                        mark(prompt, "KEY • " .. branch.Name, COLORS.Key, 985)
                    else
                        mark(keyObj, "KEY • " .. branch.Name, COLORS.Key, 980)
                    end
                end
            end
        end

        if CONFIG.ShowExit then
            local exitGate = chaseWorld:FindFirstChild("ExitGate")
            if exitGate then
                local gatePrompt = exitGate:FindFirstChild("GatePrompt", true)
                mark(gatePrompt or exitGate, "EXIT GATE", COLORS.Exit, 800)
            end
        end
    end

    -- -----------------------------------------------------------------------
    -- PHASE 2: Scrow mall code papers + loading-bay keypad
    -- -----------------------------------------------------------------------
    if phase == "mall" then
        local scrow = Workspace:FindFirstChild("Scrow")
        if scrow then
            local state = scrow:GetAttribute("State")
            local suffix = state and (" • " .. string.upper(tostring(state))) or ""
            mark(scrow, "MONSTER • SCROW" .. suffix, COLORS.Monster, 1000)
        end

        local mallCode = Workspace:FindFirstChild("MallCode")
        if mallCode then
            local digits = tostring(LocalPlayer:GetAttribute("MallDigits") or "")
            local realClues = {}
            local total = #digits

            for _, model in ipairs(mallCode:GetChildren()) do
                local index = tonumber(model:GetAttribute("DigitIndex"))
                local isDecoy = model:GetAttribute("Decoy") == true or model.Name == "OldCodePaper"
                local prompt = model:FindFirstChild("ReadPrompt", true)

                if not isDecoy and index and index >= 1 and index <= 6 and index % 1 == 0
                    and prompt and prompt:IsA("ProximityPrompt") and promptWorldPosition(prompt) then
                    total = math.max(total, index)
                    table.insert(realClues, {model = model, prompt = prompt, index = index})
                elseif CONFIG.ShowDecoyPaper and isDecoy and prompt and prompt:IsA("ProximityPrompt") then
                    mark(prompt, "CODE PAPER • DECOY", COLORS.Decoy, 960)
                end
            end

            table.sort(realClues, function(a, b) return a.index < b.index end)
            total = math.max(total, #realClues)

            for _, clue in ipairs(realClues) do
                local known = digits:sub(clue.index, clue.index)
                if not known:match("^%d$") then
                    mark(clue.prompt, string.format("CODE CLUE %d/%d", clue.index, total), COLORS.CodePaper, 990)
                end
            end
        end

        if CONFIG.ShowExit then
            local mallExit = Workspace:FindFirstChild("MallExit")
            if mallExit then
                local keypadPrompt = mallExit:FindFirstChild("KeypadPrompt", true)
                if keypadPrompt and keypadPrompt:IsA("ProximityPrompt") then
                    mark(keypadPrompt, "EXIT KEYPAD", COLORS.Exit, 800)
                else
                    local keypad = mallExit:FindFirstChild("Keypad")
                    if keypad then mark(keypad, "EXIT KEYPAD", COLORS.Exit, 800) end
                end
            end
        end
    end

    for target, rec in pairs(records) do
        if rec.source == "known" and not seen[target] then
            destroyRecord(target)
        end
    end
end

local function scanGeneric()
    if not isActive() or not CONFIG.ShowGenericObjectives then
        return
    end

    local root = getCharacterRoot()
    local corpus = currentObjectiveCorpus()
    local tokens = objectiveTokens(corpus)
    local seen = {}

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if not isInactiveThresholdPhaseInstance(obj) then
            if obj:IsA("Model") and not isKnownCovered(obj) then
                local monsterLabel = classifyMonster(obj)
                if monsterLabel then
                    seen[obj] = true
                    ensureRecord(obj, monsterLabel, COLORS.Monster, "generic", 50)
                end
            elseif obj:IsA("ProximityPrompt") and not isKnownCovered(obj) then
                local anchor = firstBasePart(obj)
                local inRange = true
                if root and anchor then
                    inRange = (root.Position - anchor.Position).Magnitude <= CONFIG.MaxGenericDistance
                end

                if inRange then
                    local label, color, score = classifyGenericPrompt(obj, tokens)
                    if label then
                        seen[obj] = true
                        ensureRecord(obj, label, color, "generic", score)
                    end
                end
            end
        end
    end

    -- Also consume explicit CollectionService tags when a game exposes objective-ish tags.
    local tags = {}
    local tagsOk, tagList = pcall(function()
        return CollectionService:GetAllTags()
    end)
    if tagsOk and type(tagList) == "table" then
        tags = tagList
    end

    for _, tag in ipairs(tags) do
        local low = string.lower(tag)
        if string.find(low, "objective", 1, true) or
           string.find(low, "quest", 1, true) or
           string.find(low, "clue", 1, true) or
           string.find(low, "key", 1, true) or
           string.find(low, "generator", 1, true) or
           string.find(low, "fuse", 1, true) then
            for _, inst in ipairs(CollectionService:GetTagged(tag)) do
                if inst:IsDescendantOf(Workspace)
                    and not isInactiveThresholdPhaseInstance(inst)
                    and not isKnownCovered(inst) then
                    seen[inst] = true
                    ensureRecord(inst, "OBJECTIVE • " .. string.upper(tag), COLORS.Generic, "generic", 8)
                end
            end
        end
    end

    for target, rec in pairs(records) do
        if rec.source == "generic" and not seen[target] then
            destroyRecord(target)
        end
    end
end

local compactObjectiveLabel

-- ---------------------------------------------------------------------------
-- Dynamic path guidance
-- ---------------------------------------------------------------------------

local function clearNavMarkers()
    for _, item in ipairs(navMarkers) do
        if item.gui then
            destroyOwned(item.gui)
        end
        if item.part then
            destroyOwned(item.part)
        end
    end
    table.clear(navMarkers)
    navMarkerGuideIndex = nil
end

local function aliveRecord(target)
    local rec = target and records[target]
    return rec and target.Parent and rec.anchor and rec.anchor.Parent and rec or nil
end

local function recordWorldPosition(rec)
    if not rec or not rec.anchor or not rec.anchor.Parent then
        return nil
    end
    if rec.target and rec.target:IsA("ProximityPrompt") then
        return promptWorldPosition(rec.target) or rec.anchor.Position
    end
    return rec.anchor.Position
end

local function routeLabel(rec)
    return string.upper(tostring(rec and rec.label or ""))
end

local function routeRank(rec, objectiveCorpus)
    if not rec or not rec.target or not rec.target.Parent then
        return nil
    end

    local label = routeLabel(rec)
    if string.find(label, "MONSTER", 1, true) or string.find(label, "DECOY", 1, true) then
        return nil
    end

    local phase = currentThresholdPhase()
    if phase == "other" then return nil end

    -- Hard phase isolation: never route to an objective from the other floor just
    -- because its replicated object happens to be physically closer.
    if phase == "mall" then
        if string.find(label, "KEY CONTAINER", 1, true)
            or string.find(label, "KEY •", 1, true)
            or string.find(label, "EXIT GATE", 1, true) then
            return nil
        end
    elseif phase == "underground" then
        if string.find(label, "CODE CLUE", 1, true)
            or string.find(label, "CODE PAPER", 1, true)
            or string.find(label, "EXIT KEYPAD", 1, true)
            or string.find(label, "CODE / KEYPAD", 1, true) then
            return nil
        end
    end

    -- Scrow mall: real paper until all four digits are known, then keypad.
    local inMall = phase == "mall"
    if inMall then
        local digits = tostring(LocalPlayer:GetAttribute("MallDigits") or "")
        local digitCount = 0
        for _ in string.gmatch(digits, "%d") do
            digitCount += 1
        end
        local complete = digitCount >= 4 and not string.find(digits, "_", 1, true)

        if not complete then
            if string.find(label, "CODE CLUE", 1, true) then return 100000 end
            if string.find(label, "CODE PAPER • REAL", 1, true) then return 99500 end
            if string.find(label, "CLUE / PAPER", 1, true) then return 90000 end
            if string.find(label, "CODE / KEYPAD", 1, true) then return 3500 end
            if string.find(label, "EXIT", 1, true) then return 500 end
        else
            if string.find(label, "EXIT KEYPAD", 1, true) then return 100000 end
            if string.find(label, "CODE / KEYPAD", 1, true) then return 95000 end
            if string.find(label, "EXIT", 1, true) then return 90000 end
            if string.find(label, "CODE CLUE", 1, true) then return 100 end
            if string.find(label, "CODE PAPER", 1, true) then return 250 end
        end
    end

    -- Underground key phase: don't send the player to the exit while keys are missing.
    local chaseWorld = Workspace:FindFirstChild("ChaseWorld")
    local gate = chaseWorld and chaseWorld:FindFirstChild("ExitGate")
    if phase == "underground" and gate then
        local needed = tonumber(gate:GetAttribute("KeysNeeded"))
        local found = tonumber(gate:GetAttribute("KeysFound"))
        if needed and found and needed > 0 then
            if found < needed then
                if string.find(label, "KEY • LIVE", 1, true) then return 100000 end
                if string.find(label, "KEY CONTAINER", 1, true) then return 98000 end
                if string.find(label, "KEY •", 1, true) then return 97000 end
                if string.find(label, "KEY / KEY OBJECTIVE", 1, true) then return 94000 end
                if string.find(label, "EXIT", 1, true) then return 250 end
            else
                if string.find(label, "EXIT GATE", 1, true) then return 100000 end
                if string.find(label, "EXIT", 1, true) then return 95000 end
            end
        end
    end

    -- Generic games / future Threshold objectives. Objective UI text biases matching ESP.
    local rank = tonumber(rec.priority) or 0
    if string.find(label, "OBJECTIVE", 1, true) then rank += 1500 end
    if string.find(label, "CODE", 1, true) or string.find(label, "PAPER", 1, true) then rank += 900 end
    if string.find(label, "KEY", 1, true) then rank += 850 end
    if string.find(label, "EXIT", 1, true) then rank += 500 end

    local corpus = objectiveCorpus or ""
    local checks = {
        {"key", "KEY"}, {"password", "CODE"}, {"code", "CODE"},
        {"paper", "PAPER"}, {"clue", "PAPER"}, {"exit", "EXIT"},
        {"generator", "GENERATOR"}, {"fuse", "FUSE"},
        {"breaker", "BREAKER"}, {"repair", "REPAIR"},
    }
    for _, pair in ipairs(checks) do
        if string.find(corpus, pair[1], 1, true) and string.find(label, pair[2], 1, true) then
            rank += 4500
        end
    end

    return rank
end

local function chooseAutoRouteTarget()
    local root = getCharacterRoot()
    if not root then
        return nil
    end

    local corpus = currentObjectiveCorpus()
    local bestTarget, bestRank, bestDistance = nil, -math.huge, math.huge

    for target, rec in pairs(records) do
        if target and target.Parent and rec.anchor and rec.anchor.Parent then
            local rank = routeRank(rec, corpus)
            if rank then
                local worldPos = recordWorldPosition(rec)
                local dist = worldPos and (root.Position - worldPos).Magnitude or math.huge
                if rank > bestRank or (rank == bestRank and dist < bestDistance) then
                    bestTarget = target
                    bestRank = rank
                    bestDistance = dist
                end
            end
        end
    end

    return bestTarget
end

local function interactionStandPoint(prompt)
    local target = promptWorldPosition(prompt)
    local char = LocalPlayer.Character
    local root = getCharacterRoot()
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not target or not char or not root or not humanoid then
        return target
    end

    local maxRange = math.max(2.5, tonumber(prompt.MaxActivationDistance) or 7)
    local clearance = humanoid.HipHeight + root.Size.Y * 0.5
    local bodySize = Vector3.new(2.2, 3.8, 2.2)

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {char}
    rayParams.RespectCanCollide = true

    local overlap = OverlapParams.new()
    overlap.FilterType = Enum.RaycastFilterType.Exclude
    overlap.FilterDescendantsInstances = {char}
    overlap.RespectCanCollide = true

    local radii = {1.75, 3, 4.5, 6}
    local best, bestScore
    local bestFloor, bestFloorScore

    for _, radius in ipairs(radii) do
        if radius < maxRange - 0.25 then
            for index = 0, 15 do
                local angle = index * math.pi / 8
                local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
                local hit = Workspace:Raycast(
                    target + offset + Vector3.new(0, 3, 0),
                    Vector3.new(0, -18, 0),
                    rayParams
                )

                if hit and hit.Normal.Y > 0.6 then
                    local point = hit.Position + Vector3.new(0, clearance + 0.08, 0)
                    local promptDistance = (point - target).Magnitude
                    if promptDistance < maxRange - 0.25 then
                        local score = (point - root.Position).Magnitude + promptDistance * 0.08

                        if not bestFloorScore or score < bestFloorScore then
                            bestFloor = point
                            bestFloorScore = score
                        end

                        local blocked = false
                        for _, part in ipairs(Workspace:GetPartBoundsInBox(CFrame.new(point), bodySize, overlap)) do
                            if part.CanCollide then
                                blocked = true
                                break
                            end
                        end

                        if not blocked and (not bestScore or score < bestScore) then
                            best = point
                            bestScore = score
                        end
                    end
                end
            end
        end
    end

    -- Prefer a verified body-clear interaction spot. If mesh bounds make every
    -- sample look blocked, a grounded in-range point is still much better than
    -- asking pathfinding to terminate inside the paper/shelf itself.
    return best or bestFloor or target
end

local function routeTargetPosition(target)
    local rec = aliveRecord(target)
    if not rec then
        return nil
    end

    if target:IsA("ProximityPrompt") then
        return interactionStandPoint(target)
    end

    return rec.anchor.Position
end

local function pathLength(waypoints)
    local total = 0
    for i = 2, #waypoints do
        total += (waypoints[i].Position - waypoints[i - 1].Position).Magnitude
    end
    return total
end

local function computeRoute(startPos, goalPos, expectedRevision, expectedPhase)
    local r = CONFIG.RouteGoalOffsetRadius
    local offsets = {
        Vector3.zero,
        Vector3.new(r, 0, 0), Vector3.new(-r, 0, 0),
        Vector3.new(0, 0, r), Vector3.new(0, 0, -r),
        Vector3.new(r * 0.7, 0, r * 0.7), Vector3.new(-r * 0.7, 0, r * 0.7),
        Vector3.new(r * 0.7, 0, -r * 0.7), Vector3.new(-r * 0.7, 0, -r * 0.7),
    }

    local bestWaypoints, bestScore = nil, math.huge

    for i, offset in ipairs(offsets) do
        if not isActive() or phaseRevision ~= expectedRevision or currentThresholdPhase() ~= expectedPhase then return nil end
        local path = PathfindingService:CreatePath({
            AgentRadius = CONFIG.RouteAgentRadius,
            AgentHeight = CONFIG.RouteAgentHeight,
            AgentCanJump = true,
            WaypointSpacing = CONFIG.RouteWaypointSpacing,
        })

        local ok = pcall(function()
            path:ComputeAsync(startPos, goalPos + offset)
        end)

        if not isActive() or phaseRevision ~= expectedRevision or currentThresholdPhase() ~= expectedPhase then return nil end
        if ok and path.Status == Enum.PathStatus.Success then
            local points = path:GetWaypoints()
            if #points >= 2 then
                local endMiss = (points[#points].Position - goalPos).Magnitude
                local score = endMiss * 100 + pathLength(points)
                if score < bestScore then
                    bestScore = score
                    bestWaypoints = points
                end

                -- Direct target succeeded cleanly; no need to probe every offset.
                if i == 1 and endMiss <= math.max(5, r) then
                    break
                end
            end
        end
    end

    return bestWaypoints
end

local function makeTurnMarker(position, textValue, color)
    local part = ownNew("Part")
    part.Name = "RouteTurn"
    part.Anchored = true
    part.CanCollide = false
    part.CanQuery = false
    part.CanTouch = false
    part.Transparency = 1
    part.Size = Vector3.new(0.2, 0.2, 0.2)
    part.Position = position + Vector3.new(0, 2.2, 0)
    part.Parent = visualFolder

    local gui = ownNew("BillboardGui")
    gui.Name = "RouteTurnMarker"
    gui.Adornee = part
    gui.AlwaysOnTop = true
    gui.LightInfluence = 0
    gui.MaxDistance = 100000
    gui.Size = UDim2.fromOffset(58, 22)
    gui.Parent = screenGui

    local t = ownNew("TextLabel")
    t.Size = UDim2.fromScale(1, 1)
    t.BackgroundColor3 = Color3.fromRGB(8, 10, 14)
    t.BackgroundTransparency = 0.2
    t.BorderSizePixel = 0
    t.Font = Enum.Font.GothamBold
    t.TextSize = 10
    t.TextColor3 = color
    t.TextStrokeTransparency = 0.45
    t.Text = textValue
    t.Parent = gui

    table.insert(navMarkers, {part = part, gui = gui})
end

local function rebuildTurnMarkers()
    -- Minimal HUD: never paint the whole route. The current turn marker is
    -- created on demand only when that turn is close enough to matter.
    clearNavMarkers()
end

local function nearestFutureWaypointDistance(position)
    local best = math.huge
    for i = math.max(1, navWaypointIndex - 1), math.min(#navWaypoints, navWaypointIndex + 4) do
        best = math.min(best, (position - navWaypoints[i].Position).Magnitude)
    end
    return best
end

local function setNavigationTarget(target, manual)
    if manual then
        navManualTarget = target
        navPathMode = target and "LOCKED" or "AUTO"
    end
    phaseRevision = phaseRevision + 1
    navNeedsRepath = true
end

local function repathNavigation()
    if not isActive() or not CONFIG.RouteGuidance or navComputing then
        return
    end

    local root = getCharacterRoot()
    if not root then
        return
    end

    if navManualTarget and not aliveRecord(navManualTarget) then
        navManualTarget = nil
        navPathMode = "AUTO"
    end

    local desired = navManualTarget or chooseAutoRouteTarget()
    if not desired then
        navTarget = nil
        navWaypoints = {}
        navWaypointIndex = 1
        navPathLength = 0
        clearNavMarkers()
        navText.Text = "NO OBJECTIVE"
        navArrow.Rotation = 0
        navArrow.TextColor3 = COLORS.Nav
        navNeedsRepath = false
        return
    end

    local goalPos = routeTargetPosition(desired)
    if not goalPos then
        return
    end

    navComputing = true
    local startPos = root.Position
    local expectedRevision, expectedPhase, expectedRoot = phaseRevision, currentThresholdPhase(), root
    local points = computeRoute(startPos, goalPos, expectedRevision, expectedPhase)
    navComputing = false

    if not isActive() or phaseRevision ~= expectedRevision or currentThresholdPhase() ~= expectedPhase
        or getCharacterRoot() ~= expectedRoot or not aliveRecord(desired) then
        return
    end

    navTarget = desired
    navLastRepath = os.clock()
    navLastRootPosition = startPos
    navLastTargetPosition = goalPos
    navNeedsRepath = false

    if points and #points >= 2 then
        navWaypoints = points
        navWaypointIndex = 2
        navPathLength = pathLength(points)
        rebuildTurnMarkers()
    else
        navWaypoints = {}
        navWaypointIndex = 1
        navPathLength = (startPos - goalPos).Magnitude
        pathFailureCount = pathFailureCount + 1
        clearNavMarkers()
    end
end

local function nextGuidanceIndex()
    if #navWaypoints == 0 then
        return nil
    end

    local start = math.max(2, navWaypointIndex)
    for i = start, #navWaypoints - 1 do
        if navWaypoints[i].Action == Enum.PathWaypointAction.Jump then
            return i
        end

        local a = navWaypoints[i - 1].Position
        local b = navWaypoints[i].Position
        local c = navWaypoints[i + 1].Position
        local d1 = Vector3.new(b.X - a.X, 0, b.Z - a.Z)
        local d2 = Vector3.new(c.X - b.X, 0, c.Z - b.Z)
        if d1.Magnitude > 0.05 and d2.Magnitude > 0.05 then
            local dot = math.clamp(d1.Unit:Dot(d2.Unit), -1, 1)
            local angle = math.deg(math.acos(dot))
            if angle >= CONFIG.RouteTurnAngle then
                return i
            end
        end
    end

    return #navWaypoints
end

local function directionWord(angle)
    local absAngle = math.abs(angle)
    if absAngle < 18 then
        return "FORWARD"
    elseif absAngle < 60 then
        return angle > 0 and "RIGHT" or "LEFT"
    elseif absAngle < 125 then
        return angle > 0 and "HARD RIGHT" or "HARD LEFT"
    else
        return "TURN AROUND"
    end
end

local function updateNavigationHUD()
    if not CONFIG.RouteGuidance then
        navFrame.Visible = false
        return
    end
    navFrame.Visible = true

    local root = getCharacterRoot()
    local camera = Workspace.CurrentCamera
    local rec = aliveRecord(navTarget)
    if not root or not camera or not rec then
        navArrow.Rotation = 0
        navText.Text = "SCANNING..."
        return
    end

    if #navWaypoints < 2 then
        navArrow.Text = "?"
        navArrow.Rotation = 0
        navText.Text = "NO WALKABLE PATH\n" .. compactObjectiveLabel(rec.label)
        clearNavMarkers()
        return
    end
    navArrow.Text = "▲"

    while navWaypointIndex <= #navWaypoints and
          (root.Position - navWaypoints[navWaypointIndex].Position).Magnitude <= CONFIG.RouteAdvanceDistance do
        navWaypointIndex += 1
    end

    local targetPos = rec.anchor.Position
    local nextPos = nil
    local action = nil
    local guideIndex = nextGuidanceIndex()
    if guideIndex and guideIndex <= #navWaypoints then
        nextPos = navWaypoints[guideIndex].Position
        action = navWaypoints[guideIndex].Action
    else
        nextPos = targetPos
    end

    local flat = Vector3.new(nextPos.X - root.Position.X, 0, nextPos.Z - root.Position.Z)
    if flat.Magnitude > 0.05 then
        local localDir = camera.CFrame:VectorToObjectSpace(flat.Unit)
        local angle = math.deg(math.atan2(localDir.X, -localDir.Z))
        navArrow.Rotation = angle

        local nextDist = math.floor(flat.Magnitude + 0.5)
        local targetDist = math.floor((targetPos - root.Position).Magnitude + 0.5)
        local turn = directionWord(angle)
        if action == Enum.PathWaypointAction.Jump then
            turn = "JUMP • " .. turn
        end

        local code = tostring(LocalPlayer:GetAttribute("MallDigits") or "")
        local objective = compactObjectiveLabel(rec.label)
        if code ~= "" and code ~= "nil" then
            objective = string.format("%s • CODE %s", objective, code)
        end
        navText.Text = string.format("%s • %dst\n%s • %dst", turn, nextDist, objective, targetDist)
        navArrow.TextColor3 = rec.color or COLORS.Nav

        -- One turn marker only, and only once the turn is close enough to be useful.
        if CONFIG.ShowRouteTurnMarkers and guideIndex and guideIndex < #navWaypoints then
            local guideDist = (root.Position - navWaypoints[guideIndex].Position).Magnitude
            if guideDist <= CONFIG.RouteTurnMarkerActivationDistance then
                if navMarkerGuideIndex ~= guideIndex then
                    clearNavMarkers()
                    navMarkerGuideIndex = guideIndex
                    local markerText = action == Enum.PathWaypointAction.Jump and "JUMP" or "TURN"
                    makeTurnMarker(navWaypoints[guideIndex].Position, markerText, rec.color or COLORS.Nav)
                end
            elseif navMarkerGuideIndex ~= nil then
                clearNavMarkers()
            end
        elseif navMarkerGuideIndex ~= nil then
            clearNavMarkers()
        end
    end
end

connect(navAuto.Activated, function()
    navManualTarget = nil
    navPathMode = "AUTO"
    phaseRevision = phaseRevision + 1
    navNeedsRepath = true
end)

local LIGHTING_PROPERTIES = {
    "Brightness",
    "ClockTime",
    "FogStart",
    "FogEnd",
    "GlobalShadows",
    "Ambient",
    "OutdoorAmbient",
    "ExposureCompensation",
}

local function saveLighting()
    for _, prop in ipairs(LIGHTING_PROPERTIES) do
        local ok, value = pcall(function()
            return Lighting[prop]
        end)
        if ok then
            originalLighting[prop] = value
        end
    end

    for _, child in ipairs(Lighting:GetChildren()) do
        if child:IsA("PostEffect") then
            originalEffects[child] = child.Enabled
        elseif child:IsA("Atmosphere") then
            originalAtmospheres[child] = {
                Density = child.Density,
                Haze = child.Haze,
                Glare = child.Glare,
            }
        end
    end
end

local function applyFullbright()
    if not isActive() or not CONFIG.Fullbright then
        return
    end

    pcall(function() Lighting.Brightness = 3 end)
    pcall(function() Lighting.ClockTime = 14 end)
    pcall(function() Lighting.FogStart = 0 end)
    pcall(function() Lighting.FogEnd = 1000000 end)
    pcall(function() Lighting.GlobalShadows = false end)
    pcall(function() Lighting.Ambient = Color3.fromRGB(190, 190, 190) end)
    pcall(function() Lighting.OutdoorAmbient = Color3.fromRGB(190, 190, 190) end)
    pcall(function() Lighting.ExposureCompensation = 0.35 end)

    for _, child in ipairs(Lighting:GetChildren()) do
        if child:IsA("PostEffect") then
            if originalEffects[child] == nil then
                originalEffects[child] = child.Enabled
            end
            pcall(function() child.Enabled = false end)
        elseif child:IsA("Atmosphere") then
            if originalAtmospheres[child] == nil then
                originalAtmospheres[child] = {
                    Density = child.Density,
                    Haze = child.Haze,
                    Glare = child.Glare,
                }
            end
            pcall(function()
                child.Density = 0
                child.Haze = 0
                child.Glare = 0
            end)
        end
    end
end

compactObjectiveLabel = function(label)
    local upper = string.upper(tostring(label or "OBJECTIVE"))
    local clueIndex, clueTotal = upper:match("CODE CLUE%s+(%d+)%/(%d+)")
    if clueIndex then
        return string.format("CLUE %s/%s", clueIndex, clueTotal)
    end
    if string.find(upper, "KEY CONTAINER", 1, true) then return "KEY CONTAINER" end
    if string.find(upper, "KEY • LIVE", 1, true) then return "KEY" end
    if string.find(upper, "KEY •", 1, true) then return "KEY" end
    if string.find(upper, "CODE PAPER • REAL", 1, true) then return "CODE PAPER" end
    if string.find(upper, "EXIT KEYPAD", 1, true) then return "EXIT KEYPAD" end
    if string.find(upper, "EXIT GATE", 1, true) then return "EXIT" end
    if string.find(upper, "CODE / KEYPAD", 1, true) then return "KEYPAD" end
    if string.find(upper, "CLUE / PAPER", 1, true) then return "CLUE" end
    if string.find(upper, "MONSTER", 1, true) then
        return string.gsub(upper, "MONSTER • ", "")
    end
    return upper
end

local monsterIndicators = {}
for i = 1, CONFIG.MaxMonsterIndicators do
    local frame = ownNew("Frame")
    frame.Name = "MonsterIndicator" .. i
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Size = UDim2.fromOffset(92, 24)
    frame.BackgroundColor3 = Color3.fromRGB(18, 8, 8)
    frame.BackgroundTransparency = 0.28
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.Parent = screenGui

    local arrow = ownNew("TextLabel")
    arrow.Name = "Arrow"
    arrow.Position = UDim2.fromOffset(2, 1)
    arrow.Size = UDim2.fromOffset(22, 22)
    arrow.BackgroundTransparency = 1
    arrow.Font = Enum.Font.GothamBlack
    arrow.Text = "▲"
    arrow.TextSize = 17
    arrow.TextColor3 = COLORS.Monster
    arrow.TextStrokeTransparency = 0.45
    arrow.Parent = frame

    local text = ownNew("TextLabel")
    text.Name = "Text"
    text.Position = UDim2.fromOffset(23, 1)
    text.Size = UDim2.fromOffset(66, 22)
    text.BackgroundTransparency = 1
    text.Font = Enum.Font.GothamBold
    text.TextSize = 10
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.TextColor3 = COLORS.Monster
    text.TextStrokeTransparency = 0.45
    text.Parent = frame

    monsterIndicators[i] = {frame = frame, arrow = arrow, text = text}
end

local function updateMonsterIndicators(root)
    local camera = Workspace.CurrentCamera
    if not root or not camera then
        for _, item in ipairs(monsterIndicators) do item.frame.Visible = false end
        return
    end

    local monsters = {}
    for target, rec in pairs(records) do
        if target and target.Parent and rec.anchor and rec.anchor.Parent
            and not isInactiveThresholdPhaseInstance(target)
            and string.find(routeLabel(rec), "MONSTER", 1, true) then
            local vertical = math.abs(rec.anchor.Position.Y - root.Position.Y)
            if currentThresholdPhase() == "other" or vertical <= CONFIG.MonsterVerticalBand then
                table.insert(monsters, {rec = rec, dist = (root.Position - rec.anchor.Position).Magnitude})
            end
        end
    end
    table.sort(monsters, function(a, b) return a.dist < b.dist end)

    local vp = camera.ViewportSize
    local center = Vector2.new(vp.X * 0.5, vp.Y * 0.5)
    local marginX, marginY = 58, 58

    for i, item in ipairs(monsterIndicators) do
        local m = monsters[i]
        if not m then
            item.frame.Visible = false
        else
            local pos = m.rec.anchor.Position + Vector3.new(0, 2.5, 0)
            local screen, onScreen = camera:WorldToViewportPoint(pos)
            local p = Vector2.new(screen.X, screen.Y)
            if screen.Z < 0 then
                p = center - (p - center)
            end

            local dx, dy = p.X - center.X, p.Y - center.Y
            if math.abs(dx) < 0.001 and math.abs(dy) < 0.001 then dy = -1 end
            local sx = (vp.X * 0.5 - marginX) / math.max(math.abs(dx), 0.001)
            local sy = (vp.Y * 0.5 - marginY) / math.max(math.abs(dy), 0.001)
            local scale = math.min(1, sx, sy)
            local clamped = center + Vector2.new(dx * scale, dy * scale)

            item.frame.Position = UDim2.fromOffset(clamped.X, clamped.Y)
            item.frame.Visible = true
            local flat = Vector3.new(pos.X - root.Position.X, 0, pos.Z - root.Position.Z)
            if flat.Magnitude > 0.05 then
                local localDir = camera.CFrame:VectorToObjectSpace(flat.Unit)
                item.arrow.Rotation = math.deg(math.atan2(localDir.X, -localDir.Z))
            end

            local name = compactObjectiveLabel(m.rec.label)
            name = string.gsub(name, " • FOLLOW", "")
            name = string.gsub(name, " • BLOCK", "")
            name = string.gsub(name, " • GLOAT", "")
            name = string.gsub(name, " • RUNOFF", "")
            name = string.gsub(name, "TWINENTITYVISUAL", "TWIN")
            name = string.gsub(name, "TWINENTITY", "TWIN")
            item.text.Text = string.format("%s %d", name, math.floor(m.dist + 0.5))
            item.frame.BackgroundTransparency = m.dist <= 80 and 0.12 or 0.35
        end
    end
end

local function updateLabels()
    local root = getCharacterRoot()

    for target, rec in pairs(records) do
        if not target or not target.Parent or not rec.anchor or not rec.anchor.Parent then
            destroyRecord(target)
        else
            local labelUpper = routeLabel(rec)
            local isMonster = string.find(labelUpper, "MONSTER", 1, true) ~= nil
            local isCodeClue = string.find(labelUpper, "CODE CLUE", 1, true) ~= nil
            local isKeyContainer = string.find(labelUpper, "KEY CONTAINER", 1, true) ~= nil
            local isCurrent = target == navTarget or target == navManualTarget
            local phase = currentThresholdPhase()

            -- Keep passive locations readable without bringing the giant billboards
            -- back: unread mall clues are cyan pips, hidden-key containers are orange
            -- pips. The selected target upgrades to the normal text/highlight.
            local showPassiveDot =
                (isCodeClue and CONFIG.ShowUnreadPaperDots and phase == "mall") or
                (isKeyContainer and CONFIG.ShowHiddenKeyContainerDots and phase == "underground")

            if showPassiveDot then
                local dot = ensurePaperDot(rec)
                if dot then
                    dot.Adornee = rec.anchor
                    local exactPosition = recordWorldPosition(rec)
                    local offset = exactPosition and (exactPosition - rec.anchor.Position) or Vector3.zero
                    dot.StudsOffsetWorldSpace = offset + Vector3.new(0, 1.35, 0)
                    dot.Enabled = not isCurrent
                end
            elseif rec.dot then
                rec.dot.Enabled = false
            end

            -- The route system can still see every record, but the player only sees
            -- the current objective. Monsters use compact screen-edge indicators.
            if rec.billboard then
                rec.billboard.Enabled = isCurrent and not isMonster
            end
            if rec.highlight then
                local closeMonster = false
                if isMonster and root then
                    closeMonster = (root.Position - rec.anchor.Position).Magnitude <= 125
                end
                rec.highlight.Enabled = (isCurrent and not isMonster) or closeMonster
                rec.highlight.FillTransparency = closeMonster and 0.93 or 0.88
                rec.highlight.OutlineTransparency = closeMonster and 0.28 or 0.12
            end

            if isCurrent and not isMonster and rec.text then
                local worldPos = recordWorldPosition(rec)
                local studs = root and worldPos and math.floor((root.Position - worldPos).Magnitude + 0.5) or 0
                rec.text.Text = string.format("%s • %dst", compactObjectiveLabel(rec.label), studs)
            end
        end
    end

    updateMonsterIndicators(root)
end

connect(kill.Activated, function() shutdown("USER_NAV_KILL") end)

saveLighting()
applyFullbright()
scanKnown()
scanGeneric()
updateLabels()

connect(Workspace.ChildAdded, function(child)
    if child.Name == "Scrow" or child.Name == "MallCode" or child.Name == "MallExit" or child.Name == "ChaseWorld" then
        deferOwned(scanKnown)
    end
end)

connect(Workspace.DescendantAdded, function(obj)
    if obj:IsA("ProximityPrompt") then
        delayOwned(0.1, function()
            if isActive() then
                scanKnown()
                scanGeneric()
            end
        end)
    end
end)

local function refreshPhaseSensitiveESP()
    if not isActive() then return end
    phaseRevision = phaseRevision + 1
    navNeedsRepath = true
    navTarget = nil
    navWaypoints = {}
    clearNavMarkers()
    scanKnown()
    scanGeneric()
    updateLabels()
end

connect(LocalPlayer:GetAttributeChangedSignal("InMall"), function()
    refreshPhaseSensitiveESP()
end)
connect(LocalPlayer:GetAttributeChangedSignal("InCase"), function()
    refreshPhaseSensitiveESP()
end)
connect(LocalPlayer:GetAttributeChangedSignal("MallDigits"), function()
    refreshPhaseSensitiveESP()
end)
connect(LocalPlayer:GetAttributeChangedSignal("Keys"), function()
    refreshPhaseSensitiveESP()
end)

connect(LocalPlayer.CharacterAdded, refreshPhaseSensitiveESP)

connect(Lighting.ChildAdded, function()
    deferOwned(applyFullbright)
end)

spawnOwned(function()
    while isActive() do
        scanKnown()
        task.wait(CONFIG.ScanInterval)
    end
end)

spawnOwned(function()
    while isActive() do
        scanGeneric()
        task.wait(CONFIG.GenericScanInterval)
    end
end)

spawnOwned(function()
    while isActive() do
        applyFullbright()
        task.wait(0.5)
    end
end)

spawnOwned(function()
    while isActive() do
        updateLabels()
        task.wait(CONFIG.DistanceUpdateInterval)
    end
end)

spawnOwned(function()
    while isActive() do
        local root = getCharacterRoot()
        local rec = aliveRecord(navTarget)
        local targetPos = rec and rec.anchor.Position or nil
        local now = os.clock()

        if navManualTarget and not aliveRecord(navManualTarget) then
            navManualTarget = nil
            navPathMode = "AUTO"
            navNeedsRepath = true
        end

        if root and CONFIG.RouteGuidance then
            local stale = (now - navLastRepath) >= CONFIG.RouteRepathInterval
            local targetMoved = targetPos and navLastTargetPosition and (targetPos - navLastTargetPosition).Magnitude > 4
            local offPath = #navWaypoints > 0 and nearestFutureWaypointDistance(root.Position) > CONFIG.RouteOffPathDistance
            local desired = navManualTarget or chooseAutoRouteTarget()
            local targetChanged = desired ~= navTarget

            if navNeedsRepath or stale or targetMoved or offPath or targetChanged then
                repathNavigation()
            end
        end

        updateNavigationHUD()
        task.wait(0.08)
    end
end)

controller.Rescan = function()
        if isActive() then
            scanKnown()
            scanGeneric()
            updateLabels()
        end
    end
controller.SetRouteTarget = function(target)
        if not isActive() then return end
        if target == nil then
            navManualTarget = nil
            navPathMode = "AUTO"
            phaseRevision = phaseRevision + 1
            navNeedsRepath = true
            return
        end
        if records[target] then
            setNavigationTarget(target, true)
        end
    end
controller.AutoRoute = function()
        if not isActive() then return end
        navManualTarget = nil
        navPathMode = "AUTO"
        phaseRevision = phaseRevision + 1
        navNeedsRepath = true
    end
controller.Config = CONFIG
if isActive() then env.__PELICAN_THRESHOLD_ESP = controller else shutdown("CANCELLED_INITIALIZATION") end
return controller
