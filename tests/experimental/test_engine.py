from pathlib import Path
import ctypes,ctypes.util,time
ROOT=Path(__file__).resolve().parents[2]
lib=ctypes.CDLL(ctypes.util.find_library('lua5.4'))
lib.luaL_newstate.restype=ctypes.c_void_p
for name,args in [('luaL_openlibs',[ctypes.c_void_p]),('luaL_loadstring',[ctypes.c_void_p,ctypes.c_char_p]),('luaL_loadfilex',[ctypes.c_void_p,ctypes.c_char_p,ctypes.c_char_p]),('lua_pcallk',[ctypes.c_void_p,ctypes.c_int,ctypes.c_int,ctypes.c_int,ctypes.c_longlong,ctypes.c_void_p]),('lua_close',[ctypes.c_void_p])]:getattr(lib,name).argtypes=args
lib.lua_tolstring.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_void_p];lib.lua_tolstring.restype=ctypes.c_char_p
state=lib.luaL_newstate();lib.luaL_openlibs(state)
for p in [ROOT/'experimental/decision_engine.lua',ROOT/'experimental/auto_qb.lua',ROOT/'experimental/loader.lua']:
 if lib.luaL_loadfilex(state,str(p).encode(),None):raise Exception(lib.lua_tolstring(state,-1,None).decode())
lib.lua_close(state)
# Vector mock is arithmetic only; all decisions below execute the real evaluators.
legacy={};exec(compile((ROOT/'tests/test_trust_burn.py').read_text().split("source = (ROOT/")[0],'<harness>','exec'),{'__file__':str(ROOT/'tests/test_trust_burn.py'),**legacy})
h=(ROOT/'tests/test_trust_burn.py').read_text();pre=h.split("PRELUDE = r'''")[1].split("'''",1)[0]
pre=pre.replace('a.X*b,a.Y*b,a.Z*b',"a.X*(type(b)=='number' and b or b.X),a.Y*(type(b)=='number' and b or b.Y),a.Z*(type(b)=='number' and b or b.Z)")
pre+='\nVector3={new=vec}\n'
src=(ROOT/'games/ff3/auto_qb.lua').read_text()
legacy=src[src.index('local riskPolicy={'):src.index('function riskPolicy.normalize')]+src[src.index('local function predict(s,t)'):src.index('local lastNativeInputs')]+src[src.index('local function coverage(shot,s,defenders)'):src.index('controller.fit={}')]+src[src.index('local function better(a,b)'):src.index('local function receiverBetter(a,b)')]
legacy+=src[src.index('local function receiverBetter(a,b)'):src.index('local function classify(shot,s,defenders)')]
exp=(ROOT/'experimental/auto_qb.lua').read_text()
def scheduler(text,name):
 block=text[text.index('        local indices={}'):text.index('        local best=evaluate(receivers,indices,defenders,now)')]
 return '\nlocal function '+name+'(receivers,choice,shotCache,now,planRound,possession,lines,controller,cachedOnly)\n'+block+'\nreturn indices\nend\n'
schedules=scheduler(src,'oldSchedule')+scheduler(exp,'newSchedule')
code=pre+legacy+schedules+'\nlocal E=(function()\n'+(ROOT/'experimental/decision_engine.lua').read_text()+'\nend)()\n'+r'''
local e=E.new();local failures=0;local assertions=0
local function check(name,ok)assertions=assertions+1;if not ok then failures=failures+1;print('FAIL '..name)end end
local function actor(x,z,vx,vz)return{p=vec(x,3,z),v=vec(vx,0,vz),turn=0,routeTurn=0,name='DB',hum={WalkSpeed=20},observedSpeed=math.sqrt(vx*vx+vz*vz)}end
local function shot(w,t,x,y)
 local arrival=w.p+w.v*t+vec(x or 0,2+(y or 0),0)
 local origin=vec(0,5,0);local delta=arrival-origin
 local v=delta/t+vec(0,14*t,0)
 return{origin=origin,velocity=v,arrival=arrival,time=t,mode='Bullet',variant=t>.9 and 'SoftBullet' or 'QuickBullet',power=v.Magnitude,softBullet=true,networkPing=0,receiverResidual=0}
end
local function grade(s,w,d,mode,td)
 e:evaluate(s,w,d,{gravity=28,mode=mode or 'TRUST',gain=td and 25 or 10,endzone=td or false})
 riskPolicy.mode=mode or 'TRUST';risk(s,w,d);coverage(s,w,d)
 return s
end
local function describe(name,s)
 print(string.format('%s | old=%s | B=%s risk=%.3f difficulty=%.3f score=%.2f',name,tostring(throwable(s)),tostring(E.allowed(s,'TRUST')),s.unified.RiskScore,s.unified.CatchDifficulty,s.unified.Score))
end
local w=actor(-20,30,0,20)
local gentle=grade(shot(w,1),w,{},'TRUST',true)
local fast=grade(shot(w,.65),w,{},'TRUST',true)
local float=grade(shot(w,3),w,{},'TRUST',true)
check('old faster preference reproduced',better(fast,gentle))
check('B chooses comfortable open pass',E.better(gentle,fast,'TRUST'))
check('B rejects excessive floating preference',E.better(gentle,float,'TRUST'))
local midfield=actor(30,80,0,0)
local distant=grade(shot(w,1),w,{midfield},'TRUST',true)
check('distant safety does not veto open TD',E.allowed(distant,'TRUST'))
local short=grade(shot(w,.8),w,{},'TRUST',false)
check('comfortable TD outranks short completion',E.better(distant,short,'TRUST'))
for _,gap in ipairs({3.9,4,4.1,7})do
 local wr=actor(0,40,0,20);local corner=actor(0,40-gap,0,20)
 local s=grade(shot(wr,1),wr,{corner})
 describe('isolated gap '..gap,s)
 check('nested eligibility '..gap,not E.allowed(s,'SAFE') or E.allowed(s,'MOD'))
 check('nested TRUST '..gap,not E.allowed(s,'MOD') or E.allowed(s,'TRUST'))
 if gap==4 then check('Trust accepts four stud native-shaped burn',E.allowed(s,'TRUST'))end
end
local wr=actor(0,40,0,20)
local stable=grade(shot(wr,1),wr,{actor(0,36,0,20)})
local slight=grade(shot(wr,1),wr,{actor(0,36,0,20.1)})
check('near-four risk continuous',math.abs(stable.unified.RiskScore-slight.unified.RiskScore)<.04)
local closing=grade(shot(wr,1),wr,{actor(0,36,0,30)})
check('rapid closing risk exceeds stable',closing.unified.RiskScore>stable.unified.RiskScore)
local underneath=grade(shot(wr,1),wr,{actor(0,20,0,0)})
check('underneath interception refused',not E.allowed(underneath,'TRUST'))
local reversal=grade(shot(wr,1,0),wr,{})
reversal.arrival=wr.p-vec(0,0,30);e:evaluate(reversal,wr,{}, {gravity=28,mode='TRUST',gain=10})
check('unreachable reversal hard rejected',reversal.unified.HardReason~=nil)
local toward=grade(shot(wr,1),wr,{actor(12,58,-20,0)})
local away=grade(shot(wr,1),wr,{actor(12,58,20,0)})
check('momentum changes threat',toward.unified.RiskScore>away.unified.RiskScore)
for _,s in ipairs({gentle,fast,float,distant,closing,underneath,toward,away})do describe('comparison',s)end
check('Trust specifically admits contest MOD declines',E.allowed(stable,'TRUST') and not E.allowed(stable,'MOD'))
check('slightly closing Trust remains eligible',E.allowed(slight,'TRUST'))
check('rapid closing Trust refuses',not E.allowed(closing,'TRUST'))
check('old shorter completion preference reproduced',receiverBetter({shot=short},{shot=distant}))
local highHelp=grade(shot(wr,1),wr,{actor(0,70,0,-20)})
check('closing over-top help refuses',not E.allowed(highHelp,'TRUST'))
local lowHelp=grade(shot(wr,1),wr,{actor(0,120,0,-20)})
check('distant approaching help is lower risk',lowHelp.unified.RiskScore<highHelp.unified.RiskScore)
for _,gap in ipairs({-8,-2,0,2,3.9,4,4.1,7,12,20})do
 local s=grade(shot(wr,1),wr,{actor(0,40-gap,0,20)})
 check('nested risk sweep '..gap,not E.allowed(s,'SAFE') or E.allowed(s,'MOD'))
 check('nested risk sweep TRUST '..gap,not E.allowed(s,'MOD') or E.allowed(s,'TRUST'))
end
local receivers,cache={},{ }
for i=1,6 do
 local player={Character={}};local sample=actor(0,i==6 and 58 or 20,0,20);sample.model=player.Character
 receivers[i]={player=player,sample=sample,estimate=.5}
 cache[player]={model=sample.model,epoch=1,generation=1,plannedAt=i==2 and 9.7 or 9.9}
end
local control={field={InEndzone=function(p)return p.Z>=60 end}}
local args={receivers,{player=receivers[1].player},cache,10,1,{epoch=1},{generation=1},control,false}
local old=oldSchedule(table.unpack(args));local new=newSchedule(table.unpack(args))
check('old scheduler chooses oldest short receiver',old[2]==2)
check('new scheduler catches brief scoring hint',new[2]==6)
cache[receivers[2].player].plannedAt=8
check('oldest receiver prevents urgency starvation',newSchedule(table.unpack(args))[2]==2)
local repeatShot=shot(wr,1)
local many={actor(0,36,0,20),actor(10,60,-10,0),actor(-10,60,10,0)}
grade(repeatShot,wr,{},'TRUST');check('initial release candidate open',E.allowed(repeatShot,'TRUST'))
e:evaluate(repeatShot,wr,many,{gravity=28,mode='TRUST',gain=20})
check('fresh coverage regrade revokes previous allowance',not E.allowed(repeatShot,'TRUST'))
check('invalid model settings rejected',not pcall(E.new,{SafeRisk=.8,ModRisk=.1}))
local started=os.clock();local durations={}
for i=1,1000 do local tick=os.clock();e:evaluate(shot(wr,1),wr,{actor(0,36,0,20),actor(20,70,-10,0),actor(-20,60,10,0)}, {gravity=28,mode='TRUST',gain=20});durations[i]=os.clock()-tick end
print(string.format('1000 x 3-defender evaluations: %.3f seconds; max individual %.6f seconds',os.clock()-started,e.maxSeconds))
table.sort(durations);print(string.format('Mock timings median=%.6f p95=%.6f p99=%.6f seconds',durations[500],durations[950],durations[990]))
print('ASSERTIONS '..assertions..' FAILURES '..failures)
-- Deliberately report all failures before returning a failing exit status.
assert(failures==0,'Comparative decision failures: '..failures)
'''
state=lib.luaL_newstate();lib.luaL_openlibs(state)
status=lib.luaL_loadstring(state,code.encode())
if not status:status=lib.lua_pcallk(state,0,0,0,0,None)
if status:raise SystemExit(lib.lua_tolstring(state,-1,None).decode())
lib.lua_close(state)
print('Experimental source parses; comparative evaluator tests completed')
