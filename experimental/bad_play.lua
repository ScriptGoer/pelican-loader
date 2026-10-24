-- Bounded anonymous evidence. No JSON, disk or network work in Grade().
local B={}
local function vector(v)return v and {v.X,v.Y,v.Z} or nil end
local function copy(v,depth)
    if type(v)~='table' then if type(v)=='number' then return v==v and math.abs(v)<math.huge and v or nil end;if type(v)=='string' or type(v)=='boolean' then return v end;return nil end
    if (depth or 0)>20 then return nil end
    local out={};for k,x in pairs(v)do if type(k)=='string' or type(k)=='number' then out[k]=copy(x,(depth or 0)+1)end end;return out
end
-- Explicit primitive copying avoids accidentally exporting engine instances/secrets.
function B.new(code,engine)
    return setmetatable({CodeId=code,EngineId=engine,ring={},aliases={},aliasCount=0,serial=0,profile={Frames=0,OverBudget=0,Graded=0,Skipped=0,MaxGrade=0,MaxFrame=0}}, {__index=B})
end
function B:token(name)
    name=tostring(name or 'UNKNOWN');if not self.aliases[name]then if self.aliasCount>=256 then self.profile.IdentityOverflow=true;return 'OTHER' end;self.aliasCount=self.aliasCount+1;self.aliases[name]='P'..self.aliasCount end
    return self.aliases[name]
end
function B:actor(a)
    if not a then return end
    return {Id=self:token(a.name),p=vector(a.p),v=vector(a.v),observedSpeed=a.observedSpeed,
        WalkSpeed=a.hum and a.hum.WalkSpeed,Head=vector(a.head and a.head.Position),At=a.at,MotionAt=a.motionAt,Turn=a.routeTurn or a.turn}
end
function B:actors(list)local out={};for i,a in ipairs(list or {})do if i>64 then break end;out[#out+1]=self:actor(a)end;return out end
function B:pos(epoch,now)
    if self.current and self.current.Epoch==epoch then return self.current end
    if self.current then self.lastClosed=self.current end
    self.serial=self.serial+1
    local p={Id=self.serial,Epoch=epoch,Started=now,Frames={},Outcome={Status='UNKNOWN',RequiredMovement='UNKNOWN',Fault='UNRESOLVED'},DroppedFrames=0}
    self.ring[#self.ring+1]=p;if #self.ring>3 then table.remove(self.ring,1)end;self.current=p;return p
end
function B:begin(epoch,now,receivers,modes,defenders,config,mode,plan)
    local p=self:pos(epoch,now);p.LastAt=now
    local f={At=now,Config=copy(config),Mode=mode,Plan=plan,Rows={},Defenders=self:actors(defenders),DroppedRows=0,Order=0}
    p.Frames[#p.Frames+1]=f;if #p.Frames>2 then table.remove(p.Frames,1);p.DroppedFrames=p.DroppedFrames+1 end
    self.frame=f;self.open=true;self.finalActive=false
    for _,r in ipairs(receivers)do for _,variant in ipairs(modes)do self:row(r.player.Name,variant)end end
end
function B:row(name,variant)
    local f=self.frame;if not f then return end
    local key=self:token(name)..'/'..tostring(variant)
    if not f.Rows[key]then
        if f.RowCount and f.RowCount>=128 then f.DroppedRows=f.DroppedRows+1;return end
        f.RowCount=(f.RowCount or 0)+1
        f.Rows[key]={Key=key,Receiver=self:token(name),Variant=variant,NativeStatus='NOT_SCHEDULED',Status='NOT_EVALUATED',Reason='NOT_SCHEDULED'}
    end
    return f.Rows[key]
end
function B:status(name,variant,status,reason)
    local row=self:row(name,variant);if row then row.Status=status;row.Reason=reason;self.profile[reason or status]=(self.profile[reason or status] or 0)+1;self.profile.Skipped=self.profile.Skipped+1 end
end
function B:schedule(name,modes)for _,v in ipairs(modes)do local r=self:row(name,v);if r then r.NativeStatus='SCHEDULED_NOT_ATTEMPTED' end end end
function B:native(name,variant,shot,why)
    local row=self:row(name,variant);if row then row.NativeStatus=shot and 'SOLVED' or 'SOLVER_REJECTED';row.NativeReason=why end
end
function B:trajectory(shot)
    return {origin=vector(shot.origin),velocity=vector(shot.velocity),arrival=vector(shot.arrival),time=shot.time,
        power=shot.power,variant=shot.variant,mode=shot.mode,networkPing=shot.networkPing,NativeAt=shot.at,
        Lead=shot.appliedLead and {shot.appliedLead.X,shot.appliedLead.Y},NativeInput=shot.nativeInput,NativeInputKind=shot.nativeInputKind,PowerMethod=shot.powerMethod,
        EffectiveYLead=shot.effectiveYLead,ActualAngle=shot.actualAngle}
end
function B:input(shot,wr,defenders,context,config)
    return {Shot=self:trajectory(shot),Receiver=self:actor(wr),Defenders=self.open and self.frame.Defenders or self:actors(defenders),Context=copy(context),Config=copy(config)}
end
function B:grade(shot,wr,defenders,context,config,seconds)
    local captureStart=os.clock()
    local input=self:input(shot,wr,defenders,context,config)
    local result=copy(shot.unified)
    for _,t in ipairs(result.Threats or {})do t.Defender=self:token(t.Defender)end
    self.profile.Graded=self.profile.Graded+1;self.profile.MaxGrade=math.max(self.profile.MaxGrade,seconds)
    if seconds>.003 then self.profile.OverBudget=self.profile.OverBudget+1 end
    if self.open then
        local row=self:row(wr.name,shot.variant or shot.mode)
        if row then self.frame.Order=self.frame.Order+1;row.Order=self.frame.Order;if row.NativeStatus~='SOLVED' then row.NativeStatus='CACHE_REUSED' end;row.Input=input;row.Result=result;row.Status='EVALUATED';row.EvaluatorSeconds=seconds end
    elseif self.finalActive and self.current then self.current.Final=self.current.Final or {};self.current.Final.Input=input;self.current.Final.Result=result;self.current.Final.At=os.clock() end
    self.profile.MaxCapture=math.max(self.profile.MaxCapture or 0,os.clock()-captureStart)
end
function B:finish(best,seconds)
    local f=self.frame;if not f then return end
    f.Selected=best and self:token(best.player.Name)..'/'..tostring(best.shot.variant or best.shot.mode) or nil
    for key,row in pairs(f.Rows)do
        if row.Status=='EVALUATED' then
            row.Reason=row.Result.HardReason or row.PlanAllowed==false and 'EXPLICIT_DEPTH_PLAN'
                or not row.Result.Allowed and 'RISK_TOLERANCE' or key==f.Selected and 'WINNER' or 'LOWER_OPPORTUNITY_SCORE'
        elseif row.Status=='NOT_EVALUATED' and row.NativeStatus=='SCHEDULED_NOT_ATTEMPTED' and row.Reason~='GRADING_BUDGET' then row.Reason=f.NativeLimited and 'PLANNING_BUDGET' or 'MODE_ROTATION'
        elseif row.NativeStatus=='SOLVER_REJECTED' then row.Reason='NATIVE_SOLVER_REJECTED' end
    end
    f.Duration=seconds;self.profile.MaxFrame=math.max(self.profile.MaxFrame,seconds);self.profile.Frames=self.profile.Frames+1
    self.open=false
end
function B:final(epoch,now,qb,settings)
    local p=self:pos(epoch,now);self.open=false;self.finalActive=true
    p.Final={AttemptAt=now,QB=self:actor(qb),Settings=copy(settings),Status='RECALCULATING'}
end
function B:gate(reason)
    if self.finalActive and self.current and self.current.Final then self.current.Final.Gate=reason end
end
function B:sent(id,api,now)
    if not self.current then return end
    self.current.ThrowId=id or ('local:'..self.current.Id);self.current.SentAt=now;self.current.Final.Status=api
    self.lastSent=self.current;self.finalActive=false
end
function B:observe(id,value)
    for _,p in pairs({last=self.lastSent,closed=self.lastClosed})do if p.ThrowId==id then p.Observation=copy(value);p.Outcome.Status=value.ObservedOutcome or value.Outcome or 'UNKNOWN' end end
    for _,p in ipairs(self.ring)do if p.ThrowId==id then p.Observation=copy(value);p.Outcome.Status=value.ObservedOutcome or value.Outcome or 'UNKNOWN' end end
    if self.pinned and self.pinned.Possession.ThrowId==id then self.pinned.Possession.Observation=copy(value);self.pinned.Possession.Outcome.Status=value.ObservedOutcome or value.Outcome or 'UNKNOWN' end
end
function B:flag(now,current)
    local p=not current and self.lastSent and now-(self.lastSent.SentAt or 0)<=45 and self.lastSent or self.lastClosed or self.current
    if current then p=self.current end
    if not p then return false,'NO_POSSESSION_EVIDENCE' end
    self.pinned={Schema='PELICAN_BAD_PLAY_1',CodeId=self.CodeId,EngineId=self.EngineId,FlaggedAt=now,WallTime=os.time(),
        Possession=copy(p),Profile=copy(self.profile),ReplayScope='EVALUATOR_AND_RECORDED_CANDIDATE_SELECTION_ONLY',
        Missing={NativeSolverReplay='NOT_AVAILABLE',ServerCatchMechanics='NOT_OBSERVED'}}
    return true,p.Id
end
function B:heartbeat(now,elapsed,nativeCalls)
    local p=self.profile
    if self.lastBeat then
        local ms=(now-self.lastBeat)*1000;local bucket=ms<=8 and 'LE8' or ms<=16.67 and 'LE16_67' or ms<=33.33 and 'LE33_33' or 'GT33_33'
        p.FrameIntervals=p.FrameIntervals or {};p.FrameIntervals[bucket]=(p.FrameIntervals[bucket] or 0)+1
        p.MaxFrameInterval=math.max(p.MaxFrameInterval or 0,ms)
    end
    self.lastBeat=now;p.MaxCallbackSeconds=math.max(p.MaxCallbackSeconds or 0,elapsed);p.MaxNativeCalls=math.max(p.MaxNativeCalls or 0,nativeCalls)
end
function B:report()return self.pinned end
return B
