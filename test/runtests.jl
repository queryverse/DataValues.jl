using DataValues
using Base.Test

type TestNType{T}
    v::DataValue{T}
end

@enum TestEnum enum_val_a enum_val_b

@testset "DataValues" begin

include("test_core.jl")
include("test_operations.jl")
include("test_basederived.jl")
include("test_broadcast.jl")

# include("array/test_broadcast.jl")
# include("array/test_broadcast2.jl")
include("array/test_constructors.jl")
include("array/test_indexing.jl")
# include("array/test_map.jl")
include("array/test_datavaluematrix.jl")
include("array/test_datavaluevector.jl")
include("array/test_primitives.jl")
# include("array/test_reduce.jl")
include("array/test_show.jl")
# include("array/test_subarray.jl")
include("array/test_typedefs.jl")

end
