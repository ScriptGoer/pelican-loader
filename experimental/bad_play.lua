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
    local history={};local path=a.path or {}
    for i=1,math.min(6,#path)do local at=math.floor(1+(i-1)*math.max(0,#path-1)/math.max(1,math.min(6,#path)-1));local p=path[at];history[#history+1]={At=p.at,p=vector(p.p)}end
    return {Id=self:token(a.name),p=vector(a.p),v=vector(a.v),acceleration=vector(a.acceleration),observedSpeed=a.observedSpeed,
        WalkSpeed=a.hum and a.hum.WalkSpeed,JumpPower=a.hum and a.hum.JumpPower,Head=vector(a.head and a.head.Position),At=a.at,MotionAt=a.motionAt,Turn=a.turn,RouteTurn=a.routeTurn,History=history}
end
function B:actors(list)local out={};for i,a in ipairs(list or {})do if i>64 then break end;out[#out+1]=self:actor(a)end;return out end
function B:pos(epoch,now)
    if epoch<=0 then return end
    if self.current and self.current.Epoch==epoch then return self.current end
    if self.current then self.lastClosed=self.current end
    self.serial=self.serial+1
    local p={Id=self.serial,Epoch=epoch,Started=now,Frames={},Timeline={},TimelineDropped=0,TimelineScope='SCORES_AND_REASONS; FULL_INPUTS_IN_KEYFRAMES',Outcome={Status='UNKNOWN',RequiredMovement='UNKNOWN',Fault='UNRESOLVED'},DroppedFrames=0}
    self.ring[#self.ring+1]=p;if #self.ring>3 then table.remove(self.ring,1)end;self.current=p;return p
end
function B:eligibility(now)if self.current then self.current.Eligibility={At=now,Rows={}}end end
function B:excluded(name,s,reason,role)
    if not self.current or not self.current.Eligibility then return end
    local rows=self.current.Eligibility.Rows;if #rows<64 then rows[#rows+1]={Receiver=self:token(name),Actor=self:actor(s),Reason=reason,Role=role or 'TEAMMATE'}end
end
function B:context(context)
    local out=copy(context)
    for _,key in ipairs({'MarginDefender','LaneDefender'})do if out.Guard and out.Guard[key]then out.Guard[key]=self:token(out.Guard[key])end end
    if out.GuardInputs and out.GuardInputs.Drops then local drops={};for name,at in pairs(out.GuardInputs.Drops)do drops[self:token(name)]=at end;out.GuardInputs.Drops=drops end
    return out
end
function B:result(result)
    if not result then return end
    local out=copy(result)
    for _,t in ipairs(out.Threats or {})do t.Defender=self:token(t.Defender)end
    for _,key in ipairs({'MarginDefender','LaneDefender'})do if out.Guard and out.Guard[key]then out.Guard[key]=self:token(out.Guard[key])end end
    return out
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
        if f.RowCount and f.RowCount>=512 then f.DroppedRows=f.DroppedRows+1;return end
        f.RowCount=(f.RowCount or 0)+1
        f.Rows[key]={Key=key,Receiver=self:token(name),Variant=variant,NativeStatus='NOT_SCHEDULED',Status='NOT_EVALUATED',Reason='NOT_SCHEDULED'}
    end
    return f.Rows[key]
end
function B:status(name,variant,status,reason,shot)
    local row=self:row(name,variant);if row then row.Status=status;row.Reason=reason;if shot then row.Native=self:trajectory(shot)end;self.profile[reason or status]=(self.profile[reason or status] or 0)+1;self.profile.Skipped=self.profile.Skipped+1 end
end
function B:schedule(name,modes)for _,v in ipairs(modes)do local r=self:row(name,v);if r then r.NativeStatus='SCHEDULED_NOT_ATTEMPTED' end end end
function B:native(name,variant,shot,why,invoked)
    local row=self:row(name,variant);if row then row.NativeStatus=shot and 'SOLVED' or invoked==false and 'GENERATOR_REJECTED' or 'SOLVER_REJECTED';row.NativeReason=why;row.NativeInvoked=invoked;if shot then row.Native=self:trajectory(shot)end end
end
function B:trajectory(shot)
    return {origin=vector(shot.origin),velocity=vector(shot.velocity),arrival=vector(shot.arrival),time=shot.time,
        power=shot.power,variant=shot.variant,mode=shot.mode,networkPing=shot.networkPing,NativeAt=shot.at,
        Lead=shot.appliedLead and {shot.appliedLead.X,shot.appliedLead.Y},NativeInput=shot.nativeInput,NativeInputKind=shot.nativeInputKind,PowerMethod=shot.powerMethod,
        EffectiveYLead=shot.effectiveYLead,ActualAngle=shot.actualAngle,softBullet=shot.softBullet,jumpBullet=shot.jumpBullet,nativeCoverageJump=shot.nativeCoverageJump,magTrial=shot.magTrial,screen=shot.screen,receiverResidual=shot.receiverResidual}
end
function B:input(shot,wr,defenders,context,config)
    return {Shot=self:trajectory(shot),Receiver=self:actor(wr),Defenders=self:actors(defenders),Context=self:context(context),Config=copy(config)}
end
function B:grade(shot,wr,defenders,context,config,seconds)
    if not self.open and not self.finalActive then return end
    local captureStart=os.clock()
    local input=self:input(shot,wr,defenders,context,config)
    local result=self:result(shot.unified)
    self.profile.Graded=self.profile.Graded+1;self.profile.MaxGrade=math.max(self.profile.MaxGrade,seconds)
    if seconds>.003 then self.profile.OverBudget=self.profile.OverBudget+1 end
    if self.open then
        local row=self:row(wr.name,shot.variant or shot.mode)
        if row then self.frame.Order=self.frame.Order+1;row.Order=self.frame.Order;if row.NativeStatus~='SOLVED' then row.NativeStatus='CACHE_REUSED' end;row.Input=input;row.Result=result;row.Status='EVALUATED';row.EvaluatorSeconds=seconds end
    elseif self.finalActive and self.current then
        local f=self.current.Final
        if not f.SelectedVariant or f.SelectedVariant==(shot.variant or shot.mode)then f.Input=input;f.Result=result;f.At=os.clock()
        else f.Comparisons=f.Comparisons or {};if #f.Comparisons<6 then f.Comparisons[#f.Comparisons+1]={Input=input,Result=result}end end
    end
    self.profile.MaxCapture=math.max(self.profile.MaxCapture or 0,os.clock()-captureStart)
end
function B:admit(shot,guard)
    local row
    if self.open and shot.evidenceReceiver then row=self:row(shot.evidenceReceiver,shot.variant or shot.mode)
    elseif self.finalActive and self.current and (not self.current.Final.SelectedVariant or self.current.Final.SelectedVariant==(shot.variant or shot.mode))then row=self.current.Final end
    if row and row.Input then row.Result=self:result(shot.unified);row.Input.Context.Guard=self:context({Guard=guard}).Guard;row.PlanAllowed=shot.planAllowed;row.ReleaseBlocked=shot.releaseBlocked end
end
function B:finish(best,seconds)
    local finishedAt=os.clock()
    local f=self.frame;if not f then return end
    f.Selected=best and self:token(best.player.Name)..'/'..tostring(best.shot.variant or best.shot.mode) or nil
    for key,row in pairs(f.Rows)do
        if row.Status=='EVALUATED' then
            row.Reason=row.Result.HardReason or row.PlanAllowed==false and 'EXPLICIT_DEPTH_PLAN'
                or not row.Result.Allowed and row.Result.Reason or key==f.Selected and 'WINNER' or 'LOWER_ORDERED_SCORE'
        elseif row.Status=='NOT_EVALUATED' and row.NativeStatus=='SCHEDULED_NOT_ATTEMPTED' and row.Reason~='GRADING_BUDGET' then row.Reason=f.NativeLimited and 'PLANNING_BUDGET' or 'MODE_ROTATION'
        elseif row.NativeStatus=='SOLVER_REJECTED' then row.Reason='NATIVE_SOLVER_REJECTED'
        elseif row.NativeStatus=='GENERATOR_REJECTED' then row.Reason=row.NativeReason or 'GENERATION_UNAVAILABLE' end
    end
    f.Duration=seconds;self.profile.MaxFrame=math.max(self.profile.MaxFrame,seconds);self.profile.Frames=self.profile.Frames+1
    if self.current then
        local p=self.current;local light={At=f.At,Mode=f.Mode,Plan=f.Plan,Selected=f.Selected,Rows={}}
        for key,row in pairs(f.Rows)do light.Rows[key]={Status=row.Status,Reason=row.Reason,NativeStatus=row.NativeStatus,NativeReason=row.NativeReason,
            Score=row.Result and copy(row.Result.Score),GuardReason=row.Result and row.Result.Reason,Flight=row.Input and row.Input.Shot.time,Power=row.Input and row.Input.Shot.power}end
        p.Timeline[#p.Timeline+1]=light
        if #p.Timeline>64 then table.remove(p.Timeline,1);p.TimelineDropped=p.TimelineDropped+1 end
        if not p.FirstPlan then p.FirstPlan=copy(f)end
        if best and best.shot.unified and best.shot.unified.Allowed and not p.FirstViable then p.FirstViable=copy(f)end
    end
    f.Duration=seconds+os.clock()-finishedAt;self.profile.MaxFrame=math.max(self.profile.MaxFrame,f.Duration)
    self.profile.MaxCapture=math.max(self.profile.MaxCapture or 0,os.clock()-finishedAt)
    self.open=false
end
function B:final(epoch,now,qb,settings,variant)
    local p=self:pos(epoch,now);self.open=false;self.finalActive=true
    p.Final={AttemptAt=now,QB=self:actor(qb),Settings=copy(settings),Status='RECALCULATING',SelectedVariant=variant}
end
function B:timing(best,now)if self.current then self.current.Timing={At=now,Receiver=self:token(best.player.Name),Forecast=copy(best.shot.unified.Developing),Status='DEVELOPING_ROUTE_CONTINUATION'};self.current.DevelopmentDecision=self.current.DevelopmentDecision or copy(self.frame)end end
function B:released(shot)
    if not self.current or not self.current.Final then return end
    self.current.Final.Checks={Status='ALL_RELEASE_GUARDS_PASSED',Native=self:trajectory(shot),Guard=self:context({Guard=shot.unified.Guard}).Guard}
    self.current.ReleasedDecision=copy(self.frame)
end
function B:gate(reason)
    if self.current then self.current.LastGate=reason;self.current.LastGateAt=os.clock() end
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
    self.pinned={Schema='PELICAN_BAD_PLAY_1',Version='experimental-unified-b3',CodeId=self.CodeId,EngineId=self.EngineId,FlaggedAt=now,WallTime=os.time(),
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
