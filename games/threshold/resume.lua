-- Threshold resume adapter. This is the only production teleport queue owner.
-- Archive farm source retains its original self-queue for provenance only.
local context, requested = ...
context = type(context) == 'table' and context or {}
local VERSION = 'PELICAN_THRESHOLD_RESUME_V1'
local MODULE_VERSION = 'PELICAN_THRESHOLD_V1'
local SCHEMA = 'threshold-resume/1'
local RECORD_KEY = '__PELICAN_THRESHOLD_SESSION_V1'
local PUBLIC_LOADER = 'https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/loader.lua'
local LOBBY, CHASE = 78453398695059, 129085487311457
local MAX_STATE, MAX_FARM = 8 * 1024 * 1024, 3 * 1024 * 1024
local env = _G
if type(getgenv) == 'function' then
    local ok, value = pcall(getgenv)
    if ok and type(value) == 'table' then env = value end
end
local function capability(name)
    local value = env[name]
    if type(value) == 'function' then return value end
    value = _G[name]
    if type(value) == 'function' then return value end
end
local read, write = capability('readfile'), capability('writefile')
local queue = capability('queue_on_teleport') or capability('queueonteleport')
if not queue and type(env.syn) == 'table' and type(env.syn.queue_on_teleport) == 'function' then
    queue = env.syn.queue_on_teleport
end
local httpOK, http = pcall(function() return game:GetService('HttpService') end)
if not httpOK then http = nil end
local ctl = {Version = VERSION}
local events, record = {}, nil
local active, ready, terminalConfirmed = true, false, false
local storageTouched, queueAccepted = false, false
local status = 'PREPARING'
local function note(kind, detail)
    events[#events + 1] = kind .. '|' .. tostring(detail or ''):sub(1, 280)
    if #events > 24 then table.remove(events, 1) end
end
local function validToken(value)
    return type(value) == 'string' and #value >= 8 and #value <= 96 and value:match('^[%w_-]+$') ~= nil
end
local function validGeneration(value)
    return type(value) == 'number' and value == math.floor(value) and value > 0 and value < 1000000
end
local function validState(value, token, generation)
    if type(value) ~= 'table' or value.Schema ~= SCHEMA or value.ModuleVersion ~= MODULE_VERSION
        or value.Token ~= token or value.Generation ~= generation or value.Status ~= 'ACTIVE'
        or not validToken(token) or not validGeneration(generation) then return false end
    local selection = value.Selection
    if type(selection) ~= 'table' or type(selection.farm) ~= 'boolean' or type(selection.navigator) ~= 'boolean' then return false end
    for key in pairs(selection) do if key ~= 'farm' and key ~= 'navigator' then return false end end
    if value.FarmState ~= nil and (type(value.FarmState) ~= 'string' or #value.FarmState > MAX_FARM) then return false end
    return true
end
local function files(token)
    return 'pelican_threshold_session_' .. token .. '.json', 'pelican_threshold_session_' .. token .. '.enabled'
end
local function flagValue(value) return value.Token .. ':' .. tostring(value.Generation) end
local function owned() return record and env[RECORD_KEY] == record and record.Owner == ctl end
local function current() return active and owned() and record.Status == 'ACTIVE' end
local function snapshot()
    return {Schema = SCHEMA, ModuleVersion = MODULE_VERSION, Token = record.Token,
        Generation = record.Generation, Status = record.Status,
        Selection = {farm = record.Selection.farm == true, navigator = record.Selection.navigator == true},
        FarmState = record.FarmState}
end
local function roundtrip(path, value)
    storageTouched = true
    local ok, problem = pcall(write, path, value)
    if not ok then return false, 'WRITE_FAILED: ' .. tostring(problem) end
    local got, actual = pcall(read, path)
    if not got or actual ~= value then return false, 'READBACK_FAILED' end
    return true
end
local function stopFlag()
    if not record or type(read) ~= 'function' or type(write) ~= 'function' then
        return not queueAccepted and not (record and record.QueueInstalled)
    end
    local _, flag = files(record.Token)
    local ok, problem = roundtrip(flag, 'STOPPED')
    if not ok then note('STOP_FLAG_FAILURE', problem) end
    return ok
end
local function unavailable(reason)
    ready = false
    status = reason
    if record then record.Selection.farm = false; record.ResumeFailed = true end
    note('RESUME_UNAVAILABLE', reason)
    if storageTouched or queueAccepted or (record and record.QueueInstalled) then
        terminalConfirmed = stopFlag()
    end
    return false
end
local function persist()
    if not current() or not http or type(read) ~= 'function' or type(write) ~= 'function' then return false end
    -- An executor file operation may yield. Never write an ACTIVE flag after
    -- the user stopped while a checkpoint was being saved.
    local function stillCurrent()
        if current() then return true end
        if owned() and record.Status == 'STOPPED' then terminalConfirmed = stopFlag() end
        return false
    end
    local encoded, body = pcall(function() return http:JSONEncode(snapshot()) end)
    if not encoded or type(body) ~= 'string' or #body > MAX_STATE then return unavailable('STATE_ENCODE_FAILED') end
    if not stillCurrent() then return false end
    local file, flag = files(record.Token)
    local ok, problem = roundtrip(file, body)
    if not stillCurrent() then return false end
    if not ok then return unavailable('STATE_' .. problem) end
    ok, problem = roundtrip(flag, flagValue(record))
    if not stillCurrent() then return false end
    if not ok then return unavailable('FLAG_' .. problem) end
    return true
end
-- No URL, module path, executable source or perk mode is taken from disk.
local function bootstrap(token, generation)
    local file, flag = files(token)
    return string.format([==[
local e=_G
if type(getgenv)=='function' then local ok,v=pcall(getgenv);if ok and type(v)=='table' then e=v end end
local r=e.readfile or readfile
if type(r)~='function' or type(loadstring)~='function' then return end
local flag,file,expected=%q,%q,%q
local token,generation=%q,%d
local function compatibleOwner()
 local c=e.__PELICAN_THRESHOLD_SESSION_V1
 if type(c)~='table' or c.Owner==nil then return true end
 if c.Status=='STOPPED' then return false end
 if c.Status~='ACTIVE' then return true end
 return c.Schema=='threshold-resume/1' and c.ModuleVersion=='PELICAN_THRESHOLD_V1'
  and c.Token==token and c.Generation==generation
end
local function enabled()
 if not compatibleOwner() then return false end
 local ok,v=pcall(r,flag);return ok and v==expected and compatibleOwner()
end
if not enabled() then return end
if game.PlaceId~=78453398695059 and game.PlaceId~=129085487311457 then return end
local deadline=os.clock()+60
while true do
 if not enabled() then return end
 local ok,p=pcall(function() return game:GetService('Players').LocalPlayer end)
 if game:IsLoaded() and ok and p and p:FindFirstChildOfClass('PlayerGui') then break end
 if os.clock()>=deadline or not task or type(task.wait)~='function' then return end
 task.wait(0.2)
end
if game.PlaceId~=78453398695059 and game.PlaceId~=129085487311457 then return end
local ok,body=pcall(r,file);if not ok or type(body)~='string' or #body>8388608 then return end
local decoded,s=pcall(function() return game:GetService('HttpService'):JSONDecode(body) end)
if not decoded or type(s)~='table' or s.Schema~='threshold-resume/1' or s.ModuleVersion~='PELICAN_THRESHOLD_V1'
 or s.Token~=token or s.Generation~=generation or s.Status~='ACTIVE' or type(s.Selection)~='table'
 or type(s.Selection.farm)~='boolean' or type(s.Selection.navigator)~='boolean' then return end
for k in pairs(s.Selection) do if k~='farm' and k~='navigator' then return end end
if s.FarmState~=nil and (type(s.FarmState)~='string' or #s.FarmState>3145728) then return end
if not enabled() then return end
local key='__PELICAN_THRESHOLD_BOOT_V1'
if e[key]==expected then return end
e[key]=expected
local got,source=pcall(function() return game:HttpGet(%q) end)
if not got or type(source)~='string' or source=='' or not enabled() then return end
local compiled,f=pcall(loadstring,source,'@pelican-threshold-resume')
if not compiled or type(f)~='function' or not enabled() then return end
pcall(f,{ThresholdResume={Token=token,Generation=generation}})
]==], flag, file, token .. ':' .. tostring(generation), token, generation, PUBLIC_LOADER)
end
local function arm()
    if not current() then return false end
    if not http or type(read) ~= 'function' or type(write) ~= 'function' or type(queue) ~= 'function' then
        return unavailable('FILE_OR_QUEUE_CAPABILITY_UNAVAILABLE')
    end
    if record.ResumeFailed then return unavailable('SESSION_RESUME_PREVIOUSLY_FAILED') end
    if not persist() then return false end
    if record.QueueInstalled then
        queueAccepted, ready, status = true, true, 'ARMED_EXISTING_QUEUE'
        return true
    end
    local ok, problem = pcall(queue, bootstrap(record.Token, record.Generation))
    if not ok or problem == false then return unavailable('QUEUE_CALL_FAILED: ' .. tostring(problem)) end
    -- Queue APIs usually return nil; a successful call proves acceptance only,
    -- not that this executor will actually execute it after teleport.
    record.QueueInstalled = true
    if not current() then
        queueAccepted = true
        if owned() and record.Status == 'STOPPED' then terminalConfirmed = stopFlag() end
        note('QUEUE_ACCEPTED_AFTER_STOP', 'Stopped flag remains authoritative')
        return false
    end
    queueAccepted, ready, status = true, true, 'ARMED_QUEUE_CALL_ACCEPTED'
    note('QUEUE_ACCEPTED', 'One menu bootstrap; actual teleport execution unverified')
    return true
end
local function readRequested(value)
    if type(value) ~= 'table' or not validToken(value.Token) or not validGeneration(value.Generation) then return nil, 'INVALID_RESUME_OPTIONS' end
    for key in pairs(value) do if key ~= 'Token' and key ~= 'Generation' then return nil, 'INVALID_RESUME_OPTIONS' end end
    if not http or type(read) ~= 'function' or type(write) ~= 'function' then return nil, 'RESUME_STORAGE_UNAVAILABLE' end
    local file, flag = files(value.Token)
    local ok, enabled = pcall(read, flag)
    if not ok or enabled ~= value.Token .. ':' .. tostring(value.Generation) then return nil, 'RESUME_FLAG_INACTIVE' end
    local got, body = pcall(read, file)
    if not got or type(body) ~= 'string' or #body > MAX_STATE then return nil, 'RESUME_STATE_UNAVAILABLE' end
    local decoded, state = pcall(function() return http:JSONDecode(body) end)
    if not decoded or not validState(state, value.Token, value.Generation) then return nil, 'RESUME_STATE_INVALID' end
    if value.Generation >= 999999 then return nil, 'RESUME_GENERATION_LIMIT' end
    local checked, finalFlag = pcall(read, flag)
    if not checked or finalFlag ~= value.Token .. ':' .. tostring(value.Generation) then return nil, 'RESUME_FLAG_INACTIVE' end
    return state
end
local previous = env[RECORD_KEY]
if type(previous) == 'table' and previous.Schema == SCHEMA and previous.ModuleVersion == MODULE_VERSION
    and previous.Status == 'ACTIVE' and previous.Preserve ~= true and previous.Owner ~= nil then
    -- The dispatcher must stop its old controller first. A helper executed
    -- directly cannot replace an active owner and leave its queued work alive.
    active = false; status = 'ACTIVE_SESSION_NOT_STOPPED'
    note('RESUME_REJECTED', status)
elseif requested ~= nil then
    local state, problem = readRequested(requested)
    if state then
        record = state
        record.Generation = record.Generation + 1
        record.QueueInstalled, record.ResumeFailed = false, false
        note('RESUMED_SELECTION', 'Validated token and checkpoint; spending modes excluded')
    else
        active = false; status = problem; note('RESUME_REJECTED', problem)
    end
elseif type(previous) == 'table' and previous.Schema == SCHEMA and previous.ModuleVersion == MODULE_VERSION
    and previous.Status == 'ACTIVE' and previous.Preserve == true
    and validState(previous, previous.Token, previous.Generation) then
    -- Same Lua environment only. A manual execution never discovers old files.
    record = previous
    note('SAME_CLIENT_REEXECUTE', 'Retained currently active in-memory selection')
else
    local token
    if http then
        local ok, value = pcall(function() return http:GenerateGUID(false) end)
        if ok and validToken(value) then token = value end
    end
    if not token then
        env.__PELICAN_THRESHOLD_TOKEN_COUNTER = (tonumber(env.__PELICAN_THRESHOLD_TOKEN_COUNTER) or 0) + 1
        token = tostring(os.time()) .. '_' .. tostring(math.random(100000, 999999)) .. '_' .. tostring(env.__PELICAN_THRESHOLD_TOKEN_COUNTER)
    end
    record = {Schema = SCHEMA, ModuleVersion = MODULE_VERSION, Token = token, Generation = 1,
        Status = 'ACTIVE', Selection = {farm = false, navigator = false}, QueueInstalled = false}
    note('FRESH_SELECTION', 'Both features off; old disk selections ignored')
end
if record then
    record.Owner, record.Preserve = ctl, false
    env[RECORD_KEY] = record
end
function ctl.Enabled() return current() and ready and not record.ResumeFailed end
function ctl.GetSelection()
    if not record then return {farm = false, navigator = false} end
    return {farm = record.Selection.farm == true, navigator = record.Selection.navigator == true}
end
function ctl.SetSelection(name, enabled)
    if name ~= 'farm' and name ~= 'navigator' then note('SELECTION_REJECTED', name); return false end
    if type(enabled) ~= 'boolean' or not current() then return false end
    if name == 'farm' and enabled and not ctl.Enabled() then return false end
    record.Selection[name] = enabled
    if not ready then return false end
    return persist()
end
function ctl.GetFarmState() return record and record.FarmState or nil end
function ctl.SaveFarmState(state)
    if not current() or not ready or type(state) ~= 'string' or #state > MAX_FARM then return false end
    local ok, decoded = pcall(function() return http:JSONDecode(state) end)
    if not ok or type(decoded) ~= 'table' or decoded.schema ~= 'threshold-farm/6.1' then
        note('FARM_STATE_REJECTED', 'Expected original threshold-farm/6.1 checkpoint JSON')
        return false
    end
    record.FarmState = state
    return persist()
end
function ctl.DisarmFarm(reason)
    -- The central kill writes STOPPED before stopping feature workers. Their
    -- subsequent disarm acknowledgements must remain idempotent and honest.
    if owned() and record.Status == 'STOPPED' then return terminalConfirmed end
    if not current() then return false end
    record.Selection.farm = false
    note('FARM_DISARMED', reason)
    if not ready then return not (record.QueueInstalled == true) end
    return persist()
end
function ctl.Stop(reason)
    if not owned() then active = false; return true end
    local preserve = reason == 'REEXECUTE' or reason == 'TELEPORT'
    if preserve and record.Status == 'ACTIVE' then
        record.Preserve = true
        active = false; ready = false; status = 'DETACHED_FOR_' .. reason
        note('DETACH', reason)
        return true
    end
    active, ready = false, false
    record.Preserve, record.Status = false, 'STOPPED'
    record.Selection.farm, record.Selection.navigator = false, false
    status = 'STOPPED'
    if not terminalConfirmed then terminalConfirmed = stopFlag() end
    if not terminalConfirmed then status = 'STOPPED_FLAG_WRITE_UNCONFIRMED' end
    note('STOP', tostring(reason) .. '|FLAG_CONFIRMED=' .. tostring(terminalConfirmed))
    return terminalConfirmed
end
function ctl.GetReport()
    local rows = {'THRESHOLD_RESUME_REPORT', 'VERSION|' .. VERSION, 'STATUS|' .. status,
        'ENABLED|' .. tostring(ctl.Enabled()), 'READFILE|' .. tostring(type(read) == 'function'),
        'WRITEFILE|' .. tostring(type(write) == 'function'), 'QUEUE|' .. tostring(type(queue) == 'function'),
        'QUEUE_CALL_ACCEPTED|' .. tostring(queueAccepted), 'STOP_FLAG_CONFIRMED|' .. tostring(terminalConfirmed),
        'FRESH_REJOIN_AUTOEXEC|NOT_ESTABLISHED', 'PROCESS_QUIT_RESET|EXECUTOR_DEPENDENT_NOT_GUARANTEED'}
    if record then
        rows[#rows + 1] = 'TOKEN|' .. record.Token
        rows[#rows + 1] = 'GENERATION|' .. tostring(record.Generation)
        rows[#rows + 1] = 'FARM_SELECTED|' .. tostring(record.Selection.farm)
        rows[#rows + 1] = 'NAVIGATOR_SELECTED|' .. tostring(record.Selection.navigator)
        rows[#rows + 1] = 'FARM_CHECKPOINT|' .. tostring(record.FarmState ~= nil)
    end
    for _, value in ipairs(events) do rows[#rows + 1] = value end
    return table.concat(rows, '\n')
end
-- Register before any file/queue operations so initialization failures can stop.
if type(context.RegisterCleanup) == 'function' then context.RegisterCleanup(ctl.Stop) end
if record and game.PlaceId ~= LOBBY and game.PlaceId ~= CHASE then
    unavailable('UNSUPPORTED_PLACE'); ctl.Stop('UNSUPPORTED_PLACE')
elseif current() then
    arm()
end
return ctl
