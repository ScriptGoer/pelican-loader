Mock={time=10,vectorCount=0,descReads=0,childReads=0,tasks={},services={},roster={},upvalues={}}
Mock.cpuClock=os.clock
os.clock=function()return Mock.realClock and Mock.cpuClock()or Mock.time end
local vm={}
local function newv(x,y,z)Mock.vectorCount=Mock.vectorCount+1;return setmetatable({X=x or 0,Y=y or 0,Z=z or 0},vm)end
vm.__index=function(v,k)
 if k=='Magnitude'then return math.sqrt(v.X*v.X+v.Y*v.Y+v.Z*v.Z)end
 if k=='Unit'then local m=math.sqrt(v.X*v.X+v.Y*v.Y+v.Z*v.Z);return m>0 and newv(v.X/m,v.Y/m,v.Z/m)or newv()end
 if k=='Dot'then return function(a,b)return a.X*b.X+a.Y*b.Y+a.Z*b.Z end end
end
vm.__add=function(a,b)return newv(a.X+b.X,a.Y+b.Y,a.Z+b.Z)end
vm.__sub=function(a,b)return newv(a.X-b.X,a.Y-b.Y,a.Z-b.Z)end
vm.__unm=function(a)return newv(-a.X,-a.Y,-a.Z)end
vm.__mul=function(a,b)if type(a)=='number'then a,b=b,a end;if type(b)=='table'then return newv(a.X*b.X,a.Y*b.Y,a.Z*b.Z)end;return newv(a.X*b,a.Y*b,a.Z*b)end
vm.__div=function(a,b)return newv(a.X/b,a.Y/b,a.Z/b)end
Vector3={new=newv};Vector2={new=function(x,y)return newv(x,y,0)end}
Color3={new=function(r,g,b)return{R=r,G=g,B=b}end,fromRGB=function(r,g,b)return{R=r/255,G=g/255,B=b/255}end}
UDim2={new=function(xs,xo,ys,yo)return{X={Scale=xs,Offset=xo},Y={Scale=ys,Offset=yo}}end,
 fromOffset=function(x,y)return{X={Scale=0,Offset=x},Y={Scale=0,Offset=y}}end}
Enum={Font={GothamMedium='g',Code='c'},HighlightDepthMode={AlwaysOnTop='on'},TextXAlignment={Left='l'},TextYAlignment={Top='t'},RaycastFilterType={Exclude='e'}}
local function signal()
 local s={connections={}}
 function s:Connect(fn)local c={Connected=true,Function=fn,LuaConnection=true,Enabled=true};function c:Disconnect()self.Connected=false end;self.connections[#self.connections+1]=c;return c end
 function s:Fire(...)for _,c in ipairs(self.connections)do if c.Connected then c.Function(...)end end end
 return s
end
local im={};local methods={}
im.__index=function(o,k)
 if k=='Parent'then return rawget(o,'_parent')end
 if k=='ContentText'then return o.Text or ''end
 return methods[k]
end
im.__newindex=function(o,k,v)
 if k~='Parent'then rawset(o,k,v);return end
 local prev=rawget(o,'_parent')
 if prev then for i,c in ipairs(prev._children)do if c==o then table.remove(prev._children,i);break end end end
 rawset(o,'_parent',v)
 if o.AncestryChanged then o.AncestryChanged:Fire(o,v)end
 if o._props.Parent then o._props.Parent:Fire()end
 if v then
  v._children[#v._children+1]=o
  local at=v;while at do at.DescendantAdded:Fire(o);at=at.Parent end
 end
end
local basepart={Part=true,MeshPart=true,Seat=true}
function methods:IsA(k)
 return self.ClassName==k or k=='Instance'or k=='BasePart'and basepart[self.ClassName]
  or k=='GuiObject'and(self.ClassName=='Frame'or self.ClassName=='TextLabel'or self.ClassName=='TextButton'or self.ClassName=='ImageLabel'or self.ClassName=='ImageButton'or self.ClassName=='TextBox'or self.ClassName=='ScrollingFrame')
  or k=='GuiButton'and(self.ClassName=='TextButton'or self.ClassName=='ImageButton')
  or k=='LayerCollector'and self.ClassName=='ScreenGui' or k=='ValueBase'and self.ClassName:match('Value$')~=nil
end
function methods:IsDescendantOf(p)local x=self.Parent;while x do if x==p then return true end;x=x.Parent end;return false end
function methods:GetChildren()Mock.childReads=Mock.childReads+1;local r={};for _,c in ipairs(self._children)do r[#r+1]=c end;return r end
function methods:GetDescendants()
 Mock.descReads=Mock.descReads+1;local r={}
 local function visit(o)for _,c in ipairs(o._children)do r[#r+1]=c;visit(c)end end;visit(self);return r
end
function methods:FindFirstChild(name)for _,c in ipairs(self._children)do if c.Name==name then return c end end end
function methods:WaitForChild(name)return self:FindFirstChild(name)end
function methods:FindFirstChildOfClass(k)for _,c in ipairs(self._children)do if c:IsA(k)then return c end end end
function methods:GetAttribute(k)return self._attrs[k]end
function methods:SetAttribute(k,v)self._attrs[k]=v end
function methods:GetPropertyChangedSignal(k)self._props[k]=self._props[k]or signal();return self._props[k]end
function methods:GetFullName()return self.Name end
function methods:GetConnectedParts()return self.ConnectedParts or{}end
function methods:Destroy()self.Parent=nil end
function methods:Fire(...)self.Event:Fire(...)end
function methods:Activate()self.Activations=(self.Activations or 0)+1;self.Activated:Fire()end
function methods:Deactivate()self.Deactivations=(self.Deactivations or 0)+1 end
Instance={new=function(k)
 return setmetatable({_instance=true,ClassName=k,Name=k,_children={},_attrs={},_props={},
  DescendantAdded=signal(),DescendantRemoving=signal(),AncestryChanged=signal(),Activated=signal(),MouseButton1Click=signal(),Event=signal(),Visible=true,Enabled=true,
  AbsolutePosition=newv(0,0,0),AbsoluteSize=newv(100,24,0),Position=newv(),Size=newv(1,1,1),
  AssemblyLinearVelocity=newv(),Health=100,DisplayName=k,Anchored=true,Transparency=0,Color=Color3.new(1,1,1),RequiresHandle=true},im)
end}
function typeof(v)if type(v)=='table'and v._instance then return'Instance'end;return type(v)end
function Mock.cf(p,right,up,look)
 local c={Position=p or newv(),RightVector=right or newv(-1,0,0),UpVector=up or newv(0,1,0),LookVector=look or newv(0,0,1)}
 function c:PointToObjectSpace(v)local d=v-self.Position;return newv(d:Dot(self.RightVector),d:Dot(self.UpVector),-d:Dot(self.LookVector))end
 function c:VectorToObjectSpace(v)return newv(v:Dot(self.RightVector),v:Dot(self.UpVector),-v:Dot(self.LookVector))end
 function c:VectorToWorldSpace(v)return self.RightVector*v.X+self.UpVector*v.Y-self.LookVector*v.Z end
 function c:PointToWorldSpace(v)return self.Position+self:VectorToWorldSpace(v) end
 return c
end
workspace=Instance.new('Workspace');workspace.Gravity=196.2;workspace.CFrame=Mock.cf();workspace.CurrentCamera={ViewportSize=newv(1536,709,0),CFrame=Mock.cf()}
function workspace.CurrentCamera:WorldToScreenPoint(v)return newv(768+v.X,354-v.Z,10),true end
function workspace.CurrentCamera:WorldToViewportPoint(v)return self:WorldToScreenPoint(v)end
function workspace:Raycast()return Mock.floor and{Instance=Mock.floor}or nil end
RaycastParams={new=function()return{}end}
local me=Instance.new('Player');me.Name='QB';me.DisplayName='QB';me.Neutral=false
local pg=Instance.new('PlayerGui');pg.Parent=me
local players={LocalPlayer=me}
function players:GetPlayers()return Mock.roster end
function players:GetPlayerFromCharacter(c)for _,p in ipairs(Mock.roster)do if p.Character==c then return p end end end
Mock.services.Players=players;Mock.services.RunService={Heartbeat=signal()};Mock.services.UserInputService={GetMouseLocation=function()return newv(700,300,0)end}
Mock.services.GuiService={GetGuiInset=function()return newv()end};Mock.services.CoreGui=Instance.new('CoreGui');Mock.services.ReplicatedStorage=Instance.new('ReplicatedStorage')
game={PlaceId=82866880824588,GetService=function(_,n)return Mock.services[n]end}
task={spawn=function(fn)Mock.tasks[#Mock.tasks+1]=fn end,wait=function(t)Mock.time=Mock.time+(t or .01)end}
function getupvalues(fn)
 if Mock.upvalues[fn]then return Mock.upvalues[fn]end
 local r={};for i=1,100 do local n,v=debug.getupvalue(fn,i);if not n then break end;r[i]=v end;return r
end
function setupvalue(fn,i,v)if Mock.upvalues[fn]then Mock.upvalues[fn][i]=v;return end;return debug.setupvalue(fn,i,v)end
function getconstants(fn)return{'GetMouseLocation','WorldToScreenPoint','GetPlayers','Team','Health','Magnitude'}end
function getconnections(s)return s.connections end
function islclosure()return true end
function isexecutorclosure()return true end
function setclipboard(s)Mock.clip=s end
function writefile(n,s)Mock.file=s end
function warn(s)print('WARN',s)end
function Mock.change(o,k,v)o[k]=v;if o._props[k]then o._props[k]:Fire()end end
function Mock.makePlayer(name,team,p,v)
 local player=Instance.new('Player');player.Name=name;player.DisplayName=name;player.Team=team;player.Neutral=false
 local char=Instance.new('Model');char.Name=name;char.Parent=workspace;player.Character=char
 local hum=Instance.new('Humanoid');hum.DisplayName=name;hum.Parent=char
 local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Position=p;root.AssemblyLinearVelocity=v or newv();root.Parent=char
 Mock.roster[#Mock.roster+1]=player;return player,root,hum
end
local team=Instance.new('Team');team.Name='OFFENSE';local other=Instance.new('Team');other.Name='DEFENSE';Mock.team=team;Mock.other=other
local qb,root,hum=Mock.makePlayer('QB',team,newv(0,6,80));me.Character=qb.Character;me.Team=team;Mock.roster[1]=me
Mock.qroot=root;Mock.qhum=hum
