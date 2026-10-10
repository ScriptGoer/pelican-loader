# Pelican multi-game loader

One entry point automatically selects FF3 or Threshold from observed PlaceIds.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/loader.lua"))()
```

| Game/place | Route | Pinned release |
|---|---|---|
| FF3 live `82866880824588` | Casual Auto QB; LOS/movement gates and blacklist | `ff3-v15.4` |
| FF3 practice `81310542478972` | Separate manual practice baseline | `v13` |
| Threshold lobby `78453398695059` | Opt-in feature menu | `threshold-v1` |
| Threshold Chase `129085487311457` | Same menu; Eli/Scrow phase-aware features | `threshold-v1` |

Unknown places load nothing. Threshold universe ID is unverified and is not assumed. Reexecution requires confirmed cleanup of the previous controller.

**Threshold:** tiny feature list for farm, NAV / ESP / fullbright, fast rolls, and separate UI rolls. Nothing starts spending on join. Each roller requires its own START and visible budget. Red kill cancels queued continuation and opens the final report/copy view. [Usage, provenance, and limits](THRESHOLD.md).

**FF3:** V15 preserves the user-confirmed V14 native lock/solver/release path. Automatic throws wait at least three seconds and require a moving receiver at least six yards beyond the observed LOS. No idle, inside-LOS, or guessed-LOS fallback throws. Tap the small status pill for AUTO / THR / COPY, **WR LIST** to block/allow teammates, and **WAIT 3s** to choose a 3/4/5-second minimum hold. Opening the dropdown pauses automatic release. Launch Yuna separately with QB Aimbot on and Mouse Aimbot off. Practice, original V13, and the `ff3-v14` tag are preserved. V15.2 fixes the sticky LOS scan cap caused by unrelated Beams and retained map objects; real LOS is still required. V15.3 now retains/rechecks the observed root Parts `LineDown` and `LineTogo` through late configuration and replacement, preserving all current geometry checks. V15.4 moves field tracking before Yuna/play/ball gates so it updates regardless of role; the initial ambiguity scan still must complete before passing. The fixes and gates/UI still need live validation. [Policy, usage, and evidence](FF3_AUTO_QB.md).

**LOS search:** the V15.2 live report finished scanning but found zero active markers. The V2 live search report confirms `workspace.LineDown` and `workspace.LineTogo` are Parts whose visible geometry passes existing checks. Run the separate [V3 search diagnostic](FF3_LOS_SEARCH.md) from any role to inspect the user-identified blue LOS `LineDown`, exact failed checks, and changes during plays. It offers a short clipboard export and selectable, paged REPORT fallback. It stops Pelican Auto QB and never throws; V3 fixes GUI Vector2 sampling errors, and normal routing now uses V15.4 background field tracking. The earlier zero-marker failure's exact live trigger remains uncertain.

Copy reports before leaving Roblox. Clipboard success indicates API acceptance, not iOS readback. Local tests do not prove in-game performance or mechanics.

Only runtime source, instructions, and checksums are public. Original handoffs, gameplay reports, test harnesses, and supplied paid-source attachments remain outside this distribution. No credentials or private keys are included.
