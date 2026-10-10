# Focused FF3 LOS trace

The V15.4 live report reaches passing readiness (possession epoch/age recorded) but remains at LOS_SEARCHING. It visits 21,153 objects with 1,582 pending roots, never marks initial discovery complete, and makes zero native solver calls or automatic attempts. This establishes that the current block is before receiver aiming/release; becoming QB does not resolve it. No runtime exception is recorded in that report.

The report's `retained=false` is a fresh `FindFirstChild` result used as a weak-table key. It is not a geometry verdict and cannot alone prove the Part was never accepted. Local public-API proxy/weak-handle counterexamples reproduce false export membership after successful immediate retention. Separate tests reproduce type rejection, parent reference inequality despite structural ancestry, and differing immediate lookup references. These are diagnostic hypotheses, not proof that Delta/Roblox has any of those behaviors in this session.

Initial completion is also tied to the whole discovery queue emptying at least once. Source-level tests reproduce continuous early Model creation keeping that queue nonempty after original root traversal finishes. Later churn after initial completion does not revoke it. The actual report lacks initial-root progress and queued classes, so it cannot establish which stage or objects caused this live backlog.

## Run one bounded trace

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/ff3-los-trace-v1/diagnostics/ff3_los_trace.lua"))()
```

Run from any role with field lines visible. Yuna can remain running so its scene changes are represented. The trace requires confirmed cleanup of an active Pelican Auto QB or older LOS search; it does not execute Yuna, invoke its solver, acquire a receiver lock, or send a throw request. Its field-only guard returns before profile discovery and all gameplay selection/release on every tick; UI or context options cannot enable passing.

It uses the actual Auto QB scanner and LOS predicates, with unchanged work/timing limits and completion condition. `tools/build_ff3_los_trace.py` generates it mechanically from the current source and writes the input SHA256 in its header. Unreachable gameplay function definitions are retained to keep derivation reviewable; the fixed field-only guard prevents their execution.

The trace records each named object's typeof, class, IsA result, parent class/equality, ancestry, exact acceptance, immediate stored key, and equality/key results from another lookup. It also records original-root traversal completion, current root/stack, queued classes, scan progress age, and the existing counts. It keeps only metadata strings, not new strong references to named Parts, so it does not intentionally mask a weak-reference issue.

A failed named-object check or runtime exception stops the trace and preserves its exact cause immediately. Missing objects are reported and may appear during startup. Otherwise it takes a snapshot and stops on the first scheduled tick after 20 seconds of the runtime clock. Engine calls/persistence cannot be preempted by that deadline. COPY exports an interim snapshot; red X ends it earlier. Stopping disconnects its listeners, removes its UI, and leaves Yuna running. Teleport stops and preserves it. It does not resume Auto QB or queue teleports.

The final report is automatically copied through the supported clipboard API and written, when available, to **PELICAN_FF3_LOS_TRACE_REPORT.txt**; the executor-session fallback is `getgenv().PELICAN_FF3_LOS_TRACE_REPORT`. Send that report before quitting Roblox. API acceptance does not prove iOS clipboard readback. If the file/clipboard APIs are unavailable, the session report exists only until the executor session ends.

This trace collects the missing checks. It does not claim a corrected live LOS or require repeating selection/aim/catch tests. The normal loader's v15.4.1 change is only exception shutdown/reporting; LOS discovery behavior remains V15.4 pending trace evidence.

## Stop on exceptions

Auto QB v15.4.1 stops immediately on a runtime-tick exception, a native solver exception, or an ambiguous throw-request exception. It saves STOP_REASON and FATAL_ERROR, releases its owned lock/listeners/UI, and makes no subsequent automatic retry, including across a later play. No candidate/open-receiver/readiness gate is relaxed. Ordinary waiting/eligibility states and unavailable report APIs remain explicitly reported states.

Local validation includes 28 actual-script trace checks and 12 error-stop checks, plus the existing controller, loader, diagnostic, and bundle checks. None establishes the live executor's identity semantics, scan completion, iPhone copying, or automatic throwing.
