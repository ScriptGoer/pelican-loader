-- Optional one-time auto-execute BEFORE Yuna/other visual modifiers.
local env=type(getgenv)=='function' and getgenv() or _G
local light=game:GetService('Lighting')
local old=env.PELICAN_FF3_VISUAL_BASELINE
if old and old.JobId==game.JobId then return old end
local b={JobId=game.JobId,Source='USER_CAPTURED_BEFORE_VISUAL_MODS',Values={}}
for _,key in ipairs({'Brightness','Ambient','OutdoorAmbient','ClockTime','FogStart','FogEnd','GlobalShadows','ColorShift_Top','ColorShift_Bottom','ExposureCompensation'})do
 local ok,value=pcall(function()return light[key]end);if ok and value~=nil then b.Values[key]=value end
end
env.PELICAN_FF3_VISUAL_BASELINE=b
return b
