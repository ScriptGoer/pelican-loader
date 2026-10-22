# FF3 V26.16: short post-jump release and shared public-match coverage

V26.17 fixes route-dependent MOD/TRUST/Fit eligibility, regrades other eligible receivers’ fresh cached paths and favors shorter ready completions. Strict Bullet limits, final native validation and the 75-ms takeoff target remain. [Current selection policy](FF3_OPPORTUNITIES.md).

Both existing entry points receive this update through the same Auto QB module:

```lua
-- Normal public/casual games; AUTO still supports the existing VIP hint.
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/loader.lua"))()
-- Explicit compact league profile:
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/competitive.lua"))()
```

Use the desired entry. X reloads main and gets the new pin. There is one shared controller/cleanup owner. Other game routes and companion source retain their bytes.

## Jump release timing

The new default targets **75 milliseconds after first observed local takeoff**. This applies to an existing automatic deep jump and to a player-started jump while Auto QB is active, including a short automatic pass during that jump. A ground short pass has no new timer or forced jump. A screen still does not request a QB jump, but a deliberately player-started QB jump receives the same offset. Manual native input and the deliberate AWAY action remain independent.

Takeoff requires an airborne/Jumping/Freefall state and positive local root vertical velocity. A Jump flag or Jumping state without upward motion does not start the timer. The observer continues looking for positive motion if state changes before physics applies the impulse. It records one takeoff per air cycle, caches the current local root/humanoid identity, and resets on model/health changes and inactive possession contexts. No new player or Workspace scan, state listener, delayed worker, busy wait or solver-polling loop is added. The existing heartbeat checks the clock. Tracking can continue while THR is off, so enabling release later during an already observed jump does not restart a fresh 75 ms wait.

While waiting, there are no extra native trajectory calls. At release, actual airborne pose, native origin/trajectory, receiver movement, LOS, possession, lock ownership and current defenders are checked again. Fit and covered Jump still need their fresh counterfactuals. A stopped/reversed/cut receiver, changed team/filter/blacklist, lost ball, respawn, disabled controls, manual native action, disconnected Yuna or a closing lane cancels the original pending request. There is no wait for the apex or visual animation windup; the owned animation still begins after the packet.

If a requested takeoff is not observed within 0.25 seconds, cancel that opportunity visibly rather than waiting indefinitely, retrying the same deep request or silently treating a requested jump as an observed jump. This is a readiness cancellation; genuine API/calculator/cleanup errors still stop and preserve reports. The existing ordinary jump-unavailable path is retained when no jump can be requested. An already airborne player without a newly observed takeoff does not receive an invented historical timestamp or a peak gate.

**75 ms is a target, not a real-time guarantee.** Release occurs at the first available heartbeat after the target, only if a safe opportunity remains. At 60/30/20 FPS, mocked releases measured roughly 83–100 ms after observation. A slower frame, expensive native solve, startup midway through a jump or an opportunity developing later can place actual release outside 50–100 ms. No sub-frame precision or fabricated timing is claimed. Reports/history preserve the actual measured delay before sending. Timing is relative to first qualified observation, not a verified sub-frame physical impulse or a server timestamp.

Optional configuration (no new HUD row): `FF3.JumpDelaySeconds` accepts 0.05 through 0.10 seconds. Default is 0.075; explicit 0 retains the previous immediate policy. No random delay is added. Changing receiver does not restart the same physical jump clock.

## Coverage shared with public/casual matches

Performance infrastructure already lived in the common module: bounded discovery, cached native data, rotating receiver/mode evaluations, final native call cap and the UI-only ground guide. This release also shares the **coverage decision changes** that were previously league-only:

- Whole native path and arrival grading charges defender movement during the recorded ping. Wide-open margins do not charge that latency twice.
- Geometric layer/threat counts are recorded in casual matches as well. They describe observed actors, not verified LB/safety assignments.
- A strict Fit coverage window can qualify when actual normal Bullet and Dime paths are threatened, no known safe ordinary alternative exists, and Fit itself clears the full path and arrival. Fresh Bullet and Dime calculations precede the actual Fit at release. Its native speed/lead are preserved.
- Five planning attempts reserve up to three final calls inside the existing eight-native-calls-per-frame cap. Modes/receivers still rotate; the code does not exhaust all possibilities every frame.

This does not force the league UI or screen rules onto public servers. Casual friend filtering, receiver list/trust controls, pass plan, optional route chat, AWAY and folded evidence controls stay available. Ordinary AFK and behind-LOS restrictions remain; only an explicitly armed league screen has the existing stationary/depth exception. Bullet and native covered Jump stay strict in every risk mode. Open receivers continue preferring supported ordinary gentle Bullets. No lead values, catch windows, anti-cheat or remote packet format are changed.

`FF3.CoverageWindows=false` explicitly restores the older casual timing-rescue-only Fit/latency policy. League retains its V26.15 coverage baseline. Default is true in either profile. The geometry, pursuit, turn envelope and native-to-server agreement remain approximations requiring game evidence, not a promise of interception-free play.

## Evidence, validation and release

Reports add JUMP_DELAY_TARGET_SECONDS, JUMP_TIMING_STATUS, observation/cancellation counters, actual last measured delay and SHARED_COVERAGE_WINDOWS/scope. CurrentSettings retains JumpDelaySeconds/CoverageWindows. Automatic throw records retain JumpDelayTarget, JumpObservedDelay and JumpTimingSource. The exact current leads and actual native path remain available. No private upload/report is made public.

36 suites / **2,112 mocked assertions** pass: 101 new timing checks, 24 shared-coverage checks and the prior 1,987. Tests exercise simulated automatic/manual jumps at multiple frame rates, early ascent with a fresh native origin, honest low-FPS overshoot, state-before-motion ordering, reuse of an existing takeoff clock, no intermediate native calls, ground short immediacy, route/coverage/ownership/lifecycle cancellation, missing takeoff, genuine API errors and explicit delay options. Shared tests release the same strict ground Fit window in CASUAL/LEAGUE, exercise fresh safety closure, preserve casual controls/AFK/screen restrictions, verify ping is charged once, and release with both production timing and shared coverage enabled. An airborne final calculation can correctly choose a different safe mode from the earlier ground window.

Historical packet/mode fixtures explicitly select JumpDelaySeconds=0 and CoverageWindows=false alongside their existing legacy controls to preserve their intended baselines. New suites exercise real production defaults. Sources and rebuilt bundle pass Lua 5.4 mocked validation; no actual Roblox throw/chat/currency or mobile timing test was run. Live phone timing, takeoff observation, catches, coverage quality and runtime cost remain unverified.

The loader pins **ff3-v26.16**, contract **PELICAN_FF3_V26**. The immutable ff3-v26.15 tag preserves the prior runtime. Both normal and competitive entries load the same updated implementation.
