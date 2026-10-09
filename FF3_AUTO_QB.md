# FF3 live Auto QB V14

The live route now loads `games/ff3/auto_qb.lua` at `ff3-v14`. The previous `games/ff3/live.lua` is preserved byte-for-byte, as is practice. Threshold modules and route pins are unchanged. Re-run the same public loader to obtain V14.

Launch Yuna separately, before or after Pelican, and enable **QB Aimbot**. Pelican waits for a matching live instance. Native Mouse Aimbot must be off because it deliberately substitutes a mouse position for the selected receiver. Enable Yuna's Auto Throw Type to retain its movement-based selection; if disabled, Pelican preserves its manual mode instead. Existing SmartPass, AntiOOB, lead, angle, power, and mode settings remain untouched.

The top-right 138×22 status pill expands AUTO / THR / COPY controls. AUTO off restores the owned lock. THR off selects and previews without sending requests. The red 22×22 X stops Pelican through the loader and exposes the final report. Supported `writefile` saves `PELICAN_FF3_AUTO_QB_REPORT.txt`; COPY, stopping, and teleport attempt clipboard preservation. `PELICAN_FF3_LAST_REPORT` retains a report in executor memory. API acceptance is not iOS clipboard readback. Copy before leaving Roblox; fresh rejoin execution is not established.

## Source-supported failure and correction

Evidence is the supplied `DPH_Message_readable.txt`, SHA-256 `ff065de978a9b2d037068658ddf03898913ebad40ec5fd0f4bb6796191a3c8f2`. Only the readable QB section was inspected. The VM wrapper was not executed or published; its relationship to the user's currently running Yuna build remains unverified.

| Contract in the readable source | V13 limitation | V14 behavior |
|---|---|---|
| `fn13`, lines 1213–1283, reads shared `Locked`, `LockedOnto`, `LockedOntoName`; the locked branch returns one model | Replaces a getter captured by one Heartbeat callback and expects an unlocked model/distance pair | Owns the native lock triplet; validates a living human teammate; restores only its own writes |
| `fn37`, lines 1922–1966, calls its own captured `fn13` | A different closure's captured getter need not change with the preview getter | Qualifies the same final solver across preview and release and the same settings table in its native selector |
| `fn37` returns origin, power, flight time, final velocity, and mode; its returned/displayed angle is an initial angle | Reconstructs the throw path from HUD values | Uses returned final velocity directly for interception evaluation and the release request |
| Native aiming release is an `InputBegan` callback, lines 2287–2319 | `Tool:Activate()` does not emit `UserInputService.InputBegan` | Sends the readable live request directly, after current game throw permission, native target, and trajectory checks |

The separate getter capture and Tool/input mismatch are reproduced using real Lua closures and separate mock signals. They establish defects in the old integration contract. They do **not** establish that every historical zero-attempt report had only those causes.

Discovery uses bounded, read-only `getconnections`, `getconstants`, and `getupvalues` (or their debug equivalents). It requires a single source-shaped preview/solver/selector/release graph, four native HUD cards, and captured game `Status` / `Throwable` value instances. The live release signature includes the source's `70000000` constant. There are no fixed upvalue positions, getter replacements, global hooks, obfuscated program execution, or anti-cheat/anti-tamper modifications. A different source profile remains inactive and displays a reason; it is not silently guessed.

## Selection and release

Pelican samples current human players, evaluates at most two candidate trajectories per 0.12-second selection tick, settles the winner through the shared lock and native solver, and re-solves immediately before releasing. Lower-ranked candidates rotate so a blocked first/second candidate cannot permanently hide a third. Native solver calls are bounded to four per release tick. Departed player samples are removed.

Defender estimates evaluate the native parabolic flight path and projected arrival, using gravity 28 and conservative risk parameters retained from V13. They consider defender motion and the catch portion of the trajectory, not only present receiver proximity. These estimates remain provisional; they are not measured server catch windows. No new jump bullet or arbitrary vertical offset is added. Existing native modes are preserved: the readable source chooses Fit for a near-straight route away from the QB, Bullet for a sufficiently lateral route, and retains its other native cases. Its High Arc setting selects different native modes; Pelican does not alter that setting.

The ordinary live request exactly follows the inspected release:

```lua
remote:FireServer(
    "Clicked",
    origin - finalVelocity.Unit * 5 + Vector3.new(70000000, 0, 0),
    origin + finalVelocity.Unit * 10000,
    nativePower,
    1
)
```

The offset is on X only, matching the source's single-argument `Vector3.new(70000000)`. The existing equipped tool's existing `Handle.RemoteEvent` is used. No remotes are created. Pelican does not call the input handler's unbounded animation wait or its `RemoveBalls` cosmetic cleanup. Whether current live servers require that animation timing or any additional release conditions is **unverified**. A successful `FireServer` API call is labeled `API_ACCEPTED_UNCONFIRMED`, never a confirmed throw, completion, or catch.

An attempt is recorded before calling the remote. There is one request per continuous equipped/throwable possession; no timer or ambiguous error automatically retries it. The native `Throw` animation from readable `fn26` also reserves a manual throw, preserving the shared target for its native solver and suppressing a competing automatic request. A subsequent authoritative play/throwability transition, equipped ball change, or character change permits a new possession, including reuse of the same Tool. An unconfirmed request drops its owned lock after one second. A user/native lock edit is preserved and pauses AUTO. Stopping disconnects only Pelican listeners, restores only its owned lock, removes its UI, and confirms cleanup only after those operations succeed.

## Validation and live uncertainties

`tests/auto_qb_v14_test.lua` executes the actual shipped controller against source-shaped closures with supplied reflection metadata. It reproduces the old contract failures and verifies automatic request generation, coherent final-velocity arguments, movement/manual modes, trajectory threats, teammate restriction, lock ownership, startup before Yuna, profile ambiguity, missing APIs, malformed solver output, authoritative throw permission, no ambiguous retry, reused Tool/new possession, cancellation, report preservation, and cleanup failure/retry. This verifies integration behavior in mocks, not actual executor reflection or server acceptance.

Local validation on 2026-10-09: 58 actual-controller mock checks, 86 loader checks, 55 checks of every route's real bundled startup/reexecution/cleanup, and five ordinary Yuna source-model tests passed. Original live V13, practice, and all six Threshold gameplay module hashes remain unchanged. Native Luau compilation passed for the new controller, loader, manifest, and rebuilt bundle. The fixture also covers native vector returns and both plain-table and Instance containers for captured game values. Completed gameplay experiments are not rerun as claims of new success.

Required live validation: qualification against the current Yuna build and iPhone executor; shared-lock display and actual selected receiver; current live request/animation acceptance; defender-motion estimates; release, catch, and miss outcomes; frame time on the iPhone; report copy before exit. High jump-catch regions and the intermediate dead zone still require game-mechanics calibration and remain outside this rewrite. Reports identify the current gate and exact request counters, so qualification failures can be distinguished from a server rejecting a sent request.
