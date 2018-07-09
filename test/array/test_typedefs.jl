using Test
using DataValues

@testset "DataValueArray: TypeDefs" begin

x = DataValueArray(
    [1, 2, 3],
    [false, false, true]
)

y = DataValueArray(
    [
        1 2;
        3 4;
    ],
    [
        false false;
        true false;
    ],
)

@test isa(x, DataValueArray{Int, 1})
@test isa(x, DataValueVector{Int})

@test isa(y, DataValueArray{Int, 2})
@test isa(y, DataValueMatrix{Int})

end
