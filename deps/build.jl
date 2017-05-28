ops_filename = joinpath(@__DIR__, "ops.jl")

if !isfile(ops_filename)
    open(ops_filename, "w") do f
        println(f, "include(joinpath(@__DIR__,\"..\",\"src\",\"operations.jl\"))")
    end
end
