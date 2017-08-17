using DataValues
using Base.Test

type TestNType{T}
    v::DataValue{T}
end

@enum TestEnum a b

@testset "DataValues" begin

include("test_core.jl")
include("test_operations.jl")
include("test_basederived.jl")

end
