# NFLData

[![CI](https://github.com/john-b-edwards/NFLData.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/john-b-edwards/NFLData.jl/actions/workflows/CI.yml)

[![nflverse
discord](https://img.shields.io/discord/789805604076126219?color=7289da&label=nflverse%20discord&logo=discord&logoColor=fff&style=flat-square)](https://discord.com/invite/5Er2FBnnQa)

`NFLData.jl` is a low level package designed to read football data from the [nflverse](https://nflverse.nflverse.com/) into Julia in a `DataFrame` format. This package can be thought of as the Julia equivalent of the `{nflreadr}` R package. Functions are named identically to existing functions in `{nflreadr}`, (typically) take the same arguments, and should return identical data. This package is built by and mantained by the nflverse organization, primarily @john-b-edwards.

This package is currently in development. Functions may not work properly. In the event that you encounter a bug or unexpected error, please [make an issue](https://github.com/john-b-edwards/NFLData.jl/issues/new/choose) and we will attempt to address it.

## Installation

Eventually, we plan on making `NFLData.jl` available via the Julia package manager. Until that time, you can install the development version directly from GitHub. 

You can install the package with the following one liner:

```julia
using Pkg; Pkg.add("https://github.com/john-b-edwards/NFLData.jl")
```

You can also add the package using the `Pkg.jl` REPL. Open an interactive Julia session, then press `]` to open the REPL, then run `add https://github.com/john-b-edwards/NFLData.jl`.

## Usage

### `load_*()` functions

The main functions of `NFLData.jl` are prefixed with `load_*`. For example, to load all NFL teams and associated information, you can run:

```
julia> using NFLData
By default, NFLData.jl caches data for up to 24 hours.
To disable this caching, run `cache_data_pref(false)` and restart Julia.
To clear the cache, run `clear_cache()`.

julia> load_teams()
36×16 DataFrame
 Row │ team_abbr  team_name              team_id  team_nick   team_conf  team_division  team_color  team_color2  team_color3  team_color4  team_log ⋯     │ String3    String31               Int64    String15    String3    String15       String7     String7      String7      String7      String   ⋯─────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────   1 │ ARI        Arizona Cardinals         3800  Cardinals   NFC        NFC West       #97233F     #000000      #ffb612      #a5acaf      https:// ⋯   2 │ ATL        Atlanta Falcons            200  Falcons     NFC        NFC South      #A71930     #000000      #a5acaf      #a30d2d      https://  
   3 │ BAL        Baltimore Ravens           325  Ravens      AFC        AFC North      #241773     #9E7C0C      #9e7c0c      #c60c30      https://  
   4 │ BUF        Buffalo Bills              610  Bills       AFC        AFC East       #00338D     #C60C30      #0c2e82      #d50a0a      https://  
   5 │ CAR        Carolina Panthers          750  Panthers    NFC        NFC South      #0085CA     #000000      #bfc0bf      #0085ca      https:// ⋯   6 │ CHI        Chicago Bears              810  Bears       NFC        NFC North      #0B162A     #E64100      #0b162a      #E64100      https://  
   7 │ CIN        Cincinnati Bengals         920  Bengals     AFC        AFC North      #FB4F14     #000000      #000000      #d32f1e      https://  
  ⋮  │     ⋮                ⋮               ⋮         ⋮           ⋮            ⋮            ⋮            ⋮            ⋮            ⋮                ⋱  31 │ SEA        Seattle Seahawks          4600  Seahawks    NFC        NFC West       #002244     #69be28      #a5acaf      #001532      https://  
  32 │ SF         San Francisco 49ers       4500  49ers       NFC        NFC West       #AA0000     #B3995D      #000000      #a5acaf      https:// ⋯  33 │ STL        St. Louis Rams            2510  Rams        NFC        NFC West       #003594     #FFD100      #001532      #af925d      https://  
  34 │ TB         Tampa Bay Buccaneers      4900  Buccaneers  NFC        NFC South      #A71930     #322F2B      #000000      #ff7900      https://  
  35 │ TEN        Tennessee Titans          2100  Titans      AFC        AFC South      #002244     #4B92DB      #c60c30      #a5acaf      https://  
  36 │ WAS        Washington Commanders     5110  Commanders  NFC        NFC East       #5A1414     #FFB612      #000000      #5b2b2f      https:// ⋯                                                                                                                        6 columns and 23 rows omitted
  ```

  Some functions can query data from specific or multiple years. For example, to load NFLFastR play by play data from 2023, you can run the following:

  ```
  julia> load_pbp(2023)
49665×372 DataFrame
   Row │ play_id   game_id          old_game_id  home_team  away_team  season_type  week    posteam  posteam_type  defteam  side_of_field  yardline ⋯       │ Float64?  String?          String?      String?    String?    String?      Int32?  String?  String?       String?  String?        Float64? ⋯───────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────     1 │      1.0  2023_01_ARI_WAS  2023091007   WAS        ARI        REG               1  missing  missing       missing  missing           missi ⋯     2 │     39.0  2023_01_ARI_WAS  2023091007   WAS        ARI        REG               1  WAS      home          ARI      ARI
     3 │     55.0  2023_01_ARI_WAS  2023091007   WAS        ARI        REG               1  WAS      home          ARI      WAS
     4 │     77.0  2023_01_ARI_WAS  2023091007   WAS        ARI        REG               1  WAS      home          ARI      WAS
     5 │    102.0  2023_01_ARI_WAS  2023091007   WAS        ARI        REG               1  WAS      home          ARI      WAS                     ⋯     6 │    124.0  2023_01_ARI_WAS  2023091007   WAS        ARI        REG               1  WAS      home          ARI      WAS
     7 │    147.0  2023_01_ARI_WAS  2023091007   WAS        ARI        REG               1  WAS      home          ARI      WAS
   ⋮   │    ⋮             ⋮              ⋮           ⋮          ⋮           ⋮         ⋮        ⋮          ⋮           ⋮           ⋮             ⋮   ⋱ 49660 │   4759.0  2023_22_SF_KC    2024021100   KC         SF         POST             22  KC       home          SF       SF
 49661 │   4791.0  2023_22_SF_KC    2024021100   KC         SF         POST             22  KC       home          SF       SF                      ⋯ 49662 │   4813.0  2023_22_SF_KC    2024021100   KC         SF         POST             22  KC       home          SF       SF
 49663 │   4835.0  2023_22_SF_KC    2024021100   KC         SF         POST             22  KC       home          SF       SF
 49664 │   4860.0  2023_22_SF_KC    2024021100   KC         SF         POST             22  KC       home          SF       SF
 49665 │   4881.0  2023_22_SF_KC    2024021100   KC         SF         POST             22  KC       home          SF       missing           missi ⋯                                                                                                                   361 columns and 49652 rows omitted
 ```

 To load data from multiple seasons, pass in either a `Vector` or `UnitRange` of seasons. For example, to load PBP data from 2022 and 2023:

 ```
 julia> load_pbp(2022:2023)
99099×372 DataFrame
   Row │ play_id   game_id          old_game_id  home_team  away_team  season_type  week    posteam  posteam_type  defteam  side_of_field  yardline ⋯       │ Float64?  String?          String?      String?    String?    String?      Int32?  String?  String?       String?  String?        Float64? ⋯───────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────     1 │      1.0  2022_01_BAL_NYJ  2022091107   NYJ        BAL        REG               1  missing  missing       missing  missing           missi ⋯     2 │     43.0  2022_01_BAL_NYJ  2022091107   NYJ        BAL        REG               1  NYJ      home          BAL      BAL
     3 │     68.0  2022_01_BAL_NYJ  2022091107   NYJ        BAL        REG               1  NYJ      home          BAL      NYJ
     4 │     89.0  2022_01_BAL_NYJ  2022091107   NYJ        BAL        REG               1  NYJ      home          BAL      NYJ
     5 │    115.0  2022_01_BAL_NYJ  2022091107   NYJ        BAL        REG               1  NYJ      home          BAL      NYJ                     ⋯     6 │    136.0  2022_01_BAL_NYJ  2022091107   NYJ        BAL        REG               1  NYJ      home          BAL      NYJ
     7 │    172.0  2022_01_BAL_NYJ  2022091107   NYJ        BAL        REG               1  NYJ      home          BAL      NYJ
   ⋮   │    ⋮             ⋮              ⋮           ⋮          ⋮           ⋮         ⋮        ⋮          ⋮           ⋮           ⋮             ⋮   ⋱ 99094 │   4759.0  2023_22_SF_KC    2024021100   KC         SF         POST             22  KC       home          SF       SF
 99095 │   4791.0  2023_22_SF_KC    2024021100   KC         SF         POST             22  KC       home          SF       SF                      ⋯ 99096 │   4813.0  2023_22_SF_KC    2024021100   KC         SF         POST             22  KC       home          SF       SF
 99097 │   4835.0  2023_22_SF_KC    2024021100   KC         SF         POST             22  KC       home          SF       SF
 99098 │   4860.0  2023_22_SF_KC    2024021100   KC         SF         POST             22  KC       home          SF       SF
 99099 │   4881.0  2023_22_SF_KC    2024021100   KC         SF         POST             22  KC       home          SF       missing           missi ⋯                                                                                                                   361 columns and 99086 rows omitted
 ```

 To load all seasons available for a given data resource, simply pass `true` as an argument to the function.

 ```
 julia> load_pbp(true)
1183941×372 DataFrame
     Row │ play_id   game_id          old_game_id  home_team  away_team  season_type  week    posteam  posteam_type  defteam  side_of_field  yardli ⋯         │ Float64?  String?          String?      String?    String?    String?      Int32?  String?  String?       String?  String?        Float6 ⋯─────────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────       1 │     35.0  1999_01_ARI_PHI  1999091200   PHI        ARI        REG               1  PHI      home          ARI      ARI                   ⋯       2 │     60.0  1999_01_ARI_PHI  1999091200   PHI        ARI        REG               1  PHI      home          ARI      PHI
       3 │     82.0  1999_01_ARI_PHI  1999091200   PHI        ARI        REG               1  PHI      home          ARI      PHI
       4 │    103.0  1999_01_ARI_PHI  1999091200   PHI        ARI        REG               1  PHI      home          ARI      PHI
       5 │    126.0  1999_01_ARI_PHI  1999091200   PHI        ARI        REG               1  PHI      home          ARI      PHI                   ⋯       6 │    150.0  1999_01_ARI_PHI  1999091200   PHI        ARI        REG               1  PHI      home          ARI      PHI
       7 │    176.0  1999_01_ARI_PHI  1999091200   PHI        ARI        REG               1  ARI      away          PHI      ARI
    ⋮    │    ⋮             ⋮              ⋮           ⋮          ⋮           ⋮         ⋮        ⋮          ⋮           ⋮           ⋮             ⋮ ⋱ 1183936 │   3939.0  2024_01_WAS_TB   2024090811   TB         WAS        REG               1  WAS      away          TB       TB
 1183937 │   3969.0  2024_01_WAS_TB   2024090811   TB         WAS        REG               1  WAS      away          TB       TB                    ⋯ 1183938 │   3982.0  2024_01_WAS_TB   2024090811   TB         WAS        REG               1  TB       home          WAS      WAS
 1183939 │   4005.0  2024_01_WAS_TB   2024090811   TB         WAS        REG               1  TB       home          WAS      WAS
 1183940 │   4027.0  2024_01_WAS_TB   2024090811   TB         WAS        REG               1  TB       home          WAS      WAS
 1183941 │   4049.0  2024_01_WAS_TB   2024090811   TB         WAS        REG               1  TB       home          WAS      missing           mis ⋯                                                                                                                 361 columns and 1183928 rows omitted
 ```

By default, if _no_ argument is passed to a function that queries a data resource by season, the most recent season of data is returned.

```
julia> load_pbp()
2578×372 DataFrame
  Row │ play_id   game_id          old_game_id  home_team  away_team  season_type  week    posteam  posteam_type  defteam  side_of_field  yardline_ ⋯      │ Float64?  String?          String?      String?    String?    String?      Int32?  String?  String?       String?  String?        Float64?  ⋯──────┼──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────    1 │      1.0  2024_01_ARI_BUF  2024090801   BUF        ARI        REG               1  missing  missing       missing  missing           missin ⋯    2 │     40.0  2024_01_ARI_BUF  2024090801   BUF        ARI        REG               1  ARI      away          BUF      BUF                    3  
    3 │     61.0  2024_01_ARI_BUF  2024090801   BUF        ARI        REG               1  ARI      away          BUF      ARI                    7  
    4 │     83.0  2024_01_ARI_BUF  2024090801   BUF        ARI        REG               1  ARI      away          BUF      ARI                    6  
    5 │    108.0  2024_01_ARI_BUF  2024090801   BUF        ARI        REG               1  ARI      away          BUF      BUF                    4 ⋯    6 │    133.0  2024_01_ARI_BUF  2024090801   BUF        ARI        REG               1  ARI      away          BUF      BUF                    3  
    7 │    155.0  2024_01_ARI_BUF  2024090801   BUF        ARI        REG               1  ARI      away          BUF      BUF                    3  
  ⋮   │    ⋮             ⋮              ⋮           ⋮          ⋮           ⋮         ⋮        ⋮          ⋮           ⋮           ⋮             ⋮    ⋱ 2573 │   3939.0  2024_01_WAS_TB   2024090811   TB         WAS        REG               1  WAS      away          TB       TB
 2574 │   3969.0  2024_01_WAS_TB   2024090811   TB         WAS        REG               1  WAS      away          TB       TB                       ⋯ 2575 │   3982.0  2024_01_WAS_TB   2024090811   TB         WAS        REG               1  TB       home          WAS      WAS                    3  
 2576 │   4005.0  2024_01_WAS_TB   2024090811   TB         WAS        REG               1  TB       home          WAS      WAS                    4  
 2577 │   4027.0  2024_01_WAS_TB   2024090811   TB         WAS        REG               1  TB       home          WAS      WAS                    4  
 2578 │   4049.0  2024_01_WAS_TB   2024090811   TB         WAS        REG               1  TB       home          WAS      missing           missin ⋯                                                                                                                    361 columns and 2565 rows omitted
```

### Other utilities
Some helper functions have been ported over from `{nflreadr}` for use in `NFLData.jl`. For example, to reference the most recent season of NFL play, use `most_recent_season()`:

```
julia> most_recent_season()
2024
```

### Caching
`NFLData.jl` relies on `Scatch.jl` to cache data. In most cases, when a data resource is pulled in, `NFLData.jl` will download the data resource to a local scatch space, then read the file into memory. There is some minor overhead in pulling the data into memory, but subsequent runs referencing these data resources are extraordinarily fast. For functions with identical calls, this is a product of Julia's [Just In Time (JIT) compliation](https://ucidatascienceinitiative.github.io/IntroToJulia/Html/WhyJulia).

```
julia> @time load_rosters(2023);
  3.156570 seconds (1.43 M allocations: 101.806 MiB, 41.90% gc time, 68.60% compilation time)

julia> @time load_rosters(2023);
  0.007354 seconds (56.84 k allocations: 6.774 MiB)

 ```

However, this caching functionality will also speed up reading in _different_ calls that reference the same object. Notice how calling `load_rosters(2020:2021)` takes 2x longer than `load_rosters(2022:2023)`, because the 2023 roster file has already been donwloaded to the local cache.

```
julia> @time load_rosters(2020:2021);
  1.399959 seconds (121.23 k allocations: 15.015 MiB)

julia> @time load_rosters(2022:2023);
  0.591959 seconds (115.24 k allocations: 14.204 MiB)
```

By default, the cache is cleared after 24 hours (as these data resources may be updated often, especially during the season). If you wish to clear the cache manually, simply run `clear_cache()`. Note that due to JIT compilation, calling the `load_players()` function is still faster than the original call, even after clearing the cache.

```
julia> @time load_players();
  1.270892 seconds (763.69 k allocations: 64.265 MiB, 2.00% gc time, 24.62% compilation time)

julia> clear_cache()

julia> @time load_players();
  0.598928 seconds (182.71 k allocations: 24.055 MiB, 1.44% gc time)
```

As the startup message for `NFLData.jl` indicates, you can disable this behavior by running `cache_data_pref(false)` and restarting your Julia session.

## Getting help
The best places to get help on this package are:

* the [nflverse discord](https://discord.com/invite/5Er2FBnnQa) (for both this package as well as anything R/NFL related)
* opening [an issue](https://github.com/john-b-edwards/NFLData.jl/issues/new/choose)

## Contributing
Many hands make light work! Here are some ways you can contribute to this project:

* You can [open an issue](https://github.com/john-b-edwards/NFLData.jl/issues/new/choose) if you’d like to request specific data or report a bug/error.

## Terms of Use
This package is released as open source under the MIT License. NFL data accessed by this package belong to their respective owners, and are governed by their terms of use.