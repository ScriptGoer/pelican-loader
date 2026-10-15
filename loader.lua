-- PELICAN: one exact-place entry point. No universe/name fallback, credentials,
-- retries, old-version fallback, or Yuna launch. See docs/loader.md.
local options = ...
if options == nil then options = {} end

-- BEGIN INLINE MANIFEST (tests compare with manifest.lua)
local manifest = {
    Schema = 2,
    LoaderVersion = "PELICAN_LOADER_V2",
    DefaultRef = "v13",
    BaseUrl = "https://raw.githubusercontent.com/ScriptGoer/pelican-loader",
    ObservedFF3Universe = 9908641400,
    Places = {
        [82866880824588] = {
            Name = "FF3 live", Game = "FF3", Ref = "ff3-v17",
            Path = "games/ff3/auto_qb.lua", Version = "PELICAN_FF3_V17",
            Experimental = true, Policy = "LIVE_HUMAN_TEAMMATES",
        },
        [81310542478972] = {
            Name = "FF3 practice", Game = "FF3", Ref = "v13",
            Path = "games/ff3/practice.lua", Version = "PELICAN_FF3_V13",
            Experimental = true, Policy = "PRACTICE_EXPLICIT_TEAMLESS",
        },
        [78453398695059] = {
            Name = "Threshold lobby", Game = "Threshold", Ref = "threshold-v1",
            Path = "games/threshold/init.lua", Version = "PELICAN_THRESHOLD_V1",
            Experimental = true, Policy = "THRESHOLD_OPT_IN_LOBBY",
        },
        [129085487311457] = {
            Name = "Threshold Chase", Game = "Threshold", Ref = "threshold-v1",
            Path = "games/threshold/init.lua", Version = "PELICAN_THRESHOLD_V1",
            Experimental = true, Policy = "THRESHOLD_PHASE_AWARE_CHASE",
        },
    },
}
-- END INLINE MANIFEST

local KEY = "PELICAN_LOADER_SESSION"
local environment = _G
if type(getgenv) == "function" then
    local ok, value = pcall(getgenv)
    if ok and type(value) == "table" then environment = value end
end
local session = {
    Version = manifest.LoaderVersion,
    State = "STARTING",
    IsStopped = false,
    IsClean = false,
    Context = {},
}
local events, uiConnections, cleanupHooks = {}, {}, {}
local controller, gui, status, panel, details, copyButton
local initActive, initializationStarted, cleanupRegistered = false, false, false
local cleanupComplete, stopRequested = false, false
local handlingRuntimeError = false
local lastReport, lastError, moduleVersion = "", "", ""
local placeId, gameId, ref, baseUrl, route, moduleUrl, sources
local sourceMode = "HTTP"
local copyResult = "NOT_REQUESTED"

local function bounded(value, limit)
    local ok, result = pcall(tostring, value)
    result = ok and result or "UNPRINTABLE_ERROR"
    return result:sub(1, limit or 1800)
end
local function record(kind, message)
    if #events >= 24 then table.remove(events, 1) end
    events[#events + 1] = kind .. "|" .. bounded(message or "")
end
local function setStatus(message)
    if status then pcall(function() status.Text = message end) end
end
local function removeUI()
    for _, connection in ipairs(uiConnections) do
        pcall(function() connection:Disconnect() end)
    end
    uiConnections = {}
    if gui then pcall(function() gui:Destroy() end) end
    gui, status, panel, details, copyButton = nil, nil, nil, nil, nil
end

function session.GetReport()
    local rows = {
        "PELICAN_LOADER_REPORT", "LOADER_VERSION|" .. session.Version,
        "STATE|" .. session.State, "STOPPED|" .. tostring(session.IsStopped),
        "CLEANUP_CONFIRMED|" .. tostring(session.IsClean),
        "PLACE_ID|" .. tostring(placeId), "GAME_ID|" .. tostring(gameId),
        "OBSERVED_FF3_UNIVERSE|" .. tostring(manifest.ObservedFF3Universe),
        "ROUTE|" .. (route and route.Name or "NONE"),
        "POLICY|" .. (route and route.Policy or "NONE"),
        "REF|" .. tostring(ref), "MODULE_VERSION|" .. moduleVersion,
        "SOURCE_MODE|" .. sourceMode,
        "MODULE_URL|" .. tostring(moduleUrl), "COPY_RESULT|" .. copyResult,
    }
    if lastError ~= "" then rows[#rows + 1] = "ERROR|" .. lastError end
    for _, row in ipairs(events) do rows[#rows + 1] = row end
    if controller and type(controller.GetReport) == "function" then
        local ok, report = pcall(controller.GetReport)
        if ok and type(report) == "string" then
            lastReport = report
        elseif not ok then
            rows[#rows + 1] = "REPORT_FAILURE|" .. bounded(report)
        end
    end
    if lastReport ~= "" then
        rows[#rows + 1] = "MODULE_REPORT_BEGIN\n" .. lastReport .. "\nMODULE_REPORT_END"
    end
    return table.concat(rows, "\n")
end

local function copyReport()
    local copier = environment.setclipboard or setclipboard
    if type(copier) ~= "function" then
        copyResult = "CLIPBOARD_UNAVAILABLE"
    else
        local ok, problem = pcall(copier, session.GetReport())
        copyResult = ok and "CALL_SUCCEEDED_NO_READBACK" or "COPY_FAILED"
        if not ok then record("COPY_FAILURE", problem) end
    end
    if copyButton then
        pcall(function()
            copyButton.Text = copyResult == "CALL_SUCCEEDED_NO_READBACK" and "Copy call OK" or "Copy unavailable"
        end)
    end
    if details then pcall(function() details.Text = session.GetReport():sub(1, 3600) end) end
    return copyResult == "CALL_SUCCEEDED_NO_READBACK"
end

local function buildUI(player)
    if gui or not player or not Instance then return end
    local ok, problem = pcall(function()
        local parent = player:FindFirstChildOfClass("PlayerGui")
        if not parent then return end
        local old = parent:FindFirstChild("PELICAN_LOADER_UI")
        if old then old:Destroy() end
        gui = Instance.new("ScreenGui")
        gui.Name, gui.ResetOnSpawn, gui.DisplayOrder = "PELICAN_LOADER_UI", false, 200
        gui.Parent = parent
        local function label(class, name, size, position, text)
            local object = Instance.new(class)
            object.Name, object.Size, object.Position = name, size, position
            object.BackgroundColor3 = Color3.fromRGB(25, 28, 33)
            object.TextColor3 = Color3.fromRGB(240, 240, 240)
            object.BorderSizePixel, object.TextSize = 0, 11
            object.Font, object.Text = Enum.Font.Gotham, text
            object.Parent = gui
            return object
        end
        status = label("TextButton", "Status", UDim2.fromOffset(140, 24), UDim2.new(0, 8, 0.18, 0), "PELICAN loading")
        local stopButton = label("TextButton", "End", UDim2.fromOffset(26, 24), UDim2.new(0, 152, 0.18, 0), "END")
        stopButton.BackgroundColor3 = Color3.fromRGB(140, 35, 40)
        panel = Instance.new("Frame")
        panel.Name, panel.Size, panel.Position = "Details", UDim2.fromOffset(280, 198), UDim2.new(0, 8, 0.18, 28)
        panel.BackgroundColor3, panel.BorderSizePixel, panel.Visible = Color3.fromRGB(25, 28, 33), 0, false
        panel.Parent = gui
        details = label("TextBox", "Report", UDim2.fromOffset(272, 164), UDim2.fromOffset(4, 4), "")
        details.Parent, details.TextEditable, details.ClearTextOnFocus = panel, false, false
        details.MultiLine, details.TextWrapped = true, true
        details.TextXAlignment, details.TextYAlignment = Enum.TextXAlignment.Left, Enum.TextYAlignment.Top
        copyButton = label("TextButton", "Copy", UDim2.fromOffset(272, 24), UDim2.fromOffset(4, 170), "Copy details before leaving")
        copyButton.Parent = panel
        uiConnections[#uiConnections + 1] = status.Activated:Connect(function()
            panel.Visible = not panel.Visible
            details.Text = session.GetReport():sub(1, 3600)
        end)
        uiConnections[#uiConnections + 1] = copyButton.Activated:Connect(copyReport)
        uiConnections[#uiConnections + 1] = stopButton.Activated:Connect(function()
            session.Stop("USER_END")
            copyReport()
        end)
    end)
    if not ok then record("UI_FAILURE", problem); removeUI() end
end

local function stopInternal(reason, keepUI)
    stopRequested, session.IsStopped = true, true
    if cleanupComplete then
        if not keepUI then removeUI() end
        return true
    end
    record("STOP", reason or "STOP")
    if initActive then
        session.IsClean = false
        record("CLEANUP_PENDING", "MODULE_INITIALIZATION_IN_PROGRESS")
        return false
    end
    local cleaned = true
    if controller and type(controller.Stop) == "function" then
            local ok, result = pcall(controller.Stop, reason or "STOP")
            cleaned = ok and result == true
            if not cleaned then record("CLEANUP_FAILURE", ok and "STOP_DID_NOT_CONFIRM_TRUE" or result) end
    elseif initializationStarted and not cleanupRegistered then
        cleaned = false
        record("CLEANUP_FAILURE", "INITIALIZATION_HAS_NO_CONTROLLER_OR_REGISTERED_ROLLBACK")
    end
    for index = #cleanupHooks, 1, -1 do
        local ok, result = pcall(cleanupHooks[index], reason or "STOP")
        if ok and result == true then
            table.remove(cleanupHooks, index)
        else
            cleaned = false
            record("CLEANUP_FAILURE", ok and "REGISTERED_CLEANUP_DID_NOT_CONFIRM_TRUE" or result)
        end
    end
    session.IsClean, cleanupComplete = cleaned, cleaned
    if cleaned and session.State ~= "ERROR" and session.State ~= "UNSUPPORTED" then session.State = "STOPPED" end
    -- Snapshot the module's final report before another run can replace it.
    session.GetReport()
    if cleaned and not keepUI then removeUI() end
    return cleaned
end

function session.Stop(reason)
    local userEnd = reason == "USER_END"
    local cleaned = stopInternal(reason or "STOP", userEnd)
    if userEnd then
        setStatus(cleaned and "PELICAN stopped" or "PELICAN cleanup pending")
        if gui then pcall(function() gui.Enabled = true end) end
        if panel then pcall(function() panel.Visible = true end) end
    end
    return cleaned
end

local function fail(kind, message)
    lastError = kind .. ": " .. bounded(message)
    session.State = "ERROR"
    record(kind, message)
    stopInternal(kind, true)
    setStatus("PELICAN " .. kind)
    if gui then pcall(function() gui.Enabled = true end) end
    if panel then pcall(function() panel.Visible = true end) end
    if details then pcall(function() details.Text = session.GetReport():sub(1, 3600) end) end
    return session
end

session.Context.RequestStop = function(reason)
    reason = reason or "USER_END"
    local cleaned = session.Stop(reason)
    if reason == "USER_END" then copyReport() end
    return cleaned
end
session.Context.IsCancelled = function() return stopRequested end
session.Context.ReportRuntimeError = function(message)
    -- Async module tasks must call this explicitly; the loader's init pcall
    -- cannot catch errors from separate threads or event callbacks.
    if cleanupComplete then return false end
    if handlingRuntimeError then
        -- A controller's cleanup can itself report an error. Keep that receipt
        -- without recursively entering Stop and its rollback stack.
        record("RUNTIME_DURING_CLEANUP", message)
        return false
    end
    handlingRuntimeError = true
    local ok, problem = pcall(fail, "RUNTIME", message)
    handlingRuntimeError = false
    if not ok then error(problem, 0) end
    return true
end
session.Context.RegisterCleanup = function(callback)
    if type(callback) ~= "function" then error("cleanup must be a function", 2) end
    cleanupRegistered = true
    if stopRequested then
        local ok, result = pcall(callback, "CANCELLED_INITIALIZATION")
        if not ok or result ~= true then cleanupHooks[#cleanupHooks + 1] = callback end
        return ok and result == true
    end
    cleanupHooks[#cleanupHooks + 1] = callback
    return true
end

local players
local serviceOK, serviceResult = pcall(function() return game:GetService("Players") end)
if serviceOK then players = serviceResult end
if players then buildUI(players.LocalPlayer) end

-- Cleanup must be positively acknowledged before replacing session ownership.
local previous = environment[KEY]
if previous ~= nil then
    if type(previous) ~= "table" or type(previous.Stop) ~= "function" then
        return fail("RESTART", "Existing namespaced session has no Stop controller; refusing to stack")
    end
    local ok, clean = pcall(previous.Stop, "REEXECUTE")
    if not ok or clean ~= true then
        return fail("RESTART", ok and "Previous cleanup not confirmed; reload blocked" or clean)
    end
end
environment[KEY] = session

if type(options) ~= "table" then return fail("CONFIG", "Loader options must be a table") end
sources = options.Sources
if sources ~= nil and type(sources) ~= "table" then return fail("CONFIG", "Sources must be a path-to-source table") end
if sources ~= nil then sourceMode = "BUNDLED" end
ref, baseUrl = options.Ref or manifest.DefaultRef, options.BaseUrl or manifest.BaseUrl
if type(ref) ~= "string" or ref == "" or ref:find("[?#\\%s]") or ref:sub(1, 1) == "/" or ref:sub(-1) == "/" then
    return fail("CONFIG", "Ref must be a nonempty Git ref or commit")
end
for segment in ref:gmatch("[^/]+") do
    if segment == "." or segment == ".." then return fail("CONFIG", "Ref contains a traversal segment") end
end
if type(baseUrl) ~= "string" or not baseUrl:match("^https://[^/%s]+/.+") or baseUrl:find("[?#\\%s]") then
    return fail("CONFIG", "BaseUrl must be an HTTPS repository root without query, fragment, or credentials")
end
if baseUrl:match("^https://[^/]*@") then return fail("CONFIG", "Credentials cannot be embedded in BaseUrl") end
baseUrl = baseUrl:gsub("/+$", "")
local timeout = options.ReadyTimeout or 20
if type(timeout) ~= "number" or timeout ~= timeout or timeout < 0 or timeout > 60 then
    return fail("CONFIG", "ReadyTimeout must be 0 to 60 seconds")
end
session.Context.Ref, session.Context.BaseUrl = ref, baseUrl
session.Context.LoaderVersion = manifest.LoaderVersion
session.Context.SourceMode = sourceMode
session.Context.Sources = sources
session.Context.LoaderBaseUrl = manifest.BaseUrl
session.Context.LoaderRef = "main"
if options.Threshold ~= nil and type(options.Threshold) ~= "table" then return fail("CONFIG", "Threshold options must be a table") end
if options.ThresholdResume ~= nil and type(options.ThresholdResume) ~= "table" then return fail("CONFIG", "ThresholdResume must be a table") end
session.Context.ThresholdOptions = options.Threshold or {}
session.Context.ThresholdResume = options.ThresholdResume

local started = os.clock()
while not stopRequested do
    local loadedOK, loaded = pcall(function() return game:IsLoaded() end)
    if not loadedOK then return fail("READY", loaded) end
    if loaded and players and players.LocalPlayer then break end
    if os.clock() - started >= timeout then return fail("READY", "Roblox or LocalPlayer not ready within bounded wait") end
    if not task or type(task.wait) ~= "function" then return fail("READY", "task.wait unavailable") end
    task.wait(0.1)
    if players then buildUI(players.LocalPlayer) end
end
if stopRequested then return session end
buildUI(players.LocalPlayer)
local idsOK, idsError = pcall(function()
    placeId, gameId = tonumber(game.PlaceId), tonumber(game.GameId)
end)
if not idsOK then return fail("ROUTE", idsError) end
if not placeId or not gameId then return fail("ROUTE", "Runtime game/place identifiers are not numeric") end
route = manifest.Places[placeId]
if not route then
    session.State = "UNSUPPORTED"
    record("UNSUPPORTED", "Explicit place route not supplied; no module fetched")
    stopInternal("UNSUPPORTED", true)
    setStatus("PELICAN unsupported")
    return session
end
if route.Game == "FF3" and gameId ~= manifest.ObservedFF3Universe then
    -- Historical universe is logged, never a substitute for exact-place routing.
    record("UNIVERSE_DIFFERENCE", "Observed FF3 universe differs from supplied report")
end
ref = options.Ref or route.Ref or manifest.DefaultRef
session.Context.Ref = ref
moduleVersion = route.Version
moduleUrl = sources ~= nil and ("bundled:" .. route.Path) or (baseUrl .. "/" .. ref .. "/" .. route.Path)
session.Context.PlaceId, session.Context.GameId = placeId, gameId
session.Context.RouteName, session.Context.ModulePath = route.Name, route.Path
session.Context.ModuleVersion, session.Context.Policy = route.Version, route.Policy
record("ROUTE", route.Name .. "|" .. route.Path .. "|" .. route.Version)

session.State = "FETCH"
setStatus("PELICAN fetch")
local fetchOK, source = pcall(function()
    if sources ~= nil then return sources[route.Path] end
    return game:HttpGet(moduleUrl)
end)
if stopRequested then return session end
if not fetchOK then return fail("FETCH", source) end
if type(source) ~= "string" or source == "" then return fail("FETCH", "Selected module source missing, empty, or nontext") end
if type(loadstring) ~= "function" then return fail("COMPILE", "Executor loadstring unavailable") end
session.State = "COMPILE"
local compileOK, chunk, compileError = pcall(loadstring, source, "@" .. route.Path)
if not compileOK then return fail("COMPILE", chunk) end
if type(chunk) ~= "function" then return fail("COMPILE", compileError or "No compiled function returned") end
if stopRequested then return session end

session.State, initActive, initializationStarted = "INIT", true, true
local initOK, result = pcall(chunk, session.Context)
initActive = false
if type(result) == "table" then controller = result end
if not initOK then return fail("INIT", result) end
if stopRequested then
    -- Cancellation or async failure during initialization must clean the returned
    -- controller rather than leaving a late-created module running.
    stopInternal("CANCELLED_INITIALIZATION", session.State == "ERROR")
    return session
end
if not controller or type(controller.Stop) ~= "function" or type(controller.GetReport) ~= "function" then
    return fail("CONTROLLER", "Module must return Stop(reason) and GetReport() functions")
end
if controller.Version ~= route.Version then
    return fail("CONTROLLER", "Module version mismatch: expected " .. route.Version .. ", received " .. bounded(controller.Version))
end
local stopped = controller.IsStopped
if type(stopped) == "function" then
    local stoppedOK, stoppedResult = pcall(stopped)
    if not stoppedOK then return fail("CONTROLLER", "IsStopped check failed: " .. bounded(stoppedResult)) end
    stopped = stoppedResult
end
if stopped == true then return fail("CONTROLLER", "Module returned an already stopped controller") end
session.State = "RUNNING"
record("INIT_OK", "Controller returned; this does not verify gameplay behavior")
if gui then pcall(function() gui.Enabled = false end) end
return session
