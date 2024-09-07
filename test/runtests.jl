using NFLData
using Test

@testset "NFLData.jl" begin
    # utility tests
    # labor day check
    @test size(load_players())[1] > 0
    @test size(load_pbp())[1] > 0
    @test size(load_contracts())[1] > 0
    @test size(load_draft_picks())[1] > 0
    @test size(load_espn_qbr())[1] > 0
    @test size(load_ff_playerids())[1] > 0
    @test size(load_ff_rankings())[1] > 0
    @test size(most_recent_season())[1] > 0
end
