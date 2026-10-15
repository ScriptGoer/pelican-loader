# FF3 Auto QB V16: compare native receiver and throw choices

V15.4 is the working gameplay baseline. The supplied later report records stable observed LOS geometry, 15 automatic request calls, zero ambiguous requests, and a maximum controller tick of 0.011316 seconds. The user reports that automatic passing works and that sideline decisions are good. The report does not establish which passes were caught, their completion rate, or why individual interceptions occurred.

The remaining complaints are receiver fixation, slow recognition of open or burning receivers, and a movement-only throw-mode rule that can choose an unnecessary high arc into coverage. V16 replaces that mode rule for Pelican's automatic decisions with comparison of native **Bullet, Fit, Dime, and Jump** outputs. It retains the qualified native target lock, aiming solver, SmartPass, field geometry, and ordinary request path. It does not introduce a new catch-height formula.

## Starting and stopping

Use the same public loader:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/loader.lua"))()
```

The FF3 live route is pinned to the immutable `ff3-v16` release and `games/ff3/auto_qb.lua`. Launch Yuna separately, before or after Pelican. Enable Yuna QB Aimbot, disable Mouse Aimbot, and **turn off Yuna Auto Throw Type**. Pelican requires that deliberate mode-ownership setting; it does not silently turn the native feature off or run two competing automatic mode selectors.

The compact HUD retains AUTO, THR, COPY, the receiver blacklist, and the red kill switch. AUTO off or stopping releases owned native selection and mode settings. THR off permits selection without an automatic request. Opening the receiver list pauses release. Red X stops the controller, removes its UI/listeners, restores owned settings, and preserves the report. The separate mobile jump-width helper has its own lifecycle.

## What the native source actually supports

The readable QB block in the supplied `DPH_Message_readable.txt` was inspected as text. Its complete program and encoded wrapper were not executed or redistributed. The references below identify facts about that supplied build; they are not a certificate that every Yuna revision or the FF3 server uses identical mechanics.

| Source reference | Supported fact | V16 consequence |
| --- | --- | --- |
| `fn29`, original lines 1628–1642 | Automatic mode selection uses receiver-motion alignment relative to the QB-to-receiver direction. It has no defender input. High Arc substitutes Dive/Dime for Fit/Jump. | Movement direction is insufficient to choose the safest throw. V16 compares outputs for the requested four modes instead. |
| `fn34`, lines 1777–1786 | When Auto Throw Type is off, the nested aiming calculation independently reads `SelectedType`. | Passing a different mode argument alone is insufficient. Pelican must own the matching shared setting while it solves. |
| `fn16` and `fn34`, lines 1298–1308 and 1812–1847 | Bullet/Fit use nominal power 95 and the low ballistic branch. Dime/Jump use configured Angle/Power behavior; `PreferHighArc` also affects their Power-mode calculation. | Modes are not interchangeable labels, and a farther receiver does not automatically require a higher arc. |
| Native lead table and its sliders, lines 775–777 and 1193–1207 | Each mode has configurable horizontal and vertical leads. | V16 reads the active native lead table rather than substituting default offsets. A lead value is not a measured catch window. |
| `fn36`, lines 1855–1920 | Native prediction iterates receiver motion using flight time plus measured network ping, adds configured lead, and can apply SmartPass rerouting. | Preserve native prediction and SmartPass; evaluate the actual resulting path and arrival. |
| `fn37`, lines 1921–1962 | Returned flight time and final velocity describe the final solve. Its angle field can retain an earlier solve's angle. | The displayed angle alone does not determine the trajectory or its interception risk. |

V16 keeps the user's actual **Angle, Power, ManualType, PreferHighArc, AutoCorrect, AntiOOB, SmartPass, and per-mode leads**. It does not invent Dime/Jump angle presets, switch to Power mode, or force power 95 for those modes. A candidate is evaluated under the active configuration; a bad or invalid candidate is excluded. This means a mode with an unsuitable configured angle is not promised to produce a useful pass.

The shared `SelectedType` lease records the prior value and the last value written by Pelican. Restoration occurs only while Pelican still owns that value. An external edit or native Auto Throw Type being reenabled ends Pelican's control instead of repeatedly overwriting the user's choice. Profile replacement, selection cancellation, stop, and error cleanup must release the old lease. No callback replacement, anti-cheat change, or anti-tamper hook is involved.

## Joint receiver and trajectory decisions

Candidate priority considers whether a receiver/mode pair can pass the **release** checks, rather than letting a merely selectable favorite monopolize the decision. An incumbent is compared with a rotating challenger. Safe-open history belongs to each receiver instead of being discarded whenever the rotating candidate changes. History never authorizes an old trajectory: current team, movement, LOS, field, native target, and a fresh final path must still pass before release.

A receiver burning a defender is eligible for consideration even when they are not isolated by a large proximity gap. The relevant questions are whether the defender can reach the projected flight path and arrival region in time, and whether the native pass remains plausible for the intended teammate. Running forward, diagonally, or sideways does not by itself select a mode. A short pass does not by itself select Bullet, and a long pass does not by itself select Dime or Jump.

The user's examples define decision expectations, not additional measured game mechanics:

| Situation | Expected comparison |
| --- | --- |
| A. Receiver runs forward while a defender stays deeper. | Consider a clear Bullet underneath. Do not automatically choose an overshooting Fit merely because the route is forward. |
| B. A defender stands between QB and receiver. | Do not automatically choose Bullet merely because the pass is short. Consider an alternate native arc only if its path and arrival are safer; otherwise hold. |
| C. A deep receiver has separation. | Keep Bullet/Fit in the comparison and compare their real flight with Dime/Jump. Distance alone does not eliminate a mode. |
| D. A nearby receiver is covered and a farther receiver has a safer pass. | Prioritize the safer releasable receiver/mode pair rather than the nearest or incumbent receiver. |
| E. Every candidate is unsafe. | Hold the ball. A timeout or lack of alternatives never creates a safe pass. |

Native motion lead and SmartPass retain anticipation and possible outside placement. Pelican does not replace them with an aim at the receiver's current position, add camera animations, or change the camera to make a throw look different. Dime/Jump retain the native configured angle/power behavior rather than being flattened into a single power preset.

The planner examines up to two receivers per tick and rotates up to three of the four modes for each, allowing the omitted mode to be considered on subsequent ticks. Rotation advances after an actual solve, so a slow single call consuming the budget does not permanently starve the other modes. Rotating receiver challenges similarly preserve a turn for every eligible receiver. It permits at most six candidate native solves, one winning-preview solve, and one immediate pre-release solve: **eight native calls per tick**. Candidate work has an 8 ms budget. This budget cannot interrupt an individual engine or native-solver call. A cache entry lasts at most 0.36 seconds and must be reevaluated against current observations; it cannot substitute for the final fresh solve. Changes to numerical native settings or configured leads clear cached choices and safe-open history without overwriting those settings. The report's measured tick duration remains the practical performance evidence.

The minimum play-development hold is now **2 seconds**, with **2/3/4-second** HUD choices. The safe-open hold is **0.24 seconds**, reduced from 0.65. These are deliberate responsiveness settings, not measured catch mechanics. They retain a minimum development period and require recent continuous receiver motion. Receivers normally must already be six yards downfield. When the HUD and observed goal line verify goal-to-go with fewer than six yards remaining, a receiver at or beyond that goal line can qualify; its current position must still be strictly beyond the LOS. The shorter goal distance never selects a throw mode. There is no snap-time throw, stationary-receiver fallback, inside-LOS exception, blacklist override, or throw forced by an expired timer.

## Trajectory and receive checks

For each candidate, derive ball position from the returned origin, final velocity, and flight time using the supplied native model's acceleration. Validate the returned tuple, mode, freshness, range, field position, and LOS. Preserve native AntiOOB behavior and sideline clamping.

The solver's returned aimpoint is not automatically its actual ballistic arrival: native vertical lead and AntiOOB clamping occur inside the final aiming helper. V16 checks horizontal arrival consistency against that native aimpoint **after the exact native AntiOOB clamp**. Arithmetic tolerance here concerns floating-point calculation; it is not a catch radius. This also detects source fallback/later-crossing outputs that land well beyond their supposed native target. The source-only offline Fit/Bullet comparison demonstrates why validating the actual return tuple matters.

Receiver plausibility uses a necessary, optimistic horizontal travel bound. It uses the maximum of observed movement speed, current horizontal velocity, and a valid Humanoid WalkSpeed, multiplied by native flight time plus the actual ping used for prediction, then includes the magnitude of the active native horizontal lead. It does not insert an invented catch-radius allowance. The active lead table must be identified uniquely by its source-shaped mode/Vector2 entries in the qualified native function graph; ambiguous or unavailable evidence cannot be replaced with guessed defaults.

This travel bound allows an immediate change of direction and is therefore only an optimistic reach check. Passing it does not prove the receiver will change course, jump, react, or catch. It cannot establish standing, dead-zone, or high-jump catch regions. Existing Yuna Jump is a native named mode, **not** a newly calibrated Bullet-speed high-jump throw.

Defender evaluation retains the analytic vertical interception intervals and time-dependent horizontal projection/uncertainty checks over the ball's flight. It also considers defenders near the actual arrival. These remain estimates based on observed character motion and ordinary Humanoid properties, not authoritative FF3 catch/hitbox limits. A nearby defender outside the projected interception path is different from one who can meet the ball. A higher candidate must still pass the full path and arrival checks; increased height alone is not a safety reward.

## Evidence, failures, and unresolved mechanics

The user's timestamp descriptions and mode examples are qualitative expectations. No new video file was supplied for this revision. The described underneath pass at 1:48–1:54, sideline sequences, crowded deep interceptions, and the camera elevation change at 4:42–4:44 help explain the desired decisions. Editing and camera tracking do not establish launch angle, mode, power, catchability, or one uninterrupted ball trajectory. Source inspection supports how the supplied native solver calculates candidate outputs; it does not establish the actual server's complete catch implementation or an exact power-to-ball-speed conversion.

Exceptions in the controller tick or native solver stop the script immediately and preserve their original cause. An ambiguous request exception also stops it after that one attempt; no request is retried, including on a later play. Ordinary readiness waits and invalid candidate outputs remain explicit gates, not hidden exception retries. Reports distinguish selected mode, candidate rejection reasons, owned settings, requests, fatal errors, and cleanup status. Clipboard API acceptance is not iPhone clipboard readback; preserve the report before leaving Roblox.

Local validation passed 86 actual-controller synthetic scenario/lifecycle checks, 66 current-controller LOS regressions, 12 exception-stop checks, 86 loader checks, and 55 bundle startup/cleanup checks. The archived V15.4.1 policy suite passed 56 checks, preserved diagnostics passed 79 search/28 trace checks, and the offline FIT/BULLET mathematical helper passed five tests. Native Luau compilation passed for controller, fixture, V16 suite, loader, manifest, and rebuilt bundle; baseline byte preservation and deterministic diagnostic generation also passed. Mode-specific fixture geometry covers A–E, native Jump, receiver/mode fairness, call/time budgets, arrival/clamp consistency, horizontal reach rejection, mode/config ownership, menu/pacing behavior, goal-to-go depth and off-camera eligibility. Synthetic native fixtures and the offline mathematical helper do not establish in-game catches or phone performance.

**Still needs live Roblox validation:** all four modes under the user's actual native configuration; burn recognition without throwing into converging coverage; preserved good sideline behavior; earlier useful releases without passes to idle/inside-LOS receivers; intended receiver reaction/catchability; cancellation and owned-setting restoration; and iPhone frame/touch behavior. Catch-height windows, dead-zone bounds, reliable jump timing, and abnormal defender capabilities remain unverified. No destructive, currency-spending, or live server test is part of this implementation.

Only the FF3 live route is updated. The observed live PlaceId remains `82866880824588`; practice `81310542478972` and Threshold lobby/Chase routes remain unchanged. No new game or universe IDs are invented. Original source and the V15.4 baseline remain preserved in their archives and immutable releases.

For a validated goal-to-go HUD/goal-strip pair, the minimum receiver depth is capped at the observed distance to the goal line. This removes the six-yard policy obstruction on a short goal-to-go field without allowing a receiver or arrival behind the LOS. Ordinary downs retain six yards. This is a pacing/eligibility policy, not a catch-mechanics calibration.

The inherited model horizon remains 4.5 seconds and its current-receiver range cap remains 330 studs; reports expose both. A longer native flight is rejected explicitly, rather than treated as calibrated coverage prediction. These are model limits, not verified FF3 maximum throw distances. Surplus clearance scoring saturates beyond twice the strict release margins so a slow arc does not beat an already-safe direct throw merely for extra empty space; residual movement correction also has a ranking cost.

Eligible teammates are considered across the field rather than discarded solely for being outside the camera view. The source-qualified locked selector supplies the selected teammate without cursor selection. This adds no camera movement or artificial aiming animation.
