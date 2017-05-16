module TestTypeDefs
    using Base.Test
    using DataArrays2

    x = DataArray2(
        [1, 2, 3],
        [false, false, true]
    )

    y = DataArray2(
        [
            1 2;
            3 4;
        ],
        [
            false false;
            true false;
        ],
    )

    @test isa(x, DataArray2{Int, 1})
    @test isa(x, DataVector2{Int})

    @test isa(y, DataArray2{Int, 2})
    @test isa(y, DataMatrix2{Int})
end
