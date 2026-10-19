# FF3 V26.7: checked flight-time comfort and current lead snapshots

V26.6 estimated gentler power requests but did not impose a minimum on the returned low-power flight time. Its 40-power request floor could still produce a fast close pass, and its estimate measured from the QB head while the inspected native source moves the actual launch origin toward the target. Full-power fallback required only 0.5 seconds of modeled travel. A lower-power label or input therefore did not establish a comfortable flight.

## What changes

The default standing Bullet request floor is now **20**; gentle and quicker coverage estimates target **0.90** and **0.65 seconds**. A recent valid native launch origin, translated by current QB head movement, refines subsequent estimates. It expires with the existing short cache/possession/profile scope. Integer requests round downward instead of rounding up to a faster shot. Every result still comes from the protected native solver; no manually fabricated server velocity is introduced.

Automatic eligibility now checks the returned native trajectory time. SoftBullet requires at least 95% of its gentle target (0.855 seconds by default); QuickBullet and other lower-power candidates require the quicker window (0.65 seconds). Native full power, regardless of mode label, requires the full gentle target (0.90 seconds). An optional explicit FullPowerYards still adds a distance restriction; the default uses actual flight time rather than a fixed yard cutoff or yellow marker. CloseBullet=false remains an explicit opt-out and is identified in uploaded settings.

The lowest safe softened Bullet remains preferred when available. Coverage may justify the quicker candidate, but each trajectory must still pass its own strict lane/receiver/coverage checks. If no supported, safe, sufficiently comfortable candidate exists, automatic release remains withheld; manual targeting remains available. These are application comfort preferences, not calibrated catch windows or human reaction guarantees. No delay timer, jump-peak wait or extra native solve loop is added. The existing per-frame solve budget stays eight.

A synthetic native-origin shift reproduces the archived V26.6 estimate accepting a sub-0.65-second flight. The corrected controller rejects that result and uses a slower checked standing Bullet. This proves a local failure mechanism, not the exact cause of every reported live fast pass. Why a particular live build rejects the native low-power branches still requires its rejection evidence.

## Better retained evidence

`CurrentSettings` records exact last-verified Bullet/Fit/Jump/Dive/Dime X/Y values, session/run, observation time, source, configured power policy and bounded native power-control status. Sampling runs at most once per second after passing work; export/upload also refreshes it. Settings can therefore be uploaded without a throw. An unavailable native table never becomes guessed defaults. Current-session upload omits a prior session's last-known settings. Per-throw lead snapshots remain unchanged and are the correct evidence for that historical throw.

Actual flight-time requirements and policy rejections are saved with accepted/blocked throws and readable decision evidence. A comfort refusal is reported as such instead of being labeled only as coverage. Native-control failures are recorded without actor names or credentials. The existing companion and exact own-chat `a` command remain compatible; they upload the retained **current session**, while DATA exports full retained history. Upload after a completed attempt to include its final trace. The latest bin snapshot replaces its prior view; this is not archival storage for every server.

Two receiver-evidence defects are also corrected. A near-zero positive replicated vertical velocity during PlatformStanding no longer qualifies as a jump signal; a clear upward impulse shortly after that transition can still confirm an observed ascent. Native context strings are stored in bounded chunks so the generic 100-character string bound cannot silently truncate the matching context; legacy incomplete contexts remain unusable for comparisons. These changes do not claim verified dive/catch mechanics or assign QB/WR fault.

## Lead advice limits

An observed jump/dive, miss or opponent carrier does not independently prove a lead error. Receiver route changes, unclear catch input, coverage and noisy flight samples can prevent attribution. Fit's conditional vertical-lead branch is recorded separately; changing its Y setting does not guarantee that the native branch applies it. The advisor remains read-only and withholds unsupported numeric adjustments. Its existing controlled-pose and matched single-axis evidence requirements remain.

## Validation

All **22 local suites / 1,173 mocked assertions** pass, including 24 new native-comfort/current-settings checks and six additional pose/context checks. Coverage cases exercise a safe quicker pass and refusal of a narrower uncomfortable window; unsupported low-power control cannot force a sub-comfort full-power fallback. Native temporary-setting rollback, request identity, release timing, AFK/blacklist/LOS, upload scope, lifecycle and the rebuilt bundle remain covered. Historical coverage fixtures move their defender from 31 to 35 studs so the quicker pass has a valid window under the new longer comfort policy. Recorder packet equivalence now compares current-policy history ON versus OFF rather than expecting an intentional power change to equal archived V26.3.

No live Roblox/chat/currency tests were run. Actual server power conversion, native low-power compatibility, receiver comfort and iPhone overhead remain unverified. Immutable ff3-v26.6 preserves the previous release. The loader pins ff3-v26.7; other games and the standalone companion are unchanged.
