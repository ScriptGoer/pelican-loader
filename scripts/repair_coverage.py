"""Change coverage labels only; every defender retains full interception checks."""
def repair(s):
 old="elseif fraction>0 and fraction<1 then layers.Underneath=layers.Underneath+1 end"
 new="""elseif fraction>0 and fraction<1 and (pathClearance<CFG.ThrowLane or clearance<CFG.ThrowMargin) then
                layers.Underneath=layers.Underneath+1
            end"""
 assert s.count(old)==1
 return s.replace(old,new,1)
