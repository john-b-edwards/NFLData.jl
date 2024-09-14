module NFLData

using Dates
using DataFrames

include("helpers.jl")
using .helpers

include("getdata.jl")
using .getdata

export cache_data_pref
export load_players
export load_pbp
export load_contracts
export load_depth_charts
export load_draft_picks
export load_espn_qbr
export load_ff_playerids
export load_ff_rankings
export load_ff_opportunity
export load_ftn_charting
export load_injuries
export most_recent_season
export load_nextgen_stats
export load_officials
export load_participation
export load_pfr_advstats
export load_player_stats
export load_rosters
export load_rosters_weekly
export load_schedules
export load_snap_counts
export load_teams
export load_trades
export clear_cache

# load all NFL players in NFL DB
function load_players()
    return from_url("https://github.com/nflverse/nflverse-data/releases/download/players/players")
end

# load NFLFastR PBP
function load_pbp(seasons = most_recent_season())
    seasons = check_years(seasons, 1999, "NFL PBP data")
    df = reduce(vcat, from_url.("https://github.com/nflverse/nflverse-data/releases/download/pbp/play_by_play_",seasons))
    return df
end

# load contract data
function load_contracts()
    return from_url("https://github.com/nflverse/nflverse-data/releases/download/contracts/historical_contracts",file_type=".csv.gz")
end

# load depth charts
function load_depth_charts(seasons = most_recent_season())
    seasons = check_years(seasons, 2001, "NFL depth charts", true)
    df = reduce(vcat, from_url.("https://github.com/nflverse/nflverse-data/releases/download/depth_charts/depth_charts_",seasons))
    return df
end

# load draft picks
function load_draft_picks()
    return from_url("https://github.com/nflverse/nflverse-data/releases/download/draft_picks/draft_picks")
end

# load espn qb stats
function load_espn_qbr(summary_type = "season")
    if !(summary_type in ["season","week"])
        throw(DomainError(summary_type,"Please pass in one of \"season\" or \"week\" for the argument `summary_type`!"))
    end 
    df = from_url("https://github.com/nflverse/nflverse-data/releases/download/espn_data/qbr_$summary_type" * "_level")
    return df
end

# load fantasy player ids
function load_ff_playerids()
    return from_url("https://github.com/dynastyprocess/data/raw/master/files/db_playerids", file_type = ".csv")
end

# load latest fantasy player rankings
function load_ff_rankings(type = "draft")
    if !(type in ["draft","week","all"])
        throw(DomainError(type,"Please pass in one of \"draft\", \"week\", or \"all\" for the argument `type`!"))
    end
    if type == "draft"
        df = from_url("https://github.com/dynastyprocess/data/raw/master/files/db_fpecr_latest",file_type = ".csv")
    elseif type == "week"
        df = from_url("https://github.com/dynastyprocess/data/raw/master/files/fp_latest_weekly",file_type = ".csv")
    elseif type == "all"
        df = from_url("https://github.com/dynastyprocess/data/raw/master/files/db_fpecr")
    end
    return df
end

# load ff opportunity stats
function load_ff_opportunity(seasons = most_recent_season(), stat_type = "weekly", model_version = "latest")
    seasons = check_years(seasons, 2006, "FF opportunity data")
    if !(stat_type in ["weekly","pbp_pass","pbp_rush"])
        throw(DomainError(stat_type,"Please pass in one of \"weekly\",\"pbp_pass\",\"pbp_rush\" for the argument `stat_type`!"))
    end
    if !(model_version in ["latest","v1.0.0"])
        throw(DomainError(stat_type,"Please pass in one of \"latest\" or \"v1.0.0\" for the argument `model_version`!"))
    end
    df = reduce(vcat, from_url.("https://github.com/ffverse/ffopportunity/releases/download/$model_version-data/ep_$stat_type" * "_",seasons))
    return df
end

# load ftn charting data
function load_ftn_charting(seasons = most_recent_season())
    seasons = check_years(seasons, 2022, "FTN charting data")
    df = reduce(vcat, from_url.("https://github.com/nflverse/nflverse-data/releases/download/ftn_charting/ftn_charting_",seasons))
    return df
end

# load injury data
function load_injuries(seasons = most_recent_season())
    seasons = check_years(seasons, 2009, "NFL injury data", true)
    df = reduce(vcat, from_url.("https://github.com/nflverse/nflverse-data/releases/download/injuries/injuries_",seasons))
    return df
end

# load nextgen stats
function load_nextgen_stats(stat_type = "passing")
    if !(stat_type in ["passing", "receiving", "rushing"])
        throw(DomainError(stat_type,"Please pass in one of \"passing\",\"receiving\",\"rushing\" for the argument `stat_type`!"))
    end
    df = from_url("https://github.com/nflverse/nflverse-data/releases/download/nextgen_stats/ngs_$stat_type")
    return df
end

# load officiating data for nfl games
function load_officials()
    return from_url("https://github.com/nflverse/nflverse-data/releases/download/officials/officials")
end

# load participation data for nfl games
function load_participation(seasons = 2023, include_pbp = false)
    seasons = check_years(seasons, 2016, "NFL participation data")
    if maximum(seasons) > 2023
        throw(DomainError(maximum(seasons),"The NFL has ceased to provide participation data for any games following the 2023 season."))
    end
    df = reduce(vcat, from_url.("https://github.com/nflverse/nflverse-data/releases/download/pbp_participation/pbp_participation_",seasons))
    if include_pbp
        pbp = reduce(vcat, load_pbp.(seasons))
        df = select(df, Not([:old_game_id]))
        df = innerjoin(df, pbp, on = [:nflverse_game_id => :game_id, :play_id => :play_id])
    end
    return df
end

# load pfr advanced stats
function load_pfr_advstats(seasons = most_recent_season(), stat_type = "pass", summary_level = "week")
    seasons = check_years(seasons, 2018, "PFR advanced stats")
    if !(stat_type in ["pass","rush","rec","def"])
        throw(DomainError(stat_type,"Please pass in one of \"pass\",\"rush\",\"rec\", or \"def\" for the argument `stat_type`!"))
    end
    if !(summary_level in ["week","season"])
        throw(DomainError(stat_type,"Please pass in one of \"week\" or \"season"\" for the argument `summary_level`!"))
    end
    if summary_level == "season"
        df = from_url("https://github.com/nflverse/nflverse-data/releases/download/pfr_advstats/advstats_season_$stat_type")
        df = df[in.(df.season, seasons),:]
        return df
    elseif summary_level == "week"
        df = reduce(vcat, from_url.("https://github.com/nflverse/nflverse-data/releases/download/pfr_advstats/advstats_week_" * stat_type * "_", seasons))
    end
    return df
end

# load player stats calculated from pbp
function load_player_stats(stat_type = "offense")
    if stat_type == "offense"
        file_ext = "player_stats"
    elseif stat_type == "defense"
        file_ext = "player_stats_def"
    elseif stat_type == "kicking"
        file_ext = "player_stats_kicking"
    else
        throw(DomainError(stat_type,"Please pass in one of \"offense\", \"defense\", or \"kicking\" for the argument `stat_type`!"))
    end
    df = from_url("https://github.com/nflverse/nflverse-data/releases/download/player_stats/$file_ext")
    return df
end

# load rosters
function load_rosters(seasons = most_recent_season(true))
    seasons = check_years(seasons, 1920, "NFL rosters", true)
    df = reduce(vcat, from_url.("https://github.com/nflverse/nflverse-data/releases/download/rosters/roster_", seasons))
    return df
end

# load rosters weekly
function load_rosters_weekly(seasons = most_recent_season(true))
    seasons = check_years(seasons, 2002, "NFL weekly rosters", true)
    df = reduce(vcat, from_url.("https://github.com/nflverse/nflverse-data/releases/download/weekly_rosters/roster_weekly_", seasons))
    return df
end

# load schedules
function load_schedules()
    df = from_url("https://github.com/nflverse/nfldata/raw/master/data/games",file_type=".csv")
    df.roof = ifelse.(in.(df.roof, [["closed", "dome", "outdoors", "open", "retractable"]]), df.roof, missing)
    return df
end

# load snap counts
function load_snap_counts(seasons = most_recent_season())
    seasons = check_years(seasons, 2012, "NFL snap counts")
    df = reduce(vcat, from_url.("https://github.com/nflverse/nflverse-data/releases/download/snap_counts/snap_counts_", seasons))
    return df
end

function load_teams(current = true)
    df = from_url("https://github.com/nflverse/nflverse-pbp/raw/master/teams_colors_logos",file_type = ".csv")
    if current
# TODO out <- out[out$team_abbr %in% nflreadr::team_abbr_mapping,]
    end
    return df
end

function load_trades()
    df = from_url("https://github.com/nflverse/nfldata/raw/master/data/trades",file_type = ".csv")
    return(df)
end

end
