module helpers
using Dates
using DataFrames
using CSV
using Artifacts
using Unicode

export check_years
export compute_labor_day
export nflverse_game_id
export clean_team_abbrs
export clean_player_names

function __init__()
    global team_abbr_mapping = CSV.read(joinpath(artifact"data","team_abbr_mapping.csv"),DataFrame)
    global team_abbr_mapping_norelocate = CSV.read(joinpath(artifact"data","team_abbr_mapping_norelocate.csv"),DataFrame)
    global player_names_clean = CSV.read(joinpath(artifact"data","clean_player_names.csv"),DataFrame)
end

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
    clean_team_abbrs(team::String; current_location::Bool = true, keep_non_matches::Bool = true)

Clean abbreviations of teams to NFLverse friendly abbreviations.

# Examples

```julia-repl
julia> clean_team_abbrs("SD")
"LAC"
```
"""
function clean_team_abbrs(team::String; current_location::Bool = true, keep_non_matches::Bool = true)
    if current_location
        m = team_abbr_mapping
    else
        m = team_abbr_mapping_norelocate
    end
    if any(m.alternate .== team)
        team = m.team[m.alternate .== team][1]
    else
        if !keep_non_matches
            team = missing
        end
    end
    return team
end

"""
    clean_player_names(player_name::String; 
    lowercase::Bool = false, 
    convert_lastfirst::Bool = true, 
    use_name_database::Bool = true, 
    convert_to_ascii::Bool = true)

Clean up player names for merges. Can convert names to lowercase, swap first/last names, remove diacritics, and also rely on manual overrides as specified by nflverse devs.
# Examples
```julia-repl
julia > clean_player_names("Jr., Marvin Harrison")
"Marvin Harrison"

```
"""
    
function clean_player_names(player_name::String; 
    lowercase::Bool = false, 
    convert_lastfirst::Bool = true, 
    use_name_database::Bool = true, 
    convert_to_ascii::Bool = true)

    player_name = strip(replace(player_name,r"\s+"=>" "))
    if convert_lastfirst
        player_name = replace(player_name,r"^(.+), (.+)$"=>s"\2 \1")
    end
    player_name = replace(player_name,r" Jr\.$| Sr\.$| III$| II$| IV$| V$|'|\.|,"=>"")
    player_name = replace(player_name,r" JR\.$| SR\.$"=>"")
    player_name = replace(player_name,r" jr\.$| sr\.$| iii$| ii$| iv$| v$"=>"")
    if convert_to_ascii
        player_name = Unicode.normalize(player_name,stripmark=true)
    end
    if use_name_database
        if player_name in player_names_clean.alt_name
            player_name = player_names_clean.correct_name[player_names_clean.alt_name .== player_name][1]
        end
    end
    if lowercase
        player_name = Base.lowercase(player_name)
    end
    return player_name
end

"""
    nflverse_game_id(season::Number,week::Number,away::String,home::String)

Check and calculate an nflverse game ID.

# Examples
```julia-repl
julia> nflverse_game_id(2022, 2, "LAC", "KC")
"2022_02_LAC_KC"
"""
function nflverse_game_id(season::Number,week::Number,away::String,home::String)
    check_years(season, 1999, "NFLverse game ID")
    if (week > 22) | (week < 0)
        throw(DomainError(week,"`week` must be between 1 and 22!"))
    end

    valid_names = team_abbr_mapping_norelocate.alternate

    if !all(in.(home, [valid_names]))
        throw(DomainError(home[.!(in.(home, [valid_names]))],"Invalid home team specified!"))
    elseif !all(in.(away, [valid_names]))
        throw(DomainError(away[.!(in.(away, [valid_names]))],"Invalid away team specified!"))
    end

    home = clean_team_abbrs.(home, current_location = false)
    away = clean_team_abbrs.(away, current_location = false)

    ids = string(season) .* "_" .* lpad.(string.(week), 2, '0') .* "_" .* away .* "_" .* home
    return ids
end

end
