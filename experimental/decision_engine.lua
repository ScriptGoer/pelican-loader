-- Build B: scores are uncalibrated costs, never probabilities.
local E={}
E.defaults={Acceleration=36,ReactionSeconds=.12,HorizontalReach=4.5,VerticalReach=12.2,
    PositionUncertainty=.35,VelocityUncertainty=.5,Samples=16,ContestRelief=.75,DistanceScale=1.5,
    SafeRisk=.16,ModRisk=.32,TrustRisk=.58,RiskWeight=70,ComfortWeight=8,TouchdownValue=45}
local function clamp(x,a,b)return math.max(a,math.min(b,x))end
local function flat(v)return v*Vector3.new(1,0,1)end
local function sigmoid(x)return 1/(1+math.exp(-clamp(x,-30,30)))end
local function speed(s)return math.max(flat(s.v).Magnitude,s.hum and s.hum.WalkSpeed or 0,s.observedSpeed or 0)end
function E.new(options)
    local c={};for k,v in pairs(E.defaults)do c[k]=v end
    for k,v in pairs(options or {})do
        assert(c[k]~=nil and type(v)=='number' and v==v and v>=0 and v<10000,'Invalid evaluator parameter: '..tostring(k));c[k]=v
    end
    assert(c.Samples>=4 and c.Samples<=32 and c.Samples%1==0,'Samples must be 4..32')
    assert(c.SafeRisk<=c.ModRisk and c.ModRisk<=c.TrustRisk and c.TrustRisk<=1,'Risk caps must be nested in [0,1]')
    assert(c.ContestRelief<=1 and c.DistanceScale>0,'ContestRelief must be <=1 and DistanceScale positive')
    assert(c.HorizontalReach>0 and c.VerticalReach>0,'Reach assumptions must be positive')
    return setmetatable({config=c,checks=0,maxSeconds=0},{__index=E})
end
local function step(p,v,target,dt,cap,a,react)
    if not react then
        local delta=flat(target-p);local desired=delta.Magnitude>0 and delta.Unit*cap or v*0
        local change=desired-v;v=v+(change.Magnitude>0 and change.Unit*math.min(change.Magnitude,a*dt) or change)
    end
    if v.Magnitude>cap then v=v.Unit*cap end
    return p+v*dt,v
end
local function nearestSegment(b0,b1,p0,p1)
    local r=flat(b0-p0);local delta=flat((b1-p1)-(b0-p0))
    local f=delta:Dot(delta)>0 and clamp(-r:Dot(delta)/delta:Dot(delta),0,1) or 0
    return (r+delta*f).Magnitude,f
end
function E:evaluate(shot,wr,defenders,context)
    local begun=os.clock();local c=self.config;self.checks=self.checks+1
    local t=shot.time;local result={Allowed=false,HardReason=nil,Threats={},RiskScore=0,Score=-1e9,Calibration='UNVERIFIED_MODEL_COSTS'}
    shot.unified=result
    if type(t)~='number' or t~=t or t==math.huge or t<=0 or not shot.origin or not shot.velocity or not shot.arrival then result.HardReason='INVALID_TRAJECTORY';return result end
    local ping=math.max(0,shot.networkPing or 0)
    local wrEnd=wr.p+flat(wr.v)*(t+ping)
    local adjustment=flat(shot.arrival-wrEnd).Magnitude
    local endVelocity=shot.velocity-Vector3.new(0,context.gravity*t,0)
    local relativeSpeed=(endVelocity-wr.v).Magnitude
    local height=shot.arrival.Y-(wr.head and wr.head.Position.Y or wr.p.Y+2)
    local travel=flat(shot.arrival-wr.p).Magnitude
    -- Necessary travel check is shared with production. This adds a bounded
    -- acceleration correction around current motion, not free omnidirectional speed.
    if travel>speed(wr)*(t+ping)+c.HorizontalReach or adjustment>c.HorizontalReach+.5*c.Acceleration*t*t then
        result.HardReason='RECEIVER_MOVEMENT_INFEASIBLE'
    end
    result.CatchDifficulty=relativeSpeed/60+adjustment/(c.HorizontalReach+speed(wr)*t*.25)
        +math.max(0,height-1)/3+math.max(0,-height-2)/3+math.max(0,t-1.4)^2
    result.ArrivalRelativeSpeed=relativeSpeed;result.HeightAboveHead=height;result.Adjustment=adjustment
    local bestAdvantage=100
    for index,d in ipairs(defenders)do
        local p=d.p+flat(d.v)*ping;local v=flat(d.v);local p2,v2=p,v
        local threat,early,closest=0,0,math.huge
        local receiverP,receiverV=wr.p+flat(wr.v)*ping,flat(wr.v)
        local dt=t/c.Samples
        local relativeEnd=wrEnd-(d.p+flat(d.v)*(t+ping))
        local route=flat(wr.v)
        local positionAdvantage=route.Magnitude>0 and math.min(relativeEnd:Dot(route.Unit),flat(wr.p-d.p):Dot(route.Unit)) or flat(relativeEnd).Magnitude-adjustment
        for i=1,c.Samples do
            local at=i*dt;local previousP,previousP2,previousReceiver=p,p2,receiverP
            local ball0=shot.origin+shot.velocity*(at-dt)-Vector3.new(0,.5*context.gravity*(at-dt)^2,0)
            local ball=shot.origin+shot.velocity*at-Vector3.new(0,.5*context.gravity*at*at,0)
            p,v=step(p,v,shot.arrival,dt,speed(d),c.Acceleration,at<=c.ReactionSeconds)
            p2,v2=step(p2,v2,ball,dt,speed(d),c.Acceleration,at<=c.ReactionSeconds)
            receiverP,receiverV=step(receiverP,receiverV,ball,dt,speed(wr),c.Acceleration,at<=c.ReactionSeconds)
            local distance,f=nearestSegment(ball0,ball,previousP,p)
            local distance2,f2=nearestSegment(ball0,ball,previousP2,p2)
            if distance2<distance then distance,f=distance2,f2 end
            local contact=at-dt+f*dt
            local contactBall=shot.origin+shot.velocity*contact-Vector3.new(0,.5*context.gravity*contact*contact,0)
            local vertical=contactBall.Y-d.p.Y
            if vertical>=-2 and vertical<=c.VerticalReach then
                local uncertainty=c.PositionUncertainty+c.VelocityUncertainty*(at+ping)
                local receiverDistance=math.min(flat(contactBall-(wr.p+flat(wr.v)*(contact+ping))).Magnitude,flat(contactBall-(previousReceiver+(receiverP-previousReceiver)*f)).Magnitude)
                local supportAdjustment=flat(receiverP-(wr.p+flat(wr.v)*(at+ping))).Magnitude
                local advantage=distance-receiverDistance
                -- Overlapping WR/DB catch neighborhoods form a contest, not an
                -- automatic DB win. Relief depends continuously on momentum advantage.
                local receiverAccess=sigmoid((2*c.HorizontalReach-receiverDistance)/c.DistanceScale)
                local access=sigmoid((c.HorizontalReach+uncertainty-distance)/c.DistanceScale)
                local contest=access*(1-c.ContestRelief*receiverAccess*sigmoid(positionAdvantage/c.DistanceScale))
                if contest>threat then result.SupportAdjustment=math.max(result.SupportAdjustment or 0,supportAdjustment*receiverAccess*contest) end
                threat=math.max(threat,contest);closest=math.min(closest,distance)
                if receiverDistance>c.HorizontalReach then early=math.max(early,contest)end
            end
        end
        local adv=flat(shot.arrival-p).Magnitude-flat(shot.arrival-wrEnd).Magnitude
        bestAdvantage=math.min(bestAdvantage,adv)
        result.RiskScore=1-(1-result.RiskScore)*(1-threat) -- pooled risk COST, not independence/probability claim
        if threat>.02 then result.Threats[#result.Threats+1]={Defender=d.name or tostring(index),RiskScore=threat,EarlyRisk=early,
            EndpointAdvantage=adv,MinimumDistance=closest<math.huge and closest or nil}end
    end
    result.CatchDifficulty=result.CatchDifficulty+(result.SupportAdjustment or 0)/(2*c.HorizontalReach)
    result.ReceiverAdvantage=bestAdvantage
    result.ScoringValue=math.max(0,context.gain or 0)+(context.endzone and c.TouchdownValue or 0)
    result.Score=result.ScoringValue-c.RiskWeight*result.RiskScore-c.ComfortWeight*result.CatchDifficulty
    result.RiskCaps={SAFE=c.SafeRisk,MOD=c.ModRisk,TRUST=c.TrustRisk}
    result.Allowed=not result.HardReason and result.RiskScore<=result.RiskCaps[context.mode]
    result.Reason=result.HardReason or (result.Allowed and 'VIABLE_OPPORTUNITY' or 'RISK_TOLERANCE')
    self.maxSeconds=math.max(self.maxSeconds,os.clock()-begun)
    return result
end
function E.allowed(shot,mode)
    local u=shot.unified;return u~=nil and not u.HardReason and u.RiskScore<=u.RiskCaps[mode]
end
function E.better(a,b,mode)
    if not b then return true end
    local ar,br=E.allowed(a,mode),E.allowed(b,mode)
    if ar~=br then return ar end
    if a.unified.Score~=b.unified.Score then return a.unified.Score>b.unified.Score end
    return a.time<b.time
end
return E
