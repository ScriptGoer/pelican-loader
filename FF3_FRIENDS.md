# FF3 V26.10: ANY / FRIENDS and exact cut-back chat

Expand the existing status pill and tap **ANY**, above the NORMAL/DEEP/SHORT button, to toggle **ANY ↔ FRIENDS**. A fresh executor environment defaults ANY. A deliberate selection persists across ordinary QB/X reloads in the same executor environment; an explicit loader ReceiverFilter option wins. The folded control is independent of pass plan and SAFE / MOD / TRUST.

- **ANY** preserves targeting of eligible current teammates. V26.11 may request deferred friendship verification for a streak/prevent route call; friendship does not gate ANY throws.
- **FRIENDS** permits only eligible current teammates with a fresh verified positive friend result. Nonfriends, unknown/expired results and platform API failures remain excluded. It does not fall back to a nonfriend manual lock or automatic throw. Friends must still pass team, AFK/movement, blacklist, LOS, plan, power and coverage checks. Opposing friends remain defenders.

The filter applies to Pelican-controlled receiver locks and automatic releases; independent native/manual Yuna actions and deliberate AWAY are not rewritten. Changing filters clears prepared sequences/selection and cancels a queued route-chat call. Final release rechecks filter eligibility so a mode switch cannot authorize an old nonfriend packet.

## Platform lookup and lifecycle

The controller uses the local player's exposed IsFriendsWithAsync method when present, otherwise IsFriendsWith. Both are treated as potentially yielding platform reads. A single owned deferred worker resolves only the eligible teammate requests; no friendship call runs in the native solver or Heartbeat decision callback. Unknown recipients remain ineligible while that worker runs. An in-flight player stays marked pending so repeated eligibility reads cannot queue duplicate requests.

Positive/negative results are cached locally for 30 seconds, keyed by the actual Player and checked UserId. Large modern account IDs are supported. Expiry excludes a recipient until the result refreshes. Platform-side friendship caching can impose further freshness limits; this is a recently verified relationship filter, not a guaranteed instantaneous unfriending event feed. A malformed result/API error is held as ineligible for the cache interval; no exception text or credentials are exported. Missing methods/scheduler leave FRIENDS unavailable rather than enabling ANY. ANY does not require a platform lookup for receiver eligibility. V26.11 route chat separately verifies a prospective friend recipient.

A yielding read has a 15-second watchdog and can be cancelled on mode change, stop, teleport or reload. Failed cancellation does not claim clean shutdown or permit a replacement controller over the old worker. The pending queue is capped by the existing roster limit; cached results use weak Player keys and expire for eligibility after 30 seconds. All lookup state is owned by the controller. The existing per-frame native solve budget is unchanged, and cached eligibility is rechecked immediately before automatic send. Reports include the selected filter, platform method, lookup status and call count; the HUD reports waiting for an eligible friend when no FRIENDS candidate qualifies.

Only the selected filter is retained in per-throw/current-setting history. The relationship cache, friend list and platform user IDs are not added to uploads. Existing anonymous throw observations and the `a` companion remain compatible.

## Exact chat text

The optional automatic team message is now exactly **`cut back`**. It retains the existing verified team-channel requirement, sustained coverage check, CB ON/OFF control, once-per-possession protection and 30-second cooldown. There is no public-channel fallback, UI replay or new chat trigger. Deferred sends revalidate the receiver filter; switching to FRIENDS cancels an old queued nonfriend call. The local `a` upload listener ignores `cut back`.

## Optional initial configuration

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptGoer/pelican-loader/main/loader.lua"))({
    FF3 = { ReceiverFilter = "FRIENDS" }
})
```

ReceiverFilter accepts ANY / FRIENDS, case insensitive. Ordinary users need no configuration; initial ANY preserves existing teammate eligibility.

## Validation and limits

All **24 local suites / 1,319 mocked assertions** pass. The new 67-check friend suite covers default ANY/no platform calls, friend-only selection over a closer nonfriend, supported platform method paths, large IDs, unknown/invalid/error responses, opponents, AFK/blacklists, deferred deduplication, cache expiry, mode-switch cancellation, folded UI/session behavior, cancellation failure/replacement prevention, timeout and upload metadata. Three route-chat checks cover cancellation when FRIENDS is selected; the existing chat suite verifies the exact updated text with local captures. No real Roblox friendship lookups, chat, game requests or currency actions were performed. Actual executor API availability/freshness and iPhone timing remain unverified.

The live loader pins ff3-v26.10. Immutable ff3-v26.9 preserves the prior behavior; other game routes and standalone companion source are unchanged.

V26.11 extends the team-chat owner with verified-friend `slant right`, `slant left` and `cut back` streak/prevent calls. The exact-cut-back-only description above records V26.10 behavior. [Current chat behavior](FF3_ROUTE_CALLS.md).
