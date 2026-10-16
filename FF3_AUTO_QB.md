# FF3 V20.2: faster field readiness, immediate windows and manual receiver locks

V19 was reported as substantially better in-game. The remaining reported problems were slow LOS searching, overly strict deep attempts, unwanted release delays and losing the target when coverage blocked automatic passing. V20 changes these specific gates rather than replacing the native aiming integration.

## V20.2: bypass LOS during Goal while Auto QB stays active

The V20.1 whole-controller pause was the wrong interpretation of the user's request and is withdrawn. V20.2 keeps automatic selection, native mode comparison, manual target locking and automatic release active on a visible goal-to-go HUD reading. Only LOS-derived requirements are bypassed: marker discovery/stability, the receiver/arrival minimum six-yard depth, and the QB-past-LOS check. Normal downs immediately restore these requirements and revalidate the current lines before passing.

AFK protection is unchanged. A receiver still needs current, observed continuous movement and travel; stationary teammates, including one who stops after selection, are rejected. Human teammate/team, blacklist, health, actual field bounds, receiver reachability, native tuple/arrival validation and defender path/arrival checks remain. AUTO/THR, manual ownership, errors/cleanup and one request per possession are unchanged. Goal text does not fabricate a catch opportunity.

During the bypass, current LOS and attack direction are explicitly unavailable rather than copied from a previous play or guessed from movement/camera. Native trajectory risk still evaluates every defender's reachable lane and arrival. Classifications/priorities requiring a verified downfield direction are unavailable; regular safe-completion comparison remains active. `LOS_STATUS|GOAL_TO_GO_LOS_BYPASSED` and `GOAL_TO_GO_LOS_BYPASSED|true` identify this mode. Observed ground geometry is still needed for independent field/arrival checks; missing ground is not silently invented. Goal transitions invalidate prior planning caches without creating another possession/request allowance.

The existing HUD reader recognizes visible ordinal/numeric, ampersand/and, case and rich-text variants, ignores hidden stale labels and uses the existing bounded scan. Final release refreshes the HUD: Goal appearing can bypass LOS that tick, while Goal disappearing restores normal LOS gates before a request. These are client-visible HUD observations, not an authoritative server goal-state guarantee.

63 new actual-controller mocked checks cover all Goal forms with hidden line markers, a QB past the old line, a receiver within the old six-yard exclusion, automatic passing/mode evaluation, AFK and stationary-with-velocity exclusions, a receiver stopping after selection, coverage/manual-only selection, blacklist/off-field/dead-play/AUTO gates, normal-down restoration, one-attempt ownership, transitions during native solves and missing field geometry. Existing responsiveness (62), timeout (25), LOS (66), ground recovery (28), error-stop (12), loader (89) and bundle (55) checks pass, as does native Luau compilation. The 37 historical V20.1 pause checks are pinned to its exact preserved source, not presented as current behavior. No live Roblox execution occurred; real HUD transitions, catchability and iPhone performance remain unverified.

## Changes

**LOS readiness:** V19 required the initial map traversal to finish even when the observed field and named lines were already valid. V20 directly checks `workspace.Models.Field.Ground`, `workspace.LineDown` and `workspace.LineTogo`. The known ground must pass the existing size, position, orientation and ancestry checks; both named root Parts must be unique, visible, anchored, correctly colored, full-width, aligned strips. Root-level marker candidates are collected together. Existing line separation, discovered HUD agreement, ambiguity and 0.25-second stability checks still apply. Discovery runs before Yuna/QB/possession gates, so it can prepare while another player has the ball or before Yuna starts.

This explicitly permits the validated known layout before unrelated nested map traversal finishes. The bounded background traversal continues; a contradictory nested marker discovered later revokes readiness. It cannot guarantee the absence of an undiscovered nested contradiction. Other layouts and missing/hidden named lines still require the background discovery path. V20.2 bypasses LOS during goal-to-go rather than using the historical goal-line fallback. Reports distinguish `LOS_READY_SOURCE`, `LOS_FAST_PATH_STATUS` and `LOS_SCAN_COMPLETE`; readiness does not pretend the scan has finished. Root enumeration is capped at 4,096 objects and refreshed on root additions/replacements and periodically; it uses no per-Part listeners or per-frame full descendant scan.

**Release timing:** all valid automatic windows now bypass the old two-second development hold, 0.24-second stable-open hold and animation-progress wait. The existing native Throw asset starts if discoverable, without delaying release. The WAIT pacing control is removed; AUTO, THR, WR LIST, COPY and red kill remain. This means immediate release when a window passes evaluation, rather than a zero-latency guarantee: evaluation remains on the 0.12-second decision interval, uses bounded native calls and must obtain valid observations. The existing AFK filter still requires recent continuous movement (0.65 seconds and observed travel). Verified LOS, at least six yards beyond LOS, current human teammate, blacklist and field restrictions remain.

**Deep throws:** fixed 330-stud range and 4.5-second flight vetoes are removed. A deeper aligned defender no longer blocks an elevated pass solely for being in front of the receiver. The candidate's actual native flight is checked for whether that defender can reach its arrival or lane. A realistically reachable front safety or other interception risk still blocks automatic passing. Arrival below the verified field plane is invalid, as are inconsistent native aim/arrival tuples, unreachable receiver endpoints, field exits and other existing native validity failures. This adds no arbitrary jump-catch height or new power/lead settings.

**Manual receiver lock:** the best evaluated eligible receiver remains locked when coverage blocks automatic release. If no native mode supplies a valid automatic trajectory, the fallback compares predicted separation and travel estimate, with incumbent stability. `LOCK_ONLY|true` and a `MANUAL_LOCK_...` gate identify these states. This keeps normal Yuna manual input pointed at the intended receiver; it does not send an automatic request into coverage. Safe windows take priority when they appear. AUTO OFF releases Pelican's lock; THR OFF retains selection while disabling automatic release. Existing deliberate user/native lock edits are preserved. Blacklisted, AFK, dead, opposing or inside-LOS players do not become fallback targets. Missing trustworthy field/game state still blocks targeting.

Native Bullet/Fit/Dime/Jump outputs are compared as before. Protected solves restore Yuna's automatic mode and selection settings before returning to input. Clear-burn priority, ordinary short-completion preference, target stability, fresh final trajectory checks, one attempt per possession, no ambiguous retry, cleanup and error/report preservation remain. No automatic jump/apex gate returns. Practice, Threshold, historical diagnostics and the separate mobile jump-button helper are unchanged.

## Usage and rollback

Keep Yuna QB Aimbot ON, Mouse Aimbot OFF and Auto Throw Type ON. The normal public loader pins the FF3 live module to `ff3-v20.2`, controller `PELICAN_FF3_V20`:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/loader.lua"))()
```

The matching immutable V20.2 loader is also available at `ff3-v20.2/loader.lua`. For rollback, run the matching V19 loader:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/ff3-v19/loader.lua"))()
```

Save COPY reports before leaving Roblox. Missing field objects before kickoff are readiness waits; only a ready throwable QB possession consumes the existing 20-second field-discovery deadline. Genuine runtime/native-solver/request errors stop and preserve their cause. A covered/manual lock or intentional Goal LOS bypass is an expected decision state, not an error.

## Evidence and validation

The new actual-controller suite passes 62 synthetic assertions. Identical large-map fixtures reproduce V19's unfinished-scan wait and V20's named-field readiness. They cover direct-path invalidation and later nested ambiguity, startup before Yuna, ordinary release before two seconds and in a single eligible tick, animation without waiting, covered/manual locking, transition to a safe automatic request, failed native trajectory fallback, external edits, AUTO cleanup, reachable versus unreachable front safety, a valid five-second native flight, buried arrival rejection, AFK/blacklist/LOS exclusions and frame-call limits.

Maintained timeout (25), LOS (66), ground recovery (28), error-stop (12), loader/config (89) and bundle initialization/cleanup (55) checks pass. Historical V17 (89), V18 (68) and V19 (35) suites run against their preserved sources, separately from V20. Native Luau compilation, exact V19 preservation, bundle generation and unchanged other-module checks pass. Public release checksums cover only runtime and documentation; private reports, original attachments, fixtures and paid source remain private.

These are local checks, not a Roblox catch test or iPhone performance measurement. Defender pursuit/reach estimates and receiver travel bounds remain uncalibrated against authoritative server catch mechanics. Longer native flights increase prediction uncertainty. The new fast LOS path's layout assumption, mobile release responsiveness, manual input/animation visibility, deep catchability and live safety classification need in-game validation. Native Dime/Jump arrival mismatches are still rejected and reported rather than silently corrected with invented offsets. The original paid attachment is not available in this execution environment; this update uses the preserved integration, source audit and current code, without claiming a fresh inspection of that attachment or the montage.
