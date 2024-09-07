module NFLData

using CSV
using Preferences
using DataFrames
using UrlDownload: urldownload
using Scratch: @get_scratch!

export cache_data_pref
export load_players
export load_pbp

# set caching preferences, default to true
function cache_data_pref(pref::Bool)
    @set_preferences!("cache" => pref)
end

const cache_data = @load_preference("cache", true)

download_cache = ""

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

# Downloads a resource, stores it within a scratchspace
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

function from_url(url::String, seasons::AbstractVector{Int})
    if cache_data
        for season in seasons
            fname = joinpath(download_cache, basename(url) * string(season) * ".csv.gz")
            if !isfile(fname)
                download(url * string(season) * ".csv.gz", fname)
            end
        end
        fnames = [joinpath(download_cache, basename(url) * string(season) * ".csv.gz") for season in seasons]
        df = reduce(vcat, [DataFrame(CSV.File(fname)) for fname in fnames])
    else
        df = reduce(vcat, [urldownload(url * string(season) * ".csv.gz") for season in seasons])
    end 
    return df
end

function __init__()
    global download_cache = @get_scratch!("downloaded_files")
end

function load_players()
    return from_url("https://github.com/nflverse/nflverse-data/releases/download/players/players")
end

function load_pbp(seasons)
    if minimum(seasons) < 1999
        throw(ErrorException(min(seasons),"No PBP data available prior to 1999!"))
    elseif maximum(seasons) > 2024 # TODO replace with current season logi
        throw(ErrorException(max(seasons),"No PBP data available after 2024!"))
    end
    return from_url("https://github.com/nflverse/nflverse-data/releases/download/pbp/play_by_play_",seasons)
end


end
