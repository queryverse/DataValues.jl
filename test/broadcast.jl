using DataArrays2
using Base.Test
using Compat

@testset "Broadcast" begin

A1 = rand(Int, 10)
M1 = rand(Bool, 10)
n = rand(2:5)
dims = [ rand(2:5) for i in 1:n]
A2 = rand(10, dims...)
M2 = rand(Bool, 10, dims...)
C2 = Array{Float64}(10, dims...)
i = rand(2:5)
A3 = rand(10, [dims; i]...)
M3 = rand(Bool, 10, [dims; i]...)
C3 = Array{Float64}(10, [dims; i]...)

m1 = broadcast((x,y)->x, M1, M2)
m2 = broadcast((x,y)->x, M2, M3)
R2 = reshape(Bool[ (x->(m1[x] | M2[x]))(i) for i in 1:length(M2) ], size(M2))
R3 = reshape(Bool[ (x->(m2[x] | M3[x]))(i) for i in 1:length(M3) ], size(M3))
r2 = broadcast((x,y)->x, R2, R3)
Q3 = reshape(Bool[ (x->(r2[x] | R3[x]))(i) for i in 1:length(R3) ], size(M3))

U1 = DataArray2(A1)
U2 = DataArray2(A2)
U3 = DataArray2(A3)
V1 = DataArray2(A1, M1)
V2 = DataArray2(A2, M2)
V3 = DataArray2(A3, M3)
Z2 = DataArray2(Float64, 10, dims...)
Z3 = DataArray2(Float64, 10, [dims; i]...)

f() = 5
f(x::Real) = 5 * x
f(x::Real, y::Real) = x * y
f(x::Real, y::Real, z::Real) = x * y * z

    for (dests, arrays, DataArray2s, mask) in
    ( ((C2, Z2), (A1, A2), (U1, U2), ()),
        ((C3, Z3), (A2, A3), (U2, U3), ()),
        ((C3, Z3), (A1, A2, A3), (U1, U2, U3), ()),

        ((C2, Z2), (A1, A2), (V1, V2), (R2,)),
        ((C3, Z3), (A2, A3), (V2, V3), (R3,)),
        ((C3, Z3), (A1, A2, A3), (V1, V2, V3), (Q3,)),
)

    # Base.broadcast!(f, B::DataArray2, As::DataArray2...)
    broadcast!(f, dests[1], arrays...)
    # TODO Fix broadcast!(i->f.(i), dests[2], DataArray2s...)
    # TODO Fix @test isequal(dests[2], DataArray2(dests[1], mask...))

    # Base.broadcast(f, As::DataArray2...)
    D = broadcast(f, arrays...)
    # TODO Fix X = broadcast(f, DataArray2s...)
    # TODO Fix @test isequal(X, DataArray2(D, mask...))
end

# Base.broadcast!(f, X::DataArray2)
for (array, dataarray2, mask) in
    ( (A1, U1, ()), (A2, U2, ()), (A3, U3, ()),
        (A1, V1, (M1,)), (A2, V2, (M2,)), (A3, V3, (M3,)),
)
    broadcast!(f, array)
    broadcast!(f, dataarray2)
    # TODO Fix @test isequal(dataarray2, DataArray2(array, mask...))
end

# test broadcasted arithmetic operators
A = rand(10)
X1 = DataArray2(A)
n = rand(2:5)
dims = rand(2:5, n)
B = rand(Float64, 10, dims...)
X2 = DataArray2(B)
M = rand(Bool, 10, dims...)
Y = DataArray2(B, M)

A = rand(Bool, 100)
B = rand(Bool, 100)
M1 = rand(Bool, 100)
M2 = rand(Bool, 100)
X = DataArray2(A, M1)
Y = DataArray2(B, M2)
# TODO Fix @test broadcast(&, X, Y) == DataArray2(A .& B, M1 .| M2)
# TODO Fix @test broadcast(|, X, Y) == DataArray2(A .| B, M1 .| M2)

# Test broadcasting with constructor
t = DataArray2(rand(3))
c = DataArray2(rand(Bool, 3))
# TODO Fix @test isequal(SurvEvent.(t, c), DataArray2([SurvEvent(get(t[i]), get(c[i])) for i in 1:3]))
# TODO Fix @test isa(SurvEvent.(t, c), DataVector2{SurvEvent})

end
