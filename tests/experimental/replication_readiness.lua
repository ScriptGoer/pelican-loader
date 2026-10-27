-- Receiver pose can arrive in bursts while replicated velocity remains valid.
-- The source-shaped server/native fixture does not establish Roblox timing.
local setup=dofile('tests/experimental/fixtures/ff3_league_fixture.lua')
local count=0
local function check(ok,label)count=count+1;assert(ok,label)end
local function source(ref)
 local p=assert(io.popen('git show '..ref..':experimental/auto_qb.lua'));local s=p:read('*a');p:close();return s
end
local current=assert(io.open('experimental/auto_qb.lua')):read('*a')
local function run(code,moving)
 local t=setup({source=code,freezeReceivers=true,ff3={Profile='CASUAL',RiskMode='SAFE'}})
 t.ar.Position=Vector3.new(15,6,30);t.ar.AssemblyLinearVelocity=Vector3.new(8,0,0)
 local c=t.run();local maximum=0
 for i=1,180 do
  if moving and i%6==0 then t.ar.Position=t.ar.Position+Vector3.new(.8,0,0)end
  maximum=math.max(maximum,t.advance(1/60));t.drain()
  if #t.requests>0 then break end
 end
 return t,c,maximum
end
local baseline,old=run(source('experimental-unified-b3.2'),true)
check(#baseline.requests==1,'B3.2 accepts an open runner whose position arrives every six frames')
check(old.Stop('REFERENCE'),'B3.2 cleanup')
local broken,b=run(source('experimental-unified-b3.3'),true)
check(#broken.requests==0 and b.GetReport():find('IDLE_OR_ROUTE_NOT_READY',1,true),'B3.3 reproduces false idle rejection with the same moving runner')
check(b.Stop('REPRODUCED'),'B3.3 cleanup')
local repaired,c,maximum=run(current,true)
check(#repaired.requests==1,'current runtime takes the moving open receiver despite sparse pose replication')
check(maximum<=8 and c.Stop('FIXED'),'repaired path retains native budget and cleanup')
local afk,a=run(current,false)
check(#afk.requests==0,'unchanged position with stale nonzero velocity is still refused as AFK')
check(a.Stop('AFK'),'AFK cleanup')
local E=assert(loadfile('experimental/decision_engine.lua'))()
local engine=E.new();local wr={p=Vector3.new(0,6,30),head={Position=Vector3.new(0,8.5,30)},v=Vector3.new(8,0,0)}
local function placed(y,leadY,grounded)
 local origin=Vector3.new(0,8,80);local arrival=Vector3.new(8,y,30)
 local sh={origin=origin,arrival=arrival,velocity=arrival-origin+Vector3.new(0,14,0),time=1,mode='Dime',appliedLead={X=3,Y=leadY}}
 engine:evaluate(sh,wr,{}, {gravity=28,ReceiverGrounded=grounded,OpenComfort=true,ComfortSeconds=.9,Guard={Allowed=true,Strict=true,Margin=45,Lane=45}})
 return sh
end
local body=placed(7,0,true);local low=placed(5,0,true)
check(E.allowed(body),'grounded body-level placement remains admitted')
check(not E.allowed(low) and low.unified.Reason=='NATIVE_PLACEMENT_BELOW_RECEIVER_BODY','unexpected below-body native placement cannot silently count as an easy catch')
check(low.unified.Score.CatchHeight>body.unified.Score.CatchHeight,'comfort ranking no longer gives foot-level arrivals a free height score')
check(E.allowed(placed(5,-2,true)),'explicitly negative user lead is not silently overridden')
check(E.allowed(placed(5,0,false)),'airborne receiver is not constrained to the current elevated body position')
check(E.allowed(placed(5.9999999,0,true)),'numeric rounding at the body reference is tolerated')
local function lowRuntime(code)
 local t=setup({source=code,ff3={Profile='CASUAL',RiskMode='SAFE'},nativeModes={Dime=true},modeShots=function(mode,model,origin)
  local r=model.PrimaryPart;local arrival=r.Position+r.AssemblyLinearVelocity+Vector3.new(0,-1,0)
  return {velocity=arrival-origin+Vector3.new(0,14,0),time=1,aimpoint=arrival}
 end})
 t.ar.Position=Vector3.new(15,6,30);t.ar.AssemblyLinearVelocity=Vector3.new(8,0,0)
 t.a.Character:FindFirstChildOfClass('Humanoid').FloorMaterial=Enum.Material.Ground
 local c=t.run();t.steps(18);return t,c
end
local oldLow,oldC=lowRuntime(source('experimental-unified-b3.3'))
check(#oldLow.requests==1 and oldC.Stop('LOW_REFERENCE'),'B3.3 reproduces admission of an unexpected low native result')
local fixedLow,lowC=lowRuntime(current)
check(#fixedLow.requests==0 and lowC.GetReport():find('NATIVE_PLACEMENT_BELOW_RECEIVER_BODY',1,true),'actual corrected controller refuses the same low native result before sending')
check(lowC.Stop('LOW_FIXED'),'low placement rejection cleans up')
print('PASS sparse-replication readiness checks',count,'(synthetic comparison of actual controllers)')
