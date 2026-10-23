# FF3 V26.20: receiver planning

V26.21 fixes stale final-rejection metrics and retains bounded per-receiver mode-attempt diagnostics. Passing rules remain unchanged. [Current evidence behavior](FF3_FINAL_EVIDENCE.md).

Both the ordinary and competitive loaders use the same updated Auto QB module, pinned to `ff3-v26.20`. X reloads the usual loader. V26.19 remains at its immutable tag.

The previous scheduler refreshed the incumbent and repeatedly favored the highest-ranked challenger. Other eligible receivers shared fewer slots. The challenger slot now goes to the least recently planned eligible current character. Ranked order breaks initial ties, and the incumbent continues to be checked. Visit times update after actual planner attempts; character, possession and field identity prevent reuse across invalid contexts.

In a six-receiver native-shaped test, the longest revisit gap falls from **1.30 to 0.65 seconds**, in both CASUAL and LEAGUE. These are fixture measurements at 130-ms ticks, not a phone latency guarantee. More receivers or a slow native calculator can take longer. Existing short-pass ranking and target-switch hysteresis still apply; the scheduler does not force a pass to its next challenger.

The ordinary 120-ms cadence, two scheduled receivers, five shared planning attempts, 8-ms planning allowance and eight total native calls per frame remain. Other fresh cached trajectories are still regraded, and the winner is freshly solved before release. Reactive cache-only evaluations do not advance visits or native mode rotation. The change replaces the temporary challenger list with a bounded existing-roster loop and one timestamp per cached receiver; it adds no listener, worker, world object or HUD row.

The local report adds `TARGET_DISPLAY_NAME` and `TARGET_USER_ID` alongside the existing username `TARGET`. Different native/Pelican names can be aliases for the same player; name text alone is not proof of a wrong target. Native preview mode, time and player cards are not automatic-release receipts. Anonymous history actors remain anonymous; these identity fields stay in the established local diagnostic report.

Strict Bullet coverage, holding-high ordinary-Bullet selection, contested-slant conditional Jump, Fit comparisons, lower-power comfort, AFK/team/filter/blacklist checks, receiver reach, LOS/goal behavior, manual ownership, jump timing, one-request/no-ambiguous-retry behavior and cleanup remain. Other games and standalone companions retain their source bytes.

Timestamped gameplay stills can identify plausible shorter alternatives underneath deeper defenders. They cannot establish continuous motion, receiver readiness, actual flight, catch hitboxes or packet ownership. Perspective separation does not establish a safe passing lane. This release fixes a separately reproduced search delay; it does not claim that every apparent opening in an edited recording was catchable. No physics or interception thresholds were recalibrated from pixels. Receivers are human players.

The new 82-check suite compares prior/current native-shaped solve histories in both profiles, including revisit bounds, actual strictly graded release, one packet, control restoration, identity mapping, AFK/blacklist exclusion, cleanup and slow-calculator progress. All 57 standalone Lua contract suites pass, with additional source-model and integration checks. Native Luau syntax passes for all public modules, the generated private bundle and the new test (20 files). Local tests do not prove real FF3 completion rates, server/native physics agreement, current paid-build compatibility or iPhone performance. No private screenshots, chat, paid source, raw history or credentials are distributed.
