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
