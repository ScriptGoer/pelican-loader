-- Pure evaluator replay; caller supplies decoded JSON, matching engine and Vector3.
return function(report,Engine,expectedEngineId)
    local out={Reproduced=0,Missing={},Mismatches={},Selections={}}
    if report.Schema~='PELICAN_BAD_PLAY_1' then error('Unsupported bad-play schema')end
    if report.EngineId~=expectedEngineId then out.Missing[#out.Missing+1]='ENGINE_VERSION_MISMATCH';return out end
    local function vec(a)return a and Vector3.new(a[1],a[2],a[3])end
    local function actor(a)
        assert(a and a.p and a.v,'Actor position/velocity missing')
        return {name=a.Id,p=vec(a.p),v=vec(a.v),observedSpeed=a.observedSpeed,hum={WalkSpeed=a.WalkSpeed},head=a.Head and {Position=vec(a.Head)} or nil}
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
        for _,field in ipairs({'Score','RiskScore','CatchDifficulty','ReceiverAdvantage','ScoringValue'})do
            local a,b=shot.unified[field],row.Result[field]
            if a~=b and (type(a)~='number' or type(b)~='number' or math.abs(a-b)>1e-8*math.max(1,math.abs(b)))then out.Mismatches[#out.Mismatches+1]=key..':'..field end
        end
        if shot.unified.HardReason~=row.Result.HardReason then out.Mismatches[#out.Mismatches+1]=key..':HARD_REASON'end
        return shot
    end
    local p=report.Possession
    for i,f in ipairs(p.Frames or {})do
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
    else out.Missing[#out.Missing+1]='FINAL_EVALUATOR_INPUT_OR_RESULT_MISSING'end
    out.Scope='EVALUATOR_AND_RECORDED_ELIGIBILITY; NOT_NATIVE_SOLVER_STATE_OR_SERVER_OUTCOME'
    out.Complete=#out.Missing==0 and #out.Mismatches==0
    return out
end
