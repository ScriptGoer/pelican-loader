# FF3 V25: close-pass power and actual goal-to-go LOS

The user reports V24.2 automatic passing works. That exact baseline is preserved privately and remains available through the immutable public `ff3-v24.2` tag. V25 retains the frame-based movement fix and immediate release path.

## Close bullets

The attached clip lasts about 19.78 seconds. Its opening short two-point pass visibly shows power **60** (inspected at approximately 0.15 seconds). This demonstrates a lower-power example, not a calibrated distance-to-power curve or measured catch acceptance. The previously inspected source's Bullet/Fit branch forces nominal 95, so simply changing the Power field while requesting Bullet would not implement the requested behavior.

V25 adds a `SoftBullet` candidate using the existing native configurable Power/low-arc path (native Dime calculation), temporarily assigning the current Bullet lead to that calculation. It does not fabricate a velocity, catch height or new target offset. It uses the native output tuple, verifies requested power was honored, verifies the active Bullet vertical lead, and rejects the higher ballistic branch. The actual path/arrival then passes the same current teammate, motion, field, receiver-reach and defender checks. A safe softened close candidate is preferred; if a defender can contest the slower path, an independently safe original fast pass remains available.

The default application policy requests 60 through ten horizontal yards, ramps to 95 by 25 yards, and leaves longer passes unchanged. These are editable comfort settings chosen for this feature, not official FF3 mechanics inferred from one clip. Softened close shots do not request deep jumps merely because their slower flight time exceeds a normal jump's airtime. Other deep passes retain normal jump then immediate final checks/release, without peak waiting.

Every temporary ManualType, Power, PreferHighArc and lead-table value is tracked inside the existing synchronous native transaction and restored before the callback returns. External edits are preserved and end the transaction safely. Unsupported returned power/lead/arc skips the variant and keeps normal candidates available. A genuine native exception/yield still follows the existing stop-and-preserve policy. No extra GUI, input replay, solver hook or anti-cheat change is introduced. Candidate planning retains six planning calls/eight total native calls per Heartbeat.

Disable or tune the new candidate through the loader:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/loader.lua"))({
    FF3 = { CloseBullet = { Enabled = true, MinPower = 60, SoftYards = 10, FullPowerYards = 25 } }
})
```

`FF3.CloseBullet=false` restores ordinary native-power planning. The selected SoftBullet variant is carried through winner preview and final release, so it cannot silently turn back into a 95-power Bullet between planning and sending. Reports identify `SoftBullet`, actual native power/time/path and the current policy. The native calculation internally uses Dime's generic power branch; the resulting candidate is a lower-arc Bullet-lead variation, not a claim that Yuna's hardcoded Bullet branch supports arbitrary power.

## Goal-to-go

`LineDown` is the blue LOS. `LineTogo` is the yellow first-down marker. Names retain candidates; current geometry, color, visibility, ground and ambiguity checks decide whether a line is usable. Goal-to-go now validates blue LOS without requiring the first-down line, including direct readiness before an unrelated full-map traversal completes. It no longer clears LOS and exempts all LOS checks.

Direction first uses a validated normal-line direction at that same LOS/ground. Otherwise it requires agreement between the nearest known field end zone and the QB being behind the observed LOS. Center-field ties, missing/hidden/ambiguous blue lines, unknown ground or conflicting QB-side evidence do not invent a direction. This geometric fallback is an explicit policy requiring live verification, not a newly discovered authoritative offense flag. Both field ends and the observed 180-degree ground orientation are covered locally.

Goal receivers and their arrival points must be beyond LOS; the ordinary six-yard minimum is omitted because the end zone may be only a few yards away. QB past-LOS, AFK, blacklist, coverage, field and possession checks remain. Normal downs immediately restore the yellow-marker/HUD agreement and usual depth rules. Goal HUD never bypasses unrelated constraints. The fast root path still validates the actual blue Part; a missing LineTogo is permitted only for Goal, not normal downs.

## Validation and limits

559 current mocked assertions pass: new native close-power checks 33, new goal-blue-line checks 55, frame/animation regression 38, jump/release/stats removal 53, endpoint/evidence 34, AWAY 35, reload 9, error-stop 12, loader/config 116, bundle 55, active-play timeouts 25, LOS discovery 66 and ground recovery 28. Original bypass tests explicitly target archived V24.2 and are not counted as validation of the new Goal behavior. Native Power tests use an explicitly enabled mocked generic power branch; they do not execute the paid source or a live game.

The loader pins `ff3-v25` and requires `PELICAN_FF3_V25`. UI stays compact; AWAY remains always visible, manual WR blacklist and COPY/X remain, and stats remain removed. Other game routes/source bytes are preserved. Native setting/lead restoration, unsupported responses, coverage-based fast fallback, errors/yields, external edits/stop and both Goal directions are tested. No live Roblox, currency, server-exit or anti-cheat tests were run. Actual native generic-power compatibility, catch quality, low-power speed conversion, goal direction behavior and iPhone performance still need in-game verification. The existing confirmed V24.2 baseline remains the rollback.
