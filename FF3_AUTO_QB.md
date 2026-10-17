# FF3 Auto QB V24.2

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/loader.lua"))()
```

V24.2 fixes a release bug: selection and final calculation could sample receiver displacement milliseconds apart within one physics frame. The unchanged position was misread as zero speed, so a moving receiver became “idle” and the throw was cancelled after the jump. Motion history now advances once per Heartbeat; actual pose and velocity are still checked again immediately before sending.

An exact owned-animation identity check also prevents Pelican's own track from being mistaken for a separate native throw. Genuine manual/native Throw tracks still prevent competing requests. No detector bypass, invasive hook, jump-power change or invented animation is added.

**AWAY** is a separate always-visible 54×22 button beside the collapsed status bar. It stays manual, shares possession ownership and uses the existing modeled high boundary exit. Actual grounding treatment is unverified. Expand the status bar for AUTO, THR, COPY and manual WR LIST exclusions. X confirms cleanup and reloads while preserving the prior report.

Safe deep opportunities request a normal jump and immediately perform final native safety/release checks, with no peak/ascent or animation-progress wait. Short passes stay immediate. AFK/teammate/manual-blacklist checks, trajectory/mode planning, short-pass preference, defender protection, Goal LOS-only exemption and advisory RUN arrow remain. Stats scanning, automatic stat exclusions and auto-leaving remain removed. Keep Yuna QB Aimbot ON, Mouse Aimbot OFF and Auto Throw Type ON; startup configuration/replay remains cancelled.

The endpoint validation introduced in V24.1 and bounded blocked-decision evidence remain. Reports distinguish actual AUTO_QB/AWAY requests from native-animation observations. An observed animation or accepted FireServer call does not prove a server throw or catch. The loader pins ff3-v24.2; the stable controller contract is PELICAN_FF3_V24. Check RELEASE_VERSION for the patch version.

**Validation:** 534 mocked assertions pass, including 38 new wall-time/frame/animation checks. Advancing the clock by 0.5 ms inside native calculations without a physics update reproduces the old false-idle cancellation; the updated controller releases in the same synthetic short/deep scenes. Actual AFK, stopped/reversed routes, teleports, manual controls and separate native animations still block invalid requests. Existing endpoint, AWAY, jump/release, Goal, reload, error, LOS/ground, loader and bundle suites pass.

Actual Roblox/iPhone acceptance, catches, animation appearance, grounding and performance remain unverified. The supplied report contains legitimate covered opportunities as well as the cancellation path; this release does not simply ignore defenders. No live game, currency or real server-exit tests were performed. Copy reports before quitting Roblox. Other game routes are unchanged. Original source/reports and private fixtures remain outside this public distribution.
