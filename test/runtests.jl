using DataArrays2
using Base.Test

my_tests = [
    "typedefs.jl",
    "constructors.jl",
    "primitives.jl",
    "indexing.jl",
    "map.jl",
    "broadcast.jl",
    "nullablevector.jl",
    "nullablematrix.jl",
    "reduce.jl",
    "subarray.jl",
    "show.jl",
]

immutable SurvEvent
    time::Float64
    censored::Bool
end

@testset "DataArrays2" begin

for my_test in my_tests
    include(my_test)
end

end
