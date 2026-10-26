# Pelican Auto QB — repaired experiment B3.1

B3.1 adds focused live-report policy fixes to B3 on the dedicated `repair-unified-qb` branch. **Production main/V26.22 is unchanged.** The baseline is `c9cc9ea`; original B is `4a4689b`, and the later B2 diagnostics commit is `614550d`. B2 did not change B's decision engine. The original repair remains pinned at `experimental-unified-b3`. Historical documentation is preserved in [BUILD_B_ORIGINAL.md](BUILD_B_ORIGINAL.md).

Start Yuna with QB Aimbot ON, Mouse Aimbot OFF and Auto Throw Type ON. Run:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/repair-unified-qb/experimental/loader.lua"))()
```

The loader pins the immutable `experimental-unified-b3.1` module. X reloads the repair loader. Confirm `RELEASE_VERSION|experimental-unified-b3.1` in COPY. The existing loader ownership/confirmed-cleanup protocol prevents stacking with production/B. If an auto-execute script subsequently launches main again, it replaces the experiment; replace that auto-execute line or launch the experiment after it finishes. To return to production, execute the normal main loader. No production route or source file is modified.

## B3 live reports and B3.1 corrections

Three B3 reports were initially read and matched to the published fingerprint. One records receiver possession after a long Bullet, one records opponent possession after a 69-power native Dime, and one records ground geometry after a downfield Fit. All three record substantial post-release route changes; none establishes quarterback/receiver fault or a calibrated catch window.

The Fit exposed a concrete inherited admission loophole: its actual native vertical lead collapsed to approximately zero, yet its mode label let it use relaxed non-Bullet coverage admission. B3.1 recognizes exactly flattened native results from the returned effective lead. Those paths require the existing strict Bullet guards or the specific qualified TRUST trailing-corner proof. This is an arithmetic distinction, not a newly invented jump/standing catch threshold. Genuine elevated trajectories retain their configured policies.

The Fit's endpoint was also truncated by the native AntiOOB boundary while observed receiver momentum continued outward beyond it. The old reach test checked only optimistic travel distance. B3.1 additionally rejects an observed boundary-clamped endpoint when constant-velocity continuation exceeds that boundary by more than the configured horizontal lead allowance. It uses the same native bounds already validated by the solver and the same endpoint arithmetic tolerance. It does not move the target, alter lead, infer route intent, add a release timer, or penalize an already inward-moving receiver merely for being near a sideline. Projected continuation and correction allowance are recorded in BAD evidence.

Finally, the throwable wrapper returned raw baseline permission instead of the evaluator's final veto. B3.1 enforces that veto through the actual release path and reports its reason. A test injects a new veto only during the fresh final grade and verifies that no packet is sent.

The 69-power interception passed strict coverage checks. Its later route change and observed physics do not establish that increasing power would have prevented it. B3.1 therefore does not globally speed up comfortable passes or claim that this interception's cause is fixed. The environment reset removed the uploaded originals after the initial reads, before complete offline replay. These fixes use the retained measurements, independent source inspection and reduced synthetic reproductions; full replay of those original live reports remains outstanding. Raw reports and player histories are not published here.

## Established causes and corrections

| Regression | Verified implementation problem | B3 correction / practical limit |
| --- | --- | --- |
| Missing deep opportunities | B hard-disables `deepThrow`; its simulated risk caps can reject a native window that V26.22 admits; 3-ms grading truncation can leave useful alternatives unexamined. Disabling jump alone does not explain every missing throw. | Restore real flight/jump classification and observed takeoff/75-ms release path. Retain V26.22's credible TRUST burn and early-interception proof. Grade every fresh cached alternative. No claim every apparent live burn is safe. |
| Uncomfortable Bullets | B forcibly sets `powerAllowed=true`, removing the actual native flight-time comfort veto. A difficulty cost alone does not prevent an uncomfortable winner. | Actual V26.22 comfort floors are mandatory again. EASE ranks admitted endpoints by comfort deficit, receiver-relative catch height, unnecessary loft and relative arrival speed before distance/flight. It favors a supported gentler pass when safe, rather than blindly choosing the fastest mode. |
| Premature diagonal threshold throw | Eligibility and score were effectively sufficient for immediate submission; there was no developing-route timing assessment. | Only near-threshold, grounded-motion, wide windows with a quantitatively improving continuation can pause briefly. Future clearance must retain strict margin/lane surplus after a worst-speed movement allowance. A straightened route, closing window, goal/screen or brief contested opportunity has no added hold. |
| Covered TRUST throw | The new reaction/acceleration/catch-neighborhood simulation allowed contest relief through an uncalibrated pooled cost cap. Constructed cases expose admissions without a current trailing advantage. | Remove that permission model. Use V26.22's actual whole-flight/arrival checks and specific TRUST trailing-corner proof. Current and projected advantage, early path and other defenders remain vetoes. |
| Disconnected legacy behavior | B replaced Fit/Jump admission, forced clear-burn false, and removed deep-jump behavior while retaining old controls and report labels. | Restore derived burn evidence, native Fit counterfactuals, conditional native HIGH and the underlying functional controls. Retire unsupported mag/custom-height/unconditional-wide-Jump trials rather than display dead switches. |
| Expensive/starved evaluator | Per-candidate pursuit integrates 16 steps per defender and copies model snapshots, while a separate 3-ms budget suppresses other candidates. Pre-solver omissions also consumed native-attempt slots. | Reuse the inherited analytic risk grade and cheap ordered joint ranking. Remove the separate grading cutoff. Keep the 8-ms native planning allowance, bounded mode-sweep attempts and eight-native-calls/frame guard; only real native calls consume native slots. Profile guard, capture, callback and interval cost. |

The table documents B3's initial repair. The B3.1 section above distinguishes subsequent observed reports from established code defects. The inherited body reach, instant-turn pursuit and game/native physics assumptions remain uncalibrated.

## Joint selection and timing

Receiver and supported native trajectory are evaluated together. A candidate must pass current team/movement/blacklist/filter, field/LOS, receiver reach, native output, power comfort, configured risk, mode admission and possession checks. The ordered score then compares admission, strict-versus-contested risk tier, developing readiness, comfort deficit, catch height, extra ballistic loft, relative arrival speed, proven contest gap, pass distance and flight. It is a vector of explicit costs, **not completion odds**. There are no new risk-score weights to tune until a fixture passes.

V26.22's four-stud TRUST allowance is specifically a current **and projected** trailing-corner advantage with no early direct interception, closing burn or over-top help. It is not general permission to throw at covered players. SAFE/MOD retain their original risk math. More separation no longer gets a worse priority simply because a simulated pursuit contacted the flight earlier.

The joint ranker replaces the old independent mode/receiver label preferences. Required Fit/Jump comparisons and final fresh solves remain. NORMAL still prefers easier shorter completions among comparable admitted windows. DEEP uses 20 yards beyond the observed LOS plus developed-route comebacks/end-zone exceptions. SHORT retains the genuinely wide-open deep exception. These restrictions are evaluated through the actual existing plan logic, not duplicated approximate filters.

Developing timing does not predict an unseen receiver input or promise that a diagonal route will straighten. It forecasts current observed momentum, using measured velocity trend where available. It only considers a receiver close enough to the six-yard boundary to be affected by the short continuation. Significant lateral motion, improving catch geometry, ample current clearance and surviving future clearance are all required. The default forecast horizon is 0.18 seconds, bounded to 0.35 seconds; these are explicit application preferences, not measured FF3 reaction constants. A hold cannot renew indefinitely. Its safety/usefulness is checked again; it ends early when the receiver straightens or the opportunity becomes time-sensitive. The normal native final check still decides release.

`FF3.Unified` now supports only `DevelopingRoutes`, `DevelopmentHorizon` and `DevelopmentMax`. Old `Samples`, acceleration/reaction, contest-relief, pooled-risk-cap and score-weight options are rejected explicitly. Remove the old Unified configuration table when launching B3. EASE changes ranking; it cannot waive conditional HIGH proof or full-power floors. `FF3.CloseBullet=false` remains an explicit advanced opt-out from those inherited floors.

## Compact controls and feature audit

**Folded:** only the 54×22 QB pill and existing red reload X. There is no persistent BAD PLAY/AWAY/SCREEN touch area. QB opens a 230-pixel-wide menu with three columns and at most three rows; TOOLS changes pages. Flagging a play closes the menu. Receiver and lead panels no longer stack over the grid.

| Control/feature | Active behavior |
| --- | --- |
| AUTO / THR | Actual selection and automatic release toggles; OFF releases/cancels owned work as before. |
| SAFE / MOD / TRUST | V26.22 admission policies plus the B3.1 native-geometry/boundary vetoes, including TRUST's qualified ordinary Bullet/Dime trailing-corner exception. A flattened non-Bullet cannot borrow elevated-pass admission. |
| NORMAL / DEEP / SHORT | Actual depth/comeback/end-zone/wide-deep rules described above. Visible in casual and league PLAY menus. |
| EASE | OpenComfort ranking ON/OFF. Full-power comfort and HIGH safety proof remain independent. |
| ARC AUTO / OLD | Existing verified native adaptive-angle request versus the native configured input; actual returned trajectory is still graded. |
| HIGH | Conditional **receiver** native Jump type, using its own configured lead and fresh chest comparison. It does not toggle the QB's automatic deep jump. |
| QB deep jump | Automatic ordinary jump, then the configured short observed-takeoff release offset; no apex wait. Rechecks cancel a lost window. Unsupported normal jump state retains the existing explicit fallback/report. |
| WR list / ANY-FRIENDS | The WR list toggles NORMAL/BLOCKED; ANY-FRIENDS changes actual receiver eligibility. Friends are verified asynchronously. Manual mag-trust markings are preserved for production but are not an active setting in B3. League keeps ANY and hides casual friendship controls. |
| SCREEN | League-only explicit teammate/current-possession stationary behind-LOS exception; strict native Bullet and final checks remain. Inside PLAY, not always on-screen. |
| PROFILE | CASUAL/LEAGUE override; AUTO's VIP text remains a private-server hint, not proof of league identity. |
| AWAY / CB | Existing deliberate throw-away action and opt-in friend route chat. TOOLS only, casual only; no new automatic messages. |
| COPY / DATA | Usual reports/history when unpinned; pinned BAD export when flagged. CLEAR BAD returns them to their normal workflow. File-only success says SAVED, not COPIED. |
| STOP / X | STOP ends and cleans up the experiment; X reloads through confirmed cleanup. |
| Movement guide / receiver evidence | Existing advisory PlayerGui arrow and passive observations remain. Exact leads remain in DATA/BAD metadata; the separate LEADS panel control is removed from the compact menu. No automatic lead tuning or claimed receiver fault. |
| MAG / custom raised Bullet / unconditional wide-open Jump preference | Retired from active planning, setters reject enabling unsupported trials, and controls are removed. Original native helper source remains intact. HIGH is the supported conditional replacement. |

The separately running verified Pelican jump-width helper keeps its widened native jump button, while its own persistent bar is hidden during B3. Stop/revert restores that bar only if still owned; external visibility changes are preserved. Yuna/game UI is not hidden. `FF3.CompactCompanionHUD=false` opts out at startup. No Workspace objects, synthesized movement, anti-cheat changes or invasive hooks are introduced.

## BAD THROW / MISSED capture and export

1. After a bad pass, tap **QB → TOOLS → BAD THROW**. It pins the latest attempted possession within 45 seconds. For a current withheld opportunity, use **MISSED** instead. This avoids silently flagging a different recent throw.
2. Flagging attempts immediate clipboard/file export and closes the menu. The report is also retained in executor session memory. API acceptance is not iOS clipboard readback proof.
3. After the play settles, **QB → TOOLS → COPY / BAD DATA** exports the same pin with any late outcome observations. The file is `PELICAN_FF3_BAD_PLAY.json` where file APIs work.
4. Paste/upload that JSON. **CLEAR BAD** removes the pin and restores ordinary COPY/DATA; it does not delete the exported file. Stop/reload preserves the pin. A full app exit needs the saved/exported artifact.

The journal records anonymous receiver/defender positions, velocities, six-point motion history, relevant native settings/leads, ordered scores, actual return power/arc/time/arrival, comfort/threat evidence, eligibility exclusions, native/generator errors, scheduling/budget omissions and exact CodeId/EngineId plus wall/monotonic timestamps. Native supported tuples, failed generation and never-attempted modes are distinguished. Failed native output is not replaced with an earlier candidate's good margins.

The actual released decision cohort is preserved separately from final native calculations, counterfactuals and final checks. First-plan, first-viable and first-development cohorts are also retained. A bounded 64-frame score/reason timeline helps distinguish an earlier opening from the latest covered state. Three possessions, two rolling full frames and up to 512 candidate rows per full frame are retained. The row limit covers the verified roster/mode bound; overflow/identity/truncation counters are explicit. Full inputs are in keyframes; older timeline rows are summaries. This is bounded evidence, not an exhaustive match recording.

Exports have a 1.5 MB limit. If necessary, older timeline summaries are removed with an explicit omission count before export; full critical native evidence is preserved. An oversized critical report stays in memory and reports failure rather than pretending it exported. JSON/disk/clipboard work runs on deliberate export, not per candidate. Capture/finish costs are measured too. No automatic cloud upload is added, and credentials are not captured.

Observed outcomes retain their original uncertainty. A missed catch, interception, route change or jump does not by itself establish who caused it or the required catching technique.

## Deterministic replay and validation

From this repair checkout, with Python and liblua5.4:

```sh
python3 scripts/build_experimental.py
python3 scripts/replay_bad_play.py PELICAN_FF3_BAD_PLAY.json
python3 scripts/replay_bad_play.py OLD_B3_BAD_PLAY.json --ref experimental-unified-b3
python3 tests/experimental/test_engine.py
python3 tests/experimental/test_integration.py
python3 tests/experimental/test_bad_play.py
python3 tests/test_trust_burn.py
```

The five additional `tests/experimental/auto_qb_*_test.lua` suites run through `tests/experimental/run_lua.py`. The comparison tests require Git history for `4a4689b` and `c9cc9ea`. The fixture defaults to the repaired runtime, not production. Historical fixture options are explicit; the B3 scenarios also exercise production-default options.

Replay checks EngineId **and** full build-input CodeId, recomputes ordered decisions and the captured analytic path/arrival/comfort/Trust-burn calculations from actor snapshots, and compares them with the saved values. It validates released and critical keyframes, not just a final score copied from the report. Tampered risk values, missing inputs, truncated rows and wrong versions fail with nonzero status. Float32 comparison tolerance is diagnostic only; it never relaxes runtime safety thresholds. Native solver execution, authoritative team/field/possession state and server catches cannot be replayed offline. Time/rounding boundary mismatches must be investigated, not treated as player fault.

The regression set compares B3 with real V26.22 and original B. It covers comfortable versus fast/floating throws, deep native takeoff/release, credible versus unsafe TRUST cases, opposing pursuit directions, developing/straightened/brief routes, all relevant controls, native errors/yields/external edits, screens, final comparisons, cleanup, compact HUD ownership and BAD export/replay. The original engine admits five no-trailing-advantage scenes in the constructed matrix that restored guards refuse. In local Lua-table-vector benchmarks, B's three-defender grade was approximately 1.7–3.2 ms versus roughly 0.1–0.4 ms for B3's analytic grade/ranking/capture. These are desktop fixture measurements, not native Roblox/iPhone frame guarantees.

Historical replay uses the explicitly selected local Git ref, checks its original fingerprints and performs no network fetch or report-supplied code execution. The historical CLI test reproduces a synthetic B3 model report against the original source; it is not a replay claim about the missing live uploads.

The completed validation run passed **835 assertions/scenes** and native Luau compilation of all **19** experimental/test Lua modules. [REPAIR_VALIDATION.md](REPAIR_VALIDATION.md) records the suite breakdown and replay checks.

**Remaining uncertainty:** live completion/interception rates, correct inherited catch/reach boundaries, current paid-build match, actual server ball agreement, human route intent, and iPhone latency/thermals. No live throw, chat, currency action or private cloud-data write was performed. Passing automated tests establishes these local contracts, not gameplay improvement.
