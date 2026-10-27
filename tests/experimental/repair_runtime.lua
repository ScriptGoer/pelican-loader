-- Native-shaped local runtime contracts. No live catching or server simulation.
local setup=dofile('tests/experimental/fixtures/ff3_league_fixture.lua')
local current=assert(io.open('experimental/auto_qb.lua')):read('*a')
local baseline=assert(io.open('games/ff3/auto_qb.lua')):read('*a')
local pipe=assert(io.popen('git show 4a4689b:experimental/auto_qb.lua'));local buildb=pipe:read('*a');pipe:close()
local checks=0
local function check(v,label)checks=checks+1;assert(v,label)end
local function instrument(source)
 local s,n=source:gsub('local built,buildError=pcall%(function%(%)',[[
controller.Audit={risk=risk,coverage=coverage,allowed=throwable,solve=solve,deep=deepThrow,evaluate=evaluate,sample=sample,
 state=function()return possession,lines end,
 seed=function(p,s,shots)shotCache[p]={model=s.model,epoch=possession.epoch,generation=lines.generation,shots=shots,rotation=0}end}
local built,buildError=pcall(function()]],1);assert(n==1);return s
end
local function scene(source,ff3,extra)
 local o=extra or {};o.source=instrument(source or current);o.newSafetyDefaults=true;o.newSharedCoverageDefaults=true;o.newJumpTimingDefaults=true;o.newReactiveDefaults=true
 o.ff3=ff3 or {};o.ff3.Profile=o.ff3.Profile or 'CASUAL'
 local t=setup(o);t.ar.Position=Vector3.new(0,6,20);t.ar.AssemblyLinearVelocity=Vector3.new(6,0,-6)
 t.dr.Position=Vector3.new(65,6,-155)
 local c=t.run();c.SetThrow(false);t.steps(12);return t,c,c.Audit
end
local function actor(x,z,vx,vz)
 return {name='TestActor',p=Vector3.new(x,3,z),v=Vector3.new(vx,0,vz),turn=0,routeTurn=0,observedSpeed=math.sqrt(vx*vx+vz*vz),hum={WalkSpeed=20,JumpPower=50}}
end
local function native(w,time,mode,power)
 local arrival=w.p+w.v*time+Vector3.new(0,2,0);local origin=Vector3.new(0,5,0)
 return {origin=origin,arrival=arrival,velocity=(arrival-origin)/time+Vector3.new(0,14*time,0),time=time,mode=mode or 'Bullet',variant=mode or 'Bullet',power=power or 80,networkPing=0,receiverResidual=0,at=Mock.time}
end
-- Verify the advertised code-level regressions against both original sources.
for _,case in ipairs({{source=baseline,name='V26.22'},{source=buildb,name='Build B'},{source=current,name='B3'}})do
 local t,c,a=scene(case.source,{RiskMode='TRUST'})
 local wr=actor(0,-40,0,-20);local corner=actor(0,-36,0,-20)
 local s={mode='Bullet',variant='Bullet',power=95,origin=Vector3.new(0,5,0),velocity=Vector3.new(0,12,-60),arrival=Vector3.new(0,3,-60),time=1,networkPing=0,receiverResidual=0,at=Mock.time}
 a.risk(s,wr,{corner});a.coverage(s,wr,{corner})
 check(a.allowed(s)==(case.name~='B3'),'legacy four-stud low Bullet waiver is retired only in repaired experiment '..case.name)
 if case.name=='B3' then
  check(s.trustBurn and s.trustBurn.Allowed and s.unified.Reason=='BULLET_REQUIRES_STRICT_COVERAGE','ordinary Bullet cannot borrow the retained trailing-gap evidence')
  for _,d in ipairs({actor(0,-20,0,0),actor(0,-36,0,-30),actor(0,-70,0,20)})do
   local bad=native(wr,1,'Bullet',95);a.risk(bad,wr,{d});a.coverage(bad,wr,{d})
   check(not a.allowed(bad),'underneath/closing/help threat refuses TRUST release')
  end
 end
 local fast=native(wr,.4,'Bullet',95);a.risk(fast,wr,{});a.coverage(fast,wr,{})
 check((fast.powerAllowed~=false)==(case.name=='Build B'),'only Build B bypasses actual full-power comfort eligibility')
 Mock.qhum.UseJumpPower=true;Mock.qhum.JumpPower=50
 check(a.deep({time=1},Mock.qhum)==(case.name~='Build B'),'deep jump classification functional in '..case.name)
 check(c.Stop('COMPARE'),'comparative cleanup')
end
-- Real automatic deep native solve: takeoff and short release offset are restored.
for _,profile in ipairs({'CASUAL','LEAGUE'})do
 local t,c=scene(current,{Profile=profile,RiskMode='TRUST',PassPlan='DEEP',CloseBullet=false},
  {simulateJump=true,changeState=true,stateJumpWorks=true,nativeModes={Dime=true}})
 Mock.qhum.UseJumpPower=true;Mock.qhum.JumpPower=50
 t.ar.Position=Vector3.new(0,6,-30);t.ar.AssemblyLinearVelocity=Vector3.new(0,0,-10)
 t.steps(10);c.SetThrow(true)
 local max=0;for _=1,160 do max=math.max(max,t.advance(1/60));t.drain()end
 local p=t.payload()
 check(p and #t.requests==1,'deep native opportunity actually releases in '..profile)
 check(p.JumpObservedDelay and p.JumpObservedDelay>=.075 and p.JumpObservedDelay<.12,'deep release uses observed takeoff offset')
 check(p.Mode=='Dime' and p.CatchDepthYards>=20 and max<=8,'DEEP plan and native budget retain actual effect')
 check(c.bad.current.Final.Native and c.bad.current.Final.Checks and c.bad.current.Final.Input,'final native/guard/input captured')
 check(c.bad.current.ReleasedDecision and c.bad.current.Final.SelectedVariant==p.Variant,'actual release pins its competing-candidate snapshot')
 check(c.Stop('DEEP'),'deep cleanup')
end
-- All public controls must connect to live policy, not just change labels.
local t,c,a=scene(current,{RiskMode='SAFE'})
check(c.bad.current.Settings.Leads.Bullet and c.bad.current.Settings.AutomaticThrow==false,'withheld possession preserves lead/settings data without a final attempt')
local gui=t.ui();local compact=gui:FindFirstChild('CompactQB')
check(compact and compact.Text=='QB' and compact.Size.X.Offset==54,'folded QB pill is small and quiet')
check(not c.badButton.Visible and not c.badCurrentButton.Visible and gui:FindFirstChild('ThrowAway').Visible,'BAD stays folded while AWAY is immediately available')
compact.Activated:Fire();check(not c.badButton.Visible,'BAD is not on the normal PLAY page')
c.unified.toolsButton.Activated:Fire();check(c.badButton.Visible and c.badCurrentButton.Visible,'BAD controls only appear inside TOOLS')
c.unified.toolsButton.Activated:Fire()
check(not c.mag.button.Visible,'unsupported mag trial is absent, not a dead visible switch')
check(c.SetMagTrial(true)==false and c.SetJumpBullet(true)==false,'unsupported native-point experiments reject explicit activation')
local risk=gui:FindFirstChild('RiskMode');risk.Activated:Fire();check(c.GetReport():find('\nRISK_MODE|MOD\n',1,true),'risk UI reaches actual MOD policy')
risk.Activated:Fire();check(c.GetReport():find('\nRISK_MODE|TRUST\n',1,true),'risk UI reaches actual TRUST policy')
local wr=actor(0,-40,0,-20);local corner=actor(0,-36,0,-20)
local s={mode='Bullet',variant='Bullet',power=95,origin=Vector3.new(0,5,0),velocity=Vector3.new(0,12,-60),arrival=Vector3.new(0,3,-60),time=1,networkPing=0,receiverResidual=0,at=Mock.time}
a.risk(s,wr,{corner});a.coverage(s,wr,{corner});check(not a.allowed(s) and s.unified.Reason=='BULLET_REQUIRES_STRICT_COVERAGE','TRUST UI keeps ordinary Bullet strict')
c.SetRiskMode('MOD');a.risk(s,wr,{corner});a.coverage(s,wr,{corner});check(not a.allowed(s),'MOD UI cannot borrow TRUST contest relief')
-- Native-supported OpenComfort ranking is explicitly toggleable.
c.unified.easeButton.Activated:Fire();check(not c.passPlan.openComfort,'EASE button changes OpenComfort')
c.unified.easeButton.Activated:Fire();check(c.passPlan.openComfort,'EASE button restores OpenComfort')
local function open(mode,time,power)
 local w=actor(0,40,8,0);local sh=native(w,time,mode,power);sh.variant=mode=='Bullet'and(power<94.5 and 'QuickBullet'or'Bullet')or mode
 a.risk(sh,w,{});a.coverage(sh,w,{});a.allowed(sh);return sh
end
local quick=open('Bullet',.68,70);local gentle=open('Bullet',.95,50)
check(c.unified.better(gentle,quick),'comfortable wide-open native endpoint beats unnecessarily fast pass')
local natural=open('Dime',1,60);local floating=open('Dime',3,60);check(c.unified.better(natural,floating),'comfortable direct opportunity beats gratuitous floating trajectory')
c.SetOpenComfort(false);quick=open('Bullet',.68,70);gentle=open('Bullet',.95,50)
check(c.unified.better(quick,gentle),'EASE OFF changes actual ordering, not just text')
c.SetOpenComfort(true)
c.SetAdaptiveAngle(false);check(not c.angle.enabled,'ARC control changes native adapter flag')
c.angle.button.Activated:Fire();check(c.angle.enabled,'ARC control restores adaptive native calculations')
c.SetNativeJump(false);check(not c.nativeJump.enabled,'HIGH OFF removes native receiver Jump planning')
check(a.solve(t.a,'CoverageJump')==nil,'HIGH OFF prevents actual native Jump solve')
c.jumpBullet.button.Activated:Fire();check(c.nativeJump.enabled,'HIGH button restores native Jump')
-- Plan filters including the old supported deep-comeback and short wide exception.
c.SetPassPlan('DEEP');local short=native(actor(0,40,8,0),.95,'Bullet',60);a.risk(short,actor(0,40,8,0),{});a.coverage(short,actor(0,40,8,0),{})
check(not a.allowed(short),'DEEP excludes ordinary shallow candidate')
local possession,field=a.state();local back=actor(0,30,0,8);back.depthEpoch=possession.epoch;back.depthGeneration=field.generation;back.depthPeakYards=25
local comeback=native(back,.95,'Bullet',60);a.risk(comeback,back,{});a.coverage(comeback,back,{})
check(comeback.deepComeback and a.allowed(comeback),'DEEP preserves observed developed-route comeback exception')
c.SetPassPlan('SHORT');local deep=native(actor(0,-40,0,-6),1.5,'Bullet',95);a.risk(deep,actor(0,-40,0,-6),{});a.coverage(deep,actor(0,-40,0,-6),{})
check(a.allowed(deep) and deep.wideOpen,'SHORT retains genuine wide-open deep exception')
c.SetPassPlan('NORMAL');a.risk(short,actor(0,40,8,0),{});a.coverage(short,actor(0,40,8,0),{});check(a.allowed(short),'NORMAL restores shallow completion')
check(c.SetBlacklisted(t.a,true),'blacklist API active');t.steps(2);check(c.GetReport():find('BLACKLISTED',1,true),'blacklist excludes actual teammate eligibility');c.SetBlacklisted(t.a,false)
gui:FindFirstChild('Receivers').Activated:Fire()
local menu=gui:FindFirstChild('ReceiverList')
check(menu:FindFirstChild('Title').Text=='Tap: normal > block','WR list describes the effective two-state policy')
menu:FindFirstChild('Receiver1').Activated:Fire();check(c.GetReceiverState(t.a)=='BLOCKED','first WR tap actually blocks selection')
menu:FindFirstChild('Receiver1').Activated:Fire();check(c.GetReceiverState(t.a)=='NORMAL','second WR tap restores selection without an inert trust step')
check(not c.SetReceiverState(t.a,'TRUSTED'),'manual mag trust cannot be enabled through a stale API')
gui:FindFirstChild('Receivers').Activated:Fire()
c.SetAuto(false);check(not t.q.Locked,'AUTO OFF releases native lock')
c.SetAuto(true);c.SetThrow(false);t.steps(3);check(#t.requests==0,'THR OFF preserves selection without throws')
compact.Activated:Fire();check(not c.badButton.Visible and compact.Text=='QB','folding removes BAD touch area again')
check(c.Stop('UI'),'controls cleanup')
-- Developing route forecast is conditional, bounded and abandons a hold if a
-- changing window requires an immediate throw. No unobserved route cut is asserted.
local E=assert(loadfile('experimental/decision_engine.lua'))();local e=E.new()
local w={name='Route',p=Vector3.new(20,6,52),v=Vector3.new(10,0,-8),acceleration=Vector3.new(-10,0,-8),hum={WalkSpeed=20}}
local function route(urgent,goal)
 local sh=native(w,.95,'Bullet',65);sh.origin=Vector3.new(0,8,80);sh.velocity=(sh.arrival-sh.origin)/sh.time+Vector3.new(0,14*sh.time,0)
 local g={Allowed=true,Strict=true,WideOpen=not urgent,DefenderETA=urgent and 1 or 4,Margin=20,Lane=20}
 local context={gravity=28,Guard=g,ForwardX=0,ForwardZ=-1,CurrentDepthYards=6.05,MinDepthYards=6,OpenComfort=true,ComfortSeconds=.9,GoalOrScreen=goal}
 e:evaluate(sh,w,{},context);return sh
end
local developing=route(false,false)
check(developing.unified.Developing,'near-threshold observed momentum predicts easier continuation')
local player={};check(e:wait(player,w,1,developing,10),'developing wide window gets bounded continuation')
check(not e:wait(player,w,1,route(true,false),10.02),'brief/closing window cancels wait immediately')
check(not e:wait({},w,1,route(false,true),10),'goal/screen never inherits six-yard development hold')
local closing=route(false,false);local context={gravity=28,Guard={Allowed=true,Strict=true,WideOpen=true,DefenderETA=4,Margin=12,Lane=8,ThreatSpeed=50},ForwardZ=-1,CurrentDepthYards=6.05,MinDepthYards=6,OpenComfort=true,ComfortSeconds=.9}
e:evaluate(closing,w,{},context);check(not closing.unified.Developing,'rapidly closing wide-looking window is not held')
local another={};check(e:wait(another,w,1,developing,10),'new possession can consider continuation')
check(not e:wait(another,w,1,developing,10.19),'continuation cannot renew itself indefinitely')
w.v=Vector3.new(0,0,-12);w.acceleration=nil
check(not route(false,false).unified.Developing,'straightened natural route releases without artificial timer')
-- A real sampler crosses eligibility on a diagonal, then straightens. Waiting
-- is cancelled as soon as the forecast no longer helps (not a universal timer).
do
 local t=setup({source=instrument(current),newSafetyDefaults=true,newSharedCoverageDefaults=true,newJumpTimingDefaults=true,newReactiveDefaults=true,ff3={Profile='CASUAL'}})
 t.ar.Position=Vector3.new(20,6,68);t.ar.AssemblyLinearVelocity=Vector3.new(8,0,-8);t.dr.Position=Vector3.new(65,6,-155)
 local c=t.run();c.SetThrow(false);t.steps(8);c.SetThrow(true)
 for _=1,10 do t.advance(.13);t.drain();if c.GetReport():find('\nGATE|DEVELOPING_ROUTE_CONTINUATION',1,true)then break end end
 check(#t.requests==0 and c.GetReport():find('\nGATE|DEVELOPING_ROUTE_CONTINUATION',1,true),'actual near-threshold opportunity conditionally waits')
 local started=Mock.time;t.ar.AssemblyLinearVelocity=Vector3.new(0,0,-12)
 for _=1,12 do t.advance(1/60);t.drain();if #t.requests>0 then break end end
 check(#t.requests==1 and Mock.time-started<.18,'actual straightened route releases before original continuation expiry')
 check(c.bad.current.Timing and c.Stop('DEVELOPMENT'),'timing evidence and cleanup persist')
end
-- A simulated slow grade must not make fresh competing cached modes disappear.
-- This uses synthetic cache entries, not an assertion that native emits them.
do
 local slow=current:gsub('local gradeStarted=os.clock%(%)','local gradeStarted=os.clock();Mock.time=Mock.time+.004',1)
 local t,c,a=scene(slow,{Profile='CASUAL'})
 t.br.Position=Vector3.new(-30,6,25);t.br.AssemblyLinearVelocity=Vector3.new(6,0,-6);t.steps(10)
 local receivers={}
 for _,p in ipairs({t.a,t.b})do
  local sample=a.sample(p,Mock.time);local shots={}
  for _,variant in ipairs({'SoftBullet','QuickBullet','Bullet'})do
   local sh=native(sample,variant=='QuickBullet'and .7 or .95,'Bullet',variant=='Bullet'and 95 or 60)
   sh.variant=variant;sh.softBullet=variant~='Bullet';shots[variant]=sh
  end
  a.seed(p,sample,shots);receivers[#receivers+1]={player=p,sample=sample}
 end
 a.evaluate(receivers,{}, {},Mock.time)
 local count=0;for _,row in pairs(c.bad.frame.Rows)do if row.Status=='EVALUATED'then count=count+1 end;check(row.Reason~='GRADING_BUDGET','fresh mode is never silently skipped at 3 ms')end
 check(count==6,'all six fresh native-shaped alternatives are graded despite synthetic 4-ms guard work')
 check(c.bad.profile.OverBudget>0 and c.Stop('BUDGET'),'expensive grade is measured rather than hidden')
end
-- Export a real controller-captured synthetic throw for the external replay CLI.
do
 local t,c=scene(current,{RiskMode='SAFE'});c.SetThrow(true);t.steps(8)
 check(#t.requests==1 and c.bad:flag(Mock.time),'actual runtime BAD THROW captures latest attempt')
 local report=c.bad:report();check(report.Possession.Final.Checks.Status=='ALL_RELEASE_GUARDS_PASSED','export contains actual final passed checks')
 check(report.Possession.FirstPlan.Settings.NativeContext.Signature and report.Possession.FirstPlan.Settings.Risk=='SAFE','critical candidate cohort pins native/settings context at its own decision time')
 local function json(v)
  if v==nil then return 'null'end
  if type(v)=='string'then return '"'..v:gsub('\\','\\\\'):gsub('"','\\"'):gsub('\n','\\n')..'"'end
  if type(v)=='number'or type(v)=='boolean'then return tostring(v)end
  local out={};if #v>0 then for _,x in ipairs(v)do out[#out+1]=json(x)end;return '['..table.concat(out,',')..']'end
  for k,x in pairs(v)do out[#out+1]=json(tostring(k))..':'..json(x)end;return '{'..table.concat(out,',')..'}'
 end
 local text=json(report);check(not text:find('OpenWR',1,true)and not text:find('OtherWR',1,true),'real export stays anonymous')
 local f=assert(io.open('/tmp/pelican-b3-runtime-report.json','w'));f:write(text);f:close()
 local savedCopy=setclipboard;setclipboard=nil
 local ok,where=c.ExportBadPlay();check(ok and where=='SAVED','file-only export never claims a successful clipboard copy')
 local firstFile=report.ExportFile;check(firstFile and isfile(firstFile),'unique first flagged report saved')
 local firstContents=readfile(firstFile)
 c.unified.clearButton.Activated:Fire();check(c.bad:report()==nil and t.env.PELICAN_FF3_BAD_PLAY_REPORT==nil,'CLEAR BAD restores normal DATA/COPY workflow')
 check(c.bad:flag(Mock.time,true),'MISSED/current flag remains available separately from last attempted throw')
 for i=1,3 do
  check(c.ExportBadPlay(),'additional flag exports');local nextFile=c.bad:report().ExportFile
  check(nextFile~=firstFile and isfile(nextFile),'each flag uses a separate saved file')
  if i<3 then check(c.bad:flag(Mock.time,true),'next independent flag')end
 end
 check(readfile(firstFile)==firstContents,'four flags do not overwrite the first report')
 check(#t.env.PELICAN_FF3_BAD_PLAY_ARCHIVE==4,'session archive retains all four flags')
 check(c.bad:report().Version=='experimental-unified-b4.1','report version matches actual published build')
 setclipboard=savedCopy

 check(c.Stop('CAPTURE'),'capture cleanup')
end

-- Direction-sensitive direct-path evidence is retained even when conservative
-- full-speed pursuit refuses both contested endpoints.
do
 local t,c,a=scene(current,{RiskMode='TRUST'});local wr=actor(0,-40,0,-20)
 local toward=native(wr,1,'Bullet',95);local away=native(wr,1,'Bullet',95)
 a.risk(toward,wr,{actor(12,-50,-20,0)});a.coverage(toward,wr,{actor(12,-50,-20,0)})
 a.risk(away,wr,{actor(12,-50,20,0)});a.coverage(away,wr,{actor(12,-50,20,0)})
 check(toward.directLane<away.directLane,'opposite defensive pursuit changes direct interception evidence')
 check(c.Stop('DIRECTION'),'direction scene cleanup')
end
-- Ease is only a ranking preference; switching it off cannot waive native-high proof.
do
 local t,c,a=scene(current,{SafetyReads=false,OpenComfort=false})
 local raised={mode='Jump',variant='CoverageJump',nativeCoverageJump=true,time=1,power=80,margin=12,lane=8,defenderETA=2}
 local ordinary={mode='Bullet',variant='Bullet',time=1,power=80,margin=12,lane=8,defenderETA=2}
 check(not c.jumpBullet.assess(raised,{ordinary}) and not a.allowed(raised),'EASE OFF cannot bypass conditional high admission')
 check(c.Stop('HIGH_PROOF'),'independent high proof cleanup')
end
-- Companion compaction changes only the verified Pelican bar; native jump
-- layout and Yuna UI are owned elsewhere and remain untouched.
do
 local H=assert(loadfile('experimental/compact_hud.lua'))()
 local t=setup();local pg=t.me:FindFirstChild('PlayerGui');local bar=Instance.new('ScreenGui');bar.Name='PELICAN_FF3_MOBILE_JUMP_V1';bar.Enabled=true;bar.Parent=pg
 local yuna=Instance.new('ScreenGui');yuna.Name='Yuna';yuna.Enabled=true;yuna.Parent=pg
 local owner={Version='PELICAN_FF3_MOBILE_JUMP_V1',IsStopped=false};t.env.PELICAN_FF3_MOBILE_JUMP=owner
 local hud=H.new(pg,t.env);hud:check(0)
 check(not bar.Enabled and yuna.Enabled,'only known Pelican companion HUD is compacted')
 hud:stop();check(bar.Enabled,'companion bar restores on experiment cleanup')
 hud:check(1);bar.Enabled=true;hud:stop();check(bar.Enabled,'external UI visibility edit is preserved')
 t.env.PELICAN_FF3_MOBILE_JUMP=nil;hud:check(2);check(bar.Enabled,'name match alone cannot claim another UI')
end

-- Reduced synthetic reproductions of the live report's policy gaps. Raw user
-- reports and actor histories are deliberately not bundled with these tests.
do
 local t,c,a=scene(current,{RiskMode='TRUST'})
 local wr=actor(0,-40,0,-20)
 local function prepared(mode,margin,path)
  local sh=native(wr,1.17,mode,95);sh.effectiveYLead=0;sh.appliedLead={X=6,Y=7}
  sh.margin=margin;sh.lane=path;sh.directLane=2.5;sh.raceAdvantage=.6;sh.receiverETA=.68;sh.defenderETA=1.34
  sh.routeLateral=0;sh.receiverTurn=.24;sh.fitAllowed=true;sh.powerAllowed=true
  a.coverage(sh,wr,{});return sh
 end
 local flat=prepared('Fit',1.5,-1)
 check(not a.allowed(flat) and flat.unified.Reason=='FLAT_NATIVE_REQUIRES_STRICT_COVERAGE','head-level Fit cannot borrow relaxed non-Bullet admission')
 local dime=prepared('Dime',1.5,-1)
 check(not a.allowed(dime),'head-level Dime cannot borrow relaxed non-Bullet admission')
 local strict=prepared('Fit',10,8);check(a.allowed(strict),'safe native Fit remains available even when native flattens it')
 local soft=prepared('Dime',10,8);soft.power=69;check(a.allowed(soft),'strictly clear 69-power opportunity is not banned merely because one report was intercepted')
 local lifted=prepared('Dime',1.5,-1);lifted.effectiveYLead=7;a.coverage(lifted,wr,{})
 check(a.allowed(lifted),'genuinely elevated Dime retains the configured TRUST policy')
 local burn=native(wr,1,'Bullet',95);burn.effectiveYLead=0
 burn.origin=Vector3.new(0,5,0);burn.velocity=Vector3.new(0,12,-60);burn.arrival=Vector3.new(0,3,-60)
 a.risk(burn,wr,{actor(0,-36,0,-20)});a.coverage(burn,wr,{actor(0,-36,0,-20)})
 check(not a.allowed(burn) and burn.trustBurn.Allowed and burn.unified.Reason=='BULLET_REQUIRES_STRICT_COVERAGE','flat trailing advantage remains evidence but cannot waive Bullet coverage')
 strict.unified.HardReason='SYNTHETIC_FINAL_POLICY_VETO'
 check(not a.allowed(strict),'final throwable wrapper enforces evaluator veto rather than returning raw guard permission')
 -- Native clamp bounds are the exact existing AntiOOB contract. The additional
 -- correction allowance is the user's existing horizontal lead, not a new radius.
 t.q.AntiOOB.XTolerance=3;t.q.AntiOOB.ZTolerance=3
 local runner=actor(-54,-50,-20,1)
 local boundary=native(runner,1.17,'Fit',95);boundary.origin=Vector3.new(4,12,-128);boundary.arrival=Vector3.new(-72,7,-48.5)
 boundary.velocity=(boundary.arrival-boundary.origin)/boundary.time+Vector3.new(0,14*boundary.time,0)
 boundary.networkPing=.1;boundary.appliedLead={X=6,Y=7};boundary.margin=20;boundary.lane=20;boundary.defenderETA=4;boundary.fitAllowed=true;boundary.powerAllowed=true
 a.coverage(boundary,runner,{})
 check(not a.allowed(boundary) and boundary.unified.Reason=='NATIVE_BOUNDARY_ROUTE_ADJUSTMENT','clamped endpoint cannot silently require a continuing WR to brake or cut back')
 check(boundary.unified.Boundary.Excess>boundary.unified.Boundary.LeadAllowance,'report quantifies the continuation mismatch against configured lead')
 runner.v=Vector3.new(20,0,1);a.coverage(boundary,runner,{})
 check(a.allowed(boundary),'receiver already turning inward can use the same boundary endpoint')
 runner.v=Vector3.new(-20,0,1);boundary.arrival=Vector3.new(-65,7,-48.5);a.coverage(boundary,runner,{})
 check(a.allowed(boundary),'ordinary unclamped target is not confused with native boundary truncation')
 boundary.arrival=Vector3.new(-72,7,-48.5);boundary.appliedLead.X=10;a.coverage(boundary,runner,{})
 check(a.allowed(boundary),'configured horizontal lead remains the correction allowance')
 check(c.Stop('LIVE_POLICY_REPRO'),'live policy reproduction cleans up')
end
do
 local needle='controller.bad:grade(shot,s,defenders,inputs,controller.unified.config,(shot.guardSeconds or 0)+os.clock()-begun)'
 local injected,n=current:gsub(needle:gsub('([^%w])','%%%1'),needle..";if controller.bad.finalActive then shot.unified.HardReason='TEST_FINAL_GEOMETRY_CHANGED'end",1)
 check(n==1,'fresh-final-veto test patches the actual captured-grade site')
 local t,c=scene(injected,{RiskMode='SAFE'});c.SetThrow(true);t.steps(12)
 check(#t.requests==0 and c.GetReport():find('TEST_FINAL_GEOMETRY_CHANGED',1,true),'fresh final policy veto prevents the packet and reports its actual reason')
 check(c.Stop('FINAL_POLICY_VETO'),'vetoed release cleans up without retrying a request')
end

-- A cancelled automatic jump must not consume the whole possession or silently
-- authorize a ground release when the game's next takeoff is not available.
do
 local options={simulateJump=true,nativeModes={Dime=true}}
 local t,c=scene(current,{Profile='CASUAL',RiskMode='TRUST',PassPlan='DEEP',CloseBullet=false},options)
 Mock.qhum.UseJumpPower=true;Mock.qhum.JumpPower=50
 t.ar.Position=Vector3.new(0,6,-30);t.ar.AssemblyLinearVelocity=Vector3.new(0,0,-10);t.steps(8);c.SetThrow(true)
 for _=1,40 do t.advance(1/60);t.drain();if (Mock.jumpCount or 0)>0 then break end end
 check((Mock.jumpCount or 0)==1 and #t.requests==0,'first automatic jump starts after current native preflight, before release')
 check(c.bad.current.PreJump and c.bad.current.PreJump.Status=='PREJUMP_VERIFIED','prejump evidence is distinguished from an actual release attempt')
 t.ar.AssemblyLinearVelocity=Vector3.new()
 for _=1,40 do t.advance(1/60);t.drain()end
 check(#t.requests==0,'route losing its window still cancels rather than forcing the throw')
 options.jumpFailure=true;t.ar.AssemblyLinearVelocity=Vector3.new(0,0,-10)
 for _=1,50 do t.advance(1/60);t.drain()end
 check(#t.requests==0 and not c.IsStopped,'unavailable cooldown takeoff does not become a ground throw or a possession-wide shutdown')
 options.jumpFailure=false
 for _=1,120 do t.advance(1/60);t.drain();if #t.requests>0 then break end end
 check(#t.requests==1 and (Mock.jumpCount or 0)>=2,'later safe deep window gets a fresh automatic takeoff')
 check(t.requests[1].qbVy>0 and t.payload().JumpObservedDelay>=.075,'recovered throw releases ascending after the takeoff offset, not from the bottom')
 check(c.Stop('JUMP_RECOVERY'),'cancelled/recovered jump state cleans up')
end
do
 local needle='controller.bad:grade(shot,s,defenders,inputs,controller.unified.config,(shot.guardSeconds or 0)+os.clock()-begun)'
 local blocked=current:gsub(needle:gsub('([^%w])','%%%1'),needle..";if controller.bad.finalActive then shot.unified.HardReason='TEST_PREJUMP_BLOCKED'end",1)
 local t,c=scene(blocked,{RiskMode='SAFE',CloseBullet=false},{simulateJump=true,nativeModes={Dime=true}})
 Mock.qhum.UseJumpPower=true;Mock.qhum.JumpPower=50;c.SetThrow(true);t.steps(12)
 check(#t.requests==0 and (Mock.jumpCount or 0)==0,'fresh native veto blocks the visible jump itself')
 check(c.bad.current.PreJump and c.bad.current.PreJump.Status=='PREJUMP_BLOCKED','blocked preflight remains exportable')
 check(c.Stop('PREJUMP_BLOCK'),'blocked preflight cleans up')
end
print('PASS B3 runtime repair checks',checks,'(synthetic native/state contracts, not live catches)')
