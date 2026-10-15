# FF3 native-mode recovery

V16 is withdrawn from the default loader. Restore Yuna **QB Aimbot ON**, **Mouse Aimbot OFF**, and **Auto Throw Type ON** for the earlier native automatic mode behavior. Stop a running Pelican instance with red X, then reexecute the normal multi-game loader. Reexecution requires confirmed previous cleanup. Original native numerical aiming settings remain the user's; this release does not choose or overwrite SelectedType, angles, power, leads, SmartPass, or AntiOOB. V16 remains archived and tagged for audit, not recommended as a working revision.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/loader.lua"))()
```

## What the supplied failure proves

The original `LOS Ground Unkown.txt` is archived privately with its checksum. It records zero Pelican native solver calls, zero attempts/requests, no owned mode, both named line Parts retained, no valid ground, an unfinished traversal (9,587 visits, 1,158 pending roots), two observed native/manual possessions, and no fatal exception. The captured controller never reached its receiver/mode planner. It does not capture the actual manual selected type or ball trajectories and cannot establish the cause of each random throw.

Requiring the user to switch native automatic modes off before Pelican could take over was an integration mistake. With that setting off, Yuna's ordinary manual input uses its stored manual type/angle/power; the report records Angle mode at 45 and power 95. Native manual animations were observed while Pelican remained blocked. This is consistent with changed ordinary aiming, not independent evidence of a Pelican-generated throw.

The source's `LOS_GROUND_UNKNOWN` combines three states: ground not discovered, current ground failing shape checks, or a sticky ambiguity flag. The supplied report does not distinguish them. Its incomplete scan means absence from the cache does not establish absence from the actual map. The earlier live search identifies `workspace.Models.Field.Ground`, a Part at (0,2.55,0), size (225,1,420). Native QBA source describes aiming but does not establish which traversal branch has run in a particular live scene.

The first recovery step restores the exact V15.4.1 module and pin, retaining the native mode policy and exception shutdown. Further ground-discovery changes must validate the observed path and existing geometry, report the exact rejection, preserve ambiguity protection, and stop a failed initial field wait instead of silently retrying forever. They must not claim the entire live failure is reproduced merely from a synthetic counterexample.

Local validation is syntax/contract evidence only. Live ground discovery, native aiming restoration, automatic passing and iPhone performance still need verification. Other game routes and mobile jump layout are unchanged. Preserve reports before leaving Roblox; API acceptance is not iOS clipboard readback.

## V15.4.2: bounded ground discovery, native modes

The current route pins `ff3-v15.4.2`, controller `PELICAN_FF3_V15`. It uses the V15.4.1 aiming/receiver/pacing implementation, with no V16 mode ownership. The restored automatic controller requires native Auto Throw Type ON and reports ENABLE_YUNA_AUTO_THROW_TYPE otherwise; it never flips the setting itself. This prevents silently using a leftover manual mode for automatic Pelican throws.

The controller directly reads the earlier observed `workspace.Models.Field.Ground` before field validation on every existing tick. It applies the original dimensions, position, anchoring and axis checks plus workspace ancestry. Names alone do not authorize a ground. Current failed geometry, incomplete initial ambiguity traversal, multiple ground references, contradictory lines and down labels still block throws. The global scan stays bounded and is not skipped. Late ground geometry and replacement at the observed path can now recover independently of the one-time seen cache. No broader scan, geometry relaxation or new per-Part listener is added.

Reports separate cached-ground reason, source, known-path lookup/shape reason, actual dimensions/position/orientation, ambiguity metadata, initial discovery completion, and actual native selected type/Auto Throw Type/angle/power/lock. Ambiguous references are not proof of two physical Parts on an executor that changes handles. The supplied failure cannot establish whether it had undiscovered, rejected, or ambiguous ground.

Initial valid ground plus initial traversal must be established within 20 seconds of the controller's runtime clock; otherwise it stops, disconnects its listeners, releases its lock, removes its UI and preserves FIELD_DISCOVERY_TIMEOUT with the reason. The bound cannot preempt an individual engine call. Once initial discovery succeeds, ordinary hidden line markers/dead plays remain safe waits, not startup errors. Throw/runtime/solver exception shutdown is preserved.

Local tests reproduce unknown-ground-before-traversal and geometry-configured-after-seen failures in the archived baseline, then recover through the observed path. They cover rejected same-name objects, invalid dimensions/orientation/anchoring/position, genuine ambiguity, replacement at the actual earlier reported coordinates, timeout/save/no-retry, and unchanged native settings. They also demonstrate that native Auto Throw Type OFF changes the fixture's native mode while Pelican has made zero solver calls. This is not a reproduction of the live random ball trajectories or proof of the exact live discovery cause.

Validation: 28 new actual-controller recovery checks, 66 LOS discovery regressions, 12 error-stop checks, 86 loader checks, and 55 bundle startup/cleanup checks pass locally; syntax checks and byte-preserved archives are verified. Historical V15 (56) and withdrawn V16 (86) suites remain pinned to their archived sources. Their passing results did not establish live V16 integration, and do not validate this recovery in Roblox.
