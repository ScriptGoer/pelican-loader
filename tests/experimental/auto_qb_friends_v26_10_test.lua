-- Actual controller; friendship responses and task/IO scheduling are local mocks.
local helpers=dofile('tests/experimental/fixtures/ff3_history_fixture.lua')
local checks=0
local function check(v,msg) checks=checks+1;assert(v,msg) end
local function has(c,s) return c.GetReport():find(s,1,true)~=nil end
local function scene(mode,options)
    options=options or {};options.ff3=options.ff3 or {};options.ff3.ReceiverFilter=mode
    local t=helpers.setup(nil,options)
    t.ar.Position=Vector3.new(0,6,45);t.br.Position=Vector3.new(-20,6,0)
    t.dr.Position=Vector3.new(-70,6,-150);t.dr.AssemblyLinearVelocity=Vector3.new()
    if options.largeIds then t.a.UserId=10000000101;t.b.UserId=10000000102 end
    t.results={[t.b.UserId]=true};t.calls={}
    local function lookup(_,id)
        t.calls[#t.calls+1]={id=id,inHeartbeat=Mock.inHeartbeat}
        if options.friendError then error('friend API error SECRET') end
        if options.friendYield then coroutine.yield() end
        if options.invalidResult then return 'yes' end
        return t.results[id]==true
    end
    if not options.noFriendAPI then
        if options.asyncMethod then t.me.IsFriendsWithAsync=lookup else t.me.IsFriendsWith=lookup end
    end
    t.steps=function(n,drain)
        for _=1,n or 24 do Mock.inHeartbeat=true;t.advance(.13);Mock.inHeartbeat=false;if drain~=false then t.drain() end end
    end
    return t
end

local t=scene(nil);local c=t.run();t.steps()
check(c.receiverFilter.mode=='ANY' and #t.calls==0,'unconfigured default ANY performs no friendship API calls')
check(#t.requests==1 and t.requests[1].target==t.a.Character,'ANY preserves existing nonfriend teammate targeting')
check(c.Stop('ANY'),'ANY cleanup')

for _,options in ipairs({{}, {asyncMethod=true},{largeIds=true}}) do
    t=scene('FRIENDS',options);c=t.run();t.steps()
    check(#t.requests==1 and t.requests[1].target==t.b.Character,'FRIENDS picks a verified friend instead of a closer nonfriend')
    check(#t.calls==2 and not t.calls[1].inHeartbeat and not t.calls[2].inHeartbeat,'friendship checks run deferred once per eligible teammate, outside decision callback')
    check(has(c,'RECEIVER_FILTER|FRIENDS') and has(c,'FRIEND_LOOKUP_METHOD|'..(options.asyncMethod and 'IsFriendsWithAsync' or 'IsFriendsWith')),'friend API/filter method is reported')
    check(c.Stop('VERIFIED'),'verified friend cleanup')
end

for _,kind in ipairs({'NONE','ENEMY_FRIEND','AFK_FRIEND','BLACKLIST_FRIEND','API_ERROR','API_MISSING','INVALID_RESULT','INVALID_ID'}) do
    local options={friendError=kind=='API_ERROR',noFriendAPI=kind=='API_MISSING',invalidResult=kind=='INVALID_RESULT'}
    t=scene('FRIENDS',options)
    if kind=='NONE' then t.results={}
    elseif kind=='ENEMY_FRIEND' then t.results={};t.db.UserId=103;t.results[103]=true
    elseif kind=='AFK_FRIEND' then t.br.AssemblyLinearVelocity=Vector3.new()
    elseif kind=='INVALID_ID' then t.b.UserId=0 end
    c=t.run();if kind=='BLACKLIST_FRIEND' then c.SetBlacklisted(t.b,true) end;t.steps()
    check(#t.requests==0 and not t.q.Locked,'FRIENDS does not fall back to a nonfriend/native manual target: '..kind)
    check(not c.IsStopped and not c.GetReport():find('SECRET',1,true),'friend API refusal/error remains safe and does not leak exception text: '..kind)
    check(c.Stop('NO_FRIEND'),'no eligible friend cleanup: '..kind)
end

-- A yielding read cannot authorize a throw; ANY can cancel the optional lookup.
t=scene('FRIENDS',{friendYield=true});c=t.run();t.steps(14)
check(c.receiverFilter.worker and #t.calls==1 and #t.requests==0,'only one in-flight yielding friendship check; unknown is excluded')
t.steps(12);check(#t.calls==1,'repeated eligibility reads do not duplicate the in-flight lookup')
check(c.SetReceiverFilter('ANY') and not c.receiverFilter.worker,'ANY cancels the owned friendship read')
t.steps();check(#t.requests==1 and t.requests[1].target==t.a.Character,'explicit ANY restores normal eligible targeting')
check(c.Stop('CANCEL_LOOKUP'),'cancelled lookup cleanup')

-- Expiry makes a previously verified friend unknown until a fresh successful result.
t=scene('FRIENDS');c=t.run();c.SetThrow(false);t.steps()
check(c.receiverFilter.allowed(t.b),'verified friend is cached')
local before=#t.calls
local fresh=true;for _=1,30 do fresh=c.receiverFilter.allowed(t.b) and fresh end
check(fresh and #t.calls==before,'repeated positive cache reads do not invoke the platform API')
t.results[t.b.UserId]=false;Mock.time=Mock.time+31
check(not c.receiverFilter.allowed(t.b),'expired friendship cannot authorize a final release')
c.receiverFilter.update(Mock.time);t.drain()
check(not c.receiverFilter.allowed(t.b),'a fresh negative friendship result removes eligibility')
check(c.Stop('CACHE'),'cache expiry cleanup')

-- Toggling FRIENDS cancels a prepared nonfriend release in the final solve.
local ctl,changed
t=scene('ANY',{duringSolve=function()
    if ctl and not changed and not Mock.inNativePreview and ctl.GetReport():find('TARGET|OpenWR',1,true) then changed=true;ctl.SetReceiverFilter('FRIENDS') end
end})
c=t.run();ctl=c
for _=1,30 do t.advance(.13);t.drain();if changed then break end end
check(changed and #t.requests==0 and c.receiverFilter.mode=='FRIENDS','filter change during preparation cannot send the previously eligible nonfriend throw')
check(c.Stop('FINAL_FILTER'),'filter-change final cancellation cleanup')

-- Folded control and session memory behave independently of pass/risk modes.
t=scene(nil);c=t.run();c.SetThrow(false);t.steps(12)
local ui=t.me:FindFirstChild('PlayerGui'):FindFirstChild('PELICAN_FF3_AUTO_QB_V26');local button=ui:FindFirstChild('ReceiverFilter')
check(button and button.Text=='ANY' and not button.Visible,'ANY/FRIENDS starts folded')
local status;for _,o in ipairs(ui:GetChildren()) do if o:IsA('TextButton') and o.Visible and o.Name~='ThrowAway' and o.Text~='X' then status=o end end
status.Activated:Fire();button.Activated:Fire()
check(button.Visible and button.Text=='FRIENDS' and t.env.PELICAN_FF3_RECEIVER_FILTER=='FRIENDS','compact button selects and saves FRIENDS')
check(has(c,'PASS_PLAN|NORMAL') and has(c,'RISK_MODE|TRUST'),'friend filter does not change pass plan or TRUST startup risk')
check(not c.SetReceiverFilter('ALL') and c.receiverFilter.mode=='FRIENDS','invalid filter leaves FRIENDS intact')
check(c.Stop('RELOAD'),'friend filter reload cleanup');c=t.run()
check(c.receiverFilter.mode=='FRIENDS','deliberate friend filter persists across ordinary controller reload')
check(c.Stop('PERSISTED') and not c.SetReceiverFilter('ANY'),'stopped filter cannot be changed')

-- A pending read is owned by Stop/replacement, including cancellation failure.
t=scene('FRIENDS',{friendYield=true,ff3={History=false}});c=t.run();t.steps(14);t.fail.cancel=true
check(not c.Stop('CANCEL_FAILURE'),'failed friendship worker cancellation cannot confirm cleanup')
local ok=pcall(t.run);check(not ok,'unconfirmed old friend worker prevents a replacement controller')
t.fail.cancel=false;check(c.Stop('RECOVER'),'cancellation retry finishes owned worker cleanup')
t=scene('FRIENDS',{friendYield=true});c=t.run();t.steps(14);Mock.time=Mock.time+16;c.receiverFilter.update(Mock.time)
check(not c.receiverFilter.worker and has(c,'FRIEND_LOOKUP_STATUS|LOOKUP_TIMEOUT'),'hung platform read is cancelled and reported')
check(c.Stop('TIMEOUT'),'timeout cleanup')

-- Export keeps the selected mode, not the friend list, IDs or cache contents.
t=scene('FRIENDS');c=t.run();t.steps();local _,snapshot=c.history.Snapshot(true)
check(snapshot.CurrentSettings.ReceiverFilter=='FRIENDS','current upload settings retain receiver filter')
local payload;for _,r in ipairs(snapshot.Records) do if r.Kind=='throw' then payload=r.Payload end end
check(payload and payload.ReceiverFilter=='FRIENDS','throw receipts retain filter used for the request')
check(snapshot.Friends==nil and snapshot.FriendCache==nil and snapshot.CurrentSettings.Friends==nil,'friendship cache/list is not exported')
check(c.Stop('EXPORT'),'friend export cleanup')
print('FF3 friend-filter checks passed:',checks,'(mocked; platform friendship API/cache behavior unverified)')
