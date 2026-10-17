# Yuna GUI interaction recorder V1

Standalone, opt-in observation tool for the observed FF3 live place. It can run alongside Auto QB and the stats recorder. It does not change the loader, Auto QB or Yuna settings. The user chose this capture workflow instead of the source-dependent auto-config approach.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/yuna-gui-recorder-v1/diagnostics/yuna_gui_recorder.lua"))()
```

## Capture the startup sequence

1. Execute the recorder before Yuna, or with Yuna already running.
2. Let Yuna finish loading. The recorder recognizes a Yuna ScreenGui name or a simple Yuna title where available. If it remains WAIT YUNA, tap **PICK**, then tap a harmless tab inside Yuna. That real tab action is also recorded; it is not consumed or repeated.
3. Wait for **YUNA REC**, then perform the exact setup you want repeated: for example, wire button twice, QB Aimbot on, then any other settings. Include the menu/tab navigation needed to reach each control. Use the desired final state, not exploratory clicks if possible.
4. Tap **DONE**. This finishes capture, saves the evidence and copies the text report. Tap **YUNA COPY** to copy again. Send the report before leaving Roblox. If available, also send the JSON recording for exact structured paths and state history.

**VIEW** provides a paged, selectable report when clipboard access is unavailable. **X** saves and fully stops/removes the recorder. COPY success means API acceptance without iOS readback. Reexecution requires confirmed prior cleanup.

The small toolbar sits at the left, below the existing stats bar. It does not consume, synthesize or block Yuna input. PICK chooses one ScreenGui; if a separate Yuna window lives in another ScreenGui, use PICK again and identify it explicitly. Other game/UI input and the recorder's own controls are excluded from capture. Native button signals can still be observed for controls activated without a pointer gesture, and are labelled separately.

## What is recorded

- Ordered touch/mouse begin/end events, coordinates relative to the clicked object, and rate-limited drag samples (up to 20 samples per gesture, 10 Hz). Keyboard keys and TextBox values are never collected.
- The selected GUI generation, object classes, labels/icon references, and relative path segments with same-name/class sibling indexes and counts. This preserves rows that all happen to be named Template. JSON keeps original segment names up to 256 characters; longer names are explicitly marked truncated and cannot be assumed replayable.
- Real `Activated` and `MouseButton1Click` observations, correlated with the pointer action when possible. Both signals may belong to one physical tap. **They must not be replayed as two clicks.** Uncorrelated signals remain explicit rather than inventing a physical action.
- A small local control neighbourhood at input/signals and approximately 150/600 milliseconds afterward. Initial style/text state and changed nodes are retained, including knob positions, visibility and colors. Unchanged states are compacted. These are visual observations, not authoritative meanings of toggle colors or callback completion.
- Root creation/loss, structural quiet, timing, capabilities, finish/error and cleanup status. New controls receive observers; detached controls lose observers. Recreated GUI roots get separate generations.

Observations do not establish callback execution order: Yuna's handler may run before the recorder's input listener. AFTER timestamps are sampled on Heartbeat and are not exact timers. A local neighbourhood may be truncated; JSON/text explicitly marks that case. TextBox contents and credential-named labels are excluded. No closures/upvalues/constants, arbitrary text input or remote payloads are collected.

## Saved evidence

- `PELICAN_YUNA_GUI_REPORT.txt`: readable event/control/state report.
- `PELICAN_YUNA_GUI_RECORDING.json`: structured roots, exact path segments, node metadata and correlated event/state history, when JSON and file APIs are available.
- `getgenv().PELICAN_YUNA_GUI_REPORT` and `getgenv().PELICAN_YUNA_GUI_RECORDING`: session copies; they disappear with the Roblox process.

Default waiting and capture limits are 180 seconds each. Capture time starts after the first root is selected. Optional arguments accept `{WaitTimeout=300, Duration=300}`, each bounded from 5 to 600 seconds. A caller can supply `{Root=actualScreenGuiInstance}` or use the controller's `SelectRoot(instance)` if necessary. This is an explicit instance selection, not a guessed Explorer path.

## Performance and lifecycle

Discovery scans only GUI containers: PlayerGui, accessible CoreGui and optional `gethui()`. It does not require gethui, scan Workspace, hook input, invoke feature callbacks, modify anti-cheat code or send game requests. API access is feature-checked. Hit testing uses `GetGuiObjectsAtPosition` with observed screen coordinates. Per-container hit-test results, errors, root inset settings and the current GUI inset are included for diagnosis. Cross-container overlay order and exact iPhone/executor coordinate behavior remain unverified.

Scanning runs at 10 Hz in batches of up to 64 objects, with a one-millisecond budget checked between objects. A single API call cannot be preempted by that budget. Discovery queues are capped at 8,000 objects; capped initial discovery offers PICK instead of an unbounded search. Selected-root limits include 512 observed buttons, 1,500 node descriptors, 500 events, four active gestures, 12 pending state checks and a report-size stop. Local snapshots visit at most 24 objects. Reports save on changes, at most twice per second during normal capture. Expensive property capture runs around interactions, not every rendered frame.

A structural quiet period of 0.75 seconds is a **readiness hint**, not proof that Yuna finished initializing its feature callbacks. You should visually wait for full load before recording setup. Fatal access/runtime errors stop the data listeners, show YUNA ERROR and open the saved report view. Three PICK taps returning no GUI object finish with a concrete error. Missing file/clipboard APIs retain the report viewer. Teleport and X save and stop. Failed cleanup is retained for retry and blocks replacement rather than stacking another recorder.

## Replay status

**Replay is not implemented or automatically enabled.** The next step is to inspect the user's recorded setup sequence and correlate actual clicks with resulting control state. This allows a later implementation to use the correct control once, verify the intended state, wait for real readiness and remove unnecessary human delays. A captured image/path or quiet GUI alone does not verify a feature's callback, that a toggle should be flipped, or that fast replay succeeded. No additional Yuna source upload is required just to run this recorder.

## Evidence and validation

The supplied 25.73-second stats capture contains 268 GUI stat entries but no Yuna button/control entries or exact username matches. It exposed ranked display labels and repeated Template/TextTemplate paths, which cannot associate the exported values with reliable player identities/columns. That report does not establish that Yuna was absent. It is preserved privately; it prompted this focused interaction recorder and indexed paths, not speculative stat bans.

The actual recorder passes 49 mocked assertions: late Yuna startup, title discovery, distinct physical taps/native signals, same-name rows, delayed state changes, privacy, drag limits, external GUI exclusion, dynamically created controls, root recreation, report retention, complete stop/replacement, timeout/error handling, optional export and hidden containers, thirty rapid taps with state compaction, and failed cleanup blocking replacement. Regression checks pass for existing stats recorder (19), AWAY (35), X reload (9), guide/peak (66), loader (116) and bundle startup/cleanup (55). New source and tests parse/run through Lua 5.4; a native Luau compiler is unavailable.

No live Yuna/Roblox/executor capture or replay has been performed by Codex. Exact touch hit testing, all real Yuna widgets, hidden GUI accessibility, true initialization readiness and phone performance still need the user's capture. Public distribution contains the recorder, instructions and checksums only; original reports and private test fixtures remain private.
