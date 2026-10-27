from pathlib import Path
import hashlib

def instrument(s,root):
    def one(old,new):
        nonlocal s
        assert s.count(old)==1,(old[:90],s.count(old));s=s.replace(old,new,1)
    module=(root/'experimental/bad_play.lua').read_text()
    inputs=['experimental/decision_engine.lua','experimental/bad_play.lua','experimental/compact_hud.lua','experimental/oscillation.lua','experimental/presentation.lua','scripts/build_experimental.py','scripts/instrument_bad_play.py','scripts/build_guard_replay.py','scripts/repair_coverage.py','scripts/repair_guide.py','games/ff3/auto_qb.lua']
    code=hashlib.sha256(b''.join((root/p).read_bytes() for p in inputs)).hexdigest()
    engine_id=hashlib.sha256((root/'experimental/decision_engine.lua').read_bytes()).hexdigest()
    one('controller.unified=Unified.new((context.FF3Options or {}).Unified)',f"controller.unified=Unified.new((context.FF3Options or {{}}).Unified)\ncontroller.bad=(function()\n{module}\nend)().new('{code}','{engine_id}')\ncontroller.bad.pinned=env.PELICAN_FF3_BAD_PLAY_REPORT")
    hud=(root/'experimental/compact_hud.lua').read_text()
    one('controller.bad.pinned=env.PELICAN_FF3_BAD_PLAY_REPORT','controller.bad.pinned=env.PELICAN_FF3_BAD_PLAY_REPORT\ncontroller.unified.helperHUD=(function()\n'+hud+'\nend)().new(pg,env)')
    one('controller.bad.open=false;controller.bad.finalActive=false','controller.bad.open=false;controller.bad.finalActive=false;controller.unified.helperHUD:stop()')
    one('controller.league.Update(now);controller.jumpTiming.Observe(now);','controller.league.Update(now);if ff3Options.CompactCompanionHUD~=false then controller.unified.helperHUD:check(now)end;controller.jumpTiming.Observe(now);')
    one('local function setGate(value)',"local function setGate(value)\n    controller.bad:gate(value)")
    one("if status then status.Text=(choice and choice.player.Name..' ' or '')..value:gsub('_',' '):sub(1,24) end", "if status then status.Text=expanded and value:gsub('_',' '):sub(1,24) or 'QB' end")
    settings=r'''function controller.unified.Settings()
    return {Auto=auto,AutomaticThrow=throwing,Risk=riskPolicy.mode,Plan=controller.passPlan.mode,
        Profile=controller.league.mode,RequestedProfile=controller.league.requested,ReceiverFilter=controller.receiverFilter.mode,
        OpenComfort=controller.passPlan.openComfort,NativeJump=controller.nativeJump.enabled,AdaptiveAngle=controller.angle.enabled,
        SafetyReads=controller.safety.enabled,CoverageWindows=controller.coverageWindows.enabled,JumpDelaySeconds=controller.jumpTiming.delay,
        MovementGuide={Enabled=ff3Options.MovementGuide~=false,Status=controller.groundGuide.status,Draws=controller.groundGuide.draws,Checks=assistance.guideChecks},
        MinDownfieldYards=CFG.MinDownfieldYards,WorldGravity=workspace.Gravity,Unified=controller.unified.config,
        CloseBullet={Enabled=touch.enabled,Comfort=touch.comfort,Quick=touch.quick,MinPower=touch.min,FullPowerYards=touch.full},
        Leads=controller.receiverEvidence.ReadSettings(),NativeContext=controller.receiverEvidence.NativeContext(),
        Field={LOS=controller.history.Vector(lines.los),Forward=controller.history.Vector(lines.forward),GoalToGo=lines.goalToGo,Generation=lines.generation,Status=lines.status}}
end
'''
    one('local function evaluate(receivers,indices,defenders,now)', settings+'local function evaluate(receivers,indices,defenders,now)\n    controller.bad:begin(possession.epoch,now,receivers,plannerModes,defenders,controller.unified.config,riskPolicy.mode,controller.passPlan.mode)\n    controller.bad.frame.Settings=controller.unified.Settings()')
    one('    local calls,started,limited=0,os.clock(),false','    for _,g in ipairs(groups)do controller.bad:schedule(g.r.player.Name,plannerModes)end\n    local calls,started,limited=0,os.clock(),false')
    one('local shot,why=solve(g.r.player,mode);calls=calls+(frameCalls-beforeCalls);attempts=attempts+1','local shot,why=solve(g.r.player,mode);calls=calls+(frameCalls-beforeCalls);attempts=attempts+1\n            controller.bad:native(g.r.player.Name,mode,shot,why,frameCalls>beforeCalls)')
    one('if limited then planDeferred=planDeferred+1 end','controller.bad.frame.NativeLimited=limited\n    if limited then planDeferred=planDeferred+1 end')
    one("else receiverRejects[r.player.Name..'/'..mode]=rejection end\n            end\n        end", "else controller.bad:status(r.player.Name,mode,'READINESS_REJECTED',rejection,shot);receiverRejects[r.player.Name..'/'..mode]=rejection end\n            else controller.bad:status(r.player.Name,mode,'NOT_EVALUATED',shot and 'STALE_NATIVE_TUPLE' or 'NO_NATIVE_TUPLE',shot)\n            end\n        end")
    one('    return best\nend\n-- Advisory only:', '    controller.bad:finish(best,os.clock()-started)\n    return best\nend\n-- Advisory only:')
    one('        observePossession(now)','        observePossession(now)\n        local evidence=controller.bad:pos(possession.epoch,now);if evidence then evidence.Settings=controller.unified.Settings()end')
    one('        receiverRejects={};receiverRejectAt=now','        receiverRejects={};receiverRejectAt=now;controller.bad:eligibility(now)')
    one("else receiverRejects[player.Name]=rejection; opportunities[player]=nil; shotCache[player]=nil end", "else controller.bad:excluded(player.Name,s,rejection);receiverRejects[player.Name]=rejection;opportunities[player]=nil;shotCache[player]=nil end")
    one("receiverRejects[player.Name]='MOVEMENT_UNVERIFIED'; opportunities[player]=nil; shotCache[player]=nil", "controller.bad:excluded(player.Name,s,'MOVEMENT_UNVERIFIED',player.Team==me.Team and 'TEAMMATE' or 'OPPONENT')\n                    receiverRejects[player.Name]='MOVEMENT_UNVERIFIED'; opportunities[player]=nil; shotCache[player]=nil")
    one("elseif player.Team~=me.Team then defenders[#defenders+1]=s end\n            end\n        end", "elseif player.Team~=me.Team then defenders[#defenders+1]=s end\n            elseif player~=me and player.Team==me.Team then controller.bad:excluded(player.Name,nil,player.Neutral and 'NEUTRAL_TEAMMATE' or 'NO_LIVE_CHARACTER')\n            end\n        end")

    one('        maxHeartbeat=math.max(maxHeartbeat,os.clock()-now)','        controller.bad:heartbeat(now,os.clock()-now,frameCalls)\n        maxHeartbeat=math.max(maxHeartbeat,os.clock()-now)')
    one("    local receipt={stage='FINAL_CONTEXT_CHECK'", "    local _,qr,qh=body(me)\n    controller.bad:final(possession.epoch,now,qr and {name='QB',p=qr.Position,v=qr.AssemblyLinearVelocity,head=qh},\n        controller.unified.Settings(),selected.shot.variant or selected.shot.mode)\n    local receipt={stage='FINAL_CONTEXT_CHECK'")
    one("if shot then receipt.shot=shot;receipt.stage='FINAL_TUPLE_NOT_GRADED' end", "if shot then receipt.shot=shot;receipt.stage='FINAL_TUPLE_NOT_GRADED';controller.bad.current.Final.Native=controller.bad:trajectory(shot) end")
    one("    if not shot then setGate(why); return end\n    if os.clock()-now>.28", "    if not shot then controller.bad.current.Final.NativeFailure=why;setGate(why);return end\n    if os.clock()-now>.28")
    one("    usedTools[ball.tool]=possession.epoch; attempts=attempts+1", "    controller.bad:released(shot)\n    usedTools[ball.tool]=possession.epoch; attempts=attempts+1")
    one("    if ok then\n        local observed,why=pcall(controller.receiverEvidence.Begin", "    if not throwId then throwId='bad:'..controller.bad.current.Id end\n    controller.bad:sent(throwId,ok and 'API_ACCEPTED_UNCONFIRMED' or 'AMBIGUOUS_NO_RETRY',os.clock())\n    if ok then\n        local observed,why=pcall(controller.receiverEvidence.Begin")
    one('    function h.AttachObservation(id,value)','    function h.AttachObservation(id,value)\n        controller.bad:observe(id,value)')
    export=r'''function controller.ExportBadPlay()
    local function done(ok,value)controller.bad.exportStatus=value;return ok,value end
    local report=controller.bad:report();if not report then return done(false,'FLAG_A_PLAY_FIRST') end
    env.PELICAN_FF3_BAD_PLAY_REPORT=report
    local http=game:GetService('HttpService')
    if not report.ExportFile then
        env.PELICAN_FF3_BAD_FILE_SEQUENCE=(env.PELICAN_FF3_BAD_FILE_SEQUENCE or 0)+1
        local valid,guid=pcall(function()return http:GenerateGUID(false)end)
        local suffix=valid and type(guid)=='string' and guid:gsub('[^%w%-]','') or tostring(os.time())..'-'..tostring(env.PELICAN_FF3_BAD_FILE_SEQUENCE)
        report.ExportFile='PELICAN_FF3_BAD_PLAY_'..suffix..'.json'
    end
    local archive=env.PELICAN_FF3_BAD_PLAY_ARCHIVE
    if type(archive)~='table' then archive={};env.PELICAN_FF3_BAD_PLAY_ARCHIVE=archive end
    local found=false;for _,old in ipairs(archive)do if old==report then found=true;break end end
    if not found then archive[#archive+1]=report;while #archive>8 do table.remove(archive,1)end end
    local ok,encoded=pcall(function()return game:GetService('HttpService'):JSONEncode(report)end)
    if not ok then return done(false,'ENCODE_FAILED') end
    while #encoded>1500000 and report.Possession.Timeline and #report.Possession.Timeline>0 do
        local timeline=report.Possession.Timeline;local drop=math.ceil(#timeline/2)
        for _=1,drop do table.remove(timeline,1)end
        report.Possession.TimelineDropped=(report.Possession.TimelineDropped or 0)+drop
        local valid,nextEncoded=pcall(function()return game:GetService('HttpService'):JSONEncode(report)end)
        if not valid then return done(false,'ENCODE_FAILED')end;encoded=nextEncoded
    end
    if #encoded>1500000 then return done(false,'REPORT_SIZE_LIMIT; RETAINED_IN_MEMORY') end
    env.PELICAN_FF3_BAD_PLAY_REPORT=report
    local copier=type(setclipboard)=='function' and setclipboard or type(toclipboard)=='function' and toclipboard
    local copied=copier and pcall(copier,encoded) or false
    local saved=type(writefile)=='function' and pcall(writefile,report.ExportFile,encoded) or false
    if saved then pcall(writefile,'PELICAN_FF3_BAD_PLAY.json',encoded) end -- latest-report alias only
    return done(copied==true or saved==true,copied and 'COPIED' or saved and 'SAVED' or 'NO_EXPORT_API')
end
'''
    presentation=r'''controller.presentation=(function()
PRESENTATION_SOURCE
end)().new({containers={pg},job=game.JobId,lighting=game:GetService('Lighting'),baseline=function()return env.PELICAN_FF3_VISUAL_BASELINE end,
 error=function(err)fatalError=clean(err);log('PRESENTATION_ERROR',err);controller.Stop('PRESENTATION_ERROR')end,
 roots=function()
    local list={};if gui then list[#list+1]=gui end
    if profile and profile.hud then for _,card in pairs(profile.hud)do if type(card)=='table' and card.CardText then list[#list+1]=card.CardText end end end
    for _,item in ipairs(controller.presentation.extraRoots or {})do list[#list+1]=item end
    return list
 end})
if core then controller.presentation.options.containers[#controller.presentation.options.containers+1]=core end
if type(gethui)=='function' then
 local ok,h=pcall(gethui)
 if ok and typeof(h)=='Instance' and h~=core and h~=pg then
    controller.presentation.options.hiddenContainer=h;controller.presentation.options.containers[#controller.presentation.options.containers+1]=h
 end
end
function controller.SetPresentationHidden(value)controller.presentation:set(value==true)end
function controller.RegisterPresentationGui(o)
 if typeof(o)~='Instance' then return false end
 local p=controller.presentation;p.extraRoots=p.extraRoots or {};if #p.extraRoots>=64 then return false end
 p.extraRoots[#p.extraRoots+1]=o;if p.hidden then p:scan()end;return true
end
controller.presentation:start(me)
'''.replace('PRESENTATION_SOURCE',(root/'experimental/presentation.lua').read_text())
    one('local built,buildError=pcall(function()',export+presentation+'local built,buildError=pcall(function()')
    one('controller.unified.helperHUD:stop()',"if controller.presentation then controller.presentation:stop()end;controller.unified.helperHUD:stop()")
    one('cleanupComplete=historyClean and friendsClean and', 'cleanupComplete=historyClean and friendsClean and (not controller.presentation or controller.presentation.clean) and')
    one('controller.league.Update(now);if ff3Options.', 'controller.presentation:update(now);controller.unified.ObserveOscillation(now);controller.league.Update(now);if ff3Options.')
    one("status=button('WAIT YUNA',-166,138)","status=button('QB',-82,54,40);status.Name='CompactQB'")
    one("    local kill=button('X',-26,22);", "    local kill=button('X',-26,22,40);")
    one("    awayButton=button('AWAY',-226,54,62);", "    controller.badButton=button('BAD THROW',-226,106,162);controller.badButton.Name='BadPlay'\n    controller.badCurrentButton=button('MISSED',-116,106,162);controller.badCurrentButton.Name='MissedPlay'\n    for _,entry in ipairs({{controller.badButton,false},{controller.badCurrentButton,true}})do\n        connect(entry[1].Activated,function()local ok=controller.bad:flag(os.clock(),entry[2]);if ok then controller.ExportBadPlay() end;entry[1].Text=ok and 'FLAGGED' or 'NO PLAY';expanded=false;controller.league.Paint() end)\n    end\n    controller.unified.easeButton=button(controller.passPlan.openComfort and 'EASE ON' or 'EASE OFF',-226,106,187);controller.unified.easeButton.Name='OpenComfort'\n    connect(controller.unified.easeButton.Activated,function()controller.SetOpenComfort(not controller.passPlan.openComfort)end)\n    awayButton=button('AWAY',-226,54,62);")
    one("local ok,result=controller.history.Export();controller.history.button.Text", "local ok,result;if controller.bad:report()then ok,result=controller.ExportBadPlay()else ok,result=controller.history.Export()end;controller.history.button.Text")
    one("connect(copyButton.Activated,function() preserve(true);", "connect(copyButton.Activated,function() if controller.bad:report()then local ok,result=controller.ExportBadPlay();copyButton.Text=ok and result or 'FAIL';return end;preserve(true);")
    one('        receiverButton.Visible=expanded and not league;awayButton.Visible=not league', '        receiverButton.Visible=expanded and not league;awayButton.Visible=expanded and not league')
    one('        controller.league.screenButton.Visible=league;controller.league.profileButton.Visible=expanded','        controller.league.screenButton.Visible=expanded and league;controller.league.profileButton.Visible=expanded')
    one("        if not expanded or league then controller.receiverEvidence.panel.Visible=false end", "        controller.badButton.Visible=expanded;controller.badCurrentButton.Visible=expanded;controller.unified.easeButton.Visible=expanded\n        controller.mag.button.Visible=false\n        controller.jumpBullet.button.Visible=expanded and controller.nativeJump.supported and not league\n        controller.jumpBullet.button.Text=controller.nativeJump.enabled and 'HIGH ON' or 'HIGH OFF'\n        status.Text=expanded and gate:gsub('_',' '):sub(1,24) or 'QB'\n        if expanded then status.Size=UDim2.fromOffset(166,22);status.Position=UDim2.new(1,-194,0,40)else status.Size=UDim2.fromOffset(54,22);status.Position=UDim2.new(1,-82,0,40)end\n        if not expanded or league then controller.receiverEvidence.panel.Visible=false end")
    one("'RELEASE_VERSION|experimental-unified-b3.9'", "'RELEASE_VERSION|experimental-unified-b3.9','BAD_PLAY_CODE_ID|'..controller.bad.CodeId,'RETIRED_FEATURES|MAG_TRIAL; CUSTOM_JUMP_BULLET; WIDE_OPEN_JUMP_PREFERENCE; LEADS_AVAILABLE_IN_DATA','RANKING_POLICY|FRESH_V26_22_ADMISSION; ORDERED_COMFORT_COMPONENTS; NO_SIMULATED_CONTEST_RELIEF; NO_THREE_MS_GRADING_OMISSIONS'")

    one("'BAD_PLAY_CODE_ID|'..controller.bad.CodeId", "'BAD_PLAY_CODE_ID|'..controller.bad.CodeId,'PRESENTATION_MODE|'..tostring(controller.presentation and controller.presentation.status),'PRESENTATION_LIGHTING|'..tostring(controller.presentation and controller.presentation.lightingStatus)")

    # Two compact pages replace the old scatter of controls. The folded HUD
    # owns only a 54-pixel QB pill and the existing red reload button.
    one("    controller.badButton=button('BAD THROW'", "    controller.unified.toolsButton=button('TOOLS',-230,64,40);controller.unified.toolsButton.Name='Tools'\n    connect(controller.unified.toolsButton.Activated,function()controller.unified.toolsOpen=not controller.unified.toolsOpen;receiverMenu.Visible=false;controller.receiverEvidence.panel.Visible=false;controller.league.Paint()end)\n    controller.unified.stopButton=button('STOP',-230,72,187);controller.unified.stopButton.Name='StopQB'\n    connect(controller.unified.stopButton.Activated,function()controller.Stop('USER_END')end)\n    controller.badButton=button('BAD THROW'")
    one("        if not expanded then if receiverMenu.Visible and choice then choice.openSince=nil end;receiverMenu.Visible=false end",r"""        if not expanded then if receiverMenu.Visible and choice then choice.openSince=nil end;receiverMenu.Visible=false;controller.unified.toolsOpen=false end
        controller.unified.toolsButton.Visible=expanded;controller.unified.toolsButton.Text=controller.unified.toolsOpen and 'PLAY' or 'TOOLS'
        if expanded then status.Size=UDim2.fromOffset(136,22);status.Position=UDim2.new(1,-164,0,40)end
        local all={autoButton,throwButton,copyButton,receiverButton,riskButton,awayButton,controller.comeback.button,
            controller.receiverFilter.button,controller.passPlan.button,controller.mag.button,controller.angle.button,
            controller.jumpBullet.button,controller.history.button,controller.receiverEvidence.button,controller.league.screenButton,
            controller.league.profileButton,controller.badButton,controller.badCurrentButton,controller.unified.easeButton,controller.unified.stopButton}
        for _,b in ipairs(all)do b.Visible=false end
        local list={};local function add(b,allowed)if allowed~=false then list[#list+1]=b end end
        if controller.unified.toolsOpen then
            add(controller.badButton);add(controller.badCurrentButton);add(copyButton);add(controller.history.button)
            add(controller.league.profileButton);add(controller.comeback.button,not league)
            add(controller.receiverEvidence.button);add(controller.unified.stopButton)
        else
            add(autoButton);add(throwButton);add(riskButton);add(controller.passPlan.button)
            add(receiverButton,not league);add(controller.receiverFilter.button,not league);add(controller.league.screenButton,league)
            add(controller.unified.easeButton);add(controller.jumpBullet.button,controller.nativeJump.supported);add(controller.angle.button)
        end
        for i,b in ipairs(list)do
            b.Visible=expanded and not receiverMenu.Visible and not controller.receiverEvidence.panel.Visible
            b.Size=UDim2.fromOffset(72,24);b.Position=UDim2.new(1,-230+((i-1)%3)*76,0,68+math.floor((i-1)/3)*26)
        end
        awayButton.Visible=true;awayButton.Size=UDim2.fromOffset(40,22);awayButton.Position=UDim2.new(1,expanded and -274 or -126,0,40)
        receiverMenu.Position=UDim2.new(1,-166,0,68)
        controller.receiverEvidence.panel.Position=UDim2.new(1,-230,0,68);controller.receiverEvidence.panel.Size=UDim2.fromOffset(226,139)
""")
    one('        if receiverMenu.Visible then renderReceivers() end\n    end)\n    autoButton.Visible=false', '        if receiverMenu.Visible then renderReceivers() end\n        controller.league.Paint()\n    end)\n    autoButton.Visible=false')
    one('        if receiverMenu.Visible then renderReceivers() end\n    end)\n    controller.SetProfile', '        if receiverMenu.Visible then renderReceivers() end\n        controller.league.Paint()\n    end)\n    controller.SetProfile')
    one('controller.receiverEvidence.nextPaintAt=0;controller.receiverEvidence.Paint()','controller.receiverEvidence.nextPaintAt=0;controller.receiverEvidence.Paint();controller.league.Paint()')

    one("controller.SetReceiverState(p,state=='NORMAL' and 'BLOCKED' or state=='BLOCKED' and 'TRUSTED' or 'NORMAL')\n                end\n            end\n        end)","controller.SetReceiverState(p,state=='NORMAL' and 'BLOCKED' or state=='BLOCKED' and 'TRUSTED' or 'NORMAL')\n                end\n            end\n            if not receiverMenu.Visible then expanded=false end;controller.league.Paint()\n        end)")

    one("    controller.unified.stopButton=button('STOP'", "    controller.unified.clearButton=button('CLEAR BAD',-230,72,187);controller.unified.clearButton.Name='ClearBadPlay'\n    connect(controller.unified.clearButton.Activated,function()controller.bad.pinned=nil;env.PELICAN_FF3_BAD_PLAY_REPORT=nil;copyButton.Text='COPY';controller.history.button.Text='DATA';controller.league.Paint()end)\n    controller.unified.stopButton=button('STOP'")
    one('controller.badCurrentButton,controller.unified.easeButton,controller.unified.stopButton}', 'controller.badCurrentButton,controller.unified.easeButton,controller.unified.stopButton,controller.unified.clearButton}')
    one('add(controller.receiverEvidence.button);add(controller.unified.stopButton)', 'add(controller.unified.clearButton,controller.bad:report()~=nil);add(controller.unified.stopButton)')
    one('        controller.unified.toolsButton.Visible=expanded;', "        controller.history.button.Text=controller.bad:report() and 'BAD DATA' or 'DATA'\n        controller.unified.toolsButton.Visible=expanded;")
    one("controller.history.button.Text=ok and 'COPIED' or 'FAIL'", "controller.history.button.Text=ok and (result=='SAVED' and 'SAVED' or 'COPIED') or 'FAIL'")

    # NativeJump toggle's immediate paint must use the new receiver-height label.
    s=s.replace('Tap: normal > block > trust','Tap: normal > block')
    one("state=='NORMAL' and 'BLOCKED' or state=='BLOCKED' and 'TRUSTED' or 'NORMAL'","state=='BLOCKED' and 'NORMAL' or 'BLOCKED'")
    one("state=='BLOCKED' and '[X]' or state=='TRUSTED' and '[T]' or controller.mag.Source(p,false)=='FRIEND' and '[F]' or '[ ]'","state=='BLOCKED' and '[X]' or controller.receiverFilter.friend(p,false) and '[F]' or '[ ]'")
    s=s.replace("and 'JUMP ON' or 'JUMP OFF'","and 'HIGH ON' or 'HIGH OFF'")
    return s
