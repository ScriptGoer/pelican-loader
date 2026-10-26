"""B3 source ownership and deterministic-build contracts (not live claims)."""
from pathlib import Path
import hashlib,subprocess,sys
R=Path(__file__).resolve().parents[2]
b=(R/'games/ff3/auto_qb.lua').read_text();e=(R/'experimental/auto_qb.lua').read_text();loader=(R/'experimental/loader.lua').read_text()
def block(s,a,z):return s[s.index(a):s.index(z,s.index(a))]
checks=0
def check(value,label):
 global checks
 assert value,label;checks+=1
native=block(e,'local function solve(player,mode)','function controller.mag.RefreshModes()')
import re
native=re.sub(r'    -- BEGIN OBSERVED OSCILLATION ADAPTER\n.*?    -- END OBSERVED OSCILLATION ADAPTER\n','',native,flags=re.S)
native=native.replace("mode=='QuickBullet' or zig","mode=='QuickBullet'").replace('softBullet=soft,oscillationBullet=zig,','softBullet=soft,')
check(block(b,'local function solve(player,mode)','function controller.mag.RefreshModes()')==native,'native solver unchanged outside explicit zigzag request/endpoint guards; original lead transaction preserved')
original=block(b,'local function risk(shot,receiver,defenders)','local lastNativeInputs')
repair=block(e,'local function risk(shot,receiver,defenders)','local lastNativeInputs')
for line in [
 '    local gradeStarted=os.clock();shot.maxThreatSpeed=0\n',
 '    shot.guardInputs={Clock=gradeStarted,Drops={}}\n',
 '    local ref=receiver.chestReference;if ref then shot.guardInputs.ChestReference={time=ref.time,at=ref.at}end\n',
 '            if receiver.dropHistory[key]then shot.guardInputs.Drops[d.name]=receiver.dropHistory[key]end\n',
 '    shot.guardInputs.ClockEnd=os.clock();shot.guardSeconds=os.clock()-gradeStarted\n']:
 assert line in repair,line
 repair=repair.replace(line,'')
repair=repair.replace(';shot.maxThreatSpeed=math.max(shot.maxThreatSpeed,speed)','')
check(original==repair,'complete original path and Trust-burn grader retained, aside from timing counters')
check(block(b,'local function deepThrow(shot,hum)','-- Request the ordinary jump only.')==block(e,'local function deepThrow(shot,hum)','-- Request the ordinary jump only.'),'real deep flight/jump classification restored')
for token in ['local KEY = "PELICAN_LOADER_SESSION"','/repair-unified-qb/experimental/loader.lua','Path = "experimental/auto_qb.lua"','Ref = "experimental-unified-b3.4"']:
 check(token in loader,'isolated loader ownership/ref '+token)
for token in ["'NATIVE_SETTINGS_CHANGED_DURING_SOLVE'","'DECISION_STALE_AFTER_NATIVE_SOLVER'","'QB_LAUNCH_POSE_CHANGED_REPLAN'","'REQUEST_ALREADY_ATTEMPTED'","usedTools[ball.tool]=possession.epoch; attempts=attempts+1","risk(shot,selected.sample,defenders); coverage(shot,selected.sample,defenders)","if frameCalls>=8 then","local fitVariant=selected.shot.fitAlternativeVariant","shot.powerAllowed=touch.fullAllowed(shot)","controller.bad:released(shot)","DEVELOPING_ROUTE_CONTINUATION"]:
 check(token in e,'preserved live contract '+token)
check("io.open('experimental/auto_qb.lua')" in (R/'tests/experimental/fixtures/auto_qb_fixture.lua').read_text(),'runtime fixture defaults to repaired experiment')
check('os.clock()-gradingStarted<.003' not in e,'3-ms grading exclusion removed')
check('local function deepThrow() return false end' not in e,'disabled-jump stub absent')
for name in subprocess.check_output(['git','ls-tree','-r','--name-only','c9cc9ea'],cwd=R,text=True).splitlines():
 check((R/name).read_bytes()==subprocess.check_output(['git','show','c9cc9ea:'+name],cwd=R),'production file changed: '+name)
before={name:hashlib.sha256((R/name).read_bytes()).digest()for name in ['experimental/auto_qb.lua','experimental/loader.lua','experimental/guard_replay.lua']}
subprocess.run([sys.executable,str(R/'scripts/build_experimental.py')],cwd=R,check=True)
for name,h in before.items():check(hashlib.sha256((R/name).read_bytes()).digest()==h,'deterministic regeneration '+name)
print('PASS',checks,'source/isolation contracts; all V26.22 production files byte-identical')
