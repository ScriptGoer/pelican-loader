"""Advisory-only guide scheduling and bounded ground projection."""
def repair(s):
 def one(a,b):
  nonlocal s
  assert s.count(a)==1,(a[:80],s.count(a));s=s.replace(a,b,1)
 one('function controller.unified.BaselineThrowable(shot)',r'''function controller.unified.CoverageReady(shot)
    return type(shot)=='table' and finite(shot.margin) and finite(shot.lane)
        and finite(shot.time) and shot.time>0
end
function controller.unified.BaselineThrowable(shot)
    if not controller.unified.CoverageReady(shot) then return false end''')
 one('function controller.unified.Guard(shot)\n',r'''function controller.unified.Guard(shot)
    if not controller.unified.CoverageReady(shot) then
        return {Allowed=false,Strict=false,Reason='COVERAGE_GRADE_MISSING'}
    end
''')
 one('forecastGuide=function(data,now)',r'''function controller.groundGuide.SelectShot(r,now)
    if type(r)~='table' or not r.sample then return end
    local cache=shotCache[r.player]
    if not cache or cache.model~=r.sample.model or cache.epoch~=possession.epoch or cache.generation~=lines.generation then return end
    local function usable(shot)
        if not controller.unified.CoverageReady(shot) or not finite(shot.at) or now<shot.at or now-shot.at>CFG.CacheAge
            or not vector(shot.origin) or not vector(shot.velocity) or not vector(shot.arrival)
            or type(shot.powerAllowed)~='boolean' or type(shot.planAllowed)~='boolean'
            or type(shot.unified)~='table' or type(shot.unified.Guard)~='table'
            or (shot.mode~='Bullet' and shot.mode~='Dime') or shot.jumpBullet
            or shot.nativeCoverageJump or shot.magTrial or shot.screen then return false end
        -- Reach checking writes telemetry: validate a probe so advice cannot
        -- mutate the actual cached/native-release evidence.
        local probe={mode=shot.mode,time=shot.time,arrival=shot.arrival}
        return receivePossible(probe,r.sample)
    end
    if usable(r.shot) then return r.shot end
    local best
    for _,mode in ipairs({'Bullet','Dime','SoftBullet','QuickBullet'})do
        local shot=cache.shots[mode]
        if usable(shot) and (not best or shot.at>best.at)then best=shot end
    end
    return best
end
function controller.groundGuide.Queue(r,now)
    local scene=controller.angle.scene;local ball=ready()
    if not ball or not scene or now-scene.at>CFG.CacheAge or scene.epoch~=possession.epoch
        or scene.generation~=lines.generation or scene.team~=me.Team then
        controller.groundGuide.status='WAIT_FRESH_GUIDE_SCENE';return
    end
    assistance.guidePending={r=r,ball=ball,defenders=scene.defenders}
end
forecastGuide=function(data,now)''')
 one('if ff3Options.MovementGuide==false and ff3Options.PredictiveJump==false or not data', 'if ff3Options.MovementGuide==false or not data')
 one('    local shot,s=r.shot,r.sample\n    if not shot or not shot.time or throwable(shot) or not receiverReady(r.player,s,now) then return end',r'''    local shot,s=controller.groundGuide.SelectShot(r,now),r.sample
    if not lines.forward or not shot then controller.groundGuide.status='WAIT_FRESH_GUIDE_TRAJECTORY';return end
    if Unified.admit(shot,controller.unified.Guard(shot)) then controller.groundGuide.status='CURRENT_WINDOW_OPEN';return end
    if not receiverReady(r.player,s,now) or s.oscillation then controller.groundGuide.status='WAIT_STABLE_GUIDE_ROUTE';return end''')
 one("local future={origin=shot.origin+run*lead", "local future={advisory=true,appliedLead=shot.appliedLead,effectiveYLead=shot.effectiveYLead,origin=shot.origin+run*lead")
 one('local receiver={p=predict(s,lead),v=s.v,turn=s.turn', 'local receiver={name=s.name,hum=s.hum,head=s.head and {Position=s.head.Position+velocity*lead},p=predict(s,lead),v=s.v,turn=s.turn')
 # Forecast grades must never overwrite actual candidate/final release evidence.
 one('controller.bad:grade(shot,s,defenders,inputs,controller.unified.config,(shot.guardSeconds or 0)+os.clock()-begun)', 'if not shot.advisory then controller.bad:grade(shot,s,defenders,inputs,controller.unified.config,(shot.guardSeconds or 0)+os.clock()-begun) end')
 one('if shot.unified then controller.bad:admit(shot,g) end', 'if shot.unified and not shot.advisory then controller.bad:admit(shot,g) end')
 one("    setGate(reason or 'MANUAL_LOCK_COVERED')\nend", "    setGate(reason or 'MANUAL_LOCK_COVERED')\n    controller.groundGuide.Queue(r,os.clock())\nend")
 one('    local ok=controller.groundGuide.Project(root.Position,g.direction,clamp(hum.WalkSpeed*g.lead,3,9))',r'''    local length=clamp(hum.WalkSpeed*g.lead,3,9)
    local ok=false
    for _=1,3 do
        ok=controller.groundGuide.Project(root.Position,g.direction,length)
        if ok then break end
        length=length/2
    end''')
 one('local left=tip-direction*2+right*1.25;local wing=tip-direction*2-right*1.25', 'local headLength=math.min(2,length*.4);local halfWidth=math.min(1.25,length*.25)\n    local left=tip-direction*headLength+right*halfWidth;local wing=tip-direction*headLength-right*halfWidth')
 return s
