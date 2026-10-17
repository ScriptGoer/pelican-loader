# FF3 V23: team stats and receiver exclusions

The existing loader now pins `ff3-v23`, controller `PELICAN_FF3_V23`, with a separate `games/ff3/team_stats.lua` dependency. Yuna startup configuration and GUI replay are cancelled. The regular loader does not install auto-execute, click Yuna's wire button or enable its features. It stops previous Pelican GUI/stats recorder instances after confirmed cleanup. Yuna still starts separately with QB Aimbot ON, Mouse Aimbot OFF and Auto Throw Type ON for automatic passing.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/loader.lua"))()
```

## Implemented behavior

The compact expanded QB HUD adds **TEAM**, which enables/disables automatic stat exclusions, inspection and leaving. Its label shows SCAN, WAIT, WR, CB or DATA ? as evidence becomes available. WR LIST shows **[S]** for stat exclusions and **[X]** for manual blocks. Tap a receiver to allow/block them. A manual allow wins over automatic exclusions and exempts that player from automatic leave counting for the session. TEAM OFF removes only the automatic restrictions. Existing manual blocks survive it. X still reloads cleanly and preserves the previous report.

The small manual **AWAY** action remains beside WR LIST. It uses a high modeled sideline exit without requiring a receiver, shares the one-attempt possession reservation, and uses the discoverable native Throw animation when available. Actual grounding treatment, flight and animation remain unverified; high aim does not guarantee immunity to intentional grounding.

Auto QB's throwing algorithm is retained: short-pass preference, no AFK targets, teammate/blacklist checks, trajectory/mode comparison, native setting restoration, deep normal jumping and observed peak release, sold-burn cancellation, advisory RUN arrow and Goal's LOS-only exemption. The stats module adds receiver eligibility decisions; it does not replace native throw calculations or add release delays. Practice and Threshold keep their prior routes and source bytes.

## Reading the real table

The supplied live stats report identifies `PlayerGui.MainGui.Stats.Info`, `ScrollingFrame.Template.TextTemplate`, `Category.wr`/`db`, and `StatsType.server`. V23 uses the live row Instance as the grouping identity rather than flattened repeated paths. Header/cell horizontal alignment must form an unambiguous one-to-one map. Player labels have the observed numeric ranking prefix removed.

Exact usernames map to current UserIds only when no other current player's display name collides. Display-name-only rows require a unique, closed one-to-one mapping of the entire current server roster. Partial lists, global-looking subsets, duplicate labels, overlapping columns, zero-size/unready layouts and contradictory percentage/count pairs are not actionable. OVR is never used to judge skill. Current-team membership and actual UserId are checked again before applying results.

The reader works with already-populated table data. Automatic inspection also attempts the game's actual **Server → Receiver → Corner** handlers while no active/throwable play or equipped football is present. It qualifies the observed paths, TextButton labels and exactly one enabled callable `MouseButton1Click` handler. It never invents a stats remote or an input object, invokes both mouse/Activated handlers, hooks game code, or configures Yuna. Activated-only/ambiguous/unavailable handlers are reported and leave passive table reading available. Opening the game's Server/Receiver stats normally can populate that fallback.

Inspection uses a cancellable owned task, runs at most once per completed cycle plus a 30-second interval, and stops when play resumes or the user opens/interacts with the stats view. It preserves hidden-window visibility where it still owns the change and restores a previously identifiable role at cycle completion (otherwise Receiver). TEAM OFF/Stop cancel owned tasks and disconnect listeners. Game callbacks may perform their normal server reads; completion is not proof of server synchronization or cancellation of any independent work spawned by game code. No direct remote protocol is assumed.

A native handler that errors or remains pending for five seconds stops the controller and saves the cause without retry. A completed handler whose table remains unreadable is a bounded unavailable-data result; it restores the view and makes no judgment. It does not create a pregame fatal countdown or hold passing until stats arrive.

## Conservative criteria chosen for this project

These are explicit application policies chosen under the user's delegated preference, not official FF3 skill thresholds or catch-mechanics calibration. They describe poor stats, not proof that every failed target was the receiver's fault.

- Receiver baseline: at least **80 targets**, with the upper 95% Wilson confidence bound on catch rate below **30%**. Ordinarily a fresh disjoint window of at least **10 additional targets** must independently satisfy the same confidence rule before exclusion. Unchanged polls never count as more performance.
- Extreme existing aggregate: at least **250 targets**, with the catch-rate upper bound below **15%**, can establish sufficiently poor historical stats immediately. A later good measured window clears the automatic restriction; extreme old totals do not override fresh recovery within that stream.
- Corner: only an explicitly labelled completions/catches-allowed numerator and targets denominator can be graded. The lower confidence bound must exceed **70%** under the normal rule, or **85%** over at least 250 targets for an extreme aggregate. The supplied reports do not verify that this column exists in FF3. Low interception totals, an unnamed ratio or a Corner `Catch/Target` caption are not treated as bad receiving stats. Unknown Corner fields are recorded as **CB_UNVERIFIED** without automatic judgments.

Counter resets and changes of job/UI scope start a new baseline. The ledger is bounded to 512 per-player/role entries and retained in session memory across X reload; it does not invent separate matches or persist private player profiles to a new database. Left-team restrictions clear immediately. Missing data grades expire, with a default **600-second** retention for an already-supported exclusion. Fresh eligible rows update it. Cached UI may lag real performance until the next query; manual allow and TEAM OFF are available immediately.

## Automatic leaving

Automatic leave requires at least **three teammates**, a complete current-roster mapping, a qualified large-sample grade for every teammate, and confirmed poor results for at least **67%** of them. The current table must be visible or come from the qualified idle inspection. All counting grades must have been observed in the last three seconds, the roster stable for ten seconds and the controller running for at least twenty seconds. Manual allowances reduce the poor-player count.

The QB must be idle with no equipped football, native Throwable false and status outside InPlay. AUTO OFF prevents automatic leaving. Immediately before leaving, the main controller saves/copies the full report, confirms all child/parent cleanup, and rechecks team/play/ball state. It requests the local player's `Kick` to leave; it does not kick other players or invent a server-hop endpoint. If both file and clipboard export are unavailable or fail, the exit is blocked so the report is not lost. One request is allowed per controller, with no retry after ambiguous failure. An API return is labelled unconfirmed; no live disconnect is claimed by local tests.

Both automatic exclusion and leaving default on because the user requested them. To disable either independently:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/loader.lua"))({
    FF3 = { TeamStats = { AutoBlacklist = true, AutoLeave = false, AutoInspect = true } }
})
```

`Enabled=false` starts the module off; TEAM can enable it later. Policy fields shown above are configurable through the same table (`MinTargets`, `MinExtraTargets`, `MaxCatchUpper`, `MinAllowedLower`, `SevereTargets`, `SevereCatchUpper`, `SevereAllowedLower`, `MinTeamSize`, `MinBadFraction`, `TeamStableSeconds`, `GraceSeconds`, `RetentionSeconds`). Missing or unsupported stats always mean no action. Receiver stats govern Pelican Auto QB target exclusions; no official game ball-ban/vote remote is sent. Corner results contribute to team assessment without independently excluding a good receiver.

## Reports and validation

Regular COPY includes **TEAM_STATS_BEGIN/END**, per-player confidence/verdict/counters, grouped raw rows, native-inspection capability/status, unverified Corner rows and leave receipts. The separate `PELICAN_FF3_TEAM_STATS_REPORT.txt` and `getgenv().PELICAN_FF3_TEAM_STATS_REPORT` retain the stats report when APIs permit. Full Auto QB evidence remains in `PELICAN_FF3_AUTO_QB_REPORT.txt` and `PELICAN_FF3_LAST_REPORT`. Writes are throttled during normal scanning and forced before leaving or errors. Clipboard/file acceptance is not iPhone readback. Copy reports before quitting Roblox.

Passed **611 mocked assertions**: stats reader/policy/native inspection 44, actual QB integration 28, AWAY 35, guide/peak 66, X reload 9, Goal 63, active-play timeout 25, LOS discovery 66, ground recovery 28, error-stop 12, loader/config 116, rebuilt bundle 55, Threshold menu 45 and existing stats recorder 19. Error-injection warnings are expected. New sources and the rebuilt bundle parse/run through Lua 5.4; no native Luau compiler is available. V22 Auto QB is preserved privately and the public `ff3-v22` tag remains a rollback.

**Not proven in-game:** real stats handler availability/signatures, layout/identity mapping, server data freshness, actual Corner field semantics, decision quality, phone performance, native high throw acceptance/grounding and an actual server exit. The reports establish the WR labels/paths, not the whole integrated behavior. No live Roblox, currency-spending or real Kick tests were performed. Unknown schemas are visible limitations, not silently implemented features. Public files exclude original reports, paid source, archives and private test fixtures.
