# FF3 Auto QB V24

V24 removes the V23 team-stat integration and strict jump-peak requirement. The regular loader pins `ff3-v24` / `PELICAN_FF3_V24`.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/loader.lua"))()
```

## Controls and passing

**AWAY** is a separate, always-visible 54×22 button beside the collapsed status bar. Opening the menu is no longer required. Expanding/collapsing the menu does not hide it. It shares confirmed stop/reload cleanup with the QB controller. Its manual-only action, native animation discovery, one-attempt possession reservation, field checks and modeled high boundary exit are unchanged. Actual flight and intentional-grounding treatment remain unverified; high aim is not a guarantee against grounding.

For a safe deep candidate, Auto QB requests the normal Humanoid jump and uses ChangeState(Jumping) where available, then starts the discoverable native throw animation and immediately performs the final native solve/safety checks and release. There is **no ascent, peak, animation-progress or jump-observation timer**. Short passes stay immediate and do not request a jump. The existing flight-time versus normal-jump-airtime classification is retained; no fixed deep yardage cutoff is added.

Already-airborne/pending user jumps do not need another jump. Disabled or unobserved jumping does not block an otherwise safe pass. A genuine API exception still stops and preserves the report. The owned Jump flag remains available to the following physics turn and is cleaned when consumed or on the next heartbeat/stop; no velocity, jump-power, gravity or anti-cheat changes are made. Actual jump visuals and server release timing must still be checked on iPhone. This requests a jump before release; it does not claim an observed elevated launch.

The final calculation still checks current receiver movement, team, manual blacklist, catchability, defender trajectory and coverage, possession, native manual-throw ownership and AUTO/THR controls. A receiver stopping/cutting or a defender entering the window during the final solve cancels the pass. A cancelled native solve clears its preparation/cache without excluding that receiver for the rest of the possession, so later safe windows can be reconsidered. Turning AUTO/THR off or blacklisting during that solve now cancels cleanly instead of dereferencing a cleared sequence.

**Stats are removed from the active controller and bundle:** no TEAM button, stat reads, stats-based receiver blocks, game-stats button invocation or automatic team exit. Old TeamStats options and evidence are ignored. Manual WR LIST exclusions remain. Previous instances are stopped with confirmed cleanup; separate old recorder instances are stopped rather than required. Original V23 source is archived privately and the immutable public V23 tag preserves its release.

Safe receiver/mode selection, short-completion preference, AFK protection, native settings restoration, Goal's LOS-only exemption, COPY, X reload and the advisory RUN arrow remain. Prediction-only guidance no longer schedules speculative jumps. It never moves the QB or authorizes/delays a throw. Keep Yuna QB Aimbot ON, Mouse Aimbot OFF and Auto Throw Type ON; Yuna startup automation remains cancelled. Practice and Threshold routes are unchanged.

## Evidence and validation

The V23 code explicitly gated deep release on an observed peak, stopped on an unobserved jump and could miss the opportunity while waiting. A synthetic regression reproduces a safe window disappearing before that peak: preserved V23 sends zero requests while V24 sends during the opening. This establishes the code-level regression in that fixture, not the cause of every missed live throw. The previous `TEAM WR` label identified the parsed page; it did not establish that automatic exclusions or leave criteria had been met. The user reports that live stats behavior was ineffective; it has been removed rather than retuned.

**462 current mocked assertions passed:** jump/immediate release/stats removal 53, manual AWAY 35, X reload 9, Goal LOS-only exemption 63, active-play timeout/reporting 25, LOS discovery 66, ground/native recovery 28, error-stop 12, loader/config 116 and rebuilt bundle 55. The 53 new checks include old-versus-new regression, no-observed/disabled jumps, same-frame jump ownership, final-solve route/coverage/control cancellation, AFK rejection, old stats configuration and future-only guidance. Error-injection warnings are expected. Another 138 historical assertions pass against archived V23, not the current release. Lua 5.4 parse/run validation is available; a native Luau compiler and Roblox runtime are not.

No live Roblox, currency-spending or real Kick tests were performed. Actual game acceptance, jump/throw animation appearance, catch quality, grounding and mobile performance remain unverified. COPY preserves the current report; X preserves the previous loader report before confirmed cleanup/reload. Copy before quitting Roblox. API acceptance is not proof of an in-game throw or iOS clipboard readback.
