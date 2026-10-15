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
