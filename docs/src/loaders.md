# Loaders

The primary purpose of `NFLData.jl` is to load sports data from the NFL into Julia. All functions that load data into Julia are prefixed with `load_*()`. All files are loaded in as [`DataFrames`](https://dataframes.juliadata.org/stable/).

To load a data resource into memory, when a `load_*()` function is called initially, `NFLData.jl` downloads the data resource as a `.parquet`, `.csv`, or `.csv.gz` file into a Scratch space. From there, `NFLData.jl` reads the data into memory as a DataFrame. If the data object is referenced again, then the cached file (from the Scratch space) is read into memory, and the file is not redownloaded unless the cache is cleared. For more information on this behavior, see [Caching](caching.md).

## Available resources

The data resources available in `NFLData.jl` are maintained by the `nflverse` organization (as is this package). These resources are directly stored in a variety of places, but most commonly as releases in the [`nflverse/nflverse-data` repository](https://github.com/nflverse/nflverse-data/releases). These data resources are typically sourced directly from the NFL and its various APIs, but other third party resources are represented as well, such as data from [pro-football-reference.com](https://www.pro-football-reference.com/).

For a complete list of what resources are available, consult the [`{nflreadr}`](https://nflreadr.nflverse.com/reference/index.html) documentation--all `load_*()` functions from `{nflreadr}` have been implemented in `NFLData.jl`, and the arguments are all (approximately) the same.

Some examples are provided below in terms of how to read and query these `load_*()` functions.

### Universal data resources

Many loaders do not take any arguments, and simply load a data resource into a Julia environment. For example, `load_players()` simply returns all players in the NFL's database, past and present.

```julia
julia> using NFLData

julia> load_players()
20753×32 DataFrame
   Row │ status   display_name      first_name  last_name  esb_id     gsis_id     birth_da ⋯
       │ String?  String?           String?     String?    String?    String?     String?  ⋯
───────┼────────────────────────────────────────────────────────────────────────────────────
     1 │ RET      'Omar Ellison     'Omar       Ellison    ELL711319  00-0004866  1971-10- ⋯
     2 │ ACT      A'Shawn Robinson  A'Shawn     Robinson   ROB367960  00-0032889  1995-03-
     3 │ DEV      A.J. Arcuri       A.J.        Arcuri     ARC716900  00-0037845  1997-08-
     4 │ ACT      A.J. Barner       A.J.        Barner     BAR235889  00-0039793  2002-05-
     5 │ RES      A.J. Bouye        Arlandus    Bouye      BOU651714  00-0030228  1991-08- ⋯
     6 │ ACT      A.J. Brown        Arthur      Brown      BRO413223  00-0035676  1997-06-
     7 │ ACT      A.J. Cann         Aaron       Cann       CAN364949  00-0032255  1991-10-
     8 │ ACT      A.J. Cole         A.J.        Cole       COL214396  00-0035190  1995-11-
     9 │ RET      A.J. Cruz         A.J.        Cruz       CRU779150  00-0032270  missing  ⋯
    10 │ RET      A.J. Dalton       A.J.        Dalton     DAL649400  00-0031108  missing
    11 │ RET      A.J. Davis        A.J.        Davis      DAV115245  00-0029167  1989-07-
   ⋮   │    ⋮            ⋮              ⋮           ⋮          ⋮          ⋮           ⋮    ⋱
 20744 │ DEV      Zion Logue        Zion        Logue      LOG824407  00-0039400  2002-07-
 20745 │ RET      Zipp Duncan       Zipp        Duncan     DUN383863  00-0027294  missing  ⋯
 20746 │ RET      Zola Davis        Zola        Davis      DAV815538  00-0004071  1975-01-
 20747 │ RET      Zoltan Mesko      Zoltan      Mesko      MES280733  00-0027749  1986-03-
 20748 │ CUT      Zonovan Knight    Zonovan     Knight     KNI764772  00-0037157  2001-04-
 20749 │ CUT      Zuri Henry        Zuri        Henry      HEN713594  00-0039689  2000-04- ⋯
 20750 │ RET      Zuriel Smith      Zuriel      Smith      SMI828252  00-0022024  1980-01-
 20751 │ CUT      Zurlon Tipton     Zurlon      Tipton     TIP645432  00-0030855  1989-04-
 20752 │ DEV      Zyon Gilbert      Zyon        Gilbert    GIL144859  00-0037373  1999-02-
 20753 │ ACT      Zyon McCollum     Zyon        McCollum   MCC496223  00-0037268  1999-05- ⋯
                                                           26 columns and 20732 rows omitted
```

### Queryable by season

Many loaders can query by season. By default, these loaders will return the most recent season of data.

```julia
julia> load_pbp() # 2024 season thru week 2
5288×372 DataFrame
  Row │ play_id   game_id          old_game_id  home_team  away_team  season_type  week    ⋯
      │ Float64?  String?          String?      String?    String?    String?      Int32?  ⋯
──────┼─────────────────────────────────────────────────────────────────────────────────────
    1 │      1.0  2024_01_ARI_BUF  2024090801   BUF        ARI        REG               1  ⋯
    2 │     40.0  2024_01_ARI_BUF  2024090801   BUF        ARI        REG               1
    3 │     61.0  2024_01_ARI_BUF  2024090801   BUF        ARI        REG               1
    4 │     83.0  2024_01_ARI_BUF  2024090801   BUF        ARI        REG               1
    5 │    108.0  2024_01_ARI_BUF  2024090801   BUF        ARI        REG               1  ⋯
    6 │    133.0  2024_01_ARI_BUF  2024090801   BUF        ARI        REG               1
    7 │    155.0  2024_01_ARI_BUF  2024090801   BUF        ARI        REG               1
    8 │    177.0  2024_01_ARI_BUF  2024090801   BUF        ARI        REG               1
    9 │    199.0  2024_01_ARI_BUF  2024090801   BUF        ARI        REG               1  ⋯
   10 │    224.0  2024_01_ARI_BUF  2024090801   BUF        ARI        REG               1
   11 │    265.0  2024_01_ARI_BUF  2024090801   BUF        ARI        REG               1
  ⋮   │    ⋮             ⋮              ⋮           ⋮          ⋮           ⋮         ⋮     ⋱
 5279 │   4104.0  2024_02_TB_DET   2024091503   DET        TB         REG               2
 5280 │   4130.0  2024_02_TB_DET   2024091503   DET        TB         REG               2  ⋯
 5281 │   4155.0  2024_02_TB_DET   2024091503   DET        TB         REG               2
 5282 │   4162.0  2024_02_TB_DET   2024091503   DET        TB         REG               2
 5283 │   4187.0  2024_02_TB_DET   2024091503   DET        TB         REG               2
 5284 │   4210.0  2024_02_TB_DET   2024091503   DET        TB         REG               2  ⋯
 5285 │   4233.0  2024_02_TB_DET   2024091503   DET        TB         REG               2
 5286 │   4256.0  2024_02_TB_DET   2024091503   DET        TB         REG               2
 5287 │   4279.0  2024_02_TB_DET   2024091503   DET        TB         REG               2
 5288 │   4301.0  2024_02_TB_DET   2024091503   DET        TB         REG               2  ⋯
                                                           365 columns and 5267 rows omitted
```

You can return a different season of data, if available, by passing in the year to query:

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
```

To get data for multiple years, pass a range of years into the function.

```julia
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
```

To get all years of data for a resource, pass `true` into the function. Be advised that this may take a few seconds.

```julia
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

Trying to query a resource for a year where data is unavailable will throw an error.

```julia
julia> load_pbp(1995)
ERROR: DomainError with 1995:
No NFL PBP data available prior to 1999\!
```

### Other queries

Some data is available to queried with other parameters. For example, you can query ESPN quarterback rating (QBR) data grouped by season or by week:

```julia
julia> load_espn_qbr("season") # by season
1413×23 DataFrame
  Row │ season  season_type  game_week     team_abb  player_id  name_short         rank    ⋯
      │ Int32?  String?      String?       String?   String?    String?            Float64 ⋯
──────┼─────────────────────────────────────────────────────────────────────────────────────
    1 │   2006  Regular      Season Total  IND       1428       P. Manning               1 ⋯
    2 │   2006  Regular      Season Total  NE        2330       T. Brady                 2
    3 │   2006  Regular      Season Total  SD        5529       P. Rivers                3
    4 │   2006  Regular      Season Total  CIN       4459       C. Palmer                4
    5 │   2006  Regular      Season Total  NO        2580       D. Brees                 5 ⋯
    6 │   2006  Regular      Season Total  BAL       733        S. McNair                6
    7 │   2006  Regular      Season Total  NYJ       2149       C. Pennington            7
    8 │   2006  Regular      Season Total  DAL       5209       T. Romo                  8
    9 │   2006  Regular      Season Total  PHI       1753       D. McNabb                9 ⋯
   10 │   2006  Regular      Season Total  ARI       9596       M. Leinart              10
   11 │   2006  Regular      Season Total  STL       2299       M. Bulger               11
  ⋮   │   ⋮          ⋮            ⋮           ⋮          ⋮              ⋮              ⋮   ⋱
 1404 │   2024  Regular      Season Total  NE        4569173    R. Stevenson       missing
 1405 │   2024  Regular      Season Total  LV        2576336    A. Abdullah        missing ⋯
 1406 │   2024  Regular      Season Total  NO        4243322    J. Haener          missing
 1407 │   2024  Regular      Season Total  CAR       14012      A. Dalton          missing
 1408 │   2024  Regular      Season Total  MIN       4242431    T. Chandler        missing
 1409 │   2024  Regular      Season Total  DAL       2972515    C. Rush            missing ⋯
 1410 │   2024  Regular      Season Total  MIA       4036419    S. Thompson        missing
 1411 │   2024  Regular      Season Total  KC        4361529    I. Pacheco         missing
 1412 │   2024  Regular      Season Total  SF        3126486    D. Samuel Sr.      missing
 1413 │   2024  Regular      Season Total  ARI       4360175    C. Tune            missing ⋯
                                                            17 columns and 1392 rows omitted

julia> load_espn_qbr("week") # by week
9604×30 DataFrame
  Row │ season  season_type  game_id    game_week  week_text  team_abb  player_id  name_sh ⋯
      │ Int32?  String?      String?    Int32?     String?    String?   String?    String? ⋯
──────┼─────────────────────────────────────────────────────────────────────────────────────
    1 │   2006  Regular      260910009          1  Week 1     CHI       4480       R. Gros ⋯
    2 │   2006  Regular      260910034          1  Week 1     PHI       1753       D. McNa
    3 │   2006  Regular      260910010          1  Week 1     NYJ       2149       C. Penn
    4 │   2006  Regular      260910019          1  Week 1     IND       1428       P. Mann
    5 │   2006  Regular      260910029          1  Week 1     ATL       2549       M. Vick ⋯
    6 │   2006  Regular      260907023          1  Week 1     PIT       1490       C. Batc
    7 │   2006  Regular      260910027          1  Week 1     BAL       733        S. McNa
    8 │   2006  Regular      260910030          1  Week 1     JAX       4465       B. Left
    9 │   2006  Regular      260911028          1  Week 1     MIN       331        B. John ⋯
   10 │   2006  Regular      260910017          1  Week 1     BUF       5547       J.P. Lo
   11 │   2006  Regular      260911028          1  Week 1     WSH       445        M. Brun
  ⋮   │   ⋮          ⋮           ⋮          ⋮          ⋮         ⋮          ⋮            ⋮ ⋱
 9595 │   2024  Regular      401671659          1  Week 1     LAC       4038941    J. Herb
 9596 │   2024  Regular      401671719          1  Week 1     TEN       4361418    W. Levi ⋯
 9597 │   2024  Regular      401671761          1  Week 1     DAL       2577417    D. Pres
 9598 │   2024  Regular      401671719          1  Week 1     CHI       4431611    C. Will
 9599 │   2024  Regular      401671805          1  Week 1     GB        4036378    J. Love
 9600 │   2024  Regular      401671712          1  Week 1     NYG       3917792    D. Jone ⋯
 9601 │   2024  Regular      401671734          1  Week 1     CAR       4685720    B. Youn
 9602 │   2024  Regular      401671761          1  Week 1     CLE       3122840    D. Wats
 9603 │   2024  Regular      401671807          2  Week 2     BUF       3918298    J. Alle
 9604 │   2024  Regular      401671807          2  Week 2     MIA       4241479    T. Tago ⋯
                                                            23 columns and 9583 rows omitted
```

## Data dictionaries

Data dictionaries for almost every data resource available through a `load_*()` function is available on the [`{nflreadr}` website](https://nflreadr.nflverse.com/articles/index.html).

