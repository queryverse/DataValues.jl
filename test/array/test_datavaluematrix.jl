using DataValues
using LinearAlgebra
using Test

@testset "DataValueArray: DataMatrix" begin


#----- test Base.diag -----#
A = reshape([1:25...], 5, 5)
m = fill(false, 5, 5)
m[1] = true
m[25] = true
X = DataValueArray(A)
Y = DataValueArray(A, m)

@test isequal(diag(X), DataValueArray([1, 7, 13, 19, 25]))
@test isequal(diag(Y), DataValueArray([1, 7, 13, 19, 25],
                                        [true, false, false, false, true]))

end
