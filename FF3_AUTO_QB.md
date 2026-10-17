# FF3 Auto QB V24.1

V24 removes the V23 team-stat integration and strict jump-peak requirement. The regular loader pins `ff3-v24.1` / `PELICAN_FF3_V24`.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/loader.lua"))()
```

## V24.1 correction and evidence

The supplied V24 report proves zero automatic jump requests, zero throw attempts, zero requests sent and no prepared release. LOS and ground were valid. It does **not** establish a jump-peak failure in that session. The recorded `MANUAL_LOCK_COVERED` gate occurred 15 times. A native Throw animation was observed later; that observation is not proof that Pelican submitted a throw or that a server accepted it.

Two retained Dime/Jump rejections show horizontal arrival-to-aim differences of approximately 0.032 studs, calculated from coordinates rounded to three decimals. The V24 check used `max(0.01, horizontalRange*0.0001)` and rejected these native outputs. Their larger Y differences are separate native vertical leads, already excluded from that horizontal check. The report omits launch points/velocities, exact arithmetic and covered candidate/defender snapshots, so it cannot prove why the residual arose, whether the passes were catchable, or why every Bullet/Fit candidate was held.

## Focused implementation

V24.1 uses `max(0.05, horizontalRange*0.0001)` as an explicit narrow arithmetic policy. This allowance covers the observed small residuals; it is not a measured FF3 catch radius or a claim of calibrated mechanics. The solver's actual velocity/flight time/ballistic arrival remain unchanged. Receiver reach, field bounds, defender path/arrival margins and safety checks still evaluate that actual arrival. Larger inconsistencies remain rejected. No coverage, catch-height, movement, AFK, mode-preference or release thresholds are relaxed.

The last eight blocked-decision snapshots preserve the reason, possession/time, native trajectory, candidate comparisons, limiting lane/arrival defender and actual receiver/defender observations. Consecutive identical decision keys are limited to one snapshot per second. Stop, dead play, lock release and COPY retain those snapshots even when the current comparison cache is cleared. This adds bounded report work and no additional native solves or physics sampling.

Native endpoint rejects now retain exact error/tolerance/epoch and are labelled historical rejections. Small residual acceptance has a separate arithmetic-only receipt. `LAST_ACTION_SOURCE` distinguishes `AUTO_QB`, `MANUAL_AWAY` and `NATIVE_ANIMATION_OBSERVED; REQUEST_NOT_PROVEN`; possession ending does not erase that source. An observed native animation still retains existing one-attempt ownership protection.

AWAY remains always visible. Stats remain removed. Deep throws request a normal jump and immediately run final native checks without a peak wait. Manual blacklist, AFK rejection, Goal LOS-only exemption, RUN guidance, report preservation and X reload remain. Other games are unchanged. The loader pins `ff3-v24.1`; controller contract stays `PELICAN_FF3_V24`, with `RELEASE_VERSION|ff3-v24.1` identifying this patch.

## Validation and limits

496 current mocked assertions pass: new endpoint/evidence tests 34 plus the 462 current V24 checks for jump/release, AWAY, Goal, reload, LOS, ground, error handling, loader and rebuilt bundle. The new synthetic regression uses the reported small horizontal differences with an otherwise safe trajectory: archived V24 rejects it while V24.1 proceeds. Other cases keep a close defender blocked, reject 0.051/0.1/10-stud inconsistencies, retain blocked snapshots after dead play/stop and distinguish an observed animation from an actual requested throw. The original V24 source/report are preserved privately. A full live scene cannot be reconstructed from this report.

These tests prove the local arithmetic/rejection changes, not live completions. It remains uncertain whether the coverage model is too conservative in this session, whether the native animation observation was a manual throw, and whether correcting the small endpoint rejects is sufficient for the user's missed opportunities. Native physics, catch behavior and iPhone performance remain unverified. No Roblox live throw or currency-spending tests were run. Do not describe V24.1 as an established complete fix for all zero-attempt cases.

## Controls and passing

**AWAY** is a separate, always-visible 54×22 button beside the collapsed status bar. Opening the menu is no longer required. Expanding/collapsing the menu does not hide it. It shares confirmed stop/reload cleanup with the QB controller. Its manual-only action, native animation discovery, one-attempt possession reservation, field checks and modeled high boundary exit are unchanged. Actual flight and intentional-grounding treatment remain unverified; high aim is not a guarantee against grounding.

For a safe deep candidate, Auto QB requests the normal Humanoid jump and uses ChangeState(Jumping) where available, then starts the discoverable native throw animation and immediately performs the final native solve/safety checks and release. There is **no ascent, peak, animation-progress or jump-observation timer**. Short passes stay immediate and do not request a jump. The existing flight-time versus normal-jump-airtime classification is retained; no fixed deep yardage cutoff is added.

Already-airborne/pending user jumps do not need another jump. Disabled or unobserved jumping does not block an otherwise safe pass. A genuine API exception still stops and preserves the report. The owned Jump flag remains available to the following physics turn and is cleaned when consumed or on the next heartbeat/stop; no velocity, jump-power, gravity or anti-cheat changes are made. Actual jump visuals and server release timing must still be checked on iPhone. This requests a jump before release; it does not claim an observed elevated launch.

The final calculation still checks current receiver movement, team, manual blacklist, catchability, defender trajectory and coverage, possession, native manual-throw ownership and AUTO/THR controls. A receiver stopping/cutting or a defender entering the window during the final solve cancels the pass. A cancelled native solve clears its preparation/cache without excluding that receiver for the rest of the possession, so later safe windows can be reconsidered. Turning AUTO/THR off or blacklisting during that solve now cancels cleanly instead of dereferencing a cleared sequence.

**Stats are removed from the active controller and bundle:** no TEAM button, stat reads, stats-based receiver blocks, game-stats button invocation or automatic team exit. Old TeamStats options and evidence are ignored. Manual WR LIST exclusions remain. Previous instances are stopped with confirmed cleanup; separate old recorder instances are stopped rather than required. Original V23 source is archived privately and the immutable public V23 tag preserves its release.

Safe receiver/mode selection, short-completion preference, AFK protection, native settings restoration, Goal's LOS-only exemption, COPY, X reload and the advisory RUN arrow remain. Prediction-only guidance no longer schedules speculative jumps. It never moves the QB or authorizes/delays a throw. Keep Yuna QB Aimbot ON, Mouse Aimbot OFF and Auto Throw Type ON; Yuna startup automation remains cancelled. Practice and Threshold routes are unchanged.

## Evidence and validation

The V23 code explicitly gated deep release on an observed peak, stopped on an unobserved jump and could miss the opportunity while waiting. A synthetic regression reproduces a safe window disappearing before that peak: preserved V23 sends zero requests while V24 sends during the opening. This establishes the code-level regression in that fixture, not the cause of every missed live throw. The previous `TEAM WR` label identified the parsed page; it did not establish that automatic exclusions or leave criteria had been met. The user reports that live stats behavior was ineffective; it has been removed rather than retuned.

**Preserved V24 validation: 462 mocked assertions passed:** jump/immediate release/stats removal 53, manual AWAY 35, X reload 9, Goal LOS-only exemption 63, active-play timeout/reporting 25, LOS discovery 66, ground/native recovery 28, error-stop 12, loader/config 116 and rebuilt bundle 55. The 53 new checks include old-versus-new regression, no-observed/disabled jumps, same-frame jump ownership, final-solve route/coverage/control cancellation, AFK rejection, old stats configuration and future-only guidance. Error-injection warnings are expected. Another 138 historical assertions pass against archived V23, not the current release. Lua 5.4 parse/run validation is available; a native Luau compiler and Roblox runtime are not.

No live Roblox, currency-spending or real Kick tests were performed. Actual game acceptance, jump/throw animation appearance, catch quality, grounding and mobile performance remain unverified. COPY preserves the current report; X preserves the previous loader report before confirmed cleanup/reload. Copy before quitting Roblox. API acceptance is not proof of an in-game throw or iOS clipboard readback.
