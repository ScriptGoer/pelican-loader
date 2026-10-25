import ctypes,ctypes.util,sys
from pathlib import Path
lib=ctypes.CDLL(ctypes.util.find_library('lua5.4'))
lib.luaL_newstate.restype=ctypes.c_void_p
lib.luaL_openlibs.argtypes=[ctypes.c_void_p]
lib.luaL_loadbufferx.argtypes=[ctypes.c_void_p,ctypes.c_char_p,ctypes.c_size_t,ctypes.c_char_p,ctypes.c_char_p]
lib.lua_pcallk.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_int,ctypes.c_int,ctypes.c_longlong,ctypes.c_void_p]
lib.lua_tolstring.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_void_p];lib.lua_tolstring.restype=ctypes.c_char_p
lib.lua_close.argtypes=[ctypes.c_void_p]
s=Path(sys.argv[1]).read_bytes();l=lib.luaL_newstate();lib.luaL_openlibs(l)
v=lib.luaL_loadbufferx(l,s,len(s),b'validation',None)
if not v:v=lib.lua_pcallk(l,0,0,0,0,None)
if v:print(lib.lua_tolstring(l,-1,None).decode());sys.exit(1)
lib.lua_close(l)
