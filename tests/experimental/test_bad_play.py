from pathlib import Path
import hashlib,json,subprocess,sys,tempfile,re
R=Path(__file__).resolve().parents[2]
ns={'__file__':str(R/'tests/test_trust_burn.py')}
exec((R/'tests/test_trust_burn.py').read_text().split("source = (ROOT/")[0],ns)
pre=ns['PRELUDE'].replace('a.X*b,a.Y*b,a.Z*b',"a.X*(type(b)=='number' and b or b.X),a.Y*(type(b)=='number' and b or b.Y),a.Z*(type(b)=='number' and b or b.Z)")
engine=(R/'experimental/decision_engine.lua').read_text();digest=hashlib.sha256(engine.encode()).hexdigest()
runtime=(R/'experimental/auto_qb.lua').read_text();codeid=re.search(r"end\)\(\)\.new\('([a-f0-9]{64})'",runtime)[1]
with tempfile.TemporaryDirectory() as folder:
    dest=Path(folder)/'fixture.json'
    code=pre+'\nVector3={new=vec}\nlocal E=(function()\n'+engine+'\nend)()\nlocal B=(function()\n'+(R/'experimental/bad_play.lua').read_text()+'\nend)()\nlocal replay=(function()\n'+(R/'experimental/replay.lua').read_text()+'\nend)()\n'+r'''
local count=0
local function check(ok,label)count=count+1;assert(ok,label)end
local b=B.new('CODEID','DIGEST');local e=E.new()
local wr={name='private_receiver_name',p=vec(0,3,40),v=vec(0,0,20),hum={WalkSpeed=20},observedSpeed=20}
local function shot(t,variant)return{origin=vec(0,5,0),velocity=vec(0,14*t,(40+20*t)/t),arrival=vec(0,5,40+20*t),time=t,power=80,variant=variant,mode='Bullet',networkPing=.02,at=1}end
local context={gravity=28,mode='TRUST',gain=20,endzone=false,OpenComfort=true,ComfortSeconds=.9,Guard={Allowed=true,Strict=true,Reason='CLEAR_NATIVE_WINDOW',Margin=45,Lane=45}}
local receivers={{player={Name=wr.name},sample=wr}}
b:begin(1,1,receivers,{'SoftBullet','QuickBullet','Fit'},{},e.config,'TRUST','NORMAL')
b:schedule(wr.name,{'SoftBullet','QuickBullet','Fit'})
local gentle=shot(1,'SoftBullet');local fast=shot(.65,'QuickBullet')
for _,s in ipairs({gentle,fast})do
 e:evaluate(s,wr,{},context);b:native(wr.name,s.variant,s);b:grade(s,wr,{},context,e.config,.004)
 b:row(wr.name,s.variant).PlanAllowed=true
end
b:status(wr.name,'Fit','NOT_EVALUATED','GRADING_BUDGET')
b:finish({player={Name=wr.name},shot=gentle},.009)
check(b.profile.OverBudget==2,'per-grade soft budget overruns counted')
local row=b.frame.Rows[b:token(wr.name)..'/Fit'];check(row.Reason=='GRADING_BUDGET','budget skip remains unevaluated')
check(row.Input==nil and row.Status=='NOT_EVALUATED','skip never fabricated into rejection')
local snap=b.frame.Rows[b:token(wr.name)..'/SoftBullet']
check(snap.Input.Receiver.p[3]==40,'initial snapshot geometry')
wr.p=vec(0,3,42)
check(snap.Input.Receiver.p[3]==40,'snapshot independent of later actor movement')
wr.p=vec(0,3,40)
b:final(1,1.1,wr,{Plan='NORMAL'})
local final=shot(.9,'SoftBullet');e:evaluate(final,wr,{},context);b:grade(final,wr,{},context,e.config,.001)
b.current.Final.Native=b:trajectory(final);b.current.Final.PlanAllowed=true
b:sent('throw-1','API_ACCEPTED_UNCONFIRMED',1.2)
b:begin(2,2,receivers,{'SoftBullet'},{},e.config,'TRUST','NORMAL')
check(b:flag(2.1),'flag succeeds after planner advanced')
local report=b:report();report.Version='MODEL_ONLY_TEST'
check(report.Possession.Epoch==1,'flags prior attempted possession')
check(report.Possession.Final.Input.Shot.time==.9,'actual final recalculation retained')
check(report.Possession.Frames[1].Rows[b:token(wr.name)..'/SoftBullet'].Input.Shot.time==1,'planner tuple remains separate')
check(report.CodeId=='CODEID' and report.EngineId=='DIGEST','code identity survives serialization copy')
b:observe('throw-1',{ObservedOutcome='OPPONENT_POSSESSION_OBSERVED',RequiredMovement='UNKNOWN',Fault='UNRESOLVED'})
check(report.Possession.Observation.ObservedOutcome=='OPPONENT_POSSESSION_OBSERVED','late observation linked to pinned report')
check(report.Possession.Outcome.Fault=='UNRESOLVED','no inferred fault')
check(report.Possession.FirstViable and report.Possession.Timeline[1].Rows[b:token(wr.name)..'/SoftBullet'].Score,'earliest viable cohort and timeline scores retained')
local outcome=replay(report,E,'DIGEST')
check(outcome.Complete and outcome.Reproduced==7,'planner and final evaluator replay match')
local wrong=replay(report,E,'wrong-engine');check(not wrong.Complete and #wrong.Missing>0,'version mismatch is not replay success')
local old=report.Possession.Final.Input
report.Possession.Final.Input=nil
check(not replay(report,E,'DIGEST').Complete,'missing final input flagged')
report.Possession.Final.Input=old
local score=report.Possession.Final.Result.Score
report.Possession.Final.Result.Score={Flight=999}
check(#replay(report,E,'DIGEST').Mismatches>0,'corrupted expected score detected')
report.Possession.Final.Result.Score=score
for i=3,10 do b:begin(i,i,receivers,{'SoftBullet'},{},e.config,'TRUST','NORMAL')end
check(#b.ring==3,'possession ring bounded')
for i=1,70 do b:begin(99,20+i,receivers,{'SoftBullet'},{},e.config,'TRUST','NORMAL');b:finish(nil,.001)end
check(#b.current.Timeline==64 and b.current.TimelineDropped==6,'timeline has an explicit memory bound and omission count')
b:observe('throw-1',{ObservedOutcome='UNKNOWN'})
check(report.Possession.Outcome.Status=='UNKNOWN','late unknown outcome retained after ring eviction')
b:heartbeat(1,.001,2);b:heartbeat(1.1,.004,8)
check(b.profile.FrameIntervals.GT33_33==1 and b.profile.MaxNativeCalls==8,'live frame interval histogram')
-- Minimal test-only JSON encoder; runtime uses HttpService outside throw work.
local function json(v)
 if v==nil then return 'null' end
 if type(v)=='string'then return '"'..v:gsub('\\','\\\\'):gsub('"','\\"'):gsub('\n','\\n')..'"'end
 if type(v)=='number' or type(v)=='boolean'then return tostring(v)end
 local out={};local array=#v>0
 if array then for _,x in ipairs(v)do out[#out+1]=json(x)end;return '['..table.concat(out,',')..']'end
 for k,x in pairs(v)do out[#out+1]=json(tostring(k))..':'..json(x)end;return '{'..table.concat(out,',')..'}'
end
local text=json(report)
check(not text:find('private_receiver_name',1,true),'report does not expose player name')
local f=assert(io.open('DEST','w'));f:write(text);f:close()
print('PASS '..count..' BAD PLAY retention, replay and privacy checks')
'''
    code=code.replace('CODEID',codeid).replace('DIGEST',digest).replace('DEST',str(dest))
    ns['run'](code)
    subprocess.run([sys.executable,str(R/'scripts/replay_bad_play.py'),str(dest)],check=True)
    report=json.loads(dest.read_text());report['Possession']['Final'].pop('Input')
    dest.write_text(json.dumps(report))
    failed=subprocess.run([sys.executable,str(R/'scripts/replay_bad_play.py'),str(dest)],capture_output=True,text=True)
    assert failed.returncode!=0 and 'MISSING' in failed.stdout
    report=json.loads(dest.read_text());report['CodeId']='different-build'
    dest.write_text(json.dumps(report))
    failed=subprocess.run([sys.executable,str(R/'scripts/replay_bad_play.py'),str(dest)],capture_output=True,text=True)
    assert failed.returncode!=0 and 'BUILD_CODE_ID_MISMATCH' in failed.stdout
    print('PASS saved JSON CLI round-trip, incomplete input and wrong-build nonzero exits')
