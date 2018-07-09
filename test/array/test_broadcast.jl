using DataValues
using Test

@testset "DataValueArray: Broadcast" begin

A1 = rand(Int, 10)
M1 = rand(Bool, 10)
n = rand(2:5)
dims = [ rand(2:5) for i in 1:n]
A2 = rand(10, dims...)
M2 = rand(Bool, 10, dims...)
C2 = Array{Float64}(undef, 10, dims...)
i = rand(2:5)
A3 = rand(10, [dims; i]...)
M3 = rand(Bool, 10, [dims; i]...)
C3 = Array{Float64}(undef, 10, [dims; i]...)

m1 = broadcast((x,y)->x, M1, M2)
m2 = broadcast((x,y)->x, M2, M3)
R2 = reshape(Bool[ (x->(m1[x] | M2[x]))(i) for i in 1:length(M2) ], size(M2))
R3 = reshape(Bool[ (x->(m2[x] | M3[x]))(i) for i in 1:length(M3) ], size(M3))
r2 = broadcast((x,y)->x, R2, R3)
Q3 = reshape(Bool[ (x->(r2[x] | R3[x]))(i) for i in 1:length(R3) ], size(M3))

U1 = DataValueArray(A1)
U2 = DataValueArray(A2)
U3 = DataValueArray(A3)
V1 = DataValueArray(A1, M1)
V2 = DataValueArray(A2, M2)
V3 = DataValueArray(A3, M3)
Z2 = DataValueArray{Float64}(10, dims...)
Z3 = DataValueArray{Float64}(10, [dims; i]...)

f() = 5
f(x) = 5 * x
f(x, y) = x * y
f(x, y, z) = x * y * z

for (dests, arrays, nullablearrays, mask) in
    ( ((C2, Z2), (A1, A2), (U1, U2), ()),
      ((C3, Z3), (A2, A3), (U2, U3), ()),
      ((C3, Z3), (A1, A2, A3), (U1, U2, U3), ()),

      ((C2, Z2), (A1, A2), (V1, V2), (R2,)),
      ((C3, Z3), (A2, A3), (V2, V3), (R3,)),
      ((C3, Z3), (A1, A2, A3), (V1, V2, V3), (Q3,)),
)

    # Base.broadcast!(f, B::DataValueArray, As::DataValueArray...)
    broadcast!(f, dests[1], arrays...)
    broadcast!(f, dests[2], nullablearrays...)
    @test isequal(dests[2], DataValueArray(dests[1], mask...))

    # Base.broadcast(f, As::DataValueArray...)
    D = broadcast(f, arrays...)
    X = broadcast(f, nullablearrays...)
    @test isequal(X, DataValueArray(D, mask...))
end

# Base.broadcast!(f, X::DataValueArray)
for (array, nullablearray, mask) in
    ( (A1, U1, ()), (A2, U2, ()), (A3, U3, ()),
      (A1, V1, (M1,)), (A2, V2, (M2,)), (A3, V3, (M3,)),
)
    broadcast!(f, array)
    broadcast!(f, nullablearray)
    @test isequal(nullablearray, DataValueArray(array, mask...))
end

# test broadcasted arithmetic operators
A = rand(10)
X1 = DataValueArray(A)
n = rand(2:5)
dims = rand(2:5, n)
B = rand(Float64, 10, dims...)
X2 = DataValueArray(B)
M = rand(Bool, 10, dims...)
Y = DataValueArray(B, M)

A = rand(Bool, 100)
B = rand(Bool, 100)
M1 = rand(Bool, 100)
M2 = rand(Bool, 100)
X = DataValueArray(A, M1)
Y = DataValueArray(B, M2)
# TODO This NullableArray test doesn't use 3VL
# @test isequal(broadcast(&, X, Y), DataValueArray(A .& B, M1 .| M2))
# @test isequal(broadcast(|, X, Y), DataValueArray(A .| B, M1 .| M2))

end # module
