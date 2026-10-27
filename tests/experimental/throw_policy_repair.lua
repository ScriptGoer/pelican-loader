-- Integration regressions; synthetic native tuples, no live catch guarantees.
local setup=dofile('tests/experimental/fixtures/ff3_league_fixture.lua')
local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
for _,ref in ipairs({'experimental-unified-b3.9','CURRENT'})do
 local src;if ref=='CURRENT'then src=assert(io.open('experimental/auto_qb.lua')):read('*a')else local f=assert(io.popen('git show '..ref..':experimental/auto_qb.lua'));src=f:read('*a');f:close()end
 local t=setup({source=src,newSafetyDefaults=true,newSharedCoverageDefaults=true,newJumpTimingDefaults=true,ff3={Profile='CASUAL',RiskMode='SAFE',CloseBullet=false}})
 t.ar.Position=Vector3.new(0,6,-70);t.ar.AssemblyLinearVelocity=Vector3.new(0,0,-6)
 t.dr.Position=Vector3.new(0,6,50);t.dr.AssemblyLinearVelocity=Vector3.new();t.db.Character:FindFirstChildOfClass('Humanoid').WalkSpeed=0
 t.addDB('DeepSafety',Vector3.new(0,6,-160),Vector3.new(),0)
 local c=t.run();c.SetThrow(false);t.steps(8);c.SetThrow(true);local max=t.steps(20)
 if ref=='CURRENT' then
  check(#t.requests==1,'underneath blocker and deeper safety permit a strict actual elevated trajectory')
  check(c.bad.current.Final.Native.ActualAngle>25,'actual native elevated release is not the old low arc')
  check(c.bad.current.Final.Result.Guard.Strict,'elevated release proves whole-path and arrival clearance')
  check(c.bad.current.Final.Input.Context.SafetyReads,'layered case runs with real safety reads enabled')
  check(t.q.Angle==45 and t.q.ManualType=='Angle' and t.q.Power==95 and t.q.AutoThrowType.Enabled,'native configured controls are restored')
  check(max<=8,'elevated comparison honors global eight-call cap')
 else
  check(#t.requests==0 and c.GetReport():find('SAFETY_HIGH_BULLET_ONLY',1,true),'old high-safety label veto reproduces missed layered window')
 end
 check(c.Stop('LAYERS'),'layered cleanup')
end
-- A rejected native Power tuple must never become a packet. Its existing Angle
-- alternative can be probed once and used only after returned-tuple validation.
local t=setup({powerEndpointMismatch=true,ff3={Profile='CASUAL',RiskMode='SAFE'}})
t.ar.Position=Vector3.new(0,6,40);t.ar.AssemblyLinearVelocity=Vector3.new(6,0,-6);t.dr.Position=Vector3.new(70,6,-170)
local c=t.run();c.SetThrow(false);t.steps(8)
check(#t.requests==0,'native fallback probing does not send a throw')
check(c.unified.Settings().CloseBullet.Method=='ANGLE','inconsistent Power output activates native Angle fallback')
check(c.unified.Settings().CloseBullet.PowerFallback.Error>0,'BAD settings retain the precise failed Power control evidence')
c.SetThrow(true);local max=t.steps(12);local p=t.payload()
check(#t.requests==1 and p.Variant=='SoftBullet' and p.Power<94.5,'supported softer Bullet actually releases below full power')
check(p.Time>=.855 and p.Lead[2]==t.leads.Bullet.Y,'soft native flight passes comfort and retains Bullet lead')
check(max<=8 and t.q.ManualType=='Angle' and t.q.Power==95,'fallback stays bounded and restores user controls')
check(c.Stop('SOFT_FALLBACK'),'soft fallback cleanup')
-- Explicit configured loft is a supported native candidate, not a new Y lead.
local src=assert(io.open('experimental/auto_qb.lua')):read('*a')
src=src:gsub('local built,buildError=pcall%(function%(%)','controller.Audit={solve=solve};local built,buildError=pcall(function()',1)
t=setup({source=src,ff3={Profile='CASUAL',RiskMode='SAFE',CloseBullet=false}})
t.ar.Position=Vector3.new(0,6,-70);t.ar.AssemblyLinearVelocity=Vector3.new(0,0,-6);t.dr.Position=Vector3.new(70,6,170)
c=t.run();c.SetThrow(false);t.steps(12);t.advance(.13)
local loft=c.Audit.solve(t.a,'LoftDime')
check(loft and loft.mode=='Dime' and loft.variant=='LoftDime','configured-angle candidate maps to real native Dime')
check(math.abs(loft.actualAngle-45)<.01 and loft.power<95,'configured angle produces native high arc and native-derived power')
check(math.abs(loft.effectiveYLead-t.leads.Dime.Y)<.01,'loft preserves configured Dime height instead of inventing an offset')
check(t.q.Angle==45 and t.q.ManualType=='Angle' and t.q.AutoThrowType.Enabled,'loft mode transaction restores controls')
for _,risk in ipairs({'SAFE','MOD','TRUST'})do
 c.SetRiskMode(risk)
 local jump={mode='Jump',variant='CoverageJump',nativeCoverageJump=true,time=1,power=80,margin=12,lane=8,defenderETA=2,safetyRead={High=true,State='HIGH_SAFETY_OBSERVED'},safetyOverTop=false}
 local chest={mode='Bullet',variant='Bullet',time=1,power=80,margin=12,lane=-1,defenderETA=2,safetyRead={High=true}}
 check(c.jumpBullet.assess(jump,{chest}),'strict receiver Jump can rescue an actual blocked chest path in '..risk)
 chest.lane=8
 check(not c.jumpBullet.assess(jump,{chest}),'strict safe ordinary Bullet veto remains in '..risk)
 jump.margin=-1;chest.lane=-1
 check(not c.jumpBullet.assess(jump,{chest}),'closed elevated window cannot be forced in '..risk)
end
check(c.Stop('HIGH_PROOFS'),'native elevated proof cleanup')
print('PASS throw-policy repair checks',checks,'(synthetic; no claim about live completion or required catch movement)')
