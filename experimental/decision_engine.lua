-- Joint native-candidate ranking. Fresh native guards authorize releases;
-- their optimistic pursuit clearances are distances, never probabilities.
local E={defaults={DevelopingRoutes=true,DevelopmentHorizon=.18,DevelopmentMax=.35}}
local function flat(v)return Vector3.new(v.X,0,v.Z)end
local deliveryOrder={'RiskTier','RiskDebt','Development','RouteStability','ComfortDeficit','CatchHeight','ExcessLoft','RelativeSpeed','ContestGap','PassDistance','Flight'}
function E.new(options)
 local c={};for k,v in pairs(E.defaults)do c[k]=v end
 for k,v in pairs(options or {})do
  assert(c[k]~=nil,'Unsupported evaluator option: '..tostring(k))
  if k=='DevelopingRoutes'then assert(type(v)=='boolean','DevelopingRoutes must be boolean')
  else assert(type(v)=='number'and v==v and v>=0 and v<=.5,'Development horizon must be 0..0.5 seconds')end;c[k]=v
 end
 assert(c.DevelopmentHorizon<=c.DevelopmentMax,'DevelopmentHorizon exceeds DevelopmentMax')
 return setmetatable({config=c,checks=0,maxSeconds=0,holds=setmetatable({},{__mode='k'})},{__index=E})
end
function E.certificate(shot,g)
 local u=shot.unified
 -- Native SmartPass can turn a named Fit/Dime into a head-level endpoint.
 -- A mode label must not grant the looser elevated-pass admission to that path.
 local policy=u and u.HardReason or shot.oscillationBullet and not (g.Strict and g.WideOpen) and 'ZIGZAG_REQUIRES_WIDE_OPEN'
  -- A configured loft is an extra path to clear actual coverage, not a faster
  -- ordinary Dime. The inherited trailing-burn allowance does not establish
  -- that the receiver retains its advantage through this longer flight.
  or shot.variant=='LoftDime' and not g.Strict and 'LOFT_REQUIRES_CLEAR_WINDOW'
  or u and u.FlatNative and shot.mode~='Bullet' and not (g.Strict or g.TrustBurn and g.TrustBurn.Allowed)
  and 'FLAT_NATIVE_REQUIRES_BULLET_GUARDS'
 local allowed=g.Allowed==true and not policy
 local kind=not allowed and 'REJECTED' or g.Strict and 'STRICT_CLEAR_WINDOW'
  or g.TrustBurn and g.TrustBurn.Allowed and 'QUALIFIED_TRAILING_BURN' or 'QUALIFIED_CATCH_WINDOW'
 return allowed,policy or g.Reason or (allowed and 'VIABLE_NATIVE_WINDOW' or 'COVERAGE_REJECTED'),kind
end
function E.admit(shot,g)
 local allowed,reason,kind=E.certificate(shot,g)
 local u=shot.unified
 if u then u.Guard=g;u.Allowed=allowed;u.Reason=reason;u.AdmissionKind=kind end
 return allowed
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
 -- Admission comes first. Configured loft must establish its own clear window;
 -- it cannot win by borrowing the ordinary native Dime's trailing-burn policy.
 -- Within the supported native families, keep modeled path clearance ahead of
 -- cosmetic height so the repair does not restore the old low-Bullet bias.
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
local function compareFields(x,y,fields)
 for _,k in ipairs(fields)do
  if math.abs(x[k]-y[k])>1e-6 then return x[k]<y[k],k end
 end
end
function E.compare(a,b)
 if not b then return true,'ONLY_CANDIDATE' end
 local ar,br=E.allowed(a),E.allowed(b);if ar~=br then return ar,'RELEASE_PERMISSION' end
 local x,y=a.unified.Score,b.unified.Score;if not x or not y then return x~=nil end
 local better,field=compareFields(x,y,deliveryOrder)
 if better~=nil then return better,field end
 return false,'EQUIVALENT_DELIVERY'
end
function E.better(a,b)
 local result=E.compare(a,b);return result
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
