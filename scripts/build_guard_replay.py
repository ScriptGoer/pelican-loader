"""Generate offline analytic-risk replay from the unchanged production source."""
from repair_coverage import repair as repair_coverage
def build(root):
 s=(root/'games/ff3/auto_qb.lua').read_text()
 cfg=s[s.index('local CFG ='):s.index('local Players, Run, Input')]
 policy=s[s.index('local riskPolicy={'):s.index('function riskPolicy.normalize')]
 math=repair_coverage(s[s.index('local function predict(s,t)'):s.index('local lastNativeInputs')])
 power=s[s.index('function touch.fullAllowed(shot)'):s.index('function touch.record')]
 pre='''-- Generated analytic risk replay. No Roblox/network/native calls.
return function(shot,receiver,defenders,context)
 local V=Vector3.new
 local function flat(v)return V(v.X,0,v.Z)end
 local function clamp(x,a,b)return math.max(a,math.min(b,x))end
 local function finite(x)return type(x)=='number'and x==x and math.abs(x)<1e8 end
 local inputs=assert(context.GuardInputs,'Missing pre-grade guard inputs')
 local os={clock=function()return inputs.ClockEnd or inputs.Clock end}
 local workspace={Gravity=context.WorldGravity}
 local lines={forward=V(context.ForwardX,0,context.ForwardZ)}
 local controller={coverageMath={grades=0,verticalBands=0},coverageWindows={enabled=context.CoverageWindows},
  league={mode=context.Profile},safety={enabled=context.SafetyReads}}
 local touch={enabled=context.CloseBullet.Enabled,comfort=context.CloseBullet.Comfort,quick=context.CloseBullet.Quick,full=context.CloseBullet.FullPowerYards}
'''
 post='''
 riskPolicy.mode=context.mode
 if shot.oscillationBullet then shot.variant='SoftBullet' end -- same comfort floor as the owned low-power adapter
 receiver.chestReference=inputs.ChestReference
 receiver.dropHistory={}
 for _,d in ipairs(defenders)do d.model=d;local at=inputs.Drops and inputs.Drops[d.name];if at then receiver.dropHistory[d]=at end end
 risk(shot,receiver,defenders)
 return shot
end
'''
 (root/'experimental/guard_replay.lua').write_text(pre+cfg+policy+power+math+post)
