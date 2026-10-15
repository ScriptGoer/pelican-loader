# FF3 V18: short completions, stable targets and automatic deep jump releases

The user confirms V17 works and reports four remaining issues: no visible throwing animation, rapid switching between open receivers, a preference for short completions, and a request to jump automatically before releasing deep throws at the jump peak. This is user-reported success and criticism, not measured completion-rate evidence. V17's exact controller is preserved privately and at the immutable public `ff3-v17` release.

## Run

Keep Yuna **QB Aimbot ON, Mouse Aimbot OFF, Auto Throw Type ON**. Start either script first. Use the normal loader:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/loader.lua"))()
```

The FF3 live route pins `ff3-v18`, contract `PELICAN_FF3_V18`. Practice, Threshold, the optional jump-button helper and historical diagnostics retain their existing routes and module bytes. The tiny HUD, WR blacklist, AUTO/THR, pace controls, report preservation and red kill switch remain.

## Completion preference and receiver stability

Receiver choice first separates release-qualified from merely selectable options using the existing interception checks. Among release-qualified receiver/mode results it favors shorter actual horizontal ball travel. Mode comparison within each receiver still uses V17's native outputs, safety, flight and residual-placement ranking. An unsafe nearby receiver cannot displace a safe farther receiver.

The controller keeps a release-qualified incumbent through small rank/distance changes. A safe challenger must shorten the pass by at least **five yards** to replace that incumbent; loss of the incumbent's release qualification permits immediate replacement by a qualified alternative. The first considered receivers are ordered by approximate distance, with rotating challengers retained so a covered nearby player cannot permanently hide a safe farther player. These are deliberate selection policies, not new FF3 physics constants.

## Automatic jump and peak release

A **deep throw defaults to at least 30 yards of actual horizontal travel from the QB's native release origin to the native predicted arrival**. This is a configurable policy cutoff; it is not a claim about the game's official deep-pass definition. Fit/Bullet/Dime/Jump names do not determine the cutoff.

After the ordinary play-development, receiver-motion, LOS and safe-window checks pass, a deep opportunity requests a normal `Humanoid.Jump`. It does not require a manual jump-button press. It changes no jump power, gravity, velocity, movement speed or catch offsets, and respects disabled jumping/seated/platform states. The controller then observes actual airborne ascent and the vertical-velocity sign crossing on Heartbeat. It releases only after the observed peak, within a **0.10-second observation grace**, while still airborne and no longer rising. This accommodates discrete mobile frames; it cannot promise a mathematical zero-velocity instant.

At release it refreshes receiver/defender observations and calls the native final solver again from the QB's actual elevated position. Native trajectory, receiver reach, interception risk, possession, LOS, team, blacklist, mode scope, animation progress and peak timing must still pass. A prior safe preview is not release authorization. Fit remains one of the jointly evaluated native modes and naturally uses the higher launch origin when the QB jumps; its native leads and power policy are unchanged. This does not establish new WR jump-catching or dead-zone mechanics.

Short passes do not request a jump or wait for an apex. They use the ordinary animation windup when an actual native asset is available. If a short opportunity becomes preferable during preparation, the pending deep sequence is cancelled; an already-started physical jump is not forcibly undone.

Only one automatic jump is requested per continuous ready possession to avoid repeated jumping after a lost window. If coverage closes or the peak is missed, the controller holds rather than forcing the pass. A later safe short option can still complete, and a naturally observed subsequent jump can provide another deep release window. No second throw request is permitted for a possession that already attempted a request. A normal jump request with no observed ascent stops after one second with its own report reason. Menu opening, AUTO/THR off, blacklist changes, native/manual throw ownership, lost possession/character, stopping and teleport start cancel pending work. Kill restores an unconsumed owned Jump flag; it does not force a landing.

## Throwing animation: supported path and remaining limit

V17's actual automatic-release path sent the source-shaped remote request without starting an animation. That omission is established by the code. Previously preserved native-source audit notes record a Throw animation gate near **0.19 seconds** in the input release path (original readable QB lines 2290–2313). The original paid attachment is not mounted in the current workspace; this change uses those preserved references and the current integration code, and neither executes nor republishes that attachment.

V18 searches for an existing Throw Animation/AnimationTrack associated with the qualified release/tool captures, a native Throw observed on the current character, or a bounded local animation-asset search. Conflicting assets are rejected. It loads a separate owned track on the current character's existing Animator, plays the actual observed asset, and waits for its source-observed release time. The owned track has a distinct name so it is not mistaken for a native manual throw. Native/manual tracks and original asset objects are never stopped or altered. The owned animation is stopped/destroyed on cancellation and shutdown; after an accepted API call it may finish naturally. It does not call `Tool:Activate()` solely to animate, because that could also issue an uncontrolled native throw.

**The game's Throw asset must actually be exposed.** If no unambiguous asset/current Animator can be found, V18 explicitly records `THROW_ANIMATION_STATUS` and `THROW_ANIMATION_SOURCE` and preserves the working V17 request path. It does not silently insert a fabricated ID. This means animation discovery is implemented, but visible animation is not guaranteed on the actual executor until live verification. Actual load/play exceptions stop immediately; a track that fails to advance to the release time stops after a bounded 1.25-second wait. These are integration timeouts, not catch thresholds.

Reports retain actual mode/trajectory/actors plus `THROW_RELEASE`: pass distance, deep classification, QB height/vertical velocity, observed peak age and animation status. They also expose preparation/cancellation outcome, automatic jump count, selected distance policies, animation source/asset, whole-Heartbeat duration and own native calls per frame. File/session preservation remains every ten seconds, on automatic request, jump preparation, stop and teleport; API acceptance does not prove iPhone file/clipboard readback.

## Optional policies

No extra mobile controls were added. To change the two distance policies deliberately:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/loader.lua"))({
    FF3 = { DeepThrowYards = 35, ReceiverSwitchYards = 5 }
})
```

Both values accept 1–100 yards. Lower `DeepThrowYards` makes more throws require automatic jumping. Higher `ReceiverSwitchYards` keeps a safe incumbent through larger distance differences. Default remains 30/5.

If needed, restore the user-reported working V17 with its matching loader:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/ff3-v17/loader.lua"))()
```

## Validation and live uncertainty

The 68 new actual-controller synthetic assertions cover automatic deep jumping without user input, observed post-peak/elevated release, native-asset animation progress, short-over-deep completion preference, unsafe short versus safe deep selection, stable locks under alternating small advantages, shorter-challenger replacement, cancellation during jump, pending Jump-flag restoration, replacement QB with reused Tool, no unobserved-ascent fallback, native animation errors/stalls/missing-asset reporting, configurable cutoff, cleanup and frame solver budget. Fake asset IDs exist only in private fixtures; no animation ID is invented in public runtime source. Tests use synthetic Humanoid motion and native-shaped solver closures, not the paid source or a Roblox server.

The current timeout (25), LOS (66), ground recovery (28), error-stop (12), loader/config (89) and bundle startup/cleanup (55) assertions pass. The archived V17 coverage suite (89) remains separate and passes against the preserved V17 controller with the shared fixture. Native Luau compilation passes. Other runtime modules and original V17 bytes are preserved.

Heavy planning remains on the 0.12-second budget. The per-frame work observes the local QB jump and advances an already prepared release; it does not scan every receiver/mode every frame. Receiver/defender observations refresh at actual release. A shared eight-call cap covers planning and precise-release native calculations in the same Heartbeat. Animation-asset discovery is bounded and owned-track reuse avoids repeating successful discovery per throw. Whole-Heartbeat CPU time is reported; no local test establishes iPhone performance.

Still needs live verification: normal automatic jump handling by the actual FF3 character/controller; animation asset discovery, visibility and replication while walking; the native 0.19-second gate against the running Yuna build; peak observation under actual mobile frame timing; fresh Fit/Bullet/Dime/Jump catchability; stable short preference with live coverage; and cleanup/report readback. V17's defender reach estimates, receiver bounds and server ball-physics assumptions remain uncalibrated. User confirmation that V17 works does not validate V18's new sequence. No live, destructive or currency-spending test was run, and no anti-cheat or anti-tamper code was modified.
