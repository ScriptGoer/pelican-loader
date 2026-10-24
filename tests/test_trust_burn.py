"""Run the real coverage/eligibility functions with geometry fixtures via liblua.

These tests exercise policy math, not Roblox catches or server acceptance.
No Roblox calls, external packages or gameplay are needed.
"""
import ctypes
import ctypes.util
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
lua = ctypes.CDLL(ctypes.util.find_library('lua5.4'))
lua.luaL_newstate.restype = ctypes.c_void_p
lua.luaL_openlibs.argtypes = [ctypes.c_void_p]
lua.luaL_loadstring.argtypes = [ctypes.c_void_p, ctypes.c_char_p]
lua.luaL_loadfilex.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_char_p]
lua.lua_pcallk.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_longlong, ctypes.c_void_p]
lua.lua_tolstring.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_void_p]
lua.lua_tolstring.restype = ctypes.c_char_p
lua.lua_close.argtypes = [ctypes.c_void_p]

def run(code):
    state = lua.luaL_newstate()
    lua.luaL_openlibs(state)
    try:
        status = lua.luaL_loadstring(state, code.encode())
        if not status:
            status = lua.lua_pcallk(state, 0, 0, 0, 0, None)
        if status:
            raise AssertionError(lua.lua_tolstring(state, -1, None).decode())
    finally:
        lua.lua_close(state)

PRELUDE = r'''
local V={};V.__index=function(a,k)
    if k=='Magnitude' then return math.sqrt(a.X*a.X+a.Y*a.Y+a.Z*a.Z) end
    if k=='Unit' then return a/a.Magnitude end
    return V[k]
end
function vec(x,y,z) return setmetatable({X=x,Y=y,Z=z},V) end
V.__add=function(a,b)return vec(a.X+b.X,a.Y+b.Y,a.Z+b.Z)end
V.__sub=function(a,b)return vec(a.X-b.X,a.Y-b.Y,a.Z-b.Z)end
V.__mul=function(a,b)return vec(a.X*b,a.Y*b,a.Z*b)end
V.__div=function(a,b)return a*(1/b)end
V.__unm=function(a)return a*(-1)end
function V:Dot(b)return self.X*b.X+self.Y*b.Y+self.Z*b.Z end
local function flat(a)return vec(a.X,0,a.Z)end
local function clamp(x,a,b)return math.max(a,math.min(b,x))end
local function finite(x)return type(x)=='number' and x==x and math.abs(x)<math.huge end
local CFG={Gravity=28,MinMoveSpeed=2,ThrowMargin=6,ThrowLane=4,CacheAge=.36,MotionWindow=.8}
local workspace={Gravity=196.2}
local lines={forward=vec(0,0,1)}
local controller={coverageMath={grades=0,verticalBands=0},coverageWindows={enabled=true},
    league={mode='CASUAL'},safety={enabled=true},passPlan={openComfort=true,assess=function()end},
    mag={Allowed=function()return true end}}
local touch={fullAllowed=function()return true end}
'''

def policy(source):
    profile = source[source.index('local riskPolicy={'):source.index('function riskPolicy.normalize')]
    math_code = source[source.index('local function predict(s,t)'):source.index('local lastNativeInputs')]
    eligibility = source[source.index('local function coverage(shot,s,defenders)'):source.index('controller.fit={}')]
    return PRELUDE + profile + math_code + eligibility

FIXTURES = r'''
local count=0
local function actor(z,speed,x)
    return {p=vec(x or 0,3,z),v=vec(0,0,speed),turn=0,routeTurn=0,
        observedSpeed=math.abs(speed),hum={WalkSpeed=math.abs(speed)},name='DB'}
end
local function scene(mode,gap,opts)
    opts=opts or {};riskPolicy.mode=mode
    local wr=actor(40,20);local db=actor(40-gap,opts.speed or 20,opts.side)
    local shot={mode=opts.mode or 'Bullet',variant=opts.variant or opts.mode or 'Bullet',
        origin=vec(0,5,0),velocity=vec(0,12,60),arrival=vec(0,3,60),time=1,
        networkPing=opts.ping or 0,receiverResidual=0}
    shot.softBullet=opts.soft;shot.magTrial=opts.mag;shot.jumpBullet=opts.jump;shot.screen=opts.screen
    local defenders={db};if opts.extra then defenders[#defenders+1]=opts.extra end
    risk(shot,wr,defenders);coverage(shot,wr,defenders)
    return shot,wr,defenders
end
local function check(label,actual,wanted)
    count=count+1;assert(actual==wanted,label..': expected '..tostring(wanted)..', got '..tostring(actual))
end
'''

source = (ROOT/'games/ff3/auto_qb.lua').read_text()
baseline = subprocess.check_output(['git','show','fc6bd1d6d9a4589573c804b938a52060c84a2ac3:games/ff3/auto_qb.lua'], cwd=ROOT, text=True)
run(policy(baseline) + FIXTURES + "check('baseline TRUST misses four-stud burn',throwable(scene('TRUST',4)),false)")
run(policy(source) + FIXTURES + r'''
for _,mode in ipairs({'SAFE','MOD'}) do
    for _,gap in ipairs({3,4,7}) do check(mode..' unchanged gap '..gap,throwable(scene(mode,gap)),false) end
end
for _,kind in ipairs({'Bullet','Dime'}) do
    for _,gap in ipairs({4,7}) do
        local shot=scene('TRUST',gap,{mode=kind})
        check(kind..' TRUST gap '..gap,throwable(shot),true)
        check('explicit contested admission',shot.trustBurn.Allowed,true)
    end
end
local contested=scene('TRUST',4)
check('fixture fails strict endpoint',contested.margin<CFG.ThrowMargin,true)
check('fixture has full-flight direct overlap',contested.directLane<0,true)
check('fixture clears earlier path',contested.trustBurn.EarlyLane>0,true)
check('3 studs stays below policy',throwable(scene('TRUST',3)),false)
check('closing corner',throwable(scene('TRUST',4,{speed=21})),false)
check('side defender is not trailing corner',throwable(scene('TRUST',4,{side=7})),false)
check('stationary corner obstructs early path',throwable(scene('TRUST',4,{speed=0})),false)
check('holding-high safety',throwable(scene('TRUST',4,{extra=actor(70,20)})),false)
check('underneath crossing obstruction',throwable(scene('TRUST',4,{extra=actor(20,0)})),false)
check('SoftBullet eligible',throwable(scene('TRUST',4,{variant='SoftBullet',soft=true})),true)
check('QuickBullet eligible',throwable(scene('TRUST',4,{variant='QuickBullet',soft=true})),true)
check('ping context',throwable(scene('TRUST',4,{ping=.1})),true)
for _,options in ipairs({{mag=true,mode='Dime'},{jump=true},{screen=true},{mode='Jump'},{mode='Fit'}}) do
    check('special mode keeps gates',throwable(scene('TRUST',4,options)),false)
end
for _,field in ipairs({'planAllowed','powerAllowed'}) do
    local shot=scene('TRUST',4);shot[field]=false
    check(field..' veto retained',throwable(shot),false)
end
local shot=scene('TRUST',4);shot.releaseBlocked=true;check('release veto',throwable(shot),false)
shot=scene('TRUST',4);riskPolicy.mode='MOD';check('mode switch rejects cached allowance',throwable(shot),false)
local wr,defenders
shot,wr,defenders=scene('TRUST',4);defenders[1].v=vec(0,0,24)
risk(shot,wr,defenders);coverage(shot,wr,defenders)
check('final regrade revokes closing burn',throwable(shot),false)
shot,wr,defenders=scene('TRUST',4);wr.routeTurn=.6
risk(shot,wr,defenders);coverage(shot,wr,defenders)
check('unstable WR route',throwable(shot),false)
shot,wr,defenders=scene('TRUST',4);wr.v=vec(20,0,0)
risk(shot,wr,defenders);coverage(shot,wr,defenders)
check('crosser does not become burn',shot.trustBurn==nil,true)
for _,mode in ipairs({'SAFE','MOD','TRUST'}) do
    local s,w=scene(mode,30);risk(s,w,{});coverage(s,w,{})
    check('wide-open Bullet stays eligible',throwable(s),true)
end
-- The shared lane implementation must preserve its first two results exactly.
for _,gap in ipairs({0,3,4,7,30}) do
    local s,w,d=scene('TRUST',gap)
    local a,b=lane(s,d[1],false,true)
    local x,y=lane(s,d[1],false,true,.75)
    check('pursuit lane unchanged '..gap,a,x);check('direct lane unchanged '..gap,b,y)
end
print('PASS: '..count..' coverage/eligibility checks plus reproduced baseline rejection')
''')

grid = r'''
local out={}
for _,mode in ipairs({'SAFE','MOD'}) do
    for _,gap in ipairs({0,3,4,7,16,30}) do
        for _,speed in ipairs({0,10,20,26}) do
            for _,side in ipairs({0,4,12}) do
                local s=scene(mode,gap,{speed=speed,side=side})
                out[#out+1]={throwable(s),s.margin,s.lane,s.directLane,s.safetyOverTop,s.safetyRead.High}
            end
        end
    end
end
return out
'''
run('local before=(function()\n'+policy(baseline)+FIXTURES+grid+'\nend)()\n'
    +'local after=(function()\n'+policy(source)+FIXTURES+grid+'\nend)()\n'
    +r'''
assert(#before==#after)
for i,row in ipairs(before) do
    for j=1,6 do assert(row[j]==after[i][j],'SAFE/MOD policy changed at scene '..i..' metric '..j) end
end
print('PASS: '..#before..' SAFE/MOD scenes match baseline eligibility and coverage metrics')
''')

for path in [ROOT/p for p in ('games/ff3/auto_qb.lua','loader.lua','manifest.lua','competitive.lua')]:
    state = lua.luaL_newstate()
    try:
        if lua.luaL_loadfilex(state,str(path).encode(),None):
            raise AssertionError(f'{path}: '+lua.lua_tolstring(state,-1,None).decode())
    finally:
        lua.lua_close(state)
print('PASS: Auto QB, loader, manifest and competitive entry parse with Lua 5.4')
