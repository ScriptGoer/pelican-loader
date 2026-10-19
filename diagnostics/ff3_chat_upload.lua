-- PELICAN_FF3_CHAT_UPLOAD_V1: exact local chat "a" uploads retained session data.
-- Companion only: never launches Auto QB, Yuna, a second recorder, or its own HTTP worker.
-- Configure credentials privately in getgenv().PELICAN_FF3_CHAT_UPLOAD_CONFIG.
local env=type(getgenv)=='function' and getgenv() or _G
local key='PELICAN_FF3_CHAT_UPLOAD'
local previous=env[key]
if previous and (type(previous.Stop)~='function' or previous.Stop('REPLACED')~=true) then error('PELICAN: prior chat uploader cleanup failed') end
local controller={Version='PELICAN_FF3_CHAT_UPLOAD_V1',IsStopped=false,Status='WAIT_AUTO_QB',Triggers=0,Uploaded=0}
local connections={}
local active,history,pendingHistory,pendingJob
local lastPoll,lastTrigger=-math.huge,-math.huge
local function notify(message)
    if type(warn)=='function' then pcall(warn,'PELICAN history: '..message) end
    pcall(function() game:GetService('StarterGui'):SetCore('SendNotification',{Title='Pelican data',Text=message,Duration=2}) end)
end
local function listen(signal,callback)
    if not signal then return false end
    local ok,c=pcall(function() return signal:Connect(callback) end)
    if not ok or not c then return false end
    connections[#connections+1]=c;return true
end
function controller.GetReport()
    return 'PELICAN_FF3_CHAT_UPLOAD_V1\nSTATUS|'..controller.Status..'\nSTOPPED|'..tostring(controller.IsStopped)
        ..'\nTRIGGERS|'..controller.Triggers..'\nVERIFIED_UPLOADS|'..controller.Uploaded
        ..'\nCOMMAND|EXACT_LOCAL_LOWERCASE_a\nSCOPE|RETAINED_CURRENT_SESSION; NO_CHAT_CONTENTS_UPLOADED'
end
function controller.Stop(reason)
    controller.IsStopped=true
    local remaining={}
    for _,c in ipairs(connections) do if not pcall(function() c:Disconnect() end) then remaining[#remaining+1]=c end end
    connections=remaining
    local clean=not pendingHistory or pendingHistory.CancelUpload(pendingJob)==true
    controller.Status=clean and 'STOPPED' or 'CLEANUP_UNCONFIRMED'
    env.PELICAN_FF3_CHAT_UPLOAD_LAST_REPORT=controller.GetReport()
    if #remaining==0 and clean then if env[key]==controller then env[key]=nil end;return true end
    return false
end
if game.PlaceId~=82866880824588 then controller.Status='NOT_FF3_LIVE';controller.IsStopped=true;return controller end
local source=env.PELICAN_FF3_CHAT_UPLOAD_CONFIG or env.PELICAN_FF3_JSONBIN
assert(type(source)=='table','PELICAN: configure private chat-upload credentials before starting the companion')
-- Copy only known fields; never serialize credentials or arbitrary config values.
local config={BinId=source.BinId,AccessKey=source.AccessKey,MasterKey=source.MasterKey,
    Initialize=source.Initialize~=false,ManualOnly=true,CurrentSessionOnly=true,IntervalSeconds=source.IntervalSeconds}
assert(type(config.BinId)=='string' and #config.BinId==24 and config.BinId:match('^%x+$'),'PELICAN: invalid JSONBin bin ID')
assert(not (config.AccessKey~=nil and config.MasterKey~=nil),'PELICAN: configure exactly one JSONBin credential type')
assert(type(config.MasterKey or config.AccessKey)=='string' and #(config.MasterKey or config.AccessKey)>0,'PELICAN: missing private JSONBin credential')
env.PELICAN_FF3_JSONBIN=config -- auto-execute before or after Auto QB
local players=game:GetService('Players')
local me=players.LocalPlayer
local bindPlayer
local playerDeadline=os.clock()+30
local function attach()
    local qb=env.PELICAN_FF3_AUTO_QB
    if not qb or qb.IsStopped then active=nil;history=nil;controller.Status='WAIT_AUTO_QB';return false end
    local h=qb.history
    if type(h)~='table' or type(h.ConfigureJSONBin)~='function' or type(h.RequestUpload)~='function'
        or type(h.CancelUpload)~='function' then
        active=nil;history=nil;controller.Status='UPDATE_AUTO_QB_TO_V26_5';return false
    end
    if active~=qb then
        local ok,why=h.ConfigureJSONBin(config)
        if not ok then controller.Status=why;return false end
        active=qb;history=h;controller.Status='READY_TYPE_a'
    end
    return true
end
local function trigger(text)
    if controller.IsStopped or text~='a' then return end
    local now=os.clock()
    if now-lastTrigger<2 then return end -- deduplicate modern/legacy delivery of the same local message
    lastTrigger=now;controller.Triggers=controller.Triggers+1
    if pendingJob and pendingJob.State=='UPLOADING' then notify('Upload already running');return end
    if not attach() then notify(controller.Status);return end
    local job,why=history.RequestUpload()
    if not job then controller.Status=why;notify(why);return end
    pendingHistory,pendingJob=history,job;controller.Status='UPLOADING';notify('Uploading current session')
end
local function poll()
    if controller.IsStopped then return end
    local now=os.clock();if now-lastPoll<.5 then return end;lastPoll=now
    if not me then
        me=players.LocalPlayer
        if not me then
            controller.Status='WAIT_LOCAL_PLAYER'
            if now>=playerDeadline then notify('Local player startup timeout');controller.Stop('LOCAL_PLAYER_TIMEOUT') end
            return
        end
        bindPlayer()
    end
    if pendingJob and pendingJob.State~='UPLOADING' then
        controller.Status=pendingJob.State
        if pendingJob.State=='READBACK_VERIFIED' then controller.Uploaded=controller.Uploaded+1;notify('Session upload verified')
        else notify('Upload: '..pendingJob.State) end
        pendingJob=nil;pendingHistory=nil
    end
    local qb=env.PELICAN_FF3_AUTO_QB
    if qb~=active or qb and qb.IsStopped then attach() end
end
local function guarded(fn,...)
    local ok=pcall(fn,...)
    if not ok then controller.Status='COMPANION_ERROR';notify('Uploader stopped after an error');controller.Stop('RUNTIME_ERROR') end
end
local built,why=pcall(function()
    env[key]=controller
    bindPlayer=function()
        -- Chatted is scoped to this LocalPlayer. Modern SendingMessage also requires
        -- a matching TextSource UserId; neither path sends or rewrites any chat.
        local localChat=listen(me.Chatted,function(text) guarded(trigger,text) end)
        local serviceOK,chat=pcall(function() return game:GetService('TextChatService') end)
        local modernChat=false
        if serviceOK and chat then
            modernChat=listen(chat.SendingMessage,function(message)
                guarded(function()
                    if message and message.TextSource and message.TextSource.UserId==me.UserId then trigger(message.Text) end
                end)
            end)
        end
        assert(localChat or modernChat,'PELICAN: no supported local chat event')
        if me.OnTeleport then listen(me.OnTeleport,function(state)
            local value=tostring(state)
            if value:find('Started',1,true) or value:find('InProgress',1,true) then controller.Stop('TELEPORT') end
        end) end
    end
    assert(listen(game:GetService('RunService').Heartbeat,function() guarded(poll) end),'PELICAN: heartbeat unavailable')
    if me then bindPlayer();attach() else controller.Status='WAIT_LOCAL_PLAYER' end
end)
if not built then controller.Stop('STARTUP_ERROR');error(why) end
return controller
