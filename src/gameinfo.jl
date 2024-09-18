module gameinfo
using Dates

include("helpers.jl")
using .helpers

include("getdata.jl")
using .getdata

export load_officials
export load_schedules   
export most_recent_season
export get_current_week

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

"""
    most_recent_season(roster::Bool = false)

Return the most recent NFL season (including in-progress season).

If `roster=true`, the upcoming NFL season is returned if the system date is March 15th or later. Defaults to `false`.

"""
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

"""
    get_current_week(use_date::Bool = false)

Return the current/upcoming week of the NFL season. Uses the schedules by default, can be swapped to use date-based heuristics by passing `use_date=true`.

# Examples
```julia
julia>  # if using Dates; today() == "2024-09-15"

julia>get_current_week()
2
```
"""
function get_current_week(use_date::Bool = false)
    if !use_date
        sched = load_schedules()
        current_season = sched[sched.season .== most_recent_season(),:]
        if all(.!ismissing.(current_season.result)) 
            current_week = maximum(current_season.week)
        else
            current_week = minimum(current_season.week[ismissing.(current_season.result)])
        end
    else
        season_opener = compute_labor_day(most_recent_season()) + Day(3)
        current_week = floor(Dates.value(today() - season_opener) / 7) + 1
        current_week = maximum([1, current_week])
        current_week = minimum([22, current_week])
        current_week = Int64.(current_week)
    end
    return current_week
end

end