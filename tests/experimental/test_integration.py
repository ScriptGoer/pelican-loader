"""Check generated/runtime ownership contracts without claiming live Roblox execution."""
from pathlib import Path
import hashlib, subprocess,sys
R=Path(__file__).resolve().parents[2]
b=(R/'games/ff3/auto_qb.lua').read_text();e=(R/'experimental/auto_qb.lua').read_text();loader=(R/'experimental/loader.lua').read_text()
def block(s,a,z):return s[s.index(a):s.index(z,s.index(a))]
assert block(b,'local function solve(player,mode)','function controller.mag.RefreshModes()')==block(e,'local function solve(player,mode)','function controller.mag.RefreshModes()')
checks=1
for token in ['local KEY = "PELICAN_LOADER_SESSION"','/fix/auto-qb-regressions-20261024/experimental/loader.lua','Path = "experimental/auto_qb.lua"']:
 assert token in loader,token;checks+=1
for token in ["'NATIVE_SETTINGS_CHANGED_DURING_SOLVE'","'DECISION_STALE_AFTER_NATIVE_SOLVER'","'QB_LAUNCH_POSE_CHANGED_REPLAN'","'REQUEST_ALREADY_ATTEMPTED'","usedTools[ball.tool]=possession.epoch; attempts=attempts+1","risk(shot,selected.sample,defenders); coverage(shot,selected.sample,defenders)","if frameCalls>=8 then","controller.unified.generation","os.clock()-gradingStarted<.003","DecisionAge=","Unified=shot.unified","local function deepThrow(shot,hum)"]:
 assert token in e,token;checks+=1
assert 'local fitVariant=selected.shot.fitAlternativeVariant' not in e;checks+=1
assert 'Ref = "93832398e74edb83743bf0bcacc81aa8a5f8bd57"' in (R/'loader.lua').read_text();checks+=1
before=hashlib.sha256(e.encode()).digest()
subprocess.run([sys.executable,str(R/'scripts/build_experimental.py')],check=True)
assert hashlib.sha256((R/'experimental/auto_qb.lua').read_bytes()).digest()==before;checks+=1
print(f'PASS {checks} integration/source contracts, including byte-identical native solve and deterministic regeneration')

# Repair regression contracts (live gameplay remains unverified).
repaired=(R/'experimental/auto_qb.lua').read_text()
assert 'local function deepThrow(shot,hum)' in repaired
assert 'shot.powerAllowed=touch.fullAllowed(shot)' in repaired
assert 'and shot.powerAllowed~=false' in repaired
assert 'return Unified.better(a,b,riskPolicy.mode)' in repaired
assert "'BAD_PLAY_DIAGNOSTIC|'" in repaired
assert "'GRADE_BUDGET_NOT_EVALUATED'" in repaired
assert "'NATIVE_PLANNING_BUDGET_NOT_EVALUATED'" in repaired
assert "badPlayButton=button('BAD PLAY'" in repaired
print('PASS 8 repair contracts; runtime performance and behavior need in-game tests')

assert "WAIT_DIAGONAL_ROUTE_DEVELOPMENT" in repaired
assert "RELEASE_VERSION|repair-b2-20261024" in repaired
assert "fix/auto-qb-regressions-20261024" in loader
print("PASS 3 route-timing/version/loader repair contracts")

assert "controller.unified.lastRelease.Alternatives={}" in repaired
assert "controller.unified.lastRelease.HistoryThrowId=throwId" in repaired
print("PASS 2 actual-release diagnostic contracts")
