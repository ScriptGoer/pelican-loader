-- Compact FF3 league profile; shares normal loader ownership/cleanup and route.
-- Yuna is still started separately. No credentials or game IDs are introduced.
local supplied=... or {}
assert(type(supplied)=='table','PELICAN competitive options must be a table')
assert(game.PlaceId==82866880824588,'PELICAN competitive requires the observed FF3 live place')
assert(supplied.FF3==nil or type(supplied.FF3)=='table','FF3 options must be a table')
local options={};for k,v in pairs(supplied) do options[k]=v end
options.FF3={};for k,v in pairs(supplied.FF3 or {}) do options.FF3[k]=v end
options.FF3.Profile='LEAGUE'
local source=game:HttpGet('https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/loader.lua')
local chunk,why=loadstring(source,'@PELICAN_competitive_loader')
assert(chunk,why)
return chunk(options)
