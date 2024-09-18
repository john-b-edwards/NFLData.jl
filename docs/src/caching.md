# Caching

`NFLData.jl` uses `Scratch.jl` to cache previously loaded data objects on a local disk. [This, in conjunction with Julia's Just-In-Time (JIT) compilation](https://ucidatascienceinitiative.github.io/IntroToJulia/Html/WhyJulia), makes reading data into Julia with this package extremely fast.

## Reading data

This section walks through how `NFLData.jl` loads data into Julia at a high level depending on the context that each function call exists in.

### Initial function call

When a user calls a `load_*()` function for the first time, the following process occurs:
1. The relevant resource is queried from the web.
2. The resource is downloaded to the Scratch space as a .parquet, .csv, or .csv.gz file.
3. The resource is read into the Julia workspace

```julia
julia> using NFLData

julia> julia> @time load_rosters(2023);
  3.156570 seconds (1.43 M allocations: 101.806 MiB, 41.90% gc time, 68.60% compilation time)
```

### Relying on JIT Compilation

With JIT compiling, Julia keeps a record of all previous function calls in a Julia session. When a function is called with the same arguments as a previous function call in the session, Julia returns the cached object, rather than re-running the function from scratch.

```julia
julia> @time load_rosters(2023);
  0.007354 seconds (56.84 k allocations: 6.774 MiB)
```

### Caching

However, calling the same function with different arguments will not result in the same speedup, because Julia does not recognize the new function call. This means that even if a call references the same data object, it can't cache that file from a previous function call in the workspace (for example, `load_rosters(2022:2023)` and `load_rosters(2023:2024)` both reference the same underlying `rosters_2023.parquet` file, but because the arguments passed to `load_rosters(2022:2023)` and `load_rosters(2023:2024)` are different, Julia will not rely on JIT compilation to speed up reading the `roster_2023.parquet` file into memory).

To resolve this issue, `NFLData.jl` checks if a referenced data resource already exists in the Scratch space, and  if it does, rather than re-downloading the file, it just reads the local version. For this example, this speeds up _any_ function call that references a previously downloaded data object. Notice how a function call that references the previously cached 2023 roster file is faster than one that references roster files that were not previously cached.

```julia
julia> @time load_rosters(2020:2021); # none of these files have been cached before
  1.399959 seconds (121.23 k allocations: 15.015 MiB)

julia> @time load_rosters(2022:2023); # just the 2023 file has been cached
  0.591959 seconds (115.24 k allocations: 14.204 MiB)
```

## Cache management

By default, `NFLData.jl` will clear out the cache if the oldest object in the cache is more than 24 hours old.

If you need to manually clear out the cache, you can run `using NFLData; clear_cache()`.

To disable the caching behavior, you can run `using NFLData; cache_data_pref(false)` and restart your Julia session.
