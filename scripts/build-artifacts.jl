using NFLData
using DataFrames
using CSV

# player name mapping
player_name_mapping = from_url("https://github.com/nflverse/nflreadr/raw/main/data-raw/clean_player_names",file_type=".csv")
player_name_mapping = player_name_mapping[.!nonunique(player_name_mapping[:,[:correct_name]]),[:alt_name, :correct_name]]
player_name_mapping.alt_name = strip.(replace.(player_name_mapping.alt_name,r"\s+"=>" "))
player_name_mapping.correct_name = strip.(replace.(player_name_mapping.correct_name,r"\s+"=>" "))

CSV.write(joinpath("../data/", "clean_player_names.csv"),player_name_mapping)

# team name mapping
teams = from_url("https://github.com/nflverse/nfldata/raw/master/data/teams",file_type=".csv")
teams = teams[:,[:team, :nfl, :espn, :pfr, :pfflabel, :fo]]
teams = stack(teams, Not([:team]))[:,[:team, :value]]
teams = rename(teams,[:team,:alternate])
teams = teams[.!nonunique(teams),:]
teams = teams[.!ismissing.(teams.alternate),:]
teams = vcat(teams,
DataFrame(team = ["GB","KC","LV","NE","NO","LAC","TB","WAS","LV","LA","LA","STL","LAC","SD","AFC","NFC","NFL"],
alternate = ["GBP","KCC","LVR","NEP","NOS","SDC","TBB","WFT","OAK","STL","SL","SL","SD","SDC","AFC","NFC","NFL"]))
sort!(teams, [:alternate])

team_abbr_mapping = teams[.!(in.(teams.team, [["OAK","STL","SD"]])),:]
# team_abbr_mapping = Dict([team_abbr_mapping.team[i] => team_abbr_mapping.alternate[i] for i in 1:nrow(team_abbr_mapping)])

CSV.write(joinpath("../data/", "team_abbr_mapping.csv"),team_abbr_mapping)

team_abbr_mapping_norelocate = teams[
    .!(
        ((teams.team .== "LV") .& in.(teams.alternate,[["OAK"]])) .|
        ((teams.team .== "LAC") .& in.(teams.alternate,[["SD","SDG","SDC"]])) .|
        ((teams.team .== "LA") .& in.(teams.alternate,[["STL","SL"]])) .|
        ((teams.team .== "STL") .& in.(teams.alternate,[["LA","RAM"]])) .|
        ((teams.team .== "OAK") .& in.(teams.alternate,[["LV","LVR","RAI"]])) .|
        ((teams.team .== "SD") .& in.(teams.alternate,[["LAC","LACH"]]))
    ),:
]
sort!(team_abbr_mapping_norelocate,[:alternate])

CSV.write(joinpath("../data/", "team_abbr_mapping_norelocate.csv"),team_abbr_mapping_norelocate)