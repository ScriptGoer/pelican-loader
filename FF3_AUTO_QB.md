# FF3 V20.1: faster field readiness, immediate windows and manual receiver locks

V19 was reported as substantially better in-game. The remaining reported problems were slow LOS searching, overly strict deep attempts, unwanted release delays and losing the target when coverage blocked automatic passing. V20 changes these specific gates rather than replacing the native aiming integration.

## V20.1 goal-to-go pause

At the user's request, a visible down-and-distance HUD reading such as `1st & Goal`, `4th & Goal` or `10 and goal` pauses Pelican Auto QB. It releases Pelican's receiver lock, cancels release preparation and clears the LOS discovery deadline. It does not require a yellow or end-zone marker to establish this pause. Normal Yuna settings/manual input remain available; the Pelican UI stays present. Normal downs automatically leave the pause and revalidate LOS before selecting or passing again. AUTO/THR controls retain the user's choices. Reports identify `GOAL_TO_GO_PAUSED`, so this expected pause is not confused with a missing-field error.

The previous goal-to-go branch tried to substitute a separately discovered goal-line strip for the yellow first-down marker. That code can report `LOS_GOAL_UNKNOWN` if no suitable strip is found; without a new live report, the precise cause of the user's lost LOS remains unverified. V20.1 deliberately pauses this situation instead of inventing a new goal-line calculation. Goal text is checked before field readiness and again during the fresh release checks. Hidden stale text is ignored; a visible Goal reading takes precedence during conflicting HUD transitions. HUD discovery still uses the existing bounded scanner.

37 new actual-controller mocked assertions cover all four downs, number/and/rich-text variants, missing field/goal markers, waiting beyond the field deadline without an error, target restoration, normal-down recovery, conflicting/hidden text, a Goal transition during native calculation and cleanup. Existing V20 responsiveness (62), timeout (25), LOS (66), ground recovery (28), error-stop (12), loader (89) and bundle (55) checks also pass, as does native Luau compilation. This validates local control flow; actual FF3 HUD discovery/transitions still need live testing.

## Changes

**LOS readiness:** V19 required the initial map traversal to finish even when the observed field and named lines were already valid. V20 directly checks `workspace.Models.Field.Ground`, `workspace.LineDown` and `workspace.LineTogo`. The known ground must pass the existing size, position, orientation and ancestry checks; both named root Parts must be unique, visible, anchored, correctly colored, full-width, aligned strips. Root-level marker candidates are collected together. Existing line separation, discovered HUD agreement, ambiguity and 0.25-second stability checks still apply. Discovery runs before Yuna/QB/possession gates, so it can prepare while another player has the ball or before Yuna starts.

This explicitly permits the validated known layout before unrelated nested map traversal finishes. The bounded background traversal continues; a contradictory nested marker discovered later revokes readiness. It cannot guarantee the absence of an undiscovered nested contradiction. Other layouts and missing/hidden named lines still require the background discovery path. V20.1 pauses goal-to-go rather than using the historical goal-line fallback. Reports distinguish `LOS_READY_SOURCE`, `LOS_FAST_PATH_STATUS` and `LOS_SCAN_COMPLETE`; readiness does not pretend the scan has finished. Root enumeration is capped at 4,096 objects and refreshed on root additions/replacements and periodically; it uses no per-Part listeners or per-frame full descendant scan.

**Release timing:** all valid automatic windows now bypass the old two-second development hold, 0.24-second stable-open hold and animation-progress wait. The existing native Throw asset starts if discoverable, without delaying release. The WAIT pacing control is removed; AUTO, THR, WR LIST, COPY and red kill remain. This means immediate release when a window passes evaluation, rather than a zero-latency guarantee: evaluation remains on the 0.12-second decision interval, uses bounded native calls and must obtain valid observations. The existing AFK filter still requires recent continuous movement (0.65 seconds and observed travel). Verified LOS, at least six yards beyond LOS, current human teammate, blacklist and field restrictions remain.

**Deep throws:** fixed 330-stud range and 4.5-second flight vetoes are removed. A deeper aligned defender no longer blocks an elevated pass solely for being in front of the receiver. The candidate's actual native flight is checked for whether that defender can reach its arrival or lane. A realistically reachable front safety or other interception risk still blocks automatic passing. Arrival below the verified field plane is invalid, as are inconsistent native aim/arrival tuples, unreachable receiver endpoints, field exits and other existing native validity failures. This adds no arbitrary jump-catch height or new power/lead settings.

**Manual receiver lock:** the best evaluated eligible receiver remains locked when coverage blocks automatic release. If no native mode supplies a valid automatic trajectory, the fallback compares predicted separation and travel estimate, with incumbent stability. `LOCK_ONLY|true` and a `MANUAL_LOCK_...` gate identify these states. This keeps normal Yuna manual input pointed at the intended receiver; it does not send an automatic request into coverage. Safe windows take priority when they appear. AUTO OFF releases Pelican's lock; THR OFF retains selection while disabling automatic release. Existing deliberate user/native lock edits are preserved. Blacklisted, AFK, dead, opposing or inside-LOS players do not become fallback targets. Missing trustworthy field/game state still blocks targeting.

Native Bullet/Fit/Dime/Jump outputs are compared as before. Protected solves restore Yuna's automatic mode and selection settings before returning to input. Clear-burn priority, ordinary short-completion preference, target stability, fresh final trajectory checks, one attempt per possession, no ambiguous retry, cleanup and error/report preservation remain. No automatic jump/apex gate returns. Practice, Threshold, historical diagnostics and the separate mobile jump-button helper are unchanged.

## Usage and rollback

Keep Yuna QB Aimbot ON, Mouse Aimbot OFF and Auto Throw Type ON. The normal public loader pins the FF3 live module to `ff3-v20.1`, controller `PELICAN_FF3_V20`:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/loader.lua"))()
```

The matching immutable V20.1 loader is also available at `ff3-v20.1/loader.lua`. For rollback, run the matching V19 loader:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/ff3-v19/loader.lua"))()
```

Save COPY reports before leaving Roblox. Missing field objects before kickoff are readiness waits; only a ready throwable QB possession consumes the existing 20-second field-discovery deadline. Genuine runtime/native-solver/request errors stop and preserve their cause. A covered/manual lock is an expected decision state, not an error.

## Evidence and validation

The new actual-controller suite passes 62 synthetic assertions. Identical large-map fixtures reproduce V19's unfinished-scan wait and V20's named-field readiness. They cover direct-path invalidation and later nested ambiguity, startup before Yuna, ordinary release before two seconds and in a single eligible tick, animation without waiting, covered/manual locking, transition to a safe automatic request, failed native trajectory fallback, external edits, AUTO cleanup, reachable versus unreachable front safety, a valid five-second native flight, buried arrival rejection, AFK/blacklist/LOS exclusions and frame-call limits.

Maintained timeout (25), LOS (66), ground recovery (28), error-stop (12), loader/config (89) and bundle initialization/cleanup (55) checks pass. Historical V17 (89), V18 (68) and V19 (35) suites run against their preserved sources, separately from V20. Native Luau compilation, exact V19 preservation, bundle generation and unchanged other-module checks pass. Public release checksums cover only runtime and documentation; private reports, original attachments, fixtures and paid source remain private.

These are local checks, not a Roblox catch test or iPhone performance measurement. Defender pursuit/reach estimates and receiver travel bounds remain uncalibrated against authoritative server catch mechanics. Longer native flights increase prediction uncertainty. The new fast LOS path's layout assumption, mobile release responsiveness, manual input/animation visibility, deep catchability and live safety classification need in-game validation. Native Dime/Jump arrival mismatches are still rejected and reported rather than silently corrected with invented offsets. The original paid attachment is not available in this execution environment; this update uses the preserved integration, source audit and current code, without claiming a fresh inspection of that attachment or the montage.
