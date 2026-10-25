local setup=dofile('tests/experimental/fixtures/ff3_league_fixture.lua')
local sources={BASELINE=assert(io.open('games/ff3/auto_qb.lua')):read('*a'),B3=assert(io.open('experimental/auto_qb.lua')):read('*a')}
local h=assert(io.popen('git show 4a4689b:experimental/auto_qb.lua'));sources.BUILD_B=h:read('*a');h:close()
local count,all=0,{}
local function check(v,msg)count=count+1;assert(v,msg)end
local function actor(x,z,vx,vz,name)return{name=name or 'WR',p=Vector3.new(x,3,z),v=Vector3.new(vx,0,vz),turn=0,routeTurn=0,observedSpeed=math.sqrt(vx*vx+vz*vz),hum={WalkSpeed=math.sqrt(vx*vx+vz*vz),JumpPower=50}}end
for _,version in ipairs({'BASELINE','BUILD_B','B3'})do
 local source=sources[version]:gsub('local built,buildError=pcall%(function%(%)','controller.MathAudit={risk=risk,coverage=coverage,allowed=throwable};local built,buildError=pcall(function()',1)
 local t=setup({source=source,newSafetyDefaults=true,newSharedCoverageDefaults=true,newJumpTimingDefaults=true,newReactiveDefaults=true,ff3={RiskMode='TRUST'}})
 t.ar.Position=Vector3.new(0,6,20);t.ar.AssemblyLinearVelocity=Vector3.new(6,0,-6)
 local c=t.run();c.SetThrow(false);t.steps(12);local a=c.MathAudit
 all[version]={};local previous
 for _,gap in ipairs({-4,0,2,4,7,12})do for _,side in ipairs({0,4,8})do for _,vz in ipairs({-30,-20,0,20})do
  local wr=actor(0,-40,0,-20);local d=actor(side,-40+gap,0,vz,'DB')
  local s={mode='Bullet',variant='Bullet',power=95,origin=Vector3.new(0,5,0),velocity=Vector3.new(0,12,-60),arrival=Vector3.new(0,3,-60),time=1,networkPing=0,receiverResidual=0,at=Mock.time}
  a.risk(s,wr,{d});a.coverage(s,wr,{d});local ok=a.allowed(s);local key=gap..':'..side..':'..vz
  all[version][key]={Allowed=ok,Gap=gap,Side=side,Velocity=vz,Risk=s.unified and s.unified.RiskScore}
  if version=='B3' then
   check(ok==all.BASELINE[key].Allowed,'repaired permission agrees with actual V26.22 on constructed scene '..key)
   if gap==4 and side==0 and vz==-20 then previous=s end
   if gap==7 and side==0 and vz==-20 then check(c.unified.better(s,previous),'larger credible burn never gets lower priority from earlier corner contact')end
  end
 end end end
 -- Benchmark full model grade including inherited analytic guards on 3 defenders.
 local clock=Mock.cpuClock;local wr=actor(0,-40,0,-20);local ds={actor(0,-36,0,-20),actor(25,-70,0,-10),actor(-30,-20,10,-10)}
 local begun=clock();local capture=c.bad and c.bad.open;if c.bad then c.bad.open=true end
 for _=1,100 do local s={mode='Bullet',variant='Bullet',power=95,origin=Vector3.new(0,5,0),velocity=Vector3.new(0,12,-60),arrival=Vector3.new(0,3,-60),time=1,networkPing=0,receiverResidual=0,at=Mock.time};a.risk(s,wr,ds);a.coverage(s,wr,ds);a.allowed(s)end
 if c.bad then c.bad.open=capture end
 print('MODEL_CPU_MEAN_MS',version,(clock()-begun)*10,'(Lua-table vectors; no mobile guarantee)')
 check(c.Stop('COMPARE'),'model cleanup')
end
local counterexamples=0
for k,b in pairs(all.BUILD_B)do
 if b.Allowed and not all.B3[k].Allowed and b.Gap<=0 then counterexamples=counterexamples+1 end
end
check(counterexamples>0,'original TRUST budget admitted some receiver-without-trailing-advantage scenes that fresh guards refuse')
print('COVERED_NO_ADVANTAGE_COUNTEREXAMPLES',counterexamples)
print('PASS comparative model checks',count,'(constructed scenes, not verified live interceptions)')
