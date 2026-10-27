"""Complete a missing ordinary native Dime comparison before optional lofts.

This schedules checked native work only. It does not authorize a rejected
trajectory, widen endpoint tolerances, invent catch heights or send packets.
"""


def repair(source):
    start = source.index('function controller.unified.CompareLoft(best,now,defenders)')
    end = source.index('local function tick(now,cachedOnly)', start)
    source = source[:start] + r'''function controller.unified.CompareLoft(best,now,defenders)
    if not best or not best.shot then return true end
    local permission=best.shot.unified
    if permission and permission.Allowed and permission.Guard and permission.Guard.Strict then return true end
    local cache=shotCache[best.player]
    if not cache then return true end
    cache.modeAt=cache.modeAt or {}
    -- Core Dime precedes the optional receiver-Jump/configured-loft paths.
    -- A fresh existing core tuple was already regraded with this scene. Only
    -- missing/stale core work is supplemented. A failed attempt may retry at
    -- the existing planning cadence,
    -- rather than hiding a changing window for the whole native-cache lifetime.
    -- modeAt and the global native cap bound retries, including reactive ticks.
    for _,mode in ipairs({'Dime','CoverageJump','LoftDime'})do
        local enabled=mode=='Dime' or mode=='CoverageJump' and controller.nativeJump.enabled
            or mode=='LoftDime' and controller.angle.enabled
        local tried=cache.modeAt[mode]
        local horizon=mode=='Dime' and CFG.Interval or CFG.CacheAge
        local cached=cache.shots[mode]
        local missingCore=mode~='Dime' or not cached or now-cached.at>CFG.CacheAge
        if enabled and missingCore and (not tried or now-tried>=horizon) then
            if frameCalls>=8 then
                controller.bad.open=true
                controller.bad:status(best.player.Name,mode,'NOT_EVALUATED','NATIVE_FRAME_BUDGET')
                local omitted=controller.bad:row(best.player.Name,mode)
                if omitted then omitted.NativeStatus='BUDGET_NOT_ATTEMPTED';omitted.NativeReason='NATIVE_FRAME_BUDGET';omitted.NativeInvoked=false end
                controller.bad:finish(best,0)
                setGate('WAIT_NATIVE_MODE_COMPARISON_BUDGET');return false
            end
            local before=frameCalls;local begun=os.clock();local shot,why,failure=solve(best.player,mode)
            if stopped then return false end
            controller.bad.open=true
            controller.bad:native(best.player.Name,mode,shot,why,frameCalls>before,failure)
            if why=='NATIVE_FRAME_BUDGET' then
                controller.bad:status(best.player.Name,mode,'NOT_EVALUATED','NATIVE_FRAME_BUDGET')
                local omitted=controller.bad:row(best.player.Name,mode)
                if omitted then omitted.NativeStatus='BUDGET_NOT_ATTEMPTED';omitted.NativeReason='NATIVE_FRAME_BUDGET';omitted.NativeInvoked=false end
                controller.bad:finish(best,os.clock()-begun)
                setGate('WAIT_NATIVE_MODE_COMPARISON_BUDGET');return false
            end
            cache.modeAt[mode]=now
            cache.shots[mode]=shot
            if shot then
                local eligible,reason=receiverReady(best.player,best.sample,now,shot.arrival)
                if eligible then eligible,reason=receivePossible(shot,best.sample) end
                if eligible then
                    risk(shot,best.sample,defenders);coverage(shot,best.sample,defenders)
                    if shot.nativeCoverageJump then
                        local chest=cache.shots.Bullet
                        if chest and now-chest.at<=CFG.CacheAge then
                            risk(chest,best.sample,defenders);coverage(chest,best.sample,defenders)
                            controller.jumpBullet.assess(shot,{chest})
                        end
                    end
                    if better(shot,best.shot) then best.shot=shot end
                else controller.bad:status(best.player.Name,mode,'READINESS_REJECTED',reason,shot) end
            end
            controller.bad:finish(best,os.clock()-begun)
            -- A newly strict ordinary completion needs no optional loft probes.
            local u=best.shot.unified
            if u and u.Allowed and u.Guard and u.Guard.Strict then return true end
        end
    end
    return true
end
''' + source[end:]
    return source
