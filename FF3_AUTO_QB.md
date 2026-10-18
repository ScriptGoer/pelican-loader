# FF3 V26: selectable burn risk and visual-independent release

V26 adds SAFE / MOD / TRUST and separates automatic visual animation from aiming/release. It preserves the previous close-power candidate, goal blue-line LOS, frame-based movement history, AFK/manual blacklist checks, ordinary jump request and no-peak release behavior. The immutable `ff3-v25` release and private exact source archive preserve the previous version.

## Compact risk selector

Expand the status bar and tap **SAFE** beside WR LIST to cycle **SAFE → MOD → TRUST → SAFE**. New sessions default SAFE. A deliberate selection is kept in executor session memory for reexecution/X reload; an explicit loader RiskMode option wins. No disk profile, GUI replay or auto-execute is added. Mode changes cancel prepared work and clear old candidate caches before rescanning. A mode change during the final native call cannot authorize the old prepared pass.

SAFE keeps the existing endpoint margin 6, lane margin 4 and over-the-top rules. A synthetic unchanged scene selects the same native receiver/mode and sends the same packet at the same time as V25 when visuals are disabled.

MOD adds contested **downfield burn** opportunities when the receiver is following a sufficiently stable, comfortable route and has a modeled catch-point advantage over the corner. TRUST admits tighter burn races and more route adjustment. These are deliberately riskier user choices; neither mode guarantees that a defender cannot intercept. Existing strict-safe opportunities remain eligible in every mode.

The additional windows use these explicit application policies, in source-model studs/seconds:

| Additional-window check | MOD | TRUST |
|---|---:|---:|
| Minimum conservative endpoint margin | 2 | -2 |
| Minimum conservative lane margin | -1 | -4 |
| Minimum modeled DB ETA minus WR ETA | 0.08 s | -0.02 s |
| Maximum lateral correction from projected route | 3 | 6 |
| Maximum normalized horizontal turn | 0.25 | 0.5 |
| Maximum WR ETA after nominal arrival | 0.05 s | 0.1 s |

ETA uses the inherited 4.5-stud horizontal reach estimate and observed/normal run speed. Horizontal route stability excludes vertical jump velocity. Negative lane allowance acknowledges a corner's possible reaction/turning route; TRUST's slightly negative race allowance admits a close contest. These are confidence/risk preferences, **not measured FF3 catch radii, certified reaction windows or interception probabilities**.

Every newly admitted contested window must also clear the defender's observed-motion path through the actual ball flight's reachable-height intervals. An already direct interception path still blocks. A deeper prevent defender still blocks elevated throws. AFK, current team, manual blacklist, valid field/LOS, receiver reach, native ownership, actual play/ball state and one-attempt possession protection remain. Softened close-power passes retain the original strict checks; looser burn risk does not blindly make them slower into coverage. Lateral short routes do not become contested burns just because TRUST is selected.

The conservative pursuit disk and direct observed-motion corridor are both approximations using inherited uncalibrated reach. MOD/TRUST may lose contests. They expose progressively tighter opportunities without replacing native catch/aim calculations or forcing a throw when every profile check fails. Extra arithmetic runs at the existing decision cadence; no new world/player scan or native call is added, and total native frame budget stays eight. SAFE skips the additional race/direct-path work.

Configure an initial mode if desired:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/loader.lua"))({
    FF3 = { RiskMode = "MOD" }
})
```

`SAFE`, `MOD`/`MODERATE` and `TRUST` are accepted. Reports show RISK_MODE, limits, direct-lane clearance, race advantage, WR ETA and lateral correction.

## Bullet/animation investigation

The user reports intermittent bullet overthrows and suspects simultaneous animation. No new trajectory report establishes their precise live cause. V25 played the owned animation before the last native calculation, so visual head motion could influence the native launch calculation.

V26 loads/prepares the known track first, requests a normal deep jump where appropriate, then performs the fresh native solve and final eligibility/coverage checks. It rechecks the native launch head reference before reserving/sending; a greater-than-0.5-stud head change invalidates that unsent calculation for replanning. The actual native origin, direction and power are preserved. **Only after the request returns does visual playback begin.** No animation progress, windup or peak timer gates the pass, and the visual track cannot retroactively change the sent packet. There is no animation-based lead correction or arbitrary aim-offset patch.

AWAY retains its existing deliberate manual animation/request path. A genuine visual exception after an automatic request preserves the already-sent receipt, stops and never retries or mislabels the visual error as an ambiguous network request. Stop during animation loading destroys the returned track rather than leaving an unowned instance. Native/manual tracks remain separate from Pelican's exact owned track.

THROW_INPUTS preserves native reference/send head positions, current native lead, ping and solve age alongside actual path/power, receiver/defender observations and active risk. That evidence can distinguish stale-pose, lead, movement and native-model hypotheses if overthrows continue. Removing visual influence is demonstrated locally; it is not proof that animation caused every reported overthrow or that native/server physics and low-power conversion are calibrated.

## Validation and limits

635 current mocked assertions pass: risk modes 60, visual release 16, existing frame/animation regression 38, jump/release 53, close-power 33, goal blue-line 55, endpoint/evidence 34, AWAY 35, reload 9, error-stop 12, loader/config 116, bundle 55, active-play timeout 25, LOS discovery 66 and ground recovery 28. Error-injection warnings are expected.

New scenes distinguish a MOD burn from SAFE and a tighter TRUST burn from MOD, retain prevent/direct-path and eligibility gates, exercise the mobile cycle and a mid-solve mode change, retain SAFE packet/timing behavior and accept a jumping WR without mistaking vertical velocity for a route cut. A synthetic animation-driven head shift changes V25's packet but not V26's packet relative to the no-animation baseline. Post-send visual errors and stop-during-load resource cleanup are covered. The preparation-stage regression hooks now explicitly run during track loading rather than during post-send visual playback.

Sources and bundle parse/run in Lua 5.4; local mocks do not establish Roblox catches, actual server launch behavior, configured risk quality or iPhone performance. No live/currency/real-exit tests were run. The exact cause of the user's intermittent live overthrow remains unproven. V26 removes a demonstrated coupling and implements requested risk policies; further physics/lead changes should depend on actual throw evidence. The loader pins `ff3-v26` and requires `PELICAN_FF3_V26`. Other game source bytes/routes remain unchanged. AWAY stays visible; stats and Yuna startup automation remain removed.
