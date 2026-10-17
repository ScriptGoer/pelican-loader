# FF3 V22: manual high throw-away and a read-only stats recorder

The live route pins `ff3-v22`, controller `PELICAN_FF3_V22`. The regular loader URL is unchanged. V21.1 source is preserved privately in `archive/ff3-v21.1`; its immutable public tag remains available for rollback.

## Manual AWAY

Expand the top-right status bar and tap **AWAY**, beside WR LIST. The button is 54 by 22 pixels and disappears with the expanded controls. It is deliberate manual input, never an automatic response to covered receivers. It can be used with Pelican AUTO/THR or native QBA off, but requires a qualified live Yuna release profile, a living QB, a throwable play, the equipped football and accepted field ground. It does not need an eligible receiver or alter Yuna settings.

The aim uses the preserved native nominal 95 / ball-gravity-28 model and the existing field-coordinate bounds. It compares high-branch trajectories toward both sidelines and chooses the higher modeled boundary crossing. On normal downs with verified LOS/direction, the modeled exit must be downfield of the line; Goal retains its LOS-only exemption. These are manual aiming policies, not newly verified server mechanics. Nominal model velocity is not proof of the server's exact power-to-velocity conversion.

The button cancels Pelican's pending receiver/jump preparation, starts the actual discoverable native Throw asset when available, and submits the existing observed native request shape. It reserves the shared possession before animation initialization. Repeated taps, native manual ownership and an existing Auto QB attempt cannot submit another request in that possession. The same possession observation is used by manual actions and the decision tick, including an authoritative play transition between ticks. Changed play/ball/character, stale launch position or field, and runtime failures cancel before sending. An ambiguous request stops immediately without retry. No animation ID or hook is invented.

**Unverified:** actual server acceptance, exact flight, catch avoidance, natural-looking animation, iPhone layout and intentional-grounding rules. A high modeled sideline crossing does not establish that the game will waive intentional grounding. The report says `GROUNDING_RULE_UNVERIFIED` and records the manual request separately from native receiver/mode calculations.

## Stats and startup-control recorder

Run this separately alongside the loader:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/ff3-v22/diagnostics/ff3_stats_recorder.lua"))()
```

During the 90-second capture, open the teammate Receiver and Corner stat pages in the game's UI. The recorder does not open pages or click Yuna. Keep the relevant username and stat fields visible together. It matches exact current-team usernames to UserIds, records raw visible labels and available leaderstats, and leaves display-name-only matches unassigned. It records visible Yuna image-button paths, safe numeric asset references and startup-control labels for later source/runtime identification. A raw scope match does not establish that every field in the same panel belongs to that player.

A small top-left STATS REC/COPY bar has VIEW and X. VIEW opens a paged, selectable report. Clipboard/file APIs are used when available; reports also remain in `getgenv().PELICAN_FF3_STATS_REPORT` and `PELICAN_FF3_STATS_REPORT.txt` if writing succeeds. Save before leaving Roblox. Clipboard acceptance is not iOS readback. Optional arguments accept `{Duration=300}` for a longer capture, bounded from 5 to 300 seconds.

Scanning is incremental (up to 96 objects per 0.2-second batch, one-millisecond budget checked between objects), capped at 20,000 objects per traversal. Text candidates, image exports and report size are bounded. Data changes are sampled every five seconds and unchanged snapshots are deduplicated. Repeated polls are not independent matches. Capture completion disconnects data listeners and preserves the report UI. X fully stops and cleans the recorder; reexecution confirms old cleanup. The diagnostic remains separate from X reload and never changes gameplay.

## Precisely blocked work

**Yuna auto-config:** the requested wire-button off/on cycle and subsequent QB Aimbot enable are not implemented. The original readable `DPH_Message_readable.txt` is unavailable in this restored workspace and was not committed to either repository. The preserved QB source audit qualifies native calculations and release, but does not include the GUI's wire handler. The recorder can capture candidate controls without guessing or activating them. Reattach the original readable source to verify the actual lifecycle callbacks. The user's executor already auto-executes; no executor startup installation is needed or attempted.

**Automatic stat blacklist / leaving:** not enabled. No supplied source/report verifies the WR/CB stat GUI schema, role-specific denominators, match identity or result ownership. The user delegated the eventual criteria; no further threshold question is required. We first need the recorder report. A later rule must require enough verified role opportunities and repeated independently identified poor results, handle missing data as UNKNOWN, and distinguish poor receiver/coverage outcomes from bad QB placement or volume-only counters. A single poor game, low interception total, duplicate display name or repeatedly polled snapshot is insufficient evidence. No automatic kick, UI activation or remote request is made by this recorder.

These are explicit dependencies, not working features inferred from a similarly named label. There is substantial progress on the manual action and the bounded evidence capture; the double-toggle auto-config and automatic stat actions remain unfinished.

## Retained Auto QB behavior

Automatic receiver/mode planning, short-completion preference, current AFK protection, blacklists, native setting restoration, LOS-only Goal exemption, deep automatic normal jumping and observed peak release, sold-burn cancellation and advisory parallel RUN arrow retain the V21 behavior. X retains V21.1 confirmed-cleanup reload and previous-report preservation. Other FF3/Threshold runtime modules and route pins are unchanged. See [deep-peak and guide details](https://github.com/ScriptGoer/pelican-loader/blob/ff3-v21.1/FF3_AUTO_QB.md).

## Validation

Passed with the actual controller/recorder in private mocked fixtures: manual AWAY 35 assertions; stats recorder 19; peak/guide/cancellation 66; X reload 9; Goal 63; active-play timeout 25; LOS discovery 66; ground recovery 28; error-stop 12; loader/config 116; generated bundle initialization/cleanup 55; Threshold menu 45. Injected errors intentionally emit stop warnings. The 539 assertions verify local control/data/cleanup contracts, not Roblox outcomes.

The bundle is rebuilt from active sources. Changed Lua source files and the generated bundle parse through the available Lua 5.4 library. A broader Lua 5.4-only parse encounters the unchanged navigator's Luau `+=` syntax; that is a dialect limitation, not a newly introduced syntax error. A native Luau compiler is unavailable. No live Roblox, grounding or currency-spending test was performed. Reports, original attachments, archives, paid Yuna code, private fixtures and synthetic test asset IDs remain excluded from the public distribution.
