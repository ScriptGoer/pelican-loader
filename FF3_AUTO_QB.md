# FF3 V15.4.3: wait for play before starting the field deadline

The V15.4.2 report records accepted ground, unfinished scanning, zero solver calls/throws, WAIT_THROWABLE_PLAY 149 times and no possession age. The user confirms the game had not started. The previous 20-second clock began at controller startup and could expire before a passing opportunity existed. The saved stop reason is FIELD_DISCOVERY_TIMEOUT, not an engine/native exception. Cleanup intentionally removed Pelican's game controls; the loader remained hidden because the module did not notify it of the later heartbeat stop. The report does not establish whether the retained LineDown/LineTogo Parts were visible.

V15.4.3 continues field discovery before Yuna and before play. No timeout runs during pregame/dead plays, missing Yuna, disabled QB Aimbot/AUTO, or no equipped ball. Deliberate native locks and receiver-menu pauses do not consume the field wait either. The allowance begins only when the matched native state is InPlay/Throwable, the local QB has a valid equipped ball, and the ordinary readiness checks pass. A native/manual throw or an already-attempted possession ends that waiting obligation. Losing readiness or starting a new possession resets the allowance. AUTO OFF disarms it immediately.

An active QB still blocked on field readiness for 20 seconds stops and preserves the precise reason. Once the field is usable, the timer resets. Reports show FIELD_WAIT_POLICY, FIELD_WAIT_ARMED and FIELD_WAIT_ACTIVE_SECONDS. This corrects premature expiry; it does not prove the full map scan completes or that markers exist before kickoff, and it does not remove any ground/marker/ambiguity check.

Fatal stops notify the normal loader through its existing asynchronous error callback after controller cleanup. The loader opens its visible error/report panel while gameplay listeners, lock and controls remain stopped. This includes actual exceptions as well as active-possession timeouts. The callback is delivered at most once and cannot recursively restart cleanup. Standalone module execution without the loader preserves the existing file/session report and warns once; it does not have the loader's retained panel.

## Run

Keep Yuna QB Aimbot ON, Mouse Aimbot OFF and Auto Throw Type ON. V16 remains withdrawn; native modes and the earlier aiming path remain unchanged.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/loader.lua"))()
```

The live route pins ff3-v15.4.3 and retains the compatible PELICAN_FF3_V15 controller contract. Other game routes, blacklist, pacing, native mode ownership, one-attempt policy and mobile jump helper are unchanged.

## Evidence and validation

The new 25-check actual-controller/loader synthetic suite reproduces the V15.4.2 pregame timeout, verifies extended pregame/missing-Yuna/no-ball/AUTO-OFF waiting, per-possession resets, an actual active timeout, and retained visible error/report cleanup through the real loader. It deliberately holds scanning unfinished using a synthetic clock budget; it does not reproduce the live object counts or phone CPU behavior. Updated ground-recovery checks exercise active-QB deadlines and dead-play pauses, not startup expiry.

The 28 recovery checks, 66 LOS regressions, 12 exception-stop checks, 86 loader checks and 55 real-bundle startup/cleanup checks pass locally; native Luau compilation passes. The prior module and original uploaded report are preserved privately with checksums. No Roblox runtime test was performed. Live pregame/possession transitions, complete discovery, passing and iPhone performance remain unverified. API file/clipboard acceptance is not phone readback.
