# FF3 V26.22: Trust trailing-corner burns

TRUST can now release an ordinary Bullet (including SoftBullet/QuickBullet) or
Dime to a downfield receiver with a trailing corner, even when the existing
conservative defender reach envelope overlaps the catch. SAFE and MOD keep their
existing rules. Receiver-list TRUSTED state is unrelated to this risk mode.

The new exception requires at least **4 source-model studs of separation along
the WR's route**, both now and at the native flight time plus observed ping.
The WR must be running downfield toward the native catch point, remain within
the existing route correction/stability and arrival limits, and have no modeled
over-top safety. Every defender threatening the endpoint or lane must qualify as
a trailing corner; a second underneath/side/ahead threat cannot borrow another
corner's allowance. A closing corner that erases the four-stud advantage vetoes
the exception. A moving receiver's gap is not the old conservative endpoint
margin: that margin subtracts a defender pursuit disk and inherited reach.

The final catch contest may overlap the inherited direct-path reach envelope.
The earlier path must remain clear within the ball's existing reachable-height
intervals. The terminal contest policy allows the last 25% of flight, capped at
0.25 seconds, with a geometric shift for separation beyond four studs so a
larger burn does not become less eligible merely because the ball passes its
trailing corner earlier. These are deliberate risk settings, not calibrated
catch radii, measured player reactions, or interception probabilities.

Plan, power/flight comfort, receiver reach/readiness, field/LOS, fresh native
trajectory, possession and release checks still apply. Fit retains its evidence
gate. Custom/covered Jump, MagDime and league screens do not gain this exception.
The ordinary final native solve regrades the burn; stale separation cannot
authorize release. Existing native frame/call limits and movement scans remain.

The report identifies the policy and V26.22 release. Throw and blocked history
retain `TrustBurn` with eligibility/reason, threat count, current/projected
separation and earlier direct-path clearance. No player names or credentials are
added by this record.

Validation reproduced V26.21 rejecting the same four-stud trailing-corner
trajectory that V26.22 accepts. All 51 targeted checks pass; 144 SAFE/MOD scenes
match baseline eligibility and coverage metrics. Synthetic fixtures cover four/seven-stud burns,
closing corners, over-top safeties, other coverage, early interceptions, native
variants, mode changes, final regrading, and unchanged shared lane outputs. The
Auto QB and loader entry files parse with Lua 5.4. The private legacy test suites
were not available in this checkout. No live Roblox throws were run; actual
catch/interception quality and mobile performance still require gameplay.

The regular main loader pins the new Auto QB source to an immutable commit.
Reexecute that loader, then select **TRUST**. Other game routes retain their pins.
