# FF3 V26.12: trusted receiver states and raised-Dime calibration trial

The QB receiver list now cycles **NORMAL → BLOCKED → TRUSTED → NORMAL** on successive taps of the same row. These are sequential state changes, not timed double taps. First tap blocks; second tap clears the block and marks manual trust; third removes manual trust. The existing tiny paged list is reused.

- `[ ]`: normal, not currently verified as a friend.
- `[X]`: blocked, including if this player is a friend.
- `[T]`: manually trusted.
- `[F]`: normal manual state, but recently verified as a Roblox friend.

A friend is automatically eligible for added-height trials, unless blocked. Returning a friend to NORMAL removes manual trust but does not remove friendship eligibility. Platform lookups remain deferred, cached for 30 seconds and fail closed; unknown/nonfriends/API failures do not qualify through friendship. Manual trust resolves locally without a lookup. Friend labels may be unavailable until the relevant lookup runs; rendering the list does not request friendship data by itself.

Manual states use player UserIds in executor memory and persist across ordinary controller/X reloads. They are not promised across a full Roblox/executor exit. No friend/trust roster is uploaded. The ordinary ANY/FRIENDS receiver filter remains independent: to target a manually trusted nonfriend, use ANY. FRIENDS still requires a verified friend. Trust never overrides team, AFK, manual blacklist, LOS, plan or coverage eligibility, and opposing friends remain opponents.

## What is implemented for height

The folded **MAG OFF / MAG TEST** control deliberately starts OFF in a fresh environment. Turning it on adds **MagDime**, a native Dime candidate with the current `Dime.X` unchanged and `Dime.Y + 0.25`. This is a small explicit **trial increment**, not a data-derived catch threshold, measured maximum reach or proven mag setting. A deliberate toggle persists across ordinary reloads; explicit configuration wins.

This does not claim to identify or restrict every existing throw that might require angling. The supplied evidence/current observer cannot reliably distinguish a required normal jump from angle-assisted catch reach. Yuna's setting named “Mag” selects native throwing types; it is not an authoritative required-angling classifier. Angling may alter hand/catch reach without an obvious increase in root height.

The new candidate is only available to eligible recently verified friends or manually trusted players. It is an additional option rather than an unconditional height change for every trusted throw. An evaluated safe ordinary candidate takes priority over an evaluated safe MagDime, including across evaluated receivers and over sticky selection. The existing bounded planner does not exhaustively solve every receiver in the same tick; stale/unevaluated alternatives are not claimed safe. Untrusted players keep their ordinary existing trajectories. Bullet, Fit and native Jump leads are not increased by this feature.

The native Dime lead override exists only inside the protected synchronous solver scope. The current Angle/Power input mode, selected type, automatic settings, power and arc preference are preserved/restored. Actual returned ballistic arrival must match the requested scoped vertical lead within the existing arithmetic tolerance. If the native conditional branch ignores Y, the trial is rejected with `MAG_VERTICAL_LEAD_NOT_HONORED`; there is no guessed velocity or forced replacement branch. Actual native output still drives flight, catch-point prediction, defender modeling and final release.

MagDime requires the existing strict endpoint/lane safety and no over-top safety in SAFE, MOD and TRUST. Manual TRUSTED receiver state and the risk mode named TRUST are separate. An added-height candidate cannot use MOD/TRUST relaxation. All existing plan, movement/readiness, field, freshness and possession rules apply. Trust is rechecked during preparation, when evaluating the candidate and immediately before release. Blocking, removing the last available trust source, disabling the trial or stale friendship prevents the prepared trial packet. Native exceptions/yields/ownership conflicts retain stop-and-preserve behavior; no speculative request retry is added.

There are no new scans, event hooks, game physics edits or per-frame friendship calls. The optional candidate shares the existing planner time/call budget and eight-native-calls-per-frame cap. JB and MAG rebuild the tail of the shared candidate list without holes. When MAG is OFF, no added-height native candidate is evaluated. Native/manual throws outside Pelican are not intercepted or rewritten.

## History and calibration limit

`MAG_TRIAL`, `MAG_EXTRA_Y`, `MAG_STATUS` and `MAG_POLICY` appear in the report. History retains trial mode/extra Y and missing calibration in CurrentSettings. Per-throw records retain the native base lead, actual scoped lead, applied Y, anonymous MANUAL/FRIEND trust source, extra-Y binding and explicit `ANGLE_REQUIRED_UNVERIFIED` status. The ordinary LeadSettings readout continues showing the restored global settings. The existing `a` upload companion remains compatible.

Required movement remains UNKNOWN and fault remains UNRESOLVED. No numerical mag-height recommendation was derived from the uploaded ordinary-play history. It lacks controlled normal-jump versus angle-assisted catch limits and cannot establish a useful gap between them. Increasing Y by 0.25 can still produce a normal jump catch, an awkward/unreachable ball, or no improvement. It does not guarantee interception prevention.

The trust restriction and scoped native calculation make concrete progress; **a reliable angle-required throw remains unfinished pending game evidence**. Calibration needs the same receiver/avatar and native context, controlled successful and failed normal-jump versus angle-assisted catches at matched X, placement, trajectory and small Y changes, with ball/hand positions around contact. No automatic lead escalation or fabricated “calibrated” label is introduced.

## Optional configuration

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/loader.lua"))({
    FF3 = { MagTrial = { Enabled = false, ExtraY = 0.25 } }
})
```

Use the folded MAG control to deliberately test with a prepared trusted receiver. ExtraY accepts >0 through 0.5 native lead units as an increment policy, not a game catch limit. The loader pins ff3-v26.12 and keeps PELICAN_FF3_V26. Other game routes and the standalone companion source remain unchanged. Immutable ff3-v26.11 preserves the prior behavior.

## Validation

All **26 local suites / 1,546 mocked assertions** pass, including **119 new trust/trial checks**. Cases include the actual row cycle/session state, friend and manual eligibility, blocked friends, missing/pending/failed lookups, opponent/AFK/filter exclusions, native vertical-lead refusal, ordinary-Dime preference, revoked trust, JB/MAG candidate list combinations, current and per-throw metadata, native Angle/Power arithmetic, eight-call bound, restoration and external edits, solver exception/yield cleanup and invalid increment rejection. Native-shaped mocks establish integration behavior, not FF3 catch mechanics. No live Roblox throws/chats were sent; actual mag catchability, platform compatibility and iPhone overhead remain unverified.
