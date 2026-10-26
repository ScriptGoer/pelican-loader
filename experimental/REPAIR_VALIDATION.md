# B3.1 repair validation

Production comparison: `main` at `c9cc9ea5350d6b49dfe9d3282432d9b0ecc7ef95` (V26.22).
Original engine comparison: `4a4689b`; diagnostics-only B2: `614550d`.

The repair modifies only `experimental/`, its build/replay scripts, and `tests/experimental/`. The source/isolation test compares every production baseline file byte for byte. No live Roblox, chat, currency or cloud-history action was performed.

| Suite | Checks passed |
| --- | ---: |
| Actual repaired-controller/native-shaped runtime contracts | 120 |
| Comparative V26.22 / Build B / B3 constructed scenes | 77 |
| Source isolation, solver preservation and deterministic generation | 69 |
| BAD report retention, privacy and replay | 24 |
| Adaptive native angle and error cleanup | 94 |
| Friends filter | 67 |
| Conditional native receiver Jump | 41 |
| Shared casual/league coverage | 42 |
| League screens, profiles, UI and cleanup | 106 |
| Unchanged production TRUST burn regression | 51 |
| Unchanged production SAFE/MOD differential matrix | 144 |
| **Total asserted checks/scenes** | **835** |

Additional validation:

- B3.1 reduced reproductions cover flattened Fit/Dime admission, strict lower-power passes, genuine elevated/native deep windows, the boundary-clamp continuation mismatch, inward turns, unchanged configured lead allowance, and an evaluator veto arising only during final release. Boundary evidence round-trips through replay and corruption fails. The supplied live originals became unavailable after a workspace reset, so their complete replay is explicitly outstanding.
- Historical source selection through `--ref experimental-unified-b3` reproduces a synthetic model report against the original published B3 fingerprints without network access.

- All 19 experimental/test Lua modules compile with native Luau compiler source `74f768309c380d40601b28c4c4cdda27da415cef`.
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
