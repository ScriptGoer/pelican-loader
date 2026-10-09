# Pelican loader

One entry point, exact game/place routing. Current payloads are pinned to the v13 release tag.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/loader.lua"))()
```

Only FF3 live (82866880824588) and practice (81310542478972) are enabled. Unknown places stop without fetching a game module. Reexecution requires confirmed cleanup of the previous controller.

Start before or after Yuna; launch Yuna separately. The gameplay controls stay tiny. Press red END and save the final report before leaving Roblox. COPY SENT means the clipboard call succeeded, not OS readback.

V13 fixes demonstrated receiver-selection feedback and HUD binding/cache defects. Reliable current in-game automatic passing remains unconfirmed. Practice preserves the manual held-target baseline; practice automatic passing is unimplemented.

CTRL in the live options holds one fresh safe receiver for at most six seconds with automatic throwing paused. For a manual-only session, turn THR off first.

This distribution contains only loader/manifest and game-module source, plus usage and checksums. It contains no handoff, gameplay reports, Yuna source/license keys or GitHub credentials.
