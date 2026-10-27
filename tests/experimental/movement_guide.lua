local setup=dofile('tests/experimental/fixtures/ff3_league_fixture.lua')
local count=0
local function check(v,m)count=count+1;assert(v,m)end
for _,ref in ipairs({'experimental-unified-b3.8','CURRENT'})do
 local src
 if ref=='CURRENT'then src=assert(io.open('experimental/auto_qb.lua')):read('*a')else local p=assert(io.popen('git show '..ref..':experimental/auto_qb.lua'));src=p:read('*a');p:close()end
 src=src:gsub('local built,buildError=pcall%(function%(%)',[[controller.Audit={hold=holdManual,sample=sample,risk=risk,coverage=coverage,allowed=throwable,state=function()return possession,lines,assistance end,seed=function(p,s,shots)shotCache[p]={model=s.model,epoch=possession.epoch,generation=lines.generation,shots=shots}end};local built,buildError=pcall(function()]],1)
 local t=setup({source=src,ff3={RiskMode='SAFE',CloseBullet=false}})
 t.ar.Position=Vector3.new(0,6,-20);t.ar.AssemblyLinearVelocity=Vector3.new(0,0,-15);t.dr.Position=Vector3.new(70,6,170)
 local c=t.run();c.SetThrow(false);t.steps(12)
 local s=c.Audit.sample(t.a,Mock.time)
 local shot={origin=Vector3.new(0,8,80),arrival=s.p+s.v*2+Vector3.new(0,2,0),time=2,mode='Bullet',variant='Bullet',power=95,networkPing=0,at=Mock.time}
 shot.velocity=(shot.arrival-shot.origin)/shot.time+Vector3.new(0,14*shot.time,0)
 local d={name='Blocker',p=Vector3.new(6,6,70),v=Vector3.new(),hum={WalkSpeed=0,JumpPower=50},turn=0,routeTurn=0,observedSpeed=0}
 c.Audit.risk(shot,s,{d});c.Audit.coverage(shot,s,{d})
 check(not c.Audit.allowed(shot),'current path is actually blocked before advisory movement')
 local fit={};for k,v in pairs(shot)do fit[k]=v end;fit.mode='Fit';fit.variant='Fit';fit.fitAllowed=false
 local r={player=t.a,sample=s,shot=fit}
 c.Audit.seed(t.a,s,{Bullet=shot})
 local p,l,a=c.Audit.state()
 c.angle.scene={at=Mock.time,epoch=p.epoch,generation=l.generation,team=t.me.Team,defenders={d}}
 local calls=#Mock.nativeSolveHistory
 c.Audit.hold(r,'MANUAL_LOCK_NO_VALID_AUTO_TRAJECTORY')
 check((a.guidePending~=nil)==(ref=='CURRENT'),'covered manual selection queues guide only in repaired build')
 c.groundGuide.Forecast({r=r,ball={tool=Mock.tool,root=Mock.qroot,hum=Mock.qhum,model=t.me.Character},defenders={d}},Mock.time)
 check((a.guide~=nil)==(ref=='CURRENT'),'Fit selection reuses fresh supported cached trajectory for prediction')
 if ref=='CURRENT'then
  check(a.guide.direction.X<0,'advice points toward modeled clear passing room')
  check(#Mock.nativeSolveHistory==calls and #t.requests==0,'guide uses no native solves, packets, or throw delays')
  c.bad.open=false;c.bad.finalActive=true;c.bad.current.Final={Input={Sentinel=true},SelectedVariant='Bullet',Result={Sentinel=true}}
  c.groundGuide.Forecast({r=r,ball={tool=Mock.tool,root=Mock.qroot,hum=Mock.qhum,model=t.me.Character},defenders={d}},Mock.time)
  check(c.bad.current.Final.Input.Sentinel and c.bad.current.Final.Result.Sentinel,'advisory grades do not overwrite actual final-release evidence')
  c.bad.finalActive=false
  c.groundGuide.Draw(Mock.time)
  check(a.guideUI.Visible,'valid prediction produces projected ground arrow')
  Mock.qroot.Position=Vector3.new(0,6,73);a.guide.direction=Vector3.new(0,0,-1);a.guide.lead=.75;a.nextGuideDraw=0
  c.groundGuide.Draw(Mock.time)
  check(a.guideUI.Visible,'arrow shortens near LOS rather than disappearing')
  a.guide.at=Mock.time-1;a.nextGuideDraw=0;c.groundGuide.Draw(Mock.time)
  check(not a.guideUI.Visible,'expired prediction is hidden')
  c.Audit.seed(t.a,s,{})
  check(not c.groundGuide.SelectShot(r,Mock.time),'missing native trajectory never becomes invented advice')
  t.options.ff3.MovementGuide=false
  c.groundGuide.Forecast({r=r,ball={tool=Mock.tool,root=Mock.qroot,hum=Mock.qhum,model=t.me.Character},defenders={d}},Mock.time)
  c.groundGuide.Draw(Mock.time)
  check(not a.guide and not a.guideUI.Visible,'disabled guide clears prediction and visible arrow')
  check(#t.requests==0,'advisory forecast never sends a release request')
  check(c.unified.Settings().MovementGuide.Status and c.unified.Settings().MovementGuide.Checks,'BAD settings include guide status and work counters')
 end
 check(c.Stop('GUIDE_TEST'),'guide cleanup')
end
print('PASS movement-guide regression checks',count,'(synthetic; camera/mobile visibility and future openings unverified)')
