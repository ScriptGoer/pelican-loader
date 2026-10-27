# Pelican experimental Auto QB — B4.2

B4.2 fixes a movement-guide crash during QB acquisition; it retains B4.1’s strict flat-pass admission and ordinary-Dime comparisons. Production `main` / V26.22 is untouched. See [the audit](REWRITE_AUDIT.md) for established causes, preserved behavior and unresolved mechanics. [Validation](REPAIR_VALIDATION.md) separates automated checks from live evidence.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/repair-unified-qb/experimental/loader.lua"))()
```

This loader pins `experimental-unified-b4.2`. Confirm `RELEASE_VERSION|experimental-unified-b4.2` in COPY. X reloads the experiment. Launching the normal main loader returns to V26.22; an auto-execute entry pointing at main can also replace the experiment. The existing confirmed-cleanup protocol prevents stacking.

Enable Yuna QB Aimbot and Auto Throw Type; leave Mouse Aimbot off. Pelican discovers the supported native profile, temporarily owns settings only during synchronous native calculations and restores them. Starting before Yuna remains supported. No new anti-cheat modification, camera hook or input bypass is added.

## What changes

- The guide rejects ungraded native cache entries, including tuples that failed current receiver reach. It validates cache ownership and uses a read-only reach probe. The central coverage guard explicitly refuses missing grades instead of comparing absent numbers or inventing safe defaults. Valid guide forecasts retain actual effective lead classification. Strict throwing policy is unchanged.

- Ordinary/soft Bullets require strict modeled path and arrival clearance in SAFE, MOD and TRUST. A flat native Dime/Fit/Jump cannot borrow elevated-pass permission. TRUST still permits qualified genuinely elevated native Dime burns.
- When the best candidate is rejected or contested and its ordinary Dime is missing, compare that native Dime before optional Jump/Loft paths. A failed attempt can retry at the existing planning cadence. Existing fresh valid tuples remain reusable; a fully admitted strict completion receives no mandatory Dime delay. Invalid or unavailable alternatives never authorize a forced Bullet.

- Configured high-loft Dime needs strict actual path/arrival clearance. It cannot borrow the ordinary Dime's TRUST trailing-burn exception. The supplied B3.10 report's slow contested loft is rejected; the captured faster admitted Dime wins. This is a captured-decision counterfactual, not proof of a catch.
- A pure scheduler refreshes available core Bullet/Dime/SoftBullet candidates before their cache expires and gives remaining alternatives oldest-attempt fairness. Verified zigzag candidates retain priority. Cheap unavailable generators use no native slots. The original planning time and global eight-call cap remain.
- Automatic release avoids a redundant native preview. The actual release always uses a fresh native solve and current guards; planning cache entries cannot be sent directly.
- Normal-jump requests survive the Heartbeat in which they were requested. Transient budget/pose/staleness failures defer preparation instead of incorrectly cancelling it. Real safety/context failures still cancel.
- Reports distinguish MISSED from BAD THROW, freeze release settings and preserve bounded chronological preparation/final-attempt receipts.

## Small controls

Folded controls are QB, AWAY and reload X. QB opens a compact menu; report buttons remain in TOOLS. There is no large persistent BAD PLAY button. Type exactly `z` in your own Roblox chat to hide accessible Pelican/Yuna/executor GUI roots and their openers; `z` again restores owned visibility. Roblox chat/touch controls remain available. Automation remains active while hidden. Non-Roblox drawing overlays cannot be guaranteed.

| Control | Actual behavior |
| --- | --- |
| AUTO / THR | Selection and automatic release; turning off cancels owned work. With THR OFF, native manual throws retain Yuna’s own behavior outside the scoped calculations. |
| SAFE / MOD / TRUST | Existing actual-path/arrival policies. TRUST starts by default and retains qualified elevated ordinary-Dime trailing burns. All Bullet variants and flattened native paths keep strict clearance requirements. Configured LoftDime requires strict clearance in every mode. |
| NORMAL / DEEP / SHORT | Existing pass-plan filters. Deep is 20 yards beyond LOS, with developed comebacks/end-zone exceptions. SHORT permits deep only when genuinely wide open. |
| EASE | Comfort/catch-height/loft/relative-speed ranking. Mandatory flight/power safeguards remain separate. It cannot waive coverage. |
| ARC AUTO / OLD | Native adaptive-angle request plus the configured-angle alternative, or original configured native control. Actual returned trajectory is always graded. |
| HIGH | Conditional **receiver Jump trajectory**, using the native Jump lead. Requires a threatened ordinary chest path and a strict safe Jump path. This is different from the QB's physical jump. |
| ANY / FRIENDS | Eligible receiver filter; league uses ANY. Blacklist remains active. |
| WR list | NORMAL/BLOCKED state; unsupported manual-mag trust is not advertised as working. |
| SCREEN | League only: explicitly select one teammate for a behind-LOS stationary screen, current possession only. AFK/still players otherwise remain ineligible. |
| AWAY | Direct deliberate throw-away action, always available. Intentional-grounding avoidance is not verified. |
| COPY / DATA | Export report/data; TOOLS has BAD THROW, MISSED, BAD DATA and CLEAR BAD. |

The unsupported mag trial, custom raised Bullet and unconditional wide-open receiver Jump preference remain disabled and absent from the menu. Native leads are retained. No measured FF3 standing/jump/mag catch window has been established.

## Timing and coverage

Receiver and native trajectory are graded together after team, observed motion, blacklist/filter, LOS, field, reach, plan and power checks. The native solver controls flight; Pelican does not fabricate a catch point or silently add vertical lead. FIT remains conditional on fresh non-Fit comparisons showing a real timing/layer rescue. Conditional receiver Jump still needs a fresh ordinary-Bullet threat comparison at release.

Physical QB Auto Jump applies to qualifying deep **non-Bullet** trajectories when normal jumping is available. Bullet variants, including the fast conditional receiver-Jump trajectory, do not request a QB jump. Release uses observed takeoff and the existing 75-ms offset; it is not an apex wait. Current coverage is rechecked after takeoff. No cooldown bypass or guaranteed receiver-intent prediction is claimed.

Near the six-yard eligibility boundary, the existing developing-route logic can briefly continue an observed diagonal route only if catch geometry improves and the safety surplus survives that continuation. It does not add a universal delay. Current-velocity stops, AFK protection and immediate closing-window opportunities remain.

Native calculations are limited; a continuously changing field can outrun the cache. The scheduler improves fair work allocation, not the validity of old tuples. Every actual release is freshly solved. Unsupported/invalid/missing candidates remain unknown or rejected, never invented safe.

## Report a bad or missed play

1. After a bad release, open QB → TOOLS → **BAD THROW**, preferably before the next throw.
2. For an opening it refused, press **MISSED** while you still hold the ball.
3. The menu closes and attempts export. Send the unique `PELICAN_FF3_BAD_PLAY_<id>.json`, or use COPY/BAD DATA. A short description such as “low Bullet” or “missed middle Jump” helps identify your concern.

`Flag.Kind` now records which button you pressed, with selected possession, time and whether it had already released. MISSED after release can still include a throw; the flag states that explicitly. A possession report contains planning, omissions, release attempts and observed outcomes, not just successful releases.

The journal records anonymous receiver/defender motion, candidate scores/permissions, native failures, budget omissions, actual native power/angle/time/arrival, settings/leads, jump readiness and bounded chronological final/preparation receipts. Full replay inputs remain in critical keyframes and the final/prejump snapshots. Older attempt receipts are compact and explicitly identify their scope. Receiver motion and observed outcome do not prove who caused a miss.

Each flag gets a unique file; the plain `PELICAN_FF3_BAD_PLAY.json` is only the latest alias. COPY exports the latest pin, not a bundle. The last eight exported reports remain in `getgenv().PELICAN_FF3_BAD_PLAY_ARCHIVE` for the current executor session. CLEAR BAD clears the active pin, not saved files or that archive. Re-exporting the same pin can add late observation. Disk retention requires working executor file APIs; an overwritten old alias cannot recover past flags.

Reports are bounded to 1.5 MB; timeline trimming and omitted-row/attempt counts are explicit. Failed export reports failure and retains memory where possible. No JSONBin credentials or report upload occurs in this journal.

Replay a report locally with the exact matching tag:

```sh
python3 scripts/replay_bad_play.py report.json --ref experimental-unified-b4.2
```

For reports saved by B4 use `--ref experimental-unified-b4`; for B3.10 use `--ref experimental-unified-b3.10`. Historical tags remain available. Replay checks recorded evaluator selection and analytic risk, not native execution, replicated game timing or server catches. Wrong versions, corrupted inputs or truncated critical rows fail explicitly.

## Remaining limits

Native endpoint mismatches remain unresolved for some ordinary Dime and CoverageJump outputs: the original paid-source attachment is unavailable, and the retained source audit does not prove a valid larger tolerance. B4 retains its existing coherence guard rather than claiming an invented catch calibration. Reach, pursuit, catch height and replication assumptions still need in-game evidence.

The movement arrow remains advisory, uses projected UI, injects no Workspace object and never delays release. Its camera visibility and useful direction need live testing.

Normal brightness can be restored only from an actual pre-modifier baseline. `experimental/visual_baseline.lua` can capture it before visual modifiers. It cannot recover unknown previous values or stop an unidentified fullbright writer. No default Lighting values are invented.

## Development

`games/ff3/auto_qb.lua` is the preserved V26.22 baseline. `scripts/build_experimental.py` deterministically builds the isolated runtime; `decision_engine.lua`, `native_schedule.lua` and focused integration modules own the changed policy. Run the experimental Python suites, feature Lua suites, TRUST differential checks and native Luau compilation before publishing. `REPAIR_VALIDATION.md` records exact scope and results.
