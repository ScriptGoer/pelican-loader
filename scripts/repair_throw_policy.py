"""Native trajectory options and admission; no guessed catch offsets."""
def risk_rules(s):
 old="(shot.safetyOverTop or shot.safetyRead and shot.safetyRead.High)"
 assert s.count(old)==1
 return s.replace(old,'shot.safetyOverTop',1).replace("read.High and 'SAFETY_HIGH_BULLET_ONLY'","read.High and 'HIGH_SAFETY_OBSERVED'")
def repair(s):
 def one(a,b):
  nonlocal s
  assert s.count(a)==1,(a[:90],s.count(a));s=s.replace(a,b,1)
 s=risk_rules(s)
 # Safety-role labels are diagnostic. Actual whole-path/end-point threats veto.
 one("    if shot.safetyRead and shot.safetyRead.High and (shot.mode~='Bullet' or shot.jumpBullet or shot.nativeCoverageJump) then return false end\n",'')
 one("    if controller.safety.enabled and (shot.jumpBullet or shot.nativeCoverageJump) and (not shot.safetyRead or shot.safetyRead.State~='DROPPING_SLANT_CONTEST') then return false end\n",'')
 one("        or shot.safetyRead and shot.safetyRead.High and shot.mode~='Bullet' and 'SAFETY_HIGH_BULLET_ONLY'\n",'')
 one("    if controller.safety.enabled and (not shot.safetyRead or shot.safetyRead.State~='DROPPING_SLANT_CONTEST') then\n        shot.jumpBulletAllowed=false;shot.jumpBulletReason=shot.safetyRead and shot.safetyRead.State or 'SAFETY_READ_UNVERIFIED';return false\n    end\n",'')
 one("            and (not controller.safety.enabled or other.contestedChestThreat==true) then",'            then')
 one("and (not controller.safety.enabled or other.mode=='Bullet') then","and (not controller.safety.enabled or other.mode=='Bullet')\n            and (other.mode~='Bullet' or other.margin>=CFG.ThrowMargin and other.lane>=CFG.ThrowLane) then")
 # Existing supported Jump mechanics; apply no additional Y offsets.
 # A safe ordinary Bullet still vetoes HIGH, and HIGH still needs strict actual
 # path/arrival clearance plus a fresh threatened ordinary Bullet comparison.
 # Expose the user's configured native Angle as a second Dime option rather
 # than forcing every adaptive Dime through only the minimum-angle estimate.
 one('    local nativeJump=mode==\'CoverageJump\'',"    -- BEGIN NATIVE LOFT ALTERNATIVE\n    local loft=mode=='LoftDime'\n    -- END NATIVE LOFT ALTERNATIVE\n    local nativeJump=mode=='CoverageJump'")
 one("local nativeMode=(jump or nativeJump) and 'Jump' or (soft or mag) and 'Dime' or mode", "local nativeMode=(jump or nativeJump) and 'Jump' or (soft or mag or loft) and 'Dime' or mode")
 one("    if soft and touch.method=='ANGLE' then\n        nativeInput=",r'''    -- BEGIN NATIVE LOFT ALTERNATIVE
    if loft then
        if not controller.angle.enabled or not profile or not finite(profile.q.Angle) or profile.q.Angle<=0 or profile.q.Angle>=89 or not finite(profile.q.Power) or profile.q.Power<=0 or profile.q.Power>95 then return nil,'CONFIGURED_LOFT_UNAVAILABLE' end
        angleControl={requested=profile.q.Angle,powerCap=profile.q.Power,reason='CONFIGURED_NATIVE_ANGLE_ALTERNATIVE'}
        nativeInput=angleControl.requested
    end
    -- END NATIVE LOFT ALTERNATIVE
    if soft and touch.method=='ANGLE' then
        nativeInput=''')
 # Do not require the low-angle estimator to succeed before the independent
 # configured-angle alternative is generated.
 one("and not fastJump and (nativeMode=='Dime' or nativeMode=='Jump')", "and not fastJump and not loft and (nativeMode=='Dime' or nativeMode=='Jump')")
 one("mode=mag and 'Dime' or (soft or jump)","mode=(mag or loft) and 'Dime' or (soft or jump)")
 one("{'ZigzagBullet','SoftBullet','QuickBullet','Bullet','Fit','Dime'}", "{'ZigzagBullet','SoftBullet','Bullet','Dime','LoftDime','QuickBullet','Fit'}")
 # Aimpoint mismatch does not authorize a packet or loosen tolerance. It may
 # request the already-existing bounded Angle fallback without a network call.
 one('    if endpointError>endpointTolerance then\n',r'''    if endpointError>endpointTolerance then
        -- BEGIN SOFT POWER FALLBACK
        if soft and touch.method=='POWER' then
            touch.record(player,mode,requestedPower,power,'POWER_ENDPOINT_MISMATCH_TRY_NATIVE_ANGLE')
            touch.method='ANGLE';touch.methodReason='POWER_ENDPOINT_MISMATCH_TRY_NATIVE_ANGLE'
            touch.powerFallback={At=os.clock(),Reason=touch.methodReason,Error=endpointError,Tolerance=endpointTolerance,RequestedPower=requestedPower,ReturnedPower=power}
            return solve(player,mode) -- one Angle retry; the POWER flag is already cleared; global native cap still applies
        end
        -- END SOFT POWER FALLBACK
''')
 # Reserve one real comparison for an admitted contested default path.
 one('g.cache.plannedAt=now', 'g.cache.plannedAt=now;g.cache.modeAt=g.cache.modeAt or {};g.cache.modeAt[mode]=now')
 one('local function tick(now,cachedOnly)',r'''function controller.unified.CompareLoft(best,now,defenders)
    if not best or not best.shot or best.shot.variant=='LoftDime'
        or best.shot.mode~='Bullet' and best.shot.mode~='Dime'
        or best.shot.unified.Guard.Strict then return true end
    local cache=shotCache[best.player]
    if not cache then return true end
    cache.modeAt=cache.modeAt or {}
    for _,mode in ipairs({'CoverageJump','LoftDime'})do
        local enabled=mode=='CoverageJump' and controller.nativeJump.enabled or mode=='LoftDime' and controller.angle.enabled
        local tried=cache.modeAt[mode]
        if enabled and (not tried or now-tried>CFG.CacheAge) then
            if frameCalls>=8 then setGate('WAIT_NATIVE_MODE_COMPARISON_BUDGET');return false end
            local before=frameCalls;local begun=os.clock();local shot,why,failure=solve(best.player,mode)
            if stopped then return false end
            if why=='NATIVE_FRAME_BUDGET' then setGate('WAIT_NATIVE_MODE_COMPARISON_BUDGET');return false end
            cache.modeAt[mode]=now
            controller.bad.open=true
            controller.bad:native(best.player.Name,mode,shot,why,frameCalls>before,failure)
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
        end
    end
    return true
end
local function tick(now,cachedOnly)''')
 one('        local previous=choice', '        if not controller.unified.CompareLoft(best,now,defenders) then return end\n        local previous=choice')
 # Do not impose a stricter jump-only clearance gate after a deep non-Bullet
 # already passed the full native throw admission. Keep ordinary jump readiness
 # and observed short release offset; no Bullet QB jumps.
 one("    if not u or not u.Allowed or not u.Guard or not u.Guard.Strict then return false,'NO_STRICT_CLEAR_WINDOW' end", "    if not u or not u.Allowed or not u.Guard or not u.Guard.Allowed then return false,'NO_ADMITTED_NATIVE_WINDOW' end")
 one("    if u.Developing or receiver.oscillation then return false,'DEVELOPING_OR_OSCILLATING_ROUTE' end\n",'')
 one("    if (receiver.routeTurn or receiver.turn or 0)>riskPolicy.profiles.MOD.turn then return false,'ROUTE_TURNING' end\n",'')
 one("    return true,'FRESH_STRICT_NATIVE_WINDOW'", "    return true,'FRESH_ADMITTED_NATIVE_WINDOW'")
 return s
