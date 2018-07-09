@testset "DataValueArray: Map" begin

using Test
using DataValues

# create m random arrays each with N dimensions and length dims[i] along
# dimension i for i=1:N
N = rand(2:5)
dims = Int[ rand(3:8) for i in 1:N ]
m = rand(4:6)
n = rand(1:3)
As = Array[ [rand(dims...) for i in 1:n] ; [rand(Int, dims...) for i in n+1:m] ]

Ms = [ rand(Bool, dims...) for i in 1:m ]
Xs = Array{DataValueArray, 1}()
for i in 1:m
    push!(Xs, DataValueArray(As[i]))
end
Ys = Array{DataValueArray, 1}()
for i in 1:m
    push!(Ys, DataValueArray(As[i], Ms[i]))
end

C = Array{Float64}(dims...)
Z = DataValueArray{Float64}(dims...)

R = map(|, Ms...)

f(x...) = sum(x)
dests = (C, Z)

# 1 arg
for (args, masks) in (
    ((As, Xs), fill((), m)), ((As, Ys), [ (Ms[i],) for i in 1:m ])
)
    for i in 1:m
        # map!
        map!(f, args[1][i], args[1][i]) # map!(f, As[i], As[i])
        map!(f, args[2][i], args[2][i]) # map!(f, Xs[i], Xs[i])
        @test isequal(args[2][i], DataValueArray(args[1][i], masks[i]...))
        # map
        A = map(f, args[1][i])
        X = map(f, args[2][i])
        @test isequal(X, DataValueArray(A, masks[i]...))
    end
end
# 2 arg
i, j = rand(1:m), rand(1:m)
S = map(|, Ms[i], Ms[j])
for (args, mask) in (
    ((As, Xs), ()), ((As, Ys), (S,))
)
    # map!
    map!(f, dests[1], args[1][i], args[1][j])
    map!(f, dests[2], args[2][i], args[2][j])
    @test isequal(dests[2], DataValueArray(dests[1], mask...))
    # map
    map(f, args[1][i], args[1][j])
    map(f, args[2][i], args[2][j])
    @test isequal(dests[2], DataValueArray(dests[1], mask...))
end
# n arg
for (args, mask) in (
    ((As, Xs), ()), ((As, Ys), (R,))
)
    # map!
    map!(f, dests[1], args[1]...)
    map!(f, dests[2], args[2]...)
    @test isequal(dests[2], DataValueArray(dests[1], mask...))
    # map
    map(f, args[1]...)
    map(f, args[2]...)
    @test isequal(dests[2], DataValueArray(dests[1], mask...))
end

# test map over empty DataValueArrays
X = DataValueArray(Int[])
h1(x) = 5.0*x
h2(x) = x
h2(x...) = prod(x)

Z1 = map(h1, X)
Z2 = map(h2, X)
@test isempty(Z1)
@test isa(Z1, DataValueArray{Float64})
@test isempty(Z2)
@test isa(Z2, DataValueArray{Int})

# if a function has no method for inner eltype of empty DataValueArray,
# result should be empty DataValueArray{Any}() for consistency with generic map()
h3(x::Float64...) = prod(x)
Z3 = map(h3, X)
@test isempty(Z3)
@test isa(Z3, DataValueArray{Any})
Z3 = map(h3, X, X)
@test isempty(Z3)
@test isa(Z3, DataValueVector{Any})
Z3 = map(h3, X, X, X)
@test isempty(Z3)
@test isa(Z3, DataValueArray{Any})

# test map over all null DataValueArray
n = rand(10:100)
Ys = [ DataValueArray(rand(Int, n), fill(true, n)) for i in 1:rand(3:5) ]

Z2 = map(h2, Ys[1])
@test isequal(Z2, DataValueArray{Int}(n))
@test isa(Z2, DataValueArray{Int})
Z2 = map(h2, Ys[1], Ys[2])
@test isequal(Z2, DataValueArray{Int}(n))
@test isa(Z2, DataValueArray{Int})
Z2 = map(h2, Ys...)
@test isequal(Z2, DataValueArray{Int}(n))
@test isa(Z2, DataValueArray{Int})

end
