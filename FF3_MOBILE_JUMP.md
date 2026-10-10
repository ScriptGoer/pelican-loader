# FF3 mobile jump width helper

Optional local layout helper, independent of Auto QB, LOS diagnostics, and Yuna:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/ff3-mobile-jump-v1/games/ff3/mobile_jump.lua"))()
```

Run in FF3 live on a touch device. It doubles the existing native jump button's width toward the left, covering more of the gap beneath Block. Its right edge, height, and vertical position stay fixed. Block/Dive, jump settings, and the native button's input handler are not modified; no extra input interception or jump requests are added. The native jump image stretches with its button.

The small top-right **JUMP x2** control switches between wider/original width. Its red **X** stops this helper and restores the layout it owns. Auto QB's X stops Auto QB separately. Reexecution cleans up the prior helper first. Native size/position changes are observed for responsive layouts; control replacement is handled without leaving an older modified button behind. Teleport stops the helper; it does not queue itself.

The screenshot shows the touch control but does not establish its Explorer path. This implementation targets Roblox's standard `PlayerGui.TouchGui.TouchControlFrame.JumpButton`. It waits at most 10 seconds for that button during startup/replacement. An incompatible class/sizing constraint or runtime exception stops and saves a report; it does not guess another control or replace the game's handlers.

Failure/stop details are available in `getgenv().PELICAN_FF3_MOBILE_JUMP_REPORT` and, when the file API is available, `PELICAN_FF3_MOBILE_JUMP_REPORT.txt`. X removes the helper UI/listeners and restores properties still owned by the helper, preserving subsequent changes by another layout owner.

Native Luau syntax and static review were checked. The actual FF3 GUI path, touch hit region, orientation/respawn behavior, and iPhone layout remain **unverified in Roblox**. This change addresses touch layout only and does not fix LOS discovery or Auto QB.
