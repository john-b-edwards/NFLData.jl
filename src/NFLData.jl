module NFLData

using CSV
using Preferences
using DataFrames
using UrlDownload: urldownload
using Scratch: @get_scratch!

export cache_data_pref
export load_players

# set caching preferences, default to true
function cache_data_pref(pref::Bool)
    @set_preferences!("cache" => pref)
end

const cache_data = @load_preference("cache", true)

download_cache = ""

# Downloads a resource, stores it within a scratchspace
function from_url(url)
    if cache_data
        fname = joinpath(download_cache, basename(url))
        if !isfile(fname)
            println("Downloading to $fname !")
            download(url, fname)
        end
        println("Reading from $fname !")
        df = DataFrame(CSV.File(fname))
    else
        println("Not caching, downloading from $url !")
        df = urldownload(url)
    end 
    return df
end

function __init__()
    global download_cache = @get_scratch!("downloaded_files")
end

function load_players()
    return from_url("https://github.com/nflverse/nflverse-data/releases/download/players/players.csv")
end

end
