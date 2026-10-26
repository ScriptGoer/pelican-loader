# B3.7 repair validation

Production comparison: `main` at `c9cc9ea5350d6b49dfe9d3282432d9b0ecc7ef95` (V26.22).
Original engine comparison: `4a4689b`; diagnostics-only B2: `614550d`.

The repair modifies only `experimental/`, its build/replay scripts, and `tests/experimental/`. The source/isolation test compares every production baseline file byte for byte. No live Roblox, chat, currency or cloud-history action was performed.

| Suite | Checks passed |
| --- | ---: |
| Actual repaired-controller/native-shaped runtime contracts | 144 |
| Comparative V26.22 / Build B / B3 constructed scenes | 77 |
| Source isolation, solver preservation and deterministic generation | 69 |
| BAD report retention, privacy and replay | 24 |
| Adaptive native angle and error cleanup | 95 |
| Friends filter | 67 |
| Conditional native receiver Jump | 42 |
| Shared casual/league coverage | 42 |
| League screens, profiles, UI and cleanup | 106 |
| Unchanged production TRUST burn regression | 51 |
| Unchanged production SAFE/MOD differential matrix | 144 |
| Presentation controls and oscillating receivers | 30 |
| Sparse replication and low placement comparisons | 17 |
| Jump state machine and coverage-label regressions | 19 |
| Native exposure versus catch-height ranking | 24 |
| **Total asserted checks/scenes** | **951** |

Additional validation:

- B3.7 reproduced 17 inputs from a private B3.6 low-deep gameplay capture against its exact historical source. A private counterfactual of the recorded candidates changes Bullet to Dime when the existing clearance-debt metric precedes height comfort. No native/server outcome is rerun, and raw telemetry is excluded from this repository.
- Twenty-four new ranking checks include actual old/current controller release comparison, preserved configured/native Dime lead, EASE ON/OFF, unchanged wide-open flat preference, high-safety restrictions, SAFE refusal and admission-before-cost ordering. The underlying interception model remains uncalibrated; the unthrown Dime is not claimed to have succeeded.

- B3.6 flags and saves four independent reports, verifies distinct filenames and byte-preservation of the first file, retains all four in session memory, and checks the reported version. Existing single-report replay and historical replay remain compatible. Executor disk behavior is still unverified on iPhone.

- A newly supplied private B3.4 live BAD report reproduced 33 recorded evaluator inputs and 33 analytic risk inputs using the exact immutable B3.4 source. It recorded an ordinary Bullet, successful jump/release and an observer-reported receiver possession. It does not establish required movement, fault attribution or the cause of separate missed opportunities. Raw user telemetry is excluded from the repository.
- B3.5 compares the old/current controllers through a safe 79-degree route turn after takeoff: the old controller cancels based on direction, while the rewritten controller uses fresh geometry without cancellation. The current controller uses one grounded preflight and one rising release after the offset. A forced final-budget omission recovers on the same jump with one packet. Off-lane rushers are not labeled active underneath threats; an actual near-release blocker remains rejected. These tests do not calibrate defender turning or prove live gameplay improvements.

- B3.4 compares actual B3.2/B3.3/current controllers with a running avatar whose position arrives once per six mock frames: B3.3 falsely rejects it as idle; the other two throw. A stationary character with stale velocity still cannot qualify. Grounded body-level, unexpectedly low, explicit-negative-lead, airborne and arithmetic-boundary placements are covered. The same synthetic low native result is actually released by B3.3 and blocked by the corrected controller. These are mechanisms/counterexamples, not confirmation of the user's specific uncaptured plays.

- B3.3 verifies TRUST startup despite stale saved SAFE, later risk selection, immediate folded AWAY activation, exact local `z` matching, separate executor GUI/opener hiding, late GUI hiding, preservation of game/touch controls and previously closed windows, captured Lighting application/restoration and cleanup. Live Yuna UI locations, inaccessible executor overlays and continuously reapplied fullbright remain unverified/unsupported as documented.
- Oscillation tests reject AFK, old movement, straight routes and a single cut. The full native-shaped controller releases one comfortable `ZigzagBullet` for an open repeated-reversal case, rejects a covered case, restores native settings and remains within eight calls/frame. Its current captured JSON reproduces 17 evaluator inputs and 17 analytic risk grades. The existing throw capture still reproduces 29/29. No claim of live human catch success or remote input prediction is made.

- B3.2 tests a blocked native preflight producing zero visible jumps, cancellation after takeoff, a later safe window while takeoff is unavailable, and recovery with one ascending release after the offset. No ground packet is permitted during the simulated cooldown. Prejump evidence remains separate from final release evidence. These are mocked lifecycle checks; the actual game cooldown and mobile timing remain unverified.

- B3.1 reduced reproductions cover flattened Fit/Dime admission, strict lower-power passes, genuine elevated/native deep windows, the boundary-clamp continuation mismatch, inward turns, unchanged configured lead allowance, and an evaluator veto arising only during final release. Boundary evidence round-trips through replay and corruption fails. The supplied live originals became unavailable after a workspace reset, so their complete replay is explicitly outstanding.
- Historical source selection through `--ref experimental-unified-b3` reproduces a synthetic model report against the original published B3 fingerprints without network access.

- All 25 experimental/test Lua modules compile with native Luau compiler source `74f768309c380d40601b28c4c4cdda27da415cef`.
- An actual controller-generated synthetic BAD JSON reproduces 29 evaluations and 29 analytic risk grades. Deliberately corrupted risk, missing replay inputs and wrong-build fingerprints fail with nonzero exit status.
- The original Build B accepts five constructed no-trailing-advantage scenes that the preserved V26.22 guards reject. These demonstrate a code-level admission difference; they do not establish the cause of a specific live interception.
- A real mocked sampler approaches six yards diagonally, briefly holds the proven developing opportunity, then releases after straightening before the continuation expires. A closing opportunity cancels the hold; this is not a universal release timer.
- Deliberately slow grading still examines all fresh cached alternatives. Native planning remains capped by the existing time/count limits. Local Lua-table-vector measurements for a three-defender grade were about 1.7–3.2 ms in original B versus 0.1–0.4 ms in B3, including its analytic grade, ranking and capture. Native solver and iPhone costs remain unverified.
- `git diff --check` and source publication scans pass. No credentials, private bin IDs, raw user attachments or private-workspace dependencies are included.

Run the documented Python commands in [README.md](README.md), plus each of the five `auto_qb_*_test.lua` files using:

```sh
python3 tests/experimental/run_lua.py tests/experimental/auto_qb_angle_v26_13_test.lua
python3 tests/experimental/run_lua.py tests/experimental/auto_qb_friends_v26_10_test.lua
python3 tests/experimental/run_lua.py tests/experimental/auto_qb_native_jump_v26_15_test.lua
python3 tests/experimental/run_lua.py tests/experimental/auto_qb_league_coverage_v26_15_test.lua
python3 tests/experimental/run_lua.py tests/experimental/auto_qb_league_screen_v26_15_test.lua
```

These checks verify local contracts and counterexamples. Completion rates, human route intent, actual catch/reach windows, current Yuna build matching, server physics agreement and mobile responsiveness still require live gameplay evidence. BAD reports preserve uncertainty rather than assigning blame to a receiver.
