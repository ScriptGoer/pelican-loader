-- Pure evaluator replay; caller supplies decoded JSON, matching engine and Vector3.
return function(report,Engine,expectedEngineId,expectedCodeId,GuardReplay)
    local out={Reproduced=0,GeometryReproduced=0,Missing={},Mismatches={},Selections={}}
    if report.Schema~='PELICAN_BAD_PLAY_1' then error('Unsupported bad-play schema')end
    if report.EngineId~=expectedEngineId then out.Missing[#out.Missing+1]='ENGINE_VERSION_MISMATCH';return out end
    if expectedCodeId and report.CodeId~=expectedCodeId then out.Missing[#out.Missing+1]='BUILD_CODE_ID_MISMATCH';return out end
    if report.Profile and report.Profile.IdentityOverflow then out.Missing[#out.Missing+1]='ACTOR_IDENTITY_OVERFLOW'end
    local function vec(a)return a and Vector3.new(a[1],a[2],a[3])end
    local function actor(a)
        assert(a and a.p and a.v,'Actor position/velocity missing')
        return {name=a.Id,p=vec(a.p),v=vec(a.v),observedSpeed=a.observedSpeed,hum={WalkSpeed=a.WalkSpeed,JumpPower=a.JumpPower},turn=a.Turn or 0,routeTurn=a.RouteTurn or a.Turn or 0,head=a.Head and {Position=vec(a.Head)} or nil,acceleration=vec(a.acceleration)}
    end
    local function candidate(row,key)
        if not row.Input or not row.Result then out.Missing[#out.Missing+1]=key..':INPUT_OR_RESULT_MISSING';return end
        local ok,shot=pcall(function()
            local input=row.Input;local s={};for k,v in pairs(input.Shot)do s[k]=v end
            s.origin,s.velocity,s.arrival=vec(s.origin),vec(s.velocity),vec(s.arrival)
            local ds={};for _,a in ipairs(input.Defenders)do ds[#ds+1]=actor(a)end
            local e=Engine.new(input.Config);e:evaluate(s,actor(input.Receiver),ds,input.Context)
            return s
        end)
        if not ok then out.Missing[#out.Missing+1]=key..':MALFORMED_INPUT:'..tostring(shot);return end
        out.Reproduced=out.Reproduced+1
        local function equal(a,b)
            if type(a)~=type(b)then return false end
            if type(a)=='number'then return a==b or math.abs(a-b)<=1e-5*math.max(1,math.abs(a),math.abs(b))end
            if type(a)~='table'then return a==b end
            for k,v in pairs(a)do if not equal(v,b[k])then return false end end
            for k in pairs(b)do if a[k]==nil then return false end end
            return true
        end
        for _,field in ipairs({'Score','RiskScore','CatchDifficulty','ReceiverAdvantage','Allowed','Reason'})do
            if not equal(shot.unified[field],row.Result[field])then out.Mismatches[#out.Mismatches+1]=key..':'..field end
        end
        if GuardReplay and row.Input.Context.GuardInputs then
            local ok,geometry=pcall(function()
                local input=row.Input;local clone={};for k,v in pairs(shot)do clone[k]=v end
                local ds={};for _,d in ipairs(input.Defenders)do ds[#ds+1]=actor(d)end
                return GuardReplay(clone,actor(input.Receiver),ds,input.Context)
            end)
            if not ok then out.Missing[#out.Missing+1]=key..':GUARD_REPLAY:'..tostring(geometry)
            else
                out.GeometryReproduced=out.GeometryReproduced+1
                local g=row.Input.Context.Guard
                for field,recorded in pairs({margin=g.Margin,lane=g.Lane,directLane=g.DirectLane,powerAllowed=g.PowerAllowed,minimumFlight=g.MinimumFlight,receiverETA=g.ReceiverETA,raceAdvantage=g.RaceAdvantage})do
                    if not equal(geometry[field],recorded)then out.Mismatches[#out.Mismatches+1]=key..':GUARD_'..field end
                end
                if not equal(geometry.trustBurn,g.TrustBurn)then out.Mismatches[#out.Mismatches+1]=key..':TRUST_BURN'end
            end
        elseif GuardReplay and report.Version=='experimental-unified-b3' then out.Missing[#out.Missing+1]=key..':GUARD_INPUTS_MISSING'end
        if shot.unified.HardReason~=row.Result.HardReason then out.Mismatches[#out.Mismatches+1]=key..':HARD_REASON'end
        return shot
    end
    local p=report.Possession
    local frames={};for _,f in ipairs(p.Frames or {})do frames[#frames+1]=f end
    for _,name in ipairs({'FirstPlan','FirstViable','DevelopmentDecision','ReleasedDecision'})do if p[name]then frames[#frames+1]=p[name]end end
    for i,f in ipairs(frames)do
        if (f.DroppedRows or 0)>0 then out.Missing[#out.Missing+1]='FRAME_'..i..':TRUNCATED_ROWS'end
        local rows={};for key,row in pairs(f.Rows)do if row.Status=='EVALUATED'then rows[#rows+1]={key=key,row=row}end end
        table.sort(rows,function(a,b)return (a.row.Order or 0)<(b.row.Order or 0)end)
        local best,key
        for _,v in ipairs(rows)do
            local shot=candidate(v.row,'FRAME_'..i..':'..v.key)
            if shot then
                -- Explicit plan/state exclusions are replayed as recorded facts,
                -- not re-derived from unavailable Roblox state.
                if v.row.PlanAllowed==false or v.row.ReleaseBlocked then shot.unified.HardReason='RECORDED_PLAN_OR_STATE_EXCLUSION'end
                if Engine.better(shot,best,f.Mode)then best,key=shot,v.key end
            end
        end
        out.Selections[#out.Selections+1]={Recorded=f.Selected,Replayed=key}
        if key~=f.Selected then out.Mismatches[#out.Mismatches+1]='FRAME_'..i..':SELECTION'end
    end
    if p.Final and p.Final.Input and p.Final.Result then candidate(p.Final,'FINAL_RELEASE')
    elseif p.SentAt or p.Final and not p.Final.NativeFailure and not p.Final.Gate then out.Missing[#out.Missing+1]='FINAL_EVALUATOR_INPUT_OR_RESULT_MISSING'end
    out.TimelineScope='SUMMARY_ONLY; REPLAY_CHECKS_CAPTURED_FULL_KEYFRAMES'
    out.OmittedTimelineFrames=p.TimelineDropped or 0
    out.NumericComparison='FLOAT32_RELATIVE_1E_5; DOES_NOT_RELAX_RUNTIME_GUARDS'
    out.Scope='JOINT_RANKING_AND_CAPTURED_ANALYTIC_RISK; NATIVE_SOLVER_GAME_STATE_SERVER_NOT_RERUN'
    out.Complete=#out.Missing==0 and #out.Mismatches==0
    return out
end
