# FF3 LOS search

The October 10 V15.2 report completed a 31,982-instance scan with no cap, but recognized zero active markers and never called the native throw solver. It does not identify which marker checks failed. The standalone search records public instance geometry and the exact V15.2 discovery/active checks, without changing the automatic receiver policy.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/ff3-los-search-v2/diagnostics/ff3_los_search.lua"))()
```

Run in the observed FF3 live place. It works before or alongside Yuna, with no closure reflection dependency. It stops an existing Pelican Auto QB through its normal cleanup and preserves that controller's report. If cleanup is not acknowledged, search startup fails before it creates UI. Yuna's controls and settings remain its own. Search never throws, calls game remotes, rolls, or queues teleport continuation.

1. Let the tiny `SEARCH <count>` indicator reach `WATCH B… Y…`. A large scene takes several seconds to traverse; the increasing count shows progress. Background searches continue afterward.
2. Run from any role while the field lines are visible; neither QB status nor possession is required. The diagnostic samples existing objects as they move, change color, hide, or become enabled. The user identifies `LineDown` as the blue LOS; V2 pins every object with that exact name regardless of geometry and records its actual runtime class/path instead of inferring its type from the Explorer icon. Direct root-level objects are recorded immediately; nested objects are found by the bounded traversal. REPORT can be used as soon as the name is found.
3. Tap the status pill, then **COPY** for a short `LineDown` report. **REPORT / MANUAL COPY** opens selectable text; **SELECT** focuses/selects the page, or long-press its text to use the native copy menu. Switch **LineDown / FULL** for the complete inventory, use arrows for pages, and **COPY PAGE** to send only the displayed snapshot page. Pages contain at most 3,000 bytes. Close/reopen REPORT to refresh the frozen snapshot. Capture the report before leaving Roblox. **RESCAN** starts a fresh sweep immediately. Red **X** saves/copies and stops the search; teleport also stops and preserves it.
4. To return to Auto QB, stop the search and re-run the normal multi-game loader. Ending the diagnostic does not automatically restart throwing. The normal loader still uses V15.2; search is a separate opt-in entry point.

`WATCH B1 Y1` counts retained objects whose individual geometry passes the V15.2 comparison. It does not establish a unique continuous full-width LOS pair or a trustworthy direction. Search is evidence collection, not an Auto QB replacement.

## What it records

- Plausible field strips even when currently outside the accepted field region, hidden, or differently colored; ranked colored parts; straight/curved/disabled/incomplete Beams; relevant GUI strips, down labels, and public context values.
- Exact positions, dimensions, colors, visibility, anchoring, orientation, projected field width/depth, endpoints, curves, and each failed initial-discovery / added-discovery / active-geometry check. The source comparisons reproduce V15.2 predicates; they do not loosen production thresholds.
- First observed state, subsequent changes, last qualifying geometry, sweep completion/class counts, maximum tick duration, candidate truncation, and the previous Auto QB's gate summary. First/last qualifying snapshots survive a later line becoming hidden.

Records stay bounded: eight pinned `LineDown` objects, four ground objects, 64 parts, 24 Beams, 16 GUI objects, 24 public values, and 96 recent events. Higher-ranked line-like shapes replace lower-ranked noise. The report explicitly counts replacements/drops; a truncated inventory cannot prove that no other marker exists. No complete scripts, credentials, reflection graphs, or private handoffs are copied into reports.

Traversal uses up to 80 units of work or 1.5 ms per 40 ms tick, with processed queue entries released. It refreshes eight retained objects per 80 ms and repeats a complete sweep after a three-second gap. A single engine call or persistence operation cannot be preempted by that budget. It uses `GetChildren` in chunks and does not call `GetDescendants`. Several checks may run for one object; the budget is not a hard bound on the whole callback's duration. Candidate refreshes are not frame-complete.

Reports are retained in `getgenv().PELICAN_FF3_LOS_SEARCH_REPORT` and, where supported, `PELICAN_FF3_LOS_SEARCH_REPORT.txt`, saved periodically and on copy/kill/teleport. Clipboard calls use `setclipboard`, or `toclipboard` when the former is absent. Each button action makes one clipboard call before file I/O. A false return or exception is recorded as failure, with its error. `VERIFIED` requires exact supported `getclipboard` readback; `SENT?` means only that the API returned without an error. Readback mismatches and unavailability automatically expose the manual report. Unrelated clipboard contents are never written into reports. Unavailable or failed clipboard/file APIs are reported; the executor-session string is not persistence across app exit. Native iPhone text selection/copy still needs live verification.

## Evidence and remaining work

An actual-controller local reproduction shows V15.2 ignoring blue/yellow strips initially outside its discovery bounds, then continuing to ignore the same instances after they move into valid geometry. The diagnostic finds the valid current objects, retains earlier off-field failures, and records their later activation. Repeated sweeps also recover objects configured after insertion. This explains a plausible source-level regression; the supplied live report does not prove that those objects or transitions occurred in the user's game.

V2 incorporates the user-confirmed blue LOS name `LineDown`; runtime class, full path, and geometry remain to be collected. The user also reported copy failure. The false-return handling bug is proven in the source, but the exact failure on the user’s executor was not supplied. The manual viewer and smaller focused export make evidence accessible independently of a successful clipboard bridge.

The appropriate production correction depends on the diagnostic: retain/requalify existing shapes if their lifecycle caused the miss; investigate different geometry/color/rendering if those predicates rejected the real marker. No guessed LOS or vertical threshold is added. V14's user-reported throw success remains the release-path baseline.

Local validation: **75 actual-script checks** cover observed geometry without Yuna, bounded large-scene traversal, zero remote/throw requests, takeover and lock cleanup, exact rejection details, off-field movement, delayed configuration, color/visibility details and preserved earlier active snapshots, disabled Beam activation, public values/HUD, real menu buttons, report preservation, reexecution, teleport, missing/failing executor APIs, failed-cleanup retry, unsupported places, operation without reflection, pinned names amid inventory truncation, actual selectable-text controls, frozen snapshots, lossless bounded pagination, false/throwing clipboard results, alternate API selection, exact readback matching/mismatch, clipboard privacy, and focus cleanup. Native Luau compilation passes. Production routing and gameplay payload bytes are unchanged. Live Roblox discovery completeness and iPhone performance remain unverified.
