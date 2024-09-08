using NFLData
using Test

@testset "NFLData.jl" begin
    # utility tests
    # labor day check
    @test size(load_players())[1] > 0
    @test size(load_pbp(2023))[1] > 0
    @test size(load_contracts())[1] > 0
    @test size(load_draft_picks())[1] > 0
    @test size(load_espn_qbr())[1] > 0
    @test size(load_ff_playerids())[1] > 0
    @test size(load_ff_rankings())[1] > 0
    @test size(load_ff_opportunity(2023))[1] > 0
    @test size(load_ftn_charting(2023))[1] > 0
    @test size(load_injuries(2023))[1] > 0
    @test size(load_nextgen_stats())[1] > 0
    @test size(load_officials())[1] > 0
    @test size(load_participation(2023, true))[1] > 0
    @test size(load_pfr_advstats())[1] > 0
end
