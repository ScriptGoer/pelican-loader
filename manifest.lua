-- Declarative route inventory. loader.lua carries this same table inline so an
-- unsupported place does not trigger a manifest or module request.
return {
    Schema = 1,
    LoaderVersion = "PELICAN_LOADER_V1",
    DefaultRef = "v13",
    BaseUrl = "https://raw.githubusercontent.com/ScriptGoer/pelican-loader",
    ObservedFF3Universe = 9908641400,
    Places = {
        [82866880824588] = {
            Name = "FF3 live",
            Path = "games/ff3/live.lua",
            Version = "PELICAN_FF3_V13",
            Experimental = true,
            Policy = "LIVE_HUMAN_TEAMMATES",
        },
        [81310542478972] = {
            Name = "FF3 practice",
            Path = "games/ff3/practice.lua",
            Version = "PELICAN_FF3_V13",
            Experimental = true,
            Policy = "PRACTICE_EXPLICIT_TEAMLESS",
        },
    },
}
