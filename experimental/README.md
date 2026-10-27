# Pelican Auto QB — repaired experiment B3.10

B3.10 repairs rejected soft-Power fallback, restores trajectory-based elevated admission, compares a configured native loft option, and aligns non-Bullet deep QB jumps with actual throw permission. Prior diagnostics, movement advice and mobile controls remain. **Production main/V26.22 is unchanged.**

Start Yuna with QB Aimbot ON, Mouse Aimbot OFF and Auto Throw Type ON. Run:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/repair-unified-qb/experimental/loader.lua"))()
```

The loader pins `experimental-unified-b3.10`. X reloads the repair loader. Confirm `RELEASE_VERSION|experimental-unified-b3.10` in COPY. The existing confirmed-cleanup protocol prevents stacking with production/B. If auto-execute subsequently launches main, it replaces the experiment; update that auto-execute line or launch the experiment afterward. Execute the normal main loader to return to production.

## B3.10 throw delivery and layered coverage

The supplied B3.9 report replayed 37 captured evaluator/analytic-risk inputs. It records a 95-power Dime honoring +7.1 Y, an explicit `NO_STRICT_CLEAR_WINDOW` QB-jump skip, and opponent possession observed after receiver-route changes. It also repeatedly rejects soft Power candidates with `NATIVE_ARRIVAL_AIMPOINT_MISMATCH`. It is not a direct captured Bullet-miss calibration and does not establish receiver/QB fault or optimal lead changes.

Soft native Power output that fails endpoint consistency now requests one bounded retry through the existing native Angle path, after the protected native controls have been restored. The rejected tuple never authorizes a packet; the retry must satisfy all original endpoint, power, flight, reach and interception checks. The global eight-native-calls-per-frame cap still applies. This closes an early-return path that previously prevented the Angle fallback from being tried. A synthetic inconsistent Power tuple now produces a checked roughly 63-power SoftBullet; live executor support remains unverified.

`HIGH_SAFETY_OBSERVED` is a geometry label, not an unconditional Bullet-only command. A holding safety or an underneath linebacker must threaten the actual flight/arrival to veto a higher option. Conditional native receiver Jump still requires strict whole-path/arrival clearance and a current threatened ordinary-Bullet comparison. A genuinely strict safe Bullet still vetoes unnecessary receiver Jump. The old dropping-slant-only permission is removed; no additional catch-height offset is introduced. Native over-top interception, team/readiness, field/LOS and receiver-reach guards remain.

ARC AUTO now also generates `LoftDime`, using the player's configured native Angle and configured Dime lead through the existing owned Angle transaction. The native solver derives its actual power/flight and its returned trajectory must pass all checks; configured angle is not assumed equal to returned angle. ARC OLD disables this additional candidate. This makes an actual higher native option available instead of requiring every Dime to use only the lowest derived angle. It is not a mandate to float passes to open players.

For a contested or blocked ordinary candidate, missing current native Jump/configured-loft comparisons receive bounded same-receiver solve attempts before commitment. Existing native budgets apply; unavailable/unsafe options are recorded, never invented as safe. A strict currently admitted completion is not held for these comparisons. Native Jump still cannot be released without its real chest counterfactual. Fit remains a timing rescue or strict between-layers option; a late unsafe loft can provide a real timing-rescue comparison, solved freshly before final Fit release.

Automatic **QB** jumps for admitted deep non-Bullets now use the same fresh native throw permission, including qualified TRUST/MOD windows. The extra strict-clearance/turn-only jump veto no longer turns an admitted deep pass into an immediate ground release. Normal jump availability/physics and the observed short offset still apply. Bullet variants still do not request QB jumps. Actual final safety checks may cancel a lost window; no promise about future receiver intent or game jump cooldown is made.

BAD captures now retain native planner failure details plus the active soft control method and rejected-Power fallback evidence. For another issue: after a bad release use **QB → TOOLS → BAD THROW** before another throw; for a missed window use **MISSED while still holding the ball**. Send the new unique JSON (or COPY text) with a short label such as `Bullet miss`, `No QB jump`, or `Missed elevated window`. No manual measurements or lead guesses are needed. Every file is one flagged snapshot, and the plain filename remains only the latest alias.

## B3.9 movement advice

The guide previously ran only through one late covered-winner gate and abandoned Fit selections outright. Covered/manual selections now queue advice when the normal evaluator has a fresh matching possession/team/field scene. A Fit or unsupported primary selection can reuse that same receiver's current cached ordinary Bullet/Dime trajectory, including supported softened Bullet variants. Missing/stale tuples do not produce invented directions. The existing currently-open gate remains: the arrow is for estimated future room, not a reason to hold a pass that is already available.

Forecasting remains after release work, with at most six continuation estimates and the existing 1-ms advisory budget. No native solves, player scans, character motion, packets or throw-delay gates are added. The inherited conservative future-path and QB-room checks still decide whether to suggest a direction. Forecasts are estimates using observed continuation, not proof of a future catch. Some covered scenes will correctly have no advice.

The PlayerGui ground arrow tries its normal length, half length and quarter length before hiding for an invalid/off-screen footprint. Arrowhead dimensions scale with length; field/LOS constraints remain. If the camera cannot see the nearby field, no fake ground marker is drawn. No Workspace objects or new interactive HUD controls are introduced. Stale/changed-context advice and disabled guides remain hidden.

Advisory future grades are excluded from BAD candidate/final-release capture, fixing a path where a forecast could overwrite release evidence. BAD settings now include movement-guide status, draw count and forecast-check count to distinguish missing forecasts from projection failures.

## B3.8 conservative Auto Jump

**Historical policy, superseded by B3.10’s shared throw/jump permission.**

Ordinary, soft, quick, zigzag and raised/conditional receiver-Jump Bullet variants never request a QB jump. They also bypass the automatic takeoff-offset wait, including when the QB is manually airborne. This changes automatic QB movement, not the receiver's configured catch target or native throw type.

For other deep trajectories, grounded preflight still runs the full current native solver, receive/reach, risk, possession and final-context checks. A new automatic jump additionally requires strict path/arrival clearance (the existing SAFE margin/lane thresholds), no active developing-route or oscillation classification, and a turn value within the existing MOD route-stability limit. Normal jump physics must be known, and ordinary jumping must be available. These are conservative current-evidence requirements, not a calibrated probability or certainty about future player movement.

A TRUST/MOD throw admitted through contest allowance can still release without an automatic jump if this stronger jump test fails. Skipping jump cannot create a takeoff wait or suppress a valid ground pass; final fresh throw checks still run. Already-committed qualifying jumps retain the observed short release offset and recovery safeguards. BAD `PreJump.AutoJump` records the separate permission and reason, so `PREJUMP_VERIFIED` alone no longer implies a jump was requested.

## B3.7 contested trajectory ranking

A supplied live report reproduced 17 evaluator/analytic risk inputs with the exact B3.6 source. The captured cohort contained an admitted deep Bullet targeting head height and an admitted Dime honoring its configured positive Y lead. Both used TRUST's trailing-corner proof. The Dime had substantially less modeled whole-path clearance debt, but the old ranker compared catch-height cost first and selected Bullet. The selected Bullet's own zero Y lead was honored: this report does not show the native solver discarding Dime lead.

The ranker already calculated `RiskScore = max(0, -min(Margin, Lane))`, a conservative geometric clearance deficit in studs. It now includes that existing value as `Score.RiskDebt`, immediately after strict-versus-contested RiskTier and before comfort/height/loft. No coefficient, new height offset, catch window or game probability is introduced. Clear paths have zero debt, retaining their existing comfort ordering. EASE controls comfort ranking; it cannot suppress this risk comparison. Admission still wins before all costs: a rejected Dime/Fit/Jump cannot become eligible by score. Native high-safety restrictions, Fit comparisons and final fresh checks remain intact.

Counterfactual ranking of that exact recorded cohort changes Bullet to Dime; it does not rerun the unmade native final solve or predict a completed catch. A rounded constructed full-controller scene separately reproduces old Bullet versus current Dime releases, with configured positive Dime height preserved. Wide-open flat throws, high-safety policy and SAFE rejection remain covered. Underlying defender reach/instant-turn assumptions remain uncalibrated. This targeted correction does not claim to repair every inherited adaptive-arc/native lead limitation or attribute the observed interception to one player.

## B3.6 independent BAD files

Every BAD THROW/MISSED flag now gets its own `PELICAN_FF3_BAD_PLAY_<unique-id>.json` where executor file APIs work. Re-exporting that same pin updates its own file with late observations. Later flags cannot overwrite earlier unique files. `PELICAN_FF3_BAD_PLAY.json` remains a latest-report alias; clipboard/COPY still exports the latest pin only. Upload each unique file when reporting several plays.

The last eight exported flags also remain in `getgenv().PELICAN_FF3_BAD_PLAY_ARCHIVE` across script reloads in the current executor session. CLEAR BAD clears the active pin, not that archive or saved files. Full app exit loses session memory; disk persistence depends on the executor. Failed writes cannot guarantee disk retention. Reports saved by earlier versions cannot reconstruct previously overwritten pins. Repeatedly flagging the same possession records repeated snapshots; four clicks do not necessarily represent four different throws.

## B3.5 jump lifecycle and coverage labels

Auto Jump no longer treats a 45-degree WR direction change as proof that the pass is lost. The final native solve, current receiver reach and complete interception checks decide whether that changed route is throwable. A genuine closed window still cancels the throw.

Grounded preflight runs before requesting a normal jump. Once airborne, the state machine uses observed takeoff and the configured 75-ms offset, without repeating grounded preflight on cache expiry. Failed takeoff remains retryable at the existing 250-ms application rate limit; there is no possession-wide failure latch. Known jump physics still require ascending release. After descent, wait for landing and a new normal jump rather than firing from the bottom. Unknown jump parameters retain the explicit legacy fallback.

A final native-frame budget omission, changed launch pose or stale decision requests another fresh final solve on the next heartbeat without blacklisting the receiver or discarding observed takeoff. A sent/ambiguous packet still cannot be retried. No universal release delay or fabricated receiver intent is added.

The old `Underneath` summary counted every opponent between QB and WR in downfield projection, including distant off-lane rushers. It now requires a modeled path or catch-point threat for that candidate. This is a diagnostic-label correction, **not evidence that this label caused live throw refusals**: the actual analytic interception guards already operate on every defender and remain unchanged. A rusher who can block/intercept the native flight remains a threat; teammates are excluded by existing team checks. We do not infer verified player roles or exempt defenders by name, proximity to QB or velocity alone. A live BAD report is still needed to establish whether the conservative instant-turn pursuit model rejected a particular harmless rusher.

## B3.4 missed opportunities and low placement

B3.3 sampled teammate history faster to detect oscillation, but also updated the continuous-movement gate on every sample. A replicated avatar can retain running velocity while its position updates arrive less frequently. Unchanged positions between those updates reset readiness repeatedly, falsely classifying a moving open receiver as idle. A comparison using actual published controllers reproduces this: B3.2 throws, B3.3 refuses the same runner, and B3.4 throws again.

Readiness now measures displacement over the original 0.12-second planning interval, separately from fast reversal history. Current velocity stops and teleport invalidation remain immediate. A stationary character with stale nonzero velocity still fails measured-motion readiness. No defender thresholds, risk tolerances or release delays were loosened to make this test pass. These constructed scenes establish the regression mechanism; a live MISSED report is still needed to identify all blockers in a particular play.

The old comfort score charged only height above the receiver's head, so even a foot-level native endpoint had zero height cost. B3.4 also penalizes below-body placement for a receiver whose FloorMaterial identifies them as grounded. It refuses an endpoint below that receiver's current root/body reference when the applied lead is nonnegative, using the existing narrow arithmetic tolerance. Explicit negative lead remains deliberate user placement. Airborne receivers are exempt from this current-body floor because they may land before arrival.

This is a torso-placement preference and coherence guard, not a newly calibrated catch hitbox. It does not raise everyone's lead or repair an unobserved difference between native prediction and the actual server ball. A native-shaped test reproduces B3.3 accepting a below-body result and B3.4 refusing it before a packet. For a live low pass whose native endpoint was normal, collect BAD THROW and its ball observations; the cause remains open until that evidence is available.

## B3.3 play controls and observed zigzags

TRUST is the startup default even when a previous session saved SAFE. An explicit `FF3.RiskMode` or a later risk-button selection still works. AWAY is always available as a 40×22 button beside QB/reload, including league mode; it invokes the existing deliberate throw-away action without opening TOOLS. This retains the existing unverified grounding-rule limitation.

Type exactly lowercase `z` in your own Roblox chat to hide script GUIs; type exactly `z` again to restore their prior enabled/visible states. It includes Pelican, accessible executor `gethui()` contents (including separate openers), named Pelican/Yuna roots and the qualified native Yuna HUD's root. Unknown script GUIs outside those sources can be explicitly registered with `controller.RegisterPresentationGui(instance)`. Roblox chat, game HUD and native touch controls remain available. New executor ScreenGuis are hidden as they appear. No global input hook, chat interception, synthetic message, camera change or blanket disabling of game UI is added. Executor-drawn overlays outside Roblox GUI instances are not claimed supported. Stop restores owned GUI states and disconnects the listener. Automation remains active while its GUI is hidden.

**Lighting is conditional, not fully solved.** Normal pre-modifier Lighting values cannot be recovered after another script overwrites them without a retained snapshot or that script's own restore handler. If desired, execute this **before Yuna or any visual modifier**, once per game session:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/experimental-unified-b3.3/experimental/visual_baseline.lua"))()
```

Then `z` applies that actual captured baseline; the next `z` restores the prior modifier values only where still owned. Without a valid same-game capture, COPY reports `ORIGINAL_LIGHTING_UNAVAILABLE`; no default brightness/clock/fog values are invented. A fullbright writer can reapply its values, so this does not claim to suspend an unidentified fullbright feature. That feature's owner/native restore implementation is still needed for reliable automatic suspension. Do not run the capture helper after fullbright and expect it to know the original state.

For zigzagging receivers, bounded 20 Hz observations reuse known teammate samples. Two meaningful lateral reversals, sufficient actual travel, recent activity and a mostly bounded lateral footprint qualify; a one-time cut, AFK receiver or teleport does not. The normal continuous-movement gate can then use that verified activity rather than resetting at every reversal. This is observed movement, not access to player inputs or a promise that oscillation will continue.

The additional `ZigzagBullet` candidate uses the existing protected low-arc native Power transaction with a temporary horizontal lead cancellation. The initial estimate targets the receiver's present area rather than projecting a full straight route through each reversal. The actual returned native endpoint must stay inside the recent observed footprint plus the player's existing Bullet-X placement allowance; actual power, flight comfort, reach, team, LOS, blacklist and field checks still apply. This candidate requires strict **wide-open** coverage even in TRUST, gets no trailing-contest relaxation, and is revalidated at release. Native settings/leads are restored synchronously. If native placement cannot be verified, it is rejected and the other supported candidates remain available. No new catch-height numbers or forced packets are introduced.

Joint ranking prefers this point candidate over a straight-route projection for a verified open oscillator. There is no added universal throw delay. BAD captures include the observed oscillation summary, native override lead and competing candidates; replay reproduces ranking/risk using that captured motion classification, while native execution and the classifier's original full sampling stream are outside replay scope.

## B3.2 automatic jump recovery

Before an automatic deep jump, run the same fresh native trajectory/coverage/mode/possession checks used at final release, without sending a packet or starting the throw animation. A changed window therefore blocks the visible jump earlier. Record that evidence separately as `PreJump` with `PREJUMP_VERIFIED` or `PREJUMP_BLOCKED`; it is not a throw attempt. B3.5 supersedes the old airborne cache-expiry preflight: preflight now belongs to grounded jump preparation. Final native release runs on a later heartbeat so preflight and release cannot consume each other's native-call allowance. Native call/time limits remain in force.

After a cancelled jump, a deep throw with verified normal jump physics must observe a rising local takeoff and the configured short offset. A descending/landed jump cannot authorize a later ground release. Short passes retain their ordinary release behavior. Unknown jump physics retain the explicit legacy fallback rather than guessing physics values.

Missed takeoff no longer bans the whole possession. Requests retain the existing 0.25-second rate limit, and a new request gets a new wait timestamp; an old expired wait cannot cancel it immediately. This rate limit is application scheduling, not a claimed game cooldown measurement. The next safe deep window may use the remaining ascent or a fresh takeoff after landing. Final safety checks can still cancel a genuinely lost opportunity; preflight cannot guarantee future route intent or coverage.

Regression checks cancel a real mocked deep preparation, simulate cooldown with no takeoff, verify zero ground packets, then permit takeoff and verify one ascending release after the offset. A separate fresh-native veto test confirms zero jumps. No extra UI or automatic character movement is added beyond the existing ordinary jump.

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

Receiver and supported native trajectory are evaluated together. A candidate must pass current team/movement/blacklist/filter, field/LOS, receiver reach, native output, power comfort, configured risk, mode admission and possession checks. The ordered score then compares admission, strict-versus-contested risk tier, existing path-clearance debt, developing readiness, comfort deficit, catch height, extra ballistic loft, relative arrival speed, proven contest gap, pass distance and flight. It is a vector of explicit costs, **not completion odds**. There are no new risk-score weights to tune until a fixture passes.

V26.22's four-stud TRUST allowance is specifically a current **and projected** trailing-corner advantage with no early direct interception, closing burn or over-top help. It is not general permission to throw at covered players. SAFE/MOD retain their original risk math. More separation no longer gets a worse priority simply because a simulated pursuit contacted the flight earlier.

The joint ranker replaces the old independent mode/receiver label preferences. Required Fit/Jump comparisons and final fresh solves remain. NORMAL still prefers easier shorter completions among comparable admitted windows. DEEP uses 20 yards beyond the observed LOS plus developed-route comebacks/end-zone exceptions. SHORT retains the genuinely wide-open deep exception. These restrictions are evaluated through the actual existing plan logic, not duplicated approximate filters.

Developing timing does not predict an unseen receiver input or promise that a diagonal route will straighten. It forecasts current observed momentum, using measured velocity trend where available. It only considers a receiver close enough to the six-yard boundary to be affected by the short continuation. Significant lateral motion, improving catch geometry, ample current clearance and surviving future clearance are all required. The default forecast horizon is 0.18 seconds, bounded to 0.35 seconds; these are explicit application preferences, not measured FF3 reaction constants. A hold cannot renew indefinitely. Its safety/usefulness is checked again; it ends early when the receiver straightens or the opportunity becomes time-sensitive. The normal native final check still decides release.

`FF3.Unified` now supports only `DevelopingRoutes`, `DevelopmentHorizon` and `DevelopmentMax`. Old `Samples`, acceleration/reaction, contest-relief, pooled-risk-cap and score-weight options are rejected explicitly. Remove the old Unified configuration table when launching B3. EASE changes ranking; it cannot waive conditional HIGH proof or full-power floors. `FF3.CloseBullet=false` remains an explicit advanced opt-out from those inherited floors.

## Compact controls and feature audit

**Folded:** 54×22 QB, 40×22 AWAY and the existing red reload X. BAD PLAY and SCREEN remain inside menus. QB opens a 230-pixel-wide menu with three columns and at most three rows; TOOLS changes pages. Flagging closes the menu; receiver/lead panels do not stack over the grid. `z` also hides these controls.

| Control/feature | Active behavior |
| --- | --- |
| AUTO / THR | Actual selection and automatic release toggles; OFF releases/cancels owned work as before. |
| SAFE / MOD / TRUST | V26.22 admission policies plus the B3.1 native-geometry/boundary vetoes, including TRUST's qualified ordinary Bullet/Dime trailing-corner exception. A flattened non-Bullet cannot borrow elevated-pass admission. |
| NORMAL / DEEP / SHORT | Actual depth/comeback/end-zone/wide-deep rules described above. Visible in casual and league PLAY menus. |
| EASE | OpenComfort ranking ON/OFF. Full-power comfort and HIGH safety proof remain independent. |
| ARC AUTO / OLD | Existing verified native adaptive-angle request versus the native configured input; actual returned trajectory is still graded. |
| HIGH | Conditional **receiver** native Jump type, using its own configured lead and fresh chest comparison. It does not toggle the QB's automatic deep jump. |
| QB deep jump | Deep non-Bullet: fresh admitted native throw window plus verified available normal jump. Qualified TRUST/MOD admission can jump too. Bullet variants stay grounded; final rechecks and observed timing/recovery remain. |
| WR list / ANY-FRIENDS | The WR list toggles NORMAL/BLOCKED; ANY-FRIENDS changes actual receiver eligibility. Friends are verified asynchronously. Manual mag-trust markings are preserved for production but are not an active setting in B3. League keeps ANY and hides casual friendship controls. |
| SCREEN | League-only explicit teammate/current-possession stationary behind-LOS exception; strict native Bullet and final checks remain. Inside PLAY, not always on-screen. |
| PROFILE | CASUAL/LEAGUE override; AUTO's VIP text remains a private-server hint, not proof of league identity. |
| AWAY / CB | AWAY is immediate in casual/league. CB remains opt-in friend route chat in casual TOOLS. No new automatic chat messages. |
| COPY / DATA | Usual reports/history when unpinned; pinned BAD export when flagged. CLEAR BAD returns them to their normal workflow. File-only success says SAVED, not COPIED. |
| STOP / X | STOP ends and cleans up the experiment; X reloads through confirmed cleanup. |
| Movement guide / receiver evidence | Existing advisory PlayerGui arrow and passive observations remain. Exact leads remain in DATA/BAD metadata; the separate LEADS panel control is removed from the compact menu. No automatic lead tuning or claimed receiver fault. |
| MAG / custom raised Bullet / unconditional wide-open Jump preference | Retired from active planning, setters reject enabling unsupported trials, and controls are removed. Original native helper source remains intact. HIGH is the supported conditional replacement. |

The separately running verified Pelican jump-width helper keeps its widened native jump button, while its own persistent bar is hidden during B3. Stop/revert restores that bar only if still owned; external visibility changes are preserved. Yuna/game UI is not hidden. `FF3.CompactCompanionHUD=false` opts out at startup. No Workspace objects, synthesized movement, anti-cheat changes or invasive hooks are introduced.

## BAD THROW / MISSED capture and export

1. After a bad pass, tap **QB → TOOLS → BAD THROW**. It pins the latest attempted possession within 45 seconds. For a current withheld opportunity, use **MISSED** instead. This avoids silently flagging a different recent throw.
2. Flagging attempts immediate clipboard/file export and closes the menu. The report is also retained in executor session memory. API acceptance is not iOS clipboard readback proof.
3. After the play settles, **QB → TOOLS → COPY / BAD DATA** exports the same pin with any late outcome observations. The unique file is named in its `ExportFile` field; `PELICAN_FF3_BAD_PLAY.json` is only the latest-report alias.
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

The completed validation run passed **1,026 assertions/scenes** and native Luau compilation of all **28** experimental/test Lua modules. [REPAIR_VALIDATION.md](REPAIR_VALIDATION.md) records the suite breakdown and replay checks.

**Remaining uncertainty:** live completion/interception rates, correct inherited catch/reach boundaries, current paid-build match, actual server ball agreement, human route intent, and iPhone latency/thermals. No live throw, chat, currency action or private cloud-data write was performed. Passing automated tests establishes these local contracts, not gameplay improvement.
