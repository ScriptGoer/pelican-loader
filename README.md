# Pelican multi-game loader

One entry point automatically selects FF3 or Threshold from observed PlaceIds.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/loader.lua"))()
```

| Game/place | Route | Pinned release |
|---|---|---|
| FF3 live `82866880824588` | Casual Auto QB; LOS/movement gates and blacklist | `ff3-v20` |
| FF3 practice `81310542478972` | Separate manual practice baseline | `v13` |
| Threshold lobby `78453398695059` | Opt-in feature menu | `threshold-v1` |
| Threshold Chase `129085487311457` | Same menu; Eli/Scrow phase-aware features | `threshold-v1` |

Unknown places load nothing. Threshold universe ID is unverified and is not assumed. Reexecution requires confirmed cleanup of the previous controller.

**Threshold:** tiny feature list for farm, NAV / ESP / fullbright, fast rolls, and separate UI rolls. Nothing starts spending on join. Each roller requires its own START and visible budget. Red kill cancels queued continuation and opens the final report/copy view. [Usage, provenance, and limits](THRESHOLD.md).

**FF3:** V20 validates the known field/LineDown/LineTogo layout before unrelated map traversal finishes, releases valid passing windows without development/safe-hold/animation waits, removes fixed deep flight/range cutoffs and checks predicted defender reach before calling an over-top safety. Covered eligible receivers remain locked for manual throws; automatic release still requires a valid window. Ordinary short-pass preference and clear-burn priority remain. Keep Yuna **QB Aimbot ON**, **Mouse Aimbot OFF**, **Auto Throw Type ON**. AFK/blacklist/LOS gates, native setting restoration, one-attempt ownership, red kill and genuine-error reports remain. [Behavior, validation, assumptions and rollback](FF3_AUTO_QB.md). Local synthetic checks do not establish live catches or phone performance.

**LOS search:** the V15.2 live report finished scanning but found zero active markers. The V2 live search report confirms `workspace.LineDown` and `workspace.LineTogo` are Parts whose visible geometry passes existing checks. Run the separate [V3 search diagnostic](FF3_LOS_SEARCH.md) from any role to inspect the user-identified blue LOS `LineDown`, exact failed checks, and changes during plays. It offers a short clipboard export and selectable, paged REPORT fallback. It stops Pelican Auto QB and never throws; V3 fixes GUI Vector2 sampling errors, and normal routing uses the V20 planner while the diagnostic retains its historical discovery path. The earlier zero-marker failure's exact live trigger remains uncertain.

**Focused LOS trace:** the [historical V15.4.1 trace](FF3_LOS_TRACE.md) is preserved. A subsequent user report shows stable LOS, a completed scan, and 15 requests. V16 is now withdrawn; its later ground-discovery failure is documented in the recovery notes.

**Mobile jump:** optional [jump width helper](FF3_MOBILE_JUMP.md) doubles the native jump button leftward while preserving its right edge and height. It runs independently of Auto QB/Yuna, has an original-width toggle and red restore/kill control, and does not change jump mechanics. Actual FF3/iPhone touch layout is unverified.

Copy reports before leaving Roblox. Clipboard success indicates API acceptance, not iOS readback. Local tests do not prove in-game performance or mechanics. V15.4 is user-reported working; V16 is withdrawn; V20 responsiveness, manual locks, safety classification, catches and iPhone performance remain unverified in Roblox.

Only runtime source, instructions, and checksums are public. Original handoffs, gameplay reports, test harnesses, and supplied paid-source attachments remain outside this distribution. No credentials or private keys are included.
