"""Temporal risk receipts preserve admission and avoid publishing live inputs."""
import ast
import ctypes
import ctypes.util
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'scripts'))
from repair_coverage_certificate import repair

# Reuse only the declared vector fixture, without executing its production tests.
tree = ast.parse((ROOT / 'tests/test_trust_burn.py').read_text())
pre = next(ast.literal_eval(node.value) for node in tree.body
           if isinstance(node, ast.Assign) and any(isinstance(t, ast.Name) and t.id == 'PRELUDE' for t in node.targets))
source = subprocess.check_output(['git', 'show', 'experimental-unified-b3.10:experimental/auto_qb.lua'], cwd=ROOT, text=True)
policy = source[source.index('local riskPolicy={'):source.index('function riskPolicy.normalize')]
geometry = source[source.index('local function predict(s,t)'):source.index('local lastNativeInputs')]
patched = repair(geometry)

fixtures = r'''
local checks=0
local function check(value,why)checks=checks+1;assert(value,why)end
local function actor(z,speed,x)
 return {p=vec(x or 0,3,z),v=vec(0,0,speed),turn=0,routeTurn=0,
  observedSpeed=math.abs(speed),hum={WalkSpeed=math.abs(speed)},name='PRIVATE_NAME_MUST_NOT_LEAK'}
end
local function scene(gap,kind,dbSpeed)
 riskPolicy.mode='TRUST'
 local wr=actor(40,20);local db=actor(40-gap,dbSpeed or 20)
 local shot={mode='Dime',variant='Dime',origin=vec(0,5,0),velocity=vec(0,12,60),arrival=vec(0,3,60),time=1,networkPing=0,receiverResidual=0}
 if kind=='loft' then shot.variant='LoftDime';shot.velocity=vec(0,44,35);shot.arrival=vec(0,11,105);shot.time=3 end
 local defenders={db};if kind=='obstructed' then defenders[#defenders+1]=actor(20,0)end
 risk(shot,wr,defenders)
 return shot,wr,defenders
end
local outcomes={}
for _,gap in ipairs({0,3,4,7,30})do
 for _,speed in ipairs({0,10,20,24})do
  for _,kind in ipairs({'normal','loft','obstructed'})do
   local s=scene(gap,kind,speed)
   outcomes[#outcomes+1]={s.margin,s.lane,s.directLane,s.trustBurn.Allowed,s.trustBurn.Reason,s.safetyOverTop}
  end
 end
end
return {Outcomes=outcomes,Scene=scene,Lane=lane,Risk=risk,Actor=actor,SetMode=function(mode)riskPolicy.mode=mode end,Checks=checks}
'''
code = pre + '\nlocal baseline=(function()\n' + policy + geometry + fixtures + '\nend)()\n'
code += 'local patched=(function()\n' + policy + patched + fixtures + '\nend)()\n'
code += r'''
local checks=0
local function check(v,label)checks=checks+1;assert(v,label)end
check(#baseline.Outcomes==#patched.Outcomes,'same scenario grid')
for i,a in ipairs(baseline.Outcomes)do for j=1,6 do check(a[j]==patched.Outcomes[i][j],'admission arithmetic changed '..i..'/'..j)end end
local s,w,d=patched.Scene(4,'normal')
check(s.trustBurn.Allowed,'genuine four-stud burn remains admitted')
check(s.trustBurn.EarlyLane>0 and s.trustBurn.EarlyPursuit<0,'actual-direction and instant-turn envelopes remain distinct')
local receipt=s.trustBurn.Certificates[1]
check(receipt.DefenderIndex==1 and receipt.EarlyUntil>0 and receipt.EarlyUntil<s.time,'threat ties to captured defender order and exact cutoff')
check(receipt.ArrivalClearance==s.margin and receipt.WholeFlightPursuit==s.lane,'certificate refers to actual inherited threat')
check(not receipt.Name and not receipt.Defender and not receipt.Actor,'no raw actor identifiers added')
local a,b,c,p=patched.Lane(s,d[1],false,true,.75)
local x,y,z=baseline.Lane(s,d[1],false,true,.75)
check(a==x and b==y and c==z,'first three lane results preserved')
check(p<=a+100 and p==p,'fourth temporal pursuit result is finite')
local loft=patched.Scene(4,'loft')
check(loft.trustBurn.Allowed and loft.trustBurn.EarlyPursuit>0,'high arc absent from dangerous early vertical bands is identified rather than falsely vetoed')
check(loft.trustBurn.Certificates[1].EarlyDirect>0,'no early direct interception is fabricated from late descent')
local blocked=patched.Scene(4,'obstructed')
check(not blocked.trustBurn.Allowed,'real early obstruction still refuses burn')
s,w,d=patched.Scene(4,'normal')
for i=2,20 do d[i]=patched.Actor(36,20)end
patched.Risk(s,w,d)
check(s.trustBurn.Threats==20 and #s.trustBurn.Certificates==16,'bounded per-threat diagnostics')
check(s.trustBurn.CertificatesOmitted==4,'omissions explicitly counted')
s,w,d=patched.Scene(4,'normal')
check(s.receiverETA~=nil and s.directLane~=nil,'TRUST grade records its race and current-direction evidence')
patched.SetMode('SAFE');patched.Risk(s,w,d)
check(s.receiverETA==nil and s.directLane==nil and s.raceAdvantage==nil,'SAFE regrade of cached tuple clears old TRUST-only race data')
check(s.routeLateral==nil and s.receiverTurn==nil and s.trustBurn==nil,'SAFE report cannot retain earlier route/burn permission metadata')
print('PASS coverage certificate '..checks..' synthetic checks; admission unchanged, catch reach uncalibrated')
'''
lib = ctypes.CDLL(ctypes.util.find_library('lua5.4'))
lib.luaL_newstate.restype = ctypes.c_void_p
lib.luaL_openlibs.argtypes = [ctypes.c_void_p]
lib.luaL_loadstring.argtypes = [ctypes.c_void_p, ctypes.c_char_p]
lib.lua_pcallk.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_longlong, ctypes.c_void_p]
lib.lua_tolstring.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_void_p]
lib.lua_tolstring.restype = ctypes.c_char_p
lib.lua_close.argtypes = [ctypes.c_void_p]
state = lib.luaL_newstate()
lib.luaL_openlibs(state)
try:
    status = lib.luaL_loadstring(state, code.encode())
    if not status:
        status = lib.lua_pcallk(state, 0, 0, 0, 0, None)
    if status:
        raise AssertionError(lib.lua_tolstring(state, -1, None).decode())
finally:
    lib.lua_close(state)
