from pathlib import Path
import hashlib

def instrument(s,root):
    module=(root/'experimental/bad_play.lua').read_text()
    engine=(root/'experimental/decision_engine.lua').read_bytes()
    code=hashlib.sha256(b''.join((root/p).read_bytes() for p in ['experimental/decision_engine.lua','experimental/bad_play.lua','scripts/build_experimental.py','scripts/instrument_bad_play.py','games/ff3/auto_qb.lua'])).hexdigest()
    engine_id=hashlib.sha256(engine).hexdigest()
    # Inline factory avoids exceeding the baseline chunk local-variable limit.
    s=s.replace('controller.unified=Unified.new((context.FF3Options or {}).Unified)',f"controller.unified=Unified.new((context.FF3Options or {{}}).Unified)\ncontroller.bad=(function()\n{module}\nend)().new('{code}','{engine_id}')\ncontroller.bad.pinned=env.PELICAN_FF3_BAD_PLAY_REPORT")
    s=s.replace("local function setGate(value)","local function setGate(value)\n    controller.bad:gate(value)")
    old="""    controller.unified:evaluate(shot,receiver,defenders,{gravity=CFG.Gravity,mode=riskPolicy.mode,
        gain=math.max(0,downfield(shot.arrival)/3),endzone=controller.field.InEndzone(shot.arrival)})"""
    new="""    local inputs={gravity=CFG.Gravity,mode=riskPolicy.mode,gain=math.max(0,downfield(shot.arrival)/3),endzone=controller.field.InEndzone(shot.arrival)}
    local begun=os.clock()
    controller.unified:evaluate(shot,receiver,defenders,inputs)
    controller.bad:grade(shot,receiver,defenders,inputs,controller.unified.config,os.clock()-begun)"""
    assert old in s;s=s.replace(old,new)
    s=s.replace("    controller.unified.generation=(controller.unified.generation or 0)+1", "    controller.unified.generation=(controller.unified.generation or 0)+1\n    controller.bad:begin(possession.epoch,now,receivers,plannerModes,defenders,controller.unified.config,riskPolicy.mode,controller.passPlan.mode)")
    s=s.replace('    local calls,started,limited=0,os.clock(),false', '    for _,g in ipairs(groups)do controller.bad:schedule(g.r.player.Name,plannerModes)end\n    local calls,started,limited=0,os.clock(),false')
    s=s.replace('local shot,why=solve(g.r.player,mode); calls=calls+1','local shot,why=solve(g.r.player,mode); calls=calls+1\n            controller.bad:native(g.r.player.Name,mode,shot,why)')
    s=s.replace('if limited then planDeferred=planDeferred+1 end','controller.bad.frame.NativeLimited=limited\n    if limited then planDeferred=planDeferred+1 end')
    s=s.replace("else receiverRejects[r.player.Name..'/'..mode]=rejection end", "else\n                    controller.bad:status(r.player.Name,mode,eligible and 'NOT_EVALUATED' or 'READINESS_REJECTED',eligible and 'GRADING_BUDGET' or rejection)\n                    receiverRejects[r.player.Name..'/'..mode]=rejection end")
    # Explicit unavailable/stale tuples, without classifying them as risk rejection.
    needle="""receiverRejects[r.player.Name..'/'..mode]=rejection end
            end
        end"""
    s=s.replace(needle,"""receiverRejects[r.player.Name..'/'..mode]=rejection end
            else controller.bad:status(r.player.Name,mode,'NOT_EVALUATED',shot and 'STALE_NATIVE_TUPLE' or 'NO_NATIVE_TUPLE')
            end
        end""")
    s=s.replace('    return best\nend\n-- Advisory only:', '    controller.bad:finish(best,os.clock()-started)\n    return best\nend\n-- Advisory only:')
    s=s.replace("    shot.planReason=shot.planAllowed and 'PASS_PLAN_ALLOWED' or 'EXPLICIT_DEPTH_PLAN'", "    shot.planReason=shot.planAllowed and 'PASS_PLAN_ALLOWED' or 'EXPLICIT_DEPTH_PLAN'\n    if controller.bad.open then local row=controller.bad:row(s.name,shot.variant or shot.mode);if row then row.PlanAllowed=shot.planAllowed;row.ReleaseBlocked=shot.releaseBlocked end elseif controller.bad.finalActive and controller.bad.current.Final then controller.bad.current.Final.PlanAllowed=shot.planAllowed end")
    s=s.replace("if shot then receipt.shot=shot;receipt.stage='FINAL_TUPLE_NOT_GRADED' end", "if shot then receipt.shot=shot;receipt.stage='FINAL_TUPLE_NOT_GRADED';controller.bad.current.Final.Native=controller.bad:trajectory(shot) end")
    s=s.replace('        maxHeartbeat=math.max(maxHeartbeat,os.clock()-now)', '        controller.bad:heartbeat(now,os.clock()-now,frameCalls)\n        maxHeartbeat=math.max(maxHeartbeat,os.clock()-now)')
    # Start receipt before native recalculation. Guard failures remain distinct from evaluator scores.
    s=s.replace("    local receipt={stage='FINAL_CONTEXT_CHECK'", "    local _,qbRoot,qbHead=body(me)\n    controller.bad:final(possession.epoch,now,qbRoot and {name='QB',p=qbRoot.Position,v=qbRoot.AssemblyLinearVelocity,head=qbHead},\n        {Leads=controller.receiverEvidence.ReadSettings(),NativeContext=controller.receiverEvidence.NativeContext(),Plan=controller.passPlan.mode,Profile=controller.league.mode,Field={LOS=controller.history.Vector(lines.los),Forward=controller.history.Vector(lines.forward)}})\n    local receipt={stage='FINAL_CONTEXT_CHECK'")
    s=s.replace("    if not shot then setGate(why); return end\n    if os.clock()-now>.28", "    if not shot then controller.bad.current.Final.NativeFailure=why;setGate(why); return end\n    if os.clock()-now>.28")
    s=s.replace("    if ok then\n        local observed,why=pcall(controller.receiverEvidence.Begin", "    if not throwId then throwId='bad:'..controller.bad.current.Id end\n    controller.bad:sent(throwId,ok and 'API_ACCEPTED_UNCONFIRMED' or 'AMBIGUOUS_NO_RETRY',os.clock())\n    if ok then\n        local observed,why=pcall(controller.receiverEvidence.Begin")
    s=s.replace('    function h.AttachObservation(id,value)','    function h.AttachObservation(id,value)\n        controller.bad:observe(id,value)')
    # A dedicated export retains the flagged possession and late observation attachments.
    needle="local built,buildError=pcall(function()"
    export=r'''function controller.ExportBadPlay()
    local report=controller.bad:report()
    if not report then return false,'FLAG_A_PLAY_FIRST' end
    local encoded=game:GetService('HttpService'):JSONEncode(report)
    if #encoded>1500000 then return false,'REPORT_SIZE_LIMIT; EVIDENCE_RETAINED_IN_MEMORY' end
    env.PELICAN_FF3_BAD_PLAY_REPORT=report
    local copy=type(setclipboard)=='function' and setclipboard or type(toclipboard)=='function' and toclipboard
    local copied=copy and pcall(copy,encoded) or false
    local saved=type(writefile)=='function' and pcall(writefile,'PELICAN_FF3_BAD_PLAY.json',encoded) or false
    return copied==true or saved==true,copied and 'COPIED' or saved and 'SAVED' or 'NO_EXPORT_API'
end
'''
    assert needle in s;s=s.replace(needle,export+needle)
    s=s.replace("    local kill=button('X'", "    controller.badButton=button('BAD PLAY',-366,106,62);controller.badButton.Size=UDim2.fromOffset(106,34)\n    connect(controller.badButton.Activated,function()\n        local ok,id=controller.bad:flag(os.clock())\n        controller.badButton.Text=ok and ('FLAGGED '..tostring(id)) or 'NO PLAY'\n        if ok then controller.ExportBadPlay() end\n    end)\n    local kill=button('X'")
    # COPY/DATA re-export pinned evidence; normal workflow stays when nothing flagged.
    s=s.replace("local ok,result=controller.history.Export();controller.history.button.Text", "local ok,result;if controller.bad:report() then ok,result=controller.ExportBadPlay() else ok,result=controller.history.Export() end;controller.history.button.Text")
    s=s.replace("connect(copyButton.Activated,function() preserve(true);", "connect(copyButton.Activated,function() if controller.bad:report() then controller.ExportBadPlay();copyButton.Text='BAD COPY';return end;preserve(true);")
    # Numeric legacy margins remain internal placeholders for compatibility, never diagnostic evidence.
    s=s.replace("'RELEASE_VERSION|experimental-unified-b1'", "'RELEASE_VERSION|experimental-unified-b2','BAD_PLAY_CODE_ID|'..controller.bad.CodeId")
    s=s.replace("Release='ff3-v26.21'", "Release=controller.bad.CodeId")
    for line in s.splitlines():
        if any(x in line for x in ["'RISK_LIMITS|","'TRUST_BURN_","'MAG_POLICY|","'SAFE_OPEN_SECONDS|","'RECEIVER_POLICY|"]):
            s=s.replace(line,"        'LEGACY_COVERAGE|INACTIVE_PLACEHOLDERS; DO_NOT_INTERPRET_MARGIN_LANE_AS_MEASUREMENTS',")
    # Clear legacy per-shot numerical diagnostic fields, while retaining runtime internals.
    s=s.replace('Margin=shot.margin,Lane=shot.lane,','LegacyCoverageUnavailable=true,')
    s=s.replace('Margin=other.margin,Lane=other.lane,','LegacyCoverageUnavailable=true,')
    s=s.replace('MarginDefender=h.Actor(shot.marginDB or', 'LegacyMarginDefender=h.Actor(shot.marginDB or')
    # Remove candidateEvidence strings showing fabricated zeros; structured records supersede them.
    start=s.index("            candidateEvidence[#candidateEvidence+1]=string.format")
    end=s.index('            if better(shot,bestShot)',start)
    s=s[:start]+s[end:]
    return s
