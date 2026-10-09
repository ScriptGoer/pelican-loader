# Pelican multi-game loader

One entry point automatically selects FF3 or Threshold from observed PlaceIds.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/loader.lua"))()
```

| Game/place | Route | Pinned release |
|---|---|---|
| FF3 live `82866880824588` | Native shared-lock Auto QB rewrite | `ff3-v14` |
| FF3 practice `81310542478972` | Separate manual practice baseline | `v13` |
| Threshold lobby `78453398695059` | Opt-in feature menu | `threshold-v1` |
| Threshold Chase `129085487311457` | Same menu; Eli/Scrow phase-aware features | `threshold-v1` |

Unknown places load nothing. Threshold universe ID is unverified and is not assumed. Reexecution requires confirmed cleanup of the previous controller.

**Threshold:** tiny feature list for farm, NAV / ESP / fullbright, fast rolls, and separate UI rolls. Nothing starts spending on join. Each roller requires its own START and visible budget. Red kill cancels queued continuation and opens the final report/copy view. [Usage, provenance, and limits](THRESHOLD.md).

**FF3:** live Auto QB V14 uses Yuna's shared native receiver lock and final solver, then sends the readable source's ordinary live release request. Launch Yuna separately, before or after this loader, and enable its QB Aimbot with Mouse Aimbot off. Native movement-based and manual modes are preserved. Tap the status pill for AUTO / THR / COPY; THR off selects without releasing. Red X stops and preserves the report. Practice and original live V13 remain byte-identical and practice stays pinned to `v13`. Real executor qualification, server acceptance, and catches are unverified. [Rewrite evidence, usage, and limits](FF3_AUTO_QB.md).

Copy reports before leaving Roblox. Clipboard success indicates API acceptance, not iOS readback. Local tests do not prove in-game performance or mechanics.

Only runtime source, instructions, and checksums are public. Original handoffs, gameplay reports, test harnesses, and supplied paid-source attachments remain outside this distribution. No credentials or private keys are included.
