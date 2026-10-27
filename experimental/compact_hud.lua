-- Hide only the separately owned Pelican jump-width bar, never Yuna/game UI.
local H={}
function H.new(pg,env)
 return setmetatable({pg=pg,env=env,nextAt=0},{__index=H})
end
function H:check(now)
 if now<self.nextAt then return end;self.nextAt=now+.5
 local owner=self.env.PELICAN_FF3_MOBILE_JUMP
 local gui=self.pg:FindFirstChild('PELICAN_FF3_MOBILE_JUMP_V1')
 if type(owner)~='table'or owner.Version~='PELICAN_FF3_MOBILE_JUMP_V1'or owner.IsStopped or not gui or not gui:IsA('ScreenGui')then return end
 if self.lease and self.lease.gui==gui and self.lease.owner==owner then return end
 self:stop();self.lease={gui=gui,owner=owner,before=gui.Enabled};gui.Enabled=false
end
function H:stop()
 local l=self.lease;self.lease=nil
 if l and l.gui.Parent==self.pg and self.env.PELICAN_FF3_MOBILE_JUMP==l.owner and l.gui.Enabled==false then l.gui.Enabled=l.before end
end
return H
