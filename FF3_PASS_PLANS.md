# FF3 V26.9: NORMAL / DEEP / SHORT and wide-open native Jump

Expand the existing status pill and tap **NORMAL**, to the left of JB, to cycle **NORMAL → DEEP → SHORT → NORMAL**. The control starts folded and adds no permanent HUD. It is independent of SAFE / MOD / TRUST. New sessions default NORMAL; the chosen plan survives ordinary QB/X reloads in executor session memory. Explicit loader configuration wins over that session choice.

## Target-depth plans

The confirmed split is **20 yards beyond the verified blue LOS**, measured at the native predicted catch point. This is a user-selected target-depth preference, not an official game catch mechanic or a new QB-jump threshold. It uses neither QB-to-WR distance nor the yellow first-down marker.

- **NORMAL:** retains ordinary receiver/risk ranking across all eligible depths, with the new wide-open Jump preference below.
- **DEEP:** automatically releases only to a catch point at least 20 yards beyond LOS, or to a genuinely observed deep-route comeback. All native passing types can qualify, including a deep Bullet.
- **SHORT:** prefers a safe shallow catch when both shallow and deep completions qualify. A catch at least 20 yards beyond LOS is permitted only when that particular trajectory is wide open. An incumbent deep target cannot override a newly available safe shallow candidate solely through target stickiness.

A comeback is observed within the same possession, field/LOS generation, receiver character and team. The receiver must have reached the deep split, retreated by at least the existing minimum motion-travel policy, and be moving back toward the QB side along the field direction at the existing minimum route speed. Simply running backward at short depth is insufficient. AUTO OFF discards depth provenance across the unobserved interval; possession, field and character changes invalidate it as well. Existing AFK, recent movement, team, manual blacklist, legal LOS and field checks still apply. Short comeback catches can qualify in both SHORT and DEEP.

Plans restrict automatic release. A filter refusal retains the existing eligible manual target instead of blacklisting that receiver or submitting a throw. Mode changes cancel prepared sequences, clear old candidate windows and update the saved session preference. Final native output and current receiver/defender state are checked again before release, so a mode change or closing window cannot authorize a stale packet.

## Native Jump preference

The requested jump throw means **Yuna's native Jump throw type**, distinct from the QB's pre-release jump and the experimental Bullet-X/Fit-Y jump-Bullet feature. It uses the currently configured Jump lead and native solver in the user's existing Angle/Power mode. No new vertical offset, invented catch window, animation or midgame input-mode switch is added.

When enabled, Jump is evaluated earlier in the existing bounded mode rotation. A safe preferred Jump can therefore be considered before the planner commits to an otherwise open Bullet. It must independently pass native endpoint consistency, current team/receiver reach, field/LOS, power comfort and conservative coverage checks for **its own entire flight**, rather than inheriting a quicker Bullet's safety.

For wide-open checks, defender movement during the reported ping is deducted from the conservative endpoint/lane margins within the existing risk loop. No second player scan is added. Wide open requires at least twice the existing strict endpoint and lane margins (currently 12 and 8 source-model studs), no threatened over-the-top safety, and modeled defender ETA greater than that Jump's flight time plus the recorded ping. The same policy defines SHORT's deep exception. These are explicit application safety-surplus policies, not calibrated FF3 hitboxes, catch guarantees or interception probabilities. A Jump that gives a defender time to reach its path/arrival area is blocked even if the same receiver has a safe Bullet. All native Jump candidates are restricted to this wide-open rule while the feature is enabled. If Jump does not qualify, another existing plan-eligible safe mode may be selected.

SHORT's shallow preference is applied before the Jump preference, both within a receiver's mode comparison and across receivers. DEEP never turns a shallow Jump into a deep pass merely because its arc is high. The existing QB jump-then-immediate-release behavior remains separate; there is no new peak/ascent wait or release timer. Fit still requires its timing-rescue evidence, and all Bullet variants remain strict in every risk mode.

## Configuration and reports

Regular-loader users need only the folded plan button. Optional initial settings are:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/loader.lua"))({
    FF3 = { PassPlan = "DEEP", DeepYards = 20, WideOpenJump = true }
})
```

PassPlan accepts NORMAL / DEEP / SHORT (case insensitive). DeepYards is an explicit optional depth split, defaulting to the confirmed 20. WideOpenJump=false restores the previous native-mode preference/Jump eligibility while retaining the selected depth plan. It does not remove safety/receiver gates. SAFE / MOD / TRUST settings remain independent.

Reports add PASS_PLAN, PASS_PLAN_DEEP_YARDS, WIDE_OPEN_JUMP and candidate depth/comeback/wide-open/rejection reasons. Per-throw history records the plan and classified native catch depth; current settings snapshots retain plan, split and Jump preference. The existing `a` companion remains compatible. Player depth tracking reuses current motion samples; there are no extra world scans, background loops, native solves or network workers. The existing maximum of eight native solves per frame remains. New UI listeners share the existing owned cleanup, and stopping/reloading destroys the control with its parent UI.

## Validation and unresolved runtime behavior

All **23 local suites / 1,249 mocked assertions** pass, including 67 new plan/Jump checks. They exercise shallow versus deep selection, the exact split, deep Bullets, observed versus unproven comebacks and possession reset, paused-history invalidation, SHORT deep exceptions, per-trajectory defender timing, native Jump preference in source-shaped Angle/Power math, UI cycling/session persistence, manual locks, AFK exclusion, final mode/defender changes and retained upload metadata. Existing packet-equivalence fixtures explicitly disable the deliberately new Jump preference; the new suite exercises its production default ON and actual native-shaped calculations.

Sources and rebuilt bundle pass local checks. No live Roblox catches, chat/currency actions or executor inputs were exercised. Current native Jump catchability, remote/server trajectory agreement, safety-surplus quality and iPhone overhead remain unverified. These passing tests validate controller policy and cleanup, not a guarantee that a real receiver will catch every selected Jump. The loader pins ff3-v26.9; ff3-v26.8 remains immutable, and other game routes/companion source are unchanged.
