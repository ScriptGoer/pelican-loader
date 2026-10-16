# FF3 V21: observed deep jump peaks and an advisory run arrow

V21 restores automatic jumping and observed peak release for deep throws, as the user explicitly requested. If the receiver sells the burn during preparation, the pending pass is cancelled. A separate small RUN arrow suggests parallel QB movement only when the current eligible receiver is covered but a short continuation predicts an opening. The arrow never authorizes a release or makes the throw wait for movement.

## Deep jump and cancellation

The original V18 report established one requested jump, no observed ascent and zero automatic requests. It did not establish why the normal Jump property did not produce ascent. V21 uses the normal local Humanoid Jump request and, when available, `ChangeState(Jumping)`, while respecting grounded/seated/platform and enabled-jump state. It changes no jump power, velocity, gravity, speed, anti-cheat or native input hooks. Availability of a standard API does not prove the actual executor/game accepts it.

There is no new 30-yard cutoff or minimum-yardage release gate. For this policy, a throw is treated as deep when its native flight time exceeds this character's estimated normal jump airtime, derived from actual Humanoid jump settings and workspace gravity. Missing jump parameters conservatively place elevated native modes behind peak release. This is a character-dependent timing policy, not an official FF3 deep-pass definition or server catch calibration. Reports label the policy explicitly.

A deep candidate initiates a normal jump if needed, then observes actual airborne ascent and the vertical-velocity sign crossing on Heartbeat. Release requires the observed upward-to-downward peak, within 0.10 seconds of its interpolated observation. The final native solver runs from the QB's actual elevated position. If a final solve changes a short trajectory into a deep one, it cannot slip past the peak requirement. Animation starts without a separate windup wait. Ordinary short completions still release immediately after their existing checks.

While preparing, the controller checks the WR's actual movement every Heartbeat and rechecks native trajectory/coverage at the existing 0.12-second decision rate. Stopping, reversing, or cutting at least 45 degrees from the prepared route cancels that pass. The angle is an explicit cancellation policy, not a game catch threshold. Changed observations, lost receiver reachability, a defender entering the lane/arrival, lost burn classification, a missed/stale peak or failing final checks also cancel. The cancelled receiver is blocked from another automatic attempt for that possession, while eligible manual targeting and other receivers remain available. A safe short alternative can replace a pending deep attempt. Final receiver/defender observations are refreshed after the native solve, and the route is checked again immediately before requesting release.

Only one automatic jump is requested per possession. A predictive jump may start earlier when a covered receiver's forecast suggests an approaching window; it does not authorize a throw. A normal requested jump with no observed ascent for one second stops the controller and preserves `AUTO_JUMP_NOT_OBSERVED`. It never silently substitutes a ground deep throw. Disabled normal jumping cancels preparation. Unowned/unobserved jump readiness is bounded instead of waiting indefinitely. A missed peak is cancelled rather than forced on the descent. AUTO/THR off, menu opening, kill, blacklist, changed character, possession and native/manual ownership cancel owned pending work. Cleanup restores an unconsumed owned Jump flag; it does not force an airborne character to land.

## Run-direction guidance

The tiny center RUN arrow appears only for a currently covered, eligible receiver with a predicted passing window. It points parallel to that receiver's observed horizontal movement, transformed into camera-relative screen direction. It is an instruction about QB running direction, without a receiver name. It never moves the character or controls the camera.

Forecasting reuses the selected native trajectory. At 0.25, 0.50 and 0.75 seconds ahead, it estimates receiver/defender continuation and a QB moving parallel at the current Humanoid WalkSpeed, translates the prospective trajectory, then checks field/LOS bounds and the same defender path/arrival estimates. Infeasible or over-power estimates are rejected. It does not perform extra native solves or exhaustive per-frame player/throw searches. Only the current covered candidate is forecast, after release work, with a one-millisecond planning budget checked between horizons. The budget cannot preempt a single in-progress Lua risk calculation and is not a phone performance guarantee.

Already-open opportunities hide the arrow and use the ordinary throw pipeline. The guide cannot hold a throw, wait for the QB to follow it, override targeting, or trigger release from a predicted future window. Deep throws wait only for the separately requested observed jump peak and fresh actual passing checks. Camera rotation updates the arrow without recomputing native trajectories. Stale predictions expire after 0.35 seconds; invalid context hides them. No confident forecast means no arrow.

These forecasts assume briefly constant player velocities and a continuation of an existing native trajectory. They do not establish a new authoritative native throw solution, guarantee a receiver will keep the route, or model all rushing/contact/collision outcomes along the recommended QB run. Fresh real observations and native calculations remain release requirements. `GUIDE_TARGET`, estimated opening delay, visibility, forecast work, jump API/status, peak and actual request details are retained for diagnosis.

## Usage and retained behavior

Keep Yuna QB Aimbot ON, Mouse Aimbot OFF and Auto Throw Type ON. The live route pins `ff3-v21`, contract `PELICAN_FF3_V21`:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/loader.lua"))()
```

Movement guidance and predictive jump preparation default on. To hide the arrow or disable early jump preparation independently:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/loader.lua"))({
    FF3 = { MovementGuide = false, PredictiveJump = false }
})
```

`PredictiveJump=false` disables jumping ahead of a forecast; it does not disable the requested deep peak requirement or the normal jump initiated once a deep opening is selected. `ReceiverSwitchYards` remains supported; historical `DeepThrowYards` stays ignored.

AFK protection, continuous movement/travel observation, human teammate/team/blacklist rules, field/native arrival checks, native mode/setting restoration, receiver stability, short-completion preference, one throw attempt per possession and genuine-error reporting remain. Goal-to-go still bypasses only LOS-derived gates; Auto QB and AFK/coverage checks continue. Deep peak timing also applies during Goal. Practice, Threshold, mobile jump-width helper and historical diagnostics retain their versions and source bytes. COPY reports before leaving Roblox.

The matching immutable rollback is `ff3-v20.2/loader.lua`, which has Goal LOS-only bypass and immediate deep release without jumping. V18, V19, V20.1 and V20.2 sources/reports and historical suites remain preserved privately. Paid source, original attachments, reports, test fixtures and fabricated test animation IDs are excluded from the public runtime.

## Validation and limits

The new actual-controller suite passes 66 mocked assertions covering predicted-only arrows, camera-relative parallel direction while the QB moves opposite, unchanged already-open short release timing/mode/native-call count versus V20.2, no extra native calls for covered forecasts, no arrow when coverage does not improve, normal ChangeState simulation succeeding where a property-only simulated jump fails, actual elevated peak release, already-open deep jumping, Goal coexistence, stopped/reversed/cut routes, closed coverage, controls/blacklist/kill cancellation, missing/disabled jump behavior, AFK rejection, pending Jump restoration, genuine API errors, changes during the last native calculation, stale peaks and frame-call limits.

Current Goal (63), timeout (25), LOS (66), ground recovery (28), error-stop (12), loader/config (89) and bundle initialization/cleanup (55) assertions pass. Historical V17 (89), V18 (68), V19 (35), V20.1 (37) and V20.2 responsiveness (62) suites pass against their preserved sources. Native Luau compilation, exact baseline preservation, generated bundle and unchanged unrelated runtime modules pass.

No live Roblox execution or currency-spending test was performed. A local mock of normal jumping does not establish that this FF3 character/executor will jump; V18's original failed integration remains the reason live ascent needs checking. Authoritative catch windows, defender reach/pursuit assumptions, future-opening accuracy, visibility of the native Throw animation, exact phone input layout and real mobile performance remain unverified. This release claims an implemented and locally exercised decision/lifecycle path, not proven in-game catches or natural-looking animation.
