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
from instrument_bad_play import instrument
s=instrument(s,root)
(root/'experimental/auto_qb.lua').write_text(s)
# Private loader copy has same ownership namespace; its X reload stays experimental.
loader=(root/'loader.lua').read_text().replace('Ref = "93832398e74edb83743bf0bcacc81aa8a5f8bd57"','Ref = "experimental-unified-qb"').replace('Path = "games/ff3/auto_qb.lua"','Path = "experimental/auto_qb.lua"')
loader=loader.replace('"main"','"experimental-unified-qb"').replace('/main/loader.lua','/experimental-unified-qb/experimental/loader.lua')
(root/'experimental/loader.lua').write_text(loader)
print('Generated experimental runtime and loader; production untouched')
