# FF3 V26.6: receiver movement evidence and read-only lead comparisons

The prior recorder saved the requested native trajectory and lead values, but did not follow the receiver/ball after release. V26.6 adds a passive observer and folded **LEADS** panel. It collects evidence for lead calibration while keeping intended targets, throw modes, risk gates, release packets and Yuna settings unchanged. This is a recording/calibration release; it is not a verified automatic fault detector or a guarantee of perfect lead values.

## Controls and settings

Reexecute the ordinary loader, expand the status pill and tap **LEADS**. The panel shows the current X/Y settings for Bullet, Fit, Jump, Dive and Dime where the qualified native lead table contains them. Values come from the same shared native table used by the matched solver, not a guessed GUI path or copied defaults. The readout follows settings changes; stored values retain the original numeric precision. The panel is read-only and does not change sliders or require Yuna's settings menu to stay open.

The actual applied lead, complete mode lead settings and control provenance are saved with each Pelican automatic throw. Powered standing Bullets use Bullet X/Y even though they solve through a native Dime branch. The experimental Jump Bullet uses Bullet X and **Fit Y**. Normal modes retain their corresponding controls. Native effective vertical offset and whether the configured Y was actually applied are recorded; an inactive conditional Y branch cannot justify a Y slider comparison.

The desired Fit style is an observed jump at possession, continuing the route, without a detected dive or unexplained extra-height signal. This is a preference about observed movement, not proof that jumping was necessary. Opening the panel does not hold or postpone a throw. It is mutually exclusive with the WR list to avoid overlapping menus. No permanent HUD is added.

## What is observed

After a successful Pelican automatic request, the observer follows the intended receiver and known equipped Handle. It samples at most every 0.08 seconds for at most seven seconds/80 observations, with an earlier mode-dependent observation deadline. It records:

- Actual receiver positions and reported velocities, rolling position-derived continuity, route turns, speed changes and vertical movement.
- Humanoid state/floor observations, ground-to-air jump signals, jump timing/count, whether a jump overlaps observed possession and whether an action was already in progress before the throw.
- Torso/root orientation, hands extended along travel, airborne/physics state and the first dive-like pose. R6 hand positions are explicitly labeled arm-endpoint estimates. Optional visible animation IDs are ancillary; neither an animation name nor a playing animation is required to observe the stiff, hands-out pose.
- Ball positions and a fitted physical path where a ball can be followed; nearest approach relative to the receiver's head and running direction.
- Visible ball ownership and, separately, physical connection to the intended receiver's body. Directly observed opponent possession is recorded without inventing an official interception award.
- Sampling gaps, changed characters/teams/field, nearby defenders, extra vertical displacement and other reasons a throw is unsuitable for comparison.

A same-instance outgoing Handle is tagged `EXACT_HELD_PART`. A unique newly observed football assembly may be followed as `CLONE_CANDIDATE_UNVERIFIED`; multiple candidates remain ambiguous. Clone hypotheses are useful diagnostics but do not qualify for numeric lead comparisons. Two consecutive observations of the identified ball under the intended receiver support `RECEIVER_POSSESSION_OBSERVED`; a visible physical connection is an additional comparison requirement. API success, the original possession ending, a scoreboard change or the ball disappearing are insufficient.

Raw body samples are compacted to roughly 24 uniformly retained points plus the last point. Jump events and movement extrema retain separate witness records. A bounded compact set of physics points is stored alongside its fit coefficients/residual, allowing the path fit to be recomputed. This is client-observed physics, not a server catch-window certificate. The existing 100-record/80,000-byte rolling history bound still applies; richer records may reduce how many complete throws fit.

Evidence attaches to the original throw ID instead of adding fictitious throw attempts. Attachments advance the history revision without changing request totals. DATA/export/checkpoint/upload snapshots include partial in-flight evidence without ending observation. `a` uploads the same session data, including those attachments. Your existing chat companion remains compatible and needs no new credential file. For complete final traces, upload after the catch attempt or observation finishes.

## Observed action versus required action

`JUMP_SIGNAL`, `DIVE_LIKE_POSE_ONLY` and `JUMP_AND_DIVE_LIKE_POSE` describe observations. They do not assert what the receiver had to do. An unnecessary early jump is not credited as a jump-at-possession; repeated jumps, preexisting actions, cuts, slowdowns, unclassified body poses and uncertain tracking are comparison blockers.

Remote catch-button input, camera intent and why a person jumped are unavailable. Angling can affect catch reach without an obvious extra rise in the root; ordinary root height cannot prove its absence. The extra-height check is only an unexplained-movement signal against nominal Humanoid jump properties, never an angling verdict. Every record explicitly retains `RequiredMovement=UNKNOWN` and `Fault=UNRESOLVED`.

Ball offset along the route and height relative to the observed head are measured geometry. They are not automatically labeled too short, too low, uncaught or quarterback fault. A receiver can change course in response to bad placement; a route change alone does not establish receiver fault either. The actual FF3 catch envelope and relevant pose classification still need game evidence.

## Conservative decimal comparisons

The advisor currently limits numeric output to **previously observed Fit-style alternatives**, rather than inventing an untested X/Y adjustment. The other mode values are displayed and recorded but have no fabricated numeric advice. Initial advice will normally remain withheld while game-specific evidence is missing.

A usable comparison requires an exact identified ball, physical possession witness, a clean observed path/motion context, controlled dive-pose calibration, and intended-receiver possession. Coarse matching/QC policies separate the same receiver/session, runtime release, mode/variant, power, flight-time/range context, QB jump state, active vertical branch and native settings. Nearby defenders and conflicting evidence exclude suggestions. These application policies are not FF3 catch hitbox numbers and do not gate normal passing.

There must be at least five qualifying catches at the current lead and five at a previously tested alternative differing in **one axis only**, by at most 0.5 native lead units. The observed desired-style counts must have non-overlapping Wilson 95% intervals. These descriptive intervals are not calibrated causal confidence or proof of independent/randomized trials. Conflicting directions suppress output; directly observed opponent possession associated with the alternative settings also blocks that alternative instead of being discarded from consideration.

The panel/report can then show an observed decimal alternative, sample counts and supporting throw IDs. This comparison is **conditional on observed catches**; missed/unresolved outcomes are not reliable catch-input labels. It does not establish improved completion probability, necessity of the movement or blame. The panel states that catch benefit is unproven. Test one axis at a time if you choose to try an alternative. Settings are never applied automatically.

Without controlled dive-pose calibration, numeric comparisons remain withheld. Default visual rules flag a provisional dive-like pose from a relatively horizontal torso, both hands forward along travel and an airborne or rigid-physics state. These are recording heuristics, not verified FF3 mechanics. Raw pose measurements are retained to check them against controlled recordings or actual game behavior. Later, `FF3.ReceiverEvidence.VerifiedDivePose` can supply `MaxTorsoUpAbs`, `UprightMinUpAbs`, `MinHandForward` and a nonempty `Reference` identifying that evidence. This configuration asserts prior calibration; the script does not verify that assertion automatically. No animation-ID mapping is used.

## Performance and lifecycle

All observation work runs after passing decisions. There are no extra native aiming solves, new per-frame world scans, remote-input hooks, anti-cheat changes or animation edits. Candidate indexing reuses the existing descendant listener and is bounded; pose sampling only runs during an active observation. Advice refreshes at most once per second while the panel is open, and again when a trace finishes. The report includes the maximum observed capture update duration; iPhone performance still needs measurement.

Capture cancels/finalizes on replacement, stop, teleport and actor/field changes. An observer exception disables capture and preserves an error receipt while leaving Auto QB running. This isolates recorder failures from working passing. Metadata/history failures retain their established handling. To disable pose/ball capture while retaining exact lead metadata/readout:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/loader.lua"))({
    FF3 = { ReceiverEvidence = false }
})
```

Reports add the current leads, observation status, movement/ownership summaries, QC rejections and supporting IDs for any empirical alternative. Native/manual Yuna throws without a linked Pelican request are not reconstructed from guessed packet data; Dive therefore has a settings readout but no invented automatic-throw sample stream. Actor labels remain anonymous. Server identity is used only in memory for session grouping; chat contents, credentials, usernames and paid source are not added to observations.

## Validation and remaining evidence

69 new mocked checks exercise same-handle departure/receiver possession, physical path fitting and corruption residuals, body/hand pose versus animation-name distinctions, unavailable animation APIs, clone rejection, route changes without blame, exact settings/decimal values and control provenance, calibrated versus uncalibrated poses, one-axis comparisons and supporting IDs, known opponent evidence, malformed saved data, export/upload attachments, partial traces, disabled capture and observer-error isolation. The existing suites cover release timing, modes, power, LOS, startup/shutdown and chat upload.

All 21 current suites pass: **1,143 mocked assertions**. Source and rebuilt bundle load under Lua 5.4. No Roblox catches, chat, currency or live player actions were exercised. Actual ball replication identity, remote body/hand visibility, calibrated dive poses, catch envelopes, extra-reach techniques and iPhone overhead remain unverified. Reliable automatic fault attribution is not claimed. The next useful evidence is the richer current-session export from real throws; it can identify the specific missing calibration instead of repeating generic solver tests.

The live loader pins `ff3-v26.6`; prior immutable `ff3-v26.5` and other game routes remain preserved.
