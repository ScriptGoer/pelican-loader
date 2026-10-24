# Experimental unified Auto QB — Build B1

This branch adds an isolated local evaluator. Production `loader.lua`, its
V26.22 pin, and `games/ff3/auto_qb.lua` remain unchanged from main c9cc9ea.
No ML, cloud decision service or arbitrary target-coordinate solver is used.

## Launch / return to production

Start Yuna normally with QB Aimbot ON, Mouse Aimbot OFF, Auto Throw Type ON.
In the observed FF3 live place, run:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/experimental-unified-qb/experimental/loader.lua"))({
    FF3 = { RiskMode = "TRUST", PassPlan = "NORMAL" }
})
```

The experimental loader uses the existing loader/controller ownership namespaces
and confirmed Stop cleanup. Launching it replaces the previous controller;
cleanup failure prevents stacking. X reload fetches this experimental loader.
To revert, execute the regular main loader again:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/loader.lua"))()
```

Expand the HUD and use THR OFF to inspect selection without automatic passing.
COPY exports the usual report. `RELEASE_VERSION|experimental-unified-b1` confirms
the active build. `UNIFIED_DECISIONS` contains at most 48 current evaluated
candidates, their actual native flight/power, age, evaluation and winner/loss
reason. Ordinary state/readiness/solver failures retain the existing diagnostics.
It is a bounded latest-decision view, not a permanent exhaustive match log.
Throw/blocked history includes `Unified`; report includes parameters, evaluator
maximum duration, checks, existing native-call/frame/heartbeat measurements.

## Implementation

`decision_engine.lua` is the source evaluator, embedded in the isolated runtime
by `python3 scripts/build_experimental.py`. The generation script performs no
production writes: it only writes `experimental/auto_qb.lua` and its loader.
The baseline source must remain V26.22 when regenerating.

The runtime replaces risk grading, throwable, mode/receiver ranking and the
old Fit/Jump counterfactual gates. It removes incumbent label/depth priorities,
minimum-flight comfort vetoes and categorical high-safety vetoes from selection
and final release. Fresh final native solve, actual arrival/reach, field/LOS,
manual ownership, possession, one-attempt and cleanup checks remain. The native
`solve(player,mode)` function is byte-identical to production. Existing supported
lead/arc/power generation is reused; its limitations remain. Mag trials retain
manual/friend eligibility. No automatic QB jump is added based on flight duration;
user-started jump timing remains. A native Jump variant can still be selected
when its measured trajectory wins; its name does not establish required catch action.

Every candidate uses the same bounded-acceleration pursuit model. Both observed
momentum and a reaction delay affect predicted access. Defender endpoint pursuit
and ball pursuit are examined, with closest relative segment approaches between
16 integration steps. Vertical accessibility uses an inherited envelope. Overlap
with the receiver's catch neighborhood receives continuous contest relief only
when current AND projected route positioning favor the receiver. Multiple threats
are pooled as a bounded risk cost. None of these costs are probabilities.

Catch difficulty includes relative arrival velocity, head-relative height,
route adjustment, additional modeled response adjustment and excessive flight.
Score = downfield yards + touchdown bonus - risk weight * risk cost - comfort
weight * catch difficulty. This is an application ranking, not calibrated expected
points. Among eligible candidates, modes share that score. Risk eligibility alone
uses nested caps SAFE .16 / MOD .32 / TRUST .58. Defaults and all assumptions are
explicitly exposed through `FF3.Unified`, e.g.:

```lua
FF3 = { RiskMode="TRUST", Unified={ Samples=16, Acceleration=36,
    ReactionSeconds=.12, PositionUncertainty=.35, VelocityUncertainty=.5,
    HorizontalReach=4.5, VerticalReach=12.2, ContestRelief=.75,
    DistanceScale=1.5, SafeRisk=.16, ModRisk=.32, TrustRisk=.58,
    RiskWeight=70, ComfortWeight=8, TouchdownValue=45 } }
```

These are UNCALIBRATED assumptions; reach/response values are not verified FF3
mechanics. Config rejects unknown/invalid values, non-nested caps and samples
outside 4..32. NORMAL has no depth restriction. DEEP permits deep/end-zone throws;
SHORT is explicitly short-only. Those plan restrictions are separate from risk
and identical across risk modes. Receiver readiness/team/AFK exclusions remain.

Native planning retains the existing cadence, frame-call cap and time allowance.
A cheap end-zone arrival hint can prioritize a challenger while oldest-visit
fairness overrides it after cache age. A separate 3-ms soft grading budget rotates
receivers and variants to avoid permanent starvation. One synchronous grade can
overrun the allowance. No iPhone timing guarantee is made.

## Validation and comparative findings

Run `python3 tests/experimental/test_engine.py`,
`python3 tests/experimental/test_integration.py`, and
`python3 tests/test_trust_burn.py`. Requires Python and liblua5.4; no Roblox,
external service, paid source or third-party Python package is required.

51 comparative assertions pass. Tests execute the real legacy grader/rankers and
experimental evaluator/scheduler against constructed ballistics. They do NOT
prove that the current native helper will emit every fixture or that a real
receiver will catch it. 19 integration/source contracts pass, including identical
native solver, fresh release/state guards, eight-call cap, isolated ownership,
experimental reload routing, production pin and deterministic regeneration.
These contracts are not a complete simulated Roblox lifecycle test.
The existing 51 Trust checks and 144 SAFE/MOD differential scenes also pass.

| Scenario | V26.22 fixture | Build B fixture |
|---|---|---|
| Open scoring receiver; distant midfield safety | Faster flight preference remains | Comfortable scoring trajectory wins |
| Gentle 1.0 s vs fast .65 s, both open | Fast | Gentle |
| Natural 1.0 s vs excessive 3.0 s float | Natural | Natural |
| Four-stud isolated trail | TRUST accepts | TRUST accepts; MOD declines |
| Near boundary 3.9 / 4.0 / 4.1 | Reject / accept / accept | TRUST accepts all; risk .346 / .355 / .364 |
| Slight closing from four studs | Rejects four-stud exception | TRUST accepts |
| Rapid closing | Reject | Reject |
| Nearby safety moving into window | Reject in tested legacy scene | Reject |
| Same location, defender moving toward vs away | Both legacy rejects in fixture | Toward rejects; away accepted |
| Underneath interception | Reject | Reject |
| Unreachable reversal | Necessary movement bound rejects | Hard movement rejection |
| Brief scoring hint among six receivers | Next visit goes to older short receiver | Scoring hint gets next visit; stale receiver retains fairness |
| Scoring candidate vs shorter eligible pass | Shorter wins | Scoring candidate wins |

Initial model testing failed the four-stud case because it allowed defenders to
react but kept receivers on a rigid continuation. Symmetric bounded receiver
response fixed that inconsistency. A subsequent approaching-safety counterexample
failed because projected trailing position received relief despite initially
being ahead; relief now uses the weaker current/projected advantage. Both
regression cases remain in tests. Final suites report zero assertion failures.

### Remaining counterexamples / uncertainty

In the low-arc burn fixture, seven studs of separation gets a HIGHER risk cost
(.536) than four (.355): the ball encounters the trailing defender earlier while
farther from the receiver. Both remain TRUST-eligible, but this can reverse their
relative ranking. We have NOT established whether that ordering matches FF3.
This is a documented model limitation requiring controlled trajectory/catch tests,
not evidence that more separation is intrinsically worse.

The model assumes humans can recognize and adjust toward the ball after the
configured delay. It lacks authoritative catch-input, reaction and hitbox data.
Vertical reach is not a timed jump simulation. Segment pursuit/height checks
approximate nonlinear motion; acceleration, intent and uncertainty need live
calibration. Standing/jump necessity cannot be inferred from mode labels alone.
No real completion, interception or touchdown improvement has been measured.

Desktop Lua-table vector emulation took roughly 2–3.3 ms per three-defender
candidate over 1,000 iterations in observed runs; maximum samples varied around
6–12 ms, with scheduling outliers as large as approximately 0.38 seconds across runs. This includes model overhead
and emulated-vector allocations, not native Roblox vectors or native solver time.
A representative final run had median 2.49 ms, p95 5.07 ms and p99 7.61 ms
for the emulated evaluator. It neither proves nor disproves acceptable iPhone performance. Full runtime
latency, thermal behavior, p95/p99 frames, and native call cost require device
measurements. Lower Samples is configurable, with a fidelity tradeoff.

## Build C

First collect native candidates and real ball/catch outcomes for these scenes.
Identify whether the best supported candidate still requires an awkward catch,
lands outside the useful end-zone space, or fails despite a reachable adjacent
placement. Then investigate an explicit point-target adapter; the existing native
wrapper does not provide one. Expanded catch locations/arrival times should use
this same evaluator and be compared against Build B with identical observations.
ML and remote processing remain out of scope. Validate model calibration before
expanding the search: more candidates cannot repair wrong catch mechanics.

## B2 BAD PLAY evidence

Press **BAD PLAY** after a bad throw. It pins the latest attempted possession
within 45 seconds, even after the planner advances. Otherwise it selects the
recent closed/current possession. The label shows the pinned ID. To deliberately
flag the current withheld possession, use `getgenv().PELICAN_FF3_AUTO_QB.bad:flag(os.clock(),true)`.
BAD PLAY attempts clipboard/file export immediately. After the play settles,
press COPY or DATA to re-export the SAME pinned play with late observations.
The latest export is saved as `PELICAN_FF3_BAD_PLAY.json` when writefile is available.
Clipboard API acceptance cannot establish that iOS clipboard readback worked.
No automatic upload is introduced. The pinned report also survives an ordinary
reload in executor session memory. Full app exits require the exported file.

Reports carry anonymous per-session actor tokens, exact evaluator inputs/results,
current model parameters and a SHA-256 source-input fingerprint (CodeId), plus
EngineId. Native tuples include origin, velocity, arrival, time, power, lead and
control metadata. Planner snapshots and final-release recalculation are separate;
QB/field/settings are retained at release. Non-evaluated candidates carry explicit
budget/cache/scheduling reasons. Native solve status is separate from grading.
Observations retain their original evidence/unknown labels; no fault or required
catch technique is inferred. Obsolete numeric coverage placeholders are marked
inactive and omitted from structured per-shot fields.

Memory retains three recent possessions, two planner snapshots each, at most 128
candidate rows per snapshot, and one pinned report. Dropped-frame/row counters
identify incomplete evidence. Actor identities are capped at 256 tokens. Export
has a 1.5 MB bound; an oversized report is retained in memory and reports a size
error instead of claiming a complete export. Credentials are never collected.

Replay locally with `python3 scripts/replay_bad_play.py PELICAN_FF3_BAD_PLAY.json`.
Replay validates EngineId and recomputes recorded evaluator inputs and candidate
selection order. Missing final inputs, malformed snapshots, score mismatches and
version mismatches return nonzero status. It does not rerun the native solver,
recreate unobserved candidates or reproduce authoritative server catches.
A saved report's CodeId identifies the baseline, generator, engine and recorder
source inputs; it is not falsely presented as a Git commit SHA.

The 3-ms grading budget is a cooperative limit; one synchronous grade can exceed
it. Counters record skipped work, grades above budget, capture overhead and native
calls. Heartbeat intervals and callback-duration maxima distinguish the whole
observed frame interval from this callback's elapsed work. These are live telemetry,
not proof that this script caused every frame spike. JSON encoding/disk/clipboard
work occurs on user export, never per candidate. Snapshot copying has a measurable
cost and participates in the current budget; inspect skip rates on the device.

Run `python3 tests/experimental/test_bad_play.py` for delayed flagging, immutable
snapshots, final/planner separation, late observation attachment, ring eviction,
anonymous export, JSON CLI round-trip and missing/corrupt/version evidence tests.
The production entry and V26.22 module remain unchanged. No parameter adaptation
or deep-throw behavior changes are included in this diagnostics update.
