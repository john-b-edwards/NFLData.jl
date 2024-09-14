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

include("statsdata.jl")
using .statsdata

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

# load officiating data for nfl games
function load_officials()
    return from_url("https://github.com/nflverse/nflverse-data/releases/download/officials/officials")
end

# load schedules
function load_schedules()
    df = from_url("https://github.com/nflverse/nfldata/raw/master/data/games",file_type=".csv")
    df.roof = ifelse.(in.(df.roof, [["closed", "dome", "outdoors", "open", "retractable"]]), df.roof, missing)
    return df
end

end
