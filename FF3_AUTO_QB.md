# FF3 Auto QB V23

The regular loader selects the observed FF3 live place and pins `ff3-v23` / `PELICAN_FF3_V23`:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/loader.lua"))()
```

Yuna startup automation and GUI replay are cancelled. Launch/configure Yuna separately with QB Aimbot ON, Mouse Aimbot OFF and Auto Throw Type ON. Pelican recognizes the qualified live QB functions; it does not toggle Yuna's wire interface. Previous Pelican GUI/stat recorder instances are stopped after confirmed cleanup rather than required.

V23 integrates a separate row-based team-stat reader with guarded idle game-stats inspection, conservative receiver exclusions, manual overrides and report-before-leave. Expand the small status bar for TEAM, WR LIST, AWAY and COPY. WR LIST marks automatic exclusions [S] and manual blocks [X]; tapping allow overrides the automatic judgment. TEAM OFF stops automatic stat actions. [Exact policies, native UI requirements, configuration and unresolved live limits](FF3_TEAM_STATS.md).

AWAY remains a compact manual high throw-away. It does not need a receiver and shares one-attempt ownership with ordinary Auto QB/manual throws. It uses the preserved nominal ball model and the existing native request shape/animation where discoverable. Intentional-grounding treatment, exact server flight and natural animation are unverified. [Preserved V22 throw-away evidence and details](https://github.com/ScriptGoer/pelican-loader/blob/ff3-v22/FF3_AUTO_QB.md).

Receiver/mode planning and release behavior are retained: prefer short safe completions, reject AFK/off-team/blacklisted receivers, compare native trajectory windows, restore native settings, jump normally for deep trajectories, release at the observed peak and cancel a sold burn. Goal bypasses only LOS. The small RUN arrow remains advisory and never delays a throw. [Preserved V21 deep-peak, forecast and cancellation details](https://github.com/ScriptGoer/pelican-loader/blob/ff3-v21.1/FF3_AUTO_QB.md).

X still confirms full parent/child cleanup and reloads, preserving the prior report in `getgenv().PELICAN_PREVIOUS_LOADER_REPORT`. COPY includes the stats evidence and actual request results. Source-level/read-only native discovery uses shared selector/solver/release structure, with no getter replacement, anti-cheat modification or fabricated animation IDs.

611 mocked assertions pass, including 44 stats checks, 28 actual-controller stats integration checks and the existing throw/peak/Goal/LOS/reload/loader/bundle/Threshold regressions. Local tests do not establish live catches, actual stat callback compatibility, Corner counter meanings, server-data freshness, grounding, real disconnects or phone performance. No live/currency-spending/Kick tests were performed. Unknown stats remain ungraded. `ff3-v22/loader.lua` remains an immutable rollback.
