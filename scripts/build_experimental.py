"""B3 repair: derive only experimental files from unchanged production V26.22."""
import sys
sys.dont_write_bytecode=True
from pathlib import Path
from instrument_bad_play import instrument
from build_guard_replay import build as build_guard_replay
root=Path(__file__).resolve().parents[1]
s=(root/'games/ff3/auto_qb.lua').read_text()
build_guard_replay(root)
assert "'RELEASE_VERSION|ff3-v26.22'" in s,'Build against verified V26.22 only'
def one(old,new):
 global s
 assert s.count(old)==1,(old[:100],s.count(old));s=s.replace(old,new,1)
def block(a,b,new):
 global s
 start=s.index(a);end=s.index(b,start);s=s[:start]+new+'\n'+s[end:]
engine=(root/'experimental/decision_engine.lua').read_text()
one('local context = ... or {}','local context = ... or {}\nlocal Unified=(function()\n'+engine+'\nend)()')
one('local controller = {Version=VERSION, IsStopped=false}','local controller = {Version=VERSION, IsStopped=false}\ncontroller.unified=Unified.new((context.FF3Options or {}).Unified)')
one('controller.unified=Unified.new((context.FF3Options or {}).Unified)','controller.unified=Unified.new((context.FF3Options or {}).Unified)\ncontroller.unified.oscillation=(function()\n'+(root/'experimental/oscillation.lua').read_text()+'\nend)()')
one("ff3Options.RiskMode or (riskPolicy.normalize(env.PELICAN_FF3_RISK_MODE) or 'SAFE')","ff3Options.RiskMode or 'TRUST'")
one('    controller.passPlan.observe(s,player)', '    s.oscillation=controller.unified.oscillation.detect(s.path,lines.forward,now,CFG)\n    controller.passPlan.observe(s,player)')
# Fast history sampling is for reversal evidence. Receiver readiness still needs
# displacement measured over the original planning interval, not each replicated
# pose gap. Keep current velocity stops and teleport invalidation immediate.
one('motionAt=now,motionP=root.Position,motionV=velocity,motionFrame=motionFrame',
    'motionAt=now,motionP=root.Position,motionV=velocity,motionFrame=motionFrame,readyAt=now,readyP=root.Position')
one('''            s.observedSpeed=flat(observed).Magnitude
            if s.observedSpeed>=CFG.MinMoveSpeed and flat(velocity).Magnitude>=CFG.MinMoveSpeed and observed.Magnitude<=100 then
                s.motionSince=s.motionSince or s.motionAt
            else s.motionSince=nil end''',r'''            local readyElapsed=now-(s.readyAt or s.motionAt)
            if observed.Magnitude>100 then
                s.readyAt=now;s.readyP=root.Position;s.observedSpeed=0
            elseif readyElapsed>=CFG.Interval then
                s.observedSpeed=flat(root.Position-(s.readyP or s.motionP)).Magnitude/readyElapsed
                if s.observedSpeed>=CFG.MinMoveSpeed and flat(velocity).Magnitude>=CFG.MinMoveSpeed then
                    s.motionSince=s.motionSince or s.readyAt or s.motionAt
                else s.motionSince=nil end
                s.readyAt=now;s.readyP=root.Position
            elseif flat(velocity).Magnitude<CFG.MinMoveSpeed then s.motionSince=nil end''')
one('local function receiverReady(player,s,now,point)',r'''function controller.unified.ObserveOscillation(now)
    if not auto or not profile or now<(controller.unified.nextMotionAt or 0) then return end
    controller.unified.nextMotionAt=now+.05 -- bounded observation cadence, not native solve work
    for player in pairs(samples)do if teammate(player)then sample(player,now)end end
end
local function receiverReady(player,s,now,point)''')
one("    if not vector(root.AssemblyLinearVelocity) or flat(root.AssemblyLinearVelocity).Magnitude<CFG.MinMoveSpeed then", "    if not vector(root.AssemblyLinearVelocity) or not s.oscillation and flat(root.AssemblyLinearVelocity).Magnitude<CFG.MinMoveSpeed then")
one("    if not s.motionSince or now-s.motionSince<CFG.MinMotionAge or s.observedSpeed<CFG.MinMoveSpeed then", "    if not s.oscillation and (not s.motionSince or now-s.motionSince<CFG.MinMotionAge or s.observedSpeed<CFG.MinMoveSpeed) then")
one("local minimum=power and power>=94.5 and touch.comfort or shot.variant=='SoftBullet' and touch.comfort*.95 or touch.quick", "local minimum=power and power>=94.5 and touch.comfort or shot.oscillationBullet and touch.comfort*.95 or shot.variant=='SoftBullet' and touch.comfort*.95 or touch.quick")
# Only this opt-in candidate modifies lead cancellation. Existing native tuple,
# protected temporary-mode transaction and restoration code remain unchanged.
one("    local soft=mode=='SoftBullet' or mode=='QuickBullet'", "    -- BEGIN OBSERVED OSCILLATION ADAPTER\n    local zig=mode=='ZigzagBullet'\n    if zig and (not samples[player] or not samples[player].oscillation) then return nil,'NO_OBSERVED_ZIGZAG' end\n    -- END OBSERVED OSCILLATION ADAPTER\n    local soft=mode=='SoftBullet' or mode=='QuickBullet' or zig")
one('    local appliedLead\n',r'''    local appliedLead
    -- BEGIN OBSERVED OSCILLATION ADAPTER
    if zig then
        local s=samples[player];local _,_,head=body(me);local ping=me:GetNetworkPing()
        if not head or not finite(ping) or ping<0 then return nil,'ZIGZAG_POSE_UNVERIFIED' end
        requestedPower=controller.unified.oscillation.power(s,head.Position,touch.comfort,CFG.Gravity,touch.min,profile.leads.Bullet)
        if not requestedPower then return nil,'ZIGZAG_COMFORT_POINT_OUT_OF_RANGE' end
        local x,why=controller.unified.oscillation.control(s,head.Position,requestedPower,CFG.Gravity,ping,profile.leads.Bullet)
        if not x then return nil,why end
        appliedLead=Vector2.new(x,profile.leads.Bullet.Y)
    end
    -- END OBSERVED OSCILLATION ADAPTER
''')
one('    if fastJump and (not finite(requestedPower)',r'''    -- BEGIN OBSERVED OSCILLATION ADAPTER
    if zig and not controller.unified.oscillation.contains(samples[player],arrival,math.abs(profile.leads.Bullet.X)) then return nil,'ZIGZAG_NATIVE_POINT_OUTSIDE_OBSERVED_AREA' end
    -- END OBSERVED OSCILLATION ADAPTER
    if fastJump and (not finite(requestedPower)''')
one('variant=mode,softBullet=soft,jumpBullet=jump','variant=mode,softBullet=soft,oscillationBullet=zig,jumpBullet=jump')
# Preserve the full V26.22 trajectory guards and native solver. Rank only after
# actual coverage/comfort/plan checks, not through a second simulated permission.
a=s.index('local function coverage(shot,s,defenders)');b=s.index('controller.fit={}',a)
original=s[a:b].replace('local function coverage(','function controller.unified.BaselineCoverage(',1).replace('local function throwable(','function controller.unified.BaselineThrowable(',1)
wrappers=r'''
function controller.unified.Guard(shot)
    local allowed=controller.unified.BaselineThrowable(shot)
    if shot.oscillationBullet and not (shot.wideOpen and shot.margin>=CFG.ThrowMargin and shot.lane>=CFG.ThrowLane) then allowed=false end
    local reason=shot.planAllowed==false and shot.planReason or shot.releaseBlocked and 'RELEASE_BLOCKED'
        or shot.powerAllowed==false and shot.powerReason
        or shot.safetyRead and shot.safetyRead.High and shot.mode~='Bullet' and 'SAFETY_HIGH_BULLET_ONLY'
        or shot.mode=='Fit' and not shot.fitAllowed and (shot.fitReason or 'FIT_COMPARISON_REQUIRED')
        or (shot.nativeCoverageJump or shot.jumpBullet) and not shot.jumpBulletAllowed and (shot.jumpBulletReason or 'JUMP_COMPARISON_REQUIRED')
        or not allowed and (shot.trustBurn and shot.trustBurn.Reason or 'COVERAGE_REJECTED')
        or shot.trustBurn and shot.trustBurn.Allowed and 'TRAILING_CORNER_ADVANTAGE' or 'CLEAR_NATIVE_WINDOW'
    return {Allowed=allowed,Reason=reason,Margin=shot.margin,Lane=shot.lane,DirectLane=shot.directLane,
        Strict=shot.margin>=CFG.ThrowMargin and shot.lane>=CFG.ThrowLane,ThreatSpeed=shot.maxThreatSpeed or 0,RequiredMargin=CFG.ThrowMargin,RequiredLane=CFG.ThrowLane,
        TrustBurn=shot.trustBurn,DefenderETA=finite(shot.defenderETA) and shot.defenderETA or nil,NoReachableDefender=shot.defenderETA==math.huge,RaceAdvantage=shot.raceAdvantage,
        ReceiverETA=shot.receiverETA,PowerAllowed=shot.powerAllowed,MinimumFlight=shot.minimumFlight,
        WideOpen=shot.wideOpen,MarginDefender=shot.marginDB,LaneDefender=shot.laneDB,
        SafetyRead=shot.safetyRead,FitReason=shot.fitReason,JumpReason=shot.jumpBulletReason}
end
local function coverage(shot,s,defenders)
    controller.unified.BaselineCoverage(shot,s,defenders)
    if shot.oscillationBullet and not s.oscillation then shot.releaseBlocked=true end
    local inputs={gravity=CFG.Gravity,mode=riskPolicy.mode,gain=math.max(0,downfield(shot.arrival)/3),
        endzone=shot.endzoneTarget,CurrentDepthYards=downfield(s.p)/3,MinDepthYards=CFG.MinDownfieldYards,
        ReceiverGrounded=s.hum and s.hum.FloorMaterial~=nil and s.hum.FloorMaterial~=Enum.Material.Air,
        NativeBoundary=profile and type(profile.q.AntiOOB)=='table' and {Enabled=profile.q.AntiOOB.Enabled,XTolerance=profile.q.AntiOOB.XTolerance,ZTolerance=profile.q.AntiOOB.ZTolerance} or nil,
        GoalOrScreen=lines.goalToGo or shot.screen or shot.endzoneTarget,ForwardX=lines.forward and lines.forward.X,
        ForwardZ=lines.forward and lines.forward.Z,OpenComfort=controller.passPlan.openComfort,
        ComfortSeconds=touch.enabled and touch.comfort or 0,WorldGravity=workspace.Gravity,CoverageWindows=controller.coverageWindows.enabled,Profile=controller.league.mode,SafetyReads=controller.safety.enabled,CloseBullet={Enabled=touch.enabled,Comfort=touch.comfort,Quick=touch.quick,FullPowerYards=touch.full},GuardInputs=shot.guardInputs,Guard=controller.unified.Guard(shot)}
    shot.evidenceReceiver=s.name
    local begun=os.clock();controller.unified:evaluate(shot,s,defenders,inputs)
    controller.bad:grade(shot,s,defenders,inputs,controller.unified.config,(shot.guardSeconds or 0)+os.clock()-begun)
end
local function throwable(shot)
    local g=controller.unified.Guard(shot)
    local allowed=Unified.admit(shot,g)
    if shot.unified then controller.bad:admit(shot,g) end
    return allowed
end
'''
s=s[:a]+original+wrappers+s[b:]
one("if not throwable(shot) then setGate(shot.safetyRead", "if not throwable(shot) then setGate(shot.unified and shot.unified.Reason or shot.safetyRead")
one('holdManual(best,best.shot.safetyRead', 'holdManual(best,best.shot.unified and best.shot.unified.Reason or best.shot.safetyRead')
# Confirm the actual native window before committing the visible jump. The
# normal fresh final solve still runs after observed takeoff; it may veto safely.
one('local function releaseNow(ball,selected,defenders,now)','local function releaseNow(ball,selected,defenders,now,preJump)')
one('    local unit=shot.velocity.Unit\n    -- Readable live InputBegan', '    if preJump then return true end\n    local unit=shot.velocity.Unit\n    -- Readable live InputBegan')
one('    if seq.deep then\n        local _,root=body(seq.player)', '    local preflightThisFrame=false\n    if seq.deep then\n        local _,root=body(seq.player)')
one('        requestJump(ball,now)\n        if stopped or sequence~=seq then return end',r'''        if ascentTime(ball.hum) and ball.hum.FloorMaterial==Enum.Material.Air and ball.root.AssemblyLinearVelocity.Y<=0 then
            abortPreparedBurn(seq,'DEEP_WAIT_LANDING');return
        end
        if not seq.preJumpCheckedAt or now-seq.preJumpCheckedAt>CFG.CacheAge then
            local passed=releaseNow(ball,seq.selected,{},now,true)
            controller.bad:prejump(passed==true)
            if stopped or sequence~=seq then return end
            if not passed then cancelSequence('PREJUMP_WINDOW_CHANGED');cancelJump('PREJUMP_CANCELLED');return end
            seq.preJumpCheckedAt=now;preflightThisFrame=true
        end
        requestJump(ball,now)
        if stopped or sequence~=seq then return end''')
one('    if not controller.jumpTiming.Wait(seq,ball,now) then return end', '    if preflightThisFrame then return end -- separate native budgets; physics may observe this jump next heartbeat\n    if not controller.jumpTiming.Wait(seq,ball,now) then return end')
one('        if timing.delay==0 then return true end','        if timing.delay==0 and not (seq.deep and ascentTime(ball.hum)) then return true end')
one("            timing.status='POST_JUMP_READY';return true", "            if seq.deep and ascentTime(ball.hum) and ball.root.AssemblyLinearVelocity.Y<=0 then timing.status='DEEP_WAIT_LANDING';setGate(timing.status);return false end\n            timing.status='POST_JUMP_READY';return true")
one('                assistance.jumpFailedEpoch=possession.epoch','                assistance.jumpFailedEpoch=nil -- a missed takeoff is not a possession-wide ban')
one("        timing.status='NO_NEW_JUMP_IMMEDIATE';return true", "        if seq.deep and ascentTime(ball.hum) then timing.status='WAIT_DEEP_TAKEOFF';setGate(timing.status);return false end\n        timing.status='NO_NEW_JUMP_IMMEDIATE';return true")
one('    if assistance.jumpFailedEpoch==possession.epoch then return end','')
one('    if assistance.jumpEpoch==possession.epoch and (not assistance.jumpRequestObserved or now-assistance.jumpRequestedAt<.25) then return end','    if assistance.jumpEpoch==possession.epoch and now-assistance.jumpRequestedAt<.25 then return end')
one("    hum.Jump=true;assistance.jumpMethod='HUMANOID_JUMP'", "    if sequence then sequence.jumpAwaitAt=now end\n    hum.Jump=true;assistance.jumpMethod='HUMANOID_JUMP'")
block('local function better(a,b)','local function classify(shot,s,defenders)',r'''local function better(a,b)
    throwable(a);if b then throwable(b) end
    return Unified.better(a,b)
end
local function receiverBetter(a,b) return not b or better(a.shot,b.shot) end''')
# Do not let legacy mode-label preferences overturn the joint ordering.
block('    if best and incumbent and best.player~=incumbent.player then','    return best','')
# Include analytic guard work in whole-grade measurements, not only ranking.
one('local function risk(shot,receiver,defenders)\n','local function risk(shot,receiver,defenders)\n    local gradeStarted=os.clock()\n')
one('    return shot\nend\nlocal lastNativeInputs','    shot.guardSeconds=os.clock()-gradeStarted\n    return shot\nend\nlocal lastNativeInputs')
# Reuse the risk loop's measured maximum pursuit speed for conditional waiting.
a=s.index('local function risk(shot,receiver,defenders)');b=s.index('local lastNativeInputs',a)
risk=s[a:b].replace('local gradeStarted=os.clock()','local gradeStarted=os.clock();shot.maxThreatSpeed=0')
risk=risk.replace('local speed=runSpeed(d)','local speed=runSpeed(d);shot.maxThreatSpeed=math.max(shot.maxThreatSpeed,speed)')
risk=risk.replace('local gradeStarted=os.clock();shot.maxThreatSpeed=0','local gradeStarted=os.clock();shot.maxThreatSpeed=0\n    shot.guardInputs={Clock=gradeStarted,Drops={}}\n    local ref=receiver.chestReference;if ref then shot.guardInputs.ChestReference={time=ref.time,at=ref.at}end')
risk=risk.replace('local key=d.model or d','local key=d.model or d\n            if receiver.dropHistory[key]then shot.guardInputs.Drops[d.name]=receiver.dropHistory[key]end')
risk=risk.replace('shot.guardSeconds=os.clock()-gradeStarted','shot.guardInputs.ClockEnd=os.clock();shot.guardSeconds=os.clock()-gradeStarted')
s=s[:a]+risk+s[b:]
# Ease changes ranking, never whether a high catch needs a chest-threat proof.
one('    if not controller.passPlan.openComfort and not controller.safety.enabled then return true end','')
s=s.replace("if controller.passPlan.openComfort and (shot.jumpBullet or shot.nativeCoverageJump) and not shot.jumpBulletAllowed", "if (shot.jumpBullet or shot.nativeCoverageJump) and not shot.jumpBulletAllowed")
s=s.replace("(shot.jumpBullet or shot.nativeCoverageJump) and (controller.passPlan.openComfort or controller.safety.enabled)","(shot.jumpBullet or shot.nativeCoverageJump)")
s=s.replace("(selected.shot.jumpBullet or selected.shot.nativeCoverageJump) and (controller.passPlan.openComfort or controller.safety.enabled)","(selected.shot.jumpBullet or selected.shot.nativeCoverageJump)")
s=s.replace("(best.shot.jumpBullet or best.shot.nativeCoverageJump) and (controller.passPlan.openComfort or controller.safety.enabled)","(best.shot.jumpBullet or best.shot.nativeCoverageJump)")

# All fresh cached tuples are cheap analytic grades: no separate 3-ms truncation.
# Preserve incumbent + least-recently-planned scheduling, native count/time bounds.
one('            s.turn=clamp((velocity-s.motionV).Magnitude/30,0,1)',
    '            s.acceleration=flat(velocity-s.motionV)/dt\n            s.turn=clamp((velocity-s.motionV).Magnitude/30,0,1)')
one('        submit(ball,best,defenders,now)',r'''        if controller.unified:wait(best.player,best.model,possession.epoch,best.shot,now) then
            setGate('DEVELOPING_ROUTE_CONTINUATION');controller.bad:timing(best,now);return
        end
        submit(ball,best,defenders,now)''')
# Native point placement is not a calibrated mag/custom Jump adapter. Remove
# those experiments from active generation and expose rejection, not dead UI.
block('function controller.mag.RefreshModes()','\ncontroller.mag.RefreshModes()\n',r'''function controller.mag.RefreshModes()
    for i=#plannerModes,1,-1 do plannerModes[i]=nil end
    for _,m in ipairs({'ZigzagBullet','SoftBullet','QuickBullet','Bullet','Fit','Dime'})do plannerModes[#plannerModes+1]=m end
    if controller.nativeJump.supported and controller.nativeJump.enabled then plannerModes[#plannerModes+1]='CoverageJump' end
end
controller.mag.enabled=false;controller.jumpBullet.enabled=false;controller.passPlan.preferJump=false
function controller.SetMagTrial(value) if value then setGate('MAG_UNSUPPORTED_IN_B3');return false end;return true end
function controller.SetJumpBullet(value) if value then setGate('CUSTOM_JB_UNSUPPORTED_IN_B3');return false end;return true end
function controller.SetOpenComfort(value)
    if stopped or type(value)~='boolean' then return false end
    releaseChoice();controller.passPlan.openComfort=value;controller.mag.RefreshModes()
    if controller.unified.easeButton then controller.unified.easeButton.Text=value and 'EASE ON' or 'EASE OFF' end
    return true
end''')
# Manual trust existed only to authorize the retired mag experiment. Preserve
# its saved table for production, but expose only an effective blacklist here.
one("return controller.mag.manual[receiverKey(player)]==true and 'TRUSTED' or 'NORMAL'","return 'NORMAL'")
one('function controller.SetReceiverState(player,value)\n',"function controller.SetReceiverState(player,value)\n    if value=='TRUSTED' then setGate('MANUAL_MAG_TRUST_UNSUPPORTED_IN_B3');return false end\n")
# Pre-solver omissions must not consume scarce native-call slots. Attempt work
# is still bounded by one complete mode sweep over the scheduled pair and 8 ms.
one('local calls,started,limited=0,os.clock(),false','local calls,started,limited=0,os.clock(),false\n    local attempts=0;local attemptLimit=#groups*#plannerModes')
one('    for pass=1,3 do','    for pass=1,#plannerModes do')
s=s.replace('if calls>=callLimit or os.clock()-started>=CFG.PlanSeconds then','if calls>=callLimit or attempts>=attemptLimit or os.clock()-started>=CFG.PlanSeconds then')
one('local shot,why=solve(g.r.player,mode); calls=calls+1','local beforeCalls=frameCalls\n            local shot,why=solve(g.r.player,mode);calls=calls+(frameCalls-beforeCalls);attempts=attempts+1')
s=s.replace('if pass<3 then limited=true end','if pass<#plannerModes then limited=true end')
one('function controller.Stop(reason)','function controller.Stop(reason)\n    controller.unified.holds=setmetatable({},{__mode="k"});controller.bad.open=false;controller.bad.finalActive=false\n    if controller.bad.current then controller.bad.current.Stop={Reason=clean(reason or \"USER_END\"),At=os.clock()};if controller.bad.current.Final and not controller.bad.current.SentAt then controller.bad.current.Final.Status=\"STOPPED_BEFORE_REQUEST\";controller.bad.current.Final.Gate=clean(reason or \"USER_END\")end end')

# Accurate active-policy labels; unsupported prototype controls are retired.
s=s.replace(s.splitlines()[0],'-- PELICAN_FF3_V26 (experimental-unified-b3.4): generated repair of V26.22.')
for prefix,value in {
 'OPEN_COMFORT_POLICY':'NATIVE_ENDPOINT_EASE_RANKING; CONDITIONAL_HIGH_ONLY; NO_FREE_POINT_OR_MAG_ADAPTER',
 'CLOSE_BULLET_POLICY':'ACTUAL_NATIVE_FLIGHT_FLOORS; COMFORT_BEFORE_FASTEST; LOWER_POWER_MUST_BE_SUPPORTED_AND_SAFE',
 'MAG_POLICY':'UNSUPPORTED_IN_B3; ENABLE_REJECTED; CONTROL_REMOVED',
 'JUMP_BULLET_POLICY':'CUSTOM_RAISED_BULLET_UNSUPPORTED; HIGH_USES_NATIVE_JUMP_OWN_LEAD_AND_FRESH_PROOFS',
 'AUTO_JUMP_POLICY':'FRESH_NATIVE_PREFLIGHT; OBSERVED_RISING_TAKEOFF_OFFSET; CANCELLED_JUMP_RECOVERY; NO_KNOWN_PHYSICS_GROUND_FALLBACK',
}.items():
 import re
 s=re.sub(r"'"+prefix+r"\|[^']*'",repr(prefix+'|'+value),s)
s=s.replace('FASTEST_ALLOWED_FLIGHT; OVERLAP_MODEL_UNCALIBRATED','ORDERED_COMFORT_COMPARISON; OVERLAP_MODEL_UNCALIBRATED')

# Update controls and history without rewriting native calculations.
one("'RELEASE_VERSION|ff3-v26.22'","'RELEASE_VERSION|experimental-unified-b3.4'")
s=s.replace("Release='ff3-v26.21'","Release='experimental-unified-b3.4'")
s=s.replace("MagTrial=shot.magTrial,MagExtraY=","Unified=controller.bad:result(shot.unified),MagTrial=shot.magTrial,MagExtraY=")
s=s.replace("Risk=riskPolicy.mode,Ping=shot.networkPing,DirectLane=shot.directLane,","Unified=controller.bad:result(shot.unified),Risk=riskPolicy.mode,Ping=shot.networkPing,DirectLane=shot.directLane,")
one("Source='QUALIFIED_SHARED_NATIVE_SETTINGS',SafetyReads=","Source='QUALIFIED_SHARED_NATIVE_SETTINGS',UnifiedParameters=controller.unified.config,SafetyReads=")
s=instrument(s,root)
(root/'experimental/auto_qb.lua').write_text(s)
loader=(root/'loader.lua').read_text().replace('Ref = "93832398e74edb83743bf0bcacc81aa8a5f8bd57"','Ref = "experimental-unified-b3.4"').replace('Path = "games/ff3/auto_qb.lua"','Path = "experimental/auto_qb.lua"')
loader=loader.replace('"main"','"repair-unified-qb"').replace('/main/loader.lua','/repair-unified-qb/experimental/loader.lua')
(root/'experimental/loader.lua').write_text(loader)
print('Generated B3 repair; production V26.22 untouched')
