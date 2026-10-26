-- PELICAN_FF3_V26 (experimental-unified-b3.7): generated repair of V26.22.
-- Native mode overrides exist only inside protected synchronous solves. Normal
-- Yuna automatic/manual settings are restored before returning to game input.
-- Integration contract comes from the supplied readable QB source, fn13/fn37 and
-- InputBegan release. Read-only closure discovery; no getter replacement/hooks.
-- Catch windows and current server acceptance remain unverified in Roblox.
local context = ... or {}
local Unified=(function()
-- B3 joint native-candidate ranking; fresh V26.22 guards authorize releases.
local E={defaults={DevelopingRoutes=true,DevelopmentHorizon=.18,DevelopmentMax=.35}}
local function flat(v)return Vector3.new(v.X,0,v.Z)end
function E.new(options)
 local c={};for k,v in pairs(E.defaults)do c[k]=v end
 for k,v in pairs(options or {})do
  assert(c[k]~=nil,'Unsupported B3 evaluator option: '..tostring(k))
  if k=='DevelopingRoutes'then assert(type(v)=='boolean','DevelopingRoutes must be boolean')
  else assert(type(v)=='number'and v==v and v>=0 and v<=.5,'Development horizon must be 0..0.5 seconds')end;c[k]=v
 end
 assert(c.DevelopmentHorizon<=c.DevelopmentMax,'DevelopmentHorizon exceeds DevelopmentMax')
 return setmetatable({config=c,checks=0,maxSeconds=0,holds=setmetatable({},{__mode='k'})},{__index=E})
end
function E.admit(shot,g)
 local u=shot.unified;if not u then return g.Allowed end
 -- Native SmartPass can turn a named Fit/Dime into a head-level endpoint.
 -- A mode label must not grant the looser elevated-pass admission to that path.
 local policy=u.HardReason or shot.oscillationBullet and not (g.Strict and g.WideOpen) and 'ZIGZAG_REQUIRES_WIDE_OPEN'
  or u.FlatNative and shot.mode~='Bullet' and not (g.Strict or g.TrustBurn and g.TrustBurn.Allowed)
  and 'FLAT_NATIVE_REQUIRES_BULLET_GUARDS'
 u.Guard=g;u.Allowed=g.Allowed==true and not policy
 u.Reason=policy or g.Reason or (u.Allowed and 'VIABLE_NATIVE_WINDOW' or 'COVERAGE_REJECTED');return u.Allowed
end
function E:evaluate(shot,wr,defenders,c)
 local begun=os.clock();self.checks=self.checks+1
 local g=c.Guard or {Allowed=false,Reason='FRESH_GUARD_MISSING'}
 local u={Allowed=false,Threats={},Calibration='INHERITED_UNCALIBRATED_GUARDS; RANKING_NOT_PROBABILITY'};shot.unified=u
 local t=shot.time
 if type(t)~='number'or t~=t or t<=0 or t==math.huge or not shot.origin or not shot.velocity or not shot.arrival then u.HardReason='INVALID_TRAJECTORY';u.Reason=u.HardReason;return u end
 local motion=flat(wr.v);local predicted=wr.p+motion*(t+math.max(0,shot.networkPing or 0))
 local effective=shot.effectiveYLead or shot.EffectiveYLead
 -- This is an arithmetic distinction about the returned endpoint, not a catch
 -- hitbox, standing/jump region or an inference from the configured mode name.
 u.FlatNative=type(effective)=='number' and math.abs(effective)<=.01 or false
 local bounds=c.NativeBoundary
 if bounds and bounds.Enabled then
  local allowance=math.abs(shot.appliedLead and shot.appliedLead.X or shot.Lead and shot.Lead[1] or 0)
  local tolerance=math.max(.05,flat(shot.arrival-shot.origin).Magnitude*.0001)
  for _,axis in ipairs({'X','Z'})do
   local cap=axis=='X' and 75 or 175;local inset=bounds[axis..'Tolerance']
   if type(inset)=='number' and inset==inset and math.abs(inset)<cap then
    local low,high=-cap+inset,cap+inset
    local at,goal,speed=shot.arrival[axis],predicted[axis],motion[axis]
    local edge=speed<0 and math.abs(at-low)<=tolerance and low or speed>0 and math.abs(at-high)<=tolerance and high
    local excess=edge and (speed<0 and edge-goal or goal-edge)
    if excess and excess>allowance+tolerance then
     u.Boundary={Axis=axis,Edge=edge,Projected=goal,Excess=excess,LeadAllowance=allowance,Tolerance=tolerance,
      Scope='OBSERVED_NATIVE_CLAMP; CONSTANT_VELOCITY_CONTINUATION; INTENT_UNKNOWN'}
     u.HardReason='NATIVE_BOUNDARY_ROUTE_ADJUSTMENT'
    end
   end
  end
 end
 local ev=shot.velocity-Vector3.new(0,c.gravity*t,0)
 u.ArrivalRelativeSpeed=(ev-wr.v).Magnitude;u.HeightAboveHead=shot.arrival.Y-(wr.head and wr.head.Position.Y or wr.p.Y+2)
 u.BelowBody=c.ReceiverGrounded and math.max(0,wr.p.Y-shot.arrival.Y) or 0
 local leadY=shot.appliedLead and shot.appliedLead.Y or shot.Lead and shot.Lead[2]
 -- Grounded torso placement policy, not a calibrated FF3 catch radius. An
 -- explicitly negative configured lead remains deliberate user placement.
 if c.ReceiverGrounded and leadY and leadY>=0 and u.BelowBody>math.max(.05,flat(shot.arrival-shot.origin).Magnitude*.0001) then
  u.HardReason=u.HardReason or 'NATIVE_PLACEMENT_BELOW_RECEIVER_BODY'
 end
 u.Adjustment=flat(shot.arrival-predicted).Magnitude
 local apexAt=math.max(0,math.min(t,shot.velocity.Y/c.gravity))
 u.ExcessLoft=math.max(0,shot.origin.Y+shot.velocity.Y*apexAt-.5*c.gravity*apexAt*apexAt-math.max(shot.origin.Y,shot.arrival.Y))
 u.CatchDifficulty={RelativeSpeed=u.ArrivalRelativeSpeed,HeightAboveHead=u.HeightAboveHead,BelowGroundedBody=u.BelowBody,RouteAdjustment=u.Adjustment,ExcessLoft=u.ExcessLoft,RequiredAction='UNKNOWN'}
 u.RiskScore=math.max(0,-math.min(g.Margin or 0,g.Lane or 0)) -- clearance debt, not probability
 u.ReceiverAdvantage=g.TrustBurn and math.min(g.TrustBurn.Gap or 0,g.TrustBurn.ProjectedGap or 0) or g.RaceAdvantage
 for _,k in ipairs({'MarginDefender','LaneDefender'})do if g[k]then u.Threats[#u.Threats+1]={Defender=g[k],Kind=k,Clearance=k=='MarginDefender'and g.Margin or g.Lane}end end
 local comfort=c.OpenComfort and (c.ComfortSeconds or 0)or 0
 -- Admitted contest paths can still have very different modeled exposure.
 -- Compare the existing clearance debt before comfort: an extra catch-height
 -- cost must not beat a less exposed native path. Zero-debt open passes retain
 -- the existing comfort ordering; this changes no release permission or lead.
 u.Score={RiskTier=g.Strict and 0 or g.TrustBurn and g.TrustBurn.Allowed and 1 or 2,RiskDebt=u.RiskScore,ComfortDeficit=math.max(0,comfort-t),
  CatchHeight=c.OpenComfort and (math.max(0,u.HeightAboveHead)+u.BelowBody)or 0,ContestGap=g.TrustBurn and g.TrustBurn.Allowed and -(u.ReceiverAdvantage or 0)or 0,
  RouteStability=wr.oscillation and not shot.oscillationBullet and 1 or 0,
  ExcessLoft=c.OpenComfort and u.ExcessLoft or 0,RelativeSpeed=c.OpenComfort and u.ArrivalRelativeSpeed or 0,Development=0,PassDistance=shot.passYards or flat(shot.arrival-shot.origin).Magnitude/3,Flight=t}
 local forward=Vector3.new(c.ForwardX or 0,0,c.ForwardZ or 0);local along=motion:Dot(forward);local lateral=motion-forward*along
 local depth=c.CurrentDepthYards;local h=self.config.DevelopmentHorizon
 local near=depth and depth>=(c.MinDepthYards or 6)and along>0 and (depth-(c.MinDepthYards or 6))*3<=along*h
 if self.config.DevelopingRoutes and h>0 and near and not c.GoalOrScreen and g.WideOpen and (g.NoReachableDefender and math.huge or g.DefenderETA or 0)>t+h+math.max(0,shot.networkPing or 0)and lateral.Magnitude>0 and lateral.Magnitude>=along*.5 and math.abs(wr.v.Y)<2
  and (g.Margin or 0)-((g.ThreatSpeed or 0)+motion.Magnitude)*h>=(g.RequiredMargin or 6)
  and (g.Lane or 0)-((g.ThreatSpeed or 0)+motion.Magnitude)*h>=(g.RequiredLane or 4) then
  local fv=motion
  if wr.acceleration then fv=motion+flat(wr.acceleration)*h;if fv.Magnitude>motion.Magnitude and motion.Magnitude>0 then fv=fv.Unit*motion.Magnitude end end
  local point=shot.arrival+motion*h+(fv-motion)*t;local direction=flat(point-shot.origin)
  if direction.Magnitude>0 then
   local later=(direction.Unit*flat(shot.velocity).Magnitude-fv).Magnitude;local current=(flat(shot.velocity)-motion).Magnitude
   if later+1e-6<current then u.Developing={Seconds=h,CurrentRelativeSpeed=current,ForecastRelativeSpeed=later,
    Kind=wr.acceleration and 'OBSERVED_MOMENTUM_TREND'or 'CONSTANT_VELOCITY_CONTINUATION',Reason='NEAR_ELIGIBILITY_CATCH_GEOMETRY_IMPROVING'}end
  end
 end
 u.Score.Development=u.Developing and 1 or 0
 E.admit(shot,g);self.maxSeconds=math.max(self.maxSeconds,os.clock()-begun);return u
end
function E.allowed(s)return s and s.unified and s.unified.Allowed==true or false end
function E.better(a,b)
 if not b then return true end
 local ar,br=E.allowed(a),E.allowed(b);if ar~=br then return ar end
 local x,y=a.unified.Score,b.unified.Score;if not x or not y then return x~=nil end
 for _,k in ipairs({'RiskTier','RiskDebt','Development','RouteStability','ComfortDeficit','CatchHeight','ExcessLoft','RelativeSpeed','ContestGap','PassDistance','Flight'})do if math.abs(x[k]-y[k])>1e-6 then return x[k]<y[k]end end
 return false
end
function E:wait(player,model,epoch,shot,now)
 local old=self.holds[player]
 if not old or old.model~=model or old.epoch~=epoch then old={model=model,epoch=epoch};self.holds[player]=old end
 if old.done then return false end
 if not shot.unified.Developing then if old.untilAt then old.done=true end;return false end
 old.untilAt=old.untilAt or now+math.min(shot.unified.Developing.Seconds,self.config.DevelopmentMax)
 if now>=old.untilAt then old.done=true;return false end
 return true
end
return E

end)()
local VERSION, KEY = 'PELICAN_FF3_V26', 'PELICAN_FF3_AUTO_QB'
local CFG = {Interval=.12, DiscoveryInterval=2, MaxRoster=64,
    Gravity=28,
    ThrowMargin=6, ThrowLane=4, Settle=0, MinPlayAge=0, MinDownfieldYards=6,
    MinMoveSpeed=2, MinMotionAge=.65, MotionWindow=.8, MinMotionTravel=2.4, FieldDiscoverySeconds=20, PlanCalls=6, PlanSeconds=.008, CacheAge=.36, SafeGap=.4, ReceiverSwitchYards=5}
local Players, Run, Input = game:GetService('Players'), game:GetService('RunService'), game:GetService('UserInputService')
local me = Players.LocalPlayer
if not me or game.PlaceId ~= 82866880824588 then error('PELICAN V26 requires the observed FF3 live place') end
local env = type(getgenv)=='function' and getgenv() or _G
local prior = env[KEY]
if prior and (type(prior.Stop)~='function' or prior.Stop('REPLACED')~=true) then error('PELICAN: previous Auto QB cleanup failed') end
for _,key in ipairs({'PELICAN_YUNA_GUI_RECORDER','PELICAN_FF3_STATS_RECORDER'}) do
    local old=env[key]
    if old and (type(old.Stop)~='function' or old.Stop('REMOVED_WORKFLOW')~=true) then error('PELICAN: previous recorder cleanup unconfirmed') end
end
local pg = me:FindFirstChild('PlayerGui')
if not pg then error('PELICAN: PlayerGui not ready') end
local coreOK,core=pcall(function() return game:GetService('CoreGui') end)
if not coreOK then core=nil end
-- A standalone V13/probe may have a getter replacement. Require its acknowledgement.
for _, name in ipairs({'PELICAN_FF3_LIVE','PELICAN_YUNA_RETURN_TRACE','PELICAN_YUNA_CONTROL_TEST'}) do
    local old = pg:FindFirstChild(name)
    if old then
        local stop = old:FindFirstChild('Stop')
        if stop and stop:IsA('BindableEvent') then stop:Fire() end
        if old:GetAttribute('WrapperAbsent')~=true then error('PELICAN: legacy getter cleanup unconfirmed: '..name) end
        old:Destroy()
    end
end
local controller = {Version=VERSION, IsStopped=false}
controller.unified=Unified.new((context.FF3Options or {}).Unified)
controller.bad=(function()
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
        WalkSpeed=a.hum and a.hum.WalkSpeed,JumpPower=a.hum and a.hum.JumpPower,Head=vector(a.head and a.head.Position),At=a.at,MotionAt=a.motionAt,
        MotionSince=a.motionSince,ReadinessAt=a.readyAt,ReadinessPosition=vector(a.readyP),Turn=a.turn,RouteTurn=a.routeTurn,Oscillation=copy(a.oscillation),History=history}
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
        EffectiveYLead=shot.effectiveYLead,ActualAngle=shot.actualAngle,softBullet=shot.softBullet,oscillationBullet=shot.oscillationBullet,jumpBullet=shot.jumpBullet,nativeCoverageJump=shot.nativeCoverageJump,magTrial=shot.magTrial,screen=shot.screen,receiverResidual=shot.receiverResidual}
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
function B:prejump(allowed)
    if not self.current or not self.current.Final then return end
    self.current.PreJump=copy(self.current.Final)
    self.current.PreJump.Status=allowed and 'PREJUMP_VERIFIED' or 'PREJUMP_BLOCKED'
    self.current.Final=nil;self.finalActive=false
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
    self.pinned={Schema='PELICAN_BAD_PLAY_1',Version='experimental-unified-b3.7',CodeId=self.CodeId,EngineId=self.EngineId,FlaggedAt=now,WallTime=os.time(),
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

end)().new('c125647579859d4dbee33bfaf134a624b9093d5c2a66a3d793c34c7d6b0a356a','3626267406c0c9b4ecb00134646d70f84ce022f8c61096f31ec7cc6957817edf')
controller.bad.pinned=env.PELICAN_FF3_BAD_PLAY_REPORT
controller.unified.helperHUD=(function()
-- Hide only the separately owned Pelican jump-width bar, never Yuna/game UI.
local H={}
function H.new(pg,env)
 return setmetatable({pg=pg,env=env,nextAt=0},{__index=H})
end
function H:check(now)
 if now<self.nextAt then return end;self.nextAt=now+.5
 local owner=self.env.PELICAN_FF3_MOBILE_JUMP
 local gui=self.pg:FindFirstChild('PELICAN_FF3_MOBILE_JUMP_V1')
 if type(owner)~='table'or owner.Version~='PELICAN_FF3_MOBILE_JUMP_V1'or owner.IsStopped or not gui or not gui:IsA('ScreenGui')then return end
 if self.lease and self.lease.gui==gui and self.lease.owner==owner then return end
 self:stop();self.lease={gui=gui,owner=owner,before=gui.Enabled};gui.Enabled=false
end
function H:stop()
 local l=self.lease;self.lease=nil
 if l and l.gui.Parent==self.pg and self.env.PELICAN_FF3_MOBILE_JUMP==l.owner and l.gui.Enabled==false then l.gui.Enabled=l.before end
end
return H

end)().new(pg,env)
controller.unified.oscillation=(function()
-- Observed bounded lateral reversals. No remote inputs or inferred route intent.
local O={}
local function flat(v)return Vector3.new(v.X,0,v.Z)end
function O.detect(path,forward,now,policy)
 if not forward or #path<4 then return end
 local first,last=path[1],path[#path]
 if last.at-first.at<policy.MinMotionAge then return end
 local right=Vector3.new(-forward.Z,0,forward.X)
 local travel,lateral,along,run,sign,turns,active=0,0,0,0,0,0,first.at
 local minX,maxX,minZ,maxZ=first.p.X,first.p.X,first.p.Z,first.p.Z
 for i=2,#path do
  local a,b=path[i-1],path[i];local delta=flat(b.p-a.p);local dt=b.at-a.at
  travel=travel+delta.Magnitude;lateral=lateral+math.abs(delta:Dot(right));along=along+math.abs(delta:Dot(forward))
  if dt>0 and delta.Magnitude/dt>=policy.MinMoveSpeed then active=b.at end
  minX=math.min(minX,b.p.X);maxX=math.max(maxX,b.p.X);minZ=math.min(minZ,b.p.Z);maxZ=math.max(maxZ,b.p.Z)
  local step=delta:Dot(right);local direction=step>0 and 1 or step<0 and -1 or 0
  if direction~=0 then
   if sign==0 then sign=direction;run=0
   elseif direction==sign then run=0
   else run=run+math.abs(step);if run>=policy.MinMotionTravel/2 then turns=turns+1;sign=direction;run=0 end end
  end
 end
 if turns<2 or travel<policy.MinMotionTravel or lateral<along*2 or flat(last.p-first.p).Magnitude>travel*.5
  or now-active>policy.Interval then return end
 return {Reversals=turns,Travel=travel,Age=last.at-first.at,ActiveAt=active,At=last.at,MinX=minX,MaxX=maxX,MinZ=minZ,MaxZ=maxZ,
  Scope='RECENT_OBSERVED_LATERAL_REVERSALS; CONTINUATION_NOT_GUARANTEED'}
end
function O.control(s,origin,power,gravity,ping,lead)
 if not s.oscillation then return nil,'NO_OBSERVED_ZIGZAG' end
 local target=s.head.Position+Vector3.new(0,lead.Y,0);local delta=target-origin;local range=flat(delta).Magnitude
 if range<.01 then return nil,'ZIGZAG_RANGE_INVALID' end
 local disc=power^4-gravity*(gravity*range*range+2*delta.Y*power*power)
 if disc<0 then return nil,'ZIGZAG_POINT_UNREACHABLE' end
 local angle=math.atan((power*power-math.sqrt(disc))/(gravity*range))
 local time=range/(power*math.cos(angle))
 return -flat(s.v).Magnitude*(time+ping),time
end
function O.power(s,origin,time,gravity,minPower,lead)
 local delta=s.head.Position+Vector3.new(0,lead.Y,0)-origin
 local request=math.sqrt(flat(delta).Magnitude^2/time^2+(delta.Y/time+gravity*time/2)^2)
 if request>94 then return nil,'ZIGZAG_COMFORT_POINT_OUT_OF_RANGE' end
 return math.floor(math.max(minPower,request))
end
function O.contains(s,point,allowance)
 local b=s and s.oscillation
 return b and point.X>=b.MinX-allowance and point.X<=b.MaxX+allowance and point.Z>=b.MinZ-allowance and point.Z<=b.MaxZ+allowance or false
end
return O

end)()
local connections, events, counts, samples = {}, {}, {}, {}
local profile, lease, choice, pending, gui, status, autoButton, throwButton, copyButton
local receiverButton, receiverMenu, renderReceivers, awayButton, riskButton
local blacklist=env.PELICAN_FF3_WR_BLACKLIST
if type(blacklist)~='table' or getmetatable(blacklist)~=nil then blacklist={}; env.PELICAN_FF3_WR_BLACKLIST=blacklist end
local stopped, cleanupComplete, inTick, auto, throwing, expanded = false, false, false, true, true, false
local lastTick, nextDiscovery, nextSave = -math.huge, 0, 0
local gate, copyResult, fileResult = 'WAIT_YUNA', 'NOT_REQUESTED', 'NOT_REQUESTED'
local fatalError, stopReason = 'NONE', 'NONE'
local attempts, sent, ambiguous, relinquishments, nativeCalls = 0, 0, 0, 0, 0
local receiverRejects,receiverRejectAt={},0
local arrivalRejects,arrivalResiduals={},{}
local blockedDecisions={}
local lastBlockedAt,lastBlockedKey=-math.huge,''
local opportunities, shotCache, modeChecks = {}, {}, {}
local planRound, planDeferred, maxPlanCalls = 0, 0, 0
local modeTransaction
local decisionHistory, candidateEvidence = {}, {}
local sequence, ownedAnimation, observedThrow
local cancelSequence, disposeAnimation
local clearGuide, cancelJump, forecastGuide, drawGuide, updateJump, requestJump
local assistance={jumpCount=0,guideChecks=0,maxGuideSeconds=0,
    jumpStatus='NOT_REQUESTED',jumpMethod='NONE'}
controller.groundGuide={status='WAIT_WINDOW',draws=0}
local animationStatus, animationSource = 'NOT_REQUESTED', 'NONE'
local lastSequenceOutcome='NONE'
local frameCalls,maxFrameCalls,maxHeartbeat = 0,0,0
local motionFrame=0
local maxTick=0
local fieldWaitSince, fieldWaitSeconds, initialFieldDiscovered, failureNotified = nil, 0, false, false
local function resetFieldWait() fieldWaitSince=nil; fieldWaitSeconds=0 end
local usedTools = setmetatable({}, {__mode='k'})
local possession = {tool=nil, model=nil, wasReady=false, epoch=0, since=0}
local lines={status='SEARCHING',ground=nil,los=nil,forward=nil,at=0,since=0,generation=0,
    parts=setmetatable({}, {__mode='k'}),markerCount=0,labels={},
    scan={q=core and {pg,core,workspace} or {pg,workspace},tail=core and 3 or 2,i=1,stack={},
        queued=setmetatable({}, {__mode='k'}),seen=setmetatable({}, {__mode='k'}),visited=0},
    goalToGo=false,readySource='NONE',fastStatus='NOT_CHECKED',rootChecked=-math.huge,rootDirty=true,rootNames={},
    complete=false,capped=false,negativeText=setmetatable({}, {__mode='k'})}
local V = Vector3.new
local function clean(x) return tostring(x):gsub('[\r\n|]', ' '):sub(1,180) end
local function log(kind, value)
    if #events>=32 then table.remove(events,1) end
    events[#events+1]=kind..'|'..clean(value)
end
local function setGate(value)
    controller.bad:gate(value)
    if stopped then return end
    counts[value]=(counts[value] or 0)+1
    if gate~=value then gate=value; log('GATE',value) end
    if status then status.Text=expanded and value:gsub('_',' '):sub(1,24) or 'QB' end
end
local function rememberBlocked(player,shot,reason,evidence)
    if not shot and not evidence then return end
    shot=shot or {mode=evidence.mode,variant=evidence.variant}
    local now=os.clock()
    local key=tostring(possession.epoch)..':'..player.Name..':'..tostring(shot.mode)..':'..tostring(reason)
    if key==lastBlockedKey and now-lastBlockedAt<1 then return end
    lastBlockedKey,lastBlockedAt=key,now
    local rows={string.format('at=%.3f epoch=%d target=%s mode=%s reason=%s margin=%s lane=%s marginDB=%s laneDB=%s safety=%s',
        now,possession.epoch,clean(player.Name),clean(shot.mode),clean(reason),tostring(shot.margin),tostring(shot.lane),clean(shot.marginDB or 'NONE'),clean(shot.laneDB or 'NONE'),clean(shot.safetyName or 'NONE'))}
    if shot.origin and shot.velocity and shot.arrival then
        rows[#rows+1]=string.format('TRAJECTORY t=%.6f origin=%.3f,%.3f,%.3f velocity=%.3f,%.3f,%.3f arrival=%.3f,%.3f,%.3f',
            shot.time,shot.origin.X,shot.origin.Y,shot.origin.Z,shot.velocity.X,shot.velocity.Y,shot.velocity.Z,shot.arrival.X,shot.arrival.Y,shot.arrival.Z)
    end
    for _,line in ipairs(candidateEvidence) do rows[#rows+1]='COMPARISON '..line end
    local function actor(label,s)
        if s then rows[#rows+1]=string.format('%s p=%.3f,%.3f,%.3f v=%.3f,%.3f,%.3f',label,s.p.X,s.p.Y,s.p.Z,s.v.X,s.v.Y,s.v.Z) end
    end
    actor('MARGIN_DB',shot.marginActor);actor('LANE_DB',shot.laneActor)
    local sample=samples[player];actor('WR',sample)
    if evidence then rows[#rows+1]='EVIDENCE_STAGE '..evidence.stage end
    if controller.history then controller.history.Block(player,shot,reason,sample,evidence) end
    blockedDecisions[#blockedDecisions+1]=table.concat(rows,' | ')
    if #blockedDecisions>8 then table.remove(blockedDecisions,1) end
end
local function finite(x) return type(x)=='number' and x==x and math.abs(x)<1e8 end
local ff3Options=context.FF3Options or {}
if type(ff3Options)~='table' then error('PELICAN: FF3 options must be a table') end
controller.league={mode='CASUAL',requested=ff3Options.Profile or 'AUTO',source='DEFAULT',vipSeen=false,nextCheck=0,screenDepth=ff3Options.ScreenDepthYards or 3}
assert(({AUTO=true,CASUAL=true,LEAGUE=true})[controller.league.requested],'FF3.Profile must be AUTO, CASUAL or LEAGUE')
assert(finite(controller.league.screenDepth) and controller.league.screenDepth>0 and controller.league.screenDepth<=6,'FF3.ScreenDepthYards must be >0 and <=6')
assert(ff3Options.CoverageWindows==nil or type(ff3Options.CoverageWindows)=='boolean','FF3.CoverageWindows must be boolean')
controller.coverageWindows={enabled=ff3Options.CoverageWindows~=false}
assert(ff3Options.SafetyReads==nil or type(ff3Options.SafetyReads)=='boolean','FF3.SafetyReads must be boolean')
controller.safety={enabled=ff3Options.SafetyReads~=false}
controller.coverageMath={grades=0,verticalBands=0}
controller.reactivity={nextAt=0,checks=0,wakes=0,cachedPasses=0,motionHints=0,status='WAIT_SCENE'}
assert(ff3Options.ReactiveWindows==nil or type(ff3Options.ReactiveWindows)=='boolean','FF3.ReactiveWindows must be boolean')
controller.reactivity.enabled=ff3Options.ReactiveWindows~=false
controller.jumpTiming={delay=ff3Options.JumpDelaySeconds==nil and .075 or ff3Options.JumpDelaySeconds,status='NO_JUMP',observations=0,cancelled=0}
assert(finite(controller.jumpTiming.delay) and (controller.jumpTiming.delay==0 or controller.jumpTiming.delay>=.05 and controller.jumpTiming.delay<=.1),'FF3.JumpDelaySeconds must be 0 or 0.05 through 0.10')
assert(ff3Options.NativeJump==nil or type(ff3Options.NativeJump)=='boolean','FF3.NativeJump must be boolean')
controller.nativeJump={supported=ff3Options.NativeJump~=false,enabled=ff3Options.NativeJump~=false and (ff3Options.NativeJump==true or env.PELICAN_FF3_NATIVE_JUMP~=false),status='WAIT_CHEST_THREAT'}
env.PELICAN_FF3_NATIVE_JUMP=controller.nativeJump.enabled
assert(ff3Options.ComebackChat==nil or type(ff3Options.ComebackChat)=='boolean','FF3.ComebackChat must be boolean')
controller.comeback={enabled=ff3Options.ComebackChat~=false and env.PELICAN_FF3_COMEBACK_CHAT~=false,
    observations={},status='IDLE',attempts=0,outcome='NOT_REQUESTED',nextProbe=0}
if ff3Options.ComebackChat~=nil then controller.comeback.enabled=ff3Options.ComebackChat end
env.PELICAN_FF3_COMEBACK_CHAT=controller.comeback.enabled
assert(ff3Options.JumpBullet==nil or type(ff3Options.JumpBullet)=='boolean','FF3.JumpBullet must be boolean')
controller.jumpBullet={enabled=not controller.nativeJump.supported and (ff3Options.JumpBullet==true or ff3Options.JumpBullet==nil and env.PELICAN_FF3_JUMP_BULLET==true)}
env.PELICAN_FF3_JUMP_BULLET=controller.jumpBullet.enabled
-- Target-depth preference is independent of SAFE/MOD/TRUST and native input mode.
assert(ff3Options.OpenComfort==nil or type(ff3Options.OpenComfort)=='boolean','FF3.OpenComfort must be boolean')
controller.passPlan={deepYards=ff3Options.DeepYards or 20,openComfort=ff3Options.OpenComfort~=false}
controller.passPlan.preferJump=ff3Options.WideOpenJump~=false and not controller.passPlan.openComfort
function controller.passPlan.normalize(value)
    if type(value)=='string' then value=value:upper();if value=='NORMAL' or value=='DEEP' or value=='SHORT' then return value end end
end
controller.passPlan.mode=controller.passPlan.normalize(ff3Options.PassPlan or env.PELICAN_FF3_PASS_PLAN or 'NORMAL')
assert(controller.passPlan.mode,'FF3.PassPlan must be NORMAL, DEEP or SHORT')
assert(finite(controller.passPlan.deepYards) and controller.passPlan.deepYards>=6 and controller.passPlan.deepYards<=100,'FF3.DeepYards must be 6..100 yards')
assert(ff3Options.WideOpenJump==nil or type(ff3Options.WideOpenJump)=='boolean','FF3.WideOpenJump must be boolean')
env.PELICAN_FF3_PASS_PLAN=controller.passPlan.mode
-- Read-only friend checks run in one cancellable deferred worker, never in a solve.
controller.receiverFilter=(function()
    local f={cache=setmetatable({}, {__mode='k'}),pending=setmetatable({}, {__mode='k'}),queue={},status='ANY',checks=0}
    function f.normalize(value)
        if type(value)=='string' then value=value:upper();if value=='ANY' or value=='FRIENDS' then return value end end
    end
    f.mode=f.normalize(ff3Options.ReceiverFilter or env.PELICAN_FF3_RECEIVER_FILTER or 'ANY')
    assert(f.mode,'FF3.ReceiverFilter must be ANY or FRIENDS')
    env.PELICAN_FF3_RECEIVER_FILTER=f.mode;f.status=f.mode=='ANY' and 'ANY' or 'WAIT_FRIEND_CHECKS'
    local function uid(player)
        local id=player.UserId
        return type(id)=='number' and id==id and id>0 and id<1e15 and id%1==0 and id or nil
    end
    function f.friend(player,request)
        local id=uid(player);if not id then return false,'FRIENDSHIP_UNVERIFIED' end
        local saved=f.cache[player]
        if saved and saved.uid==id and os.clock()<saved.untilAt then
            if saved.friend then return true end
            return false,saved.reason
        end
        if request~=false and not f.pending[player] and #f.queue<CFG.MaxRoster then f.pending[player]=true;f.queue[#f.queue+1]=player end
        return false,'FRIENDSHIP_CHECK_PENDING'
    end
    function f.allowed(player)
        if f.mode=='ANY' then return true end
        return f.friend(player)
    end
    function f.cancel()
        local work=f.worker
        if work then
            work.active=false
            if work.thread and coroutine.status(work.thread)~='dead' then
                if coroutine.running()==work.thread or not task or type(task.cancel)~='function' or not pcall(task.cancel,work.thread) then
                    f.status='CLEANUP_UNCONFIRMED';return false
                end
            end
            f.worker=nil
        end
        f.queue={};f.pending=setmetatable({}, {__mode='k'})
        return true
    end
    function f.update(now)
        if stopped then return end
        if f.mode=='ANY' and (not (controller.comeback.enabled or controller.mag.enabled) or not auto or not throwing) then f.cancel();return end
        if f.worker then
            if now-f.worker.at>15 then
                local player=f.worker.player
                if not f.cancel() then return end
                f.cache[player]={uid=uid(player),friend=false,untilAt=now+30,reason='FRIENDSHIP_TIMEOUT'}
                f.status='LOOKUP_TIMEOUT'
            end
            return
        end
        if #f.queue==0 then return end
        if not task or type(task.defer)~='function' or type(task.cancel)~='function' then f.status='ASYNC_UNAVAILABLE';return end
        if not f.method then
            for _,name in ipairs({'IsFriendsWithAsync','IsFriendsWith'}) do
                local ok,fn=pcall(function() return me[name] end)
                if ok and type(fn)=='function' then f.method=name;f.lookup=fn;break end
            end
            if not f.method then f.method='UNAVAILABLE';f.status='FRIEND_API_UNAVAILABLE';return end
        end
        if not f.lookup then return end
        local player=table.remove(f.queue,1);local id=uid(player)
        if not id or player==me or player.Neutral or player.Team~=me.Team then f.pending[player]=nil;return end
        local work={active=true,at=now,player=player};f.worker=work;f.status='CHECKING'
        work.thread=task.defer(function()
            if stopped or not work.active or f.worker~=work then return end
            f.checks=f.checks+1
            local ok,result=pcall(f.lookup,me,id)
            if f.worker==work then
                f.worker=nil;f.pending[player]=nil
                if not stopped and work.active and uid(player)==id then
                    local friend=ok and result==true
                    local reason=not ok and 'FRIENDSHIP_LOOKUP_FAILED' or type(result)~='boolean' and 'FRIENDSHIP_UNVERIFIED' or 'FRIENDS_ONLY'
                    f.cache[player]={uid=id,friend=friend,untilAt=os.clock()+30,reason=reason}
                    f.status=friend and 'VERIFIED_FRIEND' or ok and type(result)=='boolean' and 'VERIFIED_NOT_FRIEND' or 'LOOKUP_FAILED'
                end
            end
        end)
    end
    function f.stop() return f.cancel() end
    return f
end)()
-- Added height is an explicit opt-in calibration trial, not a measured mag zone.
controller.mag=(function()
    local options=ff3Options.MagTrial or {}
    assert(type(options)=='table','FF3.MagTrial must be a table')
    assert(options.Enabled==nil or type(options.Enabled)=='boolean','MagTrial.Enabled must be boolean')
    local trusted=env.PELICAN_FF3_WR_TRUSTED
    if type(trusted)~='table' or getmetatable(trusted)~=nil then trusted={};env.PELICAN_FF3_WR_TRUSTED=trusted end
    local m={manual=trusted,extraY=options.ExtraY or .25}
    m.enabled=options.Enabled==true or options.Enabled==nil and env.PELICAN_FF3_MAG_TRIAL==true
    assert(finite(m.extraY) and m.extraY>0 and m.extraY<=.5,'MagTrial.ExtraY must be >0 and <=0.5 native lead units')
    env.PELICAN_FF3_MAG_TRIAL=m.enabled
    m.status=m.enabled and 'WAIT_TRUSTED_TRAJECTORY' or 'OFF'
    function m.Reject(reason) m.status=reason;return nil,reason end
    return m
end)()
assert(ff3Options.AdaptiveAngle==nil or type(ff3Options.AdaptiveAngle)=='boolean','FF3.AdaptiveAngle must be boolean')
controller.angle={enabled=ff3Options.AdaptiveAngle~=false and env.PELICAN_FF3_ADAPTIVE_ANGLE~=false,
    origins=setmetatable({}, {__mode='k'}),cache=setmetatable({}, {__mode='k'}),status='WAIT_SCENE',requests=0}
if ff3Options.AdaptiveAngle~=nil then controller.angle.enabled=ff3Options.AdaptiveAngle end
env.PELICAN_FF3_ADAPTIVE_ANGLE=controller.angle.enabled
-- Explicit application risk policies, not calibrated game catch windows.
local riskPolicy={profiles={SAFE={margin=6,lane=4},
    MOD={margin=2,lane=CFG.ThrowLane,race=.08,lateral=3,turn=.25,arrivalSlack=.05},
    TRUST={margin=-2,lane=-4,race=-.02,lateral=6,turn=.5,arrivalSlack=.1}}}
-- Deliberate contest policy, not a measured FF3 catch radius/probability.
riskPolicy.burn={gap=4,contestFraction=.25,contestSeconds=.25}
function riskPolicy.normalize(value)
    if type(value)~='string' then return end
    value=value:upper();if value=='MODERATE' then value='MOD' end
    return riskPolicy.profiles[value] and value or nil
end
riskPolicy.mode=riskPolicy.normalize(ff3Options.RiskMode or 'TRUST')
assert(riskPolicy.mode,'FF3.RiskMode must be SAFE, MOD or TRUST')
env.PELICAN_FF3_RISK_MODE=riskPolicy.mode
local closeBullet=ff3Options.CloseBullet
if closeBullet==nil then closeBullet={} end
if closeBullet==false then closeBullet={Enabled=false} end
assert(type(closeBullet)=='table','FF3.CloseBullet must be a table or false')
assert(closeBullet.Enabled==nil or type(closeBullet.Enabled)=='boolean','CloseBullet.Enabled must be boolean')
local touch={enabled=closeBullet.Enabled~=false,min=closeBullet.MinPower or 20,full=closeBullet.FullPowerYards,
    comfort=closeBullet.ComfortSeconds or .9,quick=closeBullet.WindowSeconds or .65,method='POWER',methodReason='NOT_PROBED',traces={},origins=setmetatable({}, {__mode='k'})}
assert(finite(touch.min) and touch.min>=1 and touch.min<95 and (touch.full==nil or finite(touch.full) and touch.full>0 and touch.full<=100)
    and finite(touch.comfort) and touch.comfort>=.3 and touch.comfort<=1.5 and finite(touch.quick) and touch.quick>=.2 and touch.quick<touch.comfort,'Invalid CloseBullet comfort/power policy')
-- BEGIN RETAINED HISTORY
-- Isolated scope keeps this optional recorder outside the native solve/release path.
controller.history=(function()
    local h={storage='NOT_STARTED',sync='OFF',dirty=false,lastDisk=-math.huge,lastSync=-math.huge,aliases={},aliasCount=0,blocked={}}
    local options=ff3Options.History
    if options==nil then options={} end
    if options==false then options={Enabled=false} end
    assert(type(options)=='table','FF3.History must be a table or false')
    h.enabled=options.Enabled~=false
    local cacheKey='PELICAN_FF3_HISTORY_V1'
    local schema='PELICAN_FF3_HISTORY_V1'
    local paths={'PELICAN_FF3_HISTORY_A.json','PELICAN_FF3_HISTORY_B.json'}
    local maxRecords,maxBytes=100,80000
    local codec,cache,data,runId,sessionId,started,ended
    local cfg=env.PELICAN_FF3_JSONBIN
    local accessKey,binId,requestFn
    local keyHeader='X-Access-Key'
    local async=type(task)=='table' and type(task.defer)=='function' and type(task.cancel)=='function'
    local interval=120
    local function number(n) return type(n)=='number' and n==n and math.abs(n)<1e12 end
    local function integer(n) return number(n) and n>=0 and n%1==0 end
    local function safe(value,depth,budget)
        if budget.n>=3000 then return nil end
        budget.n=budget.n+1
        if type(value)=='boolean' then return value end
        if number(value) then return value end
        if type(value)=='string' then return value:sub(1,100) end
        if type(value)~='table' or getmetatable(value)~=nil or depth>=6 then return nil end
        local out={};local n=0
        for k,v in pairs(value) do
            n=n+1;if n>128 then break end
            if type(k)=='string' and #k<=40 or integer(k) and k>=1 and k<=128 then out[k]=safe(v,depth+1,budget) end
        end
        return out
    end
    local kinds={run_start=true,throw=true,blocked=true,run_end=true,possession_end=true}
    local function valid(d)
        if type(d)~='table' or d.Schema~=schema or type(d.Writer)~='string' or #d.Writer<1 or #d.Writer>100
            or not integer(d.Revision) or type(d.Records)~='table' or #d.Records>maxRecords or type(d.Totals)~='table' then return false end
        local n=0
        for k,r in pairs(d.Records) do
            n=n+1
            if not integer(k) or k<1 or k>#d.Records or type(r)~='table' or type(r.Id)~='string' or #r.Id>150
                or type(r.Run)~='string' or #r.Run>100 or not integer(r.Seq) or r.Seq>d.Revision
                or not kinds[r.Kind] or type(r.Payload)~='table' or r.Id~=d.Writer..':'..r.Seq then return false end
        end
        if n~=#d.Records then return false end
        local previous=0;for _,r in ipairs(d.Records) do if r.Seq<=previous then return false end;previous=r.Seq end
        for k,v in pairs(d.Totals) do
            if not ({Runs=true,Requests=true,Accepted=true,Ambiguous=true,Blocked=true,Errors=true,Evicted=true})[k] or not integer(v) then return false end
        end
        return true
    end
    local function decode(text)
        if not codec or type(text)~='string' or #text>maxBytes+8192 then return end
        local ok,value=pcall(function() return codec:JSONDecode(text) end)
        if ok and valid(value) then return value end
        return nil,ok and type(value)=='table' and value.Schema~=schema and 'FOREIGN_SCHEMA' or 'INVALID'
    end
    local function guid()
        if codec then
            local ok,value=pcall(function() return codec:GenerateGUID(false) end)
            if ok and type(value)=='string' and #value>0 and #value<=90 then return value end
        end
        cache.serial=(cache.serial or 0)+1
        return tostring(os.time())..'-'..tostring(math.floor(os.clock()*1000000))..'-'..cache.serial
    end
    local function total(key) data.Totals[key]=(data.Totals[key] or 0)+1 end
    local function trim()
        while #data.Records>maxRecords do table.remove(data.Records,1);total('Evicted') end
    end
    local function encode()
        if h.RefreshCurrentSettings then h.RefreshCurrentSettings() end
        if controller.receiverEvidence and controller.receiverEvidence.SnapshotActive then controller.receiverEvidence.SnapshotActive() end
        if not codec then return end
        trim()
        while true do
            local ok,text=pcall(function() return codec:JSONEncode(data) end)
            if not ok or type(text)~='string' then h.storage='ENCODE_FAILED';return end
            if #text<=maxBytes then return text end
            if #data.Records==0 then h.storage='SIZE_INVALID';return end
            table.remove(data.Records,1);total('Evicted')
        end
    end
    function h.Append(kind,payload)
        if not h.enabled or not started or ended or not kinds[kind] then return end
        data.Revision=data.Revision+1
        local record={Id=data.Writer..':'..data.Revision,Seq=data.Revision,Run=runId,Session=sessionId,Kind=kind,
            Release='experimental-unified-b3.7',Place=game.PlaceId,At=os.time(),Clock=os.clock(),Payload=safe(payload or {},0,{n=0}) or {}}
        data.Records[#data.Records+1]=record;trim();h.dirty=true
        if kind=='run_start' then total('Runs') elseif kind=='throw' then
            total('Requests');total(record.Payload.Api=='API_ACCEPTED_UNCONFIRMED' and 'Accepted' or 'Ambiguous')
        elseif kind=='blocked' then total('Blocked') elseif kind=='run_end' and record.Payload.Error then total('Errors') end
        return record.Id
    end
    function h.RefreshCurrentSettings()
        local e=controller.receiverEvidence
        if not started or ended or not data or not e then return end
        local settings=e.ReadSettings()
        if not next(settings) then return end -- preserve last verified snapshot; never substitute defaults
        local context=e.NativeContext()
        local control=touch.lastControl or {}
        local values={tostring(controller.safety.enabled),tostring(controller.reactivity.enabled),riskPolicy.mode,tostring(controller.coverageWindows.enabled),tostring(controller.jumpTiming.delay),controller.league.mode,tostring(controller.nativeJump.enabled),tostring(controller.passPlan.openComfort),controller.receiverFilter.mode,tostring(controller.angle.enabled),tostring(controller.mag.enabled),tostring(controller.mag.extraY),controller.passPlan.mode,tostring(controller.passPlan.deepYards),tostring(controller.passPlan.preferJump),table.concat(context.SignatureParts or {context.Signature or ''}),touch.method,touch.methodReason,tostring(control.Variant),tostring(control.Requested),tostring(control.Returned),tostring(control.Reason)}
        for _,mode in ipairs({'Bullet','Fit','Jump','Dive','Dime'}) do
            local value=settings[mode];values[#values+1]=value and string.format('%.17g,%.17g',value.X,value.Y) or 'UNAVAILABLE'
        end
        local signature=table.concat(values,':')
        if h.settingsSignature==signature then return end
        h.settingsSignature=signature
        data.CurrentSettings=safe({Session=sessionId,Run=runId,ObservedAt=os.time(),Leads=settings,NativeContext=context,
            Source='QUALIFIED_SHARED_NATIVE_SETTINGS',UnifiedParameters=controller.unified.config,SafetyReads=controller.safety.enabled,ReactiveWindows=controller.reactivity.enabled,RiskMode=riskPolicy.mode,JumpDelaySeconds=controller.jumpTiming.delay,CoverageWindows=controller.coverageWindows.enabled,Profile=controller.league.mode,NativeJump=controller.nativeJump.enabled,OpenComfort=controller.passPlan.openComfort,ReceiverFilter=controller.receiverFilter.mode,AdaptiveAngle=controller.angle.enabled,MagTrial={Enabled=controller.mag.enabled,ExtraY=controller.mag.extraY,Calibration='MISSING'},PassPlan=controller.passPlan.mode,DeepYards=controller.passPlan.deepYards,WideOpenJump=controller.passPlan.preferJump,BulletControl=touch.lastControl,BulletMethod=touch.method,BulletMethodReason=touch.methodReason,CloseBullet={Enabled=touch.enabled,MinPower=touch.min,ComfortSeconds=touch.comfort,WindowSeconds=touch.quick}},0,{n=0})
        data.Revision=data.Revision+1;h.dirty=true
    end
    function h.Records() return data and data.Records or {} end
    function h.SessionKey() return sessionId end
    function h.AttachObservation(id,value)
        controller.bad:observe(id,value)
        if not started or ended then return false end
        for _,record in ipairs(data.Records) do if record.Id==id and record.Kind=='throw' then
            record.Payload.Observation=safe(value,0,{n=0});data.Revision=data.Revision+1;h.dirty=true;return true
        end end
        return false
    end
    function h.Actor(name,s)
        if not s then return end
        if not h.aliases[name] then
            if h.aliasCount>=64 then return {Id='OTHER'} end
            h.aliasCount=h.aliasCount+1;h.aliases[name]='P'..h.aliasCount
        end
        return {Id=h.aliases[name],Position=h.Vector(s.p),Velocity=h.Vector(s.v),ObservedSpeed=s.observedSpeed,WalkSpeed=s.hum and s.hum.WalkSpeed}
    end
    function h.Vector(v)
        if not v then return end
        return {v.X,v.Y,v.Z}
    end
    function h.Shot(shot,player,s,api,source,defenders)
        if not h.enabled or not shot then return end
        local actors={}
        for i,d in ipairs(defenders or {}) do if i>12 then break end;actors[#actors+1]=h.Actor(d.name,d) end
        local comparisons={}
        local cached=player and shotCache[player]
        for _,mode in ipairs({'SoftBullet','QuickBullet','Bullet','Fit','Dime','Jump','JumpBullet','CoverageJump','MagDime'}) do
            local other=cached and cached.shots and cached.shots[mode]
            if other then comparisons[#comparisons+1]={Mode=mode,Power=other.power,Time=other.time,Arrival=h.Vector(other.arrival),
                Margin=other.margin,Lane=other.lane,DefenderETA=other.defenderETA,Age=os.clock()-other.at} end
        end
        return h.Append('throw',{Epoch=possession.epoch,Source=source or 'AUTO_QB',Api=api,Catch='UNKNOWN',
            Mode=shot.mode,Variant=shot.variant or shot.mode,NativeMode=shot.nativeMode,Risk=riskPolicy and riskPolicy.mode,
            JumpDelayTarget=controller.jumpTiming.delay,JumpObservedDelay=source~='MANUAL_AWAY' and sequence and sequence.jumpObservedDelay or nil,JumpTimingSource=source~='MANUAL_AWAY' and sequence and sequence.jumpTimingSource or nil,SafetyRead=shot.safetyRead,ContestedChestThreat=shot.contestedChestThreat,CoverageLayers=shot.coverageLayers,FitReason=shot.fitReason,FitComparison=shot.fitAlternativeVariant,FitSecondComparison=shot.fitSecondVariant,Profile=controller.league.mode,ProfileSource=controller.league.source,Screen=shot.screen,NativeCoverageJump=shot.nativeCoverageJump,OpenComfort=controller.passPlan.openComfort,JumpBulletReason=shot.jumpBulletReason,JumpBulletChest=shot.jumpBulletChest,ReceiverFilter=controller.receiverFilter.mode,PassPlan=controller.passPlan.mode,CatchDepthYards=shot.catchDepthYards,DeepComeback=shot.deepComeback,WideOpen=shot.wideOpen,WideMargin=shot.wideMargin,WideLane=shot.wideLane,JumpPreferred=shot.jumpPreferred,
            Power=shot.power,RequestedPower=shot.requestedPower,PowerMethod=shot.powerMethod,Time=shot.time,
            Origin=h.Vector(shot.origin),Velocity=h.Vector(shot.velocity),Arrival=h.Vector(shot.arrival),Gravity=CFG.Gravity,
            MinimumFlight=shot.minimumFlight,PowerPolicyReason=shot.powerReason,CloseBulletEnabled=touch.enabled,
            Receiver=h.Actor(player and player.Name or 'AWAY',s),Comparisons=comparisons,Defenders=actors,DefenderCount=#(defenders or {}),
            Margin=shot.margin,Lane=shot.lane,DefenderETA=shot.defenderETA,ReceiverResidual=shot.receiverResidual,TrustBurn=shot.trustBurn,
            LeadSettings=controller.receiverEvidence and controller.receiverEvidence.ReadSettings(),
            EffectiveYLead=shot.effectiveYLead,VerticalLeadControlActive=shot.verticalLeadControlActive,
            LeadControls=controller.receiverEvidence and controller.receiverEvidence.Bindings(shot),
            NativeContext=controller.receiverEvidence and controller.receiverEvidence.NativeContext(),
            Lead=shot.appliedLead and {shot.appliedLead.X,shot.appliedLead.Y},ManualInput=shot.nativeInput,
            Unified=controller.bad:result(shot.unified),MagTrial=shot.magTrial,MagExtraY=shot.magExtraY,MagTrustSource=shot.magTrustSource,
            MagBaseLead=shot.magBaseLead and {shot.magBaseLead.X,shot.magBaseLead.Y},MagCatchCalibration=shot.magTrial and 'MISSING; ANGLE_REQUIRED_UNVERIFIED' or nil,
            ActualAngleDegrees=shot.actualAngle,AdaptiveAngle=shot.angleControl~=nil,AngleRequest=shot.angleControl,NativeAngleAdjustment=shot.nativeAngleAdjustment,EndzoneTarget=shot.endzoneTarget,
            InputKind=shot.nativeInputKind,Ping=shot.networkPing,DistanceYards=shot.passYards,
            FitReason=shot.fitReason,ComparedMode=shot.fitAlternativeVariant,ComparedTime=shot.fitAlternativeTime,
            ComparedDBETA=shot.fitAlternativeDB,OverTop=shot.safetyOverTop,ClearBurn=shot.clearBurn,
            LOS=lines.status,LOSDirection=h.Vector(lines.forward),LOSPosition=h.Vector(lines.los),
            Jump=assistance.jumpStatus,Animation=animationStatus})
    end
    function h.Block(player,shot,reason,s,evidence)
        if not h.enabled or not started then return end
        local stage=evidence and evidence.stage or 'PLANNER_CANDIDATE'
        local key=tostring(shot.variant or shot.mode)..':'..tostring(reason)..':'..stage
        if h.blocked[key] and os.clock()-h.blocked[key]<10 then return end
        -- Fixed-size throttle map, independent of roster/usernames.
        local n=0;for _ in pairs(h.blocked) do n=n+1 end;if n>=64 and not h.blocked[key] then h.blocked={} end
        h.blocked[key]=os.clock()
        local trials={};local cache=shotCache[player]
        if cache and (cache.model~=player.Character or cache.epoch~=possession.epoch or cache.generation~=lines.generation) then cache=nil end
        for _,variant in ipairs({'SoftBullet','QuickBullet','Bullet','Fit','Dime','Jump','JumpBullet','CoverageJump','MagDime'}) do
            local previous=cache and cache.shots[variant]
            local rejected=receiverRejects[player.Name..'/'..variant]
            if previous or rejected then
                trials[#trials+1]={Variant=variant,LastPlanningFailure=rejected,
                    FailureAge=rejected and math.max(0,os.clock()-receiverRejectAt),
                    ReturnedAtAge=previous and math.max(0,os.clock()-previous.at),
                    Time=previous and previous.time,Power=previous and previous.power}
            end
        end
        h.Append('blocked',{Epoch=possession.epoch,Reason=reason,Mode=shot.mode,Variant=shot.variant,
            EvidenceStage=stage,TrajectoryAge=shot.at and math.max(0,os.clock()-shot.at),
            SolverFailure=evidence and evidence.failure,ModeTrials=trials,
            ModeTrialsScope='LAST_NATIVE_RETURNS_AND_LAST_PLANNING_FAILURES; NOT_CURRENT_COVERAGE',
            BulletControlScope='LAST_GLOBAL_CONTROL_TRACE; NOT_RECEIVER_PROOF',
            Power=shot.power,RequestedPower=shot.requestedPower,PowerMethod=shot.powerMethod,Time=shot.time,
            MinimumFlight=shot.minimumFlight,PowerPolicyReason=shot.powerReason,BulletControl=touch.lastControl,
            Origin=h.Vector(shot.origin),Velocity=h.Vector(shot.velocity),Arrival=h.Vector(shot.arrival),
            Margin=shot.margin,Lane=shot.lane,Receiver=h.Actor(player.Name,s),
            Unified=controller.bad:result(shot.unified),Risk=riskPolicy.mode,Ping=shot.networkPing,DirectLane=shot.directLane,
            DefenderETA=shot.defenderETA,ReceiverETA=shot.receiverETA,RaceAdvantage=shot.raceAdvantage,
            RouteLateral=shot.routeLateral,ReceiverTurn=shot.receiverTurn,OverTop=shot.safetyOverTop,BurnCandidate=shot.burnCandidate,TrustBurn=shot.trustBurn,
            FitReason=shot.fitReason,FitComparison=shot.fitAlternativeVariant,FitSecondComparison=shot.fitSecondVariant,
            PlanReason=shot.planReason,ReleaseBlocked=shot.releaseBlocked,SafetyRead=shot.safetyRead,ContestedChestThreat=shot.contestedChestThreat,
            MarginDefender=h.Actor(shot.marginDB or 'NONE',shot.marginActor),LaneDefender=h.Actor(shot.laneDB or 'NONE',shot.laneActor)})
    end
    function h.Flush()
        if not h.enabled or not started or not h.dirty or h.flushing then return end
        if cache.diskUnsafe then return end
        if not codec then h.storage='NO_JSON_MEMORY_ONLY';return end
        if not h.canWrite then return end
        local text=encode();if not text then return end
        local revision=data.Revision
        local slot=cache.nextSlot or 1
        h.diskIO=true;h.flushing=true
        local ok=pcall(writefile,paths[slot],text)
        if not ok then h.diskIO=false;h.flushing=false;cache.diskUnsafe=true;h.storage='WRITE_FAILED_MEMORY_ONLY';return end
        if type(readfile)=='function' then
            local readOK,saved=pcall(readfile,paths[slot])
            if not readOK or saved~=text then h.diskIO=false;h.flushing=false;cache.diskUnsafe=true;h.storage='READBACK_FAILED_MEMORY_ONLY';return end
            h.storage='READBACK_VERIFIED'
        else h.storage='WRITE_ACCEPTED_NO_READBACK' end
        if cache.diskUnsafe then h.storage='IO_UNCERTAIN_MEMORY_ONLY' end
        h.savedRevision=revision
        h.diskIO=false;h.flushing=false;cache.nextSlot=slot==1 and 2 or 1
        if data.Revision==revision then h.dirty=false end
        h.lastDisk=os.clock()
    end
    local function response(method,body)
        local options={Url='https://api.jsonbin.io/v3/b/'..binId..(method=='GET' and '/latest' or ''),
            Method=method,Headers={[keyHeader]=accessKey,['X-Bin-Meta']='true',['User-Agent']='PelicanFF3History/26.21'},Timeout=15}
        if body then options.Headers['Content-Type']='application/json';options.Headers['X-Bin-Versioning']='false';options.Body=body end
        h.netIO=method
        local ok,result=pcall(requestFn,options)
        h.netIO=nil
        if not ok or type(result)~='table' then return nil,'NETWORK_FAILED' end
        if result.StatusCode~=200 then return nil,'HTTP_'..tostring(tonumber(result.StatusCode) or 0) end
        if type(result.Body)~='string' or #result.Body>maxBytes+8192 then return nil,'RESPONSE_SIZE' end
        local parsedOK,parsed=pcall(function() return codec:JSONDecode(result.Body) end)
        if not parsedOK or type(parsed)~='table' or type(parsed.metadata)~='table' or parsed.metadata.private~=true
            or type(parsed.record)~='table' then return nil,'PRIVATE_RESPONSE_NOT_VERIFIED' end
        return parsed.record
    end
    local function equal(a,b,depth)
        if type(a)~=type(b) then return false end
        if type(a)~='table' then return a==b end
        if depth>10 then return false end
        for k,v in pairs(a) do if not equal(v,b[k],depth+1) then return false end end
        for k in pairs(b) do if a[k]==nil then return false end end
        return true
    end
    function h.Snapshot(currentSession)
        local text=encode();if not text then return end
        local snapshot=decode(text);if not snapshot then return end
        if currentSession then
            local records={}
            for _,record in ipairs(snapshot.Records) do if record.Session==sessionId then records[#records+1]=record end end
            snapshot.Records=records;snapshot.Scope='CURRENT_SESSION';snapshot.Session=sessionId
            if snapshot.CurrentSettings and snapshot.CurrentSettings.Session~=sessionId then snapshot.CurrentSettings=nil end
            snapshot.TotalsScope='RETAINED_SESSION_RECORDS';snapshot.RetainedOnly=true
            while true do
                local totals={}
                local function count(key) totals[key]=(totals[key] or 0)+1 end
                for _,record in ipairs(records) do
                    if record.Kind=='run_start' then count('Runs')
                    elseif record.Kind=='throw' then count('Requests');count(record.Payload.Api=='API_ACCEPTED_UNCONFIRMED' and 'Accepted' or 'Ambiguous')
                    elseif record.Kind=='blocked' then count('Blocked')
                    elseif record.Kind=='run_end' and record.Payload.Error then count('Errors') end
                end
                snapshot.Totals=totals
                local ok,encoded=pcall(function() return codec:JSONEncode(snapshot) end)
                if not ok or type(encoded)~='string' then return end
                if #encoded<=maxBytes then text=encoded;break end
                if #records==0 then return end
                table.remove(records,1)
            end
        end
        return text,snapshot
    end
    function h.Sync(currentSession)
        local body,snapshot=h.Snapshot(currentSession)
        if not body then h.sync='SNAPSHOT_INVALID';return end
        local remote,why=response('GET')
        if not remote then h.sync=why;return end
        local empty=next(remote)==nil
        if remote.Schema=='PELICAN_FF3_HISTORY_EMPTY_V1' then
            empty=true;for k in pairs(remote) do if k~='Schema' then empty=false end end
        end
        if empty and cfg.Initialize==true then -- explicitly marked/empty dedicated bin only
        elseif not valid(remote) then h.sync='FOREIGN_SCHEMA_PRESERVED';return
        elseif remote.Writer~=snapshot.Writer then h.sync='OTHER_WRITER_PRESERVED';return
        elseif remote.Revision>snapshot.Revision then h.sync='REMOTE_AHEAD_PRESERVED';return
        elseif remote.Scope~=nil and remote.Scope~='CURRENT_SESSION' then h.sync='FOREIGN_SCOPE_PRESERVED';return end
        if valid(remote) and remote.Revision==snapshot.Revision then
            if equal(remote,snapshot,0) then h.syncedRevision=snapshot.Revision;h.sync='READBACK_VERIFIED';return end
            -- The explicit companion switches the same writer between full and
            -- current-session views. Other same-revision conflicts stay refused.
            if remote.Scope==snapshot.Scope then h.sync='REVISION_CONFLICT_PRESERVED';return end
        end
        local saved,err=response('PUT',body)
        if not saved or not equal(snapshot,saved,0) then cache.remoteUnsafe=true;h.sync=err or 'PUT_ECHO_MISMATCH_NO_RETRY';return end
        local confirmed,readError=response('GET')
        if not confirmed or not equal(snapshot,confirmed,0) then cache.remoteUnsafe=true;h.sync=readError or 'READBACK_MISMATCH_NO_RETRY';return end
        h.syncedRevision=snapshot.Revision;h.sync='READBACK_VERIFIED'
    end
    local function schedule(field,fn,job)
        local token={at=os.clock(),job=job};h[field]=token
        token.thread=task.defer(function()
            if ended or h[field]~=token then return end
            local ok=pcall(fn)
            if not ok then
                if field=='netWorker' then h.sync='WORKER_FAILED_NO_RETRY';cache.remoteUnsafe=true
                else h.storage='WORKER_FAILED_MEMORY_ONLY';cache.diskUnsafe=true end
            end
            if h[field]==token then h[field]=nil end
        end)
        return token
    end
    function h.RequestUpload()
        if ended or not started or not h.enabled then return nil,'HISTORY_NOT_RUNNING' end
        if not h.remoteReady then return nil,h.sync end
        if cache.remoteUnsafe then return nil,'IO_UNCERTAIN_NO_RETRY' end
        if h.netWorker then return nil,'UPLOAD_BUSY' end
        h.uploadSerial=(h.uploadSerial or 0)+1
        local job={Id=h.uploadSerial,State='UPLOADING',Scope=cfg.CurrentSessionOnly and 'CURRENT_SESSION' or 'FULL_HISTORY'}
        h.upload=job;h.lastSync=os.clock();h.sync='SYNCING'
        schedule('netWorker',function()
            local ok=pcall(h.Sync,cfg.CurrentSessionOnly==true)
            if not ok then h.sync='WORKER_FAILED_NO_RETRY';cache.remoteUnsafe=true end
            job.State=h.sync;job.Revision=h.sync=='READBACK_VERIFIED' and h.syncedRevision or nil
        end,job)
        return job
    end
    function h.CancelUpload(job)
        if not job or h.upload~=job then return true end
        if not h.netWorker or h.netWorker.job~=job then
            if job.State=='UPLOADING' then job.State='CANCELLED' end
            return true
        end
        if h.netWorker and h.netWorker.job==job then
            local token=h.netWorker
            if h.netIO then cache.remoteUnsafe=true end
            if not pcall(task.cancel,token.thread) then return false end
            h.netWorker=nil
        end
        job.State='CANCELLED';h.sync=cache.remoteUnsafe and 'STOPPED_IO_UNCERTAIN_NO_RETRY' or 'READY'
        return true
    end
    function h.ConfigureJSONBin(value)
        if ended or not started then return false,'HISTORY_NOT_RUNNING' end
        if h.netWorker then return false,'UPLOAD_BUSY' end
        h.remoteReady=false
        if type(value)~='table' or type(value.BinId)~='string' or #value.BinId~=24 or not value.BinId:match('^%x+$')
            or value.AccessKey~=nil and value.MasterKey~=nil then h.sync='CONFIG_INVALID';return false,h.sync end
        local key=value.MasterKey or value.AccessKey
        if type(key)~='string' or #key<1 then h.sync='CONFIG_INVALID';return false,h.sync end
        for _,name in ipairs({'Initialize','ManualOnly','CurrentSessionOnly'}) do
            if value[name]~=nil and type(value[name])~='boolean' then h.sync='CONFIG_INVALID';return false,h.sync end
        end
        local seconds=value.IntervalSeconds or 120
        if not number(seconds) or seconds<60 or seconds>3600 then h.sync='INTERVAL_INVALID';return false,h.sync end
        if not codec then h.sync='JSON_UNAVAILABLE';return false,h.sync end
        if not async then h.sync='ASYNC_UNAVAILABLE';return false,h.sync end
        requestFn=request or http_request or (type(syn)=='table' and syn.request) or (type(http)=='table' and http.request)
        if type(requestFn)~='function' then h.sync='HTTP_UNAVAILABLE';return false,h.sync end
        cfg={BinId=value.BinId,Initialize=value.Initialize==true,ManualOnly=value.ManualOnly==true,CurrentSessionOnly=value.CurrentSessionOnly==true}
        binId=value.BinId;accessKey=key;keyHeader=value.MasterKey~=nil and 'X-Master-Key' or 'X-Access-Key';interval=seconds
        h.remoteReady=true;h.sync=cache.remoteUnsafe and 'PREVIOUS_IO_UNCERTAIN_NO_RETRY' or 'READY'
        h.lastSync=os.clock()-interval+10
        return true,h.sync
    end
    function h.Update(now)
        if not h.enabled or not started or ended then return end
        if now>=(h.nextSettingsAt or 0) then h.nextSettingsAt=now+1;h.RefreshCurrentSettings() end
        if h.diskWorker and now-h.diskWorker.at>20 then
            local token=h.diskWorker
            if pcall(task.cancel,token.thread) then h.diskWorker=nil end
            cache.diskUnsafe=true;h.storage='TIMEOUT_MEMORY_ONLY'
        end
        if h.netWorker and now-h.netWorker.at>20 then
            local token=h.netWorker
            if pcall(task.cancel,token.thread) then h.netWorker=nil end
            cache.remoteUnsafe=true;h.sync='TIMEOUT_NO_RETRY'
            if h.upload and h.upload.State=='UPLOADING' then h.upload.State=h.sync end
        end
        if h.dirty and now-h.lastDisk>=10 and not h.diskWorker and h.canWrite and not cache.diskUnsafe then
            h.lastDisk=now
            if async then schedule('diskWorker',h.Flush) end -- synchronous fallback is confined to preserve/stop
        end
        if h.remoteReady and not cfg.ManualOnly and not cache.remoteUnsafe and not h.netWorker and now-h.lastSync>=interval
            and h.syncedRevision~=data.Revision and (h.sync=='READY' or h.sync=='READBACK_VERIFIED') then
            h.lastSync=now;h.sync='SYNCING';schedule('netWorker',function() h.Sync(cfg.CurrentSessionOnly) end)
        end
    end
    function h.Start()
        if ended or started or not h.enabled then h.storage='OFF';return end
        local ok,value=pcall(function() return game:GetService('HttpService') end)
        if ok and value and type(value.JSONEncode)=='function' and type(value.JSONDecode)=='function' then codec=value end
        cache=env[cacheKey]
        if type(cache)~='table' or getmetatable(cache)~=nil then cache={};env[cacheKey]=cache end
        if valid(cache.data) then data=cache.data end
        h.canWrite=type(writefile)=='function' and type(readfile)=='function'
        local sawInvalid,unreadable,foreign=false,false,false
        local bestSlot
        if codec and type(readfile)=='function' then
            for i,path in ipairs(paths) do
                local exists=true
                if type(isfile)=='function' then local checkOK,result=pcall(isfile,path);if checkOK and type(result)=='boolean' then exists=result else unreadable=true;exists=false end end
                if exists then
                    local readOK,text=pcall(readfile,path)
                    if readOK then
                        local candidate,reason=decode(text)
                        if reason=='FOREIGN_SCHEMA' then foreign=true end
                        if candidate and (not data or candidate.Revision>data.Revision) then data=candidate;bestSlot=i
                        elseif not candidate then sawInvalid=true end
                    else
                        local message=tostring(text):lower()
                        local missing=message:find('not found',1,true) or message:find('does not exist',1,true) or message:find('no such file',1,true)
                        if type(isfile)=='function' or not missing then unreadable=true end
                    end
                end
            end
        end
        if ended then return end
        if bestSlot then cache.nextSlot=bestSlot==1 and 2 or 1 end
        if foreign or unreadable or sawInvalid and not data then cache.diskUnsafe=true end
        if not data then data={Schema=schema,Writer=guid(),Revision=0,Records={},Totals={}} end
        cache.data=data;runId=guid()
        if type(cache.sessionId)~='string' or #cache.sessionId<1 or #cache.sessionId>100 or cache.sessionJobId~=game.JobId then
            cache.sessionId=guid();cache.sessionJobId=game.JobId -- server ID stays in memory, never in history
        end
        sessionId=cache.sessionId;started=true
        h.storage=not codec and 'NO_JSON_MEMORY_ONLY' or cache.diskUnsafe and 'UNREADABLE_PRESERVED_MEMORY_ONLY'
            or type(readfile)~='function' and 'NO_READFILE_MEMORY_ONLY' or not h.canWrite and 'NO_FILES_MEMORY_ONLY' or 'READY'
        h.Append('run_start',{Runtime=VERSION,PreviousRecords=#data.Records,DiskRecovered=bestSlot~=nil})
        if cfg~=nil then h.ConfigureJSONBin(cfg) end
    end
    function h.Export()
        if not started then return nil,'OFF' end
        local text=encode()
        if not text then return nil,'JSON_UNAVAILABLE' end
        if type(setclipboard)~='function' then return nil,'CLIPBOARD_UNAVAILABLE' end
        local ok=pcall(setclipboard,text)
        return ok,ok and 'API_ACCEPTED' or 'COPY_FAILED'
    end
    function h.Report()
        return 'HISTORY_STORAGE|'..h.storage..'\nHISTORY_RECORDS|'..tostring(data and #data.Records or 0)
            ..'\nHISTORY_JSONBIN|'..h.sync..'\nHISTORY_SYNCED_REVISION|'..tostring(h.syncedRevision or 'NONE')
            ..'\nHISTORY_UPLOAD_MODE|'..(type(cfg)=='table' and cfg.ManualOnly and 'MANUAL_ONLY' or 'AUTOMATIC')
            ..'\nHISTORY_UPLOAD_RESULT|'..(h.upload and h.upload.State or 'NONE')
            ..'\nHISTORY_REVISION|'..tostring(data and data.Revision or 0)..'\nHISTORY_SAVED_REVISION|'..tostring(h.savedRevision or 'NONE')..'\nHISTORY_LIMIT|100_RECORDS_AND_80000_BYTES; OUTCOMES_UNKNOWN; NO_AUTO_TUNING'
    end
    function h.Stop(reason,hasError)
        if ended then return true end
        if not started then ended=true;return true end
        if not h.ending then h.Append('run_end',{Reason=reason,Error=hasError==true});h.ending=true end
        for _,field in ipairs({'netWorker','diskWorker'}) do
            local token=h[field]
            if token then
                h[field]=nil
                if field=='netWorker' and h.netIO then cache.remoteUnsafe=true;h.sync='STOPPED_IO_UNCERTAIN_NO_RETRY'
                elseif field=='diskWorker' and h.diskIO then cache.diskUnsafe=true;h.storage='IO_UNCERTAIN_MEMORY_ONLY' end
                local ok=pcall(task.cancel,token.thread)
                if not ok then h[field]=token;return false end
                if field=='diskWorker' then h.diskIO=false;h.flushing=false end
            end
        end
        -- A synchronous COPY/file API may be yielding on another callback.
        -- Do not confirm cleanup until it returns; replacement stays blocked.
        if h.flushing then cache.diskUnsafe=true;h.storage='IO_UNCERTAIN_MEMORY_ONLY';return false end
        if h.upload and h.upload.State=='UPLOADING' then h.upload.State='CANCELLED' end
        h.Flush();ended=true;accessKey=nil
        return h.netWorker==nil and h.diskWorker==nil
    end
    return h
end)()
-- END RETAINED HISTORY

local function closePower(player,quick)
    if not touch.enabled then return end
    local model=player.Character
    local target=model and model:FindFirstChild('Head')
    local root=model and model:FindFirstChild('HumanoidRootPart')
    local head=me.Character and me.Character:FindFirstChild('Head')
    if not target or not root or not head or not profile then return end
    local v=root.AssemblyLinearVelocity;local speed=math.sqrt(v.X*v.X+v.Z*v.Z)
    local origin=head.Position
    local known=touch.origins[player]
    if known and known.profile==profile and known.epoch==possession.epoch and os.clock()-known.at<=CFG.CacheAge then
        origin=known.origin+(head.Position-known.head)
    end
    local lead=profile.leads.Bullet;local ping=me:GetNetworkPing()
    if not finite(ping) or ping<0 then return end
    local function estimate(time)
        local x=target.Position.X+v.X*(time+ping)+(speed>0 and v.X/speed*lead.X or 0)-origin.X
        local z=target.Position.Z+v.Z*(time+ping)+(speed>0 and v.Z/speed*lead.X or 0)-origin.Z
        local y=target.Position.Y+lead.Y-origin.Y
        -- Estimate a power request only. Native output supplies the actual
        -- flight, lead, origin and low-arc trajectory, then coverage grades it.
        return math.floor(math.max(touch.min,math.min(94,math.sqrt((x*x+z*z)/(time*time)+(y/time+CFG.Gravity*time/2)^2))))
    end
    local gentle=estimate(touch.comfort)
    if quick then local power=estimate(touch.quick);if power<=gentle then return end;return power,touch.quick end
    return gentle,touch.comfort
end
for _,key in ipairs({'MovementGuide','PredictiveJump'}) do
    if ff3Options[key]~=nil and type(ff3Options[key])~='boolean' then error('PELICAN: '..key..' must be boolean') end
end
for _,key in ipairs({'ReceiverSwitchYards'}) do
    local value=ff3Options[key]
    if value~=nil then
        if not finite(value) or value<1 or value>100 then error('PELICAN: '..key..' must be 1 to 100 yards') end
        CFG[key]=value
    end
end
local function nativeVector(x)
    if x==nil then return end
    local kind=typeof(x)
    if kind=='vector' then
        if finite(x.x) and finite(x.y) and finite(x.z) then return V(x.x,x.y,x.z) end
    elseif kind=='Vector3' or type(x)=='table' then
        if finite(x.X) and finite(x.Y) and finite(x.Z) then return x end
    end
end
local function vector(x) return nativeVector(x)~=nil end
local function flat(v) return V(v.X,0,v.Z) end
local function clamp(x,a,b) return math.max(a,math.min(b,x)) end
local function instance(v,k)
    return typeof(v)=='Instance' and v:IsA(k)
end
local function body(player)
    local model=player and player.Character
    if not model or not model:IsDescendantOf(workspace) then return end
    local hum,root,head=model:FindFirstChildOfClass('Humanoid'),model:FindFirstChild('HumanoidRootPart'),model:FindFirstChild('Head')
    if not hum or hum.Health<=0 or not root or not head or not vector(root.Position) or not vector(head.Position) then return end
    return model,root,head,hum
end
local function receiverKey(player)
    if type(player.UserId)=='number' and player.UserId>0 and player.UserId<1e15 and player.UserId==math.floor(player.UserId) then
        return 'UID:'..tostring(player.UserId)
    end
    return 'NAME:'..player.Name
end
function controller.IsBlacklisted(player) return blacklist[receiverKey(player)]==true end
local function teammate(player)
    if player==me or not me.Team or me.Neutral or player.Neutral or player.Team~=me.Team then return false end
    if controller.IsBlacklisted(player) then return false end
    return body(player)~=nil and Players:GetPlayerFromCharacter(player.Character)==player
end
local function ownsLock()
    if not lease then return false end
    local q=lease.q
    return rawget(q,'Locked')==true and rawget(q,'LockedOnto')==lease.model and rawget(q,'LockedOntoName')==lease.name
end
local function restoreLock()
    if not lease then return end
    if ownsLock() then
        rawset(lease.q,'Locked',lease.before[1]); rawset(lease.q,'LockedOnto',lease.before[2]); rawset(lease.q,'LockedOntoName',lease.before[3])
    else relinquishments=relinquishments+1; log('LOCK','External edit preserved') end
    lease=nil
end
local function lock(player)
    if stopped or not profile or not teammate(player) or not controller.receiverFilter.allowed(player) then return false end
    local q=profile.q
    if lease and (lease.q~=q or not ownsLock()) then restoreLock(); return false end
    if not lease then
        -- Deliberate native/manual locks belong to the user. AUTO must not steal them.
        if q.Locked then return false end
        lease={q=q,before={rawget(q,'Locked'),rawget(q,'LockedOnto'),rawget(q,'LockedOntoName')}}
    end
    lease.model,lease.name=player.Character,player.Name
    rawset(q,'LockedOnto',lease.model); rawset(q,'LockedOntoName',lease.name); rawset(q,'Locked',true)
    return true
end
local function clearWindows()
    candidateEvidence={}
    for k in pairs(opportunities) do opportunities[k]=nil end
    for k in pairs(shotCache) do shotCache[k]=nil end
end
local function restoreModeTransaction()
    local m=modeTransaction
    if not m then return true end
    modeTransaction=nil
    local q=m.q
    local owned=q.AutoThrowType==m.auto and rawget(m.auto,'Enabled')==false and rawget(q,'SelectedType')==m.mode
    if rawget(m.auto,'Enabled')==false then rawset(m.auto,'Enabled',m.enabled) end
    if rawget(q,'SelectedType')==m.mode then rawset(q,'SelectedType',m.selected) end
    for _,field in ipairs(m.fields or {}) do
        if rawget(field.object,field.key)==field.written then rawset(field.object,field.key,field.before)
        else owned=false end
    end
    if m.worker and coroutine.status(m.worker)=='suspended' and type(coroutine.close)=='function' then pcall(coroutine.close,m.worker) end
    if not owned then log('MODE','External edit preserved during solve') end
    return owned
end
local function releaseChoice(keepWindows)
    if clearGuide then clearGuide() end
    if cancelJump then cancelJump('SELECTION_RELEASED') end
    if cancelSequence then cancelSequence('SELECTION_RELEASED') end
    choice=nil; restoreModeTransaction(); restoreLock(); if not keepWindows then clearWindows() end
end
function controller.SetBlacklisted(player,value)
    if stopped or not instance(player,'Player') or player==me then return false end
    local key=receiverKey(player)
    blacklist[key]=value==true and true or nil
    if value then controller.mag.manual[key]=nil end
    if value and controller.league.screen and controller.league.screen.player==player then controller.league.ClearScreen('BLACKLISTED') end
    log('BLACKLIST',player.Name..' '..tostring(value==true))
    opportunities[player]=nil; shotCache[player]=nil
    if value and choice and choice.player==player then releaseChoice() end
    if renderReceivers then renderReceivers() end
    return true
end
function controller.GetReceiverState(player)
    if controller.IsBlacklisted(player) then return 'BLOCKED' end
    return 'NORMAL'
end
function controller.SetReceiverState(player,value)
    if value=='TRUSTED' then setGate('MANUAL_MAG_TRUST_UNSUPPORTED_IN_B3');return false end
    if stopped or not instance(player,'Player') or player==me or not ({NORMAL=true,BLOCKED=true,TRUSTED=true})[value] then return false end
    local key=receiverKey(player)
    if value=='TRUSTED' and key:sub(1,4)~='UID:' then return false end
    releaseChoice()
    blacklist[key]=value=='BLOCKED' and true or nil
    controller.mag.manual[key]=value=='TRUSTED' and true or nil
    log('RECEIVER_STATE',value)
    if renderReceivers then renderReceivers() end
    return true
end
function controller.mag.Source(player,request)
    if not teammate(player) then return end
    if controller.mag.manual[receiverKey(player)]==true then return 'MANUAL' end
    if controller.receiverFilter.friend(player,request) then return 'FRIEND' end
end
function controller.mag.Allowed(player)
    if not controller.mag.enabled then return false end
    return controller.mag.Source(player)~=nil
end
controller.field={}
function controller.field.QBLimit(root,direction)
    if not lines.goalToGo then return .5 end
    direction=direction or lines.forward
    local size,cf=root and root.Size,root and root.CFrame
    if not direction or not vector(size) or not cf or not vector(cf.RightVector) or not vector(cf.LookVector) then return .5 end
    -- Goal-line straddling uses the measured root footprint, not the receiver's
    -- downfield distance or an end-zone exemption for an already-crossed QB.
    return math.max(.5,math.abs(cf.RightVector:Dot(direction))*size.X/2+math.abs(cf.LookVector:Dot(direction))*size.Z/2)
end
function controller.field.QBPast(root)
    local depth=lines.los and lines.forward and flat(root.Position-lines.los):Dot(lines.forward) or math.huge
    local limit=controller.field.QBLimit(root)
    controller.field.lastDepth,controller.field.lastLimit=depth,limit
    return depth>limit
end

-- LOS geometry is preserved from the earlier FF3 reports: the observed ground
-- and full-width blue/yellow strips (or straight Beams). Direction is never
-- inferred from camera facing, receiver movement, team names, or the QB spawn.
local function groundIssue(o)
    if not o then return 'MISSING' end
    if not instance(o,'BasePart') then return 'NOT_BASEPART' end
    if not o.Parent or not o:IsDescendantOf(workspace) then return 'DETACHED' end
    if not o.Anchored then return 'NOT_ANCHORED' end
    local s=o.Size
    if math.abs(s.X-225)>=.6 or math.abs(s.Y-1)>=.3 or math.abs(s.Z-420)>=.6 then return 'SIZE_MISMATCH' end
    local c=o.CFrame
    if (o.Position-V(0,2.5,0)).Magnitude>=1.5 then return 'WORLD_POSITION_MISMATCH' end
    if c.UpVector.Y<=.999 or math.abs(c.RightVector.X)<=.999 or math.abs(c.LookVector.Z)<=.999 then return 'ORIENTATION_MISMATCH' end
    return 'ACCEPTED'
end
local function groundShape(o) return groundIssue(o)=='ACCEPTED' end
local function observedGround()
    -- Exact path confirmed by the earlier live G166 report; a name never
    -- substitutes for the same current geometry/ancestry validation.
    local models=workspace:FindFirstChild('Models')
    if not models then return nil,'MISSING_MODELS' end
    local field=models:FindFirstChild('Field')
    if not field then return nil,'MISSING_FIELD' end
    local ground=field:FindFirstChild('Ground')
    return ground,groundIssue(ground)
end
local function retainObservedGround()
    local observed,why=observedGround()
    lines.knownGroundIssue=why
    if why=='ACCEPTED' and (not lines.ground or not groundShape(lines.ground)) then
        lines.ground=observed; lines.groundSource='OBSERVED_PATH'
    end
end
local function groundReason()
    if lines.groundAmbiguous then return 'AMBIGUOUS_GROUND_REFERENCES' end
    if not lines.ground then return 'NOT_DISCOVERED' end
    return groundIssue(lines.ground)
end
local function describeGround(o)
    if not o then return 'NONE' end
    if not instance(o,'BasePart') then return 'class='..clean(o.ClassName) end
    return string.format('class=%s size=%.3f,%.3f,%.3f position=%.3f,%.3f,%.3f anchored=%s',
        o.ClassName,o.Size.X,o.Size.Y,o.Size.Z,o.Position.X,o.Position.Y,o.Position.Z,tostring(o.Anchored))
        ..string.format(' upY=%.4f rightX=%.4f lookZ=%.4f',o.CFrame.UpVector.Y,o.CFrame.RightVector.X,o.CFrame.LookVector.Z)
end
local observedLineNames={'LineDown','LineTogo'}
local function observedLine(o)
    -- V2 live evidence identifies these root-level Parts. Names retain candidates
    -- before replication finishes; current geometry still decides acceptance.
    return instance(o,'BasePart') and o.Parent==workspace and (o.Name=='LineDown' or o.Name=='LineTogo')
end
local function retainObservedLines()
    -- Two direct lookups recover late configuration/replacement without a new
    -- global sweep, per-Part listeners, or depending on the scan's seen set.
    for _,name in ipairs(observedLineNames) do
        local o=workspace:FindFirstChild(name)
        if observedLine(o) then lines.parts[o]=true end
    end
end
local function partCandidate(o)
    if not instance(o,'BasePart') or not o.Anchored then return false end
    local s=o.Size; local width=math.max(s.X,s.Z)
    return s.Y<=3 and math.min(s.X,s.Z)<=5 and width>=30 and width<=175 and math.abs(o.Position.X)<=85
        and math.abs(o.Position.Z)<=153 and math.abs(o.Position.Y-3)<4 and o.CFrame.UpVector.Y>=.98
end
local function colorRole(c)
    if c.B>.65 and c.B>c.R+.3 and c.R<.4 and c.G<.85 then return 'BLUE' end
    if c.R>.75 and c.G>.45 and c.B<.4 then return 'YELLOW' end
end
local function markerCandidate(o)
    -- Retain plausible strip geometry even while hidden or using another color;
    -- marker() rechecks current color/visibility every read, without extra listeners.
    if partCandidate(o) then return true end
    if not instance(o,'Beam') or not o.Attachment0 or not o.Attachment1
        or math.abs(o.CurveSize0)>.1 or math.abs(o.CurveSize1)>.1 then return false end
    local a,b=o.Attachment0.WorldPosition,o.Attachment1.WorldPosition
    local d,p=b-a,(a+b)*.5
    return math.abs(d.X)>=30 and math.abs(d.X)<=175 and math.abs(d.Z)<=5 and math.abs(d.Y)<=3
        and math.abs(p.X)<=85 and math.abs(p.Z)<=153 and math.abs(p.Y-3)<4
end
local function enqueueLine(o)
    local scan=lines.scan
    if scan.seen[o] or scan.queued[o] then return end
    scan.tail=scan.tail+1; scan.q[scan.tail]=o; scan.queued[o]=true; lines.complete=false
end
local function downValue(raw)
    local text=raw:gsub('<[^>]*>',''):gsub('^%s+',''):gsub('%s+$','')
    local lower=text:lower()
    if lower:match('^%d+%a*%s*&%s*goal$') or lower:match('^%d+%a*%s+and%s+goal$') then return 'GOAL' end
    local yards=tonumber(text:match('^[1-4]%a%a%s*&%s*(%d+)$'))
    if yards and yards>=1 and yards<=30 then return yards end
end
local function scanLines()
    local scan=lines.scan; local work=0; local deadline=os.clock()+.0015
    while work<96 and os.clock()<deadline do
        local frame=scan.stack[#scan.stack]; local o
        if frame then
            if frame.i<=frame.n then
                o=frame.children[frame.i]; frame.children[frame.i]=nil; frame.i=frame.i+1
            else scan.stack[#scan.stack]=nil end
        else
            o=scan.q[scan.i]
            if not o then lines.complete=true; lines.initialComplete=true; scan.q={}; scan.i=1; scan.tail=0; break end
            scan.q[scan.i]=nil; scan.i=scan.i+1; scan.queued[o]=nil
        end
        work=work+1
        if o and not scan.seen[o] then
            scan.seen[o]=true; scan.visited=scan.visited+1
            if o==workspace or o.Parent then
                if groundShape(o) then
                    if lines.ground and groundShape(lines.ground) and lines.ground~=o then lines.groundAmbiguous=true; lines.ambiguousGround=describeGround(o)
                    else lines.ground=o; lines.groundSource='SCAN' end
                elseif observedLine(o) or markerCandidate(o) then
                    lines.parts[o]=true
                elseif instance(o,'TextLabel') or instance(o,'TextButton') then
                    if not (gui and o:IsDescendantOf(gui)) then
                        if #lines.labels<256 then lines.labels[#lines.labels+1]=o
                        elseif downValue(o.Text) or controller.league.VipText(o.Text) then
                            for i,old in ipairs(lines.labels) do
                                if not old.Parent or lines.negativeText[old] and not controller.league.VipText(old.Text) then lines.labels[i]=o; break end
                            end
                        end
                    end
                end
                if not instance(o,'Humanoid') and not (instance(o,'Model') and o:FindFirstChildOfClass('Humanoid')) then
                    local children=o:GetChildren()
                    if #children>0 then scan.stack[#scan.stack+1]={children=children,n=#children,i=1} end
                end
            end
        end
    end
end
local function marker(o,ground)
    if not o.Parent or not o:IsDescendantOf(workspace) then return end
    local cf=ground.CFrame; local center,dx,dz,height,role
    if instance(o,'BasePart') then
        role=colorRole(o.Color)
        local white=o.Color.R>.7 and o.Color.G>.7 and o.Color.B>.7
        if not role and not white or not o.Anchored or o.Transparency>.65 or o.CFrame.UpVector.Y<.98 then return end
        local sz,c=o.Size,o.CFrame
        dx=math.abs(c.RightVector:Dot(cf.RightVector))*sz.X+math.abs(c.LookVector:Dot(cf.RightVector))*sz.Z
        dz=math.abs(c.RightVector:Dot(cf.LookVector))*sz.X+math.abs(c.LookVector:Dot(cf.LookVector))*sz.Z
        center,height=o.Position,sz.Y
    else
        if not o.Enabled or not o.Attachment0 or not o.Attachment1 or math.abs(o.CurveSize0)>.1 or math.abs(o.CurveSize1)>.1 then return end
        for _,endpoint in ipairs({o.Attachment0,o.Attachment1}) do
            local at=endpoint.Parent
            for _=1,6 do
                if not at or at==workspace then break end
                if instance(at,'BasePart') and not at.Anchored or instance(at,'Model') and at:FindFirstChildOfClass('Humanoid') then return end
                at=at.Parent
            end
        end
        for _,k in ipairs(o.Color.Keypoints) do local r=colorRole(k.Value); if not r or role and r~=role then return end; role=r end
        for _,k in ipairs(o.Transparency.Keypoints) do if k.Value>.65 then return end end
        local a,b=o.Attachment0.WorldPosition,o.Attachment1.WorldPosition
        local d=cf:VectorToObjectSpace(b-a); center=(a+b)*.5; dx,dz,height=math.abs(d.X),math.abs(d.Z),math.abs(d.Y)
    end
    local p=cf:PointToObjectSpace(center)
    if dx<30 or dx>175 or dz>5 or height>3 or math.abs(p.X)>85 or math.abs(p.Y-.5)>4 or math.abs(p.Z)>153 then return end
    if not role then
        if math.abs(math.abs(p.Z)-150)<.6 and math.abs(dx-160)<1 and math.abs(dz-.25)<.1 then role='GOAL' else return end
    end
    return role,p.Z,p.X-dx/2,p.X+dx/2
end
local function namedFieldReady(now,ground,goalOnly)
    local known,why=observedGround()
    if why~='ACCEPTED' or known~=ground then lines.fastStatus='KNOWN_GROUND_UNVERIFIED'; return false end
    local blue=workspace:FindFirstChild('LineDown')
    local yellow=workspace:FindFirstChild('LineTogo')
    if lines.rootNames.blue~=blue or lines.rootNames.yellow~=yellow then lines.rootDirty=true end
    if lines.rootDirty or now-lines.rootChecked>=.5 then
        local children=workspace:GetChildren()
        if #children>4096 then lines.fastStatus='ROOT_CHECK_LIMIT'; return false end
        local blueCount,yellowCount=0,0
        for _,child in ipairs(children) do
            if child.Name=='LineDown' then blueCount=blueCount+1 end
            if child.Name=='LineTogo' then yellowCount=yellowCount+1 end
            if markerCandidate(child) then lines.parts[child]=true end
            if child~=ground and groundShape(child) then
                lines.groundAmbiguous=true; lines.ambiguousGround=describeGround(child)
            end
        end
        lines.rootNames={blue=blue,yellow=yellow,blueCount=blueCount,yellowCount=yellowCount}
        lines.rootDirty=false; lines.rootChecked=now
    end
    if lines.groundAmbiguous then lines.fastStatus='GROUND_AMBIGUOUS'; return false end
    if lines.rootNames.blueCount~=1 or not goalOnly and lines.rootNames.yellowCount~=1 then lines.fastStatus='NAMED_ROOTS_MISSING_OR_DUPLICATE'; return false end
    local entries={{blue,'BLUE'}}
    if not goalOnly then entries[#entries+1]={yellow,'YELLOW'} end
    for _,entry in ipairs(entries) do
        local object,expected=entry[1],entry[2]
        if not observedLine(object) then lines.fastStatus='NAMED_ROOT_CLASS_OR_ANCESTRY'; return false end
        local role,_,lo,hi=marker(object,ground)
        if role~=expected or hi-lo<130 or hi-lo>175 or math.abs((lo+hi)/2)>=5 then
            lines.fastStatus='NAMED_ROOT_GEOMETRY_COLOR_OR_VISIBILITY'; return false
        end
    end
    lines.fastStatus=goalOnly and 'VALIDATED_NAMED_BLUE_ONLY' or 'VALIDATED_NAMED_ROOT_PAIR'
    return true
end
local function downReading()
    local result,conflict,goalToGo
    for _,o in ipairs(lines.labels) do
        if o.Parent and lines.negativeText[o]~=o.Text then
            local raw=o.Text
            local yards=downValue(raw)
            if yards then
                local shown=o:IsDescendantOf(pg) or core and o:IsDescendantOf(core); local at=o
                for _=1,16 do
                    if not at then break end
                    if instance(at,'GuiObject') and not at.Visible or instance(at,'LayerCollector') and not at.Enabled then shown=false; break end
                    at=at.Parent
                end
                local cam=workspace.CurrentCamera
                if shown and (not cam or o.AbsolutePosition.Y<cam.ViewportSize.Y*.4) then
                    if yards=='GOAL' then goalToGo=true end
                    if result and result~=yards then conflict='CONFLICTING_DOWN_HUD' end
                    result=yards
                end
            else lines.negativeText[o]=raw end
        end
    end
    if conflict then return nil,conflict,goalToGo==true end
    return result,nil,goalToGo==true
end
local function readLines(now)
    retainObservedGround()
    retainObservedLines()
    local ground=lines.ground
    local function missing(reason)
        lines.status=reason; lines.los=nil; lines.forward=nil; lines.since=0; lines.readySource='NONE'; return false
    end
    local yards,conflict,goalToGo=downReading()
    if lines.goalToGo~=goalToGo then lines.generation=lines.generation+1 end
    lines.goalToGo=goalToGo
    if conflict then return missing(conflict) end
    -- The bound applies to actual marker geometry, never the number of visited
    -- map objects or unrelated Beams. It recovers as markers disappear/hide.
    lines.capped=false; lines.markerCount=0
    if not ground or not groundShape(ground) or lines.groundAmbiguous then return missing('LOS_GROUND_UNKNOWN') end
    local namedReady=namedFieldReady(now,ground,goalToGo)
    if not lines.initialComplete and not namedReady then return missing('LOS_SEARCHING') end
    if lines.groundAmbiguous then return missing('LOS_GROUND_UNKNOWN') end
    local clusters={BLUE={},YELLOW={},GOAL={}}; local inspected=0
    for o in pairs(lines.parts) do
        inspected=inspected+1
        if inspected>512 then lines.capped=true; return missing('LOS_CANDIDATE_LIMIT') end
        local role,z,lo,hi
        if not o.Parent or not o:IsDescendantOf(workspace) then lines.parts[o]=nil
        else role,z,lo,hi=marker(o,ground) end
        if role then
            lines.markerCount=lines.markerCount+1
            if lines.markerCount>128 then lines.capped=true; return missing('LOS_MARKER_LIMIT') end
            local groups=clusters[role]; local group
            for _,g in ipairs(groups) do if math.abs(g.z-z)<.3 then group=g; break end end
            if not group then group={z=z,segments={}}; groups[#groups+1]=group end
            group.segments[#group.segments+1]={lo=lo,hi=hi}
        end
    end
    local valid={BLUE={},YELLOW={},GOAL={}}
    for role,groups in pairs(clusters) do
        for _,g in ipairs(groups) do
            table.sort(g.segments,function(a,b) return a.lo<b.lo end)
            local lo,hi=g.segments[1].lo,g.segments[1].hi; local continuous=true
            for i=2,#g.segments do local s=g.segments[i]; if s.lo>hi+2 then continuous=false end; hi=math.max(hi,s.hi) end
            if continuous and hi-lo>=130 and hi-lo<=175 and math.abs((hi+lo)/2)<5 then valid[role][#valid[role]+1]=g end
        end
    end
    if #valid.BLUE~=1 then return missing('LOS_BLUE_MISSING_OR_AMBIGUOUS') end
    local blue,yellow=valid.BLUE[1],valid.YELLOW[1]
    local cf=ground.CFrame
    local los=ground.Position+cf.UpVector*.5-cf.LookVector*blue.z
    local delta,targetZ
    if goalToGo then
        -- LineDown is retained/validated as BLUE; a yellow first-down marker
        -- beyond the goal line is not required. Prefer a verified pair at this
        -- same LOS, otherwise require nearest-end-zone and QB-side agreement.
        if lines.confirmedGround==ground and lines.confirmedTeam==me.Team and lines.confirmedEpoch==possession.epoch
            and lines.confirmedLos and flat(lines.confirmedLos-los).Magnitude<.05 then
            local dir=lines.confirmedForward
            if dir then targetZ=dir:Dot(cf.LookVector)<0 and 150 or -150 end
        end
        if not targetZ then
            if math.abs(blue.z)<.05 then return missing('GOAL_DIRECTION_UNVERIFIED') end
            targetZ=blue.z>0 and 150 or -150
        end
        delta=targetZ-blue.z
        -- LOS can coincide with the goal stripe; receivers still have usable
        -- end-zone space beyond it. Never flip direction toward midfield there.
        if math.abs(delta)<.05 then delta=targetZ>0 and 1 or -1
        elseif (targetZ>0 and delta<0 or targetZ<0 and delta>0) then return missing('GOAL_LOS_BEYOND_TARGET_ENDZONE') end
        local _,root=body(me)
        local direction=cf.LookVector*(delta>0 and -1 or 1)
        if not root then return missing('GOAL_DIRECTION_WAIT_QB') end
        if not lines.confirmedLos or lines.confirmedGround~=ground or lines.confirmedTeam~=me.Team
            or lines.confirmedEpoch~=possession.epoch or flat(lines.confirmedLos-los).Magnitude>=.05 then
            if flat(root.Position-los):Dot(direction)>controller.field.QBLimit(root,direction) then return missing('GOAL_DIRECTION_QB_SIDE_CONFLICT') end
        end
    else
        if #valid.YELLOW~=1 then return missing('LOS_YELLOW_MISSING_OR_AMBIGUOUS') end
        delta=yellow.z-blue.z;targetZ=yellow.z
        if math.abs(delta)<2 or math.abs(delta)>90 then return missing('LOS_LINE_DISTANCE_INVALID') end
        if type(yards)=='number' and math.abs(math.abs(delta)/3-yards)>.8 then return missing('LOS_DOWN_HUD_MISMATCH') end
    end
    local forward=cf.LookVector*(delta>0 and -1 or 1)
    local same=lines.los and flat(lines.los-los).Magnitude<.05 and lines.forward:Dot(forward)>.99
    local sameMeaning=lines.confirmedLos and flat(lines.confirmedLos-los).Magnitude<.05
        and lines.confirmedForward:Dot(forward)>.99 and math.abs(lines.confirmedTargetZ-targetZ)<.05
        and lines.confirmedGround==ground
    if not sameMeaning then
        lines.generation=lines.generation+1
        log('LOS',string.format('z=%.2f forwardZ=%.0f',los.Z,forward.Z))
    end
    if not same or not sameMeaning then lines.since=now end
    lines.confirmedLos,lines.confirmedForward,lines.confirmedTargetZ,lines.confirmedGround=los,forward,targetZ,ground
    lines.confirmedTeam,lines.confirmedEpoch=me.Team,possession.epoch
    lines.los,lines.forward,lines.at=los,forward,now
    lines.readySource=goalToGo and 'GOAL_VALIDATED_BLUE_LINE' or namedReady and 'VALIDATED_NAMED_ROOT_PAIR' or 'COMPLETE_BACKGROUND_SCAN'
    lines.status=now-lines.since>=.25 and 'OBSERVED_LINES_STABLE' or 'LOS_SETTLING'
    return lines.status=='OBSERVED_LINES_STABLE'
end
local function downfield(point)
    return lines.los and lines.forward and flat(point-lines.los):Dot(lines.forward) or -math.huge
end
function controller.passPlan.observe(s,player)
    if not lines.los or not lines.forward or lines.status~='OBSERVED_LINES_STABLE' or not possession.wasReady then return end
    local depth=downfield(s.p)/3
    if s.depthEpoch~=possession.epoch or s.depthGeneration~=lines.generation or s.depthTeam~=player.Team then
        s.depthPeakYards=depth;s.depthEpoch=possession.epoch;s.depthGeneration=lines.generation;s.depthTeam=player.Team
    else s.depthPeakYards=math.max(s.depthPeakYards or depth,depth) end
end
function controller.passPlan.assess(shot,receiver)
    local p=controller.passPlan
    local verified=lines.los~=nil and lines.forward~=nil and lines.status=='OBSERVED_LINES_STABLE'
    shot.catchDepthYards=verified and downfield(shot.arrival)/3 or nil
    shot.deepTarget=shot.catchDepthYards~=nil and shot.catchDepthYards>=p.deepYards
    shot.endzoneTarget=verified and controller.field.InEndzone(shot.arrival) or false
    local current=verified and downfield(receiver.p)/3 or nil
    shot.deepComeback=verified and receiver.depthEpoch==possession.epoch and receiver.depthGeneration==lines.generation
        and finite(receiver.depthPeakYards) and receiver.depthPeakYards>=p.deepYards
        and current<=receiver.depthPeakYards-CFG.MinMotionTravel/3
        and flat(receiver.v):Dot(lines.forward)<=-CFG.MinMoveSpeed or false
    -- A wide-open policy uses the existing safety-surplus scales; these are
    -- application preferences, not calibrated FF3 catch/interception radii.
    local ping=shot.networkPing
    shot.wideOpen=finite(ping) and ping>=0 and (shot.wideMargin or shot.margin)>=CFG.ThrowMargin*2 and (shot.wideLane or shot.lane)>=CFG.ThrowLane*2
        and not shot.safetyOverTop and shot.defenderETA>shot.time+ping or false
    shot.planAllowed=p.mode=='NORMAL' or verified and (p.mode=='DEEP' and (shot.deepTarget or shot.deepComeback or shot.endzoneTarget)
        or p.mode=='SHORT' and (not shot.deepTarget or shot.wideOpen)) or false
    shot.planReason=shot.planAllowed and 'PASS_PLAN_ALLOWED' or (p.mode=='DEEP' and 'DEEP_OR_COMEBACK_ONLY' or 'SHORT_DEEP_NOT_WIDE_OPEN')
    shot.jumpPreferred=p.preferJump and shot.mode=='Jump' and shot.wideOpen or false
    if p.openComfort and shot.mode=='Jump' and not shot.nativeCoverageJump then shot.planAllowed=false;shot.planReason='NATIVE_JUMP_DISABLED_FOR_OPEN_COMFORT' end
    if p.preferJump and shot.mode=='Jump' and not shot.nativeCoverageJump and not shot.wideOpen then shot.planAllowed=false;shot.planReason='JUMP_NOT_WIDE_OPEN_BEFORE_DEFENSE' end
    if shot.screen then
        shot.planAllowed=verified and controller.league.mode=='LEAGUE' and shot.mode=='Bullet' and shot.catchDepthYards<=0
        shot.planReason=shot.planAllowed and 'EXPLICIT_CURRENT_POSSESSION_SCREEN' or 'SCREEN_ARRIVAL_NOT_BEHIND_LOS'
    end
    return shot.planAllowed
end
local function onField(point)
    if not lines.ground then return false end
    local p=lines.ground.CFrame:PointToObjectSpace(point)
    return math.abs(p.X)<=80 and math.abs(p.Z)<=180
end
function controller.field.InEndzone(point)
    if not lines.ground or not lines.forward or lines.status~='OBSERVED_LINES_STABLE' then return false end
    -- Reuse the existing validated field frame, +/-150 goal stripes and +/-180
    -- end bounds already used by LOS/AntiOOB; never infer direction from camera.
    local cf=lines.ground.CFrame;local p=cf:PointToObjectSpace(point)
    local direction=lines.forward:Dot(cf.LookVector)<0 and 1 or -1
    return math.abs(p.X)<=80 and p.Z*direction>=150 and p.Z*direction<=180
end
function controller.field.BeyondMinimum(point)
    local depth=downfield(point)
    return depth>=0 and (lines.goalToGo or controller.field.InEndzone(point) or depth>=CFG.MinDownfieldYards*3)
end
function touch.fullAllowed(shot)
    if shot.screen and controller.league.mode=='LEAGUE' then shot.powerReason='EXPLICIT_ARMED_SCREEN_RECEIVER_PREPARED';return true end
    if not touch.enabled then return true end
    local power=shot.power or shot.velocity and shot.velocity.Magnitude
    local minimum=power and power>=94.5 and touch.comfort or shot.oscillationBullet and touch.comfort*.95 or shot.variant=='SoftBullet' and touch.comfort*.95 or touch.quick
    shot.minimumFlight=minimum
    if not finite(shot.time) or shot.time<minimum then shot.powerReason='NATIVE_FLIGHT_TOO_FAST';return false end
    if power and power<94.5 then shot.powerReason='NATIVE_FLIGHT_COMFORT_CHECKED';return true end
    -- Distance/actual flight policy; a changed mode label cannot bypass it.
    local yards=shot.passYards or shot.arrival and shot.origin and flat(shot.arrival-shot.origin).Magnitude/3
    local allowed=not touch.full or yards~=nil and yards>=touch.full
    shot.powerReason=allowed and 'FULL_POWER_DISTANCE_AND_FLIGHT_CHECKED' or 'FULL_POWER_TOO_CLOSE'
    return allowed
end
function touch.record(player,variant,requested,returned,reason)
    touch.lastControl={Variant=variant,Method=touch.method,Requested= requested,Returned=returned,Reason=reason}
    local rows=touch.traces
    rows[#rows+1]=string.format('%s %s method=%s requested=%s returned=%s %s',player.Name,variant,touch.method,tostring(requested),tostring(returned),reason)
    if #rows>8 then table.remove(rows,1) end
end
function touch.angle(player,power)
    local _,root,head=body(player);local _,_,qbHead=body(me)
    if not head or not qbHead then return end
    local origin=qbHead.Position
    local cache=shotCache[player];local base=cache and cache.shots.Bullet
    if base and base.qbModel==me.Character and os.clock()-base.at<=CFG.CacheAge then origin=base.origin end
    local v=flat(root.AssemblyLinearVelocity);local lead=profile.leads.Bullet;local ping=me:GetNetworkPing()
    if not finite(ping) or ping<0 then return end
    local time=flat(head.Position-origin).Magnitude/power;local angle
    for _=1,3 do
        local target=head.Position+v*(time+ping)+(v.Magnitude>0 and v.Unit*lead.X or V())+V(0,lead.Y,0)
        local r=flat(target-origin).Magnitude;local h=target.Y-origin.Y
        local disc=power^4-CFG.Gravity*(CFG.Gravity*r*r+2*h*power*power)
        if r<=0 or disc<0 then return end
        angle=math.atan((power*power-math.sqrt(disc))/(CFG.Gravity*r))
        time=r/(power*math.cos(angle))
    end
    -- This angle is only an input to the audited native Angle/power solver.
    -- Its final output, not this estimate, supplies the released trajectory.
    return math.deg(angle) -- native Angle/UI input is degrees (live setting 45)
end
local function onLineAdded(o)
    if controller.receiverEvidence then controller.receiverEvidence.OnAdded(o) end
    if stopped then return end
    if o.Parent==workspace then lines.rootDirty=true end
    if observedLine(o) then lines.parts[o]=true end
    if groundShape(o) or partCandidate(o) then enqueueLine(o)
    elseif instance(o,'Beam') then
        -- Ignore Yuna's constantly recreated trajectory visuals. Only observed
        -- field-spanning marker geometry joins the long-lived discovery queue.
        if lines.ground and marker(o,lines.ground) then enqueueLine(o) end
    elseif instance(o,'TextLabel') or instance(o,'TextButton') then
        -- Read after the bounded scan resumes, so Parent-before-Text creation
        -- still discovers a newly recreated scoreboard. No per-label listeners.
        if not (gui and o:IsDescendantOf(gui)) then enqueueLine(o) end
    elseif instance(o,'Folder') or instance(o,'Model') then
        if not (gui and o:IsDescendantOf(gui)) then enqueueLine(o) end
    end
end
function controller.GetReport()
    local selectedRisk=riskPolicy.profiles[riskPolicy.mode]
    local rows={VERSION,'PLACE|'..tostring(game.PlaceId),'STATE|'..(stopped and 'STOPPED' or 'RUNNING'),
        'GATE|'..gate,'AUTO|'..tostring(auto),'THROW|'..tostring(throwing),'RISK_MODE|'..riskPolicy.mode,'PASS_PLAN|'..controller.passPlan.mode,
        'RECEIVER_FILTER|'..controller.receiverFilter.mode,'FRIEND_LOOKUP_STATUS|'..controller.receiverFilter.status,'FRIEND_LOOKUP_METHOD|'..(controller.receiverFilter.method or 'NOT_USED'),'FRIEND_LOOKUP_CALLS|'..controller.receiverFilter.checks,
        'PLAY_PROFILE|'..controller.league.mode,'PLAY_PROFILE_REQUEST|'..controller.league.requested,'PLAY_PROFILE_SOURCE|'..controller.league.source,
        'VIP_HINT_SEEN|'..tostring(controller.league.vipSeen),'VIP_POLICY|VISIBLE_EXACT_TOP_HUD_HINT; PRIVATE_SERVER_NOT_PROOF_OF_LEAGUE; EXPLICIT_PROFILE_OVERRIDES',
        'SCREEN_STATUS|'..tostring(controller.league.screenStatus or 'OFF'),'SCREEN_TARGET|'..(controller.league.screen and controller.league.screen.player.Name or 'NONE'),
        'SCREEN_POLICY|EXPLICIT_CURRENT_POSSESSION; STATIONARY_SELECTED_TEAMMATE_ONLY; BULLET_ONLY; ARRIVAL_BEHIND_VERIFIED_LOS; STRICT_COVERAGE',
        'SCREEN_MAX_BEHIND_LOS_YARDS|'..controller.league.screenDepth,
        'NATIVE_COVERAGE_JUMP|'..tostring(controller.nativeJump.enabled),'NATIVE_JUMP_POLICY|OWN_JUMP_LEAD_AND_NATIVE_CONTROLS; FRESH_CHEST_THREAT_REQUIRED; SAFE_ORDINARY_BULLET_VETO; CATCH_WINDOW_UNCALIBRATED',
        'LEAGUE_COVERAGE_POLICY|WHOLE_NATIVE_PATH_AND_ARRIVAL; DEFENDER_PING_BUDGET; GEOMETRIC_LAYERS_NOT_ASSIGNED_ROLES; FIT_WINDOW_REQUIRES_FRESH_BULLET_AND_DIME',
        'SHARED_COVERAGE_WINDOWS|'..tostring(controller.coverageWindows.enabled),'SHARED_COVERAGE_SCOPE|CASUAL_AND_LEAGUE; ORIGINAL_CASUAL_UI_AND_RECEIVER_FILTERS_RETAINED',
        'OPEN_COMFORT|'..tostring(controller.passPlan.openComfort),'OPEN_COMFORT_POLICY|NATIVE_ENDPOINT_EASE_RANKING; CONDITIONAL_HIGH_ONLY; NO_FREE_POINT_OR_MAG_ADAPTER',
        'PASS_PLAN_DEEP_YARDS|'..controller.passPlan.deepYards,'WIDE_OPEN_JUMP|'..tostring(controller.passPlan.preferJump),'CLEANUP_CONFIRMED|'..tostring(cleanupComplete),
        'STOP_REASON|'..stopReason,'FATAL_ERROR|'..fatalError,'ERROR_POLICY|STOP_AND_PRESERVE_NO_RETRY',
        'PROFILE|'..(profile and 'SHARED_LOCK_NATIVE_SOLVER_LIVE_INPUT' or 'NONE'),
        'LOCK_ONLY|'..tostring(choice~=nil and choice.manualOnly==true),
        'TARGET|'..(choice and choice.player.Name or 'NONE'),'MODE|'..(choice and choice.shot.mode or 'NONE'),
        'TARGET_DISPLAY_NAME|'..(choice and clean(choice.player.DisplayName) or 'NONE'),
        'TARGET_USER_ID|'..(choice and tostring(choice.player.UserId) or 'NONE'),
        'TARGET_IDENTITY_POLICY|TARGET_IS_USERNAME; DISPLAY_NAME_MAY_DIFFER; NATIVE_PREVIEW_IS_NOT_A_RELEASE_RECEIPT',
        'ATTEMPTS|'..attempts,'REQUEST_SENT|'..sent,'AMBIGUOUS_REQUESTS|'..ambiguous,
        'NATIVE_SOLVER_CALLS|'..nativeCalls,'EXTERNAL_LOCK_EDITS|'..relinquishments,'MAX_TICK_SECONDS|'..string.format('%.6f',maxTick),
        'COPY_RESULT|'..copyResult,'FILE_RESULT|'..fileResult,
        'COMEBACK_CHAT|'..tostring(controller.comeback.enabled),'COMEBACK_STATUS|'..controller.comeback.status,
        'COMEBACK_ATTEMPTS|'..controller.comeback.attempts,'COMEBACK_OUTCOME|'..controller.comeback.outcome,
        'ROUTE_CALL_LAST|'..(controller.comeback.instruction or 'NONE'),
        'COMEBACK_POLICY|FRIEND_STREAK_PREVENT: slant_right/slant_left/cut_back; WR_FACING_DOWNFIELD; STABLE_DIRECTION_0.65_SECONDS; LEGACY_COVERED_cut_back_2_SECONDS; VERIFIED_TEAM_CHANNEL_ONLY; ONCE_PER_POSSESSION; 30_SECOND_SESSION_COOLDOWN; ADVISORY_UNCALIBRATED',
        'LOS_STATUS|'..lines.status,'LOS_WORLD_Z|'..(lines.los and string.format('%.2f',lines.los.Z) or 'NONE'),
        'ATTACK_FORWARD_Z|'..(lines.forward and string.format('%.0f',lines.forward.Z) or 'NONE'),
        'LOS_SCAN_COMPLETE|'..tostring(lines.complete),'LOS_SCAN_CAPPED|'..tostring(lines.capped),
        'LOS_MARKER_CANDIDATES|'..lines.markerCount,'LOS_SCAN_VISITED|'..lines.scan.visited,
        'LOS_SCAN_PENDING_ROOTS|'..math.max(0,lines.scan.tail-lines.scan.i+1),
        'LOS_DISCOVERY_PROFILE|V20_VALIDATED_NAMED_FIELD_AND_BACKGROUND_SCAN',
        'GOAL_TO_GO_LOS_BYPASSED|false','GOAL_TO_GO|'..tostring(lines.goalToGo),'GOAL_TO_GO_POLICY|VALIDATED_BLUE_LOS; NO_YELLOW_REQUIRED; QB_SIDE_DIRECTION_CHECK; RECEIVERS_BEYOND_LOS',
        'ENDZONE_RECEIVER_POLICY|ATTACKING_ENDZONE_EXEMPT_FROM_SIX_YARDS_AND_DEEP_ONLY_DEPTH; MOVEMENT_TEAM_AND_COVERAGE_STILL_REQUIRED',
        'QB_LOS_CENTER_DEPTH|'..tostring(controller.field.lastDepth),'QB_LOS_ALLOWED_OVERLAP|'..tostring(controller.field.lastLimit),
        'LOS_READY_SOURCE|'..lines.readySource,'LOS_FAST_PATH_STATUS|'..lines.fastStatus,
        'GROUND_REASON|'..groundReason(),'GROUND_SOURCE|'..(lines.groundSource or 'NONE'),
        'GROUND_CACHED|'..describeGround(lines.ground),
        'GROUND_AMBIGUITY_OTHER|'..(lines.ambiguousGround or 'NONE'),
        'GROUND_KNOWN_PATH|workspace.Models.Field.Ground',
        'GROUND_KNOWN_REASON|'..select(2,observedGround()),
        'GROUND_KNOWN|'..describeGround((observedGround())),
        'INITIAL_FIELD_DISCOVERED|'..tostring(initialFieldDiscovered),
        'FIELD_DISCOVERY_DEADLINE_SECONDS|'..CFG.FieldDiscoverySeconds,
        'FIELD_WAIT_POLICY|READY_QB_POSSESSION_ONLY; NO_PREGAME_STARTUP_COUNTDOWN',
        'FIELD_WAIT_ARMED|'..tostring(fieldWaitSince~=nil),
        'FIELD_WAIT_ACTIVE_SECONDS|'..string.format('%.2f',fieldWaitSeconds),
        'NATIVE_MODE_OWNERSHIP|PROTECTED_SOLVE_ONLY; YUNA_AUTO_RESTORED_BETWEEN_CALLS',
        'RELEASE_VERSION|experimental-unified-b3.7','BAD_PLAY_CODE_ID|'..controller.bad.CodeId,'PRESENTATION_MODE|'..tostring(controller.presentation and controller.presentation.status),'PRESENTATION_LIGHTING|'..tostring(controller.presentation and controller.presentation.lightingStatus),'RETIRED_FEATURES|MAG_TRIAL; CUSTOM_JUMP_BULLET; WIDE_OPEN_JUMP_PREFERENCE; LEADS_AVAILABLE_IN_DATA','RANKING_POLICY|FRESH_V26_22_ADMISSION; ORDERED_COMFORT_COMPONENTS; NO_SIMULATED_CONTEST_RELIEF; NO_THREE_MS_GRADING_OMISSIONS','MODE_SCOPE_ACTIVE|'..tostring(modeTransaction~=nil),
        'MAG_TRIAL|'..tostring(controller.mag.enabled),'MAG_EXTRA_Y|'..tostring(controller.mag.extraY),
        'MAG_STATUS|'..controller.mag.status,
        'ADAPTIVE_ANGLE|'..tostring(controller.angle.enabled),'ADAPTIVE_ANGLE_STATUS|'..controller.angle.status,
        'ADAPTIVE_ANGLE_ESTIMATES|'..controller.angle.requests,
        'ANGLE_POLICY|COVERAGE_DERIVED_NATIVE_DIME_JUMP; FOUR_BOUNDED_ESTIMATES; NO_EXTRA_NATIVE_SOLVES; FIT_BULLET_LOW_BRANCH_UNCHANGED; NATIVE_OUTPUT_AND_SAFETY_RECHECK_REQUIRED',
        'MAG_POLICY|UNSUPPORTED_IN_B3; ENABLE_REJECTED; CONTROL_REMOVED',
        'JUMP_BULLET|'..tostring(controller.jumpBullet.enabled),'JUMP_BULLET_POLICY|CUSTOM_RAISED_BULLET_UNSUPPORTED; HIGH_USES_NATIVE_JUMP_OWN_LEAD_AND_FRESH_PROOFS',
        'BULLET_RISK_POLICY|SAFE_MOD_STRICT; TRUST_ORDINARY_TRAILING_CORNER_BURN_EXCEPTION; CUSTOM_JUMP_STRICT',
        'TRUST_BURN_POLICY|ORDINARY_BULLET_DIME; CURRENT_AND_PROJECTED_GAP_4; NO_OVER_TOP; EARLY_PATH_CLEAR; FINAL_CONTEST_ALLOWED',
        'TRUST_BURN_CONTEST_FRACTION|'..riskPolicy.burn.contestFraction,'TRUST_BURN_MAX_CONTEST_SECONDS|'..riskPolicy.burn.contestSeconds,
        'SAFETY_READS|'..tostring(controller.safety.enabled),'SAFETY_POLICY|HIGH_HOLDING_BULLET_ONLY; FLOATING_AUTO_ARC; DROPPING_SLANT_CHEST_THREAT_CONDITIONAL_JUMP; ORDERED_COMFORT_COMPARISON; OVERLAP_MODEL_UNCALIBRATED',
        'OPPORTUNITY_POLICY|MOD_TRUST_ROUTE_INDEPENDENT; FRESH_CACHED_RECEIVERS_REGRADED; SHORTER_READY_COMPLETIONS_PREFERRED; CANCEL_PENDING_NOT_RECEIVER',
        'REACTIVE_WINDOWS|'..tostring(controller.reactivity.enabled),'REACTIVE_CACHED_PASSES|'..controller.reactivity.cachedPasses,
        'MOTION_WATCH_CHECKS|'..controller.reactivity.checks,'MOTION_WATCH_WAKES|'..controller.reactivity.wakes,'MOVEMENT_HINTS|'..controller.reactivity.motionHints,
        'MOTION_HINT_POLICY|OPTIONAL_MOVE_DIRECTION_REGRADES_ONLY; REMOTE_INPUT_NOT_VERIFIED; NATIVE_VELOCITY_PREDICTION',
        'COVERAGE_GRADES|'..controller.coverageMath.grades,'DEFENDER_VERTICAL_BANDS|'..controller.coverageMath.verticalBands,
        'SHARED_OPTIMIZATIONS|CASUAL_AND_LEAGUE; ONE_VERTICAL_BAND_PER_DB_GRADE; REUSE_SAFETY_RESULT; CACHE_ONLY_REACTIVE_PLANNING',
        'CANCELLATION_SCOPE|PENDING_PREDICTION_ONLY; FRESH_REPLAN_SAME_RECEIVER_ALLOWED',
        'FIT_POLICY|TIMING_RESCUE_OR_ENABLED_POLICY_GRADED_LAYER_WINDOW; NO_SAFE_NON_FIT; ARRIVES_BEFORE_MODELED_DB; FRESH_COUNTERFACTUALS_AT_RELEASE',
        'MOTION_POLICY|ONE_HISTORY_SAMPLE_PER_HEARTBEAT; LIVE_POSE_AND_VELOCITY_RECHECKED_AT_RELEASE',
        'NATIVE_ENDPOINT_POLICY|HORIZONTAL_NUMERIC_TOLERANCE_MAX(0.05,RANGE*0.0001); ACTUAL_ARRIVAL_STILL_GRADED',
        'DEFENDER_MODEL|SPEED_BOUNDED_PURSUIT; INHERITED_UNCALIBRATED_REACH',
        'SAFE_OPEN_SECONDS|'..CFG.Settle,'MODEL_MAX_FLIGHT_SECONDS|NATIVE_TRAJECTORY_ABOVE_FIELD','MODEL_MAX_RANGE_STUDS|NATIVE_SOLVER_AND_FIELD_BOUNDS',
        'RISK_POLICY|SAFE=STRICT; MOD=COMFORTABLE_NON_BULLET_BURN_RACE; TRUST=TIGHTER_RACE_OR_TRAILING_CORNER_BURN; EARLY_DIRECT_PATH_AND_PREVENT_BLOCKED',
        'RISK_LIMITS|margin='..selectedRisk.margin..' lane='..selectedRisk.lane..' race='..tostring(selectedRisk.race)..' lateral='..tostring(selectedRisk.lateral)..' turn='..tostring(selectedRisk.turn),
        'MAX_HEARTBEAT_SECONDS|'..string.format('%.6f',maxHeartbeat),'MAX_NATIVE_CALLS_FRAME|'..maxFrameCalls,
        'CLOSE_BULLET_POLICY|ACTUAL_NATIVE_FLIGHT_FLOORS; COMFORT_BEFORE_FASTEST; LOWER_POWER_MUST_BE_SUPPORTED_AND_SAFE',
        'BULLET_POWER_METHOD|'..touch.method,'BULLET_POWER_METHOD_REASON|'..touch.methodReason,'BULLET_POWER_CONTROL_FAILURE|'..(touch.methodReceipt or 'NONE'),
        'BULLET_REQUEST_MIN|'..touch.min,'BULLET_COMFORT_SECONDS|'..touch.comfort,'BULLET_WINDOW_SECONDS|'..touch.quick,
        'FULL_POWER_MIN_YARDS|'..(touch.full or 'ACTUAL_FLIGHT_ONLY'),'FULL_POWER_MIN_FLIGHT_SECONDS|'..touch.comfort,
        'DEEP_THROW_YARDS|REMOVED','RECEIVER_POLICY|AUTOMATIC_SAFE_FIRST; BEST_COVERED_MANUAL_LOCK_OTHERWISE',
        'RECEIVER_SWITCH_YARDS|'..CFG.ReceiverSwitchYards,'AUTO_JUMP_REQUESTS|'..assistance.jumpCount,
        'AUTO_JUMP_POLICY|GROUNDED_PREFLIGHT; OBSERVED_TAKEOFF_STATE_MACHINE; CURRENT_ROUTE_FINAL_SOLVE; RETRY_WITHOUT_POSSESSION_BAN'..(controller.jumpTiming.delay>0 and 'OBSERVED_TAKEOFF_THEN_SHORT_OFFSET; NO_PEAK_WAIT' or 'NORMAL_REQUEST_THEN_IMMEDIATE_RELEASE; NO_ASCENT_OR_PEAK_WAIT'),
        'JUMP_DELAY_TARGET_SECONDS|'..controller.jumpTiming.delay,'JUMP_TIMING_STATUS|'..controller.jumpTiming.status,
        'JUMP_OBSERVATIONS|'..controller.jumpTiming.observations,'JUMP_TIMING_CANCELLED|'..controller.jumpTiming.cancelled,
        'LAST_JUMP_RELEASE_DELAY_SECONDS|'..tostring(controller.jumpTiming.lastReleaseDelay),
        'DEEP_POLICY|FLIGHT_EXCEEDS_CURRENT_NORMAL_JUMP_AIRTIME; NO_YARD_CUTOFF',
        'BURN_CUT_CANCEL_DEGREES|45',
        'GUIDE_MODEL|ADVISORY_NATIVE_CONTINUATION; MAX_SIX_ESTIMATES_ONE_MS_BUDGET; PARALLEL_LEFT_RIGHT_BACK; NO_AUTO_MOVEMENT; NEVER_RELEASE_AUTHORITY',
        'GUIDE_RENDER|PLAYERGUI_SEGMENTS_PROJECTED_TO_VERIFIED_GROUND; NO_WORKSPACE_OBJECTS; MAX_30_HZ; NO_DEPTH_OCCLUSION',
        'GUIDE_STATUS|'..controller.groundGuide.status,'GUIDE_DRAWS|'..controller.groundGuide.draws,
        'AUTO_JUMP_STATUS|'..assistance.jumpStatus,'AUTO_JUMP_METHOD|'..assistance.jumpMethod,
        'GUIDE_VISIBLE|'..tostring(assistance.guideUI~=nil and assistance.guideUI.Visible),
        'GUIDE_TARGET|'..(assistance.guide and assistance.guide.player.Name or 'NONE'),
        'GUIDE_OPEN_IN_SECONDS|'..(assistance.guide and string.format('%.2f',assistance.guide.lead) or 'NONE'),
        'GUIDE_FORECAST_CHECKS|'..assistance.guideChecks,'GUIDE_MAX_SECONDS|'..string.format('%.6f',assistance.maxGuideSeconds),
        'RELEASE_TIMING|'..(controller.jumpTiming.delay>0 and 'GROUND_IMMEDIATE; OBSERVED_JUMP_SHORT_OFFSET; FRESH_NATIVE_FINAL_CHECKS' or 'SHORT_IMMEDIATE; DEEP_JUMP_THEN_IMMEDIATE')..'; VISUAL_ANIMATION_AFTER_REQUEST; GUIDE_NEVER_GATES_RELEASE',
        'RELEASE_PREPARED|'..tostring(sequence~=nil),'RELEASE_PREPARE_OUTCOME|'..lastSequenceOutcome,'THROW_ANIMATION_STATUS|'..animationStatus,'THROW_ANIMATION_SOURCE|'..animationSource,
        'THROW_ANIMATION_PLAYING|'..tostring(ownedAnimation~=nil and ownedAnimation.track.IsPlaying==true),
        'THROW_ANIMATION_ASSET|'..(ownedAnimation and clean(ownedAnimation.asset) or 'NONE'),
        'WINDOW|'..(choice and choice.shot.window or 'NONE'),'PLANNER_MAX_CALLS|'..maxPlanCalls,'PLANNER_DEFERRED|'..planDeferred,
        'PLANNER_RECEIVER_POLICY|INCUMBENT_PLUS_LEAST_RECENTLY_PLANNED_CHALLENGER; EXISTING_CALL_AND_TIME_BOUNDS',
        'MIN_PLAY_SECONDS|'..CFG.MinPlayAge,'MIN_DOWNFIELD_YARDS|'..CFG.MinDownfieldYards,
        'POSSESSION_AGE_SECONDS|'..(possession.epoch>0 and string.format('%.2f',math.max(0,os.clock()-possession.since)) or 'NONE'),
        'TARGET_DEPTH_YARDS|'..(choice and lines.los and string.format('%.2f',downfield(choice.sample.p)/3) or 'NONE'),
        'OPEN_HOLD_SECONDS|'..(choice and choice.openSince and string.format('%.2f',os.clock()-choice.openSince) or 'NONE'),
        'RECEIVER_READINESS|'..'CURRENT_POSITION_BEYOND_LOS'..'; OBSERVED_RECENT_CONTINUOUS_MOVEMENT',
        'RUNTIME_VALIDATION|UNVERIFIED_IN_ROBLOX','JUMP_CATCH_CALIBRATION|MISSING; OPT_IN_NATIVE_FIT_HEIGHT_TRIAL_ONLY',
        'THROW_AWAY|MANUAL_ONLY; SOURCE_MODEL_95_GRAVITY_28; GROUNDING_RULE_UNVERIFIED',
        'RELEASE|SOURCE_NATIVE_SOLVER_OUTPUT; ONE_REQUEST_PER_POSSESSION; NO_AUTOMATIC_RETRY'}
    rows[#rows+1]=controller.history.Report()
    if controller.receiverEvidence then rows[#rows+1]=controller.receiverEvidence.Report() end
    for _,name in ipairs(observedLineNames) do
        local o=workspace:FindFirstChild(name)
        rows[#rows+1]='LOS_NAMED_LINE|'..name..' class='..(o and o.ClassName or 'MISSING')
            ..' retained='..tostring(o~=nil and lines.parts[o]==true)
    end
    if profile then
        rows[#rows+1]='NATIVE_CURRENT_SETTINGS|autoType='..tostring(profile.q.AutoThrowType.Enabled)
            ..' selectedType='..clean(profile.q.SelectedType)..' angle='..clean(profile.q.Angle)
            ..' manual='..clean(profile.q.ManualType)..' power='..clean(profile.q.Power)
            ..' locked='..tostring(profile.q.Locked)..' lockedName='..clean(profile.q.LockedOntoName)
    end
    for _,mode in ipairs({'SoftBullet','QuickBullet','Bullet','Fit','Dime','Jump','JumpBullet','CoverageJump','MagDime'}) do rows[#rows+1]='MODE_EVALUATIONS|'..mode..' '..(modeChecks[mode] or 0) end
    for _,row in ipairs(touch.traces) do rows[#rows+1]='BULLET_POWER_TRACE|'..row end
    for i,decision in ipairs(decisionHistory) do
        rows[#rows+1]='THROW_EVIDENCE|'..i..' '..decision.summary
        rows[#rows+1]='THROW_TRAJECTORY|'..i..' '..decision.trajectory
        rows[#rows+1]='THROW_RELEASE|'..i..' '..decision.release
        if decision.inputs then rows[#rows+1]='THROW_INPUTS|'..i..' '..decision.inputs end
        for _,candidate in ipairs(decision.candidates) do rows[#rows+1]='THROW_COMPARISON|'..i..' '..candidate end
        for _,actor in ipairs(decision.actors) do rows[#rows+1]='THROW_ACTOR|'..i..' '..actor end
    end
    for mode,receipt in pairs(arrivalRejects) do
        rows[#rows+1]=string.format('NATIVE_ARRIVAL_REJECT|%s %s t=%.3f arrival=%.3f,%.3f,%.3f aim=%.3f,%.3f,%.3f',mode,receipt.target,receipt.time,receipt.arrival.X,receipt.arrival.Y,receipt.arrival.Z,receipt.aim.X,receipt.aim.Y,receipt.aim.Z)
        rows[#rows+1]=string.format('NATIVE_ARRIVAL_REJECT_DETAIL|%s error=%.6f tolerance=%.6f epoch=%d; LAST_REJECTION_NOT_CURRENT_VERDICT',mode,receipt.error,receipt.tolerance,receipt.epoch)
    end
    for mode,receipt in pairs(arrivalResiduals) do
        rows[#rows+1]=string.format('NATIVE_SMALL_RESIDUAL_ACCEPTED|%s error=%.6f tolerance=%.6f epoch=%d; ARITHMETIC_ONLY_NOT_CATCH_PROOF',mode,receipt.error,receipt.tolerance,receipt.epoch)
    end
    for i,receipt in ipairs(blockedDecisions) do rows[#rows+1]='BLOCKED_DECISION|'..i..' '..receipt end
    for _,candidate in ipairs(candidateEvidence) do rows[#rows+1]='CURRENT_COMPARISON|'..candidate end
    if pending then
        rows[#rows+1]='LAST_REQUEST|'..pending.target..' '..pending.mode..' '..pending.outcome
        rows[#rows+1]='LAST_ACTION_SOURCE|'..(pending.source or 'UNKNOWN')
    end
    local blocked={}; for k,v in pairs(blacklist) do if v then blocked[#blocked+1]=k end end; table.sort(blocked)
    rows[#rows+1]='BLACKLIST|'..table.concat(blocked,',')
    for name,reason in pairs(receiverRejects) do rows[#rows+1]='RECEIVER_REJECT|'..clean(name)..' '..reason end
    local keys={}; for k in pairs(counts) do keys[#keys+1]=k end; table.sort(keys)
    for _,k in ipairs(keys) do rows[#rows+1]='GATE_COUNT|'..k..' '..counts[k] end
    for _,line in ipairs(events) do rows[#rows+1]=line end
    return table.concat(rows,'\n')
end
local function preserve(copy)
    if copy or not (type(task.defer)=='function' and type(task.cancel)=='function') then controller.history.Flush() end
    if copy then
        copyResult='UNAVAILABLE'
        if type(setclipboard)=='function' then local ok=pcall(setclipboard,controller.GetReport()); copyResult=ok and 'API_ACCEPTED' or 'FAILED' end
    end
    fileResult='UNAVAILABLE'
    if type(writefile)=='function' then
        fileResult='API_ACCEPTED'
        local ok=pcall(writefile,'PELICAN_FF3_AUTO_QB_REPORT.txt',controller.GetReport())
        if not ok then fileResult='FAILED' end
    end
    env.PELICAN_FF3_LAST_REPORT=controller.GetReport()
end
function controller.Stop(reason)
    controller.unified.holds=setmetatable({},{__mode="k"});controller.bad.open=false;controller.bad.finalActive=false;if controller.presentation then controller.presentation:stop()end;controller.unified.helperHUD:stop()
    if controller.bad.current then controller.bad.current.Stop={Reason=clean(reason or "USER_END"),At=os.clock()};if controller.bad.current.Final and not controller.bad.current.SentAt then controller.bad.current.Final.Status="STOPPED_BEFORE_REQUEST";controller.bad.current.Final.Gate=clean(reason or "USER_END")end end
    controller.reactivity.watch=nil
    if controller.league.ClearScreen then controller.league.ClearScreen('STOPPED') end
    if controller.jumpTiming.Reset then controller.jumpTiming.Reset() end
    if cleanupComplete then return true end
    if not stopped then stopReason=clean(reason or 'USER_END') end
    stopped=true; controller.IsStopped=true; fieldWaitSince=nil
    controller.angle.scene=nil;controller.angle.cache={};controller.angle.origins={}
    if controller.comeback.cancel then controller.comeback.cancel() end
    releaseChoice()
    if disposeAnimation then disposeAnimation() end
    local remaining={}
    for _,connection in ipairs(connections) do
        local ok=pcall(function() connection:Disconnect() end)
        if not ok then remaining[#remaining+1]=connection end
    end
    connections=remaining; log('STOP',reason or 'USER_END'); gate='STOPPED'
    if gui then local ok=pcall(function() gui:Destroy() end); if ok then gui=nil;assistance.guideUI=nil;assistance.guideSegments=nil end end
    if controller.receiverEvidence then controller.receiverEvidence.Stop(stopReason) end
    local friendsClean=controller.receiverFilter.stop()
    local historyClean=controller.history.Stop(stopReason,fatalError~='NONE')
    cleanupComplete=historyClean and friendsClean and (not controller.presentation or controller.presentation.clean) and #remaining==0 and gui==nil and lease==nil and modeTransaction==nil and sequence==nil and ownedAnimation==nil and assistance.jumpPlan==nil and controller.jumpTiming.track==nil and controller.jumpTiming.last==nil and controller.reactivity.watch==nil and assistance.guide==nil and controller.comeback.worker==nil
    preserve(true)
    if cleanupComplete and env[KEY]==controller then env[KEY]=nil end
    -- The loader's init pcall cannot see a later heartbeat failure. Notify it
    -- after cleanup so its retained error/report view stays visible. Reentry
    -- during loader rollback is idempotent and never resubmits this notice.
    if fatalError~='NONE' and not failureNotified then
        failureNotified=true
        local message=stopReason..': '..fatalError
        if type(context.ReportRuntimeError)=='function' then pcall(context.ReportRuntimeError,message)
        elseif type(warn)=='function' then pcall(warn,'PELICAN stopped: '..message..'; report saved') end
    end
    return cleanupComplete
end
function controller.SetAuto(value)
    auto=value==true
    if not auto then
        if controller.league.ClearScreen then controller.league.ClearScreen('AUTO_OFF') end
        resetFieldWait(); releaseChoice();if controller.comeback.cancel then controller.comeback.cancel() end
        for _,s in pairs(samples) do s.depthPeakYards=nil;s.depthEpoch=nil end
    end
    if autoButton then autoButton.Text=auto and 'AUTO ON' or 'AUTO OFF' end
    log('AUTO',auto)
end
function controller.SetThrow(value)
    throwing=value==true
    if not throwing then
        if controller.league.ClearScreen then controller.league.ClearScreen('THROW_OFF') end
        if controller.comeback.cancel then controller.comeback.cancel() end
        if cancelSequence then cancelSequence('THROW_OFF') end
        if cancelJump then cancelJump('THROW_OFF') end
    end
    if throwButton then throwButton.Text=throwing and 'THR ON' or 'THR OFF' end
    log('THROW',throwing)
end
function controller.SetRiskMode(value)
    if stopped then return false end
    local name=riskPolicy.normalize(value)
    if not name then return false end
    if name~=riskPolicy.mode then
        releaseChoice();riskPolicy.mode=name;env.PELICAN_FF3_RISK_MODE=name
        log('RISK_MODE',name);setGate('RISK_MODE_'..name)
    end
    if riskButton then riskButton.Text=riskPolicy.mode end
    return true
end
function controller.SetReceiverFilter(value)
    if stopped then return false end
    local f=controller.receiverFilter;local name=f.normalize(value)
    if controller.league.mode=='LEAGUE' and name~='ANY' then return false end
    if not name then return false end
    if name~=f.mode then
        releaseChoice()
        if controller.comeback.cancel and not controller.comeback.cancel() then return false end
        if not f.cancel() then return false end
        if f.method=='UNAVAILABLE' then f.method=nil end
        f.mode=name;f.status=name=='ANY' and 'ANY' or 'WAIT_FRIEND_CHECKS';env.PELICAN_FF3_RECEIVER_FILTER=name
        log('RECEIVER_FILTER',name);setGate('RECEIVER_FILTER_'..name)
    end
    if f.button then f.button.Text=f.mode end
    return true
end
function controller.SetPassPlan(value)
    if stopped then return false end
    local p=controller.passPlan;local name=p.normalize(value)
    if not name then return false end
    if name~=p.mode then
        releaseChoice();p.mode=name;env.PELICAN_FF3_PASS_PLAN=name
        log('PASS_PLAN',name);setGate('PASS_PLAN_'..name)
    end
    if p.button then p.button.Text=p.mode end
    return true
end
function controller.SetJumpBullet(value)
    if controller.nativeJump.supported then return false end
    if stopped or type(value)~='boolean' then return false end
    releaseChoice();controller.jumpBullet.enabled=value;env.PELICAN_FF3_JUMP_BULLET=value
    if controller.mag.RefreshModes then controller.mag.RefreshModes() end
    if controller.jumpBullet.button then controller.jumpBullet.button.Text=value and 'JB ON' or 'JB OFF' end
    log('JUMP_BULLET',value and 'OPT_IN_UNCALIBRATED_FIT_HEIGHT_TRIAL' or 'OFF')
    return true
end
function controller.SetMagTrial(value)
    if controller.league.mode=='LEAGUE' and value then return false end
    if stopped or type(value)~='boolean' then return false end
    releaseChoice();controller.mag.enabled=value;env.PELICAN_FF3_MAG_TRIAL=value
    controller.mag.status=value and 'WAIT_TRUSTED_TRAJECTORY' or 'OFF'
    if controller.mag.RefreshModes then controller.mag.RefreshModes() end
    if controller.mag.button then controller.mag.button.Text=value and 'MAG TEST' or 'MAG OFF' end
    log('MAG_TRIAL',value and 'OPT_IN_UNCALIBRATED_RAISED_DIME' or 'OFF')
    return true
end
function controller.SetAdaptiveAngle(value)
    if stopped or type(value)~='boolean' then return false end
    releaseChoice();controller.angle.enabled=value;env.PELICAN_FF3_ADAPTIVE_ANGLE=value
    controller.angle.status=value and 'WAIT_SCENE' or 'OFF'
    if controller.angle.button then controller.angle.button.Text=value and 'ARC AUTO' or 'ARC OLD' end
    return true
end
function controller.SetNativeJump(value)
    if stopped or type(value)~='boolean' or not controller.nativeJump.supported then return false end
    releaseChoice();controller.nativeJump.enabled=value;env.PELICAN_FF3_NATIVE_JUMP=value
    if controller.mag.RefreshModes then controller.mag.RefreshModes() end
    if controller.nativeJump.button then controller.nativeJump.button.Text=value and 'HIGH ON' or 'HIGH OFF' end
    return true
end
if context.RegisterCleanup then context.RegisterCleanup(function() return controller.Stop('LOADER_CLEANUP') end) end
if context.IsCancelled and context.IsCancelled() then controller.Stop('CANCELLED'); return controller end
env[KEY]=controller
controller.history.Start()
if stopped or context.IsCancelled and context.IsCancelled() then controller.Stop('CANCELLED');return controller end

-- Bounded read-only discovery. A final solver must be shared by a live preview
-- connection and the source-shaped input release, and capture the same settings
-- table as the native selector. No fixed upvalue indexes or callable guesses.
local getUV=getupvalues or (debug and debug.getupvalues)
local getK=getconstants or (debug and debug.getconstants)
local function constants(fn)
    local ok,values=pcall(getK,fn); local result={}
    if ok and type(values)=='table' then for _,v in pairs(values) do if type(v)=='string' or type(v)=='number' then result[v]=true end end end
    return result
end
local function has(c,...)
    for i=1,select('#',...) do if not c[select(i,...)] then return false end end
    return true
end
local function values(fn)
    local ok,v=pcall(getUV,fn); return ok and type(v)=='table' and v or {}
end
local modes={Bullet=true,Fit=true,Jump=true,Dive=true,Dime=true}
local function settings(t)
    return type(t)=='table' and getmetatable(t)==nil and type(rawget(t,'Enabled'))=='boolean'
        and type(rawget(t,'MouseAimbot'))=='table' and type(rawget(t,'AutoThrowType'))=='table'
        and modes[rawget(t,'SelectedType')]==true and finite(rawget(t,'Angle'))
        and (rawget(t,'ManualType')=='Angle' or rawget(t,'ManualType')=='Power')
end
local function leadTable(t)
    if type(t)~='table' or getmetatable(t)~=nil then return false end
    for _,name in ipairs({'Bullet','Fit','Dime','Jump','Dive'}) do
        local v=rawget(t,name)
        if typeof(v)~='Vector2' or not finite(v.X) or not finite(v.Y) then return false end
    end
    return true
end
local function hud(t)
    if type(t)~='table' or getmetatable(t)~=nil then return false end
    for _,key in ipairs({'Player','Time','Angle','Type'}) do
        local card=rawget(t,key)
        if type(card)~='table' or not instance(rawget(card,'CardText'),'TextLabel') then return false end
    end
    return true
end
local function state(t)
    local statusValue,throwableValue
    if typeof(t)=='Instance' then
        statusValue,throwableValue=t:FindFirstChild('Status'),t:FindFirstChild('Throwable')
    elseif type(t)=='table' and getmetatable(t)==nil then
        statusValue,throwableValue=rawget(t,'Status'),rawget(t,'Throwable')
    end
    if instance(statusValue,'StringValue') and instance(throwableValue,'BoolValue') then
        return {Status=statusValue,Throwable=throwableValue}
    end
end
local function tables(uv)
    local result,seen={},{}
    local function add(t,depth)
        if seen[t] or #result>=80 then return end
        if typeof(t)=='Instance' then seen[t]=true; result[#result+1]=t; return end
        if type(t)~='table' or getmetatable(t)~=nil then return end
        seen[t]=true; result[#result+1]=t
        if depth>0 then
            local n=0
            for _,v in pairs(t) do n=n+1; if n>40 then break end; add(v,depth-1) end
        end
    end
    for _,v in pairs(uv) do add(v,2) end
    return result
end
local function graph(root)
    local list,seen={{fn=root,depth=0}},{}
    local at=1
    while at<=#list and at<=64 do
        local node=list[at]; at=at+1
        seen[node.fn]=true; node.uv=values(node.fn); node.k=constants(node.fn)
        if node.depth<3 then
            for _,v in pairs(node.uv) do
                if type(v)=='function' and not seen[v] and #list<64 then seen[v]=true; list[#list+1]={fn=v,depth=node.depth+1} end
            end
        end
    end
    return list
end
local function nativeLeads(fn)
    local found
    for _,node in ipairs(graph(fn)) do
        for _,t in ipairs(tables(node.uv)) do
            if leadTable(t) then if found and found~=t then return nil end; found=t end
        end
    end
    return found
end
local function aliveConnection(c)
    local ok,result=pcall(function() return c.Connected~=false and c.Enabled~=false end)
    return ok and result
end
local function roots(signal,kind)
    local ok,all=pcall(getconnections,signal); local out={}
    if not ok or type(all)~='table' then return out end
    local checked=0
    for _,connection in pairs(all) do
        checked=checked+1; if checked>160 then break end
        local got,fn=pcall(function() return connection.Function end)
        if got and type(fn)=='function' and aliveConnection(connection) then
            local c=constants(fn)
            local matches=kind=='preview' and has(c,'Angle','SelectedType','MouseAimbot','Enabled')
                or kind=='release' and has(c,'Clicked','RemoteEvent','FireServer','TimePosition',70000000)
            if matches then out[#out+1]={connection=connection,fn=fn,nodes=graph(fn)} end
        end
    end
    return out
end
local function discover()
    if type(getconnections)~='function' or type(getUV)~='function' or type(getK)~='function' then return nil,'EXECUTOR_REFLECTION_MISSING' end
    local previews,releases=roots(Run.Heartbeat,'preview'),roots(Input.InputBegan,'release')
    local matches={}; local seen={}; local missingLeads=false
    for _,p in ipairs(previews) do
        for _,n in ipairs(p.nodes) do
            if has(n.k,'AutoThrowType','CardText','CardName','Player','Time','Type','Head') then
                local q,h,selector
                for _,t in ipairs(tables(n.uv)) do if settings(t) then if q and q~=t then q=false; break end; q=t end end
                if q then
                    for _,t in ipairs(tables(n.uv)) do if hud(t) then h=t end end
                    for _,fn in pairs(n.uv) do
                        if type(fn)=='function' and has(constants(fn),'LockedOnto','LockedOntoName','GetMouseLocation','GetPlayers') then
                            for _,t in ipairs(tables(values(fn))) do if t==q then selector=fn end end
                        end
                    end
                end
                if q and h and selector then
                    for _,r in ipairs(releases) do
                        local same=false; for _,rn in ipairs(r.nodes) do if rn.fn==n.fn then same=true end end
                        local leads=nativeLeads(n.fn)
                        if same and not leads then missingLeads=true end
                        local s; for _,t in ipairs(tables(values(r.fn))) do local found=state(t); if found then s=found end end
                        if same and s and leads and not seen[n.fn] then
                            seen[n.fn]=true; matches[#matches+1]={q=q,hud=h,selector=selector,solve=n.fn,state=s,preview=p.connection,release=r.connection,leads=leads}
                        end
                    end
                end
            end
        end
    end
    if #matches~=1 then return nil,#matches==0 and (missingLeads and 'NATIVE_LEAD_TABLE_MISSING_OR_AMBIGUOUS' or 'WAIT_YUNA_SOURCE_PROFILE') or 'AMBIGUOUS_YUNA_INSTANCES' end
    return matches[1]
end
local function equipped(model)
    local found
    for _,child in ipairs(model:GetChildren()) do
        if child:IsA('Tool') then
            local handle=child:FindFirstChild('Handle'); local remote=handle and handle:FindFirstChild('RemoteEvent')
            if remote and remote:IsA('RemoteEvent') then if found then return end; found={tool=child,remote=remote} end
        end
    end
    return found
end
-- Resolve an existing game Throw asset, never an invented animation ID and
-- never Tool:Activate() (which could also submit an uncontrolled native throw).
local function throwAsset(value,role)
    if instance(value,'AnimationTrack') then
        local asset=value.Animation
        if instance(asset,'Animation') and (role or value.Name=='Throw' or asset.Name=='Throw') then
            return asset,value.Priority
        end
    elseif instance(value,'Animation') and (role or value.Name=='Throw') then return value end
end
local function findThrowAsset(ball)
    local found,priority,source,ambiguous
    local function add(value,role,why)
        local asset,p=throwAsset(value,role)
        if not asset then return end
        local id=asset.AnimationId
        if type(id)~='string' or not id:match('^rbxassetid://%d+$') and not id:match('^https?://[^%s]+[?&]id=%d+') then return end
        if found and found.AnimationId~=id then ambiguous=true; return end
        found,priority,source=asset,p or priority,why
    end
    -- A native Throw track observed on this very character is strongest evidence.
    if observedThrow and observedThrow.model==ball.model then
        add(observedThrow.track,true,'OBSERVED_CURRENT_CHARACTER_THROW')
        if found then return found,priority,source end
    end
    -- Inspect captures, not callable guesses. Only the already-qualified native
    -- release and actual equipped tool's Activated closures are considered.
    local rootsToInspect={profile.release.Function}
    if type(getconnections)=='function' then
        local ok,connectionsForTool=pcall(getconnections,ball.tool.Activated)
        if ok and type(connectionsForTool)=='table' then
            local n=0
            for _,connection in pairs(connectionsForTool) do
                n=n+1; if n>16 then break end
                local got,fn=pcall(function() return connection.Function end)
                if got and type(fn)=='function' and aliveConnection(connection) then rootsToInspect[#rootsToInspect+1]=fn end
            end
        end
    end
    for _,fn in ipairs(rootsToInspect) do
        if type(fn)=='function' then
            for _,node in ipairs(graph(fn)) do
                for _,value in pairs(node.uv) do add(value,false,'QUALIFIED_RELEASE_OR_TOOL_CAPTURE') end
                for _,t in ipairs(tables(node.uv)) do
                    add(t,false,'QUALIFIED_RELEASE_OR_TOOL_CAPTURE')
                    if type(t)=='table' and getmetatable(t)==nil then
                        add(rawget(t,'Throw'),true,'QUALIFIED_THROW_TABLE_ENTRY')
                    end
                end
            end
        end
    end
    if ambiguous then return nil,nil,'AMBIGUOUS_CAPTURED_THROW_ASSETS' end
    if found then return found,priority,source end
    -- Bounded local asset search. No world scan and no remote/function invocation.
    local rootsToScan={ball.model}
    local replicated=game:GetService('ReplicatedStorage')
    for _,child in ipairs(replicated:GetChildren()) do
        if child.Name:lower():find('anim',1,true) then rootsToScan[#rootsToScan+1]=child end
    end
    local stack={}; for _,root in ipairs(rootsToScan) do stack[#stack+1]=root end
    local visited=0
    while #stack>0 and visited<256 do
        local object=table.remove(stack); visited=visited+1
        add(object,object.Parent and object.Parent.Name=='Throw','LOCAL_OR_REPLICATED_ANIMATION_ASSET')
        local children=object:GetChildren()
        if #children+#stack>256 then return nil,nil,'LOCAL_ANIMATION_SEARCH_LIMIT' end
        for _,child in ipairs(children) do stack[#stack+1]=child end
    end
    if #stack>0 then return nil,nil,'LOCAL_ANIMATION_SEARCH_LIMIT' end
    if ambiguous then return nil,nil,'AMBIGUOUS_LOCAL_THROW_ASSETS' end
    return found,priority,source or 'NATIVE_THROW_ASSET_NOT_FOUND'
end
disposeAnimation=function()
    if not ownedAnimation then return true end
    local track=ownedAnimation.track
    local ok=pcall(function() if track.IsPlaying then track:Stop() end; track:Destroy() end)
    if ok then ownedAnimation=nil end
    return ok
end
cancelSequence=function(reason)
    local old=sequence; sequence=nil
    if not old then return end
    lastSequenceOutcome=reason or 'CANCELLED'
    if old.animation and old.animation.track.IsPlaying then
        local ok,err=pcall(function() old.animation.track:Stop() end)
        if not ok then animationStatus='OWNED_ANIMATION_CLEANUP_FAILED'; log('ANIMATION_CLEANUP_ERROR',err) end
    end
    log('RELEASE_CANCEL',reason or 'CANCELLED')
end
local visual={}
function visual.prepare(ball,now)
    if ownedAnimation and (ownedAnimation.model~=ball.model or ownedAnimation.hum~=ball.hum) then
        if not disposeAnimation() then error('Owned throw animation cleanup failed') end
    end
    if not ownedAnimation then
        local asset,priority,why=findThrowAsset(ball)
        animationSource=why or 'NONE'
        if not asset then
            -- Preserve the user-confirmed V17 release when no actual asset is
            -- exposed. Report the limitation explicitly instead of guessing one.
            animationStatus=why or 'NATIVE_THROW_ASSET_NOT_FOUND'
            log('ANIMATION_UNAVAILABLE',animationStatus); return nil
        end
        local animator=ball.hum:FindFirstChildOfClass('Animator')
        if not animator then animationStatus='CURRENT_ANIMATOR_MISSING'; log('ANIMATION_UNAVAILABLE',animationStatus); return nil end
        local track=animator:LoadAnimation(asset)
        if not instance(track,'AnimationTrack') then error('Native Throw asset did not return an AnimationTrack') end
        if stopped then track:Destroy();return nil end
        ownedAnimation={track=track,model=ball.model,hum=ball.hum,source=animationSource,asset=asset.AnimationId}
        track.Name='PELICAN_AUTO_THROW'; track.Looped=false
        track.Priority=priority or Enum.AnimationPriority.Action
    end
    local track=ownedAnimation.track
    if track.IsPlaying then track:Stop() end
    animationStatus='OWN_NATIVE_THROW_PREPARED';animationSource=ownedAnimation.source
    return {track=track,at=now}
end
function visual.play(prepared)
    if not prepared or not ownedAnimation or prepared.track~=ownedAnimation.track then return end
    local track=prepared.track
    track:Play()
    animationStatus='OWN_NATIVE_THROW_STARTED'; animationSource=ownedAnimation.source
end
function visual.start(ball,now)
    local prepared=visual.prepare(ball,now);visual.play(prepared);return prepared
end

-- Manual UI actions can arrive between decision ticks. Share possession
-- observation so they cannot reserve epoch zero or reuse an old play epoch.
local function observePossession(now)
    local nativeReady=profile and profile.state.Status.Value=='InPlay' and profile.state.Throwable.Value==true
    local model=body(me)
    local ball=model and equipped(model)
    local tool=ball and ball.tool
    if nativeReady and tool then
        if not possession.wasReady or possession.tool~=tool or possession.model~=model then
            if controller.league.ClearScreen then controller.league.ClearScreen('POSSESSION_CHANGED') end
            possession.epoch=possession.epoch+1
            possession.tool,possession.model=tool,model
            possession.since=now
            resetFieldWait(); releaseChoice()
            log('POSSESSION',possession.epoch)
        end
        possession.wasReady=true
    else
        if pending and possession.wasReady then
            controller.history.Append('possession_end',{Epoch=possession.epoch,Source=pending.source,Catch='UNKNOWN'})
            pending.outcome='POSSESSION_ENDED; THROW_NOT_VERIFIED'
        end
        possession.wasReady=false
        if controller.league.ClearScreen then controller.league.ClearScreen('POSSESSION_ENDED') end
    end
end
local function ready(manual)
    if stopped or (context.IsCancelled and context.IsCancelled()) then return nil,'STOPPED' end
    if not manual and not auto then return nil,'AUTO_OFF' end
    if not profile then return nil,'WAIT_YUNA_SOURCE_PROFILE' end
    if manual and (not aliveConnection(profile.preview) or not aliveConnection(profile.release)) then return nil,'WAIT_YUNA_SOURCE_PROFILE' end
    local q=profile.q
    if not manual and not q.Enabled then return nil,'ENABLE_YUNA_QB_AIMBOT' end
    if not manual and q.MouseAimbot.Enabled then return nil,'YUNA_MOUSE_AIM_ACTIVE' end
    if not manual and q.AutoThrowType.Enabled~=true then return nil,'ENABLE_YUNA_AUTO_THROW_TYPE' end
    if profile.state.Status.Value~='InPlay' or profile.state.Throwable.Value~=true then return nil,'WAIT_THROWABLE_PLAY' end
    if not me.Team or me.Neutral then return nil,'WAIT_TEAM' end
    local model,root,head,hum=body(me)
    if not model then return nil,'WAIT_QB_ALIVE' end
    local ball=equipped(model)
    if not ball then return nil,'WAIT_EQUIPPED_BALL' end
    -- Same native animation observation as readable fn26. Manual Yuna input
    -- owns a throw already in progress; AUTO must not submit a competing one.
    local observed,tracks=pcall(function() return hum:GetPlayingAnimationTracks() end)
    if not observed or type(tracks)~='table' then return nil,'NATIVE_ANIMATION_OBSERVATION_FAILED' end
    for _,track in ipairs(tracks) do
        if track.Name=='Throw' and track.IsPlaying and (not ownedAnimation or track~=ownedAnimation.track) then
            ball.nativeThrow=true; observedThrow={model=model,track=track}; break
        end
    end
    ball.model,ball.root,ball.head,ball.hum=model,root,head,hum
    return ball
end
-- Deliberate manual throw-away. Uses the existing observed request shape,
-- never the teammate selector and never an automatic covered-pass fallback.
function controller.ThrowAway()
    if stopped then return false end
    local success,result=pcall(function()
        observePossession(os.clock())
        local ball,why=ready(true)
        if not ball then setGate(why);return false end
        if ball.nativeThrow or usedTools[ball.tool]==possession.epoch then setGate('THROW_ALREADY_OWNED');return false end
        if groundReason()~='ACCEPTED' or not onField(ball.root.Position) then setGate('THROW_AWAY_FIELD_UNVERIFIED');return false end
        local ground=lines.ground
        local groundFrame,generation=ground.CFrame,lines.generation
        local origin=ball.head.Position
        local p=groundFrame:PointToObjectSpace(origin)
        local power=95 -- preserved native Fit/Bullet nominal power, not a setting change
        local range=power*power/CFG.Gravity
        local best
        for _,side in ipairs({-1,1}) do
            local z=p.Z
            if lines.los and lines.forward then
                local los=groundFrame:PointToObjectSpace(lines.los)
                local forward=-lines.forward:Dot(groundFrame.LookVector)
                -- Keep the modeled exit downfield of the verified blue line.
                z=clamp(los.Z+forward*CFG.MinDownfieldYards*3,-170,170)
            end
            local target=groundFrame:PointToWorldSpace(V(side*85,p.Y,z))
            local delta=flat(target-origin);local distance=delta.Magnitude
            if distance>.05 and distance<range*.95 then
                local modeledRange=math.min(distance*2,range*.95)
                local angle=math.min(math.rad(80),(math.pi-math.asin(CFG.Gravity*modeledRange/(power*power)))/2)
                local velocity=delta.Unit*(power*math.cos(angle))+V(0,power*math.sin(angle),0)
                local edgeFraction=(side*80-p.X)/(side*85-p.X)
                local time=distance*edgeFraction/(power*math.cos(angle))
                local crossing=origin+velocity*time-V(0,.5*CFG.Gravity*time*time,0)
                local downfieldExit=not lines.los or not lines.forward or downfield(crossing)>0
                if time>0 and crossing.Y>origin.Y and downfieldExit and (not best or crossing.Y>best.height) then
                    best={velocity=velocity,height=crossing.Y,time=time,angle=angle,point=crossing}
                end
            end
        end
        if not best then setGate('THROW_AWAY_NO_HIGH_EXIT');return false end
        -- A second readiness observation precedes reservation; ordinary native
        -- manual input/other attempts always prevent a competing request.
        local current=ready(true)
        if not current or current.tool~=ball.tool or current.nativeThrow or usedTools[ball.tool]==possession.epoch then return false end
        releaseChoice();if receiverMenu then receiverMenu.Visible=false end
        usedTools[ball.tool]=possession.epoch
        local epoch=possession.epoch
        pending={tool=ball.tool,model=ball.model,target='OUT_OF_BOUNDS',mode='MANUAL_HIGH_AWAY',at=os.clock(),outcome='PREPARING',source='MANUAL_AWAY'}
        visual.start(ball,os.clock())
        if stopped then return false end
        local final=ready(true)
        if not final or final.tool~=ball.tool or final.remote~=ball.remote or final.model~=ball.model or final.nativeThrow
            or possession.epoch~=epoch or not possession.wasReady then
            if pending then pending.outcome='CANCELLED_BEFORE_REQUEST' end
            disposeAnimation();setGate('THROW_AWAY_CONTEXT_CHANGED');return false
        end
        -- Animation loading can yield; do not send a direction solved from a
        -- stale launch point or field reference after it returns.
        if lines.ground~=ground or ground.CFrame~=groundFrame or lines.generation~=generation or groundReason()~='ACCEPTED'
            or (final.head.Position-origin).Magnitude>.5 then
            pending.outcome='CANCELLED_BEFORE_REQUEST';disposeAnimation();setGate('THROW_AWAY_CONTEXT_CHANGED');return false
        end
        local unit=best.velocity.Unit
        attempts=attempts+1;pending.outcome='REQUESTING'
        log('THROW_AWAY',string.format('manual power=95 angle=%.2f modeledExitY=%.2f exitT=%.3f grounding=UNVERIFIED',math.deg(best.angle),best.height,best.time))
        local ok,err=pcall(function() ball.remote:FireServer('Clicked',origin-unit*5+V(70000000,0,0),origin+unit*10000,power,1) end)
        controller.history.Shot({mode='MANUAL_HIGH_AWAY',power=power,origin=origin,velocity=best.velocity,time=best.time,arrival=best.point},nil,nil,ok and 'API_ACCEPTED_UNCONFIRMED' or 'AMBIGUOUS_NO_RETRY','MANUAL_AWAY')
        if ok then sent=sent+1;pending.outcome='API_ACCEPTED_UNCONFIRMED';setGate('THROW_AWAY_SENT_UNCONFIRMED')
        else ambiguous=ambiguous+1;pending.outcome='AMBIGUOUS_NO_RETRY';fatalError=clean(err);controller.Stop('REQUEST_AMBIGUOUS_NO_RETRY');return false end
        preserve(false);return true
    end)
    if not success then fatalError=clean(result);log('THROW_AWAY_ERROR',result);controller.Stop('THROW_AWAY_RUNTIME_ERROR');return false end
    return result
end

local function sample(player,now)
    local model,root,head,hum=body(player)
    if not model then samples[player]=nil; return end
    local velocity=root.AssemblyLinearVelocity
    if not vector(velocity) or flat(velocity).Magnitude>55 then return end
    local s=samples[player]
    if not s or s.model~=model or now-(s.motionAt or s.at)>.35 then
        s={model=model,p=root.Position,v=velocity,at=now,n=1,turn=0,routeTurn=0,path={},motionSince=nil,observedSpeed=0,
            motionAt=now,motionP=root.Position,motionV=velocity,motionFrame=motionFrame,readyAt=now,readyP=root.Position}; samples[player]=s
        s.path[1]={at=now,p=root.Position}
    elseif s.motionFrame~=motionFrame then
        local dt=now-s.motionAt
        if dt>0 then
            local observed=(root.Position-s.motionP)/dt
            -- A teleport makes interception estimates stale, rather than a route ban.
            if observed.Magnitude>100 then s.n=0; s.path={}; s.motionSince=nil end
            local readyElapsed=now-(s.readyAt or s.motionAt)
            if observed.Magnitude>100 then
                s.readyAt=now;s.readyP=root.Position;s.observedSpeed=0
            elseif readyElapsed>=CFG.Interval then
                s.observedSpeed=flat(root.Position-(s.readyP or s.motionP)).Magnitude/readyElapsed
                if s.observedSpeed>=CFG.MinMoveSpeed and flat(velocity).Magnitude>=CFG.MinMoveSpeed then
                    s.motionSince=s.motionSince or s.readyAt or s.motionAt
                else s.motionSince=nil end
                s.readyAt=now;s.readyP=root.Position
            elseif flat(velocity).Magnitude<CFG.MinMoveSpeed then s.motionSince=nil end
            s.acceleration=flat(velocity-s.motionV)/dt
            s.turn=clamp((velocity-s.motionV).Magnitude/30,0,1)
            s.routeTurn=clamp(flat(velocity-s.motionV).Magnitude/30,0,1)
            s.n=s.n+1
            s.motionP,s.motionV,s.motionAt=root.Position,velocity,now
            s.path[#s.path+1]={at=now,p=root.Position}
        end
        s.motionFrame=motionFrame
    end
    local readElapsed=now-s.motionAt
    if readElapsed>0 and (root.Position-s.motionP).Magnitude/readElapsed>100 then
        s.n=0;s.path={};s.motionSince=nil
    end
    -- Re-reading an unchanged pose during a native solve/animation is not a
    -- second physics observation. Keep AFK history intact, but inspect actual
    -- current position/velocity so a stop, cut or teleport cannot slip through.
    s.turn=math.max(s.turn,clamp((velocity-s.v).Magnitude/30,0,1))
    s.routeTurn=math.max(s.routeTurn,clamp(flat(velocity-s.v).Magnitude/30,0,1))
    s.p,s.v,s.at=root.Position,velocity,now
    while #s.path>1 and now-s.path[1].at>CFG.MotionWindow do table.remove(s.path,1) end
    s.hum,s.head,s.root,s.name=hum,head,root,player.Name
    s.oscillation=controller.unified.oscillation.detect(s.path,lines.forward,now,CFG)
    controller.passPlan.observe(s,player)
    return s
end
function controller.unified.ObserveOscillation(now)
    if not auto or not profile or now<(controller.unified.nextMotionAt or 0) then return end
    controller.unified.nextMotionAt=now+.05 -- bounded observation cadence, not native solve work
    for player in pairs(samples)do if teammate(player)then sample(player,now)end end
end
local function receiverReady(player,s,now,point)
    if controller.IsBlacklisted(player) then return false,'BLACKLISTED' end
    if not teammate(player) then return false,'NOT_CURRENT_TEAMMATE' end
    if (not lines.los or lines.status~='OBSERVED_LINES_STABLE' or now-lines.at>.3) then return false,'LOS_UNVERIFIED' end
    if not s or s.n<2 or now-s.at>.3 then return false,'MOVEMENT_UNVERIFIED' end
    local model,root=body(player)
    if not model or model~=s.model then return false,'MOVEMENT_UNVERIFIED' end
    if not onField(root.Position) then return false,'OFF_FIELD' end
    if controller.league.ScreenEligible and controller.league.ScreenEligible(player,s,now) then
        if point and (downfield(point)>0 or not onField(point)) then return false,'SCREEN_ARRIVAL_NOT_BEHIND_LOS' end
        return true
    end
    if not controller.field.BeyondMinimum(root.Position) then return false,'INSIDE_OR_TOO_CLOSE_TO_LOS' end
    if not vector(root.AssemblyLinearVelocity) or not s.oscillation and flat(root.AssemblyLinearVelocity).Magnitude<CFG.MinMoveSpeed then return false,'IDLE_OR_ROUTE_NOT_READY' end
    if not s.oscillation and (not s.motionSince or now-s.motionSince<CFG.MinMotionAge or s.observedSpeed<CFG.MinMoveSpeed) then return false,'IDLE_OR_ROUTE_NOT_READY' end
    local travel=0
    for i=2,#s.path do travel=travel+flat(s.path[i].p-s.path[i-1].p).Magnitude end
    if travel<CFG.MinMotionTravel then return false,'INSUFFICIENT_RECENT_MOVEMENT' end
    if point and (not controller.field.BeyondMinimum(point) or not onField(point)) then return false,'ARRIVAL_INSIDE_LOS_OR_OFF_FIELD' end
    return controller.receiverFilter.allowed(player)
end
-- League profile reuses the existing bounded HUD scan and native controller.
do
    local l=controller.league
    function l.VipText(raw)
        return type(raw)=='string' and raw:gsub('<[^>]*>',''):gsub('^%s+',''):gsub('%s+$',''):upper()=='VIP SERVER'
    end
    function l.UI(action,...)
        local ok,result=pcall(action,...)
        if not ok then fatalError=clean(result);log('LEAGUE_UI_ERROR',result);controller.Stop('LEAGUE_UI_ERROR');return false end
        return result
    end
    function l.ClearScreen(reason)
        local old=l.screen;l.screen=nil;l.screenStatus=reason or 'OFF'
        if l.screenButton then l.screenButton.Text='SCREEN' end
        if old then
            opportunities[old.player]=nil;shotCache[old.player]=nil
            if choice and choice.player==old.player then releaseChoice() end
            log('SCREEN_STOP',l.screenStatus)
        end
    end
    function l.ValidScreen(now)
        local a=l.screen
        if not a or stopped or l.mode~='LEAGUE' or not auto or not throwing or not possession.wasReady
            or a.epoch~=possession.epoch or a.generation~=lines.generation or a.team~=me.Team
            or a.qbModel~=me.Character or a.tool~=possession.tool or usedTools[a.tool]==a.epoch or not teammate(a.player) or a.model~=a.player.Character then return false end
        local _,root=body(a.player)
        return root~=nil and onField(root.Position) and downfield(root.Position)<=0 and downfield(root.Position)>=-l.screenDepth*3
    end
    function l.ScreenEligible(player,s,now)
        local a=l.screen
        if not a or a.player~=player or not l.ValidScreen(now) or not s or s.n<2 or now-s.at>.3 then return false end
        local _,root=body(player)
        return root~=nil and vector(root.AssemblyLinearVelocity) and flat(root.AssemblyLinearVelocity).Magnitude<CFG.MinMoveSpeed
            and (s.observedSpeed or math.huge)<CFG.MinMoveSpeed
    end
    function controller.SelectScreen(player)
        if stopped or l.mode~='LEAGUE' or not auto or not throwing or not instance(player,'Player') or player==me or not teammate(player) then return false end
        observePossession(os.clock())
        local ball,why=ready()
        if not ball or not readLines(os.clock()) or controller.field.QBPast(ball.root) then setGate(why or 'SCREEN_REQUIRES_VALID_QB_LOS');return false end
        if usedTools[ball.tool]==possession.epoch then setGate('SCREEN_POSSESSION_ALREADY_ATTEMPTED');return false end
        local model,root=body(player)
        if not model or not onField(root.Position) or downfield(root.Position)>0 or downfield(root.Position)<-l.screenDepth*3 then
            setGate('SCREEN_PLAYER_MUST_BE_JUST_BEHIND_LOS');return false
        end
        releaseChoice();l.ClearScreen('RESELECTED')
        l.screen={player=player,model=model,epoch=possession.epoch,generation=lines.generation,team=me.Team,qbModel=me.Character,tool=ball.tool}
        l.screenStatus='ARMED_THIS_POSSESSION';if l.screenButton then l.screenButton.Text='SCR ON' end
        if receiverMenu then receiverMenu.Visible=false end
        setGate('SCREEN_ARMED_THIS_POSSESSION');log('SCREEN_ARM','Explicit stationary receiver exception; same possession only')
        return true
    end
    function controller.SetProfile(value,source)
        if stopped or not ({AUTO=true,CASUAL=true,LEAGUE=true})[value] then return false end
        l.requested=value
        if source=='USER' then ff3Options.Profile=value end -- loader X retains deliberate profile selection
        local mode=(value=='LEAGUE' or value=='AUTO' and l.vipSeen) and 'LEAGUE' or 'CASUAL'
        if l.mode~=mode then
            releaseChoice();l.ClearScreen('PROFILE_CHANGED')
            if not controller.comeback.cancel() or not controller.receiverFilter.cancel() then
                fatalError='Profile worker cleanup failed';controller.Stop('PROFILE_CLEANUP_FAILED');return false
            end
            if mode=='LEAGUE' then
                l.saved={filter=controller.receiverFilter.mode,mag=controller.mag.enabled,chat=controller.comeback.enabled,plan=controller.passPlan.mode}
                controller.receiverFilter.mode='ANY';controller.receiverFilter.status='LEAGUE_ANY'
                controller.mag.enabled=false;controller.mag.status='LEAGUE_OFF';controller.comeback.enabled=false;controller.comeback.status='LEAGUE_OFF'
                controller.passPlan.mode='NORMAL'
            elseif l.saved then
                controller.receiverFilter.mode=l.saved.filter;controller.receiverFilter.status=l.saved.filter=='ANY' and 'ANY' or 'WAIT_FRIEND_CHECKS'
                controller.mag.enabled=l.saved.mag;controller.comeback.enabled=l.saved.chat;controller.passPlan.mode=l.saved.plan;l.saved=nil
            end
            l.mode=mode;controller.mag.RefreshModes()
            if receiverMenu then receiverMenu.Visible=false end
            expanded=false;log('PROFILE_MODE',mode)
        end
        l.source=source or (value=='AUTO' and l.vipSeen and 'VISIBLE_VIP_HINT_UNVERIFIED_LEAGUE' or 'EXPLICIT_PROFILE')
        if l.Paint then l.Paint() end
        return true
    end
    function l.Update(now)
        if l.screen and not l.ValidScreen(now) then l.ClearScreen('SCREEN_CONTEXT_CHANGED') end
        if now<l.nextCheck then return end
        l.nextCheck=now+.5
        if l.requested=='AUTO' and not l.vipSeen then
            for _,o in ipairs(lines.labels) do
                if o.Parent and o:IsDescendantOf(pg) and l.VipText(o.Text) then
                    local shown=true;local at=o
                    for _=1,16 do
                        if not at then break end
                        if instance(at,'GuiObject') and not at.Visible or instance(at,'LayerCollector') and not at.Enabled then shown=false;break end
                        at=at.Parent
                    end
                    local camera=workspace.CurrentCamera
                    if shown and (not finite(o.TextTransparency) or o.TextTransparency<1) and camera and o.AbsolutePosition.X+o.AbsoluteSize.X>0 and o.AbsolutePosition.X<camera.ViewportSize.X and o.AbsolutePosition.Y>=0 and o.AbsolutePosition.Y<camera.ViewportSize.Y*.4
                        and o.AbsoluteSize.X>0 and o.AbsoluteSize.Y>0 then
                        l.vipSeen=true;controller.SetProfile('AUTO','VISIBLE_VIP_HINT_UNVERIFIED_LEAGUE');break
                    end
                end
            end
        end
    end
end

-- Optional team-only route call. Reuses the decision snapshot; no native solves,
-- world scan, chat UI manipulation, public-channel or guessed remote fallback.
function controller.comeback.cancel()
    local c=controller.comeback
    c.observations={};c.snapshot=nil
    local work=c.worker
    if work then
        work.active=false
        if work.invoked then c.outcome='CANCELLED_IN_FLIGHT_DELIVERY_UNKNOWN' end
        if work.thread and coroutine.status(work.thread)~='dead' and coroutine.running()~=work.thread then
            local ok=pcall(task.cancel,work.thread)
            if not ok then return false end
        end
        c.worker=nil
    end
    return true
end
function controller.SetComebackChat(value)
    if controller.league.mode=='LEAGUE' and value then return false end
    if stopped or type(value)~='boolean' then return false end
    if not controller.comeback.cancel() then return false end
    local c=controller.comeback
    c.enabled=value;env.PELICAN_FF3_COMEBACK_CHAT=value;c.status=value and 'IDLE' or 'OFF'
    if c.button then c.button.Text=value and 'CB ON' or 'CB OFF' end
    return true
end
function controller.comeback.near(s,d)
    if not lines.forward or not onField(d.p) then return false end
    local gap=flat(s.p-d.p);local distance=gap.Magnitude
    -- This is a route-call policy, not a measured interception/catch radius.
    -- A WR already coming back or separating does not need this instruction.
    return distance<=15 and (d.p-s.p):Dot(lines.forward)>=-3
        and flat(s.v):Dot(lines.forward)>=-2
        and (distance<.1 or flat(s.v-d.v):Dot(gap/distance)<=2)
end
-- Route advice only: these explicit space/observation policies are not catch
-- radii or a new throw solver. Right is the WR's right while facing downfield.
function controller.comeback.prevent(s,defenders)
    if not lines.forward then return end
    local forward=lines.forward;local velocity=flat(s.v);local speed=velocity.Magnitude
    if speed<8 or velocity:Dot(forward)<speed*.85 then return end
    local right=V(-forward.Z,0,forward.X);local prevent,nearest=nil,math.huge
    for _,d in ipairs(defenders) do
        local gap=flat(d.p-s.p);local ahead=gap:Dot(forward)
        if onField(d.p) and ahead>=0 and ahead<=speed*1.4+12 and math.abs(gap:Dot(right))<=12 then
            local future=flat(d.p+d.v*.9-s.p-velocity*.9).Magnitude
            if future<16 and future<nearest then prevent,nearest=d,future end
        end
    end
    return prevent
end
function controller.comeback.route(s,defenders,prevent)
    prevent=prevent or controller.comeback.prevent(s,defenders)
    if not prevent then return end
    local forward=lines.forward;local right=V(-forward.Z,0,forward.X);local speed=flat(s.v).Magnitude
    local function space(direction)
        local minimum,finish=math.huge,math.huge
        for i=1,3 do
            local time=i*.3;local point=s.p+direction*speed*time
            if not onField(point) or downfield(point)<0 then return end
            local clearance=math.huge
            for _,d in ipairs(defenders) do
                -- Extrapolate observed motion and reserve growing uncertainty
                -- for a defender changing direction. Advisory, never pass safety.
                local gap=flat(point-d.p-d.v*time).Magnitude-(3+time*3)
                clearance=math.min(clearance,gap)
            end
            minimum=math.min(minimum,clearance);finish=clearance
        end
        return {minimum=minimum,finish=finish}
    end
    local straight=space(flat(s.v)/speed)
    if not straight then return nil,prevent end
    local best
    for _,option in ipairs({{'slant right',(forward+right)/math.sqrt(2)}, {'slant left',(forward-right)/math.sqrt(2)}, {'cut back',-forward}}) do
        local room=space(option[2])
        if room and room.minimum>=2 and room.finish>=6 and room.finish>=straight.finish+4
            and room.minimum>=straight.minimum+1 then
            -- Retain useful downfield progress when a diagonal has room; come
            -- back only when neither slant qualifies. Opponents break side ties.
            if not best or option[1]~='cut back' and room.finish+room.minimum>best.score then
                best={text=option[1],score=room.finish+room.minimum}
            end
        end
    end
    return best and best.text or nil,prevent
end
function controller.comeback.valid(data,player,defender,instruction)
    if stopped or not controller.comeback.enabled or not auto or not throwing or pending or sequence
        or receiverMenu and receiverMenu.Visible or not choice or not choice.manualOnly then return false end
    if os.clock()-data.at>.3 or data.epoch~=possession.epoch or data.generation~=lines.generation
        or data.team~=me.Team or lines.status~='OBSERVED_LINES_STABLE' then return false end
    local ball=ready()
    if not ball or ball.nativeThrow or ball.tool~=data.tool or ball.model~=data.model or controller.field.QBPast(ball.root) then return false end
    local s=sample(player,os.clock())
    if not receiverReady(player,s,os.clock()) or s.model~=data.models[player] then return false end
    local db=Players:GetPlayerFromCharacter(defender)
    if not db or db.Neutral or not db.Team or db.Team==me.Team then return false end
    local model,root=body(db)
    if model~=defender or not vector(root.AssemblyLinearVelocity) or flat(root.AssemblyLinearVelocity).Magnitude>55 then return false end
    if instruction then
        if not controller.receiverFilter.friend(player) then return false end
        -- Re-read the complete bounded opponent roster before sending, including
        -- players who entered/respawned since the decision snapshot.
        local roster=Players:GetPlayers();if #roster>CFG.MaxRoster then return false end
        local defenders={}
        for _,p in ipairs(roster) do
            if p~=me and not p.Neutral and p.Team and p.Team~=me.Team then
                local m,r=body(p)
                if not m or not vector(r.AssemblyLinearVelocity) or flat(r.AssemblyLinearVelocity).Magnitude>55 then return false end
                defenders[#defenders+1]={model=m,p=r.Position,v=r.AssemblyLinearVelocity}
            end
        end
        local text,prevent=controller.comeback.route(s,defenders)
        return text==instruction and prevent and prevent.model==defender
    end
    return controller.comeback.near(s,{p=root.Position,v=root.AssemblyLinearVelocity})
end
function controller.comeback.channel()
    local service=game:GetService('TextChatService')
    if not service or service.CreateDefaultTextChannels~=true or not me.Team or me.Neutral then return end
    local color=me.Team.TeamColor
    if not color or not color.Name or me.TeamColor~=color then return end
    local folder=service:FindFirstChild('TextChannels')
    if not folder or not folder:IsA('Folder') then return end
    local channels=folder:GetChildren()
    if #channels>64 then return end
    local channel
    for _,o in ipairs(channels) do
        if o.Name=='RBXTeam'..color.Name then
            if channel or not o:IsA('TextChannel') then return end
            channel=o
        end
    end
    if not channel then return end
    local roster=Players:GetPlayers();if #roster>CFG.MaxRoster then return end
    local members={}
    for _,p in ipairs(roster) do
        -- Default team channels group by color; reject shared opponent colors.
        if not p.Neutral and p.Team and p.Team.TeamColor==color and p.Team~=me.Team then return end
        if not p.Neutral and p.Team==me.Team then members[p.UserId]=true end
    end
    local sources=channel:GetChildren();if #sources>CFG.MaxRoster then return end
    local own
    for _,o in ipairs(sources) do
        if not o:IsA('TextSource') or not members[o.UserId] then return end
        if o.UserId==me.UserId then if own then return end;own=o end
    end
    if own and own.CanSend==true then return channel end
end
function controller.comeback.update(now)
    local c=controller.comeback
    if c.worker then
        if now-c.worker.at>5 then
            if not c.cancel() then error('Comeback chat worker cleanup failed') end
            c.enabled=false;env.PELICAN_FF3_COMEBACK_CHAT=false
            c.status='SEND_TIMEOUT_DISABLED_NO_RETRY';if c.button then c.button.Text='CB OFF' end
        end
        return
    end
    local data=c.snapshot;c.snapshot=nil
    if data==nil then return end -- no decision tick on this physics frame
    if not data or not c.enabled or stopped or pending or sequence or not choice or not choice.manualOnly then
        c.observations={};return
    end
    local last=env.PELICAN_FF3_COMEBACK_LAST_ATTEMPT
    if c.calledEpoch==data.epoch or finite(last) and now>=last and now-last<30 then c.observations={};c.status='COOLDOWN';return end
    local seen={};local candidate;local routeBudget=2
    for _,r in ipairs(data.receivers) do
        local s=r.sample;local nearest,dist=nil,math.huge
        local instruction;local prevent=c.prevent(s,data.defenders)
        if prevent then
            -- Never turn an unknown/nonfriend streak into a generic call.
            -- ANY targeting remains ANY; only this advisory needs friendship.
            if controller.receiverFilter.friend(r.player) and routeBudget>0 then
                routeBudget=routeBudget-1;instruction=c.route(s,data.defenders,prevent)
                if instruction then nearest=prevent end
            end
        else
            for _,d in ipairs(data.defenders) do
                if c.near(s,d) then
                    local gap=flat(s.p-d.p).Magnitude
                    if gap<dist then nearest,dist=d,gap end
                end
            end
        end
        if nearest then
            seen[r.player]=true
            local old=c.observations[r.player]
            if not old or old.model~=s.model or old.defender~=nearest.model or old.epoch~=data.epoch
                or old.instruction~=instruction or old.team~=data.team or old.generation~=data.generation or now-old.at>.3 then
                old={model=s.model,defender=nearest.model,instruction=instruction,epoch=data.epoch,team=data.team,generation=data.generation,since=now}
                c.observations[r.player]=old
            end
            old.at=now
            if now-old.since>=(instruction and .65 or 2) and (not candidate or old.since<candidate.since) then candidate=old;candidate.player=r.player end
        end
    end
    for p in pairs(c.observations) do if not seen[p] then c.observations[p]=nil end end
    if not candidate then c.status='OBSERVING';return end
    if now<c.nextProbe then return end
    c.status='COVERAGE_PERSISTED'
    c.nextProbe=now+2
    if not task or type(task.defer)~='function' or type(task.cancel)~='function' then c.status='SCHEDULER_UNAVAILABLE';return end
    local channel=c.channel()
    if not channel then c.status='TEAM_CHANNEL_UNAVAILABLE';return end
    local work={active=true,at=now};c.worker=work;c.status='QUEUED'
    work.thread=task.defer(function()
        local ok,err=pcall(function()
            if not work.active or not c.valid(data,candidate.player,candidate.defender,candidate.instruction) or c.channel()~=channel then c.status='CANCELLED_BEFORE_SEND';return end
            c.calledEpoch=data.epoch;c.attempts=c.attempts+1;env.PELICAN_FF3_COMEBACK_LAST_ATTEMPT=os.clock()
            work.invoked=true;c.status='SENDING';c.outcome='AWAITING_RESULT'
            -- Exactly the requested text. No /team prefix, name, suffix or UI
            -- target switch. SendAsync may be denied by platform chat policy.
            c.instruction=candidate.instruction or 'cut back'
            local result=channel:SendAsync(c.instruction)
            if not work.active or stopped then return end
            c.outcome=result and tostring(result.Status) or 'NO_RESULT_DELIVERY_UNKNOWN'
            c.status='RESULT_RECORDED_NO_RETRY'
            if not result or result.Status~=Enum.TextChatMessageStatus.Success then
                c.enabled=false;env.PELICAN_FF3_COMEBACK_CHAT=false;c.status='SEND_NOT_SUCCESS_DISABLED_NO_RETRY'
                if c.button then c.button.Text='CB OFF' end
            end
            log('COMEBACK_CHAT',c.outcome)
        end)
        if c.worker==work then c.worker=nil end
        if not ok and not stopped then fatalError=clean(err);log('COMEBACK_ERROR',err);controller.Stop('COMEBACK_RUNTIME_ERROR_NO_RETRY') end
    end)
end
local function predict(s,t) return s.p+s.v*t end
-- Inherited vertical/horizontal reach estimates remain uncalibrated. Search
-- actual vertical flight intervals against a speed-bounded defender pursuit disk.
-- Instant direction changes favor the defender; this is not a catch guarantee.
local function linearMinimum(rx,rz,vx,vz,lo,hi,k)
    local vv=vx*vx+vz*vz; local at=hi
    if vv>k*k+1e-9 then
        local dot=rx*vx+rz*vz; local tc=-dot/vv
        local perp=math.max(0,rx*rx+rz*rz-dot*dot/vv)
        at=clamp(tc+k*math.sqrt(perp/(vv*(vv-k*k))),lo,hi)
    end
    local x,z=rx+vx*at,rz+vz*at
    return math.sqrt(x*x+z*z)-k*at
end
local function runSpeed(s)
    local speed=math.max(flat(s.v).Magnitude,s.observedSpeed or 0)
    if s.hum and finite(s.hum.WalkSpeed) then speed=math.max(speed,s.hum.WalkSpeed) end
    return speed
end
local function lane(shot,d,direct,both,earlyUntil)
    controller.coverageMath.verticalBands=controller.coverageMath.verticalBands+1
    local o,v,t=shot.origin,shot.velocity,shot.time
    local reach=12.2
    if d.hum and finite(d.hum.JumpPower) then reach=clamp(d.hum.JumpPower^2/(2*workspace.Gravity)+5,12.2,24) end
    local bottom,top=d.p.Y-2,d.p.Y+reach
    local disc=v.Y*v.Y-2*CFG.Gravity*(bottom-o.Y)
    if disc<0 then return 45,both and 45 or nil,earlyUntil and 45 or nil end
    local r=math.sqrt(disc); local lo,hi=math.max(0,(v.Y-r)/CFG.Gravity),math.min(t,(v.Y+r)/CFG.Gravity)
    if hi<lo then return 45,both and 45 or nil,earlyUntil and 45 or nil end
    local bodyRadius=4.5+d.turn*3
    local function interval(a,b)
        if b<a then return 45,both and 45 or nil,earlyUntil and 45 or nil end
        local vx,vz=v.X,v.Z
        if direct then vx,vz=vx-d.v.X,vz-d.v.Z end
        local first=linearMinimum(o.X-d.p.X,o.Z-d.p.Z,vx,vz,a,b,direct and 0 or runSpeed(d))-bodyRadius
        if both then
            local early=earlyUntil and (a<=earlyUntil and linearMinimum(o.X-d.p.X,o.Z-d.p.Z,v.X-d.v.X,v.Z-d.v.Z,a,math.min(b,earlyUntil),0)-bodyRadius or 45)
            return first,linearMinimum(o.X-d.p.X,o.Z-d.p.Z,v.X-d.v.X,v.Z-d.v.Z,a,b,0)-bodyRadius,early
        end
        return first
    end
    local high=v.Y*v.Y-2*CFG.Gravity*(top-o.Y)
    if high<=0 then return interval(lo,hi) end
    r=math.sqrt(high)
    local enter,leave=(v.Y-r)/CFG.Gravity,(v.Y+r)/CFG.Gravity
    local early,earlyDirect,earlyContest=interval(lo,math.min(hi,enter))
    local late,lateDirect,lateContest=interval(math.max(lo,leave),hi)
    return math.min(early,late),both and math.min(earlyDirect,lateDirect) or nil,
        earlyUntil and math.min(earlyContest,lateContest) or nil
end
function riskPolicy.BurnStart(shot,receiver)
    shot.trustBurn=nil
    if riskPolicy.mode~='TRUST' or (shot.mode~='Bullet' and shot.mode~='Dime')
        or shot.jumpBullet or shot.nativeCoverageJump or shot.magTrial or shot.screen then return end
    local motion=flat(receiver.v)
    if not lines.forward or motion.Magnitude<CFG.MinMoveSpeed or motion.Unit:Dot(lines.forward)<.5
        or flat(shot.arrival-receiver.p):Dot(motion)<=0 then return end
    shot.trustBurn={Allowed=false,Reason='NO_TRAILING_THREAT',Threats=0,Route=motion.Unit,
        Horizon=shot.time+math.max(0,shot.networkPing or 0),
        EarlyUntil=shot.time-math.min(shot.time*riskPolicy.burn.contestFraction,riskPolicy.burn.contestSeconds)}
end
function riskPolicy.BurnEarlyUntil(shot,receiver,d)
    local b=shot.trustBurn
    if not b then return end
    local gap=math.min(flat(receiver.p-d.p):Dot(b.Route),
        flat(predict(receiver,b.Horizon)-predict(d,b.Horizon)):Dot(b.Route))
    local closing=math.max(1,flat(shot.velocity-d.v):Dot(b.Route))
    -- More separation makes the ball pass the trailing corner earlier. Move
    -- the same contest boundary back so a bigger burn cannot grade worse.
    return math.max(0,b.EarlyUntil-math.max(0,gap-riskPolicy.burn.gap)/closing)
end
function riskPolicy.BurnGrade(shot,receiver,d,clearance,path,earlyDirect)
    local b=shot.trustBurn
    if not b or clearance>=CFG.ThrowMargin and path>=CFG.ThrowLane then return end
    b.Threats=b.Threats+1
    local relative=flat(receiver.p-d.p)
    local future=flat(predict(receiver,b.Horizon)-predict(d,b.Horizon))
    local gap,futureGap=relative:Dot(b.Route),future:Dot(b.Route)
    local side=(relative-b.Route*gap).Magnitude
    b.Gap=math.min(b.Gap or math.huge,gap)
    b.ProjectedGap=math.min(b.ProjectedGap or math.huge,futureGap)
    b.EarlyLane=math.min(b.EarlyLane or math.huge,earlyDirect or -math.huge)
    -- Only trailing corners get the contest allowance. Other lane/endpoint
    -- threats still veto it. Permit the final catch contest, not an earlier
    -- direct interception. Reuse lane()'s actual reachable-height intervals.
    if gap<riskPolicy.burn.gap-1e-6 or relative:Dot(lines.forward)<=0
        or side>riskPolicy.profiles.TRUST.lateral then b.Blocked='DEFENDER_NOT_TRAILING'
    elseif futureGap<riskPolicy.burn.gap-1e-6 then b.Blocked='BURN_CLOSING'
    elseif not earlyDirect or earlyDirect<=0 then b.Blocked='EARLY_INTERCEPTION_PATH' end
end
function riskPolicy.BurnFinish(shot)
    local b=shot.trustBurn
    if not b then return end
    local p=riskPolicy.profiles.TRUST
    b.Reason=b.Blocked or (shot.safetyOverTop or shot.safetyRead and shot.safetyRead.High) and 'SAFETY_OVER_TOP'
        or (shot.routeLateral or math.huge)>p.lateral and 'ROUTE_CORRECTION'
        or (shot.receiverTurn or 1)>p.turn and 'ROUTE_UNSTABLE'
        or (shot.receiverETA or math.huge)>shot.time+p.arrivalSlack and 'RECEIVER_LATE'
        or b.Threats==0 and 'NO_TRAILING_THREAT' or 'TRAILING_CORNER_ADVANTAGE'
    b.Allowed=b.Reason=='TRAILING_CORNER_ADVANTAGE'
    b.Route=nil -- retain scalar diagnostics only
end
local function risk(shot,receiver,defenders)
    local gradeStarted=os.clock();shot.maxThreatSpeed=0
    shot.guardInputs={Clock=gradeStarted,Drops={}}
    local ref=receiver.chestReference;if ref then shot.guardInputs.ChestReference={time=ref.time,at=ref.at}end
    controller.coverageMath.grades=controller.coverageMath.grades+1
    local margin,laneMargin,wideMargin,wideLane=45,45,45,45; local t=shot.time
    local pingBudget=finite(shot.networkPing) and math.max(0,shot.networkPing) or 0
    local firstDB,directLane=math.huge,45
    local enhanced=controller.coverageWindows.enabled or controller.league.mode=='LEAGUE'
    local layers=enhanced and {Underneath=0,Deeper=0,LaneThreats=0,CatchThreats=0} or nil
    local flight=flat(shot.arrival-shot.origin)
    -- The scene read uses a common ordinary-Bullet horizon, not the elevated
    -- candidate's different lead point. It is policy geometry, not role proof
    -- or a calibrated percentage of the game's catch hitbox.
    local read
    if controller.safety.enabled and lines.forward then
        local reference=shot.variant=='Bullet' and shot or receiver.chestReference
        if reference and reference.at and os.clock()-reference.at>CFG.CacheAge then reference=nil end
        local horizon=reference and reference.time or math.max(.05,flat(receiver.p-shot.origin).Magnitude/95)
        local motion=flat(receiver.v);local along=motion:Dot(lines.forward)
        read={State='NO_HIGH_SAFETY',High=false,Dropping=false,Contested=false,
            Slant=along>=CFG.MinMoveSpeed and (motion-lines.forward*along).Magnitude>=CFG.MinMoveSpeed,Horizon=horizon}
        receiver.dropHistory=receiver.dropHistory or setmetatable({}, {__mode='k'})
    end
    shot.safetyRead=read;shot.contestedChestThreat=false
    local route=flat(receiver.v)
    route=route.Magnitude>0 and lines.forward and route:Dot(lines.forward)>0 and route.Unit or nil
    shot.safetyOverTop,shot.safetyName=false,nil
    shot.marginDB,shot.laneDB,shot.marginActor,shot.laneActor=nil,nil,nil,nil
    riskPolicy.BurnStart(shot,receiver)
    for _,d in ipairs(defenders) do
        -- Instant turning at observed/normal run speed is optimistic for the DB.
        -- A trailing defender must cover the actual distance before arrival;
        -- a stationary prevent defender can move instead of staying frozen.
        local distance=flat(shot.arrival-d.p).Magnitude
        local speed=runSpeed(d);shot.maxThreatSpeed=math.max(shot.maxThreatSpeed,speed)
        local baseClearance=distance-speed*t-(4.5+d.turn*3)
        local clearance=baseClearance-(enhanced and speed*pingBudget or 0)
        local eta=speed>0 and math.max(0,distance-(4.5+d.turn*3))/speed or (distance<=4.5+d.turn*3 and 0 or math.huge)
        firstDB=math.min(firstDB,eta)
        local basePath,directPath,earlyDirect=lane(shot,d,false,riskPolicy.mode~='SAFE',riskPolicy.BurnEarlyUntil(shot,receiver,d))
        if directPath then directLane=math.min(directLane,directPath-(enhanced and speed*pingBudget or 0)) end
        if clearance<margin then margin=clearance;shot.marginDB=d.name;shot.marginActor=d end
        local pathClearance=basePath-(enhanced and speed*pingBudget or 0)
        riskPolicy.BurnGrade(shot,receiver,d,clearance,pathClearance,earlyDirect)
        if read then
            local relative=flat(d.p-receiver.p);local depth=relative:Dot(lines.forward)
            local later=relative+flat(d.v-receiver.v)*(read.Horizon+pingBudget)
            local laterDepth=later:Dot(lines.forward)
            local radius=4.5+d.turn*3 -- inherited model envelope; not a verified catch radius
            local side=(relative-lines.forward*depth).Magnitude
            local laterSide=(later-lines.forward*laterDepth).Magnitude
            local relevant=side<=speed*(read.Horizon+pingBudget)+radius or laterSide<=radius
            local key=d.model or d
            if receiver.dropHistory[key]then shot.guardInputs.Drops[d.name]=receiver.dropHistory[key]end
            local dropping=relevant and depth>0 and flat(d.v):Dot(lines.forward)<=-CFG.MinMoveSpeed
                and flat(d.v):Dot(-relative)>0
            if dropping then receiver.dropHistory[key]=os.clock();read.Dropping=true end
            local recent=receiver.dropHistory[key] and os.clock()-receiver.dropHistory[key]<=CFG.MotionWindow
            local catchClearance=flat(receiver.p+flat(receiver.v)*(read.Horizon+pingBudget)-d.p).Magnitude
                -speed*(read.Horizon+pingBudget)-radius
            if recent and relevant and catchClearance<CFG.ThrowMargin then receiver.dropHistory[key]=os.clock() end
            if relevant and depth>radius and laterDepth>radius and not dropping and not (recent and catchClearance<CFG.ThrowMargin) then read.High=true end
            if relevant and read.Slant and (dropping or recent) and catchClearance<CFG.ThrowMargin then
                read.Contested=true
                if shot.variant=='Bullet' and clearance<CFG.ThrowMargin then shot.contestedChestThreat=true end
            end
        end
        -- Reuse this exact grade for the over-top check instead of rebuilding
        -- the same defender vertical intervals in coverage().
        if route and not shot.safetyOverTop then
            local relative=flat(d.p-receiver.p);local along=relative:Dot(route)
            if along>=0 and relative:Dot(lines.forward)>0 and (relative-route*along).Magnitude<=speed*t+(4.5+d.turn*3)
                and (baseClearance<CFG.ThrowMargin or basePath<CFG.ThrowLane) then shot.safetyOverTop=true;shot.safetyName=d.name end
        end
        if layers then
            local fraction=flight.Magnitude>0 and flat(d.p-shot.origin):Dot(flight)/(flight.Magnitude*flight.Magnitude) or 0
            if lines.forward and flat(d.p-receiver.p):Dot(lines.forward)>0 then layers.Deeper=layers.Deeper+1
            elseif fraction>0 and fraction<1 and (pathClearance<CFG.ThrowLane or clearance<CFG.ThrowMargin) then
                layers.Underneath=layers.Underneath+1
            end
            if pathClearance<CFG.ThrowLane then layers.LaneThreats=layers.LaneThreats+1 end
            if clearance<CFG.ThrowMargin then layers.CatchThreats=layers.CatchThreats+1 end
        end
        wideMargin=math.min(wideMargin,clearance-(enhanced and 0 or speed*pingBudget))
        wideLane=math.min(wideLane,pathClearance-(enhanced and 0 or speed*pingBudget))
        if pathClearance<laneMargin then laneMargin=pathClearance;shot.laneDB=d.name;shot.laneActor=d end
    end
    if read then
        read.State=read.High and 'SAFETY_HIGH_BULLET_ONLY' or read.Contested and 'DROPPING_SLANT_CONTEST'
            or read.Dropping and 'SAFETY_FLOATING_AUTO_ARC' or 'NO_HIGH_SAFETY'
    end
    shot.coverageLayers=layers
    shot.margin,shot.lane,shot.defenderETA=margin,laneMargin,firstDB
    shot.wideMargin,shot.wideLane=wideMargin,wideLane
    shot.powerAllowed=touch.fullAllowed(shot)
    if shot.mode=='Fit' then shot.fitAllowed=false end
    if riskPolicy.mode~='SAFE' then
        local speed=runSpeed(receiver)
        shot.receiverETA=speed>0 and math.max(0,flat(shot.arrival-receiver.p).Magnitude-4.5)/speed or math.huge
        shot.raceAdvantage=firstDB-shot.receiverETA;shot.directLane=directLane
        local movement=flat(receiver.v)
        local residual=flat(shot.arrival-predict(receiver,t))
        shot.routeLateral=movement.Magnitude>0 and (residual-movement.Unit*residual:Dot(movement.Unit)).Magnitude or math.huge
        shot.receiverTurn=receiver.routeTurn or receiver.turn
    end
    riskPolicy.BurnFinish(shot)
    -- Once both clearances have a useful safety surplus, extra empty space
    -- must not make a slow floating arc beat an already-safe direct throw.
    shot.score=math.min(margin,CFG.ThrowMargin*2)*1.8+math.min(laneMargin,CFG.ThrowLane*2)*1.5-t*3-receiver.turn*12-(shot.receiverResidual or 0)*.25
    shot.guardInputs.ClockEnd=os.clock();shot.guardSeconds=os.clock()-gradeStarted
    return shot
end
local lastNativeInputs
local function refreshNativeInputs()
    local q=profile.q
    local data={q.Angle,q.Power,q.ManualType,tostring(q.PreferHighArc),tostring(q.AutoCorrect)}
    for _,mode in ipairs({'Bullet','Fit','Dime','Jump'}) do
        local lead=profile.leads[mode]
        if typeof(lead)~='Vector2' then return false end
        data[#data+1]=lead.X; data[#data+1]=lead.Y
    end
    local smart=q.SmartPass
    data[#data+1]='smart:'..type(smart)..':'..tostring(smart)
    if type(smart)=='table' then
        data[#data+1]=tostring(smart.Enabled); data[#data+1]=tostring(smart.FitOnly); data[#data+1]=tostring(smart.MaxRange)
    end
    local oob=q.AntiOOB
    data[#data+1]='oob:'..type(oob)..':'..tostring(oob)
    if type(oob)=='table' then
        data[#data+1]=tostring(oob.Enabled); data[#data+1]=tostring(oob.XTolerance); data[#data+1]=tostring(oob.ZTolerance)
    end
    local signature=table.concat(data,':')
    if lastNativeInputs and lastNativeInputs~=signature then clearWindows(); if choice then choice.openSince=nil end end
    lastNativeInputs=signature
    return true
end
local function receivePossible(shot,s)
    local lead=profile.leads[shot.mode]
    if typeof(lead)~='Vector2' or not finite(lead.X) or not finite(lead.Y) then return false,'NATIVE_LEAD_CHANGED' end
    local ping=me:GetNetworkPing()
    if not finite(ping) or ping<0 then return false,'NETWORK_PREDICTION_UNVERIFIED' end
    local speed=math.max(flat(s.v).Magnitude,s.observedSpeed or 0)
    if s.hum and finite(s.hum.WalkSpeed) then speed=math.max(speed,s.hum.WalkSpeed) end
    local distance=flat(shot.arrival-s.p).Magnitude
    -- Necessary optimistic travel bound only. Native source uses time+ping and
    -- its configurable horizontal lead. No invented catch radius or jump zone.
    local budget=speed*(shot.time+ping)+math.abs(lead.X)
    shot.networkPing=ping
    shot.receiverResidual=flat(shot.arrival-predict(s,shot.time+ping)).Magnitude
    if distance>budget+math.max(.01,budget*.0001) then return false,'RECEIVER_CANNOT_REACH_NATIVE_ARRIVAL' end
    return true
end
local function safetyAhead(s,defenders,time,shot)
    local v=flat(s.v)
    if v.Magnitude<=0 or not lines.forward or v:Dot(lines.forward)<=0 then return false end
    local route=v.Unit
    for _,d in ipairs(defenders) do
        local relative=flat(d.p-s.p)
        local along=relative:Dot(route)
        if along>=0 and relative:Dot(lines.forward)>0 then
            local lateral=(relative-route*along).Magnitude
            if lateral<=runSpeed(d)*time+(4.5+d.turn*3) then
                local arrival=shot and shot.arrival or predict(s,time)
                local clearance=flat(arrival-d.p).Magnitude-runSpeed(d)*time-(4.5+d.turn*3)
                if clearance<CFG.ThrowMargin or shot and lane(shot,d)<CFG.ThrowLane then return true,d.name end
            end
        end
    end
    return false
end
function controller.unified.BaselineCoverage(shot,s,defenders)
    local forward=lines.forward and flat(s.v):Dot(lines.forward)>0
    local ahead=flat(shot.arrival-s.p):Dot(flat(s.v))>0
    shot.burnCandidate=forward and ahead and not shot.safetyOverTop or false
    shot.clearBurn=forward and ahead and not shot.safetyOverTop
        and shot.margin>=CFG.ThrowMargin and shot.lane>=CFG.ThrowLane or false
    controller.passPlan.assess(shot,s)
end
function controller.unified.BaselineThrowable(shot)
    if shot.planAllowed==false then return false end
    if shot.releaseBlocked then return false end
    if shot.powerAllowed==false then return false end
    if shot.safetyRead and shot.safetyRead.High and (shot.mode~='Bullet' or shot.jumpBullet or shot.nativeCoverageJump) then return false end
    if controller.safety.enabled and shot.mode=='Jump' and not shot.nativeCoverageJump then return false end
    if controller.safety.enabled and (shot.jumpBullet or shot.nativeCoverageJump) and (not shot.safetyRead or shot.safetyRead.State~='DROPPING_SLANT_CONTEST') then return false end
    if shot.mode=='Fit' and not shot.fitAllowed then return false end
    if (shot.jumpBullet or shot.nativeCoverageJump) and not shot.jumpBulletAllowed then return false end
    local strict=shot.margin>=CFG.ThrowMargin and shot.lane>=CFG.ThrowLane
        and (not shot.safetyOverTop or shot.mode=='Bullet')
    if shot.nativeCoverageJump then return strict end
    if shot.magTrial then return strict and controller.mag.Allowed(shot.magPlayer) end
    if strict then return true end
    if riskPolicy.mode=='TRUST' and shot.trustBurn and shot.trustBurn.Allowed then return true end
    local p=riskPolicy.profiles[riskPolicy.mode]
    -- Risk modes govern a qualified catch window, including a crosser or a
    -- comeback. Forward-route classification must not veto an otherwise valid
    -- window. Bullet/covered Jump/Mag retain the strict branches above.
    return riskPolicy.mode~='SAFE' and shot.mode~='Bullet' and not shot.softBullet and not shot.safetyOverTop
        and shot.margin>=p.margin and shot.lane>=p.lane and (shot.directLane or -math.huge)>0
        and (shot.raceAdvantage or -math.huge)>=p.race and (shot.receiverETA or math.huge)<=shot.time+p.arrivalSlack
        and (shot.routeLateral or math.huge)<=p.lateral and (shot.receiverTurn or 1)<=p.turn
end

function controller.unified.Guard(shot)
    local allowed=controller.unified.BaselineThrowable(shot)
    if shot.oscillationBullet and not (shot.wideOpen and shot.margin>=CFG.ThrowMargin and shot.lane>=CFG.ThrowLane) then allowed=false end
    local reason=shot.planAllowed==false and shot.planReason or shot.releaseBlocked and 'RELEASE_BLOCKED'
        or shot.powerAllowed==false and shot.powerReason
        or shot.safetyRead and shot.safetyRead.High and shot.mode~='Bullet' and 'SAFETY_HIGH_BULLET_ONLY'
        or shot.mode=='Fit' and not shot.fitAllowed and (shot.fitReason or 'FIT_COMPARISON_REQUIRED')
        or (shot.nativeCoverageJump or shot.jumpBullet) and not shot.jumpBulletAllowed and (shot.jumpBulletReason or 'JUMP_COMPARISON_REQUIRED')
        or not allowed and (shot.trustBurn and shot.trustBurn.Reason or 'COVERAGE_REJECTED')
        or shot.trustBurn and shot.trustBurn.Allowed and 'TRAILING_CORNER_ADVANTAGE' or 'CLEAR_NATIVE_WINDOW'
    return {Allowed=allowed,Reason=reason,Margin=shot.margin,Lane=shot.lane,DirectLane=shot.directLane,
        Strict=shot.margin>=CFG.ThrowMargin and shot.lane>=CFG.ThrowLane,ThreatSpeed=shot.maxThreatSpeed or 0,RequiredMargin=CFG.ThrowMargin,RequiredLane=CFG.ThrowLane,
        TrustBurn=shot.trustBurn,DefenderETA=finite(shot.defenderETA) and shot.defenderETA or nil,NoReachableDefender=shot.defenderETA==math.huge,RaceAdvantage=shot.raceAdvantage,
        ReceiverETA=shot.receiverETA,PowerAllowed=shot.powerAllowed,MinimumFlight=shot.minimumFlight,
        WideOpen=shot.wideOpen,MarginDefender=shot.marginDB,LaneDefender=shot.laneDB,
        SafetyRead=shot.safetyRead,FitReason=shot.fitReason,JumpReason=shot.jumpBulletReason}
end
local function coverage(shot,s,defenders)
    controller.unified.BaselineCoverage(shot,s,defenders)
    if shot.oscillationBullet and not s.oscillation then shot.releaseBlocked=true end
    local inputs={gravity=CFG.Gravity,mode=riskPolicy.mode,gain=math.max(0,downfield(shot.arrival)/3),
        endzone=shot.endzoneTarget,CurrentDepthYards=downfield(s.p)/3,MinDepthYards=CFG.MinDownfieldYards,
        ReceiverGrounded=s.hum and s.hum.FloorMaterial~=nil and s.hum.FloorMaterial~=Enum.Material.Air,
        NativeBoundary=profile and type(profile.q.AntiOOB)=='table' and {Enabled=profile.q.AntiOOB.Enabled,XTolerance=profile.q.AntiOOB.XTolerance,ZTolerance=profile.q.AntiOOB.ZTolerance} or nil,
        GoalOrScreen=lines.goalToGo or shot.screen or shot.endzoneTarget,ForwardX=lines.forward and lines.forward.X,
        ForwardZ=lines.forward and lines.forward.Z,OpenComfort=controller.passPlan.openComfort,
        ComfortSeconds=touch.enabled and touch.comfort or 0,WorldGravity=workspace.Gravity,CoverageWindows=controller.coverageWindows.enabled,Profile=controller.league.mode,SafetyReads=controller.safety.enabled,CloseBullet={Enabled=touch.enabled,Comfort=touch.comfort,Quick=touch.quick,FullPowerYards=touch.full},GuardInputs=shot.guardInputs,Guard=controller.unified.Guard(shot)}
    shot.evidenceReceiver=s.name
    local begun=os.clock();controller.unified:evaluate(shot,s,defenders,inputs)
    controller.bad:grade(shot,s,defenders,inputs,controller.unified.config,(shot.guardSeconds or 0)+os.clock()-begun)
end
local function throwable(shot)
    local g=controller.unified.Guard(shot)
    local allowed=Unified.admit(shot,g)
    if shot.unified then controller.bad:admit(shot,g) end
    return allowed
end
controller.fit={}
function controller.jumpBullet.assess(shot,alternatives)
    shot.jumpBulletAllowed=true;shot.jumpBulletReason=nil;shot.jumpBulletChest=nil

    if controller.safety.enabled and (not shot.safetyRead or shot.safetyRead.State~='DROPPING_SLANT_CONTEST') then
        shot.jumpBulletAllowed=false;shot.jumpBulletReason=shot.safetyRead and shot.safetyRead.State or 'SAFETY_READ_UNVERIFIED';return false
    end
    for _,other in ipairs(alternatives) do
        if other~=shot and not other.jumpBullet and not other.nativeCoverageJump and not other.magTrial and throwable(other)
            and (not controller.safety.enabled or other.mode=='Bullet') then
            shot.jumpBulletAllowed=false;shot.jumpBulletReason=other.mode=='Bullet' and 'ORDINARY_SAFE_BULLET_AVAILABLE' or 'ORDINARY_SAFE_PASS_AVAILABLE';return false
        end
    end
    for _,other in ipairs(alternatives) do
        if other.variant=='Bullet' and (other.margin<CFG.ThrowMargin or other.lane<CFG.ThrowLane)
            and (not controller.safety.enabled or other.contestedChestThreat==true) then
            if throwable(shot) then
                shot.jumpBulletReason='FRESH_CHEST_PATH_THREAT'
                shot.jumpBulletChest={Time=other.time,Margin=other.margin,Lane=other.lane,Variant=other.variant}
                return true
            end
        end
    end
    shot.jumpBulletAllowed=false;shot.jumpBulletReason='NO_SAFE_JUMP_OR_FRESH_CHEST_PATH_THREAT';return false
end
function controller.fit.assess(shot,alternatives,requiredVariant)
    shot.fitAllowed=true;shot.fitAlternativeVariant=nil;shot.fitSecondVariant=nil
    if not throwable(shot) or not (shot.defenderETA>shot.time) then
        shot.fitAllowed=false;shot.fitReason='FIT_NOT_SAFE_BEFORE_DB';return false
    end
    local late
    for _,other in ipairs(alternatives) do
        if other.mode~='Fit' and not other.jumpBullet and not other.nativeCoverageJump and not other.magTrial then
            if throwable(other) then shot.fitAllowed=false;shot.fitReason='SAFE_NON_FIT_AVAILABLE';return false end
            if (not requiredVariant or other.variant==requiredVariant) and other.defenderETA<=other.time
                and shot.time<other.time and (not late or other.time<late.time) then late=other end
        end
    end
    if not late and (controller.coverageWindows.enabled or controller.league.mode=='LEAGUE') and not shot.safetyOverTop then
        local chest,loft
        for _,other in ipairs(alternatives) do
            if other.margin<CFG.ThrowMargin or other.lane<CFG.ThrowLane or other.safetyOverTop then
                if other.variant=='Bullet' then chest=other elseif other.variant=='Dime' then loft=other end
            end
        end
        if chest and loft and (not requiredVariant or requiredVariant=='Bullet') then
            shot.fitAlternativeVariant='Bullet';shot.fitSecondVariant='Dime';shot.fitReason='COVERAGE_WINDOW_BETWEEN_LAYERS'
            shot.fitAlternativeTime=chest.time;shot.fitAlternativeDB=chest.defenderETA;return true
        end
    end
    if not late then shot.fitAllowed=false;shot.fitReason='NO_LATE_ALTERNATIVE_PROVEN';return false end
    shot.fitAlternativeVariant=late.variant or late.mode;shot.fitAlternativeTime=late.time
    shot.fitAlternativeDB=late.defenderETA;shot.fitReason='TIMING_RESCUE'
    return true
end
local function better(a,b)
    throwable(a);if b then throwable(b) end
    return Unified.better(a,b)
end
local function receiverBetter(a,b) return not b or better(a.shot,b.shot) end
local function classify(shot,s,defenders)
    local speed=flat(s.v).Magnitude
    if speed<=0 then shot.window='OPEN'; return end
    local route=flat(s.v).Unit
    local nearest,nearDist
    for _,d in ipairs(defenders) do
        local db=predict(d,shot.time)
        local dist=flat(db-shot.arrival).Magnitude
        if not nearDist or dist<nearDist then nearest,nearDist=db,dist end
    end
    if not nearest then shot.window='OPEN'
    elseif not lines.forward then shot.window='COVERAGE_WINDOW'
    elseif flat(shot.arrival-nearest):Dot(route)>0 and route:Dot(lines.forward)>0 then shot.window='BURN_WINDOW'
    elseif flat(nearest-shot.arrival):Dot(lines.forward)>0 then shot.window='UNDERNEATH_WINDOW'
    else shot.window='LATERAL_WINDOW' end
end
function controller.angle.Request(player,mode,lead)
    local a=controller.angle;local scene=a.scene
    if stopped then return nil,'STOPPED' end
    if not a.enabled then return nil,'OFF' end
    if not scene or os.clock()-scene.at>.3 or scene.epoch~=possession.epoch or scene.generation~=lines.generation or scene.team~=me.Team then return nil,'ANGLE_SCENE_UNVERIFIED' end
    local _,_,head=body(me);local _,root,targetHead=body(player)
    if not head or not root or not targetHead or not vector(root.AssemblyLinearVelocity) then return nil,'ANGLE_POSE_UNVERIFIED' end
    local speed=profile and profile.q.Power;local ping=me:GetNetworkPing()
    if not finite(speed) or speed<=0 or speed>95 or not finite(ping) or ping<0 then return nil,'ANGLE_POWER_OR_PING_UNVERIFIED' end
    local cache=a.cache[player];local saved=cache and cache[mode]
    if saved and saved.frame==motionFrame and saved.epoch==scene.epoch and saved.generation==scene.generation
        and saved.x==lead.X and saved.y==lead.Y and saved.speed==speed and saved.ping==ping
        and saved.head==head.Position and saved.target==root.Position and saved.velocity==root.AssemblyLinearVelocity then return saved.control end
    local origin=head.Position;local known=a.origins[player]
    if known and known.epoch==scene.epoch and known.profile==profile and os.clock()-known.at<=CFG.CacheAge then origin=known.origin+(head.Position-known.head) end
    local velocity=flat(root.AssemblyLinearVelocity);local direction=velocity.Magnitude>0 and velocity.Unit or V()
    local time=math.max(.05,flat(targetHead.Position-origin).Magnitude/speed);local angle,blockers,needed=0,0,0
    -- Four bounded fixed-point estimates, never extra native solves. The native
    -- result and full pursuit/lane check remain the only release trajectory.
    for _=1,4 do
        local target=targetHead.Position+velocity*(time+ping)+direction*lead.X+V(0,lead.Y,0)
        local oob=profile.q.AntiOOB
        if type(oob)=='table' and oob.Enabled and finite(oob.XTolerance) and finite(oob.ZTolerance) then
            target=V(clamp(target.X,-75+oob.XTolerance,75+oob.XTolerance),target.Y,clamp(target.Z,-175+oob.ZTolerance,175+oob.ZTolerance))
        end
        local delta=flat(target-origin);local range=delta.Magnitude;local height=target.Y-origin.Y
        if range<.01 then return nil,'ANGLE_RANGE_UNVERIFIED' end
        local disc=speed^4-CFG.Gravity*(CFG.Gravity*range*range+2*height*speed*speed)
        if disc<0 then return nil,'ANGLE_ESTIMATE_UNREACHABLE' end
        local low=math.atan((speed*speed-math.sqrt(disc))/(CFG.Gravity*range))
        local flight=math.max(range/(speed*math.cos(low)),touch.enabled and touch.comfort or .05)
        local route=delta/range;local probeFlight=flight;blockers=0
        for _,d in ipairs(scene.defenders) do
            local p,v=d.p,d.v
            if d.root and d.root.Parent and vector(d.root.Position) and vector(d.root.AssemblyLinearVelocity) then p,v=d.root.Position,d.root.AssemblyLinearVelocity end
            local f=flat(p-origin):Dot(route)/range
            if f>0 and f<1 then
                local predicted=p+flat(v)*(probeFlight*f)
                f=flat(predicted-origin):Dot(route)/range
                if f>0 and f<1 and flat(predicted-origin-delta*f).Magnitude<=4.5+(d.turn or 0)*3 then
                    -- Same inherited, uncalibrated jump reach as the defender
                    -- lane model. Added clearance is an application risk policy.
                    local reach=12.2
                    if d.hum and finite(d.hum.JumpPower) then reach=clamp(d.hum.JumpPower^2/(2*workspace.Gravity)+5,12.2,24) end
                    local base=origin.Y+height*f
                    local clearance=p.Y+reach+CFG.ThrowLane-base
                    if clearance>0 then
                        flight=math.max(flight,math.sqrt(2*clearance/(CFG.Gravity*f*(1-f))))
                        blockers=blockers+1
                    end
                end
            end
        end
        time=flight;needed=math.sqrt((range/time)^2+(height/time+CFG.Gravity*time/2)^2)
        angle=math.deg(math.atan((height+CFG.Gravity*time*time/2)/range))
        if not finite(angle) or angle<=0 or angle>=89 or needed>speed+1 then return nil,'ANGLE_ESTIMATE_UNREACHABLE' end
    end
    local control={requested=angle,flight=time,powerCap=speed,blockers=blockers,reason=blockers>0 and 'LOFT_OVER_PROJECTED_LANE_BLOCKER' or 'LOW_CLEAR_LANE'}
    a.requests=a.requests+1;a.status=control.reason
    cache=cache or {};a.cache[player]=cache
    cache[mode]={frame=motionFrame,epoch=scene.epoch,generation=scene.generation,x=lead.X,y=lead.Y,speed=speed,ping=ping,
        head=head.Position,target=root.Position,velocity=root.AssemblyLinearVelocity,control=control}
    return control
end
local function solve(player,mode)
    if mode=='Jump' and (controller.passPlan.openComfort or controller.safety.enabled) then return nil,'NATIVE_JUMP_DISABLED_FOR_OPEN_COMFORT' end
    local nativeJump=mode=='CoverageJump'
    local fastJump=nativeJump and controller.safety.enabled
    if nativeJump and not controller.nativeJump.enabled then return nil,'NATIVE_JUMP_OFF' end
    local screen=controller.league.ScreenEligible and controller.league.ScreenEligible(player,samples[player],os.clock()) or false
    if screen and mode~='SoftBullet' and mode~='QuickBullet' and mode~='Bullet' then return nil,'SCREEN_BULLET_ONLY' end
    -- BEGIN OBSERVED OSCILLATION ADAPTER
    local zig=mode=='ZigzagBullet'
    if zig and (not samples[player] or not samples[player].oscillation) then return nil,'NO_OBSERVED_ZIGZAG' end
    -- END OBSERVED OSCILLATION ADAPTER
    local soft=mode=='SoftBullet' or mode=='QuickBullet' or zig
    local jump=mode=='JumpBullet'
    local mag=mode=='MagDime'
    if mag and not controller.mag.Allowed(player) then return controller.mag.Reject('MAG_TRUST_OR_TRIAL_UNAVAILABLE') end
    if jump and not controller.jumpBullet.enabled then return nil,'JUMP_BULLET_OFF' end
    if soft and touch.profile~=profile then touch.profile=profile;touch.method='POWER';touch.methodReason='NOT_PROBED';touch.methodReceipt=nil end
    local requestedPower=soft and closePower(player,mode=='QuickBullet') or nil
    if fastJump then requestedPower=profile and profile.q.Power end
    if soft and not requestedPower then return nil,'CLOSE_BULLET_NOT_NEEDED' end
    local appliedLead
    -- BEGIN OBSERVED OSCILLATION ADAPTER
    if zig then
        local s=samples[player];local _,_,head=body(me);local ping=me:GetNetworkPing()
        if not head or not finite(ping) or ping<0 then return nil,'ZIGZAG_POSE_UNVERIFIED' end
        requestedPower=controller.unified.oscillation.power(s,head.Position,touch.comfort,CFG.Gravity,touch.min,profile.leads.Bullet)
        if not requestedPower then return nil,'ZIGZAG_COMFORT_POINT_OUT_OF_RANGE' end
        local x,why=controller.unified.oscillation.control(s,head.Position,requestedPower,CFG.Gravity,ping,profile.leads.Bullet)
        if not x then return nil,why end
        appliedLead=Vector2.new(x,profile.leads.Bullet.Y)
    end
    -- END OBSERVED OSCILLATION ADAPTER
    if jump then
        if not profile or not leadTable(profile.leads) or profile.leads.Fit.Y<=0 then return nil,'JUMP_BULLET_FIT_HEIGHT_UNAVAILABLE' end
        appliedLead=Vector2.new(profile.leads.Bullet.X,profile.leads.Fit.Y);requestedPower=95
    end
    if mag then
        if not profile or not leadTable(profile.leads) then return controller.mag.Reject('MAG_LEAD_UNAVAILABLE') end
        appliedLead=Vector2.new(profile.leads.Dime.X,profile.leads.Dime.Y+controller.mag.extraY)
    end
    local nativeMode=(jump or nativeJump) and 'Jump' or (soft or mag) and 'Dime' or mode
    -- The source's selected manual value is power in Power mode and degrees
    -- in Angle mode. Do not keep passing the old Angle after selecting Power.
    local nativeInput=(soft or jump or fastJump) and requestedPower or profile and (profile.q.ManualType=='Power' and profile.q.Power or profile.q.Angle)
    local angleControl
    if controller.angle.enabled and not soft and not jump and not fastJump and (nativeMode=='Dime' or nativeMode=='Jump') then
        local reason;angleControl,reason=controller.angle.Request(player,mode,appliedLead or profile.leads[nativeMode])
        if not angleControl then controller.angle.status=reason;return nil,reason end
        nativeInput=angleControl.requested
    end
    if soft and touch.method=='ANGLE' then
        nativeInput=touch.angle(player,requestedPower)
        if not nativeInput then touch.record(player,mode,requestedPower,nil,'ANGLE_ESTIMATE_UNREACHABLE');return nil,'CLOSE_BULLET_ANGLE_ESTIMATE_UNREACHABLE' end
    end
    if frameCalls>=8 then return nil,'NATIVE_FRAME_BUDGET' end
    if not lock(player) then return nil,'NATIVE_LOCK_BUSY' end
    if not teammate(player) or profile.selector()~=player.Character then return nil,'NATIVE_TARGET_MISMATCH' end
    local q=profile.q
    local qbModel,_,qbHead=body(me)
    local _,targetRoot=body(player)
    if not qbHead or not targetRoot then return nil,'POSE_UNAVAILABLE' end
    local launchHead,targetPosition,targetVelocity=qbHead.Position,targetRoot.Position,targetRoot.AssemblyLinearVelocity
    -- fn37's tuple is not the displayed HUD angle. In particular tuple #8 is an
    -- initial angle; #6 is the final velocity after native lead/solver iterations.
    local inputs=lastNativeInputs
    if getmetatable(q.AutoThrowType)~=nil or modeTransaction or q.AutoThrowType.Enabled~=true then return nil,'NATIVE_MODE_SCOPE_BUSY' end
    -- fn34 independently reads SelectedType when automatic mode is disabled.
    -- Never leave Auto Throw Type OFF between solves or during pregame/setup.
    modeTransaction={q=q,auto=q.AutoThrowType,enabled=rawget(q.AutoThrowType,'Enabled'),
        selected=rawget(q,'SelectedType'),mode=nativeMode,fields={}}
    if fastJump then
        for _,field in ipairs({{q,'ManualType','Power'},{q,'Power',requestedPower},{q,'PreferHighArc',false}}) do
            modeTransaction.fields[#modeTransaction.fields+1]={object=field[1],key=field[2],before=rawget(field[1],field[2]),written=field[3]}
            rawset(field[1],field[2],field[3])
        end
    end
    if soft or jump then
        -- Bullet/Fit force 95 in the inspected source. Use the native generic
        -- low-arc Power path with the player's current Bullet lead instead.
        -- Every temporary setting is owned/restored within this synchronous solve.
        -- Jump's native branch always applies its vertical lead, including
        -- lateral routes. Reuse configured Fit height, not a new catch offset.
        for _,field in ipairs({{q,'ManualType',soft and touch.method=='ANGLE' and 'Angle' or 'Power'},{q,'Power',requestedPower},{q,'PreferHighArc',false},{profile.leads,nativeMode,appliedLead or profile.leads.Bullet}}) do
            local object,key,written=field[1],field[2],field[3]
            modeTransaction.fields[#modeTransaction.fields+1]={object=object,key=key,before=rawget(object,key),written=written}
            rawset(object,key,written)
        end
        if soft and touch.method=='ANGLE' then
            modeTransaction.fields[#modeTransaction.fields+1]={object=q,key='Angle',before=rawget(q,'Angle'),written=nativeInput}
            rawset(q,'Angle',nativeInput)
        end
    end
    if mag then
        modeTransaction.fields[#modeTransaction.fields+1]={object=profile.leads,key='Dime',before=rawget(profile.leads,'Dime'),written=appliedLead}
        rawset(profile.leads,'Dime',appliedLead)
    end
    if angleControl then
        for _,field in ipairs({{q,'ManualType','Angle'},{q,'Angle',nativeInput}}) do
            modeTransaction.fields[#modeTransaction.fields+1]={object=field[1],key=field[2],before=rawget(field[1],field[2]),written=field[3]}
            rawset(field[1],field[2],field[3])
        end
    end
    rawset(q.AutoThrowType,'Enabled',false); rawset(q,'SelectedType',nativeMode)
    nativeCalls=nativeCalls+1; frameCalls=frameCalls+1; maxFrameCalls=math.max(maxFrameCalls,frameCalls); modeChecks[mode]=(modeChecks[mode] or 0)+1
    local worker=coroutine.create(profile.solve); modeTransaction.worker=worker
    local ok,dir,origin,endpoint,power,time,velocity,aimpoint,initialAngle,returnedMode=coroutine.resume(worker,nativeInput,nativeMode)
    local yielded=coroutine.status(worker)=='suspended'
    local modeOwned=restoreModeTransaction()
    if yielded and not stopped then
        fatalError='Native calculator yielded; automatic settings restored and calculation cancelled'
        controller.Stop('NATIVE_SOLVER_YIELDED'); return nil,'NATIVE_SOLVER_YIELDED'
    end
    if stopped then return nil,'STOPPED' end
    if not ok then
        fatalError=clean(dir); log('SOLVER_ERROR',dir)
        controller.Stop('NATIVE_SOLVER_ERROR'); return nil,'NATIVE_SOLVER_ERROR'
    end
    if not modeOwned or q.AutoThrowType.Enabled~=true or returnedMode~=nil and returnedMode~=nativeMode then
        fatalError='Native mode changed during protected solve'
        controller.Stop('NATIVE_MODE_SCOPE_CONFLICT'); return nil,'NATIVE_MODE_SCOPE_CONFLICT'
    end
    if not ownsLock() or not teammate(player) or profile.selector()~=player.Character then return nil,'NATIVE_TARGET_MISMATCH' end
    if not refreshNativeInputs() or lastNativeInputs~=inputs then return nil,'NATIVE_SETTINGS_CHANGED_DURING_SOLVE' end
    origin,velocity=nativeVector(origin),nativeVector(velocity)
    if not vector(origin) or not vector(velocity) or not finite(time) or time<.05
        or not finite(power) or power<=0 or power>100 or velocity.Magnitude<1 or not modes[returnedMode] then return nil,'NATIVE_SOLVER_INVALID' end
    local arrival=origin+velocity*time-V(0,.5*CFG.Gravity*time*time,0)
    local ground=lines.ground
    if ground and arrival.Y<ground.Position.Y+ground.Size.Y*.5-.01 then return nil,'NATIVE_ARRIVAL_BELOW_FIELD' end
    aimpoint=nativeVector(aimpoint)
    if not vector(aimpoint) then return nil,'NATIVE_AIMPOINT_INVALID' end
    -- #7 precedes native vertical lead and AntiOOB. Only compare X/Z and
    -- reproduce the observed native clamp; this is arithmetic consistency,
    -- not an invented catch-height or catch-radius calibration.
    local target=aimpoint
    local oob=q.AntiOOB
    if type(oob)=='table' and oob.Enabled then
        if not finite(oob.XTolerance) or not finite(oob.ZTolerance) then return nil,'NATIVE_ANTIOOB_CONFIG_UNVERIFIED' end
        target=V(clamp(target.X,-75+oob.XTolerance,75+oob.XTolerance),target.Y,
            clamp(target.Z,-175+oob.ZTolerance,175+oob.ZTolerance))
    end
    local endpointError=flat(arrival-target).Magnitude
    -- The V24 live report contains native residuals of about .032-.034 studs.
    -- This narrowly bounded arithmetic allowance is not a catch radius. Use
    -- the actual ballistic arrival for every later reach/coverage check.
    local endpointTolerance=math.max(.05,flat(target-origin).Magnitude*.0001)
    if endpointError>endpointTolerance then
        arrivalRejects[mode]={target=player.Name,origin=origin,velocity=velocity,time=time,arrival=arrival,aim=target,
            error=endpointError,tolerance=endpointTolerance,epoch=possession.epoch}
        return nil,'NATIVE_ARRIVAL_AIMPOINT_MISMATCH',{Error=endpointError,Tolerance=endpointTolerance,Time=time,Power=power,
            Arrival={arrival.X,arrival.Y,arrival.Z},Aim={target.X,target.Y,target.Z}}
    end
    if endpointError>.01 then arrivalResiduals[mode]={error=endpointError,tolerance=endpointTolerance,epoch=possession.epoch} end
    local actualAngle=math.deg(math.atan(velocity.Y/math.max(.0001,flat(velocity).Magnitude)))
    if angleControl then
        -- Recorded live Dimes used input 45 but returned ~40-41 degrees.
        -- Native AutoCorrect/placement may change pitch; validate its returned
        -- path, not an invented equality between input and release elevation.
        if power>angleControl.powerCap+1 then
            controller.angle.status='NATIVE_ADAPTIVE_POWER_CAP_EXCEEDED';return nil,'NATIVE_ADAPTIVE_POWER_CAP_EXCEEDED'
        end
        controller.angle.origins[player]={origin=origin,head=launchHead,at=os.clock(),epoch=possession.epoch,profile=profile}
    end
    if mag then
        if not controller.mag.Allowed(player) then return controller.mag.Reject('MAG_TRUST_REVOKED') end
        if math.abs(arrival.Y-aimpoint.Y-appliedLead.Y)>endpointTolerance then return controller.mag.Reject('MAG_VERTICAL_LEAD_NOT_HONORED') end
        controller.mag.status='NATIVE_OUTPUT_VERIFIED_CATCH_UNCALIBRATED'
    end
    if soft or jump then
        local prefix=jump and 'JUMP_BULLET_' or 'CLOSE_BULLET_'
        local function reject(reason,switchMethod)
            if soft then
                touch.record(player,mode,requestedPower,power,reason)
                if switchMethod then touch.methodReceipt=touch.traces[#touch.traces];touch.method='ANGLE';touch.methodReason=reason end
            end
            return nil,prefix..reason
        end
        if (not soft or touch.method=='POWER') and math.abs(power-requestedPower)>1 then return reject('POWER_NOT_HONORED',soft) end
        if soft and power>=94.5 then return reject('LOW_POWER_UNAVAILABLE',touch.method=='POWER') end
        if soft and math.abs(velocity.Magnitude-power)>1 then return reject('SPEED_POWER_MISMATCH',touch.method=='POWER') end
        if jump and math.abs(velocity.Magnitude-requestedPower)>1 then return nil,'JUMP_BULLET_SPEED_NOT_HONORED' end
        local expectedY=aimpoint.Y+(appliedLead or profile.leads.Bullet).Y
        if math.abs(arrival.Y-expectedY)>endpointTolerance then return reject('LEAD_NOT_HONORED') end
        local distance=flat(arrival-origin).Magnitude
        local rise=math.atan2 and math.atan2(arrival.Y-origin.Y,distance) or math.atan((arrival.Y-origin.Y)/math.max(.001,distance))
        if math.atan(velocity.Y/math.max(.001,flat(velocity).Magnitude))>(math.pi/2+rise)/2+.0001 then return reject('HIGH_ARC_REJECTED',soft and touch.method=='POWER') end
        if soft then
            touch.origins[player]={origin=origin,head=launchHead,at=os.clock(),epoch=possession.epoch,profile=profile}
            touch.record(player,mode,requestedPower,power,'NATIVE_OUTPUT_ACCEPTED t='..string.format('%.3f',time))
            if touch.method=='POWER' then touch.methodReason='DIRECT_POWER_CONFIRMED' end
        end
    end
    appliedLead=appliedLead or profile.leads[soft and 'Bullet' or nativeMode]
    -- BEGIN OBSERVED OSCILLATION ADAPTER
    if zig and not controller.unified.oscillation.contains(samples[player],arrival,math.abs(profile.leads.Bullet.X)) then return nil,'ZIGZAG_NATIVE_POINT_OUTSIDE_OBSERVED_AREA' end
    -- END OBSERVED OSCILLATION ADAPTER
    if fastJump and (not finite(requestedPower) or math.abs(power-requestedPower)>1 or math.abs(velocity.Magnitude-power)>1
        or math.abs(arrival.Y-aimpoint.Y-appliedLead.Y)>endpointTolerance) then return nil,'NATIVE_JUMP_POWER_OR_LEAD_UNVERIFIED' end
    if fastJump then
        local rise=math.atan((arrival.Y-origin.Y)/math.max(.001,flat(arrival-origin).Magnitude))
        if math.atan(velocity.Y/math.max(.001,flat(velocity).Magnitude))>(math.pi/2+rise)/2+.0001 then return nil,'NATIVE_JUMP_HIGH_ARC_REJECTED' end
    end
    return {origin=origin,velocity=velocity,power=power,time=time,mode=mag and 'Dime' or (soft or jump) and 'Bullet' or nativeJump and 'Jump' or mode,arrival=arrival,
        variant=mode,softBullet=soft,oscillationBullet=zig,jumpBullet=jump,nativeCoverageJump=nativeJump,screen=screen,nativeMode=nativeMode,appliedLead=appliedLead,
        magTrial=mag,magPlayer=mag and player or nil,magTrustSource=mag and controller.mag.Source(player,false) or nil,
        magExtraY=mag and controller.mag.extraY or nil,magBaseLead=mag and profile.leads.Dime or nil,
        angleControl=angleControl,actualAngle=actualAngle,nativeAngleAdjustment=angleControl and actualAngle-angleControl.requested or nil,
        powerMethod=fastJump and 'NATIVE_JUMP_POWER_LOW' or soft and touch.method or 'NATIVE',requestedPower=requestedPower,
        effectiveYLead=arrival.Y-aimpoint.Y,verticalLeadControlActive=math.abs((arrival.Y-aimpoint.Y)-appliedLead.Y)<=endpointTolerance,
        nativeInput=nativeInput,nativeInputKind=fastJump and 'POWER' or angleControl and 'ANGLE_DEGREES' or ((soft or jump) and (not soft or touch.method=='POWER') or not soft and not jump and q.ManualType=='Power') and 'POWER' or 'ANGLE_DEGREES',
        launchHead=launchHead,qbModel=qbModel,targetPosition=targetPosition,targetVelocity=targetVelocity,
        passYards=flat(arrival-origin).Magnitude/3,at=os.clock()}
end
local plannerModes=controller.passPlan.openComfort and {'SoftBullet','QuickBullet','Bullet','Fit','Dime'}
    or controller.passPlan.preferJump and {'Jump','SoftBullet','QuickBullet','Bullet','Fit','Dime'} or {'SoftBullet','QuickBullet','Bullet','Fit','Dime','Jump'}
controller.jumpBullet.baseModes=#plannerModes
controller.jumpBullet.plannerModes=plannerModes
function controller.mag.RefreshModes()
    for i=#plannerModes,1,-1 do plannerModes[i]=nil end
    for _,m in ipairs({'ZigzagBullet','SoftBullet','QuickBullet','Bullet','Fit','Dime'})do plannerModes[#plannerModes+1]=m end
    if controller.nativeJump.supported and controller.nativeJump.enabled then plannerModes[#plannerModes+1]='CoverageJump' end
end
controller.mag.enabled=false;controller.jumpBullet.enabled=false;controller.passPlan.preferJump=false
function controller.SetMagTrial(value) if value then setGate('MAG_UNSUPPORTED_IN_B3');return false end;return true end
function controller.SetJumpBullet(value) if value then setGate('CUSTOM_JB_UNSUPPORTED_IN_B3');return false end;return true end
function controller.SetOpenComfort(value)
    if stopped or type(value)~='boolean' then return false end
    releaseChoice();controller.passPlan.openComfort=value;controller.mag.RefreshModes()
    if controller.unified.easeButton then controller.unified.easeButton.Text=value and 'EASE ON' or 'EASE OFF' end
    return true
end

controller.mag.RefreshModes()
function controller.fit.alternatives(player,s,defenders,now,fresh,fresh2,includeFit)
    local result={};local cache=shotCache[player]
    if not cache or cache.model~=s.model or cache.epoch~=possession.epoch or cache.generation~=lines.generation then return result end
    for _,variant in ipairs(plannerModes) do
        local other=fresh and fresh.variant==variant and fresh or fresh2 and fresh2.variant==variant and fresh2 or cache.shots[variant]
        if other and (includeFit or other.mode~='Fit') and now-other.at<=CFG.CacheAge
            and receiverReady(player,s,now,other.arrival) and receivePossible(other,s) then
            risk(other,s,defenders);coverage(other,s,defenders);result[#result+1]=other
        end
    end
    if includeFit then for _,other in ipairs(result) do if other.mode=='Fit' then controller.fit.assess(other,result) end end end
    return result
end
function controller.unified.Settings()
    return {Auto=auto,AutomaticThrow=throwing,Risk=riskPolicy.mode,Plan=controller.passPlan.mode,
        Profile=controller.league.mode,RequestedProfile=controller.league.requested,ReceiverFilter=controller.receiverFilter.mode,
        OpenComfort=controller.passPlan.openComfort,NativeJump=controller.nativeJump.enabled,AdaptiveAngle=controller.angle.enabled,
        SafetyReads=controller.safety.enabled,CoverageWindows=controller.coverageWindows.enabled,JumpDelaySeconds=controller.jumpTiming.delay,
        MinDownfieldYards=CFG.MinDownfieldYards,WorldGravity=workspace.Gravity,Unified=controller.unified.config,
        CloseBullet={Enabled=touch.enabled,Comfort=touch.comfort,Quick=touch.quick,MinPower=touch.min,FullPowerYards=touch.full},
        Leads=controller.receiverEvidence.ReadSettings(),NativeContext=controller.receiverEvidence.NativeContext(),
        Field={LOS=controller.history.Vector(lines.los),Forward=controller.history.Vector(lines.forward),GoalToGo=lines.goalToGo,Generation=lines.generation,Status=lines.status}}
end
local function evaluate(receivers,indices,defenders,now)
    controller.bad:begin(possession.epoch,now,receivers,plannerModes,defenders,controller.unified.config,riskPolicy.mode,controller.passPlan.mode)
    controller.bad.frame.Settings=controller.unified.Settings()
    controller.angle.scene={at=now,epoch=possession.epoch,generation=lines.generation,team=me.Team,defenders=defenders}
    local groups={}
    for _,index in ipairs(indices) do
        local r=receivers[index]
        local cache=shotCache[r.player]
        if not cache or cache.model~=r.sample.model or cache.epoch~=possession.epoch or cache.generation~=lines.generation then
            cache={model=r.sample.model,epoch=possession.epoch,generation=lines.generation,shots={},rotation=0}
            shotCache[r.player]=cache
        end
        groups[#groups+1]={r=r,cache=cache,tried={}}
    end
    for _,g in ipairs(groups)do controller.bad:schedule(g.r.player.Name,plannerModes)end
    local calls,started,limited=0,os.clock(),false
    local attempts=0;local attemptLimit=#groups*#plannerModes
    local callLimit=(controller.coverageWindows.enabled or controller.league.mode=='LEAGUE') and math.min(5,CFG.PlanCalls) or CFG.PlanCalls
    -- Interleave receivers before trying a second/third mode. A slow native
    -- solve cannot consume every frame's allowance on the same receiver.
    for pass=1,#plannerModes do
        for offset=1,#groups do
            local index=(offset+planRound-1)%#groups+1
            local g=groups[index]
            if calls>=callLimit or attempts>=attemptLimit or os.clock()-started>=CFG.PlanSeconds then limited=true; break end
            -- Advance only after an actual solve. Even if a single native
            -- call consumes the whole time allowance, every mode gets a turn.
            local mode
            for _=1,#plannerModes do
                g.cache.rotation=g.cache.rotation%#plannerModes+1
                local nextMode=plannerModes[g.cache.rotation]
                if not g.tried[nextMode] then mode=nextMode; break end
            end
            g.tried[mode]=true
            local beforeCalls=frameCalls
            local shot,why=solve(g.r.player,mode);calls=calls+(frameCalls-beforeCalls);attempts=attempts+1
            controller.bad:native(g.r.player.Name,mode,shot,why,frameCalls>beforeCalls)
            g.cache.plannedAt=now
            if stopped then return end
            if shot then g.cache.shots[mode]=shot
            else
                g.cache.shots[mode]=nil
                receiverRejects[g.r.player.Name..'/'..mode]=why
                if why=='NATIVE_SETTINGS_CHANGED_DURING_SOLVE' then return end
            end
        end
        if calls>=callLimit or attempts>=attemptLimit or os.clock()-started>=CFG.PlanSeconds then
            if pass<#plannerModes then limited=true end
            break
        end
    end
    controller.bad.frame.NativeLimited=limited
    if limited then planDeferred=planDeferred+1 end
    maxPlanCalls=math.max(maxPlanCalls,calls)
    -- Native work stays limited to the scheduled pair. Regrade other current
    -- receivers' still-fresh tuples too: rotating out of the solve pair must
    -- not hide a window that just opened. Cache age/identity checks bound the
    -- live tuples; every winning candidate is solved again before release.
    local scheduled={}
    for _,g in ipairs(groups) do scheduled[g.r.player]=true end
    for _,r in ipairs(receivers) do
        local cache=shotCache[r.player]
        if not scheduled[r.player] and cache and cache.model==r.sample.model
            and cache.epoch==possession.epoch and cache.generation==lines.generation then
            local fresh=false
            for _,mode in ipairs(plannerModes) do
                local shot=cache.shots[mode]
                if shot and now-shot.at<=CFG.CacheAge then fresh=true;break end
            end
            if fresh then groups[#groups+1]={r=r,cache=cache} end
        end
    end
    local best,incumbent
    candidateEvidence={}
    for _,g in ipairs(groups) do
        local r,bestShot=g.r,nil
        local chest=g.cache.shots.Bullet
        r.sample.chestReference=chest and now-chest.at<=CFG.CacheAge and chest or nil
        local valid={}
        for _,mode in ipairs(plannerModes) do
            local shot=g.cache.shots[mode]
            if shot and now-shot.at<=CFG.CacheAge then
                shot.releaseBlocked=false
                local eligible,rejection=receiverReady(r.player,r.sample,now,shot.arrival)
                if eligible then eligible,rejection=receivePossible(shot,r.sample) end
                if eligible then
                    risk(shot,r.sample,defenders); coverage(shot,r.sample,defenders)
                    valid[#valid+1]=shot
                else controller.bad:status(r.player.Name,mode,'READINESS_REJECTED',rejection,shot);receiverRejects[r.player.Name..'/'..mode]=rejection end
            else controller.bad:status(r.player.Name,mode,'NOT_EVALUATED',shot and 'STALE_NATIVE_TUPLE' or 'NO_NATIVE_TUPLE',shot)
            end
        end
        for _,shot in ipairs(valid) do if shot.jumpBullet or shot.nativeCoverageJump then shot.jumpBulletAllowed=false end end
        for _,shot in ipairs(valid) do if shot.mode=='Fit' then controller.fit.assess(shot,valid) end end
        for _,shot in ipairs(valid) do if shot.jumpBullet or shot.nativeCoverageJump then controller.jumpBullet.assess(shot,valid) end end
        for _,shot in ipairs(valid) do
            local mode=shot.variant or shot.mode
            candidateEvidence[#candidateEvidence+1]=string.format('%s %s t=%.3f p=%.2f margin=%.2f lane=%.2f release=%s clearBurn=%s safetyOverTop=%s',r.player.Name,mode,shot.time,shot.power,shot.margin,shot.lane,tostring(throwable(shot)),tostring(shot.clearBurn),tostring(shot.safetyOverTop))..string.format(' directLane=%s race=%s wrETA=%s lateral=%s',tostring(shot.directLane),tostring(shot.raceAdvantage),tostring(shot.receiverETA),tostring(shot.routeLateral))
                ..' safetyRead='..tostring(shot.safetyRead and shot.safetyRead.State)..' fitReason='..tostring(shot.fitReason)..' fitSecond='..tostring(shot.fitSecondVariant)..' jumpReason='..tostring(shot.jumpBulletReason)..' dbETA='..tostring(shot.defenderETA)..' powerAllowed='..tostring(shot.powerAllowed)..' powerMethod='..tostring(shot.powerMethod)..' powerReason='..tostring(shot.powerReason)..' minFlight='..tostring(shot.minimumFlight)..' plan='..tostring(shot.planReason)..' depthYards='..tostring(shot.catchDepthYards)..' comeback='..tostring(shot.deepComeback)..' wide='..tostring(shot.wideOpen)
            if better(shot,bestShot) then bestShot=shot end
        end
        if bestShot then
            r.shot=bestShot; g.cache.preferred=bestShot.mode
            local old=opportunities[r.player]
            if throwable(bestShot) then
                local continuous=old and old.model==r.sample.model and old.epoch==possession.epoch
                    and old.generation==lines.generation and now-old.checked<=CFG.SafeGap
                r.openSince=continuous and old.since or now
                opportunities[r.player]={since=r.openSince,checked=now,model=r.sample.model,
                    epoch=possession.epoch,generation=lines.generation}
            else opportunities[r.player]=nil end
            if choice and r.player==choice.player and r.sample.model==choice.model then incumbent=r end
            if not best or receiverBetter(r,best) then best=r end
        else opportunities[r.player]=nil end
    end

    controller.bad:finish(best,os.clock()-started)
    return best
end
-- Advisory only: forecasts run after release work, reuse the native tuple,
-- and never authorize/delay a throw or move the player's character.
clearGuide=function()
    assistance.guide=nil; assistance.guidePending=nil
    if assistance.guideUI then assistance.guideUI.Visible=false end
end
cancelJump=function(reason)
    local plan=assistance.jumpPlan
    if plan and plan.owned and plan.hum.Jump==true then
        local restored=pcall(function() plan.hum.Jump=plan.before end)
        if not restored then assistance.jumpStatus='JUMP_RESTORE_FAILED';return false end
    end
    assistance.jumpPlan=nil
    if plan then assistance.jumpStatus=reason or 'CANCELLED' end
    return true
end
local function ascentTime(hum)
    local gravity=workspace.Gravity
    if not finite(gravity) or gravity<=0 then return end
    if hum.UseJumpPower==true and finite(hum.JumpPower) and hum.JumpPower>0 then return hum.JumpPower/gravity end
    if hum.UseJumpPower==false and finite(hum.JumpHeight) and hum.JumpHeight>0 then return math.sqrt(2*hum.JumpHeight/gravity) end
end
forecastGuide=function(data,now)
    clearGuide()
    if ff3Options.MovementGuide==false and ff3Options.PredictiveJump==false or not data or stopped or not auto or pending or usedTools[data.ball.tool]==possession.epoch
        or receiverMenu and receiverMenu.Visible then return end
    local r,ball=data.r,data.ball
    local shot,s=r.shot,r.sample
    if not shot or not shot.time or throwable(shot) or not receiverReady(r.player,s,now) then return end
    local velocity=flat(s.v)
    if velocity.Magnitude<CFG.MinMoveSpeed or not finite(ball.hum.WalkSpeed) or ball.hum.WalkSpeed<=0 then return end
    if shot.jumpBullet or shot.nativeCoverageJump or shot.magTrial or shot.mode=='Fit' then return end -- no unproven counterfactual for an elevated trial/timing rescue
    local right=V(-lines.forward.Z,0,lines.forward.X)
    local directions={velocity.Unit,right,-right,-lines.forward}
    local started=os.clock()
    local checks,best=0,nil
    -- Planning horizons are advisory policy, not game catch-window calibration.
    for _,lead in ipairs({.25,.5,.75}) do
      for _,direction in ipairs(lead==.5 and directions or {directions[1]}) do
        if checks>=6 or os.clock()-started>.001 then break end
        checks=checks+1
        local run=direction*ball.hum.WalkSpeed
        local futureQB=ball.root.Position+run*lead
        local arrival=shot.arrival+velocity*lead
        if onField(futureQB) and onField(arrival) and (downfield(futureQB)<=controller.field.QBLimit(ball.root))
            and (controller.field.BeyondMinimum(arrival)) then
            local future={origin=shot.origin+run*lead,arrival=arrival,time=shot.time,mode=shot.mode,variant=shot.variant,softBullet=shot.softBullet,networkPing=shot.networkPing,
                velocity=shot.velocity+(velocity-run)*(lead/shot.time)}
            -- This is an estimated continuation, not an extra native solve.
            -- Reject estimates exceeding the source's maximum release power.
            if future.velocity.Magnitude<=100 then
                local defenders={}
                local room,oldRoom=math.huge,math.huge
                for i,d in ipairs(data.defenders) do
                    local p=predict(d,lead)
                    defenders[i]={p=p,v=d.v,turn=d.turn,observedSpeed=d.observedSpeed,hum=d.hum,name=d.name}
                    room=math.min(room,flat(futureQB-p).Magnitude-runSpeed(d)*lead-(4.5+d.turn*3))
                    oldRoom=math.min(oldRoom,flat(ball.root.Position-p).Magnitude-runSpeed(d)*lead-(4.5+d.turn*3))
                end
                local receiver={p=predict(s,lead),v=s.v,turn=s.turn,routeTurn=s.routeTurn,depthEpoch=s.depthEpoch,depthGeneration=s.depthGeneration,depthPeakYards=s.depthPeakYards}
                risk(future,receiver,defenders);coverage(future,receiver,defenders);assistance.guideChecks=assistance.guideChecks+1
                if throwable(future) and room>0 then
                    local roomGain=finite(room) and finite(oldRoom) and clamp(room-oldRoom,-6,6) or 0
                    local score=future.score+roomGain-lead*6
                    if not best or score>best.score then
                        best={player=r.player,model=s.model,qbModel=ball.model,epoch=possession.epoch,
                            generation=lines.generation,direction=direction,at=now,lead=lead,mode=shot.mode,score=score,roomGain=roomGain}
                    end
                end
            end
        end
      end
      if checks>=6 or os.clock()-started>.001 then break end
    end
    assistance.guide=best
    controller.groundGuide.status=best and 'PREDICTED_PASSING_ROOM' or 'NO_PREDICTED_SAFE_ROOM'
    assistance.maxGuideSeconds=math.max(assistance.maxGuideSeconds,os.clock()-started)
end
do
    local timing=controller.jumpTiming
    function timing.Reset()
        timing.track=nil;timing.last=nil
    end
    function timing.Observe(now)
        if stopped or not auto or not possession.wasReady or usedTools[possession.tool]==possession.epoch then timing.Reset();return end
        local p=timing.track
        if not p or p.model~=me.Character or not p.root.Parent or p.hum.Parent~=p.model then
            local model,root,_,hum=body(me)
            if not model then timing.Reset();return end
            p={model=model,root=root,hum=hum,air=false,takeoffSeen=false};timing.track=p;timing.last=nil
        end
        if p.hum.Health<=0 then timing.Reset();return end
        local state=p.hum:GetState()
        local air=p.hum.FloorMaterial==Enum.Material.Air or state==Enum.HumanoidStateType.Jumping or state==Enum.HumanoidStateType.Freefall
        if air and not p.takeoffSeen and vector(p.root.AssemblyLinearVelocity) and p.root.AssemblyLinearVelocity.Y>0 then
            timing.last={at=now,model=p.model,hum=p.hum};p.takeoffSeen=true;timing.observations=timing.observations+1
            if assistance.jumpEpoch==possession.epoch and now>=assistance.jumpRequestedAt then assistance.jumpRequestObserved=true end
            timing.status='LOCAL_TAKEOFF_OBSERVED'
        elseif not air then timing.last=nil;p.takeoffSeen=false end
        p.air=air
    end
    function timing.Wait(seq,ball,now)
        local jump=timing.last
        local rising=ball.hum.FloorMaterial==Enum.Material.Air and ball.root.AssemblyLinearVelocity.Y>0
        if jump and jump.model==ball.model and jump.hum==ball.hum then
            seq.jumpObservedAt=jump.at;seq.jumpTimingSource='OBSERVED_LOCAL_TAKEOFF'
            if seq.deep and ascentTime(ball.hum) and not rising then
                timing.status='DEEP_WAIT_LANDING';setGate(timing.status);return false
            end
            if now-jump.at<timing.delay then timing.status='WAIT_JUMP_RELEASE_OFFSET';setGate(timing.status);return false end
            timing.status='POST_JUMP_READY';return true
        end
        if seq.deep and ascentTime(ball.hum) then
            if ball.hum.FloorMaterial==Enum.Material.Air then
                timing.status='DEEP_WAIT_LANDING'
            elseif seq.jumpAwaitAt and now-seq.jumpAwaitAt<.25 then
                timing.status='WAIT_LOCAL_TAKEOFF'
            else
                -- No takeoff does not poison the possession or create a ground
                -- throw. requestJump can try again after the bounded retry gap.
                seq.preJumpCheckedAt=nil;seq.jumpAwaitAt=nil
                timing.status='WAIT_DEEP_TAKEOFF_RETRY'
            end
            setGate(timing.status);return false
        end
        timing.status='NO_NEW_JUMP_IMMEDIATE';return true
    end
end
local function deepThrow(shot,hum)
    if shot.softBullet or shot.screen then return false end -- softened close pass or deliberate stationary screen
    local ascent=ascentTime(hum)
    -- A timing policy relative to this character's normal jump, not an
    -- invented official FF3 yardage/catch threshold. Missing jump parameters
    -- still classify elevated native modes for a normal jump. The short takeoff
    -- offset is handled separately; no yard cutoff or peak gate is introduced.
    return ascent and shot.time>ascent*2 or not ascent and shot.mode~='Bullet'
end
-- Request the ordinary jump only. The optional short offset starts at observed
-- local takeoff, never at the apex or animation windup.
requestJump=function(ball,now)

    if assistance.jumpEpoch==possession.epoch and now-assistance.jumpRequestedAt<.25 then return end
    local hum=ball.hum
    if hum.Jump==true or hum.FloorMaterial==Enum.Material.Air then
        assistance.jumpStatus=controller.jumpTiming.delay>0 and 'USER_JUMP_OR_AIRBORNE; OFFSET_IF_RECENT_TAKEOFF' or 'USER_JUMP_OR_AIRBORNE; RELEASE_IMMEDIATE';return
    end
    if hum.Sit or hum.PlatformStand or not hum:GetStateEnabled(Enum.HumanoidStateType.Jumping) then
        assistance.jumpStatus='NORMAL_JUMP_UNAVAILABLE; RELEASE_IMMEDIATE';return
    end
    assistance.jumpEpoch=possession.epoch;assistance.jumpRequestedAt=now;assistance.jumpRequestObserved=false;assistance.jumpCount=assistance.jumpCount+1
    assistance.jumpPlan={hum=hum,model=ball.model,epoch=possession.epoch,before=hum.Jump,owned=true,requested=now}
    if sequence then sequence.jumpAwaitAt=now end
    hum.Jump=true;assistance.jumpMethod='HUMANOID_JUMP'
    if type(hum.ChangeState)=='function' then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        assistance.jumpMethod='HUMANOID_JUMP_AND_CHANGE_STATE'
    end
    assistance.jumpStatus=controller.jumpTiming.delay>0 and 'REQUESTED_WAIT_LOCAL_TAKEOFF_OFFSET' or 'REQUESTED_RELEASE_IMMEDIATE'
    log('AUTO_JUMP','method='..assistance.jumpMethod..(controller.jumpTiming.delay>0 and '; short observed-takeoff offset; no peak wait' or '; no ascent or peak wait'))
end
updateJump=function(now)
    local plan=assistance.jumpPlan
    if not plan then return end
    -- Leave the normal Jump flag available for one physics turn. This cleanup
    -- never authorizes, delays or retries a throw, even if no ascent occurs.
    if plan.hum.Jump~=true then plan.owned=false;assistance.jumpPlan=nil
    elseif now>plan.requested or me.Character~=plan.model or stopped then cancelJump('JUMP_REQUEST_FINISHED') end
end

drawGuide=function(now)
    if not assistance.guideUI then return end
    if ff3Options.MovementGuide==false then assistance.guideUI.Visible=false;return end
    local g=assistance.guide
    if not g or stopped or not auto or pending or now-g.at>.35 or g.epoch~=possession.epoch
        or g.generation~=lines.generation or g.qbModel~=me.Character or g.model~=g.player.Character
        or not teammate(g.player) or not choice or choice.player~=g.player or receiverMenu and receiverMenu.Visible then
        assistance.guideUI.Visible=false;return
    end
    if now<(assistance.nextGuideDraw or 0) then return end
    assistance.nextGuideDraw=now+1/30
    local _,root,_,hum=body(me)
    if not root or not hum or not finite(hum.WalkSpeed) then assistance.guideUI.Visible=false;return end
    local ok=controller.groundGuide.Project(root.Position,g.direction,clamp(hum.WalkSpeed*g.lead,3,9))
    assistance.guideUI.Visible=ok
end
function controller.groundGuide.Project(position,direction,length)
    if stopped or not gui or not assistance.guideSegments or not vector(position) or not vector(direction) or not finite(length) or length<=0 then return false end
    direction=flat(direction)
    if direction.Magnitude<.001 then controller.groundGuide.status='INVALID_DIRECTION';return false end
    direction=direction.Unit
    local camera=workspace.CurrentCamera;local ground=lines.ground
    if not camera or type(camera.WorldToScreenPoint)~='function' or not ground or groundReason()~='ACCEPTED' then
        controller.groundGuide.status='GROUND_OR_CAMERA_UNVERIFIED';return false
    end
    local cf=ground.CFrame;local localPoint=cf:PointToObjectSpace(position)
    local _,qbRoot=body(me);if not qbRoot then return false end
    local qbLimit=controller.field.QBLimit(qbRoot)
    local base=cf:PointToWorldSpace(V(localPoint.X,ground.Size.Y/2+.04,localPoint.Z))
    local right=V(-direction.Z,0,direction.X)
    local start=base+direction*.75;local tip=base+direction*length
    local left=tip-direction*2+right*1.25;local wing=tip-direction*2-right*1.25
    local points={start,tip,left,wing};local projected={}
    for i,point in ipairs(points) do
        if not onField(point) or downfield(point)>qbLimit then
            controller.groundGuide.status='ARROW_OUTSIDE_VERIFIED_ROOM';return false
        end
        local p,onScreen=camera:WorldToScreenPoint(point)
        if not vector(p) or not onScreen or p.Z<=0 then controller.groundGuide.status='ARROW_OFFSCREEN';return false end
        projected[i]=p
    end
    for i,pair in ipairs({{1,2},{2,3},{2,4}}) do
        local a,b=projected[pair[1]],projected[pair[2]]
        local dx,dy=b.X-a.X,b.Y-a.Y;local span=math.sqrt(dx*dx+dy*dy)
        if span<1 then controller.groundGuide.status='ARROW_TOO_SMALL';return false end
        local segment=assistance.guideSegments[i]
        segment.Position=UDim2.fromOffset((a.X+b.X)/2,(a.Y+b.Y)/2)
        segment.Size=UDim2.fromOffset(span,3)
        segment.Rotation=math.deg(math.atan2 and math.atan2(dy,dx) or math.atan(dy,dx))
    end
    controller.groundGuide.draws=controller.groundGuide.draws+1;controller.groundGuide.status='UI_PROJECTED_GROUND_ARROW'
    return true
end
controller.groundGuide.Forecast=forecastGuide
controller.groundGuide.Draw=drawGuide

local function holdManual(r,reason,evidence)
    if r then
        local recorded=r.shot
        if evidence then recorded=evidence.shot end
        rememberBlocked(r.player,recorded,reason or 'MANUAL_LOCK_COVERED',evidence)
    end
    if sequence and sequence.deep and r and sequence.player==r.player and reason=='MANUAL_LOCK_COVERED' then
        log('BURN_CANCEL',r.player.Name..' BURN_COVERAGE_CLOSED; REPLAN_ALLOWED')
        cancelSequence('BURN_COVERAGE_CLOSED')
    elseif cancelSequence then cancelSequence('MANUAL_LOCK_ONLY') end
    if stopped then return end
    if not r or not teammate(r.player) then releaseChoice(); setGate('NO_ACTIVE_DOWNFIELD_RECEIVER'); return end
    local eligible,rejection=receiverReady(r.player,r.sample,os.clock())
    if not eligible then releaseChoice(); setGate(rejection); return end
    if not lock(r.player) then releaseChoice(); setGate('NATIVE_LOCK_BUSY'); return end
    local stable=choice and choice.player==r.player and choice.model==r.player.Character
    r.model=r.player.Character; r.manualOnly=true; r.openSince=nil
    r.shot=r.shot or {mode='NATIVE',window='MANUAL_ONLY'}
    choice=r
    if not stable then log('MANUAL_SELECT',r.player.Name) end
    setGate(reason or 'MANUAL_LOCK_COVERED')
end
local function fallbackReceiver(receivers)
    local best,incumbent
    for _,r in ipairs(receivers) do
        if not best or r.rank>best.rank then best=r end
        if choice and choice.player==r.player and choice.model==r.player.Character then incumbent=r end
    end
    if best and incumbent and best.rank-incumbent.rank<CFG.ReceiverSwitchYards*3 then return incumbent end
    return best
end
local function currentDefenders(player,now)
    local defenders={}
    local roster=Players:GetPlayers()
    if #roster>CFG.MaxRoster then return nil,nil,'ROSTER_LIMIT' end
    for _,p in ipairs(roster) do
        if p~=me and not p.Neutral and p.Team and body(p) and (p==player or p.Team~=me.Team) then
            local s=sample(p,now)
            if not s or s.n<2 then return nil,nil,'SAMPLING_PLAYERS' end
            local model,root,head,hum=body(p)
            if not model or model~=s.model or not vector(root.AssemblyLinearVelocity) then return nil,nil,'PLAYER_OBSERVATION_CHANGED' end
            -- sample() can be called twice with the same tick timestamp. Refresh
            -- actual pose/velocity even then; the final safety check is not a cache.
            s.turn=math.max(s.turn,clamp((root.AssemblyLinearVelocity-s.v).Magnitude/30,0,1))
            s.p,s.v,s.head,s.hum=root.Position,root.AssemblyLinearVelocity,head,hum
            if p.Team~=me.Team then defenders[#defenders+1]=s end
        end
    end
    return samples[player],defenders
end

-- BEGIN RECEIVER EVIDENCE
-- Passive observations and empirical comparisons; no catch-window or input-intent claim.
controller.receiverEvidence=(function()
    local e={candidateSet=setmetatable({}, {__mode='k'}),status='NO_THROW_OBSERVED',nextAt=0,last={},candidates={},settings={},advice={},rejected={},observations=0,maxSeconds=0}
    local active
    local evidenceOptions=ff3Options.ReceiverEvidence
    if evidenceOptions==nil then evidenceOptions={} elseif evidenceOptions==false then evidenceOptions={Enabled=false} end
    assert(type(evidenceOptions)=='table','FF3.ReceiverEvidence must be a table or false')
    assert(evidenceOptions.Enabled==nil or type(evidenceOptions.Enabled)=='boolean','ReceiverEvidence.Enabled must be boolean')
    e.enabled=evidenceOptions.Enabled~=false
    if not e.enabled then e.status='CAPTURE_DISABLED' end
    local function assetId(value)
        if type(value)=='number' and value%1==0 and value>0 then return 'rbxassetid://'..string.format('%.0f',value) end
        if type(value)=='string' then
            local id=value:match('^rbxassetid://(%d+)$') or value:match('^%d+$') or value:match('^https?://www%.roblox%.com/asset/%?id=(%d+)$')
            if id then return 'rbxassetid://'..id end
        end
    end
    local poseCalibration=evidenceOptions.VerifiedDivePose
    if poseCalibration~=nil then
        assert(type(poseCalibration)=='table' and type(poseCalibration.Reference)=='string' and #poseCalibration.Reference>0 and #poseCalibration.Reference<=100,'VerifiedDivePose requires a controlled-evidence reference')
        assert(finite(poseCalibration.MaxTorsoUpAbs) and poseCalibration.MaxTorsoUpAbs>=0 and poseCalibration.MaxTorsoUpAbs<1
            and finite(poseCalibration.UprightMinUpAbs) and poseCalibration.UprightMinUpAbs>poseCalibration.MaxTorsoUpAbs and poseCalibration.UprightMinUpAbs<=1
            and finite(poseCalibration.MinHandForward) and math.abs(poseCalibration.MinHandForward)<20,'Invalid verified pose bounds')
    end
    local mappingVerified=poseCalibration~=nil
    local function vec(v) return v and {v.X,v.Y,v.Z} end
    local function round(n) return math.floor(n*1000+.5)/1000 end
    local function pose(player)
        local model,root,head,hum=body(player)
        if not model or not vector(root.AssemblyLinearVelocity) then return end
        local stateOK,state=pcall(function() return hum:GetState() end)
        local name=stateOK and tostring(state):match('([^%.]+)$') or 'UNKNOWN'
        local floor=hum.FloorMaterial
        local grounded=name=='Running' or name=='RunningNoPhysics' or name=='Landed'
        if name~='Jumping' and name~='Freefall' and not grounded and floor and Enum.Material then grounded=floor~=Enum.Material.Air end
        return {model=model,root=root,head=head,hum=hum,p=root.Position,v=root.AssemblyLinearVelocity,
            grounded=grounded,state=name,up=root.CFrame and root.CFrame.UpVector and root.CFrame.UpVector.Y}
    end
    function e.ReadSettings()
        local out={}
        if profile and profile.leads and aliveConnection(profile.preview) and aliveConnection(profile.release) then
            for _,mode in ipairs({'Bullet','Fit','Jump','Dive','Dime'}) do
                local lead=profile.leads[mode]
                if lead and finite(lead.X) and finite(lead.Y) then out[mode]={X=lead.X,Y=lead.Y} end
            end
        end
        return out
    end
    function e.NativeContext()
        local q=profile and profile.q;if not q then return {} end
        local parts={tostring(q.ManualType),tostring(q.Angle),tostring(q.Power),tostring(q.PreferHighArc),tostring(q.AutoCorrect),tostring(workspace.Gravity)}
        local function add(v) parts[#parts+1]=(type(v)=='number' or type(v)=='boolean' or type(v)=='string') and tostring(v) or 'UNAVAILABLE' end
        for _,setting in ipairs({'SmartPass','AntiOOB'}) do
            local value=q[setting]
            if type(value)=='table' then for _,field in ipairs({'Enabled','FitOnly','MaxRange','XTolerance','ZTolerance'}) do add(value[field]) end else add(value) end
        end
        for i,value in ipairs(parts) do parts[i]=tostring(value) end
        local signature=table.concat(parts,':');local chunks={}
        for i=1,#signature,90 do chunks[#chunks+1]=signature:sub(i,i+89) end
        return {Signature=signature,SignatureParts=chunks,Complete=#chunks<=8,Source='QUALIFIED_SHARED_NATIVE_SETTINGS'}
    end
    function e.Bindings(shot)
        local x=shot.mode;local y=shot.mode
        if shot.softBullet then x='Bullet';y='Bullet' end
        if shot.jumpBullet then x='Bullet';y='Fit' end
        return {X=x..'.X',Y=y..'.Y',YOffset=shot.magTrial and 'MagTrial.ExtraY' or nil}
    end
    local function owner(part)
        local function ancestor(o)
            for _=1,5 do
                if not o then return end
                if o:IsA('Model') then
                    local p=Players:GetPlayerFromCharacter(o)
                    if p then return p end
                end
                o=o.Parent
            end
        end
        local found=ancestor(part)
        if found then return found end
        local ok,parts=pcall(function() return part:GetConnectedParts(false) end)
        if ok and type(parts)=='table' then
            if #parts>16 then return nil,'ASSEMBLY_CAP' end
            for _,p in ipairs(parts) do
                local pOwner=ancestor(p)
                if pOwner then if found and found~=pOwner then return nil,'AMBIGUOUS_OWNER' end;found=pOwner end
            end
        end
        return found
    end
    local function ballLike(part)
        if not instance(part,'BasePart') then return false end
        local at=part
        for _=1,4 do if not at then break end;if at.Name=='Football' then return true end;at=at.Parent end
        return false
    end
    function e.OnAdded(part)
        if not e.enabled or e.disabled or not active or os.clock()-active.at>1 or #e.candidates>=16 then return end
        if ballLike(part) and part~=active.handle and part:IsDescendantOf(workspace) then
            local root=part.AssemblyRootPart
            if instance(root,'BasePart') then part=root end
            if not e.candidateSet[part] then e.candidateSet[part]=true;e.candidates[#e.candidates+1]=part end
        end
    end
    -- A stiff airborne torso with hands extended is pose evidence, independent of animation names.
    local function observePose(f,p)
        local model=p.model
        local torso=model:FindFirstChild('UpperTorso') or model:FindFirstChild('Torso')
        local function hand(side)
            local part=model:FindFirstChild(side..'Hand')
            if part and vector(part.Position) then return part.Position,'HAND_PART' end
            part=model:FindFirstChild(side..' Arm')
            if part and part.CFrame and vector(part.Position) then
                return part.Position-part.CFrame.UpVector*(part.Size.Y*.5),'R6_ARM_ENDPOINT_ESTIMATE'
            end
        end
        local left,leftSource=hand('Left');local right,rightSource=hand('Right')
        local travel=flat(p.v);if travel.Magnitude<1 then travel=f.route end
        local torsoUp=torso and torso.CFrame and torso.CFrame.UpVector.Y
        local forward=travel.Magnitude>0 and travel.Unit or nil
        local leftForward=left and torso and forward and (left-torso.Position):Dot(forward)
        local rightForward=right and torso and forward and (right-torso.Position):Dot(forward)
        local rigid=p.hum.PlatformStand==true or p.state=='Physics' or p.state=='Ragdoll' or p.state=='FallingDown'
        local metrics={TorsoUpY=torsoUp,RootUpY=p.up,HeadHeightFromRoot=p.head.Position.Y-p.p.Y,
            LeftHandForward=leftForward,RightHandForward=rightForward,LeftSource=leftSource,RightSource=rightSource,
            PlatformStand=p.hum.PlatformStand==true,RigidPhysicsState=rigid,AirborneState=not p.grounded}
        local known=finite(torsoUp) and finite(leftForward) and finite(rightForward)
        local maxUp=poseCalibration and poseCalibration.MaxTorsoUpAbs or .55
        local minHands=poseCalibration and poseCalibration.MinHandForward or 0
        local upright=poseCalibration and poseCalibration.UprightMinUpAbs or .8
        local diveLike=known and (not p.grounded or rigid) and math.abs(torsoUp)<=maxUp and leftForward>=minHands and rightForward>=minHands
        local classified=known and (diveLike or math.abs(torsoUp)>=upright)
        if not classified then f.poseUnknown=true end
        if diveLike and mappingVerified then f.diveVerified=true end
        metrics.Classification=diveLike and 'DIVE_LIKE_POSE' or classified and 'UPRIGHT_POSE' or 'UNCLASSIFIED_POSE'
        f.lastPose=metrics
        if diveLike and not f.firstDivePose then f.firstDivePose={At=os.clock()-f.at,Metrics=metrics} end
        return diveLike,metrics
    end
    -- Optional animation inventory is ancillary. No name/ID defines dive state.
    local function animations(f,p)
        local ok,tracks=pcall(function() return p.hum:GetPlayingAnimationTracks() end)
        if not ok or type(tracks)~='table' then return end
        for i=1,math.min(#tracks,8) do
            local track=tracks[i];local asset=track.Animation;local id=asset and assetId(asset.AnimationId)
            if id and not f.animationAssets[id] then
                local n=0;for _ in pairs(f.animationAssets) do n=n+1 end
                if n<8 then f.animationAssets[id]={At=os.clock()-f.at,AncillaryOnly=true} end
            end
        end
    end
    local function fitPath(rows)
        if #rows<6 then return nil,'TOO_FEW_FREE_FLIGHT_SAMPLES' end
        local first,last=rows[1],rows[#rows]
        local span=last[1]-first[1]
        if span<.25 then return nil,'FLIGHT_SPAN_TOO_SHORT' end
        local matrix={{0,0,0},{0,0,0},{0,0,0}}
        local rhs={{0,0,0},{0,0,0},{0,0,0}}
        for _,row in ipairs(rows) do
            local t=row[1]-first[1];local basis={1,t,t*t}
            for i=1,3 do
                for j=1,3 do matrix[i][j]=matrix[i][j]+basis[i]*basis[j] end
                for axis=1,3 do rhs[i][axis]=rhs[i][axis]+basis[i]*row[axis+1] end
            end
        end
        for col=1,3 do
            local pivot=col;for row=col+1,3 do if math.abs(matrix[row][col])>math.abs(matrix[pivot][col]) then pivot=row end end
            matrix[col],matrix[pivot]=matrix[pivot],matrix[col];rhs[col],rhs[pivot]=rhs[pivot],rhs[col]
            local scale=matrix[col][col];if math.abs(scale)<1e-9 then return nil,'FIT_SINGULAR' end
            for j=col,3 do matrix[col][j]=matrix[col][j]/scale end
            for axis=1,3 do rhs[col][axis]=rhs[col][axis]/scale end
            for row=1,3 do if row~=col then
                local a=matrix[row][col]
                for j=col,3 do matrix[row][j]=matrix[row][j]-a*matrix[col][j] end
                for axis=1,3 do rhs[row][axis]=rhs[row][axis]-a*rhs[col][axis] end
            end end
        end
        local error=0
        for _,row in ipairs(rows) do
            local t=row[1]-first[1]
            for axis=1,3 do local d=row[axis+1]-(rhs[1][axis]+rhs[2][axis]*t+rhs[3][axis]*t*t);error=error+d*d end
        end
        return {Samples=#rows,Span=span,RMS=math.sqrt(error/#rows),Gravity=-2*rhs[3][2],
            Velocity={rhs[2][1],rhs[2][2],rhs[2][3]},HorizontalAcceleration=2*math.sqrt(rhs[3][1]^2+rhs[3][3]^2)}
    end
    local function wilson(success,total)
        local z=1.96;local p=success/total;local q=1+z*z/total
        local middle=(p+z*z/(2*total))/q
        local radius=z*math.sqrt(p*(1-p)/total+z*z/(4*total*total))/q
        return middle-radius,middle+radius
    end
    function e.Evaluate(records,current,session)
        local function contextKey(context)
            if type(context)~='table' or context.Complete==false then return end
            if context.SignatureParts~=nil then
                if type(context.SignatureParts)~='table' or #context.SignatureParts<1 or #context.SignatureParts>8 then return end
                for _,part in ipairs(context.SignatureParts) do if type(part)~='string' or #part>90 then return end end
                return table.concat(context.SignatureParts)
            end
            if type(context.Signature)=='string' then return context.Signature end
        end
        local groups={};local rejected={};local badSettings={}
        local function settingKey(session,x,y,context) return table.concat({session or '',x,y,context or ''},':') end
        for _,record in ipairs(records or {}) do
            local p=type(record)=='table' and record.Kind=='throw' and record.Payload
            local o=type(p)=='table' and p.Observation
            if type(p)=='table' and p.Source=='AUTO_QB' and p.Mode=='Fit' and type(o)=='table'
                and o.Association=='EXACT_HELD_PART' and o.ObservedOutcome=='OPPONENT_POSSESSION_OBSERVED'
                and type(p.Lead)=='table' and finite(p.Lead[1]) and finite(p.Lead[2]) and type(p.NativeContext)=='table' then
                badSettings[settingKey(record.Session,p.Lead[1],p.Lead[2],contextKey(p.NativeContext))]=true
            end
        end
        local function reject(reason) rejected[reason]=(rejected[reason] or 0)+1 end
        for _,record in ipairs(records or {}) do
            local p=type(record)=='table' and record.Kind=='throw' and type(record.Payload)=='table' and record.Payload
            if p and p.Source=='AUTO_QB' and p.Mode=='Fit' and (not session or record.Session==session) then
                local o=p.Observation
                if type(o)~='table' then reject('NO_OBSERVATION')
                elseif o.Association~='EXACT_HELD_PART' then reject('BALL_IDENTITY_UNVERIFIED')
                elseif type(o.Quality)~='table' or o.Quality.PoseClassificationCalibrated~=true then reject('DIVE_POSE_UNCALIBRATED')
                elseif o.Quality.PhysicalPossessionWitness~=true then reject('POSSESSION_WELD_NOT_OBSERVED')
                elseif o.Quality.CleanComparison~=true then reject(o.Quality and o.Quality.Reason or 'QUALITY_UNKNOWN')
                elseif o.ObservedOutcome~='RECEIVER_POSSESSION_OBSERVED' then reject('OUTCOME_NOT_INTENDED_POSSESSION')
                elseif type(record.Session)~='string' or type(o.ReceiverToken)~='string' then reject('RECEIVER_CONTEXT_MISSING')
                elseif type(p.Lead)~='table' or not finite(p.Lead[1]) or not finite(p.Lead[2])
                    or type(p.LeadSettings)~='table' or type(p.LeadSettings.Fit)~='table'
                    or not contextKey(p.NativeContext)
                    or not finite(p.Power) or not finite(p.Time) or not finite(p.DistanceYards)
                    or type(o.Movement)~='table' then reject('SETTINGS_OR_MOVEMENT_CONTEXT_MISSING')
                else
                    -- These are matching/QC policies, never FF3 catch acceptance radii.
                    local matchKey=table.concat({record.Session,o.ReceiverToken,record.Release or '',p.Variant or p.Mode,p.PowerMethod or '',
                        string.format('%.3f',p.Power),math.floor(p.DistanceYards/10),math.floor(p.Time/.25),tostring(p.Jump),tostring(p.VerticalLeadControlActive),contextKey(p.NativeContext)},':')
                    local key=table.concat({matchKey,p.Lead[1],p.Lead[2]},':')
                    local g=groups[key]
                    if not g then g={matchKey=matchKey,X=p.Lead[1],Y=p.Lead[2],mode=p.Mode,variant=p.Variant,power=p.Power,distance=p.DistanceYards,
                        yActive=p.VerticalLeadControlActive,context=contextKey(p.NativeContext),session=record.Session,receiver=o.ReceiverToken,release=record.Release,n=0,desired=0,ids={}};groups[key]=g end
                    g.n=g.n+1
                    if o.Movement.JumpAtPossession==true and o.Movement.DiveSignalObserved==false and o.Movement.ContinuedRoute==true
                        and not o.Movement.ExcessHeightSignal then g.desired=g.desired+1 end
                    g.ids[#g.ids+1]=record.Id
                end
            end
        end
        local recommendations={}
        local fit=current and current.Fit
        if fit then
            for _,base in pairs(groups) do
                if base.X==fit.X and base.Y==fit.Y and base.n>=5 then
                    local _,baseHigh=wilson(base.desired,base.n)
                    for _,alt in pairs(groups) do
                        local dx,dy=alt.X-base.X,alt.Y-base.Y
                        if alt.n>=5 and alt.matchKey==base.matchKey and alt.context==base.context and alt.variant==base.variant and alt.session==base.session and alt.receiver==base.receiver and alt.release==base.release
                            and alt.power==base.power and alt.distance and base.distance and math.abs(alt.distance-base.distance)<=5
                            and ((dx==0 and base.yActive==true and alt.yActive==true and math.abs(dy)>0 and math.abs(dy)<=.5) or (dy==0 and math.abs(dx)>0 and math.abs(dx)<=.5)) then
                            local altLow=wilson(alt.desired,alt.n)
                            if altLow>baseHigh and badSettings[settingKey(alt.session,alt.X,alt.Y,alt.context)] then reject('ALTERNATIVE_HAS_OPPONENT_POSSESSION')
                            elseif altLow>baseHigh then
                                recommendations[#recommendations+1]={Mode='Fit',Axis=dx~=0 and 'X' or 'Y',From=dx~=0 and base.X or base.Y,
                                    To=dx~=0 and alt.X or alt.Y,CurrentDesired=base.desired,CurrentN=base.n,ComparedDesired=alt.desired,ComparedN=alt.n,
                                    CurrentIds=base.ids,ComparedIds=alt.ids,IntervalSeparation=altLow-baseHigh,
                                    Kind='OBSERVED_STYLE_ALTERNATIVE_NOT_CAUSAL_FAULT',RequiredMovement='UNKNOWN',CompletionEffect='UNPROVEN'}
                            end
                        end
                    end
                end
            end
        end
        local signs={}
        for _,a in ipairs(recommendations) do local sign=a.To>a.From and 1 or -1;if signs[a.Axis] and signs[a.Axis]~=sign then rejected.CONFLICTING_COMPARABLE_COHORTS=1;return {},rejected end;signs[a.Axis]=sign end
        table.sort(recommendations,function(a,b) if a.IntervalSeparation~=b.IntervalSeparation then return a.IntervalSeparation>b.IntervalSeparation end;return a.To<b.To end)
        return recommendations,rejected
    end
    function e.RefreshAdvice(force)
        if not force and os.clock()<(e.nextAdviceAt or 0) then return end;e.nextAdviceAt=os.clock()+1
        e.settings=e.ReadSettings()
        e.advice,e.rejected=e.Evaluate(controller.history.Records(),e.settings,controller.history.SessionKey())
    end
    local function compact(rows,limit)
        local out={};local step=math.max(1,math.ceil(#rows/limit))
        for i=1,#rows,step do out[#out+1]=rows[i] end
        if out[#out]~=rows[#rows] then out[#out+1]=rows[#rows] end
        return out
    end
    function e.SnapshotActive()
        local f=active
        if not f or #f.rows==0 or f.publishedSamples==#f.rows then return end
        f.publishedSamples=#f.rows
        controller.history.AttachObservation(f.throwId,{EndReason='IN_PROGRESS',Association=f.association or 'RELEASE_NOT_OBSERVED',
            ObservedOutcome='UNKNOWN',Fault='UNRESOLVED',RequiredMovement='UNKNOWN',ReceiverToken=f.receiverToken,
            Movement={JumpObserved=f.jumped,DiveSignalObserved=f.dive,RequiredMovement='UNKNOWN'},
            Quality={CleanComparison=false,PoseClassificationCalibrated=mappingVerified,Reason='FLIGHT_IN_PROGRESS'},
            Samples=compact(f.rows,24),PhysicsSamples=compact(f.path,24),
            SampleColumns={'t','bx','by','bz','rx','ry','rz','rvx','rvy','rvz','headY','grounded','state','diveLikePose','upY','torsoUpY','leftHandForward','rightHandForward','platformStand'},
            AnimationAssets=f.animationAssets,LastPose=f.lastPose,FirstDivePose=f.firstDivePose,ClosestApproach=f.closest})
    end
    local function finish(reason)
        local f=active;if not f then return end;active=nil
        local physicsRows=compact(f.path,24)
        local physics,fitReason=fitPath(physicsRows)
        local fittedSpeed=physics and math.sqrt(physics.Velocity[1]^2+physics.Velocity[3]^2)
        local speedError=fittedSpeed and math.abs(fittedSpeed-flat(f.shot.velocity).Magnitude)
        local speed=f.initialSpeed
        local movement={JumpObserved=f.jumped,JumpAtPossession=f.jumpAtPossession==true,JumpCount=f.jumpCount,JumpAt=f.jumpAt,DiveAt=f.diveAt,DiveSignalObserved=f.dive,AirborneBeforeThrow=f.airborneBefore,
            ContinuedRoute=f.maxTurn<=15 and f.minSpeedRatio>=.7 and f.observedTurn<=15 and f.observedRatio>=.7,InitialSpeed=f.initialSpeed,ObservedTurn=f.observedTurn,ObservedSpeedRatio=f.observedRatio,MaxRouteTurnDegrees=f.maxTurn,MinSpeedRatio=f.minSpeedRatio,
            MaxRise=f.maxRise,MinimumReceiverSpeed=f.minSpeed,ExcessHeightSignal=f.excessHeight,
            ObservedSequence=f.jumped and (f.dive and 'JUMP_AND_DIVE_LIKE_POSE' or 'JUMP_SIGNAL') or (f.dive and 'DIVE_LIKE_POSE_ONLY' or 'NO_JUMP_OR_DIVE_SIGNAL'),
            DiveEvidence=mappingVerified and 'CONTROLLED_POSE_CALIBRATION' or 'AIRBORNE_BODY_HAND_POSE_UNCALIBRATED',RequiredMovement='UNKNOWN',CatchInput='UNOBSERVABLE',AnglingTechnique='UNVERIFIED; NOMINAL_HEIGHT_COMPARISON_ONLY'}
        local clean=f.association=='EXACT_HELD_PART' and physics~=nil and physics.RMS<=.35
            and math.abs(physics.Gravity-CFG.Gravity)<=3 and physics.HorizontalAcceleration<=3 and speedError<=3
            and not f.changed and (not f.poseUnknown or f.diveVerified) and f.physicalPossession and not f.airborneBefore and not f.diveBefore and f.jumpCount<=1 and f.maxGap<=.25
            and f.maxTurn<=15 and f.minSpeedRatio>=.7 and f.observedTurn<=15 and f.observedRatio>=.7 and not f.excessHeight and f.nearestDB>15
        local qcReason=clean and 'OBSERVATIONAL_QC_PASSED' or f.changed and 'RECEIVER_OR_CONTEXT_CHANGED'
            or f.association~='EXACT_HELD_PART' and 'BALL_IDENTITY_UNVERIFIED'
            or f.airborneBefore and 'AIRBORNE_BEFORE_THROW' or f.diveBefore and 'DIVE_ACTIVE_BEFORE_THROW' or f.jumpCount>1 and 'REPEATED_JUMP_SIGNALS' or f.maxGap>.25 and 'SAMPLE_GAP'
            or (f.maxTurn>15 or f.observedTurn>15) and 'ROUTE_CHANGED' or (f.minSpeedRatio<.7 or f.observedRatio<.7) and 'RECEIVER_SLOWED'
            or (f.poseUnknown and not f.diveVerified) and 'POSE_CHANNEL_UNCLASSIFIED' or not f.physicalPossession and 'POSSESSION_WELD_NOT_OBSERVED'
            or f.nearestDB<=15 and 'DEFENDER_NEARBY_QC' or fitReason or 'PHYSICS_OR_EXTRA_HEIGHT_UNRESOLVED'
        local observation={EndReason=reason,Association=f.association or 'RELEASE_NOT_OBSERVED',ObservedOutcome=f.outcome or 'UNKNOWN',
            Fault='UNRESOLVED',RequiredMovement='UNKNOWN',Movement=movement,ReceiverToken=f.receiverToken,Quality={CleanComparison=clean==true,PoseClassificationCalibrated=mappingVerified,PhysicalPossessionWitness=f.physicalPossession==true,Reason=qcReason},
            SampleColumns={'t','bx','by','bz','rx','ry','rz','rvx','rvy','rvz','headY','grounded','state','diveLikePose','upY','torsoUpY','leftHandForward','rightHandForward','platformStand'},Samples=compact(f.rows,24),PhysicsSamples=physicsRows,CriticalFrames={MaxTurn=f.maxTurnAt,MinSpeed=f.minSpeedAt,Apex=f.apexAt,JumpEvents=f.jumpEvents},
            FreeFlightSamples=#f.path,Physics=physics,SpeedModelDifference=speedError,PhysicsReason=fitReason,ClosestApproach=f.closest,MaxSampleGap=f.maxGap,
            NearestDefenderToReceiver=f.nearestDB<1e6 and f.nearestDB or nil,AnimationAssets=f.animationAssets,LastPose=f.lastPose,FirstDivePose=f.firstDivePose,PoseCalibrationReference=poseCalibration and poseCalibration.Reference,Attribution='MOVEMENT_AND_GEOMETRY_ONLY; INTENT_AND_CATCH_WINDOW_UNKNOWN'}
        controller.history.AttachObservation(f.throwId,observation)
        e.last=observation;e.status=reason;e.observations=e.observations+1;e.candidates={};e.RefreshAdvice(true)
        observation.Advisor={Alternatives=e.advice,Rejected=e.rejected,Scope='CURRENT_SESSION_FIT_STYLE_ONLY; OBSERVATIONAL_NOT_CAUSAL'}
        controller.history.AttachObservation(f.throwId,observation)
    end
    function e.Begin(ball,player,shot,throwId)
        if not e.enabled or e.disabled then return end
        if active then finish('NEW_REQUEST') end
        if not throwId or not player or not shot.appliedLead then return end
        local p=pose(player);if not p then return end
        local aliases=env.PELICAN_FF3_RECEIVER_ALIASES
        if type(aliases)~='table' or aliases.job~=game.JobId then aliases={job=game.JobId,players=setmetatable({}, {__mode='k'}),n=0};env.PELICAN_FF3_RECEIVER_ALIASES=aliases end
        if not aliases.players[player] then aliases.n=aliases.n+1;aliases.players[player]='R'..aliases.n end
        local handle=ball.tool:FindFirstChild('Handle')
        local speed=flat(p.v).Magnitude
        local jump=p.hum.UseJumpPower~=false and finite(p.hum.JumpPower) and p.hum.JumpPower^2/(2*workspace.Gravity)
            or finite(p.hum.JumpHeight) and p.hum.JumpHeight or nil
        active={at=os.clock(),throwId=throwId,receiverToken=aliases.players[player],player=player,model=p.model,team=player.Team,qbModel=ball.model,handle=handle,
            shot=shot,rows={},path={},initial=p,initialSpeed=speed,route=speed>0 and flat(p.v).Unit or V(),
            minSpeedRatio=1,minSpeed=speed,maxTurn=0,maxRise=0,maxGap=0,jumpCount=0,jumpEvents={},motion={},observedTurn=0,observedRatio=1,lastAt=os.clock(),jumped=false,dive=false,
            airborneBefore=not p.grounded,wasGrounded=p.grounded,normalJump=jump,excessHeight=false,
            animationAssets={},nearestDB=1e6,ground=lines.ground,generation=lines.generation}
        animations(active,p);active.diveBefore=observePose(active,p);active.dive=active.diveBefore
        e.candidates={};e.candidateSet=setmetatable({}, {__mode='k'});e.status='OBSERVING_RECEIVER';e.nextAt=0
    end
    function e.Update(now)
        if e.disabled then return end
        if now<e.nextAt then return end;e.nextAt=now+.08
        if not active then
            if e.panel and e.panel.Visible then e.RefreshAdvice();e.Paint() end
            return
        end
        local begun=os.clock();local f=active;local p=pose(f.player)
        if not p or p.model~=f.model or f.player.Team~=f.team or f.qbModel~=me.Character or lines.ground~=f.ground then
            f.changed=true;finish('ACTOR_OR_FIELD_CHANGED');return
        end
        local elapsed=now-f.at
        f.maxGap=math.max(f.maxGap,now-f.lastAt);f.lastAt=now
        f.motion[#f.motion+1]={at=now,p=p.p};if #f.motion>4 then table.remove(f.motion,1) end
        local first=f.motion[1];local span=now-first.at
        if span>=.2 and f.initialSpeed>0 then
            local observed=flat(p.p-first.p)/span;f.observedRatio=math.min(f.observedRatio,observed.Magnitude/f.initialSpeed)
            if observed.Magnitude>0 then f.observedTurn=math.max(f.observedTurn,math.deg(math.acos(clamp(observed.Unit:Dot(f.route),-1,1)))) end
        end
        local horizontal=flat(p.v);local speed=horizontal.Magnitude
        if speed<f.minSpeed then f.minSpeed=speed;f.minSpeedAt={At=elapsed,Velocity=vec(p.v)} end
        if f.initialSpeed>0 then f.minSpeedRatio=math.min(f.minSpeedRatio,speed/f.initialSpeed) end
        if speed>0 and f.initialSpeed>0 then
            local turn=math.deg(math.acos(clamp(horizontal.Unit:Dot(f.route),-1,1)))
            if turn>f.maxTurn then f.maxTurn=turn;f.maxTurnAt={At=elapsed,Velocity=vec(p.v)} end
        end
        local rise=p.p.Y-f.initial.p.Y
        if rise>f.maxRise then f.maxRise=rise;f.apexAt={At=elapsed,Position=vec(p.p),VerticalVelocity=p.v.Y} end
        -- Tiny positive replicated velocity is not an ascent. PlatformStanding
        -- with ~0 vertical motion previously produced a false jump signal.
        if f.wasGrounded and not p.grounded then f.pendingAscent=elapsed end
        if p.grounded then f.pendingAscent=nil end
        local newJump=p.v.Y>1 and (p.state=='Jumping' and f.lastState~='Jumping'
            or f.pendingAscent and elapsed-f.pendingAscent<=.3)
        if newJump then
            f.pendingAscent=nil
            f.jumped=true;f.jumpCount=f.jumpCount+1;f.jumpAt=elapsed
            if #f.jumpEvents<4 then f.jumpEvents[#f.jumpEvents+1]={At=elapsed,State=p.state,VerticalVelocity=p.v.Y} end
        end
        f.lastState=p.state
        f.wasGrounded=p.grounded
        if f.normalJump and rise>f.normalJump+1 then f.excessHeight=true end
        animations(f,p);local dive,bodyPose=observePose(f,p);if dive and not f.dive then f.diveAt=elapsed end;f.dive=f.dive or dive
        local roster=Players:GetPlayers();if #roster>CFG.MaxRoster then f.changed=true;finish('ROSTER_CAP');return end
        for _,other in ipairs(roster) do
            if other.Team and not other.Neutral and other.Team~=f.team then
                local _,root=body(other);if root then f.nearestDB=math.min(f.nearestDB,(root.Position-p.p).Magnitude) end
            end
        end
        local part=f.part
        if not part then
            local same=f.handle
            if instance(same,'BasePart') and same.Parent then
                local carrier,why=owner(same)
                if not carrier and not why and not same:IsDescendantOf(f.qbModel) and same.AssemblyLinearVelocity.Magnitude>1 then
                    part=same;f.part=part;f.association='EXACT_HELD_PART'
                end
            end
            if not part and elapsed<=1 then
                local candidates={}
                for _,candidate in ipairs(e.candidates) do
                    if candidate.Parent and candidate.AssemblyLinearVelocity.Magnitude>1 and (candidate.Position-f.shot.origin).Magnitude<100 then
                        local carrier,why=owner(candidate)
                        if not carrier and not why then candidates[#candidates+1]=candidate end
                    end
                end
                if #candidates==1 then f.part=candidates[1];part=f.part;f.association='CLONE_CANDIDATE_UNVERIFIED'
                elseif #candidates>1 then f.ambiguous=true end
            end
        end
        local point=part and part.Parent and part.Position
        if point and not vector(point) then f.changed=true;finish('INVALID_BALL_POSITION');return end
        if #f.rows<80 then f.rows[#f.rows+1]={round(elapsed),point and round(point.X) or false,point and round(point.Y) or false,point and round(point.Z) or false,
            round(p.p.X),round(p.p.Y),round(p.p.Z),round(p.v.X),round(p.v.Y),round(p.v.Z),round(p.head.Position.Y),p.grounded,p.state,dive,p.up or false,bodyPose.TorsoUpY or false,bodyPose.LeftHandForward or false,bodyPose.RightHandForward or false,bodyPose.PlatformStand} end
        if point then
            local carrier,why=owner(part)
            if why then f.changed=true;finish(why);return end
            if carrier then
                if carrier==f.player and f.departed then
                    f.ownerSamples=(f.ownerSamples or 0)+1
                    if f.ownerSamples>=2 then
                        local airtime=f.normalJump and 2*math.sqrt(2*f.normalJump/workspace.Gravity) or 0
                        f.jumpAtPossession=f.jumped and not p.grounded and f.jumpAt and elapsed-f.jumpAt<=airtime+.16
                        local connectedOK,parts=pcall(function() return part:GetConnectedParts(false) end)
                        if connectedOK and type(parts)=='table' then
                            for i=1,math.min(#parts,64) do
                                local other=parts[i]
                                if other~=part and other.Parent==f.model and instance(other,'BasePart') then f.physicalPossession=true;break end
                            end
                        end
                        f.outcome='RECEIVER_POSSESSION_OBSERVED';finish('OBSERVED_CARRIER');return end
                elseif carrier~=me and f.departed then
                    f.outcome=carrier.Team==f.team and 'OTHER_TEAMMATE_POSSESSION_OBSERVED' or 'OPPONENT_POSSESSION_OBSERVED';finish('OTHER_CARRIER');return
                end
            else
                f.ownerSamples=0;f.departed=true
                if #f.path<80 then f.path[#f.path+1]={elapsed,point.X,point.Y,point.Z} end
                local relative=point-p.head.Position;local distance=relative.Magnitude
                if not f.closest or distance<f.closest.Distance then f.closest={At=elapsed,Distance=distance,AlongRoute=flat(relative):Dot(f.route),
                    VerticalToHead=relative.Y,ReceiverGrounded=p.grounded,ReceiverVerticalVelocity=p.v.Y} end
                local ground=f.ground
                if ground and point.Y<ground.Position.Y+ground.Size.Y*.5 then f.outcome='BELOW_GROUND_GEOMETRY_OBSERVED';finish('GROUND_GEOMETRY');return end
            end
        elseif f.part then finish('BALL_REMOVED');return end
        if f.ambiguous then f.association='AMBIGUOUS_CLONES' end
        if elapsed>math.min(7,math.max(2,f.shot.time+1.5)) or #f.rows>=80 then finish('OBSERVATION_LIMIT') end
        e.maxSeconds=math.max(e.maxSeconds,os.clock()-begun)
        if e.panel and e.panel.Visible then e.Paint() end
    end
    function e.Stop(reason)
        local ok=pcall(function() if active then finish(reason or 'STOPPED') end end)
        active=nil;e.candidates={}
        if not ok then e.disabled=true;e.status='CAPTURE_FINALIZE_ERROR_DISABLED' end
        return true
    end
    function e.Disable(reason) e.disabled=true;e.Stop(reason);e.status=reason or 'CAPTURE_ERROR_DISABLED' end
    function e.Paint()
        if not e.panel or os.clock()<(e.nextPaintAt or 0) then return end;e.nextPaintAt=os.clock()+.25
        e.settings=e.ReadSettings()
        local rows={'LEADS (read only)'}
        for _,mode in ipairs({'Bullet','Fit','Jump','Dive','Dime'}) do
            local v=e.settings[mode]
            rows[#rows+1]=mode..(v and string.format('  X %.9g  Y %.9g',v.X,v.Y) or '  not verified')
        end
        local advice=e.advice[1]
        rows[#rows+1]=advice and string.format('Observed Fit %s: %.9g -> %.9g',advice.Axis,advice.From,advice.To) or (mappingVerified and 'Advice: insufficient matched evidence' or 'Advice held: dive pose uncalibrated')
        if advice then rows[#rows+1]='Style only; catch benefit unproven' end
        rows[#rows+1]=e.last.Movement and e.last.Movement.ObservedSequence or e.status
        if e.last.ClosestApproach then
            local gap=e.last.ClosestApproach
            rows[#rows+1]=string.format('Ball %.2f along run; %.2f vs head',gap.AlongRoute,gap.VerticalToHead)
        end
        rows[#rows+1]='Required action / fault: unknown'
        e.panel.Text=table.concat(rows,'\n')
    end
    function e.Report()
        local rows={'RECEIVER_EVIDENCE|'..e.status,'RECEIVER_OBSERVATIONS|'..e.observations,
            'RECEIVER_OBSERVER_MAX_SECONDS|'..string.format('%.6f',e.maxSeconds),'RECEIVER_REQUIRED_ACTION|UNKNOWN; OBSERVED_ACTION_IS_NOT_NECESSITY',
            'RECEIVER_FAULT|UNRESOLVED; REMOTE_INPUT_INTENT_UNAVAILABLE','DIVE_CLASSIFICATION|'..(mappingVerified and 'CONTROLLED_POSE_CALIBRATION' or 'UNCALIBRATED; BODY_AND_HAND_POSE_ONLY'),'LEAD_ADVICE_POLICY|READ_ONLY; PREVIOUSLY_OBSERVED_SINGLE_AXIS_FIT_ALTERNATIVES_ONLY; CONDITIONAL_ON_CATCHES; NOT_CAUSAL'}
        if e.last.Movement then
            rows[#rows+1]='LAST_RECEIVER_ACTION|'..e.last.Movement.ObservedSequence
            rows[#rows+1]='LAST_OBSERVED_OUTCOME|'..e.last.ObservedOutcome
            rows[#rows+1]='LAST_CAPTURE_QC|'..e.last.Quality.Reason
        end
        for mode,lead in pairs(e.ReadSettings()) do rows[#rows+1]=string.format('CURRENT_LEAD|%s X=%.9g Y=%.9g',mode,lead.X,lead.Y) end
        for reason,n in pairs(e.rejected) do rows[#rows+1]='LEAD_EVIDENCE_REJECT|'..reason..' '..n end
        for i,a in ipairs(e.advice) do if i>3 then break end
            rows[#rows+1]=string.format('LEAD_STYLE_ALTERNATIVE|%s.%s %.9g -> %.9g observed=%d/%d compared=%d/%d; REQUIRED_MOVEMENT_UNKNOWN; COMPLETION_EFFECT_UNPROVEN',a.Mode,a.Axis,a.From,a.To,a.CurrentDesired,a.CurrentN,a.ComparedDesired,a.ComparedN)
            rows[#rows+1]='LEAD_SUPPORT_CURRENT|'..table.concat(a.CurrentIds,',')
            rows[#rows+1]='LEAD_SUPPORT_COMPARED|'..table.concat(a.ComparedIds,',')
        end
        return table.concat(rows,'\n')
    end
    e.FitPath=fitPath
    return e
end)()
-- END RECEIVER EVIDENCE

local function releaseNow(ball,selected,defenders,now,preJump)
    if not sequence or sequence.player~=selected.player or sequence.epoch~=possession.epoch then return end
    local _,qr,qh=body(me)
    controller.bad:final(possession.epoch,now,qr and {name='QB',p=qr.Position,v=qr.AssemblyLinearVelocity,head=qh},
        controller.unified.Settings(),selected.shot.variant or selected.shot.mode)
    local receipt={stage='FINAL_CONTEXT_CHECK',mode=selected.shot.mode,variant=selected.shot.variant}
    sequence.blockEvidence=receipt
    if usedTools[ball.tool]==possession.epoch then setGate('REQUEST_ALREADY_ATTEMPTED'); return end
    if receiverMenu and receiverMenu.Visible then setGate('RECEIVER_MENU_OPEN'); return end
    local current,reason=ready()
    if not current or current.tool~=ball.tool then setGate(reason or 'POSSESSION_CHANGED'); return end
    if current.nativeThrow then setGate('NATIVE_MANUAL_THROW_IN_PROGRESS'); return end
    if not readLines(now) then releaseChoice(); setGate(lines.status); return end
    if controller.field.QBPast(current.root) then setGate('QB_PAST_LOS'); return end
    local eligible,rejection=receiverReady(selected.player,selected.sample,now)
    if not eligible then releaseChoice(); setGate(rejection); return end
    local activeSequence=sequence
    local fitVariant=selected.shot.fitAlternativeVariant
    local fitComparison,fitSecond,why
    if selected.shot.mode=='Fit' or (selected.shot.jumpBullet or selected.shot.nativeCoverageJump) then
        if selected.shot.jumpBullet or selected.shot.nativeCoverageJump then fitVariant='Bullet' end
        if not fitVariant then setGate('FIT_TIMING_COMPARISON_MISSING');return end
        fitComparison,why=solve(selected.player,fitVariant)
        if stopped or sequence~=activeSequence then return end
        if not fitComparison then setGate(why or 'FIT_TIMING_COMPARISON_FAILED');return end
    end
    if selected.shot.mode=='Fit' and selected.shot.fitSecondVariant then
        fitSecond,why=solve(selected.player,selected.shot.fitSecondVariant)
        if stopped or sequence~=activeSequence then return end
        if not fitSecond then setGate(why or 'FIT_SECOND_COMPARISON_FAILED');return end
    end
    -- Solve the actual throw last so the native preview/captures and pose
    -- reference describe the released candidate, not its counterfactual.
    receipt.stage='FINAL_NATIVE_SOLVE'
    local shot;shot,why,receipt.failure=solve(selected.player,selected.shot.variant or selected.shot.mode)
    if shot then receipt.shot=shot;receipt.stage='FINAL_TUPLE_NOT_GRADED';controller.bad.current.Final.Native=controller.bad:trajectory(shot) end
    if stopped or sequence~=activeSequence then return end
    if not shot then controller.bad.current.Final.NativeFailure=why;setGate(why);return end
    if os.clock()-now>.28 then setGate('DECISION_STALE_AFTER_NATIVE_SOLVER'); return end
    if not readLines(os.clock()) then releaseChoice(); setGate(lines.status); return end
    local receiver,freshDefenders,changed=currentDefenders(selected.player,os.clock())
    if not receiver or not freshDefenders then setGate(changed or 'PLAYER_OBSERVATIONS_CHANGED');return end
    selected.sample,defenders=receiver,freshDefenders
    if fitComparison and fitComparison.variant=='Bullet' then receiver.chestReference=fitComparison end
    eligible,rejection=receiverReady(selected.player,selected.sample,os.clock(),shot.arrival)
    if not eligible then releaseChoice(); setGate(rejection); return end
    eligible,rejection=receivePossible(shot,selected.sample)
    if not eligible then releaseChoice(); setGate(rejection); return end
    risk(shot,selected.sample,defenders); coverage(shot,selected.sample,defenders)
    receipt.stage='FINAL_CURRENT_COVERAGE'
    if shot.mode=='Fit' then
        if not receiverReady(selected.player,receiver,os.clock(),fitComparison.arrival) or not receivePossible(fitComparison,receiver)
            or (current.head.Position-fitComparison.launchHead).Magnitude>.5 then setGate('FIT_COMPARISON_CHANGED');return end
        risk(fitComparison,receiver,defenders);coverage(fitComparison,receiver,defenders)
        if fitSecond then
            if not receiverReady(selected.player,receiver,os.clock(),fitSecond.arrival) or not receivePossible(fitSecond,receiver)
                or (current.head.Position-fitSecond.launchHead).Magnitude>.5 then setGate('FIT_SECOND_COMPARISON_CHANGED');return end
            risk(fitSecond,receiver,defenders);coverage(fitSecond,receiver,defenders)
        end
        controller.fit.assess(shot,controller.fit.alternatives(selected.player,receiver,defenders,os.clock(),fitComparison,fitSecond),fitComparison.variant)
        if not shot.fitAllowed or shot.fitAlternativeVariant~=fitComparison.variant then setGate('FIT_TIMING_RESCUE_NO_LONGER_VALID');return end
    end
    if (shot.jumpBullet or shot.nativeCoverageJump) then
        if not receiverReady(selected.player,receiver,os.clock(),fitComparison.arrival) or not receivePossible(fitComparison,receiver)
            or (current.head.Position-fitComparison.launchHead).Magnitude>.5 then setGate('JUMP_BULLET_COMPARISON_CHANGED');return end
        risk(fitComparison,receiver,defenders);coverage(fitComparison,receiver,defenders)
        if not controller.jumpBullet.assess(shot,controller.fit.alternatives(selected.player,receiver,defenders,os.clock(),fitComparison,nil,true)) then
            setGate(shot.jumpBulletReason);return
        end
    end
    if shot.safetyOverTop and shot.mode~='Bullet' then setGate('SAFETY_OVER_TOP'); return end
    if not throwable(shot) then setGate(shot.unified and shot.unified.Reason or shot.safetyRead and shot.safetyRead.High and shot.mode~='Bullet' and 'SAFETY_HIGH_BULLET_ONLY' or shot.planAllowed==false and shot.planReason or shot.powerAllowed==false and (shot.powerReason or 'BULLET_COMFORT_UNAVAILABLE') or 'DEFENDER_INTERCEPTION_RISK'); return end
    local _,receiverRoot=body(selected.player)

    if not throwing or not auto or not ownsLock() or not teammate(selected.player) or not controller.receiverFilter.allowed(selected.player) or receiverMenu and receiverMenu.Visible then return end
    if shot.magTrial and not controller.mag.Allowed(selected.player) then setGate('MAG_TRUST_REVOKED');return end
    current,reason=ready()
    if not current or current.tool~=ball.tool or current.remote~=ball.remote then setGate(reason or 'POSSESSION_CHANGED'); return end
    if current.nativeThrow then setGate('NATIVE_MANUAL_THROW_IN_PROGRESS'); return end
    if controller.field.QBPast(current.root) then releaseChoice(); setGate('QB_PAST_LOS'); return end
    if current.model~=shot.qbModel or (current.head.Position-shot.launchHead).Magnitude>.5 then
        setGate('QB_LAUNCH_POSE_CHANGED_REPLAN');return
    end
    if preJump then return true end
    local unit=shot.velocity.Unit
    -- Readable live InputBegan request, exactly: Vector3.new(70000000) is X only.
    -- No retry: FireServer acceptance does not confirm a throw or server state.
    controller.bad:released(shot)
    usedTools[ball.tool]=possession.epoch; attempts=attempts+1
    pending={tool=ball.tool,model=ball.model,target=selected.player.Name,mode=shot.mode,at=now,outcome='REQUESTING',source='AUTO_QB'}
    classify(shot,selected.sample,defenders)
    local evidence=string.format('%s %s %s t=%.3f power=%.2f arrival=%.2f,%.2f,%.2f margin=%.2f lane=%.2f residual=%.2f',
        selected.player.Name,(shot.variant or shot.mode),shot.window,shot.time,shot.power,shot.arrival.X,shot.arrival.Y,shot.arrival.Z,
        shot.margin,shot.lane,shot.receiverResidual)
    local lastDecision={summary=evidence,actors={},release=string.format('risk=%s distanceYards=%.2f clearBurn=%s safetyOverTop=%s qbY=%.3f qbVy=%.3f jump=%s animation=%s; VISUAL_AFTER_REQUEST',riskPolicy.mode,shot.passYards,tostring(shot.clearBurn),tostring(shot.safetyOverTop),current.root.Position.Y,current.root.AssemblyLinearVelocity.Y,assistance.jumpStatus,animationStatus)}
    local function actor(name,s)
        return string.format('%s p=%.2f,%.2f,%.2f v=%.2f,%.2f,%.2f runSpeed=%.2f',
            name,s.p.X,s.p.Y,s.p.Z,s.v.X,s.v.Y,s.v.Z,runSpeed(s))
    end
    lastDecision.actors[1]=actor('WR',selected.sample)
    lastDecision.trajectory=string.format('origin=%.3f,%.3f,%.3f velocity=%.3f,%.3f,%.3f gravity=%.2f',shot.origin.X,shot.origin.Y,shot.origin.Z,shot.velocity.X,shot.velocity.Y,shot.velocity.Z,CFG.Gravity)
    lastDecision.inputs=string.format('referenceHead=%.3f,%.3f,%.3f sendHead=%.3f,%.3f,%.3f lead=%.3f,%.3f ping=%s nativeSolveAge=%.6f',
        shot.launchHead.X,shot.launchHead.Y,shot.launchHead.Z,current.head.Position.X,current.head.Position.Y,current.head.Position.Z,
        shot.appliedLead.X,shot.appliedLead.Y,tostring(shot.networkPing),os.clock()-shot.at)
    lastDecision.inputs=lastDecision.inputs..' nativeMode='..shot.nativeMode..' fitReason='..tostring(shot.fitReason)
        ..' fitCompared='..tostring(shot.fitAlternativeVariant)..' comparedTime='..tostring(shot.fitAlternativeTime)..' comparedDBETA='..tostring(shot.fitAlternativeDB)..' dbETA='..tostring(shot.defenderETA)
        ..' powerMethod='..shot.powerMethod..' requestedPower='..tostring(shot.requestedPower)..' powerAllowed='..tostring(shot.powerAllowed)
        ..' manualInput='..tostring(shot.nativeInput)..' inputKind='..shot.nativeInputKind
        ..' magTrial='..tostring(shot.magTrial)..' magExtraY='..tostring(shot.magExtraY)..' magTrustSource='..tostring(shot.magTrustSource)
        ..' actualAngle='..tostring(shot.actualAngle)..' angleReason='..tostring(shot.angleControl and shot.angleControl.reason)
    lastDecision.candidates={}
    for _,candidate in ipairs(candidateEvidence) do lastDecision.candidates[#lastDecision.candidates+1]=candidate end
    for i,d in ipairs(defenders) do lastDecision.actors[#lastDecision.actors+1]=actor('DB'..i..':'..clean(d.name),d) end
    decisionHistory[#decisionHistory+1]=lastDecision
    if #decisionHistory>6 then table.remove(decisionHistory,1) end
    if sequence and sequence.jumpObservedAt then
        sequence.jumpObservedDelay=os.clock()-sequence.jumpObservedAt;controller.jumpTiming.lastReleaseDelay=sequence.jumpObservedDelay
    end
    log('REQUEST',evidence)
    local ok,err=pcall(function()
        ball.remote:FireServer('Clicked',shot.origin-unit*5+V(70000000,0,0),shot.origin+unit*10000,shot.power,1)
    end)
    local throwId=controller.history.Shot(shot,selected.player,selected.sample,ok and 'API_ACCEPTED_UNCONFIRMED' or 'AMBIGUOUS_NO_RETRY','AUTO_QB',defenders)
    if not throwId then throwId='bad:'..controller.bad.current.Id end
    controller.bad:sent(throwId,ok and 'API_ACCEPTED_UNCONFIRMED' or 'AMBIGUOUS_NO_RETRY',os.clock())
    if ok then
        local observed,why=pcall(controller.receiverEvidence.Begin,ball,selected.player,shot,throwId)
        if not observed then controller.receiverEvidence.Disable('CAPTURE_START_ERROR_DISABLED');log('RECEIVER_OBSERVER_ERROR',why) end
    end
    if ok then sent=sent+1; pending.outcome='API_ACCEPTED_UNCONFIRMED'; setGate('REQUEST_SENT_UNCONFIRMED')
    else
        ambiguous=ambiguous+1; pending.outcome='AMBIGUOUS_NO_RETRY'; fatalError=clean(err)
        log('REQUEST_ERROR',err); controller.Stop('REQUEST_AMBIGUOUS_NO_RETRY'); return
    end
    -- Visual playback starts after the packet. It never feeds back into native
    -- aim/lead/origin or introduces an animation/peak wait before release.
    local animationOK,animationError=pcall(visual.play,sequence and sequence.animation)
    if not animationOK then
        fatalError=clean(animationError);log('POST_REQUEST_ANIMATION_ERROR',animationError)
        controller.Stop('POST_REQUEST_ANIMATION_ERROR');return
    end
    preserve(false)
end
local function abortPreparedBurn(seq,reason)
    log('BURN_CANCEL',seq.player.Name..' '..reason..'; REPLAN_ALLOWED')
    cancelSequence(reason);releaseChoice();setGate(reason)
end
local function driveSequence(now)
    local seq=sequence
    if not seq then return end
    local ball,why=ready()
    if not profile or not aliveConnection(profile.preview) or not aliveConnection(profile.release) then
        cancelSequence('WAIT_YUNA_SOURCE_PROFILE');releaseChoice();setGate('WAIT_YUNA_SOURCE_PROFILE');return
    end
    if not ball or ball.nativeThrow or not throwing or not choice or choice.player~=seq.player
        or seq.model~=seq.player.Character or seq.qbModel~=ball.model or seq.hum~=ball.hum
        or seq.epoch~=possession.epoch or seq.tool~=ball.tool
        or not teammate(seq.player) or receiverMenu and receiverMenu.Visible then
        cancelSequence(why or 'RELEASE_CONTEXT_CHANGED'); return
    end
    if seq.deep then
        local grounded=ball.hum.FloorMaterial~=Enum.Material.Air
        local canRequest=grounded and ball.hum.Jump~=true and now>=(seq.nextJumpCheckAt or 0) and
            (assistance.jumpEpoch~=possession.epoch or now-assistance.jumpRequestedAt>=.25)
        if canRequest then
            local passed=releaseNow(ball,seq.selected,{},now,true)
            controller.bad:prejump(passed==true)
            if stopped or sequence~=seq then return end
            if not passed then cancelSequence('PREJUMP_WINDOW_CHANGED');cancelJump('PREJUMP_CANCELLED');return end
            seq.preJumpCheckedAt=now;seq.nextJumpCheckAt=now+.25
            requestJump(ball,now)
            return -- fresh final native solve after physics, on its own budget
        end
    end
    if not controller.jumpTiming.Wait(seq,ball,now) then return end
    if not seq.animationStarted then seq.animation=visual.prepare(ball,now);seq.animationStarted=true end
    if stopped or sequence~=seq then return end
    local receiver,defenders,rejection=currentDefenders(seq.player,now)
    if not receiver or not defenders then cancelSequence(rejection or 'RECEIVER_OBSERVATION_LOST');setGate(rejection or 'RECEIVER_OBSERVATION_LOST');return end
    seq.selected.sample=receiver
    releaseNow(ball,seq.selected,defenders,now)
    if stopped or sequence~=seq then return end
    if usedTools[ball.tool]==possession.epoch then sequence=nil;lastSequenceOutcome='API_ACCEPTED_UNCONFIRMED'
    elseif gate=='NATIVE_FRAME_BUDGET' or gate=='QB_LAUNCH_POSE_CHANGED_REPLAN' or gate=='DECISION_STALE_AFTER_NATIVE_SOLVER' then
        setGate('JUMP_FINAL_REPLAN') -- no request was sent; keep observed takeoff
    else
        local evidence=seq.blockEvidence
        rememberBlocked(seq.player,evidence and evidence.shot,gate,evidence)
        cancelSequence('FINAL_RELEASE_CHECK_BLOCKED');cancelJump('RELEASE_CANCELLED')
        opportunities[seq.player]=nil;shotCache[seq.player]=nil
    end
end
local function submit(ball,selected,defenders,now)
    local fastBurn=selected.shot.clearBurn==true
    local deep=deepThrow(selected.shot,ball.hum)
    if sequence and (sequence.player~=selected.player or sequence.model~=selected.player.Character
        or sequence.epoch~=possession.epoch or sequence.deep~=deep) then cancelSequence('TARGET_OR_TRAJECTORY_CHANGED') end
    if not sequence then
        local velocity=flat(selected.sample.v)
        sequence={player=selected.player,model=selected.player.Character,qbModel=ball.model,hum=ball.hum,tool=ball.tool,epoch=possession.epoch,
            selected=selected,fastBurn=fastBurn,deep=deep,route=velocity.Magnitude>0 and velocity.Unit or V(),checked=now,started=now}
        lastSequenceOutcome='PREPARING'
        log('PREPARE',selected.player.Name..' '..(deep and (controller.jumpTiming.delay>0 and 'DEEP_JUMP_SHORT_OFFSET' or 'DEEP_JUMP_IMMEDIATE') or 'SHORT_IMMEDIATE'))
    else sequence.selected=selected end
    driveSequence(now)
end

do
    local r=controller.reactivity
    local function hint(hum)
        local v=hum.MoveDirection
        if vector(v) and v.Magnitude>.1 and v.Magnitude<=1.1 then return flat(v) end
    end
    function r.Capture(receivers,defenders,now)
        if not r.enabled then return end
        local watch={at=now,epoch=possession.epoch,generation=lines.generation,team=me.Team}
        local seen={}
        local function add(s,defender)
            if s and s.root and s.hum and not seen[s.model] then
                seen[s.model]=true;watch[#watch+1]={player=Players:GetPlayerFromCharacter(s.model),model=s.model,root=s.root,hum=s.hum,p=s.p,v=s.v,hint=hint(s.hum),defender=defender}
            end
        end
        for _,candidate in ipairs(receivers) do if choice and candidate.player==choice.player then add(candidate.sample,false);break end end
        for _,candidate in ipairs(receivers) do if #watch>=2 then break end;add(candidate.sample,false) end
        local receiverCount=#watch
        for _,d in ipairs(defenders) do
            if choice and choice.shot and (d==choice.shot.marginActor or d==choice.shot.laneActor) then add(d,true) end
        end
        for _,d in ipairs(defenders) do if #watch-receiverCount>=6 then break end;add(d,true) end
        r.watch=watch;r.status='BOUNDED_MOTION_WATCH'
    end
    function r.Wake(now)
        local w=r.watch
        if not r.enabled or now<r.nextAt or stopped or not auto or not throwing or sequence or pending
            or not w or now-w.at>CFG.CacheAge or w.epoch~=possession.epoch or w.generation~=lines.generation or w.team~=me.Team then return false end
        r.nextAt=now+.05;r.checks=r.checks+1
        for _,s in ipairs(w) do
            if not s.player or s.player.Character~=s.model or s.player.Neutral or not s.player.Team
                or (s.player.Team~=w.team)~=s.defender or not s.root.Parent or s.root.Parent~=s.model or s.hum.Parent~=s.model then r.watch=nil;return false end
            local p,v=s.root.Position,s.root.AssemblyLinearVelocity
            local move=hint(s.hum)
            local hintChange=move and (not s.hint or (move-s.hint).Magnitude>.25)
            -- MoveDirection is an optional observed hint, not verified remote
            -- input. It can request a regrade, never change native aim/safety.
            if hintChange then r.motionHints=r.motionHints+1 end
            if vector(p) and vector(v) and (hintChange or flat(v-s.v).Magnitude>=CFG.MinMoveSpeed
                or s.defender and flat(p-s.p).Magnitude>=.5) then
                r.wakes=r.wakes+1;return true
            end
        end
        return false
    end
end
local function tick(now,cachedOnly)
    if stopped or inTick then return end
    if now-lastTick>=CFG.Interval then cachedOnly=false;lastTick=now
    elseif not cachedOnly then return end
    inTick=true
    if cachedOnly then controller.reactivity.cachedPasses=controller.reactivity.cachedPasses+1 end
    local begun=os.clock()
    local ok,err=pcall(function()
        if not cachedOnly then controller.comeback.snapshot=false end
        if context.IsCancelled and context.IsCancelled() then controller.Stop('CANCELLED'); return end
        scanLines()
        -- Field context exists for every role. Discover/refresh it before any
        -- Yuna, active-play, equipped-ball, or already-attempted return below.
        if not cachedOnly then assistance.guidePending=nil;assistance.guideDirty=true end
        local lineReady=readLines(now)
        if not initialFieldDiscovered and (lineReady or lines.initialComplete and groundReason()=='ACCEPTED') then
            initialFieldDiscovered=true
        end
        if renderReceivers and receiverMenu and receiverMenu.Visible then renderReceivers(now) end
        if profile and (not aliveConnection(profile.preview) or not aliveConnection(profile.release)) then
            releaseChoice(); profile=nil; nextDiscovery=0; log('PROFILE','Disconnected; rediscovering')
        end
        if not profile and now>=nextDiscovery then
            nextDiscovery=now+CFG.DiscoveryInterval
            local why; profile,why=discover()
            if not profile then resetFieldWait(); setGate(why); return end
            log('PROFILE','Shared selector settings + native final solver + live release matched')
        end
        -- A continuous equipped/throwable possession permits exactly one request.
        -- A later authoritative play transition or actual change of equipped
        -- ball/character permits a new attempt, including reuse of the same Tool.
        observePossession(now)
        local evidence=controller.bad:pos(possession.epoch,now);if evidence then evidence.Settings=controller.unified.Settings()end
        local ball,why=ready()
        if not ball then resetFieldWait(); releaseChoice(); setGate(why); return end
        if not refreshNativeInputs() then resetFieldWait(); releaseChoice(); setGate('NATIVE_LEAD_CHANGED'); return end
        if ball.nativeThrow and usedTools[ball.tool]~=possession.epoch then
            usedTools[ball.tool]=possession.epoch
            pending={tool=ball.tool,model=ball.model,target=choice and choice.player.Name or 'NATIVE',
                mode=choice and choice.shot.mode or 'NATIVE',at=now,outcome='NATIVE_MANUAL_THROW_UNCONFIRMED',source='NATIVE_ANIMATION_OBSERVED; REQUEST_NOT_PROVEN'}
            log('MANUAL','Native Throw animation owns this possession; no competing AUTO request')
        end
        if pending and usedTools[ball.tool]==possession.epoch then
            resetFieldWait()
            setGate(pending.outcome=='NATIVE_MANUAL_THROW_UNCONFIRMED' and pending.outcome
                or pending.outcome=='AMBIGUOUS_NO_RETRY' and 'REQUEST_AMBIGUOUS_NO_RETRY' or 'REQUEST_SENT_UNCONFIRMED')
            -- Do not keep a lock invisibly after a rejected/unknown request.
            if now-pending.at>1 then releaseChoice() end
            return
        end
        if lease and not ownsLock() then resetFieldWait(); releaseChoice(); setGate('EXTERNAL_NATIVE_LOCK_EDIT'); return end
        if profile.q.Locked and not lease then resetFieldWait(); setGate('USER_NATIVE_LOCK_ACTIVE'); return end
        if not lineReady and receiverMenu and receiverMenu.Visible then
            resetFieldWait(); releaseChoice(); setGate('RECEIVER_MENU_OPEN'); return
        end
        if not lineReady then
            -- Readiness above requires Yuna enabled, a live throwable play,
            -- local equipped ball, and no native/manual request owning the play.
            -- Pregame, missing Yuna/ball, dead plays and AUTO OFF never consume
            -- this timer. Each new possession starts with the full allowance.
            fieldWaitSince=fieldWaitSince or now
            fieldWaitSeconds=math.max(0,now-fieldWaitSince)
            if fieldWaitSeconds>=CFG.FieldDiscoverySeconds then
                fatalError=clean('Field readiness timeout during throwable QB possession; status='..lines.status
                    ..'; ground='..groundReason()..'; scanComplete='..tostring(lines.initialComplete==true))
                log('FIELD_DISCOVERY_ERROR',fatalError); controller.Stop('FIELD_DISCOVERY_TIMEOUT'); return
            end
            releaseChoice(); setGate(lines.status); return
        end
        resetFieldWait()
        if possession.lineGeneration~=lines.generation then
            possession.lineGeneration=lines.generation; possession.since=now; releaseChoice()
        end
        if controller.field.QBPast(ball.root) then releaseChoice(); setGate('QB_PAST_LOS'); return end
        local roster=Players:GetPlayers()
        if #roster>CFG.MaxRoster then releaseChoice(); setGate('ROSTER_LIMIT'); return end
        local receivers,defenders,seenRoster={},{},{}
        receiverRejects={};receiverRejectAt=now;controller.bad:eligibility(now)
        local observationMissing=false
        for _,player in ipairs(roster) do
            seenRoster[player]=true
            if player~=me and not player.Neutral and player.Team and body(player) then
                local s=sample(player,now)
                if not s or s.n<2 then
                    if player.Team~=me.Team then observationMissing=true end
                    controller.bad:excluded(player.Name,s,'MOVEMENT_UNVERIFIED',player.Team==me.Team and 'TEAMMATE' or 'OPPONENT')
                    receiverRejects[player.Name]='MOVEMENT_UNVERIFIED'; opportunities[player]=nil; shotCache[player]=nil
                elseif player.Team==me.Team then
                    local eligible,rejection=receiverReady(player,s,now)
                    -- The qualified native lock accepts a teammate independently
                    -- of cursor/camera position. Read the field, not just the view.
                    if eligible then
                        local estimate=math.max(.05,flat(s.p-ball.head.Position).Magnitude/95)
                        receivers[#receivers+1]={player=player,sample=s,estimate=estimate,rank=0}
                    else controller.bad:excluded(player.Name,s,rejection);receiverRejects[player.Name]=rejection;opportunities[player]=nil;shotCache[player]=nil end
                elseif player.Team~=me.Team then defenders[#defenders+1]=s end
            elseif player~=me and player.Team==me.Team then controller.bad:excluded(player.Name,nil,player.Neutral and 'NEUTRAL_TEAMMATE' or 'NO_LIVE_CHARACTER')
            end
        end
        for player in pairs(samples) do if not seenRoster[player] then samples[player]=nil; opportunities[player]=nil; shotCache[player]=nil end end
        if not cachedOnly then controller.reactivity.Capture(receivers,defenders,now) end
        if receiverMenu and receiverMenu.Visible then releaseChoice(); setGate('RECEIVER_MENU_OPEN'); return end
        if observationMissing then holdManual(fallbackReceiver(receivers),'MANUAL_LOCK_WAIT_DEFENDER_OBSERVATIONS'); return end
        if controller.comeback.enabled and auto and throwing then
            local models={};for _,r in ipairs(receivers) do models[r.player]=r.sample.model end
            controller.comeback.snapshot={at=now,receivers=receivers,defenders=defenders,models=models,
                epoch=possession.epoch,team=me.Team,generation=lines.generation,tool=ball.tool,model=ball.model}
        end
        for _,r in ipairs(receivers) do
            local separation=45
            for _,d in ipairs(defenders) do separation=math.min(separation,flat(predict(r.sample,r.estimate)-predict(d,r.estimate)).Magnitude) end
            r.rank=separation-r.estimate*3
            r.burnLook=lines.forward~=nil and flat(r.sample.v):Dot(lines.forward)>0 and not safetyAhead(r.sample,defenders,r.estimate)
        end
        table.sort(receivers,function(a,b) if a.burnLook~=b.burnLook then return a.burnLook end; if a.estimate~=b.estimate then return a.estimate<b.estimate end; if a.rank==b.rank then return a.player.Name<b.player.Name end; return a.rank>b.rank end)
        if #receivers==0 then releaseChoice();setGate(controller.receiverFilter.mode=='FRIENDS' and 'WAIT_ELIGIBLE_FRIEND_RECEIVER' or 'NO_ACTIVE_DOWNFIELD_RECEIVER');return end
        local indices={}
        if not cachedOnly then
            planRound=planRound+1
            local incumbent
            if choice then for i,r in ipairs(receivers) do if r.player==choice.player then incumbent=i; break end end end
            indices={incumbent or 1}
            if #receivers>1 then
                -- Keep refreshing the lock, but do not spend every other
                -- challenger slot on the rank leader. Revisit the least
                -- recently planned eligible character; native mode rotation
                -- still advances only when evaluate actually attempts it.
                local oldest=-1
                for i,r in ipairs(receivers) do
                    if i~=indices[1] then
                        local cache=shotCache[r.player]
                        local at=cache and cache.model==r.sample.model and cache.epoch==possession.epoch
                            and cache.generation==lines.generation and cache.plannedAt or -math.huge
                        if not indices[2] or at<oldest then indices[2]=i;oldest=at end
                    end
                end
            end
        end
        local best=evaluate(receivers,indices,defenders,now)
        if stopped then return end
        if cachedOnly and (not best or not throwable(best.shot)) then return end
        if not best then holdManual(fallbackReceiver(receivers),'MANUAL_LOCK_NO_VALID_AUTO_TRAJECTORY'); return end
        local previous=choice
        local stable=previous and previous.player==best.player and previous.model==best.player.Character
        best.since=stable and choice.since or now; best.model=best.player.Character
        choice=best
        -- The last candidate may differ from the winner; settle the actual shared
        -- native lock and final preview on the winner before any release.
        local final,failed,failure
        if best.shot.mode=='Fit' or (best.shot.jumpBullet or best.shot.nativeCoverageJump) then
            -- Reserve final calls for the candidate and fresh counterfactuals
            -- (three for a league layer-window Fit). Avoid a redundant preview.
            if lock(best.player) then final=best.shot else failed='NATIVE_LOCK_BUSY' end
        else final,failed,failure=solve(best.player,best.shot.variant or best.shot.mode) end
        if not final then
            if shotCache[best.player] then shotCache[best.player].shots[best.shot.variant or best.shot.mode]=nil end
            receiverRejects[best.player.Name..'/'..(best.shot.variant or best.shot.mode)]=failed
            opportunities[best.player]=nil; holdManual(best,'MANUAL_LOCK_'..failed,
                {stage='WINNER_SOLVE_FAILED',mode=best.shot.mode,variant=best.shot.variant,failure=failure}); return end
        best.shot=final;final.releaseBlocked=false
        if shotCache[best.player] then shotCache[best.player].shots[final.variant or final.mode]=best.shot end
        local eligible,rejection=receiverReady(best.player,best.sample,now,final.arrival)
        if not eligible then holdManual(best,'MANUAL_LOCK_'..rejection); return end
        eligible,rejection=receivePossible(best.shot,best.sample)
        if not eligible then shotCache[best.player]=nil; opportunities[best.player]=nil; holdManual(best,'MANUAL_LOCK_'..rejection); return end
        risk(best.shot,best.sample,defenders); coverage(best.shot,best.sample,defenders)
        if best.shot.mode=='Fit' then controller.fit.assess(best.shot,controller.fit.alternatives(best.player,best.sample,defenders,now)) end
        if best.shot.jumpBullet or best.shot.nativeCoverageJump then controller.jumpBullet.assess(best.shot,controller.fit.alternatives(best.player,best.sample,defenders,now,nil,nil,true)) end
        if not throwable(best.shot) then
            opportunities[best.player]=nil; holdManual(best,best.shot.unified and best.shot.unified.Reason or best.shot.safetyRead and best.shot.safetyRead.High and best.shot.mode~='Bullet' and 'SAFETY_HIGH_BULLET_ONLY' or best.shot.planAllowed==false and best.shot.planReason or best.shot.powerAllowed==false and (best.shot.powerReason or 'BULLET_COMFORT_UNAVAILABLE') or 'MANUAL_LOCK_COVERED')
            assistance.guidePending={r=best,ball=ball,defenders=defenders};return
        end
        best.manualOnly=false
        classify(best.shot,best.sample,defenders)
        if not stable then log('SELECT',best.player.Name..' '..best.shot.mode) end
        if not throwing then setGate('SELECT_ONLY'); return end
        if receiverMenu and receiverMenu.Visible then setGate('RECEIVER_MENU_OPEN'); return end

        if controller.unified:wait(best.player,best.model,possession.epoch,best.shot,now) then
            setGate('DEVELOPING_ROUTE_CONTINUATION');controller.bad:timing(best,now);return
        end
        submit(ball,best,defenders,now)
    end)
    inTick=false
    maxTick=math.max(maxTick,os.clock()-begun)
    if not ok then
        fatalError=clean(err); log('TICK_ERROR',err); controller.Stop('RUNTIME_ERROR'); return
    end
    if not stopped and now>=nextSave then nextSave=now+10; preserve(false) end
end
local function connect(signal,fn)
    local connection=signal:Connect(fn); connections[#connections+1]=connection; return connection
end
local function button(text,x,width,y)
    local b=Instance.new('TextButton'); b.Size=UDim2.fromOffset(width,22)
    b.Position=UDim2.new(1,x,0,y or 62); b.Text=text; b.TextSize=10; b.Font=Enum.Font.GothamMedium
    b.BackgroundColor3=Color3.fromRGB(28,37,34); b.BackgroundTransparency=.2; b.TextColor3=Color3.new(1,1,1)
    b.ClipsDescendants=true
    if Enum.TextTruncate then b.TextTruncate=Enum.TextTruncate.AtEnd end
    b.Parent=gui; return b
end
function controller.ExportBadPlay()
    local function done(ok,value)controller.bad.exportStatus=value;return ok,value end
    local report=controller.bad:report();if not report then return done(false,'FLAG_A_PLAY_FIRST') end
    env.PELICAN_FF3_BAD_PLAY_REPORT=report
    local http=game:GetService('HttpService')
    if not report.ExportFile then
        env.PELICAN_FF3_BAD_FILE_SEQUENCE=(env.PELICAN_FF3_BAD_FILE_SEQUENCE or 0)+1
        local valid,guid=pcall(function()return http:GenerateGUID(false)end)
        local suffix=valid and type(guid)=='string' and guid:gsub('[^%w%-]','') or tostring(os.time())..'-'..tostring(env.PELICAN_FF3_BAD_FILE_SEQUENCE)
        report.ExportFile='PELICAN_FF3_BAD_PLAY_'..suffix..'.json'
    end
    local archive=env.PELICAN_FF3_BAD_PLAY_ARCHIVE
    if type(archive)~='table' then archive={};env.PELICAN_FF3_BAD_PLAY_ARCHIVE=archive end
    local found=false;for _,old in ipairs(archive)do if old==report then found=true;break end end
    if not found then archive[#archive+1]=report;while #archive>8 do table.remove(archive,1)end end
    local ok,encoded=pcall(function()return game:GetService('HttpService'):JSONEncode(report)end)
    if not ok then return done(false,'ENCODE_FAILED') end
    while #encoded>1500000 and report.Possession.Timeline and #report.Possession.Timeline>0 do
        local timeline=report.Possession.Timeline;local drop=math.ceil(#timeline/2)
        for _=1,drop do table.remove(timeline,1)end
        report.Possession.TimelineDropped=(report.Possession.TimelineDropped or 0)+drop
        local valid,nextEncoded=pcall(function()return game:GetService('HttpService'):JSONEncode(report)end)
        if not valid then return done(false,'ENCODE_FAILED')end;encoded=nextEncoded
    end
    if #encoded>1500000 then return done(false,'REPORT_SIZE_LIMIT; RETAINED_IN_MEMORY') end
    env.PELICAN_FF3_BAD_PLAY_REPORT=report
    local copier=type(setclipboard)=='function' and setclipboard or type(toclipboard)=='function' and toclipboard
    local copied=copier and pcall(copier,encoded) or false
    local saved=type(writefile)=='function' and pcall(writefile,report.ExportFile,encoded) or false
    if saved then pcall(writefile,'PELICAN_FF3_BAD_PLAY.json',encoded) end -- latest-report alias only
    return done(copied==true or saved==true,copied and 'COPIED' or saved and 'SAVED' or 'NO_EXPORT_API')
end
controller.presentation=(function()
-- Local presentation ownership. Never disables Roblox controls/chat or inputs.
local P={}
local function is(o,k)return typeof(o)=='Instance' and o:IsA(k)end
local function root(o)
 for _=1,32 do if not o then return end;if is(o,'ScreenGui')then return o end;o=o.Parent end
end
local function ownedName(o)
 local n=o.Name:lower();return n:find('pelican',1,true) or n:find('yuna',1,true)
end
function P.new(options)
 return setmetatable({options=options,hidden=false,leases={},connections={},nextScan=0,status='VISIBLE',lightingStatus='NOT_REQUESTED'},{__index=P})
end
function P:connect(signal,fn)
 if signal then local c=signal:Connect(fn);self.connections[#self.connections+1]=c;return c end
end
function P:claim(o)
 if not self.hidden or not o or self.leases[o] then return end
 local prop=is(o,'ScreenGui') and 'Enabled' or is(o,'GuiObject') and 'Visible'
 if not prop then return end
 local before=o[prop];self.leases[o]={property=prop,before=before};o[prop]=false
 if o.GetPropertyChangedSignal then
  self.leases[o].connection=o:GetPropertyChangedSignal(prop):Connect(function()
   if self.hidden and o.Parent and o[prop]~=false then o[prop]=false end
  end)
 end
end
function P:scan()
 local opts=self.options
 for _,container in ipairs(opts.containers)do
  local queue=container:GetChildren();local i=1
  while i<=#queue and i<=512 do
   local o=queue[i];i=i+1
   if is(o,'ScreenGui') then
    if container==opts.hiddenContainer or ownedName(o) then self:claim(o)end
   elseif is(o,'Folder') then for _,child in ipairs(o:GetChildren())do if #queue<512 then queue[#queue+1]=child end end
   elseif container==opts.hiddenContainer and is(o,'GuiObject') then self:claim(o)end
  end
 end
 for _,o in ipairs(opts.roots()or {})do self:claim(root(o)or o)end
end
function P:normalLighting()
 local b=self.options.baseline and self.options.baseline()
 if type(b)~='table' or type(b.Values)~='table' or b.JobId~=self.options.job or b.Source~='USER_CAPTURED_BEFORE_VISUAL_MODS' then self.lightingStatus='ORIGINAL_LIGHTING_UNAVAILABLE';return end
 self.lightLease={};local light=self.options.lighting
 for key,value in pairs(b.Values)do
  local ok,before=pcall(function()return light[key]end)
  if ok then
   local wrote=pcall(function()light[key]=value end)
   if wrote then self.lightLease[key]={before=before,written=value}end
  end
 end
 self.lightingStatus='CAPTURED_BASELINE_APPLIED; OTHER_VISUAL_WRITERS_NOT_DISABLED'
end
function P:set(hidden)
 if self.stopped and hidden then return end
 if self.hidden==hidden and (hidden or not next(self.leases) and not self.lightLease) then return end
 self.hidden=hidden
 if hidden then self:scan();self:normalLighting();self.status='HIDDEN'
 else
  local remaining={}
  for o,l in pairs(self.leases)do
   if l.connection then local ok=pcall(function()l.connection:Disconnect()end);if not ok then self.connections[#self.connections+1]=l.connection end;l.connection=nil end
   local ok=pcall(function()if o.Parent and o[l.property]==false then o[l.property]=l.before end end)
   if not ok then remaining[o]=l end
  end
  self.leases=remaining
  local lightRemaining={}
  for key,l in pairs(self.lightLease or {})do local ok=pcall(function()if self.options.lighting[key]==l.written then self.options.lighting[key]=l.before end end);if not ok then lightRemaining[key]=l end end
  self.lightLease=next(lightRemaining) and lightRemaining or nil;self.status=next(remaining) and 'RESTORE_FAILED' or 'VISIBLE'
 end
end
function P:message(text)if text=='z' then self:set(not self.hidden);return true end;return false end
function P:start(me)
 self:connect(me.Chatted,function(text)
  local ok,err=pcall(self.message,self,text)
  if not ok then self:stop();if self.options.error then self.options.error(err)end end
 end)
 for _,container in ipairs(self.options.containers)do
  self:connect(container.DescendantAdded,function(o)
   if self.hidden and (is(o,'ScreenGui') or ownedName(o)) then
    if container==self.options.hiddenContainer or ownedName(o) then self:claim(root(o)or o)end
    self.nextScan=0
   end
  end)
 end
end
function P:update(now)
 if self.hidden and now>=self.nextScan then self.nextScan=now+.5;self:scan()end
end
function P:stop()
 self:set(false);self.stopped=true
 local remaining={}
 for _,c in ipairs(self.connections)do local ok=pcall(function()c:Disconnect()end);if not ok then remaining[#remaining+1]=c end end
 self.connections=remaining;self.clean=#remaining==0 and not next(self.leases) and not self.lightLease
 return self.clean
end
return P

end)().new({containers={pg},job=game.JobId,lighting=game:GetService('Lighting'),baseline=function()return env.PELICAN_FF3_VISUAL_BASELINE end,
 error=function(err)fatalError=clean(err);log('PRESENTATION_ERROR',err);controller.Stop('PRESENTATION_ERROR')end,
 roots=function()
    local list={};if gui then list[#list+1]=gui end
    if profile and profile.hud then for _,card in pairs(profile.hud)do if type(card)=='table' and card.CardText then list[#list+1]=card.CardText end end end
    for _,item in ipairs(controller.presentation.extraRoots or {})do list[#list+1]=item end
    return list
 end})
if core then controller.presentation.options.containers[#controller.presentation.options.containers+1]=core end
if type(gethui)=='function' then
 local ok,h=pcall(gethui)
 if ok and typeof(h)=='Instance' and h~=core and h~=pg then
    controller.presentation.options.hiddenContainer=h;controller.presentation.options.containers[#controller.presentation.options.containers+1]=h
 end
end
function controller.SetPresentationHidden(value)controller.presentation:set(value==true)end
function controller.RegisterPresentationGui(o)
 if typeof(o)~='Instance' then return false end
 local p=controller.presentation;p.extraRoots=p.extraRoots or {};if #p.extraRoots>=64 then return false end
 p.extraRoots[#p.extraRoots+1]=o;if p.hidden then p:scan()end;return true
end
controller.presentation:start(me)
local built,buildError=pcall(function()
    gui=Instance.new('ScreenGui'); gui.Name='PELICAN_FF3_AUTO_QB_V26'; gui.ResetOnSpawn=false; gui.DisplayOrder=1000; gui.Parent=pg
    status=button('QB',-82,54,40);status.Name='CompactQB'
    assistance.guideUI=Instance.new('Frame');assistance.guideUI.Name='RunGuide';assistance.guideUI.Size=UDim2.new(1,0,1,0)
    assistance.guideUI.Position=UDim2.fromOffset(0,0);assistance.guideUI.BackgroundTransparency=1;assistance.guideUI.Visible=false
    assistance.guideUI.Active=false;assistance.guideUI.Parent=gui
    assistance.guideSegments={}
    for _,name in ipairs({'Shaft','LeftWing','RightWing'}) do
        local segment=Instance.new('Frame');segment.Name=name;segment.AnchorPoint=Vector2.new(.5,.5)
        segment.BorderSizePixel=0;segment.BackgroundColor3=Color3.fromRGB(125,230,190);segment.BackgroundTransparency=.15
        segment.Active=false;segment.Parent=assistance.guideUI;assistance.guideSegments[#assistance.guideSegments+1]=segment
    end
    local kill=button('X',-26,22,40); kill.BackgroundColor3=Color3.fromRGB(195,40,40)
    autoButton=button('AUTO ON',-166,58,87); throwButton=button('THR ON',-105,51,87); copyButton=button('COPY',-51,47,87)
    receiverButton=button('WR LIST',-166,106,112); receiverButton.Name='Receivers'
    riskButton=button(riskPolicy.mode,-58,54,112);riskButton.Name='RiskMode'
    controller.comeback.button=button(controller.comeback.enabled and 'CB ON' or 'CB OFF',-226,54,87)
    controller.comeback.button.Name='ComebackChat';controller.comeback.button.Visible=false
    connect(controller.comeback.button.Activated,function() controller.SetComebackChat(not controller.comeback.enabled) end)
    controller.receiverFilter.button=button(controller.receiverFilter.mode,-286,54,87);controller.receiverFilter.button.Name='ReceiverFilter';controller.receiverFilter.button.Visible=false
    connect(controller.receiverFilter.button.Activated,function()
        controller.SetReceiverFilter(controller.receiverFilter.mode=='ANY' and 'FRIENDS' or 'ANY')
    end)
    controller.passPlan.button=button(controller.passPlan.mode,-286,54,112);controller.passPlan.button.Name='PassPlan';controller.passPlan.button.Visible=false
    controller.mag.button=button(controller.mag.enabled and 'MAG TEST' or 'MAG OFF',-166,72,137);controller.mag.button.Name='MagTrial';controller.mag.button.Visible=false
    connect(controller.mag.button.Activated,function() controller.SetMagTrial(not controller.mag.enabled) end)
    controller.angle.button=button(controller.angle.enabled and 'ARC AUTO' or 'ARC OLD',-92,88,137);controller.angle.button.Name='AdaptiveAngle';controller.angle.button.Visible=false
    connect(controller.angle.button.Activated,function() controller.SetAdaptiveAngle(not controller.angle.enabled) end)
    connect(controller.passPlan.button.Activated,function()
        local mode=controller.passPlan.mode
        controller.SetPassPlan(mode=='NORMAL' and 'DEEP' or mode=='DEEP' and 'SHORT' or 'NORMAL')
    end)
    controller.jumpBullet.button=button(controller.jumpBullet.enabled and 'JB ON' or 'JB OFF',-226,54,112)
    controller.history.button=button('DATA',-226,54,137);controller.history.button.Name='History';controller.history.button.Visible=false
    controller.receiverEvidence.button=button('LEADS',-286,54,137);controller.receiverEvidence.button.Visible=false
    controller.receiverEvidence.panel=Instance.new('TextLabel');controller.receiverEvidence.panel.Name='LeadEvidence'
    controller.receiverEvidence.panel.Size=UDim2.fromOffset(282,139);controller.receiverEvidence.panel.Position=UDim2.new(1,-286,0,162)
    controller.receiverEvidence.panel.BackgroundColor3=Color3.fromRGB(24,30,28);controller.receiverEvidence.panel.TextColor3=Color3.new(1,1,1)
    controller.receiverEvidence.panel.Font=Enum.Font.Code;controller.receiverEvidence.panel.TextSize=10;controller.receiverEvidence.panel.TextXAlignment=Enum.TextXAlignment.Left
    controller.receiverEvidence.panel.Parent=gui;controller.receiverEvidence.panel.Visible=false
    connect(controller.receiverEvidence.button.Activated,function()
        controller.receiverEvidence.panel.Visible=not controller.receiverEvidence.panel.Visible
        if controller.receiverEvidence.panel.Visible and receiverMenu then receiverMenu.Visible=false end
        controller.receiverEvidence.RefreshAdvice(true);controller.receiverEvidence.nextPaintAt=0;controller.receiverEvidence.Paint();controller.league.Paint()
    end)
    connect(controller.history.button.Activated,function()
        local ok,result;if controller.bad:report()then ok,result=controller.ExportBadPlay()else ok,result=controller.history.Export()end;controller.history.button.Text=ok and (result=='SAVED' and 'SAVED' or 'COPIED') or 'FAIL';log('HISTORY_COPY',result)
    end)
    controller.jumpBullet.button.Name='JumpBullet';controller.jumpBullet.button.Visible=false
    if controller.nativeJump.supported then
        controller.nativeJump.button=controller.jumpBullet.button;controller.nativeJump.button.Name='NativeJump'
        controller.nativeJump.button.Text=controller.nativeJump.enabled and 'HIGH ON' or 'HIGH OFF'
    end
    connect(controller.jumpBullet.button.Activated,function()
        if controller.nativeJump.supported then controller.SetNativeJump(not controller.nativeJump.enabled)
        else controller.SetJumpBullet(not controller.jumpBullet.enabled) end
    end)
    connect(riskButton.Activated,function()
        controller.SetRiskMode(riskPolicy.mode=='SAFE' and 'MOD' or riskPolicy.mode=='MOD' and 'TRUST' or 'SAFE')
    end)
    controller.unified.toolsButton=button('TOOLS',-230,64,40);controller.unified.toolsButton.Name='Tools'
    connect(controller.unified.toolsButton.Activated,function()controller.unified.toolsOpen=not controller.unified.toolsOpen;receiverMenu.Visible=false;controller.receiverEvidence.panel.Visible=false;controller.league.Paint()end)
    controller.unified.clearButton=button('CLEAR BAD',-230,72,187);controller.unified.clearButton.Name='ClearBadPlay'
    connect(controller.unified.clearButton.Activated,function()controller.bad.pinned=nil;env.PELICAN_FF3_BAD_PLAY_REPORT=nil;copyButton.Text='COPY';controller.history.button.Text='DATA';controller.league.Paint()end)
    controller.unified.stopButton=button('STOP',-230,72,187);controller.unified.stopButton.Name='StopQB'
    connect(controller.unified.stopButton.Activated,function()controller.Stop('USER_END')end)
    controller.badButton=button('BAD THROW',-226,106,162);controller.badButton.Name='BadPlay'
    controller.badCurrentButton=button('MISSED',-116,106,162);controller.badCurrentButton.Name='MissedPlay'
    for _,entry in ipairs({{controller.badButton,false},{controller.badCurrentButton,true}})do
        connect(entry[1].Activated,function()local ok=controller.bad:flag(os.clock(),entry[2]);if ok then controller.ExportBadPlay() end;entry[1].Text=ok and 'FLAGGED' or 'NO PLAY';expanded=false;controller.league.Paint() end)
    end
    controller.unified.easeButton=button(controller.passPlan.openComfort and 'EASE ON' or 'EASE OFF',-226,106,187);controller.unified.easeButton.Name='OpenComfort'
    connect(controller.unified.easeButton.Activated,function()controller.SetOpenComfort(not controller.passPlan.openComfort)end)
    awayButton=button('AWAY',-226,54,62);awayButton.Name='ThrowAway'
    connect(awayButton.Activated,controller.ThrowAway)
    controller.league.screenButton=button('SCREEN',-226,54,62);controller.league.screenButton.Name='Screen';controller.league.screenButton.Visible=false
    controller.league.profileButton=button(controller.league.requested,-346,54,87);controller.league.profileButton.Name='PlayProfile';controller.league.profileButton.Visible=false
    connect(controller.league.profileButton.Activated,function()
        controller.league.UI(controller.SetProfile,controller.league.mode=='LEAGUE' and 'CASUAL' or 'LEAGUE','USER')
    end)
    receiverMenu=Instance.new('Frame'); receiverMenu.Name='ReceiverList'; receiverMenu.Size=UDim2.fromOffset(162,134)
    receiverMenu.Position=UDim2.new(1,-166,0,137); receiverMenu.BackgroundColor3=Color3.fromRGB(24,30,28); receiverMenu.Parent=gui
    local title=Instance.new('TextLabel'); title.Name='Title'; title.Size=UDim2.fromOffset(158,22); title.Position=UDim2.fromOffset(2,0)
    controller.league.menuTitle=title
    title.Text='Tap: normal > block'; title.TextSize=10; title.TextColor3=Color3.new(1,1,1); title.BackgroundTransparency=1; title.Parent=receiverMenu
    local rows,rowPlayers={},{}; local page=1; local lastRender=-math.huge
    for i=1,3 do
        local index=i; local row=button('',0,158,0); row.Name='Receiver'..i; row.Parent=receiverMenu
        row.Position=UDim2.fromOffset(2,22+(i-1)*28); row.Size=UDim2.fromOffset(158,28); rows[i]=row
        connect(row.Activated,function()
            local p=rowPlayers[index]
            if p then
                if controller.league.menuScreen then
                    if controller.league.screen and controller.league.screen.player==p then controller.league.ClearScreen('USER_CANCEL');receiverMenu.Visible=false
                    else controller.league.UI(controller.SelectScreen,p) end
                else
                    local state=controller.GetReceiverState(p)
                    controller.SetReceiverState(p,state=='BLOCKED' and 'NORMAL' or 'BLOCKED')
                end
            end
            if not receiverMenu.Visible then expanded=false end;controller.league.Paint()
        end)
    end
    local prev,nextPage=button('<',0,28,0),button('>',0,28,0)
    prev.Name='Previous'; nextPage.Name='Next'; prev.Parent=receiverMenu; nextPage.Parent=receiverMenu
    prev.Position=UDim2.fromOffset(2,108); nextPage.Position=UDim2.fromOffset(132,108)
    local pageLabel=Instance.new('TextLabel'); pageLabel.Name='Page'; pageLabel.Size=UDim2.fromOffset(100,22)
    pageLabel.Position=UDim2.fromOffset(31,108); pageLabel.TextSize=10; pageLabel.TextColor3=Color3.new(1,1,1); pageLabel.BackgroundTransparency=1; pageLabel.Parent=receiverMenu
    renderReceivers=function(now)
        if stopped or now and now-lastRender<.5 then return end
        lastRender=now or os.clock()
        local list={}
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=me and me.Team and not p.Neutral and p.Team==me.Team then list[#list+1]=p end
        end
        table.sort(list,function(a,b) return a.Name<b.Name end)
        local pages=math.max(1,math.ceil(#list/3)); page=clamp(page,1,pages)
        for i,row in ipairs(rows) do
            local p=list[(page-1)*3+i]; rowPlayers[i]=p; row.Visible=p~=nil
            if p then
                local state=controller.GetReceiverState(p)
                local mark
                if controller.league.menuScreen then mark=controller.league.screen and controller.league.screen.player==p and '[S]' or state=='BLOCKED' and '[X]' or '[ ]'
                else mark=state=='BLOCKED' and '[X]' or controller.receiverFilter.friend(p,false) and '[F]' or '[ ]' end
                row.Text=mark..' @'..p.Name
            end
        end
        pageLabel.Text=#list==0 and 'No teammates' or tostring(page)..' / '..pages
        prev.Visible=pages>1; nextPage.Visible=pages>1
    end
    connect(prev.Activated,function() page=math.max(1,page-1); renderReceivers() end)
    connect(nextPage.Activated,function() page=page+1; renderReceivers() end)
    connect(receiverButton.Activated,function()
        controller.league.menuScreen=false;title.Text='Tap: normal > block'
        receiverMenu.Visible=not receiverMenu.Visible;if receiverMenu.Visible then controller.receiverEvidence.panel.Visible=false end; if cancelSequence then cancelSequence('RECEIVER_MENU') end;clearGuide();cancelJump('RECEIVER_MENU'); clearWindows(); if choice then choice.openSince=nil end
        if receiverMenu.Visible then renderReceivers() end
        controller.league.Paint()
    end)
    autoButton.Visible=false; throwButton.Visible=false; copyButton.Visible=false; receiverButton.Visible=false;riskButton.Visible=false; receiverMenu.Visible=false
    controller.league.Paint=function()
        local league=controller.league.mode=='LEAGUE'
        autoButton.Visible=expanded;throwButton.Visible=expanded;copyButton.Visible=expanded;riskButton.Visible=expanded
        receiverButton.Visible=expanded and not league;awayButton.Visible=expanded and not league
        controller.league.screenButton.Visible=expanded and league;controller.league.profileButton.Visible=expanded
        controller.league.profileButton.Text=controller.league.requested=='AUTO' and 'AUTO' or controller.league.mode
        controller.league.profileButton.Position=league and UDim2.new(1,-166,0,112) or UDim2.new(1,-346,0,87)
        controller.league.profileButton.Size=UDim2.fromOffset(league and 106 or 54,22)
        for _,b in ipairs({controller.comeback.button,controller.jumpBullet.button,controller.mag.button,controller.angle.button,
            controller.history.button,controller.receiverEvidence.button,controller.passPlan.button,controller.receiverFilter.button}) do b.Visible=expanded and not league end
        controller.receiverFilter.button.Text=controller.receiverFilter.mode;controller.passPlan.button.Text=controller.passPlan.mode
        controller.comeback.button.Text=controller.comeback.enabled and 'CB ON' or 'CB OFF';controller.mag.button.Text=controller.mag.enabled and 'MAG TEST' or 'MAG OFF'
        controller.badButton.Visible=expanded;controller.badCurrentButton.Visible=expanded;controller.unified.easeButton.Visible=expanded
        controller.mag.button.Visible=false
        controller.jumpBullet.button.Visible=expanded and controller.nativeJump.supported and not league
        controller.jumpBullet.button.Text=controller.nativeJump.enabled and 'HIGH ON' or 'HIGH OFF'
        status.Text=expanded and gate:gsub('_',' '):sub(1,24) or 'QB'
        if expanded then status.Size=UDim2.fromOffset(166,22);status.Position=UDim2.new(1,-194,0,40)else status.Size=UDim2.fromOffset(54,22);status.Position=UDim2.new(1,-82,0,40)end
        if not expanded or league then controller.receiverEvidence.panel.Visible=false end
        if not expanded then if receiverMenu.Visible and choice then choice.openSince=nil end;receiverMenu.Visible=false;controller.unified.toolsOpen=false end
        controller.history.button.Text=controller.bad:report() and 'BAD DATA' or 'DATA'
        controller.unified.toolsButton.Visible=expanded;controller.unified.toolsButton.Text=controller.unified.toolsOpen and 'PLAY' or 'TOOLS'
        if expanded then status.Size=UDim2.fromOffset(136,22);status.Position=UDim2.new(1,-164,0,40)end
        local all={autoButton,throwButton,copyButton,receiverButton,riskButton,awayButton,controller.comeback.button,
            controller.receiverFilter.button,controller.passPlan.button,controller.mag.button,controller.angle.button,
            controller.jumpBullet.button,controller.history.button,controller.receiverEvidence.button,controller.league.screenButton,
            controller.league.profileButton,controller.badButton,controller.badCurrentButton,controller.unified.easeButton,controller.unified.stopButton,controller.unified.clearButton}
        for _,b in ipairs(all)do b.Visible=false end
        local list={};local function add(b,allowed)if allowed~=false then list[#list+1]=b end end
        if controller.unified.toolsOpen then
            add(controller.badButton);add(controller.badCurrentButton);add(copyButton);add(controller.history.button)
            add(controller.league.profileButton);add(controller.comeback.button,not league)
            add(controller.unified.clearButton,controller.bad:report()~=nil);add(controller.unified.stopButton)
        else
            add(autoButton);add(throwButton);add(riskButton);add(controller.passPlan.button)
            add(receiverButton,not league);add(controller.receiverFilter.button,not league);add(controller.league.screenButton,league)
            add(controller.unified.easeButton);add(controller.jumpBullet.button,controller.nativeJump.supported);add(controller.angle.button)
        end
        for i,b in ipairs(list)do
            b.Visible=expanded and not receiverMenu.Visible and not controller.receiverEvidence.panel.Visible
            b.Size=UDim2.fromOffset(72,24);b.Position=UDim2.new(1,-230+((i-1)%3)*76,0,68+math.floor((i-1)/3)*26)
        end
        awayButton.Visible=true;awayButton.Size=UDim2.fromOffset(40,22);awayButton.Position=UDim2.new(1,expanded and -274 or -126,0,40)
        receiverMenu.Position=UDim2.new(1,-166,0,68)
        controller.receiverEvidence.panel.Position=UDim2.new(1,-230,0,68);controller.receiverEvidence.panel.Size=UDim2.fromOffset(226,139)

    end
    connect(status.Activated,function() expanded=not expanded;controller.league.Paint() end)
    connect(controller.league.screenButton.Activated,function()
        if controller.league.mode~='LEAGUE' then return end
        releaseChoice();controller.league.menuScreen=true;title.Text='Screen: this possession only'
        receiverMenu.Visible=not receiverMenu.Visible;controller.receiverEvidence.panel.Visible=false
        if receiverMenu.Visible then renderReceivers() end
        controller.league.Paint()
    end)
    controller.SetProfile(controller.league.requested,'INITIAL_PROFILE')
    connect(autoButton.Activated,function() controller.SetAuto(not auto) end)
    connect(throwButton.Activated,function() controller.SetThrow(not throwing) end)
    connect(copyButton.Activated,function() if controller.bad:report()then local ok,result=controller.ExportBadPlay();copyButton.Text=ok and result or 'FAIL';return end;preserve(true); copyButton.Text=copyResult=='API_ACCEPTED' and 'SENT' or 'FAIL' end)
    kill.Name='Reload'
    connect(kill.Activated,function()
        if type(context.RequestReload)=='function' then context.RequestReload()
        else log('RELOAD_UNAVAILABLE','Start through the repository loader');setGate('RELOAD_REQUIRES_LOADER');preserve(true) end
    end)
    local stop=Instance.new('BindableEvent'); stop.Name='Stop'; stop.Parent=gui; connect(stop.Event,function() controller.Stop('EXTERNAL_STOP') end)
    if me.OnTeleport then connect(me.OnTeleport,function(state)
        local value=tostring(state)
        if value:find('Started',1,true) or value:find('InProgress',1,true) then controller.Stop('TELEPORT')
        else preserve(true) end
    end) end
    connect(workspace.DescendantAdded,onLineAdded)
    connect(pg.DescendantAdded,onLineAdded)
    if core and core.DescendantAdded then connect(core.DescendantAdded,onLineAdded) end
    connect(Run.Heartbeat,function()
        if stopped then return end
        local now=os.clock(); frameCalls=0;motionFrame=motionFrame+1
        local ok,err=pcall(function() controller.presentation:update(now);controller.unified.ObserveOscillation(now);controller.league.Update(now);if ff3Options.CompactCompanionHUD~=false then controller.unified.helperHUD:check(now)end;controller.jumpTiming.Observe(now);updateJump(now);driveSequence(now) end)
        if not ok then fatalError=clean(err); log('RELEASE_ERROR',err); controller.Stop('RELEASE_SEQUENCE_ERROR'); return end
        local wakeOK,wake=pcall(controller.reactivity.Wake,now)
        if not wakeOK then fatalError=clean(wake);log('MOTION_WATCH_ERROR',wake);controller.Stop('MOTION_WATCH_ERROR');return end
        tick(now,wake)
        if stopped then return end
        -- Release work above always gets priority over advisory forecasting.
        local guideOK,guideError=pcall(function()
            if assistance.guideDirty then
                assistance.guideDirty=false;local data=assistance.guidePending;forecastGuide(data,os.clock())
            end
            updateJump(os.clock());drawGuide(os.clock())
        end)
        if not guideOK then fatalError=clean(guideError);log('GUIDE_ERROR',guideError);controller.Stop('GUIDE_RUNTIME_ERROR');return end
        local friendOK,friendError=pcall(controller.receiverFilter.update,os.clock())
        if not friendOK then fatalError=clean(friendError);log('FRIEND_FILTER_ERROR',friendError);controller.Stop('FRIEND_FILTER_RUNTIME_ERROR');return end
        local chatOK,chatError=pcall(controller.comeback.update,os.clock())
        if not chatOK then fatalError=clean(chatError);log('COMEBACK_ERROR',chatError);controller.Stop('COMEBACK_RUNTIME_ERROR_NO_RETRY');return end
        local captureAt=os.clock()
        local observed,observeError=pcall(controller.receiverEvidence.Update,captureAt)
        controller.receiverEvidence.maxSeconds=math.max(controller.receiverEvidence.maxSeconds,os.clock()-captureAt)
        if not observed then controller.receiverEvidence.Disable('CAPTURE_ERROR_DISABLED');log('RECEIVER_OBSERVER_ERROR',observeError) end
        controller.history.Update(os.clock())
        controller.bad:heartbeat(now,os.clock()-now,frameCalls)
        maxHeartbeat=math.max(maxHeartbeat,os.clock()-now)
    end)
end)
if not built then controller.Stop('STARTUP_ERROR'); error(buildError) end
log('START','SAFE/MOD/TRUST; '..(controller.jumpTiming.delay>0 and 'short observed-takeoff offset' or 'jump and immediate release')..'; animation after request; optional team comeback; Goal blue LOS')
return controller
