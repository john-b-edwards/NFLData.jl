# NFLData.jl

*A package for intelligently loading NFL data into Julia.*

`NFLData.jl` is a low-level data loader, designed to be a native Julia implementation of the popular `{nflreadr}` package. `NFLData.jl` makes a number of NFL data resources available quickly and handily in `DataFrame` format, while intelligently caching and updating these data sources to accomodate in-season changes.

## Installation

NFLData.jl is available from the Julia package registry, and can be installed with the following one liner.

```julia
using Pkg; Pkg.add("NFLData")
```
You can also add the package using the Pkg.jl REPL. Open an interactive Julia session, then press `]` to open the REPL, then run `add NFLData`.

## Getting Started

After installation, return to the Julia repl, and type:

```julia
julia> using NFLData
```

You can now load data into your Julia environment. For example, to pull in NFL schedules since 1999, you can use `load_schedules()`:

```julia
julia> load_schedules()
6978×46 DataFrame
  Row │ game_id          season  game_type  week   gameday     weekday   gametime  away_te ⋯
      │ String15         Int64   String3    Int64  Date        String15  Time      String3 ⋯
──────┼─────────────────────────────────────────────────────────────────────────────────────
    1 │ 1999_01_MIN_ATL    1999  REG            1  1999-09-12  Sunday    missing   MIN     ⋯
    2 │ 1999_01_KC_CHI     1999  REG            1  1999-09-12  Sunday    missing   KC
    3 │ 1999_01_PIT_CLE    1999  REG            1  1999-09-12  Sunday    missing   PIT
    4 │ 1999_01_OAK_GB     1999  REG            1  1999-09-12  Sunday    missing   OAK
    5 │ 1999_01_BUF_IND    1999  REG            1  1999-09-12  Sunday    missing   BUF     ⋯
    6 │ 1999_01_SF_JAX     1999  REG            1  1999-09-12  Sunday    missing   SF
    7 │ 1999_01_CAR_NO     1999  REG            1  1999-09-12  Sunday    missing   CAR
    8 │ 1999_01_NE_NYJ     1999  REG            1  1999-09-12  Sunday    missing   NE
    9 │ 1999_01_ARI_PHI    1999  REG            1  1999-09-12  Sunday    missing   ARI     ⋯
   10 │ 1999_01_DET_SEA    1999  REG            1  1999-09-12  Sunday    missing   DET
   11 │ 1999_01_BAL_STL    1999  REG            1  1999-09-12  Sunday    missing   BAL
  ⋮   │        ⋮           ⋮         ⋮        ⋮        ⋮          ⋮         ⋮          ⋮   ⋱
 6969 │ 2024_18_CHI_GB     2024  REG           18  2025-01-05  Sunday    13:00:00  CHI
 6970 │ 2024_18_JAX_IND    2024  REG           18  2025-01-05  Sunday    13:00:00  JAX     ⋯
 6971 │ 2024_18_SEA_LA     2024  REG           18  2025-01-05  Sunday    13:00:00  SEA
 6972 │ 2024_18_LAC_LV     2024  REG           18  2025-01-05  Sunday    13:00:00  LAC
 6973 │ 2024_18_BUF_NE     2024  REG           18  2025-01-05  Sunday    13:00:00  BUF
 6974 │ 2024_18_MIA_NYJ    2024  REG           18  2025-01-05  Sunday    13:00:00  MIA     ⋯
 6975 │ 2024_18_NYG_PHI    2024  REG           18  2025-01-05  Sunday    13:00:00  NYG
 6976 │ 2024_18_CIN_PIT    2024  REG           18  2025-01-05  Sunday    13:00:00  CIN
 6977 │ 2024_18_NO_TB      2024  REG           18  2025-01-05  Sunday    13:00:00  NO
 6978 │ 2024_18_HOU_TEN    2024  REG           18  2025-01-05  Sunday    13:00:00  HOU     ⋯
                                                            39 columns and 6957 rows omitted
```

You can load nflfastR play-by-play data into Julia with `load_pbp(years)`. The function can take either one or multiple years as arguments, or you can pass `true` into the function to pull in all years of PBP data.

```julia
julia> load_pbp(2023)
49665×372 DataFrame
   Row │ play_id   game_id          old_game_id  home_team  away_team  season_type  week   ⋯
       │ Float64?  String?          String?      String?    String?    String?      Int32? ⋯
───────┼────────────────────────────────────────────────────────────────────────────────────
     1 │      1.0  2023_01_ARI_WAS  2023091007   WAS        ARI        REG               1 ⋯
     2 │     39.0  2023_01_ARI_WAS  2023091007   WAS        ARI        REG               1
     3 │     55.0  2023_01_ARI_WAS  2023091007   WAS        ARI        REG               1
     4 │     77.0  2023_01_ARI_WAS  2023091007   WAS        ARI        REG               1
     5 │    102.0  2023_01_ARI_WAS  2023091007   WAS        ARI        REG               1 ⋯
     6 │    124.0  2023_01_ARI_WAS  2023091007   WAS        ARI        REG               1
     7 │    147.0  2023_01_ARI_WAS  2023091007   WAS        ARI        REG               1
     8 │    172.0  2023_01_ARI_WAS  2023091007   WAS        ARI        REG               1
     9 │    197.0  2023_01_ARI_WAS  2023091007   WAS        ARI        REG               1 ⋯
    10 │    220.0  2023_01_ARI_WAS  2023091007   WAS        ARI        REG               1
    11 │    245.0  2023_01_ARI_WAS  2023091007   WAS        ARI        REG               1
   ⋮   │    ⋮             ⋮              ⋮           ⋮          ⋮           ⋮         ⋮    ⋱
 49656 │   4684.0  2023_22_SF_KC    2024021100   KC         SF         POST             22
 49657 │   4709.0  2023_22_SF_KC    2024021100   KC         SF         POST             22 ⋯
 49658 │   4734.0  2023_22_SF_KC    2024021100   KC         SF         POST             22
 49659 │   4771.0  2023_22_SF_KC    2024021100   KC         SF         POST             22
 49660 │   4759.0  2023_22_SF_KC    2024021100   KC         SF         POST             22
 49661 │   4791.0  2023_22_SF_KC    2024021100   KC         SF         POST             22 ⋯
 49662 │   4813.0  2023_22_SF_KC    2024021100   KC         SF         POST             22
 49663 │   4835.0  2023_22_SF_KC    2024021100   KC         SF         POST             22
 49664 │   4860.0  2023_22_SF_KC    2024021100   KC         SF         POST             22
 49665 │   4881.0  2023_22_SF_KC    2024021100   KC         SF         POST             22 ⋯
                                                          365 columns and 49644 rows omitted

julia> load_pbp(2022:2023)
99099×372 DataFrame
   Row │ play_id   game_id          old_game_id  home_team  away_team  season_type  week   ⋯
       │ Float64?  String?          String?      String?    String?    String?      Int32? ⋯
───────┼────────────────────────────────────────────────────────────────────────────────────
     1 │      1.0  2022_01_BAL_NYJ  2022091107   NYJ        BAL        REG               1 ⋯
     2 │     43.0  2022_01_BAL_NYJ  2022091107   NYJ        BAL        REG               1
     3 │     68.0  2022_01_BAL_NYJ  2022091107   NYJ        BAL        REG               1
     4 │     89.0  2022_01_BAL_NYJ  2022091107   NYJ        BAL        REG               1
     5 │    115.0  2022_01_BAL_NYJ  2022091107   NYJ        BAL        REG               1 ⋯
     6 │    136.0  2022_01_BAL_NYJ  2022091107   NYJ        BAL        REG               1
     7 │    172.0  2022_01_BAL_NYJ  2022091107   NYJ        BAL        REG               1
     8 │    202.0  2022_01_BAL_NYJ  2022091107   NYJ        BAL        REG               1
     9 │    230.0  2022_01_BAL_NYJ  2022091107   NYJ        BAL        REG               1 ⋯
    10 │    254.0  2022_01_BAL_NYJ  2022091107   NYJ        BAL        REG               1
    11 │    275.0  2022_01_BAL_NYJ  2022091107   NYJ        BAL        REG               1
   ⋮   │    ⋮             ⋮              ⋮           ⋮          ⋮           ⋮         ⋮    ⋱
 99090 │   4684.0  2023_22_SF_KC    2024021100   KC         SF         POST             22
 99091 │   4709.0  2023_22_SF_KC    2024021100   KC         SF         POST             22 ⋯
 99092 │   4734.0  2023_22_SF_KC    2024021100   KC         SF         POST             22
 99093 │   4771.0  2023_22_SF_KC    2024021100   KC         SF         POST             22
 99094 │   4759.0  2023_22_SF_KC    2024021100   KC         SF         POST             22
 99095 │   4791.0  2023_22_SF_KC    2024021100   KC         SF         POST             22 ⋯
 99096 │   4813.0  2023_22_SF_KC    2024021100   KC         SF         POST             22
 99097 │   4835.0  2023_22_SF_KC    2024021100   KC         SF         POST             22
 99098 │   4860.0  2023_22_SF_KC    2024021100   KC         SF         POST             22
 99099 │   4881.0  2023_22_SF_KC    2024021100   KC         SF         POST             22 ⋯
                                                          365 columns and 99078 rows omitted

julia> load_pbp(true)
1186651×372 DataFrame
     Row │ play_id   game_id          old_game_id  home_team  away_team  season_type  week ⋯
         │ Float64?  String?          String?      String?    String?    String?      Int3 ⋯
─────────┼──────────────────────────────────────────────────────────────────────────────────
       1 │     35.0  1999_01_ARI_PHI  1999091200   PHI        ARI        REG               ⋯
       2 │     60.0  1999_01_ARI_PHI  1999091200   PHI        ARI        REG
       3 │     82.0  1999_01_ARI_PHI  1999091200   PHI        ARI        REG
       4 │    103.0  1999_01_ARI_PHI  1999091200   PHI        ARI        REG
       5 │    126.0  1999_01_ARI_PHI  1999091200   PHI        ARI        REG               ⋯
       6 │    150.0  1999_01_ARI_PHI  1999091200   PHI        ARI        REG
       7 │    176.0  1999_01_ARI_PHI  1999091200   PHI        ARI        REG
       8 │    197.0  1999_01_ARI_PHI  1999091200   PHI        ARI        REG
       9 │    218.0  1999_01_ARI_PHI  1999091200   PHI        ARI        REG               ⋯
      10 │    240.0  1999_01_ARI_PHI  1999091200   PHI        ARI        REG
      11 │    260.0  1999_01_ARI_PHI  1999091200   PHI        ARI        REG
    ⋮    │    ⋮             ⋮              ⋮           ⋮          ⋮           ⋮         ⋮  ⋱
 1186642 │   4104.0  2024_02_TB_DET   2024091503   DET        TB         REG
 1186643 │   4130.0  2024_02_TB_DET   2024091503   DET        TB         REG               ⋯
 1186644 │   4155.0  2024_02_TB_DET   2024091503   DET        TB         REG
 1186645 │   4162.0  2024_02_TB_DET   2024091503   DET        TB         REG
 1186646 │   4187.0  2024_02_TB_DET   2024091503   DET        TB         REG
 1186647 │   4210.0  2024_02_TB_DET   2024091503   DET        TB         REG               ⋯
 1186648 │   4233.0  2024_02_TB_DET   2024091503   DET        TB         REG
 1186649 │   4256.0  2024_02_TB_DET   2024091503   DET        TB         REG
 1186650 │   4279.0  2024_02_TB_DET   2024091503   DET        TB         REG
 1186651 │   4301.0  2024_02_TB_DET   2024091503   DET        TB         REG               ⋯
                                                        366 columns and 1186630 rows omitted
```

 `NFLData.jl` is designed to quickly load large datasets into memory. Here, we load a clean Julia session and pull in all seasons of PBP data, containing 362 columns and, as of the time of writing this documentation, 1,186,638 plays.

```julia
julia> @time pbp = load_pbp(true);
 37.171214 seconds (59.72 M allocations: 10.669 GiB, 15.75% gc time, 24.79% compilation time: <1% of which was recompilation)

```

Not bad for running on my pretty dinky work laptop (16 GB RM, Intel Core i7-1270P processor)!

## Caching

`NFLData.jl` relies on Julia's JIT compilation to speed up running large objects into memory. However, JIT compiliation does not persist across sessions. `NFLData.jl` uses `Scratch.jl` to cache the data objects referenced across sessions, so subsequent calls that reference the same data objects are faster even if the call comes from a different Julia session. To learn more about this behavior, please visit the [Caching](caching.md) chapter of this docomentation.
