"""Expose bounded temporal TRUST risk evidence without changing permission.

The inherited instant-turn pursuit disk is deliberately pessimistic. Its early
overlap is useful evidence but is not a calibrated reason to suppress a burn.
Keep the existing three lane results and all admission arithmetic unchanged.
"""


def repair(s):
    def one(old, new):
        nonlocal s
        assert s.count(old) == 1, (old[:90], s.count(old))
        s = s.replace(old, new, 1)

    # A cached tuple can be regraded under SAFE after TRUST. Fields computed
    # only for non-SAFE must not leak the previous policy into the new receipt.
    one('    local margin,laneMargin,wideMargin,wideLane=45,45,45,45; local t=shot.time',
        '    shot.receiverETA=nil;shot.raceAdvantage=nil;shot.directLane=nil;shot.routeLateral=nil;shot.receiverTurn=nil\n'
        '    shot.minimumFlight=nil;shot.powerReason=nil\n'
        '    local margin,laneMargin,wideMargin,wideLane=45,45,45,45; local t=shot.time')

    # Fourth result uses the same reachable-height intervals and contest cutoff.
    # There is no new player/physics scan and no extra lane() call.
    one("if disc<0 then return 45,both and 45 or nil,earlyUntil and 45 or nil end",
        "if disc<0 then return 45,both and 45 or nil,earlyUntil and 45 or nil,earlyUntil and 45 or nil end")
    one("if hi<lo then return 45,both and 45 or nil,earlyUntil and 45 or nil end",
        "if hi<lo then return 45,both and 45 or nil,earlyUntil and 45 or nil,earlyUntil and 45 or nil end")
    one("if b<a then return 45,both and 45 or nil,earlyUntil and 45 or nil end",
        "if b<a then return 45,both and 45 or nil,earlyUntil and 45 or nil,earlyUntil and 45 or nil end")
    one("return first,linearMinimum(o.X-d.p.X,o.Z-d.p.Z,v.X-d.v.X,v.Z-d.v.Z,a,b,0)-bodyRadius,early",
        """local pursuit=earlyUntil and (a<=earlyUntil and linearMinimum(o.X-d.p.X,o.Z-d.p.Z,v.X,v.Z,a,math.min(b,earlyUntil),runSpeed(d))-bodyRadius or 45)
            return first,linearMinimum(o.X-d.p.X,o.Z-d.p.Z,v.X-d.v.X,v.Z-d.v.Z,a,b,0)-bodyRadius,early,pursuit""")
    one("local early,earlyDirect,earlyContest=interval(lo,math.min(hi,enter))",
        "local early,earlyDirect,earlyContest,earlyPursuit=interval(lo,math.min(hi,enter))")
    one("local late,lateDirect,lateContest=interval(math.max(lo,leave),hi)",
        "local late,lateDirect,lateContest,latePursuit=interval(math.max(lo,leave),hi)")
    one("earlyUntil and math.min(earlyContest,lateContest) or nil\nend\nfunction riskPolicy.BurnStart",
        "earlyUntil and math.min(earlyContest,lateContest) or nil,\n        earlyUntil and math.min(earlyPursuit,latePursuit) or nil\nend\nfunction riskPolicy.BurnStart")
    one("function riskPolicy.BurnGrade(shot,receiver,d,clearance,path,earlyDirect)",
        "function riskPolicy.BurnGrade(shot,receiver,d,clearance,path,earlyDirect,earlyPursuit,earlyUntil,defenderIndex)")
    one("    b.Threats=b.Threats+1\n", """    b.Threats=b.Threats+1
    -- Diagnostic certificate only: current-direction and optimistic pursuit
    -- envelopes intentionally remain separate, with their actual time window.
    b.EarlyPursuit=math.min(b.EarlyPursuit or math.huge,earlyPursuit or -math.huge)
    b.Certificates=b.Certificates or {}
    if #b.Certificates<16 then
        b.Certificates[#b.Certificates+1]={DefenderIndex=defenderIndex,EarlyUntil=earlyUntil,
            EarlyDirect=earlyDirect,EarlyPursuit=earlyPursuit,ArrivalClearance=clearance,WholeFlightPursuit=path}
    else b.CertificatesOmitted=(b.CertificatesOmitted or 0)+1 end
    b.CertificateScope='SAME_VERTICAL_BANDS; CURRENT_DIRECTION_AND_INSTANT_TURN; UNCALIBRATED; DIAGNOSTIC_ONLY'
""")
    # Use the captured defender array index, never a raw username in telemetry.
    start = s.index('local function risk(shot,receiver,defenders)')
    end = s.index('local lastNativeInputs', start) if 'local lastNativeInputs' in s[start:] else len(s)
    section = s[start:end]
    assert section.count('for _,d in ipairs(defenders) do') == 1
    section = section.replace('for _,d in ipairs(defenders) do', 'for defenderIndex,d in ipairs(defenders) do', 1)
    old = "local basePath,directPath,earlyDirect=lane(shot,d,false,riskPolicy.mode~='SAFE',riskPolicy.BurnEarlyUntil(shot,receiver,d))"
    new = "local earlyUntil=riskPolicy.BurnEarlyUntil(shot,receiver,d)\n        local basePath,directPath,earlyDirect,earlyPursuit=lane(shot,d,false,riskPolicy.mode~='SAFE',earlyUntil)"
    assert section.count(old) == 1
    section = section.replace(old, new, 1)
    old = 'riskPolicy.BurnGrade(shot,receiver,d,clearance,pathClearance,earlyDirect)'
    new = 'riskPolicy.BurnGrade(shot,receiver,d,clearance,pathClearance,earlyDirect,earlyPursuit,earlyUntil,defenderIndex)'
    assert section.count(old) == 1
    section = section.replace(old, new, 1)
    return s[:start] + section + s[end:]
