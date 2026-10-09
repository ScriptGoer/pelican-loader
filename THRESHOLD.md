# Threshold usage and release evidence

Run the normal loadstring in the lobby or Chase. Tap THRESHOLD to expand/collapse its small list. Choosing a feature collapses the list; the top-right red dot stops the complete session and opens the final report/copy view.

- **FARM:** preserved v6.1 lobby → Eli keys/gate → Continue → Scrow real clues/keypad → reward/return/repeat. Explicit selection required. Hidden supply containers, acknowledgements, dynamic digits, and death/respawn recovery remain. Missing-key auto-rejoin stays OFF. Working file read/write and teleport queue are required before movement starts.
- **NAV / ESP:** phase-aware objective/monster ESP, route arrow, target selection, and fullbright from navigator v3. Lobby selection arms for Chase, without inactive-world markers. Gameplay navigation can run manually without resume APIs. It does not move the character.
- **FAST ROLLS:** conversation-transcribed direct `PerkRequest:InvokeServer("roll", 3)` strategy. One request at a time. Mounting starts no rolls; choose budget and tap the roller's START.
- **UI ROLLS:** separate saved v6.2 game-button/confirmation strategy. Requires supported firesignal/getconnections behavior. Never runs alongside fast rolling.
- **COPY REPORT:** export while Roblox remains open. The report distinguishes API copy success from unavailable/failed export.

Farm and rollers exclude one another. Unresolved or in-flight requests block replacement. Godspeed from result, equipped slot 3, or TitlePerk is a terminal lock. Odds/background text never proves possession. Ambiguous responses, unexpected cost/count, or unreconciled attributes stop follow-ups without automatic retry. STOP cannot recall an already-sent paid request. The default budget is 10 rolls at the observed nominal $400 each; the current server price/schema must still be verified.

Only the shared resume helper queues the loader. The adapted farm no longer queues itself. The helper retains the menu and deliberate farm/NAV choices across supported teleports, validates version/token/generation and exact destination, and verifies STOPPED flags. Rollers are never resumed. A stale bootstrap cannot replace a newer active session or undo a confirmed kill in the same Lua environment.

**Session limit:** actual executor teleport execution remains unverified. Fresh Leave/rejoin auto-execution and reliably detecting a full Roblox app quit are not established by the supplied capabilities. A fresh manual loader run ignores old disk selections. Use the red dot to cancel queued work before leaving. No executor auto-execute installation is invented.

Farm plus navigator is disabled by default until live combined testing. An explicit experimental configuration is available, but is not persisted by teleport bootstrap:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/loader.lua"))({Threshold={AllowFarmNavigator=true}})
```

**Provenance:** the complete farm available is v6.1; farm v6.2 has a report but no source. Navigator v3 and UI roller v6.2 are saved originals without exact-version end-to-end acceptance traces. One direct perk request is capture-proven; fast Godspeed in about ten seconds is user-reported, with conversation transcription as the available source. No instant reward reroll is present. All 24 originals and six evidence files remain byte-preserved in the private authoring repository; legacy diagnostics are excluded.

**Validation:** 745 local dispatcher/menu/farm/nav/roller/resume checks, 55 packaged startup/cleanup/red-button checks, and 5 offline FF3 source-model tests passed. Native Luau compiled every active module, the bundle, and nested farm runners. Source checks preserve six major farm gameplay regions unchanged. These tests sent no Roblox requests and spent no currency. In-game farming, Scrow recovery, ESP phase transitions, teleports, supported roller schema/price/timing, kill behavior, and iPhone performance still require live validation.
