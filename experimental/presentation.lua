-- Local presentation ownership. Never disables Roblox controls/chat or inputs.
local P={}
local function is(o,k)return typeof(o)=='Instance' and o:IsA(k)end
local function root(o)
 for _=1,32 do if not o then return end;if is(o,'ScreenGui')then return o end;o=o.Parent end
end
local function ownedName(o)
 local n=o.Name:lower();return n:find('pelican',1,true) or n:find('yuna',1,true)
end
function P.new(options)
 return setmetatable({options=options,hidden=false,leases={},connections={},nextScan=0,status='VISIBLE',lightingStatus='NOT_REQUESTED'},{__index=P})
end
function P:connect(signal,fn)
 if signal then local c=signal:Connect(fn);self.connections[#self.connections+1]=c;return c end
end
function P:claim(o)
 if not self.hidden or not o or self.leases[o] then return end
 local prop=is(o,'ScreenGui') and 'Enabled' or is(o,'GuiObject') and 'Visible'
 if not prop then return end
 local before=o[prop];self.leases[o]={property=prop,before=before};o[prop]=false
 if o.GetPropertyChangedSignal then
  self.leases[o].connection=o:GetPropertyChangedSignal(prop):Connect(function()
   if self.hidden and o.Parent and o[prop]~=false then o[prop]=false end
  end)
 end
end
function P:scan()
 local opts=self.options
 for _,container in ipairs(opts.containers)do
  local queue=container:GetChildren();local i=1
  while i<=#queue and i<=512 do
   local o=queue[i];i=i+1
   if is(o,'ScreenGui') then
    if container==opts.hiddenContainer or ownedName(o) then self:claim(o)end
   elseif is(o,'Folder') then for _,child in ipairs(o:GetChildren())do if #queue<512 then queue[#queue+1]=child end end
   elseif container==opts.hiddenContainer and is(o,'GuiObject') then self:claim(o)end
  end
 end
 for _,o in ipairs(opts.roots()or {})do self:claim(root(o)or o)end
end
function P:normalLighting()
 local b=self.options.baseline and self.options.baseline()
 if type(b)~='table' or type(b.Values)~='table' or b.JobId~=self.options.job or b.Source~='USER_CAPTURED_BEFORE_VISUAL_MODS' then self.lightingStatus='ORIGINAL_LIGHTING_UNAVAILABLE';return end
 self.lightLease={};local light=self.options.lighting
 for key,value in pairs(b.Values)do
  local ok,before=pcall(function()return light[key]end)
  if ok then
   local wrote=pcall(function()light[key]=value end)
   if wrote then self.lightLease[key]={before=before,written=value}end
  end
 end
 self.lightingStatus='CAPTURED_BASELINE_APPLIED; OTHER_VISUAL_WRITERS_NOT_DISABLED'
end
function P:set(hidden)
 if self.stopped and hidden then return end
 if self.hidden==hidden and (hidden or not next(self.leases) and not self.lightLease) then return end
 self.hidden=hidden
 if hidden then self:scan();self:normalLighting();self.status='HIDDEN'
 else
  local remaining={}
  for o,l in pairs(self.leases)do
   if l.connection then local ok=pcall(function()l.connection:Disconnect()end);if not ok then self.connections[#self.connections+1]=l.connection end;l.connection=nil end
   local ok=pcall(function()if o.Parent and o[l.property]==false then o[l.property]=l.before end end)
   if not ok then remaining[o]=l end
  end
  self.leases=remaining
  local lightRemaining={}
  for key,l in pairs(self.lightLease or {})do local ok=pcall(function()if self.options.lighting[key]==l.written then self.options.lighting[key]=l.before end end);if not ok then lightRemaining[key]=l end end
  self.lightLease=next(lightRemaining) and lightRemaining or nil;self.status=next(remaining) and 'RESTORE_FAILED' or 'VISIBLE'
 end
end
function P:message(text)if text=='z' then self:set(not self.hidden);return true end;return false end
function P:start(me)
 self:connect(me.Chatted,function(text)
  local ok,err=pcall(self.message,self,text)
  if not ok then self:stop();if self.options.error then self.options.error(err)end end
 end)
 for _,container in ipairs(self.options.containers)do
  self:connect(container.DescendantAdded,function(o)
   if self.hidden and (is(o,'ScreenGui') or ownedName(o)) then
    if container==self.options.hiddenContainer or ownedName(o) then self:claim(root(o)or o)end
    self.nextScan=0
   end
  end)
 end
end
function P:update(now)
 if self.hidden and now>=self.nextScan then self.nextScan=now+.5;self:scan()end
end
function P:stop()
 self:set(false);self.stopped=true
 local remaining={}
 for _,c in ipairs(self.connections)do local ok=pcall(function()c:Disconnect()end);if not ok then remaining[#remaining+1]=c end end
 self.connections=remaining;self.clean=#remaining==0 and not next(self.leases) and not self.lightLease
 return self.clean
end
return P
