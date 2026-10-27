-- Pure native-work selection. This never grades or authorizes a throw.
local S={}
local core={ZigzagBullet=0,Bullet=1,Dime=2,SoftBullet=3}
local optional={QuickBullet=1,Fit=2,CoverageJump=3,LoftDime=4}
function S.next(modes,modeAt,tried,now,cacheAge,unavailable)
    local best,oldest,priority,reason
    local refresh=cacheAge/2 -- leave half the existing tuple lifetime to refresh
    for index,mode in ipairs(modes) do
        if not tried[mode] and not (unavailable and unavailable[mode]) then
            local at=modeAt and modeAt[mode] or -math.huge
            local rank=core[mode]
            if rank and now-at>=refresh then
                if reason~='DUE_CORE' or at<oldest or at==oldest and rank<priority then
                    best,oldest,priority,reason=mode,at,rank,'DUE_CORE'
                end
            elseif reason~='DUE_CORE' and not rank then
                rank=optional[mode] or #modes+index
                if not best or at<oldest or at==oldest and rank<priority then
                    best,oldest,priority,reason=mode,at,rank,'FAIR_OPTIONAL'
                end
            end
        end
    end
    -- Refreshed cores need no duplicate probing when optional work is absent.
    return best,reason
end
return S
