"""Refresh core native tuples before their cache expires; fairly probe options.

Apply after repair_throw_policy and before instrument_bad_play. The module owns
work ordering only. Native solver, frame/time budgets, admission and final fresh
solve continue to own their existing responsibilities.
"""
from pathlib import Path


def repair(s, root=None):
    root = Path(root) if root else Path(__file__).resolve().parents[1]

    def one(old, new):
        nonlocal s
        assert s.count(old) == 1, (old[:100], s.count(old))
        s = s.replace(old, new, 1)

    module = (root / 'experimental/native_schedule.lua').read_text()
    one('local function evaluate(receivers,indices,defenders,now)',
        'controller.unified.nativeSchedule=(function()\n' + module + r'''
end)()
function controller.unified.ScheduleUnavailable(r,now)
    local missing={}
    if not touch.enabled then
        missing.SoftBullet='CLOSE_BULLET_NOT_NEEDED'
        missing.QuickBullet='CLOSE_BULLET_NOT_NEEDED'
        missing.ZigzagBullet='CLOSE_BULLET_NOT_NEEDED'
    else
        if not closePower(r.player,false) then missing.SoftBullet='CLOSE_BULLET_NOT_NEEDED' end
        if not closePower(r.player,true) then missing.QuickBullet='CLOSE_BULLET_NOT_NEEDED' end
    end
    if not r.sample.oscillation then missing.ZigzagBullet='NO_OBSERVED_ZIGZAG' end
    if not controller.nativeJump.enabled then missing.CoverageJump='NATIVE_JUMP_OFF' end
    local q=profile and profile.q
    if not controller.angle.enabled or not q or not finite(q.Angle) or q.Angle<=0 or q.Angle>=89
        or not finite(q.Power) or q.Power<=0 or q.Power>95 then
        missing.LoftDime='CONFIGURED_LOFT_UNAVAILABLE'
    end
    if controller.league.ScreenEligible and controller.league.ScreenEligible(r.player,r.sample,now) then
        for _,mode in ipairs(plannerModes)do
            if mode~='SoftBullet' and mode~='QuickBullet' and mode~='Bullet' then missing[mode]='SCREEN_BULLET_ONLY' end
        end
    end
    return missing
end
local function evaluate(receivers,indices,defenders,now)''')
    one('groups[#groups+1]={r=r,cache=cache,tried={}}',
        'groups[#groups+1]={r=r,cache=cache,tried={},unavailable=controller.unified.ScheduleUnavailable(r,now)}')
    old = '''            -- Advance only after an actual solve. Even if a single native
            -- call consumes the whole time allowance, every mode gets a turn.
            local mode
            for _=1,#plannerModes do
                g.cache.rotation=g.cache.rotation%#plannerModes+1
                local nextMode=plannerModes[g.cache.rotation]
                if not g.tried[nextMode] then mode=nextMode; break end
            end
            g.tried[mode]=true'''
    new = '''            -- A core tuple gets a refresh opportunity at half its existing
            -- cache lifetime. Remaining native work goes to the oldest option.
            -- Unavailable generators consume no native-call slot and are still
            -- explicit in BAD PLAY rather than silently becoming safe paths.
            if not g.skipsLogged then
                g.skipsLogged=true
                for _,skipped in ipairs(plannerModes)do
                    local reason=g.unavailable[skipped]
                    if reason then
                        g.tried[skipped]=true;g.cache.shots[skipped]=nil
                        receiverRejects[g.r.player.Name..'/'..skipped]=reason
                        controller.bad:native(g.r.player.Name,skipped,nil,reason,false)
                    end
                end
            end
            local mode=controller.unified.nativeSchedule.next(plannerModes,g.cache.modeAt,g.tried,now,CFG.CacheAge,g.unavailable)
            if mode then
            g.tried[mode]=true'''
    one(old, new)
    one('''                if why=='NATIVE_SETTINGS_CHANGED_DURING_SOLVE' then return end
            end
        end
        if calls>=callLimit''', '''                if why=='NATIVE_SETTINGS_CHANGED_DURING_SOLVE' then return end
            end
            end -- an exhausted/fully refreshed group needs no additional probe
        end
        if calls>=callLimit''')
    one('g.cache.plannedAt=now;g.cache.modeAt=g.cache.modeAt or {};g.cache.modeAt[mode]=now',
        "g.cache.plannedAt=now;g.cache.modeAt=g.cache.modeAt or {};if why~='NATIVE_FRAME_BUDGET' then g.cache.modeAt[mode]=now end")
    return s
