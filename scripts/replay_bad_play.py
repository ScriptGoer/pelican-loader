"""Replay a saved BAD PLAY JSON locally. No network requests or code from the report."""
import ctypes,ctypes.util,hashlib,json,sys
from pathlib import Path
R=Path(__file__).resolve().parents[1]
def literal(v):
    if v is None:return 'nil'
    if v is True:return 'true'
    if v is False:return 'false'
    if isinstance(v,(int,float)):return repr(v)
    if isinstance(v,str):return '"'+''.join(('\\'+str(ord(c)).zfill(3)) if c in '\\"\n\r\t' or ord(c)<32 else c for c in v)+'"'
    if isinstance(v,list):return '{'+','.join(literal(x) for x in v)+'}'
    return '{'+','.join('['+literal(k)+']='+literal(x) for k,x in v.items())+'}'
def run(report):
    engine=(R/'experimental/decision_engine.lua').read_text();digest=hashlib.sha256(engine.encode()).hexdigest()
    h=(R/'tests/test_trust_burn.py').read_text();pre=h.split("PRELUDE = r'''")[1].split("'''",1)[0]
    pre=pre.replace('a.X*b,a.Y*b,a.Z*b',"a.X*(type(b)=='number' and b or b.X),a.Y*(type(b)=='number' and b or b.Y),a.Z*(type(b)=='number' and b or b.Z)")
    code=pre+'\nVector3={new=vec}\nlocal Engine=(function()\n'+engine+'\nend)()\nlocal replay=(function()\n'+(R/'experimental/replay.lua').read_text()+'\nend)()\nlocal result=replay('+literal(report)+',Engine,"'+digest+'")\n'
    code+="for _,v in ipairs(result.Missing)do print('MISSING '..v)end;for _,v in ipairs(result.Mismatches)do print('MISMATCH '..v)end;print('Reproduced '..result.Reproduced..' evaluator inputs');if not result.Complete then error('REPLAY_INCOMPLETE_OR_MISMATCH')end"
    lib=ctypes.CDLL(ctypes.util.find_library('lua5.4'));lib.luaL_newstate.restype=ctypes.c_void_p
    lib.luaL_openlibs.argtypes=[ctypes.c_void_p];lib.luaL_loadstring.argtypes=[ctypes.c_void_p,ctypes.c_char_p]
    lib.lua_pcallk.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_int,ctypes.c_int,ctypes.c_longlong,ctypes.c_void_p]
    lib.lua_tolstring.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_void_p];lib.lua_tolstring.restype=ctypes.c_char_p;lib.lua_close.argtypes=[ctypes.c_void_p]
    state=lib.luaL_newstate();lib.luaL_openlibs(state)
    try:
        status=lib.luaL_loadstring(state,code.encode())
        if not status:status=lib.lua_pcallk(state,0,0,0,0,None)
        if status:raise ValueError(lib.lua_tolstring(state,-1,None).decode())
    finally:lib.lua_close(state)
if __name__=='__main__':
    if len(sys.argv)!=2:raise SystemExit('Usage: python3 scripts/replay_bad_play.py BAD_PLAY.json')
    raw=Path(sys.argv[1]).read_bytes()
    if len(raw)>1500000:raise SystemExit('Report exceeds 1.5 MB bound')
    run(json.loads(raw))
