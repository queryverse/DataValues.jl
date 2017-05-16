module TestMatrix
    using DataArrays2
    using Base.Test

    #----- test Base.diag -----#
    A = reshape([1:25...], 5, 5)
    m = fill(false, 5, 5)
    m[1] = true
    m[25] = true
    X = DataArray2(A)
    Y = DataArray2(A, m)

    @test isequal(diag(X), DataArray2([1, 7, 13, 19, 25]))
    @test isequal(diag(Y), DataArray2([1, 7, 13, 19, 25],
                                         [true, false, false, false, true]))

end
