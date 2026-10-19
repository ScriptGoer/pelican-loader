# FF3 Auto QB: adaptive Bullet power and retained history

The prior short-power policy used a 60 floor and could fall back directly to 95. The user wants an easy standing catch, with power changing by distance and coverage. Yellow is a rough visual reference and does not gate power. The exact cause of the earlier live report of missing lower power remains unproven.

## Current automatic behavior

The planner compares two ordinary Bullet-lead candidates: `SoftBullet` requests a gentler flight and `QuickBullet` requests a quicker coverage window. Defaults estimate power for approximately 0.75 and 0.50 seconds respectively, with a request floor of 40 and a cap of 94. These are tunable comfort policies, **not measured human reaction times or verified FF3 catch mechanics**. The initial request uses current QB/WR positions, receiver velocity, ping, the active Bullet lead and the source-model gravity. It is no longer a flat 60 short-range band or a distance-only ramp.

The estimate chooses a power input; it does not supply the ball's final trajectory. Each candidate is separately solved by the qualified native helper and receives its own projected path, flight time, receiver-reach, lane, endpoint and coverage checks. If both qualify, the lower actual native power wins. If the gentler path gives a defender too much time, a safe intermediate-power QuickBullet can win. Every Bullet variant stays strict in SAFE, MOD and TRUST. A safe ordinary Bullet remains preferred over an unnecessary experimental jump Bullet.

Full-power automatic candidates (including other native mode labels, preventing a 95-power label workaround) require enough native horizontal throw distance and flight time. The default is at least `95 * WindowSeconds / 3` yards (about 15.83 yards) and at least WindowSeconds of flight. This is an explicit comfort policy based on the modeled throw, not a first-down-line rule. Full power is available for longer eligible opportunities when a lower-power completion is unavailable or unsafe. A rejected softer candidate cannot silently authorize a short 95 throw. If nothing qualifies, automatic release stays withheld and the existing manual target remains available.

No fixed release delay, extra animation timer or peak wait is introduced. The intended change is **slower ball travel where suitable**, not delayed commitment to an open receiver. Powered standing Bullets retain the active Bullet lead rather than adding a new jump or catch-height offset. Their previous no-extra-QB-jump behavior remains; ordinary full/deep native release behavior is preserved.

## Lower-power control and evidence

The current call previously selected ManualType Power but kept passing the saved Angle as the native helper's manual input. Archived live V24/V24.1 reports show Angle=45, also establishing the UI degree convention. The call now supplies the requested power in Power mode and degree-valued input in Angle mode, including the existing native Power-mode path. A manual-value fixture reproduces old requested-60/returned-45 rejection followed by 95, then checks the corrected request. This is a supported failure mechanism, not proof of the user's latest live trigger. Returned-power verification remains mandatory.

The primary path still asks the native generic Dime Power/low-arc calculation for the current Bullet lead. It verifies returned power, actual model speed versus reported power, lower ballistic branch and actual arrival height. The inspected native Bullet/Fit branch forces 95, so changing that branch's Power setting alone cannot implement this feature.

If direct Power is not honored or gives an unsupported higher branch, the controller records the failure and changes subsequent bounded planning attempts to the source-supported generic **Angle** path. The retained audit identifies the native non-Bullet angle-to-power formula. A low-angle estimate is passed to that native solver under an owned temporary Angle/ManualType/lead/power transaction. The native final tuple, including its actual derived power and velocity, remains authoritative. It is accepted only if it is below full power, speed/power agree, the lower branch and active Bullet height are verified, and ordinary safety checks pass. Angle-derived actual power may differ from the initial request, including below its requested floor; reports preserve both. No manually fabricated velocity or server packet substitutes for an unsupported native result.

This is a source-supported compatibility fallback, not a claim that the user's current running build ignored Power. The original paid attachment is no longer in this workspace; its retained audit and current integration support the path, and actual running-build compatibility still needs live verification. Unsupported control remains visible and cannot force a short full-power pass. Actual exceptions/yields retain stop-and-preserve behavior; these are counterfactual native calculations, not repeated server throw requests. One request per possession and no ambiguous network retries remain.

All temporary settings, including Angle, restore synchronously. A conflicting external Angle edit is preserved and stops the instance. Reports now include BULLET_POWER_METHOD, persistent method failure reason/receipt, bounded requested/returned power traces, full-power limits, candidate power eligibility, selected requested/actual power and actual release trajectory. A game's displayed power number alone does not establish the sent power; the script does not rewrite the native game power UI. The request receipt records the actual argument supplied by the solver, not a verified server launch or catch.

## Configuration

Regular-loader users need no new buttons or options. Advanced settings remain optional:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/loader.lua"))({
    FF3 = {
        CloseBullet = { MinPower = 40, ComfortSeconds = 0.75, WindowSeconds = 0.50 }
    }
})
```

`CloseBullet=false` deliberately restores original native-power planning and opts out of the comfort/full-power restriction. An explicit old `MinPower=60` still requests a 60 minimum; remove it to use the new default. Optional `FullPowerYards` overrides the default minimum full-power distance while preserving the minimum flight check. Legacy `SoftYards` is ignored because the fixed-distance ramp is removed. Existing SAFE/MOD/TRUST, JB, comeback, WR blacklist, COPY, AWAY and X controls remain. Normal field/LOS requirements are preserved; power adds no yellow-marker lookup or dependency.

## Current validation

1,074 current mocked assertions pass, including 87 chat/session-upload checks and 138 retained-history/authentication checks, 56 adaptive-power checks and 33 native power/rollback checks. The new suite reproduces the archived short-95 fallback, checks intermediate power under closing coverage, unchanged open release readiness, marker independence, unsupported-control refusal, Angle recovery and transactional cleanup. Legacy non-power fixtures explicitly opt out while dedicated current power suites enable defaults. Source/bundle validation uses Lua 5.4.

No live throws/chats were run. Native build compatibility, actual server speed conversion, catch comfort and iPhone performance remain unverified. The exact prior live failure cause is not established. The loader pins `ff3-v26.6` and retains `PELICAN_FF3_V26`.

## Preserved V26.2 and earlier behavior

# FF3 V26.2: strict Bullet, timing-only Fit and jump-bullet trial

Yuna's retained source audit shows Fit's vertical lead is conditional on running-away/mouse aiming; Jump keeps it for sideways routes. That explains a sideways Fit collapsing to a chest target. Configured height is not a verified server catch window. This patch keeps the V26 controller contract and adds the controls below.

## Optional native Fit-height Bullet trial

Expand the HUD and tap **JB OFF** to enable **JB ON**, or explicitly configure:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/loader.lua"))({
    FF3 = { JumpBullet = true }
})
```

It starts **off** in a new executor session because its catch window is uncalibrated. The deliberate toggle persists in executor memory across reload; an explicit option wins. Toggle changes cancel prepared work and clear candidate caches.

The additional `JumpBullet` candidate temporarily uses the native Jump Power path, Power 95, PreferHighArc false, and a Jump lead built from the player's active **Bullet.X / Fit.Y**. Jump's unconditional vertical-lead branch retains Fit's configured lift on sideways routes. No new numeric catch-height offset is added. The final solver supplies origin, velocity, time, aim and native clamp/SmartPass placement. The controller checks reported power and model velocity magnitude against 95 (within 1), verifies actual ballistic arrival Y against the pre-vertical aimpoint plus the configured lift using the existing numeric tolerance, and rejects the higher ballistic branch. Missing/nonpositive Fit height, ignored settings, inconsistent output or unsupported behavior rejects the candidate rather than constructing a velocity by hand.

The native Jump settings and lead entry are restored inside the synchronous solve. Only the validated candidate is labeled as a Bullet variant. It passes the original strict lane/endpoint checks in all risk modes. When both ordinary and jump Bullets are safe, the ordinary Bullet wins so open receivers do not need unnecessary jumps. Native selection, team restriction, movement/field/arrival eligibility and release revalidation still apply. Reports identify `JumpBullet`, actual applied lead, native mode, power, path and the uncalibrated status.

This implements a **native Fit-height, Bullet-speed trial**, not a proven reliable high-jump catch. It may still require unsuitable timing or land in the game's dead zone. Enable it deliberately for live evaluation with a ready receiver; do not interpret a configured lift or local branch test as catch calibration. The feature does not control a WR's jump or change Humanoid jump power, catch code, anti-cheat or anti-tamper behavior.

## Bullet remains strict

`throwable` now excludes every candidate labeled Bullet from MOD/TRUST relaxation. Ordinary Bullet, SoftBullet and JumpBullet require the existing endpoint margin 6 and lane margin 4 in SAFE, MOD and TRUST. Dime/Jump retain their non-Bullet burn-risk policies; Fit additionally requires the timing gate below. The prior V26.1 source is privately preserved in the private source archive, with its immutable public tag retained. A source comparison reproduces a contested Bullet admitted by V26.1 MOD and rejected by all current risk modes.

## Fit must rescue a late throw

Fit is no longer eligible merely because its score or receiver direction looks favorable. For each receiver, the planner first grades available non-Fit candidates. A usable non-Fit opportunity vetoes automatic Fit for that receiver.

When none is usable, Fit requires a graded alternative whose modeled defender arrival time is no later than ball flight time. Fit must have a shorter flight than that late alternative, arrive before its own modeled defender ETA, and pass its current lane/endpoint/prevent and receiver checks. A lane-only problem, missing/invalid alternative, or safe but lower-scoring ordinary pass does not establish a timing rescue. Native mode names and distance alone cannot authorize Fit.

At release the controller solves the chosen counterfactual again, then solves the actual Fit last. Fresh receiver/defender observations regrade both and other still-current cached alternatives; a newly safe alternative, lost timing advantage or newly threatened Fit cancels the unsent release for replanning. Evidence records the compared variant, both flight/defender times and Fit reason. The redundant main-loop Fit preview is omitted so up to six planning calls plus the two final calls remain within the existing eight-call frame limit. No animation/peak/pacing timer is added. Manual selection remains available when automatic timing need is unproven.

Defender ETA uses the inherited speed-bounded pursuit/reach model (distance minus inherited reach, divided by observed/normal speed). It assumes immediate reaction and turning. This is a modeled timing comparison, not measured FF3 catch probability, and may be conservative. Comparisons are bounded by the existing candidate cache/call/time policy, not an exhaustive search of every possible route.

## V26.2 validation

793 current mocked assertions pass, including 55 mode-policy checks. They cover the reproduced prior Bullet regression, timing-only Fit and fresh comparison, two-receiver call budget, lateral height retention, native speed/branch verification, rollback/conflicts/stop, unsupported output and the opt-in UI. Generic jump/frame tests now use Dime where an isolated Fit no longer qualifies; preserved historical regression cases remain.

Lua 5.4 source/bundle tests do not establish live server catches or iPhone performance. No live game or chat test was performed. Native Fit height may still lie in an unreliable/dead-zone region: the JB trial starts off until deliberately enabled. The original paid attachment is unavailable in this workspace; the retained audit and current solver capability checks underpin this change. The timing/reach model remains approximate. The loader pins `ff3-v26.6` and requires `PELICAN_FF3_V26`.

## Preserved V26.1 comeback and V26 behavior

# FF3 V26.1: team comeback call

The optional route call below is added to V26 without changing its controller contract or pass decisions. Prior V26 runtime remains at immutable `ff3-v26`.

## Behavior

Chat is enabled by default for the user's requested feature. During an active Auto QB possession, when the current planner has only a manual/covered target and no release is being prepared or sent, the advisor observes eligible receivers using the existing decision snapshot. It asks for a comeback only when one active WR stays within 15 studs (5 yards) of the same defender for at least two continuous seconds. The defender must be alongside or deeper (at most 3 studs underneath). A receiver already coming back (forward velocity below -2 studs/sec) or separating from that defender by over 2 studs/sec is excluded. These are explicit route-call heuristics, **not calibrated interception/catch windows or verified corner/safety role assignments**.

The message is exactly:

```text
comeback
```

No player name, prefix or extra wording is added. It sends at most once per controller-observed possession, with a 30-second executor-session cooldown across X reload/reexecution. It does not wait for a response. Brief crossings, AFK/blacklisted/ineligible receivers, missing defender observations, pregame, a missing ball/LOS, menu selection, disabled AUTO/THR, native/manual throw ownership and safe automatic releases do not trigger calls. Interrupted coverage, character changes, field/possession/team changes and stale snapshots reset observation continuity.

The existing release runs before chat advisory work. Advisory calculations reuse the existing player samples and add no native solver calls or world scan. `SendAsync` runs in one separately owned deferred task; it never yields the Heartbeat or delays a throw. A deferred send rechecks the current ball/play, receiver movement, defender coverage, team membership and exact channel before invocation. Stop/reload/teleport and the CB toggle invalidate/cancel the owned task. An in-flight request cannot be unsent, so cancellation preserves delivery uncertainty and its cooldown instead of replaying it.

## Team-only qualification and platform limits

Only the documented default `TextChatService.TextChannels.RBXTeam` + **TeamColor.Name** channel is eligible. Default channels must be enabled. The script requires the local player's matching writable `TextSource`, validates all present channel members against the current non-neutral team, rejects duplicate channels and rejects an opponent team sharing that color. Custom/legacy/unavailable channels are reported as `TEAM_CHANNEL_UNAVAILABLE`; there is no general-chat fallback, guessed remote, `/team` command, chat GUI manipulation or chat-policy bypass.

This channel naming comes from [Roblox's default-channel documentation](https://create.roblox.com/docs/reference/engine/classes/TextChatService#CreateDefaultTextChannels), not an observed FF3 channel capture. [SendAsync](https://create.roblox.com/docs/reference/engine/classes/TextChannel#SendAsync) yields, returns a message status and may be restricted by Roblox: the current reference explicitly warns that only messages typed and sent by the user will be delivered. **Automated delivery in FF3 is unverified and may be refused even with a valid channel.** No actual message was sent in development. A returned Success records API status, not teammates' receipt or route execution.

A denied/non-success/absent result disables optional chat without retrying; a five-second unanswered request is cancelled and disables chat with unknown delivery. Auto QB stays available in those cases. An actual Lua exception follows the user's existing stop-and-preserve error policy. Reports include COMEBACK_CHAT, COMEBACK_STATUS, COMEBACK_ATTEMPTS, COMEBACK_OUTCOME and the explicit policy.

## Controls

Expand the status bar and tap **CB ON / CB OFF** below AWAY. The toggle is otherwise hidden and doesn't add to the collapsed HUD. The choice persists in executor memory for X reload. An explicit loader option overrides that session preference:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/loader.lua"))({
    FF3 = { ComebackChat = false }
})
```

No Yuna startup configuration, stat tracking, auto server leaving or GUI recording is reintroduced.

## V26.1 validation

738 current mocked checks pass: 103 team-chat checks plus the prior 635. Captures cover exact text/channel, sustained coverage, spam limits, deferred cancellation, unavailable/denied/unknown/error chat, cleanup and unchanged open-throw timing/packet/native calls. No real chat was sent. Automated delivery and iPhone performance remain unverified.

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

The V26 baseline comprised 635 mocked assertions: risk modes 60, visual release 16, existing frame/animation regression 38, jump/release 53, close-power 33, goal blue-line 55, endpoint/evidence 34, AWAY 35, reload 9, error-stop 12, loader/config 116, bundle 55, active-play timeout 25, LOS discovery 66 and ground recovery 28. Error-injection warnings are expected.

New scenes distinguish a MOD burn from SAFE and a tighter TRUST burn from MOD, retain prevent/direct-path and eligibility gates, exercise the mobile cycle and a mid-solve mode change, retain SAFE packet/timing behavior and accept a jumping WR without mistaking vertical velocity for a route cut. A synthetic animation-driven head shift changes V25's packet but not V26's packet relative to the no-animation baseline. Post-send visual errors and stop-during-load resource cleanup are covered. The preparation-stage regression hooks now explicitly run during track loading rather than during post-send visual playback.

Sources and bundle parse/run in Lua 5.4; local mocks do not establish Roblox catches, actual server launch behavior, configured risk quality or iPhone performance. No live/currency/real-exit tests were run. The exact cause of the user's intermittent live overthrow remains unproven. V26 removes a demonstrated coupling and implements requested risk policies; further physics/lead changes should depend on actual throw evidence. The loader pins `ff3-v26.6` and requires `PELICAN_FF3_V26`. Other game source bytes/routes remain unchanged. AWAY stays visible; stats and Yuna startup automation remain removed.

## V26.4 retained history

Automatic bounded device history and optional private JSONBin sync are documented in [FF3_HISTORY.md](FF3_HISTORY.md). Tap the status pill and DATA to export anonymous structured throw/block evidence across runs. Catch results stay unknown without verified outcome evidence. Throw policy and native packet/release behavior are preserved; private sync remains off until configured locally. JSONBin privacy/initialization readback was verified separately; phone executor sync remains unverified.

## V26.5 optional chat uploader

The separate [auto-execute companion](FF3_CHAT_UPLOAD.md) shares this controller’s history worker. Typing exact local lowercase `a` requests a retained current-session snapshot; ordinary QB startup does not install a chat listener or embed credentials. Device recording remains active and passing decisions are unchanged.

## V26.6 receiver evidence and exact leads

[Receiver evidence and read-only lead comparisons](FF3_RECEIVER_EVIDENCE.md) add post-throw body/hand pose and ball-path observations, exact native mode X/Y metadata, and a folded LEADS panel. Dive-like pose capture does not require an animation. Required actions and fault remain unknown; calibrated, matched, previously tested single-axis Fit alternatives are the only numeric style comparisons. The existing `a` uploader includes observations without new configuration. Throw selection, packet and release behavior are preserved. All 21 current suites pass **1,143 mocked assertions**; FF3 body/ball visibility, pose calibration, catch mechanics and iPhone overhead require live validation.
