module helpers
using Dates

export most_recent_season, check_years

"Internal functon, test if a data is available for a given year."
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

"Determine labor day of a given year, for use in determining the start of the NFL season."
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

"""
    most_recent_season(roster::Bool = false)

Return the most recent NFL season (including in-progress season).

If `roster=true`, the upcoming NFL season is returned if the system date is March 15th or later. Defaults to `false`.

# Examples
```julia-repl
julia> # if using Dates; today() == "2024-06-15"

julia> most_recent_season()
2023

julia> most_recent_season(true)
2024
```
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

end
