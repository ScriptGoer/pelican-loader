# FF3 V26.8: Moderate requires a clear conservative passing lane

Moderate previously allowed a conservative lane margin down to -1 while accepting a smaller receiver-favored endpoint/race margin. A direct observed-motion path check also ran, but that straight-line projection was insufficient protection against a defender turning toward a long-flight arrival window. A positive arrival-race estimate alone did not make a near-zero lane clearance comfortable.

V26.8 reuses the existing strict lane requirement (`CFG.ThrowLane`, currently 4 source-model studs) for Moderate. Its endpoint margin 2, race advantage 0.08 seconds, route-stability checks and other eligibility rules remain. SAFE retains its original checks. TRUST retains its deliberate tight-contest lane allowance; it is not a safe-completion guarantee. All Bullet variants remain strict in every risk mode.

This is an explicit risk-policy correction using an existing threshold, not a newly calibrated FF3 hitbox or interception probability. A local replay through the actual policy functions shows the prior Moderate limit accepting a long-Dime, negligible-clearance decision shape and the current limit refusing it. The same shape remains admitted by TRUST. Separate synthetic cases still distinguish a comfortable Moderate burn from SAFE and a tighter TRUST burn from Moderate.

No flight-time cutoff, fixed deep-yard rule, additional release delay, native aim solve or world scan is added. The planner may choose another existing safe receiver/mode or retain its manual lock when the narrow lane fails. It does not blindly replace the rejected Dime with a Fit. V26.7 native flight-time comfort, current-setting snapshots and other existing behavior remain.

## Deep-throw guidance and limits

Native Dime in Angle input mode derives power from the selected angle and geometry. A saved Power value does not govern that Angle-mode result. Therefore the proper investigation of a slow lofted Dime compares native trajectory angle/power, actual time, endpoint reach and coverage before treating the miss as an X/Y error. A faster native trajectory must clear its own lane and receiver-reach checks; simply maximizing power is not a guarantee. Fit remains restricted to its existing timing-rescue evidence.

Lead advice stays read-only. A changed receiver route, an opponent carrier or one observed miss does not isolate a decimal adjustment. An inactive native Fit-Y branch is also separate from a wrongly configured Y value. Existing historical data and private gameplay attachments are preserved outside the public runtime distribution; no numerical lead changes are applied by this release.

## Validation

All **22 local suites / 1,182 mocked assertions** pass. The risk suite increases from 60 to 69 checks: it retains SAFE packet/timing equivalence, hard eligibility/coverage gates, mode-change cancellation, UI behavior and frame-call bounds, adds refusal of the former marginal Moderate window, and replays the old/new/Trust decision shapes. The comfortable Moderate fixture moves from a 7.5 to 9.5 trailing gap so it represents the updated policy; the narrower old gap is now an explicit rejection. Sources and rebuilt bundle pass local checks. No live Roblox catches, chat, currency or player actions were tested. Pursuit/reach assumptions and actual interception quality still need in-game validation.

The loader pins ff3-v26.8; immutable ff3-v26.7 preserves the previous behavior. No other game routes or standalone companion bytes change.
