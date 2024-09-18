using Documenter, NFLData

makedocs(
    sitename="NFLData.jl",
    pages = [
        "Home" => "index.md",
        "Loaders" => "loaders.md",
        "Utilities" => "helpers.md",
        "Caching" => "caching.md",
        "NFLVerse and additional resources" => "additional.md"
    ]
)