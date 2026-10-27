# B4 audit and scope

B4 repairs the experimental branch. Production `main` / V26.22 is unchanged. This is a deterministic native-trajectory controller, not a trained model. Local validation cannot establish Roblox catch success.

## Evidence and established causes

The supplied B3.10 possession was reproduced with its exact historical source: 44 evaluator inputs and 44 analytic-risk inputs match. It contains an observed interception after a native LoftDime, approximately 67 power, 40.07 degrees and 2.94 seconds of flight. The recorded decision cohort also admitted an ordinary native Dime with 1.75 seconds of flight. These are different solve instants; the final native solve remains authoritative.

The configured-angle LoftDime had been added as a coverage alternative but inherited ordinary Dime's TRUST trailing-corner exception. The ranker then preferred its smaller optimistic clearance debt over the faster admitted alternative. Negative clearance is a distance in an uncalibrated pursuit envelope, not an interception probability. A four-stud lead did not establish that this new long-flight variant deserved the same contested permission.

B4 gives each path an explicit admission certificate. Configured LoftDime requires strict actual path and arrival clearance. It cannot borrow ordinary Dime's trailing-burn exception. Ordinary native Bullet/Dime TRUST behavior and the existing preference for a less-exposed Dime over a low Bullet remain. Strict elevated paths remain available against a blocked underneath lane. No lead is silently raised, no arbitrary flight-delay threshold is introduced, and no defender is exempted because it looks like a rusher.

Running the revised admission against that recorded decision cohort selects its admitted 1.75-second Dime and rejects the contested loft. This is a counterfactual over captured tuples and guards, not a new native solve or a prediction that the receiver would have caught it. The observed receiver change later in flight does not establish either player's fault.

## Structural changes

| Area | Audit result and change |
| --- | --- |
| Admission and selection | Separate explicit strict, qualified trailing-burn, qualified catch-window and rejected certificates. Configured loft has its own permission. Placement, plan, reach, comfort and final guard vetoes remain mandatory. Comparator exposes the deciding field instead of treating a score as a probability. |
| Native planning | Replace blind mode cycling with a separate pure work scheduler. Bullet/Dime/available SoftBullet get refresh opportunities before their tuples expire; other available variants get oldest-attempt fairness. Cheap unsupported generators consume no native calls and remain explicit in diagnostics. Fixed native-call/time limits remain; insufficient capacity cannot promise every alternative every frame. |
| Automatic preview/release | Stop performing an extra winner-preview native solve before the actual automatic preflight/release solve. Selection-only mode retains a fresh preview. Cached planning tuples never become packets directly. |
| Jump ownership | Clear an owned normal jump request on a later Heartbeat, not merely because the clock advanced within the same callback. The old clock condition could erase the request in the guide tail before another physics turn. |
| Deferred preparation | Budget, stale-decision and launch-pose scheduling failures defer the prepared sequence. They no longer masquerade as coverage rejection. Actual changed coverage, team, possession, field and receiver reach still cancel it. A fresh unsafe preflight invalidates its optimistic planning cache so it cannot repeatedly win with the same stale tuple. |
| Jump diagnosis | Preserve the actual normal-jump state, enabled flag, posture, floor and vertical velocity rather than only NORMAL_JUMP_UNAVAILABLE. |
| Diagnostic provenance | Explicit BAD_THROW or MISSED flag kind, selection scope, epoch/time and whether a throw already occurred. Release Settings freeze at actual release; later changes appear separately. Bounded attempt history retains earlier preparation/final failures. |
| Coverage evidence | Separate early current-direction interception from pessimistic instant-turn pursuit, using the same existing vertical intervals and contest horizon. Bounded receipts add evidence without inventing new permission or calibrated catch thresholds. |
| UI and lifecycle | Keep folded QB/AWAY/reload, tools-only report actions, z presentation hiding, team/blacklist/filter/LOS/plan controls and owned cleanup. Unsupported mag/custom-height/wide-open-Jump prototypes remain disabled and absent from the menu. No new HUD button or Workspace object. |

## Deliberately retained infrastructure

The loader's route isolation, real observed FF3 identifiers, native Yuna discovery/target lock, owned synchronous settings transaction, final native solve, one-request-per-possession/no-ambiguous-retry rule, current-context release checks, animation ownership and cleanup are retained. Threshold and other games are outside this repair. Rewriting those working components would not address the report's decision failure.

## Remaining uncertainty

- Some native CoverageJump outputs in the report differ horizontally from the recorded aimpoint by about 0.65–0.72 studs, exceeding the existing 0.05 arithmetic allowance. The original paid-source attachment is no longer present in this workspace; preserved audits do not establish an exact equality bound for every Power/SmartPass iteration. B4 does not fabricate a larger verified tolerance. Those tuples can still be refused.
- Defender reach, instant-turn pursuit, route continuation and catch-height mechanics remain uncalibrated. A release is model-admitted, not guaranteed catchable.
- Later receiver movement, replicated ball time and observed interception do not uniquely identify a bad lead, receiver error or server delay.
- Executor scheduling, actual normal-jump availability, camera projection, live native solver compatibility and mobile frame time require live verification. Synthetic timings are not iPhone measurements.
- Diagnostics have bounded history and file sizes. Explicit unique-file export depends on executor APIs. An old overwritten alias cannot recover missing earlier flags.

Historical tags remain immutable for comparison. Raw gameplay reports, account credentials, API keys and private source attachments are not part of this repository.
