module gameinfo

include("helpers.jl")
using .helpers

include("getdata.jl")
using .getdata

export load_officials
export load_schedules   

"""
    load_officials()

Load the referees who officiated a given NFL game.
"""
function load_officials()
    return from_url("https://github.com/nflverse/nflverse-data/releases/download/officials/officials")
end

"""
    load_schedules()

Load the NFL schedule and results for games since 1999.
"""
function load_schedules()
    df = from_url("https://github.com/nflverse/nfldata/raw/master/data/games",file_type=".csv")
    df.roof = ifelse.(in.(df.roof, [["closed", "dome", "outdoors", "open", "retractable"]]), df.roof, missing)
    return df
end

end