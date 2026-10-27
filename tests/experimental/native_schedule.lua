local S=dofile('experimental/native_schedule.lua')
local count=0
local function check(ok,reason)count=count+1;assert(ok,reason)end
local modes={'ZigzagBullet','SoftBullet','Bullet','Dime','LoftDime','QuickBullet','Fit','CoverageJump'}
local cacheAge=.36
local function pick(at,tried,now,missing)return S.next(modes,at or {},tried or {},now or 0,cacheAge,missing)end
check(pick({}, {},0,{ZigzagBullet='inactive'})=='Bullet','cold ordinary Bullet precedes optional generator probes')
check(pick({Bullet=0},{},0,{ZigzagBullet='inactive'})=='Dime','cold Dime remains core even with warm Bullet')
check(pick({Bullet=0,Dime=0},{},0,{ZigzagBullet='inactive'})=='SoftBullet','enabled softer native path is core')
local recent={ZigzagBullet=0,Bullet=0,Dime=0,SoftBullet=0}
check(pick(recent,{},.12)=='QuickBullet','unused optional follows fresh cores')
check(pick(recent,{QuickBullet=true},.12)=='Fit','optional cold-start order is explicit')
check(pick(recent,{},.18)=='ZigzagBullet','half-lifetime horizon refreshes a core')
check(pick({ZigzagBullet=.2,Bullet=.1,Dime=.08,SoftBullet=.15},{},.4)=='Dime','oldest due core wins over list order')
check(pick({Bullet=.3,Dime=.3,SoftBullet=.3,ZigzagBullet=.3,QuickBullet=.1,Fit=.15,CoverageJump=.25,LoftDime=.24},{},.4)=='QuickBullet','optional oldest-attempt fairness')
check(pick({}, {},0,{Bullet='off',Dime='off',SoftBullet='off',ZigzagBullet='off',QuickBullet='off',Fit='off',CoverageJump='off',LoftDime='off'})==nil,'all unavailable returns nil')
check(pick()=='ZigzagBullet','verified active oscillator retains its specialized native probe priority')
local tried={};for _,m in ipairs(modes)do tried[m]=true end
check(pick({},tried)==nil,'a group never requests duplicate modes in the same evaluation')
check(S.next({'Bullet','Dime'},{Bullet=0,Dime=0},{},.12,cacheAge)==nil,'fresh cores alone produce no redundant solve')
-- Mirror the existing interleaved two-receiver planner, capped at five native
-- calls per tick. Each scheduled optional is continuously available here.
local groups={{at={},last={},seen={}},{at={},last={},seen={}}}
local maximumGap=0;local optionalSeen={}
for tick=0,119 do
 local now=tick*.12;local calls=0;local allTried={{},{}}
 for pass=1,#modes do
  for offset=1,2 do
   if calls<5 then
    local index=(offset+tick)%2+1;local g=groups[index]
    local mode=pick(g.at,allTried[index],now)
    if mode then
     check(not allTried[index][mode],'no duplicate native probe in group/tick')
     allTried[index][mode]=true;g.at[mode]=now;calls=calls+1
     g.seen[mode]=(g.seen[mode]or 0)+1
     if mode=='ZigzagBullet'or mode=='Bullet'or mode=='Dime'or mode=='SoftBullet'then
      if g.last[mode]then maximumGap=math.max(maximumGap,now-g.last[mode])end
      g.last[mode]=now
     else optionalSeen[index..'/'..mode]=true end
    end
   end
  end
 end
 check(calls<=5,'original five-call planning cap remains sufficient')
end
check(maximumGap<=cacheAge+1e-6,'steady five-call/two-WR schedule refreshes every core before expiry')
for i,g in ipairs(groups)do
 for _,mode in ipairs(modes)do check(g.seen[mode]and g.seen[mode]>1,'every continuously available alternative eventually repeats '..i..'/'..mode)end
end
-- Availability changes do not manufacture work or mutate caller timestamps.
local unavailable={SoftBullet='disabled',ZigzagBullet='no reversal',QuickBullet='not close',CoverageJump='off',LoftDime='arc off'}
local at={Bullet=0,Dime=0,Fit=0};local mode=pick(at,{},.12,unavailable)
check(mode=='Fit','cheaply unavailable modes never consume native slots')
check(at.Bullet==0 and not at.SoftBullet,'selecting work does not claim a native attempt')
local noModes=S.next({}, {},{},0,cacheAge,{})
check(noModes==nil,'empty mode list terminates without work')
print('PASS native schedule',count,'checks; max steady core gap',maximumGap,'(synthetic capacity/fairness, not live timing)')
