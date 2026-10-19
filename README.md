# Pelican multi-game loader

One entry point automatically selects FF3 or Threshold from observed PlaceIds.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/loader.lua"))()
```

| Game/place | Route | Pinned release |
|---|---|---|
| FF3 live `82866880824588` | Casual Auto QB; LOS/movement gates and blacklist | `ff3-v26.10` |
| FF3 practice `81310542478972` | Separate manual practice baseline | `v13` |
| Threshold lobby `78453398695059` | Opt-in feature menu | `threshold-v1` |
| Threshold Chase `129085487311457` | Same menu; Eli/Scrow phase-aware features | `threshold-v1` |

Unknown places load nothing. Threshold universe ID is unverified and is not assumed. Reexecution requires confirmed cleanup of the previous controller.

**Threshold:** tiny feature list for farm, NAV / ESP / fullbright, fast rolls, and separate UI rolls. Nothing starts spending on join. Each roller requires its own START and visible budget. Red kill cancels queued continuation and opens the final report/copy view. [Usage, provenance, and limits](THRESHOLD.md).

**FF3:** V26.10 adds folded **ANY / FRIENDS**, default ANY, with nonblocking verified friend lookup. The automatic team message is now exactly **`cut back`**. [Receiver filter, lookup and cleanup](FF3_FRIENDS.md). V26.9 adds folded **NORMAL / DEEP / SHORT** plans. DEEP uses the confirmed 20 yards beyond LOS plus observed deep-route comebacks; SHORT favors shallow completions and requires a wide-open deep exception. Native Jump is preferred only when its own flight remains safely ahead of the defense, without changing Angle/Power input mode. [Plans, controls and limits](FF3_PASS_PLANS.md). V26.8 requires the existing strict conservative lane clearance in Moderate while retaining its looser receiver-favored endpoint/race limits. Trust remains the deliberate tight-contest option. [Deep coverage correction](FF3_MODERATE.md). V26.7 checks native returned flight-time comfort before automatic release, lowers the old request floor, and refines slower power from the native launch origin. Uploads retain exact current verified leads even before a throw, plus native power-control status. [Comfort behavior and limits](FF3_BULLET_COMFORT.md). V26.6 adds passive post-throw ball/receiver recording and a folded read-only **LEADS** panel with current native X/Y values. Dive-like motion uses body angle, hands-forward pose and airborne/physics state; no playing animation is required. Required movement and fault remain unknown, and numeric style comparisons require controlled pose calibration and matched evidence. [Evidence, advice gates and limits](FF3_RECEIVER_EVIDENCE.md). V26.5 adds an optional separate auto-execute companion: type exactly **a** in your own Roblox chat to upload retained current-session data. It shares the QB recorder and sole upload worker, keeps cloud uploads manual, and adds no permanent HUD. [Companion setup and limits](FF3_CHAT_UPLOAD.md). Device history remains automatic; private credentials stay in the local device artifact. Existing distance/coverage Bullet power, strict Bullet risk, timing-only Fit, opt-in JB, immediate jump/release, Goal LOS, AFK/manual exclusions, COPY/X, AWAY and optional comeback chat remain. Keep Yuna **QB Aimbot ON**, **Mouse Aimbot OFF**, **Auto Throw Type ON**. [Throw behavior](FF3_AUTO_QB.md) · [History and storage](FF3_HISTORY.md). Immutable `ff3-v26.9` preserves the prior release.

Historical stats/GUI diagnostics are separate tools, not regular-loader dependencies. The V23 runtime is preserved in its immutable tag; its stats integration is withdrawn.

**LOS search:** the V15.2 live report finished scanning but found zero active markers. The V2 live search report confirms `workspace.LineDown` and `workspace.LineTogo` are Parts whose visible geometry passes existing checks. Run the separate [V3 search diagnostic](FF3_LOS_SEARCH.md) from any role to inspect the user-identified blue LOS `LineDown`, exact failed checks, and changes during plays. It offers a short clipboard export and selectable, paged REPORT fallback. It stops Pelican Auto QB and never throws; V3 fixes GUI Vector2 sampling errors, and normal routing uses the V21 planner while the diagnostic retains its historical discovery path. The earlier zero-marker failure's exact live trigger remains uncertain.

**Focused LOS trace:** the [historical V15.4.1 trace](FF3_LOS_TRACE.md) is preserved. A subsequent user report shows stable LOS, a completed scan, and 15 requests. V16 is now withdrawn; its later ground-discovery failure is documented in the recovery notes.

**Mobile jump:** optional [jump width helper](FF3_MOBILE_JUMP.md) doubles the native jump button leftward while preserving its right edge and height. It runs independently of Auto QB/Yuna, has an original-width toggle and red restore/kill control, and does not change jump mechanics. Actual FF3/iPhone touch layout is unverified.

Copy reports before leaving Roblox. Clipboard success indicates API acceptance, not iOS readback. Local tests do not prove in-game performance or mechanics. V15.4 is user-reported working; V16 is withdrawn; V26 risk quality, exact overthrow causes, close-power compatibility, Goal direction, catches and iPhone performance remain unverified in Roblox.

Only runtime source, instructions, and checksums are public. Original handoffs, gameplay reports, test harnesses, and supplied paid-source attachments remain outside this distribution. No credentials or private keys are included.
