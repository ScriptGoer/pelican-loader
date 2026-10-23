-- Declarative exact-place routes; kept inline in loader.lua to avoid an extra request.
-- Threshold universe is unverified. Each game retains its own pinned module release.
return {
    Schema = 2,
    LoaderVersion = "PELICAN_LOADER_V2",
    DefaultRef = "v13",
    BaseUrl = "https://raw.githubusercontent.com/ScriptGoer/pelican-loader",
    ObservedFF3Universe = 9908641400,
    Places = {
        [82866880824588] = {
            Name = "FF3 live", Game = "FF3", Ref = "ff3-v26.20",
            Path = "games/ff3/auto_qb.lua", Version = "PELICAN_FF3_V26",
            Experimental = true, Policy = "LIVE_HUMAN_TEAMMATES",
        },
        [81310542478972] = {
            Name = "FF3 practice", Game = "FF3", Ref = "v13",
            Path = "games/ff3/practice.lua", Version = "PELICAN_FF3_V13",
            Experimental = true, Policy = "PRACTICE_EXPLICIT_TEAMLESS",
        },
        [78453398695059] = {
            Name = "Threshold lobby", Game = "Threshold", Ref = "threshold-v1",
            Path = "games/threshold/init.lua", Version = "PELICAN_THRESHOLD_V1",
            Experimental = true, Policy = "THRESHOLD_OPT_IN_LOBBY",
        },
        [129085487311457] = {
            Name = "Threshold Chase", Game = "Threshold", Ref = "threshold-v1",
            Path = "games/threshold/init.lua", Version = "PELICAN_THRESHOLD_V1",
            Experimental = true, Policy = "THRESHOLD_PHASE_AWARE_CHASE",
        },
    },
}
