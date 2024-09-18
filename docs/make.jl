using Documenter, NFLData

makedocs(
    sitename="NFLData.jl",
    pages = [
        "Home" => "index.md",
        "Loaders" => "loaders.md",
        "Utilities" => "helpers.md",
        "NFLVerse and additional resources" => "additional.md",
        "Caching" => "caching.md"
    ]
)