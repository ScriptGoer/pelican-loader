# FF3 V26.11: friend route advice into prevent coverage

With **CB ON**, Auto QB can send exactly **`slant right`**, **`slant left`**, or **`cut back`** in the verified default team channel when an eligible friend runs a streak into a deeper prevent defender. Left/right mean the WR's left/right while facing the verified attacking direction, independent of camera rotation. No receiver name, punctuation or prefix is added.

Passing takes priority. Advice only runs when the planner has a manual-only lock because no automatic window qualified. It never pauses, forces or changes a throw, moves a receiver, or changes the native throwing mode. The existing generic `cut back` advice for sustained close coverage outside the new streak/prevent condition remains available. CB ON/OFF controls both through one owned sender.

## What the policy evaluates

- Confirm the same existing teammate, blacklist, LOS, on-field and observed movement eligibility. A streak requires at least 8 studs/second with at least 85% of movement directed downfield.
- Identify a defender ahead within 12 studs laterally and within 1.4 seconds of WR speed plus 12 studs longitudinally, with projected separation below 16 studs after 0.9 seconds. This is a prevent-shaped arrangement, not authoritative detection of a game role.
- Verify the WR is a friend using the same cancellable deferred lookup and 30-second cache as FRIENDS filtering. This also works with ANY targeting, without restricting ANY receivers. Unknown/nonfriends, unavailable APIs and failed lookups cannot authorize these new calls.
- Project the straight route, both 45-degree forward slants and a straight cut back at 0.3, 0.6 and 0.9 seconds using observed horizontal velocities. Reserve `3 + 3*time` studs of uncertainty around each predicted defender. Reject routes leaving the validated field or crossing behind LOS.
- A route must have at least 2 studs of minimum reserved clearance, 6 at its endpoint, and improve over staying straight by at least 1 stud minimum and 4 at the endpoint. Prefer a qualifying slant over a cut back; compare endpoint plus minimum clearance between slants. An exact symmetric tie consistently picks right. Call cut back if both slants fail and returning creates room. If no route qualifies, stay silent.

These numbers are explicit advisory policies, **not calibrated interception radii, catch windows or guarantees**. Defenders can change direction, teammates may not react as expected, and chat can arrive late. Predictions stop at 0.9 seconds and do not claim the whole future route is safe. This feature makes a concrete coverage-based choice; its live usefulness remains unverified.

## Timing, work and ownership

A new directional call requires the same WR, prevent defender, direction, team, play and LOS generation for at least 0.65 seconds. The existing non-streak close-coverage call still requires 2 seconds. Both share one attempt per possession and a 30-second executor-session cooldown, including reloads and ambiguous deliveries.

The adviser consumes the existing bounded roster snapshot only after passing has been evaluated. A cheap streak/prevent prefilter checks candidates; at most two verified-friend candidates receive the full escape-route comparison per blocked decision. Earlier candidates retain the planner's ordering. More than two qualifying friends are not exhaustively ranked for advice in that tick. There are no additional native solves, world scans, per-frame UI listeners or independent chat workers. Friendship reads and SendAsync run in owned deferred workers, outside Heartbeat.

Immediately before sending, recheck play/ball ownership, movement, friend-cache freshness, blacklist/team, LOS generation, the receiver's character, the whole current bounded opponent roster and the exact route recommendation. Changes cancel the queued instruction. The platform channel must be the unambiguous default team channel with a send-capable local TextSource and no opposing members/shared opposing team color. There is no public chat fallback or guessed remote. A denied/ambiguous return disables messaging without retry; a yielding send times out after 5 seconds and disables messaging. Stop/reload cancels owned work and retains delivery uncertainty where needed.

`ROUTE_CALL_LAST` records the last attempted text. Existing COMEBACK report/config fields and CB control remain compatible. Friend identities/cache are not added to history or JSONBin uploads. The standalone upload companion needs no change.

## Validation

**25 local suites / 1,427 mocked assertions pass**, including 108 new route-call checks: both sides, reversed attack direction, sideline limits, both slants covered, every exit covered, defender velocity, friend/unknown/API outcomes, late opponent/coverage/eligibility changes, cancellation, shared cooldown, crowded-roster work bound and unchanged open-pass timing/native packets. The old chat suite uses the same extracted local fixture and retains all 106 assertions.

No real Roblox chat or game request was sent. Actual mobile performance, platform chat/friendship availability, teammate interpretation and route success require live Roblox testing. Existing throwing/physics assumptions are unchanged. This is substantial progress for conditional route communication; it is not live proof of better completions.

The loader pins **ff3-v26.11**, retaining **PELICAN_FF3_V26**. Immutable ff3-v26.10 preserves the prior release. Other game source/routes and public companion bytes are unchanged. Tap X to reload the current public loader.
