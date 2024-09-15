module getdata
using Scratch: @get_scratch!, delete_scratch!
using Preferences
using DataFrames
using Parquet2
using HTTP
using Downloads
using CSV
using Dates

export cache_data_pref, clear_cache, from_url

"""
    cache_data_pref(pref::Bool)

Set user preference to use data caching with NFLData.jl.
"""
function cache_data_pref(pref::Bool)
    @set_preferences!("cache" => pref)
end

"""
    clear_cache()

Clear the NFLData.jl scratch space.
"""
function clear_cache()
    delete_scratch!("NFLData_cache")
    global download_cache = @get_scratch!("NFLData_cache");
end

const cache_data = @load_preference("cache", true)

download_cache = ""

"Initialize NFLData.jl with startup messages and caching."
function __init__()
#=     printstyled("By default, NFLData.jl caches data for up to 24 hours.\n", color = :blue)
    printstyled("To disable this caching, run `cache_data_pref(false)` and restart Julia.\n", color = :blue)
    printstyled("To clear the cache, run `clear_cache()`.\n", color = :blue) =#
    # initialize cache
    tmp_cache = @get_scratch!("NFLData_cache")
    # check for what files are in the cache and how old the oldest one is
    if length(readdir(tmp_cache)) > 0
        oldest_file = unix2datetime(minimum([mtime(joinpath(tmp_cache, file)) for file in readdir(tmp_cache)]))
        # check how old the oldest file in the cache is
        time_since_last_cache = round(now() - oldest_file, Hour(1))
        # if it's been more than 24 hours, clear the cache
        if time_since_last_cache >= Hour(24)
            delete_scratch!("NFLData_cache")
        end
    end
    global download_cache = @get_scratch!("NFLData_cache")
end

"Helper function for reading a .parquet file to a DataFrame (while ensuring the connection closes after the file is read)."
function parquet2df(file::String)
    open(file) do io
        ds = Parquet2.Dataset(io)
        df = DataFrame(ds)
        close(ds)
        return df
    end
end

"Internal function to load data from a URL into a DataFrame with caching."
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

"..."
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

end