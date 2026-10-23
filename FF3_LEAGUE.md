# FF3 V26.15: native covered Jump and compact competitive profile

V26.21 fixes stale final-rejection metrics and retains bounded per-receiver mode-attempt diagnostics. Passing rules remain unchanged. [Current evidence behavior](FF3_FINAL_EVIDENCE.md).

V26.20 improves challenger scheduling within the existing native budgets and adds local target identity mapping. [Current planning behavior and limits](FF3_FRAME_REVIEW.md).

V26.19 adds holding-high Bullet-only selection, floating-safety Auto Arc and a contested-slant native low-arc Power Jump path. [Current rules and calibration limits](FF3_SAFETY_READ.md).

V26.18 cancels stale predictions without banning the receiver for the possession, restricts Jump to useful covered windows, and shares bounded reactive cache checks plus coverage-math reuse with competitive. [Current behavior and limits](FF3_REACTIVE_REPLAN.md).

V26.17 fixes route-dependent MOD/TRUST/Fit eligibility, regrades other eligible receivers’ fresh cached paths and favors shorter ready completions. Strict Bullet limits, final native validation and the 75-ms takeoff target remain. [Current selection policy](FF3_OPPORTUNITIES.md).

**V26.16 update:** automatic release targets 75 ms after observed local takeoff, with fresh final calculations and frame-bound timing. Strict layered Fit windows and defender ping grading now also run in casual/public matches; league-only UI/SCREEN eligibility stays separate. [Current timing and shared coverage](FF3_JUMP_TIMING.md).

Use the competitive entry for the observed FF3 live place:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/competitive.lua"))()
```

This delegates to the existing main loader with FF3.Profile="LEAGUE"; it does not create another controller, teleport owner or Yuna startup path. X still reloads main with the selected options. Start Yuna separately with its existing QB/mouse/automatic-mode settings. Other places are refused by this specialized entry; the ordinary multi-game entry retains all its routes.

The ordinary loader defaults to Profile="AUTO". It reuses the existing bounded GUI text scan and checks its at-most-256 labels every 0.5 seconds for exact, visible **VIP SERVER** text in the top 40% of the screen. Ancestor visibility, enabled GUI, text transparency and screen bounds are checked. Exact VIP text gets retention priority when Yuna has already filled the label cache. A visible private-server banner is a user-supplied league hint, **not verified league identity**. AUTO latches the hint for this controller so a disappearing gameplay banner cannot flap the profile. A folded profile control provides a deliberate CASUAL/LEAGUE override, retained by loader X. Explicit FF3.Profile="CASUAL" ignores the hint. The competitive entry forces LEAGUE even before a banner exists. No private-server PlaceId or new GameId is invented.

## Native Jump replacement

With default OpenComfort=true and NativeJump enabled, the former custom Bullet-X/Fit-Y trial is replaced by a CoverageJump candidate using **native Jump's own X/Y lead and native angle/power solver**. It does not borrow Fit height, write a new lead value, force power 95, or relabel Jump as Bullet. ARC AUTO derives the native Jump request using the existing bounded estimator; ARC OLD retains the configured native input. Owned controls restore after every synchronous solve.

This is a conditional coverage option, not the old wide-open Jump preference. A safe ordinary Bullet vetoes it. An actual normal Bullet must have a modeled chest-path or arrival threat, and Jump must pass strict lane/endpoint/prevent checks in every risk setting. Before release the normal Bullet is recalculated, fresh defenders grade both paths, and native Jump is solved last. A newly safe chest lane cancels Jump. Its real returned velocity, power, time, lead and reach checks remain authoritative for release. Open receivers retain ordinary lower-power standing Bullets when supported and safe. There is no new delay or default lead reduction.

The folded former JB slot is now JUMP ON/OFF; a deliberate off survives ordinary reload and explicit FF3.NativeJump=true overrides it. The custom source remains preserved for compatibility, but cannot run alongside the replacement. Only explicit FF3.NativeJump=false with JumpBullet=true enables the legacy trial. OpenComfort=false remains the earlier legacy mode policy, not the new conditional planner.

A native Jump can still be too high with the user's configured lead. No supplied server catch code or measured reliable jump window establishes an optimal value; this update does not promise a standing, ordinary-jump or angle-required catch classification. The retained source audit documents unconditional Jump lift on lateral routes and the distinct native generic versus Bullet/Fit branches. The original paid attachment is absent from this execution workspace; implementation uses that audit, current qualified integration and native-shaped arithmetic tests, not a claimed fresh reading of missing source.

## Compact league UI and screen selection

The collapsed league HUD contains only status, SCREEN and reload. Tap status for AUTO/THR, COPY, risk and profile override. Friend-only, trust/mag, chat, lead/history panels and depth controls are hidden. League targets ANY eligible teammates, cancels friend/chat workers, disables mag trials and automated route chat, and starts the NORMAL depth plan. Those casual preferences are saved and restored on switching back, without erasing session settings. Blacklist, manual native lock ownership, ordinary AFK/readiness, legal-field/LOS and final coverage checks remain. Recording continues in the background; COPY is accessible when expanded.

Tap **SCREEN**, then the intended teammate. This explicitly arms the stationary receiver exception **for the current held-ball possession only**. The chosen player must be a living, nonblacklisted teammate on the field, at or behind verified LOS, within the configured near-line band (default ScreenDepthYards=3, configurable >0 through 6). This band is an application selection policy, not an official FF3 rule. A QB already past its accepted LOS boundary cannot arm it. Two fresh observations and current near-zero horizontal movement are still required. An unselected AFK teammate never inherits this permission.

Only ordinary Bullet-lead variants are evaluated for the screen. Both receiver and actual native arrival must stay behind LOS, and strict full-path/arrival coverage still applies. Generic low-power support is preferred when safe. A deliberately armed screen opts into a prepared short Bullet: its flight can be faster than the normal open-receiver comfort floor, including native Bullet fallback when the generic lower-power path is unsupported. History marks this exception EXPLICIT_ARMED_SCREEN_RECEIVER_PREPARED. Screen selection does not force a ball through a defender and does not alter or trigger the receiver's jump. Catch/jump timing must still be coordinated with that receiver. It also does not trigger QB deep-burn jump preparation for a stationary screen.

The menu closes on selection. Selecting that same player again cancels. Permission expires after any attempted pass, possession/ball/character/team/LOS generation change, crossing the near-line band, blacklist, AUTO/THR off, profile switch or shutdown. It cannot survive a new play or be armed after that possession was already used. Final live pose, receiver readiness, native arrival and ownership checks reject a player crossing LOS during the last solve. No global AFK or depth exemption is added.

## Coverage between layers

The diagram is a geometry problem: underneath defenders can own a flat path while deeper defenders own a longer loft's arrival. League risk grades the actual full native ballistic path through the existing height intervals/pursuit envelope, plus actual arrival reach; it also charges opponents movement during reported ping. Wide-open surplus does not charge that ping twice. Endpoint race/direct-motion corridor remain the selected risk profile; Bullet and the conditional native Jump stay strict.

Each league candidate records geometric counts for opponents underneath its path versus deeper than the receiver, and lane/arrival threats. These describe observed positions, not verified LB/safety/quarter assignments. No formation name, jersey, username or nominal quarter of the field grants a completion. Every observed opponent is still evaluated against flight time, height and reachable area. The existing assumptions about pursuit, turning and catch reach remain uncalibrated.

Casual Fit retains its prior timing-rescue condition. League adds a **strict coverage-window Fit** when the Fit itself clears the entire path/arrival, no known safe ordinary alternative exists, and actual normal Bullet and Dime counterfactuals show coverage threats. A missing mode is not invented as a failed throw. Before releasing this Fit, the controller freshly solves Bullet and Dime, rechecks live receiver/defender geometry, and solves the actual Fit last. A safe alternative, closing safety, new lane defender, stopped receiver, unsupported mode or changed profile cancels the original window. Fit retains its real low-branch native speed and configured lead; it is not assigned merely because the WR runs forward or the drawing labels a pass HIGH BEAM.

The league planning allowance is five attempted solves rather than six, reserving up to three final calls within the existing eight-native-calls-per-frame cap. Comparisons rotate across modes and receivers; the controller does not exhaust every possible combination before releasing an already-valid completion. There are no new player/world scans, path rays, physics hooks or invasive changes. The existing UI-only ground guide still runs after release work, remains advisory and adds no Workspace objects. A Fit window is not forecast by the guide without future counterfactual proof.

## Research and evidence limits

Public sources inspected on 2026-10-19:

- [Independent FF3 position guide](https://footballfusion3.wiki/positions/) distinguishes QB, WR, RB, DB and kicker responsibilities; it explicitly does not establish every lineup name or hidden stat formula.
- [Independent FF3 defense guide](https://footballfusion3.wiki/defense/) discusses depth, shared responsibilities, leverage and keeping deep help, while stating public material does not supply an official named coverage playbook.
- [Independent FF3 offense guide](https://footballfusion3.wiki/offense/) supports distinct width/depth spacing and arrival opportunities; it does not publish an official passing-power or catch-window chart.

These are fan guides, not authoritative league rules or runtime mechanics. A specific LFG/league playbook, server rule settings and a reliable mapping of named assignments were not verified. The user's two-under/two-deep diagram is treated as the requested scenario and evaluated from current actors. The implementation does not assume league receiver skill, altered catch reach, fixed quarters, or guaranteed blocking/grounding legality. Runtime qualification and source math do not certify game/server equivalence.

## Validation and release

34 local suites / **1,987 mocked assertions** pass: native conditional Jump 41, league profile/screen 107, layered coverage 42 and competitive entry 12, plus the prior 1,785. Native tests prove the own-Jump lead and an 80-power configured cap can actually release without Fit height or forced 95, retain open standing Bullets, cancel on fresh chest opening, restore settings, and stop on solver errors/yields/external edits. League tests exercise visible/hidden/misleading/private-banner hints, explicit override, saved casual preference restoration, minimal UI, current-possession screen, strict coverage, unsupported lower-power fallback, final LOS crossing, all lifecycle expirations and no unselected AFK throw. Late VIP hints remain discoverable in a full cache; new UI-action and worker-cleanup failures stop and preserve rather than leaving mixed owners. A native-shaped two-under/two-deep scene actually releases a strict Fit with fresh Bullet/Dime counterfactuals and bounded work. A released latency receipt verifies defender ping is charged exactly once. Entry tests verify option copying, single loader ownership and visible startup failures.

Historical fixtures explicitly use NativeJump=false alongside their existing legacy mode/angle controls to retain their intended contract tests. The new suites exercise current production defaults. Sources and rebuilt bundle parse/run in Lua 5.4 mocks. No actual game throws, chat, currency, server-exit or receiver-control actions were performed. VIP hierarchy/layout, screen catches and jump timing, actual coverage quality, server launch physics and iPhone cost require live validation.

Loader pin: ff3-v26.15, contract PELICAN_FF3_V26. The immutable ff3-v26.14 tag preserves the prior runtime. Other game source/routes and the upload companion retain their bytes. No supplied report, paid source or credentials are included in the public distribution.
