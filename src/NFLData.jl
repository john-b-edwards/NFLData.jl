module NFLData

using Dates

include("helpers.jl")
using .helpers

include("getdata.jl")
using .getdata

include("ffverse.jl")
using .ffverse

include("rosters.jl")
using .rosters

include("pbp.jl")
using .pbp

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

# load espn qb stats
function load_espn_qbr(summary_type = "season")
    if !(summary_type in ["season","week"])
        throw(DomainError(summary_type,"Please pass in one of \"season\" or \"week\" for the argument `summary_type`!"))
    end 
    df = from_url("https://github.com/nflverse/nflverse-data/releases/download/espn_data/qbr_$summary_type" * "_level")
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

end
