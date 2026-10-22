# FF3 V26.19: holding-high versus dropping coverage

The shared casual/competitive module now makes an explicit safety-position read in addition to its actual path/arrival grading. X reloads main and pins `ff3-v26.19`. V26.18 remains available at its immutable public tag. No new HUD row, listener, world object or anti-cheat/input hook is added. Other game routes and standalone companions retain their bytes.

## Decision rules

- A relevant defender holding high on the downfield side of the receiver restricts that receiver to ordinary Bullet variants. Dime, Fit, conditional Jump, legacy high Bullet and Mag candidates are ineligible even if their individual endpoints look clear. If no normal Bullet is safe/reachable/comfortable, withhold that receiver's automatic pass rather than force it or substitute a lob. Other eligible receivers remain available.
- A defender moving down toward the receiver but not establishing a chest-arrival threat leaves ordinary Auto Arc comparison available. Depth alone is not proof of a receiving-window contest.
- A forward-and-lateral slant with an observed dropping defender threatening the projected receiving window can qualify conditional Jump. Require a fresh actual normal Bullet arrival threat from that contesting defender and a strictly safe raised native trajectory. A safe ordinary Bullet still vetoes an unnecessary jump. In this specific contested-slant state, a strictly safe Jump takes priority over Dime/Fit rather than being vetoed solely because another elevated mode is available.
- When both ordinary and raised windows are closed, withhold the pass. Strict Bullet/Jump coverage, receiver reach/movement, team/filter/blacklist, field/LOS, possession and final native ownership checks remain.

"High" means farther downfield along the validated attack direction, not greater world Y. The read considers the receiver-relative field depth, lateral relevance, actual defender direction and projected motion over a common ordinary-Bullet horizon. It does not assign verified league positions from names/uniforms. A far unrelated sideline defender cannot force a Bullet restriction. Multiple relevant defenders are considered; a holding-high defender can veto the elevated candidate while another defender is contesting underneath.

A fresh ordinary Bullet tuple supplies the common horizon where available; otherwise the observed QB/receiver distance and the supported nominal Bullet speed provide a policy estimate. Candidate-specific elevated lead points do not define whether the safety was holding high. Recent observed dropping can remain associated with the same defender while its modeled receiving threat persists, allowing a drop to transition into matching man coverage. The inherited motion window bounds retention after contact is lost. Model/character replacement resets receiver observations and weak defender keys do not become permanent player bans.

## Important calibration limit

The supplied source does not expose an authoritative "50% covered" catch-hitbox test. This implementation treats partial coverage as an **observed drop plus modeled chest-arrival threat with a separate strictly safe raised solution**. The relevance and catch-threat estimate reuses the existing defender speed/turn envelope, inherited 4.5-stud body estimate, six-stud strict endpoint policy and motion window. Those are application/model assumptions, not newly discovered FF3 catch radii or verified overlap percentages. No arbitrary vertical offset, catch-height threshold or forced throw is introduced.

## Fast native conditional Jump

The new safety policy requests native Jump using the existing native **Power/low-arc** path and the user's current Power cap. It keeps the user's own Jump X/Y lead, verifies returned power/speed and effective lead, and rejects a returned high-arc branch. It no longer asks the adaptive Angle solver to produce this conditional pass. Temporary ManualType, Power and PreferHighArc writes are owned and restored within the protected synchronous solve; Auto Throw Type, locks and all other controls retain their established ownership behavior. A failed/yielded/conflicted calculator stops before a request and restores only owned state.

This is not an unconditional 95 overwrite: a 95 configured cap yields a modeled 95 low-arc throw when supported; another cap must be honored or the candidate is rejected. Existing minimum native flight-time comfort and all path checks remain. Native catchability and actual server speed agreement are still unverified. A high configured Jump lead is not automatically reduced; it remains the player's setting, not evidence of a forgiving jump height.

Ordinary Bullet includes the existing SoftBullet/QuickBullet variants with Bullet lead. Their generic native lower-power implementation may report native mode Dime internally; the resulting low-arc Bullet trajectory and applied lead determine their classification. This does not permit an elevated native Dime through the holding-high restriction.

Among otherwise eligible ordinary modes, the fastest actual flight now wins before the old lower-power preference. Power comfort still rejects a too-fast close laser, and recipient ranking still favors shorter ready completions. DEEP/SHORT filters, jump timing and same-possession replanning remain. Conditional Jump must use the proof path; old unconditional native Jump planning cannot bypass the new safety read even if OpenComfort is explicitly disabled. `FF3.SafetyReads=false` provides an explicit historical-policy fallback; the production default is true. Deliberate JUMP OFF remains respected.

## Final release and diagnostics

The native Bullet comparison is refreshed before a conditional Jump, followed by the actual Jump solve. Current receiver/defender observations regenerate the safety read at release. A newly holding-high safety, newly safe ordinary Bullet, changed route, lost possession or closing raised window cancels the pending elevated packet. No automatic retry follows an attempted/ambiguous request.

CurrentSettings records SafetyReads. Candidate diagnostics and bounded blocked/throw records retain SafetyRead and whether the normal Bullet had a contested chest-arrival threat. Reports state the rule and its uncalibrated-overlap limitation. No additional native solves or roster scans are added to the grading loop; the existing eight-call frame cap and shared coverage/interval reuse apply to both profiles.

## Validation

39 suites / 3,551 mocked assertions pass, including 75 new safety-read and native-control checks. Tests cover stationary high safety with forward/slant receivers, unrelated wide defenders, floating-down Auto Arc, slant/drop chest threats, ordinary-Bullet veto, contested Jump preference, closed windows, fastest allowed flight, real native-shaped Bullet and low-arc Jump packets, last-moment transition to a high safety, native errors/yields/external edits, settings restoration, cleanup and call bounds in CASUAL/LEAGUE. Historical fixtures explicitly select SafetyReads=false to preserve their prior decision contracts; the new suite uses the production default.

The successful conditional Jump fixture uses a slow modeled defender and is not evidence that a live normal-speed half-covered WR is safe. A separate closed-window fixture refuses the pass. Local passes prove the tested controller/model contracts, not real FF3 catching, half-coverage hitboxes, current paid-build identity, phone performance or server agreement. No live Roblox throw, chat, currency or cloud write was performed. Existing sources, private uploads and credentials are not redistributed.
