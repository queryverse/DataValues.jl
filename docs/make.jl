using Documenter, DataValues

makedocs(modules=[DataValues],
	sitename="DataValues.jl",
	format = Documenter.HTML(analytics = "UA-132838790-1"),
	warnonly = [:missing_docs],
	pages=[
        "Introduction" => "index.md"
    ])

deploydocs(repo="github.com/queryverse/DataValues.jl.git")
