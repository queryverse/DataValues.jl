function enable_whitelist_lifting()
    ops_filename = joinpath(@__DIR__, "..", "deps", "ops.jl")

    open(ops_filename, "w") do f
        println(f, "include(joinpath(@__DIR__,\"..\",\"src\",\"operations.jl\"))")
    end
    info("You need to restart julia to enable whitelist lifting for DataValues.")
end

function disable_whitelist_lifting()
    ops_filename = joinpath(@__DIR__, "..", "deps", "ops.jl")

    open(ops_filename, "w") do f
        println(f, "")
    end
    info("You need to restart julia to disable whitelist lifting for DataValues.")
end
