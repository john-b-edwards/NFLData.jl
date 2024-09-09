module NFLData

using Preferences
using DataFrames
using Parquet2
using HTTP
using Scratch: @get_scratch!, clear_scratchspaces!
using Dates
using Downloads
using CSV

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
export clear_cache

## PREFERENCES
# set caching preferences, default to true
function cache_data_pref(pref::Bool)
    @set_preferences!("cache" => pref)
end

function clear_cache()
    clear_scratchspaces!(NFLData)
end

const cache_data = @load_preference("cache", true)

download_cache = ""

function __init__()
    printstyled("By default, NFLData.jl caches data for up to 24 hours.\n", color = :blue)
    printstyled("To disable this caching, run `cache_data_pref(false)` and restart Julia.\n", color = :blue)
    printstyled("To clear the cache, run `clear_cache()`.\n", color = :blue)
    # initialize cache
    tmp_cache = @get_scratch!("downloaded_files")
    # check for what files are in the cache and how old the oldest one is
    if length(readdir(tmp_cache)) > 0
        oldest_file = unix2datetime(minimum([mtime(joinpath(tmp_cache, file)) for file in readdir(tmp_cache)]))
        # check how old the oldest file in the cache is
        time_since_last_cache = round(now() - oldest_file, Hour(1))
        # if it's been more than 24 hours, clear the cache
        if time_since_last_cache >= Hour(24)
            clear_scratchspaces!(NFLData)
        end
    end
    global download_cache = @get_scratch!("downloaded_files")
end

## UTILITIES
# helper function, throws an error in case data is unavailable
function check_years(years_to_check, start_year, release, roster = false)
    most_rec_sea = 2024
    if years_to_check == true
        years_to_check = start_year:most_rec_sea
    end
    if minimum(years_to_check) < start_year
        throw(DomainError(minimum(years_to_check),"No $release available prior to $start_year\\!"))
    elseif minimum(years_to_check) > most_rec_sea
        throw(DomainError(minimum(years_to_check),"No $release available after $most_rec_sea!"))
    end
    if length(years_to_check) == 1
        years_to_check = [years_to_check]
    end
    return years_to_check
end

# helper function for computing start of nfl season
function compute_labor_day(season::Int)
    earliest = Dates.firstdayofweek(Date(season,9,1))
    latest = Dates.firstdayofweek(Date(season,9,8))
    if(month(earliest) == 8)
        labor_day = latest
    else
        labor_day = earliest
    end
    return labor_day
end

# determine start of nfl season
function most_recent_season(roster::Bool = false)
    labor_day = compute_labor_day(year(today()))
    season_opener = labor_day + Day(3)
    if (!roster && (today() >= season_opener)) || 
        (roster && (month(today()) == 3) && (day(today()) >= 15)) || 
        (roster && (month(today()) >= 3))
        most_rec = year(today())
    else
        most_rec = year(today()) - 1
    end
    return most_rec
end

# parquet2 helper function so we can open and close parquet files while still clearing the cache
function parquet2df(file)
    open(file) do io
        ds = Parquet2.Dataset(io)
        df = DataFrame(ds)
        close(ds)
        return df
    end
end


# Downloads a resource, stores it within a scratchspace
function from_url(url::String; file_type::String = ".parquet")
    if !(file_type in [".parquet",".csv",".csv.gz"])
        throw(DomainError(file_type,"`file_type` must be one of either \".parquet\", \".csv\", or \".csv.gz\"."))
    end
    if cache_data
        fname = joinpath(download_cache, basename(url) * file_type)
        if !isfile(fname)
            Downloads.download(url * file_type, fname)
        end
        if file_type == ".parquet"
            df = parquet2df(fname)
        elseif file_type in [".csv",".csv.gz"]
            df = DataFrame(CSV.File(fname))
        end
    else
        if file_type == ".parquet"
            res = HTTP.get(url * file_type)
            ds = Parquet2.Dataset(res.body)
            df = DataFrame(ds)
        elseif file_type in [".csv",".csv.gz"]
            df = DataFrame(CSV.File(fname))
        end
    end 
    return df
end

# for getting data from a specific season
# can be broadcasted e.g. from_url.(url,2022:2024)
function from_url(url::String, seasons::Int; file_type::String = ".parquet")
    if !(file_type in [".parquet",".csv",".csv.gz"])
        throw(DomainError(file_type,"`file_type` must be one of either \".parquet\", \".csv\", or \".csv.gz\"."))
    end
    if cache_data
        fname = joinpath(download_cache, basename(url) * string(seasons) * file_type)
        if !isfile(fname)
            Downloads.download(url * string(seasons) * file_type, fname)
        end
        if file_type == ".parquet"
            df = parquet2df(fname)
        elseif file_type in [".csv",".csv.gz"]
            df = DataFrame(CSV.File(fname))
        end
    else
        if file_type == ".parquet"
            res = HTTP.get(url * string(seasons) *  ".parquet")
            ds = Parquet2.Dataset(res.body)
            df = DataFrame(ds)
        elseif file_type in [".csv",".csv.gz"]
            df = DataFrame(CSV.File(fname))
        end
    end 
    return df
end

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
        df = from_url("https://github.com/dynastyprocess/data/raw/master/files/db_fpecr",file_type = ".csv")
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
function load_participation(seasons, include_pbp = false)
    seasons = check_years(seasons, 2016, "NFL participation data")
    df = reduce(vcat, from_url.("https://github.com/nflverse/nflverse-data/releases/download/pbp_participation/pbp_participation_",seasons))
    if include_pbp
        df = innerjoin(select!(df, Not([:old_game_id])), load_pbp(seasons), on = [:nflverse_game_id => :game_id, :play_id => :play_id])
    end
    return df
end

# load pfr advanced stats
function load_pfr_advstats(seasons, stat_type = "pass", summary_level = "week")
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

end
