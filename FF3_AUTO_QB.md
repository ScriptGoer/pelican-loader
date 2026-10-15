# FF3 V19: release a clear burn without waiting for jump or yardage

The supplied V18 report proves the controller stopped on `AUTO_JUMP_NOT_OBSERVED`, with zero automatic requests, after preparing a 31.69-yard target. LOS and ground were accepted, the scan had completed and native mode discovery worked. The controller requested one jump and did not observe upward motion. This establishes the failing release gate; it does not establish why the normal Jump flag failed on that character/executor. There were also Dime/Jump native-arrival mismatches in the report, which remain independent unverified solver-output concerns. Their checks are not loosened to manufacture a throw.

The user's replacement policy is an open burn with no safety: release before help arrives; existing safety help means no elevated burn. V19 removes the V18 automatic jump request, ascent/peak observation, jump timeout and 30-yard release cutoff entirely. They cannot block or stop this version. The previous sources and original supplied report are preserved privately, with checksums.

## Behavior

The controller evaluates the existing native Bullet/Fit/Dime/Jump outputs. A forward-running eligible teammate with a catchable native arrival ahead of their route, clear path/arrival checks and no over-top help becomes a clear-burn candidate. There is no minimum pass distance. It can be an on-axis burn; wide lateral separation is not required.

Over-top help is a defender ahead of the receiver in the downfield route corridor. The corridor includes the defender's possible lateral running distance over the candidate's actual flight time plus the inherited horizontal-reach estimate. A far opposite-side defender who cannot reach that corridor is not automatically a safety. A defender behind or underneath can still invalidate the actual ball path through the existing risk calculation. A front safety suppresses elevated native Fit/Dime/Jump burn attempts; an independently safe Bullet underneath remains available through ordinary completion policy.

A validated no-safety burn takes priority over a short lateral incumbent. It bypasses the two-second development hold, 0.24-second safe-window hold and cosmetic animation windup. The existing native Throw animation starts when an asset is available, but the ball is released without waiting for that animation to reach 0.19 seconds. Final receiver/defender observations, native solve and coverage checks still occur immediately before the one allowed request. If safety help arrives, or the catch/lane becomes unsafe, the fast attempt cancels. Updated position/velocity are read even when observation refresh occurs twice at the same tick timestamp.

Ordinary non-burn completions retain stable short-pass preference and their previous pacing/animation behavior. Live human teammate restriction, blacklist, AFK/movement observation, verified LOS/downfield/field bounds, manual/native throw ownership, no ambiguous retry, protected native mode settings and genuine-error stop/report handling remain. No jump power, velocity, gravity, aim offset, animation ID, anti-cheat or anti-tamper change is introduced. The obsolete `FF3.DeepThrowYards` option is ignored. `FF3.ReceiverSwitchYards` remains supported.

Clear-burn classification is geometric and predictive, not knowledge of the server's authoritative catch outcome or an opponent's assigned position. Its pursuit, reach, receiver-bound and native-physics assumptions remain uncalibrated. No safety at one instant is not proof that no defender will react later. The final path is rechecked; a bad native tuple is never forced simply because a receiver is running forward. Reports include current clear-burn/safety flags, actual release classification and bounded Dime/Jump arrival-versus-native-aimpoint mismatch receipts for future evidence.

## Run and rollback

Keep Yuna QB Aimbot ON, Mouse Aimbot OFF and Auto Throw Type ON. Use the normal multi-game loader:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/loader.lua"))()
```

The FF3 live route pins `ff3-v19`, controller `PELICAN_FF3_V19`. Other game routes, runtime modules, optional mobile jump-button helper and historical diagnostics are unchanged. The tiny HUD and report controls remain. The user-reported working V17 is still available through its matching immutable loader:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/ff3-v17/loader.lua"))()
```

## Validation

The 35 new actual-controller synthetic assertions exercise the exact failed integration condition (a Jump request would produce no ascent) while proving V19 never requests jumping, releases valid same-axis native Dime burns before the old two-second hold and without animation delay, behaves identically below the old 30-yard boundary, blocks an over-top safety, ignores unreachable opposite-side help, prioritizes a burn over a short lateral option, cancels when a safety enters between preview and release, preserves ordinary completion pacing and retains blacklist/AFK/LOS/manual/menu/AUTO gates and frame budgets.

The archived V18 suite remains pinned to the preserved V18 source, rather than being rewritten to pretend its jumping is current behavior. Current timeout (25), LOS (66), ground recovery (28), error-stop (12), loader/config (89) and bundle initialization/cleanup (55) assertions pass; historical V17 (89) and V18 (68) assertions pass separately. Native Luau compilation, exact source/report preservation and unchanged-module checks pass. These are local synthetic checks, not a Roblox runtime test, completion-rate measurement or iPhone performance guarantee. Live no-safety burn timing, mode catchability, safety classification, native animation visibility and existing solver mismatch causes remain unverified. No paid source is executed or republished; private gameplay reports and test fixtures are excluded from public runtime.
