"""Generate isolated runtime from unchanged V26.22; no production file writes."""
from pathlib import Path
root=Path(__file__).resolve().parents[1]
s=(root/'games/ff3/auto_qb.lua').read_text()
engine=(root/'experimental/decision_engine.lua').read_text()
s=s.replace('local context = ... or {}','local context = ... or {}\nlocal Unified=(function()\n'+engine+'\nend)()')
s=s.replace("local controller = {Version=VERSION, IsStopped=false}","local controller = {Version=VERSION, IsStopped=false}\ncontroller.unified=Unified.new((context.FF3Options or {}).Unified)")
def replace(a,b,new):
 global s
 start=s.index(a);end=s.index(b,start);s=s[:start]+new+'\n'+s[end:]
replace('local function risk(shot,receiver,defenders)','local lastNativeInputs',r'''local function risk(shot,receiver,defenders)
    controller.unified:evaluate(shot,receiver,defenders,{gravity=CFG.Gravity,mode=riskPolicy.mode,
        gain=math.max(0,downfield(shot.arrival)/3),endzone=controller.field.InEndzone(shot.arrival)})
    shot.margin,shot.lane=0,0;shot.defenderETA=math.huge
    shot.wideMargin,shot.wideLane=0,0;shot.safetyOverTop=false;shot.safetyRead=nil
    shot.score=shot.unified.Score;shot.powerAllowed=true
    return shot
end''')
replace('local function coverage(shot,s,defenders)','controller.fit={}',r'''local function coverage(shot,s,defenders)
    shot.endzoneTarget=controller.field.InEndzone(shot.arrival)
    shot.catchDepthYards=downfield(shot.arrival)/3
    shot.deepTarget=shot.catchDepthYards>=controller.passPlan.deepYards
    shot.planAllowed=controller.passPlan.mode=='NORMAL' or controller.passPlan.mode=='DEEP' and (shot.deepTarget or shot.endzoneTarget)
        or controller.passPlan.mode=='SHORT' and not shot.deepTarget
    shot.planReason=shot.planAllowed and 'PASS_PLAN_ALLOWED' or 'EXPLICIT_DEPTH_PLAN'
    shot.clearBurn=false;shot.wideOpen=shot.unified.RiskScore<=controller.unified.config.SafeRisk
end
local function throwable(shot)
    return shot.planAllowed~=false and not shot.releaseBlocked and (not shot.magTrial or controller.mag.Allowed(shot.magPlayer))
        and Unified.allowed(shot,riskPolicy.mode)
end''')
replace('function controller.jumpBullet.assess(shot,alternatives)','local function classify(shot,s,defenders)',r'''function controller.jumpBullet.assess(shot) shot.jumpBulletAllowed=true;return throwable(shot) end
function controller.fit.assess(shot) shot.fitAllowed=true;return throwable(shot) end
local function better(a,b) return Unified.better(a,b,riskPolicy.mode) end
local function receiverBetter(a,b) return not b or better(a.shot,b.shot) end''')
# Remove independent incumbent priorities; opportunity score controls target retention.
replace('    if best and incumbent and best.player~=incumbent.player then','    return best', '')
# Keep freshness/possession/native checks; remove mode-specific counterfactual vetoes.
replace('    local fitVariant=selected.shot.fitAlternativeVariant','    -- Solve the actual throw last', '')
replace("    if fitComparison and fitComparison.variant=='Bullet' then receiver.chestReference=fitComparison end",'    eligible,rejection=receiverReady', '')
replace("    if shot.mode=='Fit' then\n        if not receiverReady",'    if not throwable(shot) then setGate', '')
# All grading paths reuse same evaluator. No automatic QB jump/delay for flight duration.
replace('local function deepThrow(shot,hum)','-- Request the ordinary jump only.', 'local function deepThrow() return false end')
# bounded diagnostics for each graded candidate, plus history on actual throws/blocks
s=s.replace('MagTrial=shot.magTrial,MagExtraY=', 'Unified=shot.unified,MagTrial=shot.magTrial,MagExtraY=')
s=s.replace('Risk=riskPolicy.mode,Ping=shot.networkPing,DirectLane=shot.directLane,','Unified=shot.unified,Risk=riskPolicy.mode,Ping=shot.networkPing,DirectLane=shot.directLane,')
s=s.replace("'RELEASE_VERSION|ff3-v26.22'","'RELEASE_VERSION|experimental-unified-b1','UNIFIED_MAX_SECONDS|'..controller.unified.maxSeconds,'UNIFIED_CHECKS|'..controller.unified.checks,'UNIFIED_CONFIG|'..game:GetService('HttpService'):JSONEncode(controller.unified.config)")
s=s.replace('    return best\nend\n-- Advisory only:',r'''    controller.unified.last={}
    for _,g in ipairs(groups)do for _,shot in pairs(g.cache.shots)do
        if shot.unified and now-shot.at<=CFG.CacheAge then
            local u=shot.unified
            controller.unified.last[#controller.unified.last+1]={Receiver=g.r.player.Name,Variant=shot.variant or shot.mode,
                Flight=shot.time,Power=shot.power,Evaluation=u,Selected=best and best.player==g.r.player and best.shot==shot,
                Reason=u.HardReason or shot.planAllowed==false and 'EXPLICIT_DEPTH_PLAN' or not throwable(shot) and 'RISK_TOLERANCE'
                    or best and best.shot==shot and 'WINNER' or 'LOWER_OPPORTUNITY_SCORE'}
        end
    end end
    return best
end
-- Advisory only:''')
s=s.replace("local rows={VERSION,", "local rows={VERSION,'UNIFIED_DECISIONS|'..game:GetService('HttpService'):JSONEncode(controller.unified.last or {}),")
# Diagnostic policy strings must not describe superseded policies.
for line in s.splitlines():
 if any(x in line for x in ["'BULLET_RISK_POLICY|","'SAFETY_POLICY|","'RISK_POLICY|","'FIT_POLICY|","'OPPORTUNITY_POLICY|"]):
  s=s.replace(line,"        'UNIFIED_POLICY|SHARED_MATCHUP_MODEL; NESTED_RISK_CAPS; NO_MODE_LABEL_RANKING; SCORES_UNCALIBRATED',")
# Prioritize cheap time-sensitive scoring hints; force oldest visit when stale.
s=s.replace("local best=evaluate(receivers,indices,defenders,now)","local best=evaluate(receivers,indices,defenders,now)")
s=s.replace("local oldest=-1", "local oldest=-1;local urgentPriority=-math.huge;local urgentIndex")
s=s.replace("local at=cache and cache.model==r.sample.model", "local soon=r.sample.p+r.sample.v*r.estimate\n                        local priority=(controller.field.InEndzone(soon) and 45 or 0)-r.estimate*3\n                        if priority>urgentPriority then urgentPriority=priority;urgentIndex=i end\n                        local at=cache and cache.model==r.sample.model")
s=s.replace("        local best=evaluate(receivers,indices,defenders,now)","        local best=evaluate(receivers,indices,defenders,now)")
# diagnostics include only this grading generation; cap 48 current records.
s=s.replace("local function evaluate(receivers,indices,defenders,now)\n", "local function evaluate(receivers,indices,defenders,now)\n    controller.unified.generation=(controller.unified.generation or 0)+1\n")
s=s.replace("    shot.margin,shot.lane=0,0;", "    shot.unified.Generation=controller.unified.generation\n    shot.margin,shot.lane=0,0;")
s=s.replace("if shot.unified and now-shot.at<=CFG.CacheAge then", "if shot.unified and shot.unified.Generation==controller.unified.generation and now-shot.at<=CFG.CacheAge and #controller.unified.last<48 then")
# Separate bound for arithmetic grading, beyond existing bounded native work.
s=s.replace("    local best,incumbent\n    candidateEvidence={}","    local best,incumbent\n    local gradingStarted=os.clock()\n    table.sort(groups,function(a,b)return (a.cache.gradedAt or -math.huge)<(b.cache.gradedAt or -math.huge)end)\n    candidateEvidence={}")
s=s.replace("                if eligible then\n                    risk(shot,r.sample,defenders);", "                if eligible and os.clock()-gradingStarted<.003 then\n                    g.cache.gradedAt=now\n                    risk(shot,r.sample,defenders);")
# Candidate scheduling hints use shared cheap cost, with age overriding urgency.
s=s.replace("                local oldest=-1;local urgentPriority=-math.huge;local urgentIndex", "                local oldest=-1;local urgentPriority=-math.huge;local urgentIndex")
s=s.replace("        local best=evaluate(receivers,indices,defenders,now)","        if indices[2] and urgentIndex and now-oldest<CFG.CacheAge then indices[2]=urgentIndex end\n        local best=evaluate(receivers,indices,defenders,now)") if False else s
s=s.replace("            end\n        end\n        local best=evaluate(receivers,indices,defenders,now)","                if urgentIndex and now-oldest<CFG.CacheAge then indices[2]=urgentIndex end\n            end\n        end\n        local best=evaluate(receivers,indices,defenders,now)")

# Remove expensive legacy counterfactual regrades: all candidates already share one evaluator.
s=s.replace("controller.fit.assess(best.shot,controller.fit.alternatives(best.player,best.sample,defenders,now))","controller.fit.assess(best.shot)")
s=s.replace("controller.jumpBullet.assess(best.shot,controller.fit.alternatives(best.player,best.sample,defenders,now,nil,nil,true))","controller.jumpBullet.assess(best.shot)")
s=s.replace("        local valid={}\n        for _,mode in ipairs(plannerModes) do", "        local valid={}\n        local gradeRotation=g.cache.gradeRotation or 0\n        for offset=1,#plannerModes do\n            local mode=plannerModes[(offset+gradeRotation-1)%#plannerModes+1]")
s=s.replace("                    g.cache.gradedAt=now", "                    g.cache.gradedAt=now;g.cache.gradeRotation=(offset+gradeRotation)%#plannerModes")
s=s.replace("Evaluation=u,Selected=", "DecisionAge=math.max(0,now-shot.at),Evaluation=u,Selected=")
s=s.replace("Source='QUALIFIED_SHARED_NATIVE_SETTINGS',SafetyReads=", "Source='QUALIFIED_SHARED_NATIVE_SETTINGS',UnifiedParameters=controller.unified.config,SafetyReads=")
# Regression repairs + BAD PLAY capture. Applied only to the isolated experimental runtime.
# repair: restore deep release jump
assert s.count("local function deepThrow() return false end")==1, "repair source marker mismatch: restore deep release jump"
s=s.replace("local function deepThrow() return false end","local function deepThrow(shot,hum)\n    if shot.softBullet or shot.screen then return false end -- softened close pass or deliberate stationary screen\n    local ascent=ascentTime(hum)\n    -- A timing policy relative to this character's normal jump, not an\n    -- invented official FF3 yardage/catch threshold. Missing jump parameters\n    -- still classify elevated native modes for a normal jump. The short takeoff\n    -- offset is handled separately; no yard cutoff or peak gate is introduced.\n    return ascent and shot.time>ascent*2 or not ascent and shot.mode~='Bullet'\nend")
# repair: restore comfort safety
assert s.count("shot.score=shot.unified.Score;shot.powerAllowed=true")==1, "repair source marker mismatch: restore comfort safety"
s=s.replace("shot.score=shot.unified.Score;shot.powerAllowed=true","shot.score=shot.unified.Score;shot.powerAllowed=touch.fullAllowed(shot)")
# repair: restore clear burn indication
assert s.count("shot.clearBurn=false;shot.wideOpen=shot.unified.RiskScore<=controller.unified.config.SafeRisk")==1, "repair source marker mismatch: restore clear burn indication"
s=s.replace("shot.clearBurn=false;shot.wideOpen=shot.unified.RiskScore<=controller.unified.config.SafeRisk","shot.wideOpen=shot.unified.RiskScore<=controller.unified.config.SafeRisk\n    shot.clearBurn=lines.forward~=nil and flat(s.v):Dot(lines.forward)>CFG.MinMoveSpeed\n        and flat(shot.arrival-s.p):Dot(flat(s.v))>0\n        and shot.unified.RiskScore<=controller.unified.config.ModRisk or false")
# repair: respect comfort at release
assert s.count("return shot.planAllowed~=false and not shot.releaseBlocked and (not shot.magTrial or controller.mag.Allowed(shot.magPlayer))\n        and Unified.allowed(shot,riskPolicy.mode)")==1, "repair source marker mismatch: respect comfort at release"
s=s.replace("return shot.planAllowed~=false and not shot.releaseBlocked and (not shot.magTrial or controller.mag.Allowed(shot.magPlayer))\n        and Unified.allowed(shot,riskPolicy.mode)","return shot.planAllowed~=false and not shot.releaseBlocked and shot.powerAllowed~=false\n        and (not shot.magTrial or controller.mag.Allowed(shot.magPlayer))\n        and Unified.allowed(shot,riskPolicy.mode)")
# repair: reject comfort-disallowed candidates before ranking
assert s.count("local function better(a,b) return Unified.better(a,b,riskPolicy.mode) end")==1, "repair source marker mismatch: reject comfort-disallowed candidates before ranking"
s=s.replace("local function better(a,b) return Unified.better(a,b,riskPolicy.mode) end","local function better(a,b)\n    if not b then return true end\n    local ar,br=throwable(a),throwable(b)\n    if ar~=br then return ar end\n    return Unified.better(a,b,riskPolicy.mode)\nend")
# repair: make OpenComfort functional
assert s.count("gain=math.max(0,downfield(shot.arrival)/3),endzone=controller.field.InEndzone(shot.arrival)})")==1, "repair source marker mismatch: make OpenComfort functional"
s=s.replace("gain=math.max(0,downfield(shot.arrival)/3),endzone=controller.field.InEndzone(shot.arrival)})","gain=math.max(0,downfield(shot.arrival)/3),endzone=controller.field.InEndzone(shot.arrival),\n        comfortWeight=controller.unified.config.ComfortWeight*(controller.passPlan.openComfort and 1.3 or .5)})")
# repair: track skipped grading
assert s.count("    controller.unified.generation=(controller.unified.generation or 0)+1\n")==1, "repair source marker mismatch: track skipped grading"
s=s.replace("    controller.unified.generation=(controller.unified.generation or 0)+1\n","    controller.unified.generation=(controller.unified.generation or 0)+1\n    controller.unified.skipped={}\n")
# repair: distinct budget rejection
assert s.count("                else receiverRejects[r.player.Name..'/'..mode]=rejection end")==1, "repair source marker mismatch: distinct budget rejection"
s=s.replace("                else receiverRejects[r.player.Name..'/'..mode]=rejection end","                else\n                    local reason=not eligible and (rejection or 'RECEIVER_INELIGIBLE') or 'GRADE_BUDGET_NOT_EVALUATED'\n                    receiverRejects[r.player.Name..'/'..mode]=reason\n                    if #controller.unified.skipped<48 then controller.unified.skipped[#controller.unified.skipped+1]={\n                        Receiver=r.player.Name,Variant=mode,Reason=reason,GradingSeconds=os.clock()-gradingStarted} end\n                end")
# repair: record unsolved budget modes
assert s.count("    if limited then planDeferred=planDeferred+1 end")==1, "repair source marker mismatch: record unsolved budget modes"
s=s.replace("    if limited then planDeferred=planDeferred+1 end","    if limited then\n        planDeferred=planDeferred+1\n        for _,g in ipairs(groups)do for _,mode in ipairs(plannerModes)do\n            if not g.tried[mode] and #controller.unified.skipped<48 then\n                controller.unified.skipped[#controller.unified.skipped+1]={\n                    Receiver=g.r.player.Name,Variant=mode,Reason='NATIVE_PLANNING_BUDGET_NOT_EVALUATED'}\n            end\n        end end\n    end")
# repair: preserve structured planner snapshot
assert s.count("    return best\nend\n-- Advisory only:")==1, "repair source marker mismatch: preserve structured planner snapshot"
s=s.replace("    return best\nend\n-- Advisory only:","    controller.unified.recentPlan={\n        Epoch=possession.epoch,At=os.clock(),Mode=riskPolicy.mode,PassPlan=controller.passPlan.mode,\n        Winner=best and {Receiver=best.player.Name,Variant=best.shot.variant or best.shot.mode,\n            Score=best.shot.unified and best.shot.unified.Score} or nil,\n        Candidates=controller.unified.last,Skipped=controller.unified.skipped,\n        Config=controller.unified.config,NativeSolverCalls=nativeCalls}\n    return best\nend\n-- Advisory only:")
# repair: record actual native final-release snapshot
assert s.count("    local lastDecision={summary=evidence,actors={},release=")==1, "repair source marker mismatch: record actual native final-release snapshot"
s=s.replace("    local lastDecision={summary=evidence,actors={},release=","    controller.unified.lastRelease={Epoch=possession.epoch,At=os.clock(),ReleaseStatus='REQUEST_PREPARED_UNCONFIRMED',\n        Planner=controller.unified.recentPlan,Mode=riskPolicy.mode,PassPlan=controller.passPlan.mode,\n        Receiver=selected.player.Name,Variant=shot.variant or shot.mode,Power=shot.power,Flight=shot.time,\n        Origin={shot.origin.X,shot.origin.Y,shot.origin.Z},Velocity={shot.velocity.X,shot.velocity.Y,shot.velocity.Z},\n        Arrival={shot.arrival.X,shot.arrival.Y,shot.arrival.Z},Gravity=CFG.Gravity,\n        Unified=shot.unified,NetworkPing=shot.networkPing,NativeSolveAge=os.clock()-shot.at,\n        QB={current.root.Position.X,current.root.Position.Y,current.root.Position.Z},\n        ReceiverState={Position={selected.sample.p.X,selected.sample.p.Y,selected.sample.p.Z},\n            Velocity={selected.sample.v.X,selected.sample.v.Y,selected.sample.v.Z}},\n        Defenders={},Config=controller.unified.config}\n    for i,d in ipairs(defenders)do if i>16 then break end\n        controller.unified.lastRelease.Defenders[#controller.unified.lastRelease.Defenders+1]={\n            Name=d.name,Position={d.p.X,d.p.Y,d.p.Z},Velocity={d.v.X,d.v.Y,d.v.Z}} end\n    local lastDecision={summary=evidence,actors={},release=")
# repair: record result uncertainty
assert s.count("    if ok then\n        local observed,why=pcall(controller.receiverEvidence.Begin")==1, "repair source marker mismatch: record result uncertainty"
s=s.replace("    if ok then\n        local observed,why=pcall(controller.receiverEvidence.Begin","    if controller.unified.lastRelease then controller.unified.lastRelease.ReleaseStatus=\n        ok and 'API_ACCEPTED_UNCONFIRMED' or 'AMBIGUOUS_NO_RETRY' end\n    if ok then\n        local observed,why=pcall(controller.receiverEvidence.Begin")
# repair: expose bad play & skipped in report
assert s.count("local rows={VERSION,'UNIFIED_DECISIONS|'..game:GetService('HttpService'):JSONEncode(controller.unified.last or {}),")==1, "repair source marker mismatch: expose bad play & skipped in report"
s=s.replace("local rows={VERSION,'UNIFIED_DECISIONS|'..game:GetService('HttpService'):JSONEncode(controller.unified.last or {}),","local rows={VERSION,'UNIFIED_DECISIONS|'..game:GetService('HttpService'):JSONEncode(controller.unified.last or {}),\n        'UNIFIED_SKIPPED|'..game:GetService('HttpService'):JSONEncode(controller.unified.skipped or {}),\n        'BAD_PLAY_DIAGNOSTIC|'..game:GetService('HttpService'):JSONEncode(controller.unified.bad or {}),")
# repair: mobile BAD PLAY button
assert s.count("    autoButton=button('AUTO ON',-166,58,87); throwButton=button('THR ON',-105,51,87); copyButton=button('COPY',-51,47,87)")==1, "repair source marker mismatch: mobile BAD PLAY button"
s=s.replace("    autoButton=button('AUTO ON',-166,58,87); throwButton=button('THR ON',-105,51,87); copyButton=button('COPY',-51,47,87)","    autoButton=button('AUTO ON',-166,58,87); throwButton=button('THR ON',-105,51,87); copyButton=button('COPY',-51,47,87)\n    local badPlayButton=button('BAD PLAY',-144,100,302);badPlayButton.Name='BadPlay'\n    connect(badPlayButton.Activated,function()\n        local released=controller.unified.lastRelease\n        local plan=controller.unified.recentPlan\n        local newest=released and (not plan or released.Epoch==plan.Epoch or os.clock()-released.At<8) and released or plan\n        controller.unified.bad=newest\n        badPlayButton.Text=newest and 'FLAGGED' or 'NO PLAY'\n        if newest then preserve(true) end\n    end)")
# repair: show BAD PLAY on expanded HUD
assert s.count("        autoButton.Visible=expanded;throwButton.Visible=expanded;copyButton.Visible=expanded;riskButton.Visible=expanded")==1, "repair source marker mismatch: show BAD PLAY on expanded HUD"
s=s.replace("        autoButton.Visible=expanded;throwButton.Visible=expanded;copyButton.Visible=expanded;riskButton.Visible=expanded","        autoButton.Visible=expanded;throwButton.Visible=expanded;copyButton.Visible=expanded;riskButton.Visible=expanded\n        badPlayButton.Visible=expanded and not league")
# repair: BAD PLAY initially hidden
assert s.count("    autoButton.Visible=false; throwButton.Visible=false; copyButton.Visible=false; receiverButton.Visible=false;riskButton.Visible=false; receiverMenu.Visible=false")==1, "repair source marker mismatch: BAD PLAY initially hidden"
s=s.replace("    autoButton.Visible=false; throwButton.Visible=false; copyButton.Visible=false; receiverButton.Visible=false;riskButton.Visible=false; receiverMenu.Visible=false","    autoButton.Visible=false; throwButton.Visible=false; copyButton.Visible=false; receiverButton.Visible=false;riskButton.Visible=false; receiverMenu.Visible=false\n    badPlayButton.Visible=false")
# repair: remove stale Trust policy report
assert s.count("'TRUST_BURN_POLICY|ORDINARY_BULLET_DIME; CURRENT_AND_PROJECTED_GAP_4; NO_OVER_TOP; EARLY_PATH_CLEAR; FINAL_CONTEST_ALLOWED'")==1, "repair source marker mismatch: remove stale Trust policy report"
s=s.replace("'TRUST_BURN_POLICY|ORDINARY_BULLET_DIME; CURRENT_AND_PROJECTED_GAP_4; NO_OVER_TOP; EARLY_PATH_CLEAR; FINAL_CONTEST_ALLOWED'","'TRUST_BURN_POLICY|SUPERSEDED_IN_EXPERIMENT_BY_UNIFIED_RISK_CAPS'")
# repair: accurate OpenComfort report
assert s.count("'OPEN_COMFORT_POLICY|SAFE_ORDINARY_BULLET_FIRST; NATIVE_JUMP_NOT_PLANNED; CUSTOM_JB_REQUIRES_FRESH_CHEST_THREAT'")==1, "repair source marker mismatch: accurate OpenComfort report"
s=s.replace("'OPEN_COMFORT_POLICY|SAFE_ORDINARY_BULLET_FIRST; NATIVE_JUMP_NOT_PLANNED; CUSTOM_JB_REQUIRES_FRESH_CHEST_THREAT'","'OPEN_COMFORT_POLICY|UNIFIED_CATCH_COST_WEIGHT_1_3X; NATIVE_SUPPORTED_MODES; NATIVE_JUMP_NOT_PLANNED'")
# repair: accurate deep-throw report
assert s.count("'DEEP_POLICY|FLIGHT_EXCEEDS_CURRENT_NORMAL_JUMP_AIRTIME; NO_YARD_CUTOFF'")==1, "repair source marker mismatch: accurate deep-throw report"
s=s.replace("'DEEP_POLICY|FLIGHT_EXCEEDS_CURRENT_NORMAL_JUMP_AIRTIME; NO_YARD_CUTOFF'","'DEEP_POLICY|RESTORED_NORMAL_QB_JUMP_FOR_LONG_NATIVE_FLIGHT; NO_YARD_CUTOFF'")
# repair followup 1
assert s.count("local function submit(ball,selected,defenders,now)")==1
s=s.replace("local function submit(ball,selected,defenders,now)","-- Short, conditional observation window for a receiver entering the legal route\n-- area on an unsettled diagonal. The QB never predicts an unobserved future cut.\nlocal routeTiming=setmetatable({}, {__mode='k'})\nlocal function developingRouteHold(selected,now)\n    local r=selected.sample;local shot=selected.shot\n    if not r or not shot or not shot.unified or not lines.forward or not r.path or #r.path<3\n        or shot.deepTarget or shot.endzoneTarget then return false end\n    local depth=downfield(r.p)/3\n    if depth<6 or depth>9.5 then return false end\n    local v=flat(r.v);local speed=v.Magnitude\n    if speed<CFG.MinMoveSpeed then return false end\n    local alignment=v.Unit:Dot(lines.forward)\n    if alignment<.25 or alignment>.89 then return false end\n    local u=shot.unified;local c=controller.unified.config\n    if u.RiskScore>c.ModRisk or (u.CatchDifficulty or 0)<1 then return false end\n    local p=r.path\n    local before=flat(p[#p-1].p-p[#p-2].p)\n    local previous=before.Magnitude>1e-4 and before.Unit:Dot(lines.forward) or alignment\n    local improving=alignment>previous+.045\n    local unsettled=(r.routeTurn or 0)>.12\n    -- The receiver is already eligible, but a short continuation may improve a\n    -- difficult diagonal approach. No delay on a stable easy catch, clear deep\n    -- play, scoring target, or more urgent contested window.\n    if not improving and not unsettled and u.CatchDifficulty<1.8 then return false end\n    local active=routeTiming[selected.player]\n    if not active or active.Epoch~=possession.epoch or active.Model~=r.model then\n        active={Epoch=possession.epoch,Model=r.model,Since=now};routeTiming[selected.player]=active end\n    if now-active.Since>=.20 then return false end\n    controller.unified.lastRouteHold={Epoch=possession.epoch,Receiver=selected.player.Name,\n        DepthYards=depth,Alignment=alignment,PreviousAlignment=previous,\n        CatchDifficulty=u.CatchDifficulty,RiskScore=u.RiskScore,HoldSeconds=.20}\n    return true\nend\nlocal function submit(ball,selected,defenders,now)\n    if developingRouteHold(selected,now) then setGate('WAIT_DIAGONAL_ROUTE_DEVELOPMENT');return end")
# repair followup 2
assert s.count("'BAD_PLAY_DIAGNOSTIC|'..game:GetService('HttpService'):JSONEncode(controller.unified.bad or {}),")==1
s=s.replace("'BAD_PLAY_DIAGNOSTIC|'..game:GetService('HttpService'):JSONEncode(controller.unified.bad or {}),","'BAD_PLAY_DIAGNOSTIC|'..game:GetService('HttpService'):JSONEncode(controller.unified.bad or {}),\n        'ROUTE_TIMING_LAST_HOLD|'..game:GetService('HttpService'):JSONEncode(controller.unified.lastRouteHold or {}),")
# repair followup 3
assert s.count("'RELEASE_VERSION|experimental-unified-b1'")==1
s=s.replace("'RELEASE_VERSION|experimental-unified-b1'","'RELEASE_VERSION|repair-b2-20261024'")
(root/'experimental/auto_qb.lua').write_text(s)
# Private loader copy has same ownership namespace; its X reload stays experimental.
loader=(root/'loader.lua').read_text().replace('Ref = "93832398e74edb83743bf0bcacc81aa8a5f8bd57"','Ref = "experimental-unified-qb"').replace('Path = "games/ff3/auto_qb.lua"','Path = "experimental/auto_qb.lua"')
loader=loader.replace('"main"','"experimental-unified-qb"').replace('/main/loader.lua','/experimental-unified-qb/experimental/loader.lua')
loader=loader.replace('experimental-unified-qb','fix/auto-qb-regressions-20261024')
(root/'experimental/loader.lua').write_text(loader)
print('Generated experimental runtime and loader; production untouched')
