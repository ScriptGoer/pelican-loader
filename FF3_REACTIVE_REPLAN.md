# FF3 V26.18: reconsider lost burns, conditional Jump and shared coverage work

V26.20 improves challenger scheduling within the existing native budgets and adds local target identity mapping. [Current planning behavior and limits](FF3_FRAME_REVIEW.md).

V26.19 adds holding-high Bullet-only selection, floating-safety Auto Arc and a contested-slant native low-arc Power Jump path. [Current rules and calibration limits](FF3_SAFETY_READ.md).

The ordinary loader and `competitive.lua` both delegate to the same pinned `games/ff3/auto_qb.lua`. X reloads main and obtains `ff3-v26.18`. Competitive is a profile of the shared controller, not a separate stale QB implementation. V26.17 remains available at its immutable public tag. Other games, companion scripts and the competitive entry itself retain their source bytes.

## Cancel a prediction, then reconsider the receiver

The old `cancelledBurns[player] = possession.epoch` latch prevented every subsequent automatic candidate for that receiver after a route-cut/coverage cancellation. It also applied to later short passes. That receiver-wide ban is removed. A route reversal/cut or closing lane still cancels the old pending packet, releases its lock and invalidates the relevant cached predictions; the normal planner can solve the same eligible receiver's new route within the same possession. A forward-burn classification changing is no longer an additional final veto after the actual trajectory passes current coverage.

AFK, team, blacklist, receiver filter, LOS, bounds, native ownership and final coverage checks remain. A second opportunity cannot send another packet after an attempt already owns the possession; ambiguous requests are never retried. Replanning is not permission to send the cancelled stale direction.

A still-airborne QB reuses the actual observed takeoff clock. After a cancelled opportunity, a later safe deep window after landing can request another ordinary jump; the former one-jump-per-possession latch no longer blocks that cycle. A requested jump must have been observed before another cycle is allowed. An unobserved takeoff times out once and prevents automatic deep-jump retries for that possession, while allowing an independent short ground completion or a newly observed player-started jump. The 75-ms target, fresh airborne native origin and frame-bound timing remain. There is no apex wait or fabricated historical takeoff time.

## Jump only when it creates a window

Conditional native Jump already required a strict safe Jump trajectory and a threatened actual normal Bullet chest path. It previously vetoed only safe ordinary Bullets. It now also defers to known safe Dime and qualifying Fit alternatives. Fit is assessed before the elevated candidates; experimental Jump/Mag trials cannot circularly veto an ordinary Fit. The release stage regrades current ordinary alternatives and fresh normal Bullet before the actual Jump. Missing or unsupported alternatives are not invented as safe or unsafe. Native Jump still uses its own configured lead and native controls, not a custom raised Bullet. Deliberate Jump OFF and existing risk/filter choices remain respected.

This implements the conditional need, not a calibrated server catch height. A known safe ordinary throw is preferred. Jump is permitted only if known ordinary paths do not qualify, the normal Bullet is genuinely threatened and Jump itself meets strict coverage. Native/server catch windows and whether a particular receiver can execute the jump still require live evidence.

## React to a defender moving off a window

The new default `FF3.ReactiveWindows=true` adds a bounded motion watch on the existing Heartbeat. It checks at most two eligible receiver references and six defender references at most once per 50 ms, prioritizing the selected receiver and its known lane/arrival threats. There is no new Heartbeat connection, render loop, HTTP worker or Workspace scan. Stale/model/possession/LOS contexts cannot wake it.

Defender displacement, a velocity change, or a usable exposed `Humanoid.MoveDirection` hint can request an early **cached-only** evaluation. That evaluation regrades existing fresh native trajectories against current observations; it cannot run the general native planning sweep. If no cached window qualifies, it makes no extra native solves. If a window qualifies, normal fresh native calculations, current receiver/defender checks, possession ownership and the existing jump requirement must still pass before release. The ordinary planning rotation stays at 120 ms and keeps its five-attempt reservation; reactive passes do not advance its receiver cursor. The total eight-native-calls-per-frame bound remains. `ReactiveWindows=false` disables only the early cached evaluations.

“Instant” here means no new hold timer once the current checks pass. Detection is bounded by the 50-ms watch cadence, frames, native solve cost and an applicable takeoff offset. It does not promise a network-immediate throw or force a pass merely because one DB moved; every defender is still included in the final roster check.

Auto Rush's implementation is absent from the retained source package. The retained handoff mentions its observed behavior but does not expose its implementation or an authoritative remote-input API. `MoveDirection` is an optional client observation, not verified remote keyboard/touch input and not guaranteed to replicate. This release never treats it as future position, substitutes it into the native aiming solver or uses it to relax safety. Native velocity/time/ping prediction remains authoritative for the selected trajectory. A hint can only request a fresh decision. There are no invasive input/anti-cheat hooks or unknown paid callback calls.

## Optimizations shared with competitive

The prior shared release already reached both profiles. This release adds further common work reduction: conservative pursuit and observed-motion lane checks share one set of vertical flight intervals per defender grade, and the over-top test reuses the same grade rather than recalculating it. Pure-model equivalence tests compare prior/current margins, lanes, wide margins, defender/receiver ETA, race, score and safety decisions across SAFE/MOD/TRUST and multiple trajectories. This changes work reuse, not numerical reach/ping thresholds or game physics.

Reactive cache checks add bounded arithmetic and property reads, so a phone FPS improvement is not claimed. The new counters expose actual checks, wakes, cached evaluations, coverage grades and interval builds. Every relevant behavior and lifecycle case is exercised in CASUAL and LEAGUE. The competitive UI and explicit screen exception remain separate from ordinary receiver readiness; neither gains a general AFK or behind-LOS exception.

## Validation and unresolved evidence

38 suites / 3,476 mocked assertions pass, including 1,268 new replan/reactivity/model-equivalence checks. Tests compare the old receiver-wide ban against new same-possession releases, cover a second observed jump after landing, preserve AFK and failed-jump retry limits, exercise ordinary-mode Jump vetoes, compare old/new coverage math, and release the same defender-drop scenario in both profiles. In that simulated 60-FPS scene the enabled cache path releases around 0.267 seconds after the change versus 0.350 with ordinary planning, including the existing jump offset. Those numbers are fixture results, not phone timing or human reaction calibration. Existing native-control restoration, cleanup, ambiguity, screen, field, history, loader and companion suites pass, and the bundle is rebuilt.

CurrentSettings records ReactiveWindows. Reports state cancellation scope, motion-hint limitations, shared optimization scope and work counters. No credential, raw private report, paid source or cloud record is published. No live throw, chat, currency action or cloud write was performed. Actual remote-hint availability, catchability, server agreement, coverage calibration and mobile cost remain unverified. The missing precise source for investigating Auto Rush itself is its readable movement-prediction implementation; no replacement is claimed to have been recovered.
