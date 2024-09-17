using NFLData
using Test

@testset "NFLData.jl" begin
    # from url test
    @test size(from_url("https://github.com/nflverse/nflverse-data/releases/download/players/players",file_type=".parquet"))[1] > 0
    @test size(from_url("https://github.com/nflverse/nflverse-data/releases/download/players/players",file_type=".csv"))[1] > 0
    @test size(from_url("https://github.com/nflverse/nflverse-data/releases/download/players/players",file_type=".csv.gz"))[1] > 0
    # current week test
    @test get_current_week() > 0
    @test get_current_week() <= 22
    @test get_current_week(true) > 0
    @test get_current_week(true) <= 22
    # load most recent season test
    @test most_recent_season() > 2023
    # load_players tests
    @test size(load_players())[1] > 0
    # load_pbp tests
    @test size(load_pbp(2023))[1] > 0
    @test size(load_pbp())[1] > 0
    @test size(load_pbp(2022:2023))[1] > 0
    # load contracts tests
    @test size(load_contracts())[1] > 0
    # load draft picks tests
    @test size(load_draft_picks())[1] > 0
    # load espn qbr tests
    @test size(load_espn_qbr("week"))[1] > 0
    @test size(load_espn_qbr("season"))[1] > 0
    # load ff playerids tests
    @test size(load_ff_playerids())[1] > 0
    # load ff rankings tests
    @test size(load_ff_rankings("draft"))[1] > 0
    @test size(load_ff_rankings("week"))[1] > 0
    @test size(load_ff_rankings("all"))[1] > 0
    # load ff opportunity tests
    @test size(load_ff_opportunity(2023))[1] > 0
    @test size(load_ff_opportunity())[1] > 0
    @test size(load_ff_opportunity(2022:2023))[1] > 0
    @test size(load_ff_opportunity(2023, "pbp_pass"))[1] > 0
    @test size(load_ff_opportunity(2023, "pbp_rush"))[1] > 0
    @test size(load_ff_opportunity(2023, "weekly", "v1.0.0"))[1] > 0
    # load ftn tests
    @test size(load_ftn_charting(2023))[1] > 0
    @test size(load_ftn_charting())[1] > 0
    @test size(load_ftn_charting(2022:2023))[1] > 0
    # load injuries tests
    @test size(load_injuries(2023))[1] > 0
    @test size(load_injuries())[1] > 0
    @test size(load_injuries(2022:2023))[1] > 0
    # load ngexten stats
    @test size(load_nextgen_stats())[1] > 0
    @test size(load_nextgen_stats("receiving"))[1] > 0
    @test size(load_nextgen_stats("rushing"))[1] > 0
    # load officials tests
    @test size(load_officials())[1] > 0
    # load participation tests
    @test size(load_participation(2023))[1] > 0
    @test size(load_participation(2023, true))[1] > 0
    @test size(load_participation(2022:2023, true))[1] > 0
    # load pfr adv stats tests
    @test size(load_pfr_advstats(2023))[1] > 0
    @test size(load_pfr_advstats(2022:2023))[1] > 0
    @test size(load_pfr_advstats(2023,"rush"))[1] > 0
    @test size(load_pfr_advstats(2023,"rec"))[1] > 0
    @test size(load_pfr_advstats(2023,"def"))[1] > 0
    @test size(load_pfr_advstats(2023,"pass","season"))[1] > 0
    # load player stats tests
    @test size(load_player_stats())[1] > 0
    @test size(load_player_stats("defense"))[1] > 0
    @test size(load_player_stats("kicking"))[1] > 0
    # load rosters tests
    @test size(load_rosters(2023))[1] > 0
    @test size(load_rosters())[1] > 0
    @test size(load_rosters(1920))[1] > 0
    @test size(load_rosters(2022:2023))[1] > 0
    # load rosters weekly tests
    @test size(load_rosters_weekly(2023))[1] > 0
    @test size(load_rosters_weekly())[1] > 0
    @test size(load_rosters_weekly(2022:2023))[1] > 0
    # load schedules tests
    @test size(load_schedules())[1] > 0
    # load snap count tests
    @test size(load_snap_counts(2023))[1] > 0
    @test size(load_snap_counts())[1] > 0
    @test size(load_snap_counts(2022:2023))[1] > 0
    # load teams tests
    @test size(load_teams())[1] > 0
    # load trades tests
    @test size(load_trades())[1] > 0
    # nfl game id tests
    @test nflverse_game_id(2022, 2, "LAC", "KC") == "2022_02_LAC_KC"
    @test length(nflverse_game_id.(2022, 1:14, "KC", "NE")) == 14
    # clean team abbrs test
    @test clean_team_abbrs("SEA") == "SEA"
    @test clean_team_abbrs("FOO") == "FOO"
    @test clean_team_abbrs("SD") == "LAC"
    @test clean_team_abbrs("SD", current_location = false) == "SD"
    @test clean_team_abbrs.(["SD","SEA"]) == ["LAC","SEA"]
    @test ismissing(clean_team_abbrs("FOO", keep_non_matches = false))

end
