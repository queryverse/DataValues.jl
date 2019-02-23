using Documenter, DataValues

makedocs(
	modules = [DataValues],
	sitename = "DataValues.jl",
	analytics="UA-132838790-1",
	pages = [
        "Introduction" => "index.md"
    ]
)

deploydocs(
    repo = "github.com/queryverse/DataValues.jl.git"
)
