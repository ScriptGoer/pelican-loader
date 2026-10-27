-- Shared synthetic IO fixture; no real HTTP, Roblox or credentials.
local fixture=dofile('tests/experimental/fixtures/auto_qb_fixture.lua')
local function clone(value)
    if type(value)~='table' then return value end
    local out={};for k,v in pairs(value) do out[k]=clone(v) end;return out
end
local function store() return {files={},values={},serial=0,guids=0} end
local function setup(storage,options)
    storage=storage or store();options=options or {}
    local t=fixture(options)
    local http={}
    function http:JSONEncode(value)
        storage.serial=storage.serial+1
        local key='json:'..storage.serial
        storage.values[key]=clone(value)
        -- Deliberate size model independent of recorder limits: tests also check trimming.
        local function size(v)
            if type(v)=='string' then return #v+2 elseif type(v)~='table' then return 10 end
            local n=2;for k,x in pairs(v) do n=n+#tostring(k)+size(x)+4 end;return n
        end
        return key..string.rep(' ',size(value))
    end
    function http:JSONDecode(text)
        return assert(clone(storage.values[text:match('^json:%d+')] or storage.values[text]),'Invalid JSON fixture')
    end
    function http:GenerateGUID() storage.guids=storage.guids+1;return 'test-guid-'..storage.guids end
    Mock.services.HttpService=http
    local writes={};local requests={};local queue={};local cancelled={}
    local fail={}
    readfile=function(path)
        if fail.read then error('permission denied') end
        return assert(storage.files[path],'file not found')
    end
    isfile=function(path) return storage.files[path]~=nil end
    writefile=function(path,text)
        writes[#writes+1]={path,text}
        if fail.write then error('file write failed') end
        storage.files[path]=fail.truncate and text:sub(1,4) or text
        if fail.afterWrite then fail.afterWrite(path,text) end
    end
    task.defer=function(fn)
        local thread=coroutine.create(fn);queue[#queue+1]=thread;return thread
    end
    task.cancel=function(thread)
        if fail.cancel then error('cancel failure') end
        cancelled[thread]=true
        if coroutine.status(thread)~='dead' then coroutine.close(thread) end
    end
    request=function(opts)
        requests[#requests+1]=clone(opts)
        if fail.http then error('Network error with SECRET header value') end
        if fail.yieldGet and opts.Method=='GET' then coroutine.yield() end
        if fail.beforeGet and opts.Method=='GET' then fail.beforeGet() end
        if opts.Method=='PUT' then
            if fail.put then error('Ambiguous PUT with SECRET') end
            storage.remote=http:JSONDecode(opts.Body)
            if fail.afterPut then fail.afterPut() end
        end
        local body=http:JSONEncode({record=storage.remote or {},metadata={private=not fail.public}})
        if fail.badEcho and opts.Method=='PUT' then body=http:JSONEncode({record={},metadata={private=true}}) end
        return {StatusCode=fail.status or 200,Body=body}
    end
    local function drain()
        local current=queue;queue={}
        for _,thread in ipairs(current) do
            if not cancelled[thread] then local ok,why=coroutine.resume(thread);assert(ok,why) end
        end
    end
    local function latest()
        local best
        for _,path in ipairs({'PELICAN_FF3_HISTORY_A.json','PELICAN_FF3_HISTORY_B.json'}) do
            local ok,d=pcall(http.JSONDecode,http,storage.files[path] or '')
            if ok and (not best or d.Revision>best.Revision) then best=d end
        end
        return best
    end
    local function configure(initialize)
        t.env.PELICAN_FF3_JSONBIN={BinId=string.rep('a',24),AccessKey='SECRET',Initialize=initialize,IntervalSeconds=60}
    end
    t.storage=storage;t.http=http;t.writes=writes;t.httpRequests=requests;t.fail=fail;t.drain=drain;t.latest=latest;t.configure=configure
    return t
end

return {setup=setup,clone=clone}
