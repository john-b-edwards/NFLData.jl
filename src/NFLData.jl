module NFLData

using Preferences
using DataFrames
using Parquet2
using HTTP
using Scratch: @get_scratch!, clear_scratchspaces!
using Dates

export cache_data_pref
export load_players
export load_pbp
export load_contracts
export load_depth_charts
export load_draft_picks
export load_espn_qbr
export load_ff_playerids
export load_ff_rankings
export most_recent_season
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
    if (!roster && today() >= season_opener) || (roster && month(today()) == 3 && day(today()) >= 15) || (roster && month(today) >= 3)
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
function from_url(url::String)
    if cache_data
        fname = joinpath(download_cache, basename(url) * ".parquet")
        if !isfile(fname)
            download(url * ".parquet", fname)
        end
        df = parquet2df(fname)
    else
        res = HTTP.get(url * ".parquet")
        ds = Parquet2.Dataset(res.body)
        df = DataFrame(ds)
    end 
    return df
end

# for getting data from a specific season
# can be broadcasted e.g. from_url.(url,2022:2024)
function from_url(url::String, seasons::Int)
    if cache_data
        fname = joinpath(download_cache, basename(url) * string(seasons) * ".parquet")
        if !isfile(fname)
            download(url * string(seasons) * ".parquet", fname)
        end
        df = parquet2df(fname)
    else
        res = HTTP.get(url * string(seasons) *  ".parquet")
        ds = Parquet2.Dataset(res.body)
        df = DataFrame(ds)
    end 
    return df
end

# load all NFL players in NFL DB
function load_players()
    return from_url("https://github.com/nflverse/nflverse-data/releases/download/players/players")
end

# load NFLFastR PBP
function load_pbp(seasons = most_recent_season())
    start_year = 1999
    if seasons == true
        seasons = start_year:most_recent_season() 
    end
    if minimum(seasons) < start_year
        throw(DomainError(minimum(seasons),"No PBP data available prior to $start_year\\!"))
    elseif minimum(seasons) > most_recent_season() 
        throw(DomainError(minimum(seasons),"No PBP data available after $most_recent_season()!"))
    end
    if length(seasons) > 1
        df = reduce(vcat, from_url.("https://github.com/nflverse/nflverse-data/releases/download/pbp/play_by_play_",seasons))
    else
        df = from_url("https://github.com/nflverse/nflverse-data/releases/download/pbp/play_by_play_",seasons)
    end

    return df
end

# load contract data
function load_contracts()
    return from_url("https://github.com/nflverse/nflverse-data/releases/download/contracts/historical_contracts")
end

# load depth charts
function load_depth_charts(seasons = most_recent_season())
    start_year = 2001
    if seasons == true
        seasons = start_year:most_recent_season() 
    end
    if minimum(seasons) < start_year
        throw(DomainError(minimum(seasons),"No depth charts available prior to $start_year\\!"))
    elseif minimum(seasons) > most_recent_season() 
        throw(DomainError(minimum(seasons),"No depth charts available after $most_recent_season()!"))
    end
    if length(seasons) > 1
        df = reduce(vcat, from_url.("https://github.com/nflverse/nflverse-data/releases/download/depth_charts/depth_charts_",seasons))
    else
        df = from_url("https://github.com/nflverse/nflverse-data/releases/download/depth_charts/depth_charts_",seasons)
    end

    return df
end

# load draft picks
function load_draft_picks()
    return from_url("https://github.com/nflverse/nflverse-data/releases/download/draft_picks/draft_picks")
end

# load espn qb stats
function load_espn_qbr(seasons = most_recent_season(), summary_type = "season")
    start_year = 2006
    if seasons == true
        seasons = start_year:most_recent_season() 
    end
    if minimum(seasons) < start_year
        throw(DomainError(minimum(seasons),"No ESPN QBR data available prior to $start_year\\!"))
    elseif minimum(seasons) > most_recent_season() 
        throw(DomainError(minimum(seasons),"No ESPN QBR data available after $most_recent_season()!"))
    end
    if !(summary_type in ["season","week"])
        throw(DomainError(summary_type,"Please pass in one of \"season\" or \"week\" for the argument `summary_type`!"))
    end
    if length(seasons) > 1
        df = reduce(vcat, from_url.("https://github.com/nflverse/nflverse-data/releases/download/espn_data/qbr_" * summary_type,seasons))
    else
        df = from_url("https://github.com/nflverse/nflverse-data/releases/download/espn_data/qbr_" * summary_type,seasons)
    end

    return df
end

# load fantasy player ids
function load_ff_playerids()
    return from_url("https://github.com/dynastyprocess/data/raw/master/files/db_playerids")
end

# load latest fantasy player rankings
function load_ff_rankings(type = "draft")
    if !(type in ["draft","week","all"])
        throw(DomainError(type,"Please pass in one of \"draft\", \"week\", or \"all\" for the argument `type`!"))
    end
    if type == "draft"
        df = from_url("https://github.com/dynastyprocess/data/raw/master/files/db_fpecr_latest")
    elseif type == "week"
        df = from_url("https://github.com/dynastyprocess/data/raw/master/files/fp_latest_weekly")
    elseif type == "all"
        df = from_url("https://github.com/dynastyprocess/data/raw/master/files/db_fpecr")
    end
    return df
end

end
