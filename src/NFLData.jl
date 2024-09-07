module NFLData

using CSV
using Preferences
using DataFrames
using UrlDownload: urldownload
using Scratch: @get_scratch!
using Dates

export cache_data_pref
export load_players
export load_pbp
export most_recent_season

## PREFERENCES
# set caching preferences, default to true
function cache_data_pref(pref::Bool)
    @set_preferences!("cache" => pref)
end

const cache_data = @load_preference("cache", true)

download_cache = ""

function __init__()
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

# Downloads a resource, stores it within a scratchspace
function from_url(url::String)
    if cache_data
        fname = joinpath(download_cache, basename(url) * ".csv.gz")
        if !isfile(fname)
            download(url * ".csv.gz", fname)
        end
        df = DataFrame(CSV.File(fname))
    else
        df = urldownload(url * ".csv.gz")
    end 
    return df
end

# for getting data from a specific season
# can be broadcasted e.g. from_url.(url,2022:2024)
function from_url(url::String, seasons::Int)
    if cache_data
        fname = joinpath(download_cache, basename(url) * string(seasons) * ".csv.gz")
        if !isfile(fname)
            download(url * string(seasons) * ".csv.gz", fname)
        end
        df = DataFrame(CSV.File(fname))
    else
        df = urldownload(url * string(seasons) * ".csv.gz")
    end 
    return df
end

# load all NFL players in NFL DB
function load_players()
    return from_url("https://github.com/nflverse/nflverse-data/releases/download/players/players")
end

# load NFLFastR PBP
function load_pbp(seasons = most_recent_season())
    if minimum(seasons) < 1999
        throw(DomainError(minimum(seasons),"No PBP data available prior to 1999!"))
    elseif minimum(seasons) > 2024 # TODO replace with current season logi
        throw(DomainError(minimum(seasons),"No PBP data available after 2024!"))
    end
    if length(seasons) > 1
        df = reduce(vcat, from_url.("https://github.com/nflverse/nflverse-data/releases/download/pbp/play_by_play_",seasons))
    else
        df = from_url("https://github.com/nflverse/nflverse-data/releases/download/pbp/play_by_play_",seasons)
    end

    return df
end


end
