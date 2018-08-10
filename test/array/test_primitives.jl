using Test
using DataValues

@testset "DataValueArray: Primitives" begin

n = rand(1:5)
siz = [ rand(2:5) for i in n ]
A = rand(siz...)
M = rand(Bool, siz...)
X = DataValueArray(A, M)
i = rand(1:length(X))
@test values(X, i) == X.values[i]
@test isna(X, i) == X.isna[i]
I = [ rand(1:size(X,i)) for i in 1:n ]
@test values(X, I...) == X.values[I...]
@test isna(X, I...) == X.isna[I...]

# ----- test Base.similar, Base.size  ----------------------------------------#

x = DataValueArray{Int}((5, 2))
@test isa(x, DataValueMatrix{Int})
@test size(x) === (5, 2)

y = similar(x, DataValue{Int}, (3, 3))
@test isa(y, DataValueMatrix{Int})
@test size(y) === (3, 3)

z = similar(x, DataValue{Int}, (2,))
@test isa(z, DataValueVector{Int})
@test size(z) === (2, )

# test common use-patterns for 'similar'
dv = DataValueArray{Int}(2)
dm = DataValueArray{Int}(2, 2)
dt = DataValueArray{Int}(2, 2, 2)

similar(dv)
similar(dm)
similar(dt)

similar(dv, 2)
similar(dm, 2, 2)
similar(dt, 2, 2, 2)

# ----- test Base.copy/Base.copy! --------------------------------------------#

#copy
x = DataValueArray([1, 2, NA])
y = DataValueArray([3, NA, 5])
@test isequal(copy(x), x)
@test isequal(copyto!(y, x), x)


# copy!
function nonbits(dv)
    ret = similar(dv, DataValue{Integer})
    for ii = 1:length(dv)
        if !dv.isna[ii]
            ret[ii] = dv[ii]
        end
    end
    ret
end
set1 = Any[DataValueArray([1, NA, 3]),
            DataValueArray([NA, 5]),
            DataValueArray([1, 2, 3, 4, 5]),
            DataValueArray(Int[]),
            DataValueArray([NA, 5, 3]),
            DataValueArray([1, 5, 3])]
set2 = map(nonbits, set1)

for (dest, src, bigsrc, emptysrc, res1, res2) in Any[set1, set2]
    @test isequal(copyto!(copy(dest), src), res1)
    @test isequal(copyto!(copy(dest), 1, src), res1)

    @test isequal(copyto!(copy(dest), 2, src, 2), res2)
    @test isequal(copyto!(copy(dest), 2, src, 2, 1), res2)

    @test isequal(copyto!(copy(dest), 99, src, 99, 0), dest)

    @test isequal(copyto!(copy(dest), 1, emptysrc), dest)
    @test_throws BoundsError copyto!(dest, 1, emptysrc, 1)

    for idx in [0, 4]
        @test_throws BoundsError copyto!(dest, idx, src)
        @test_throws BoundsError copyto!(dest, idx, src, 1)
        @test_throws BoundsError copyto!(dest, idx, src, 1, 1)
        @test_throws BoundsError copyto!(dest, 1, src, idx)
        @test_throws BoundsError copyto!(dest, 1, src, idx, 1)
    end

    @test_throws ArgumentError copyto!(dest, 1, src, 1, -1)

    @test_throws BoundsError copyto!(dest, bigsrc)

    @test_throws BoundsError copyto!(dest, 3, src)
    @test_throws BoundsError copyto!(dest, 3, src, 1)
    @test_throws BoundsError copyto!(dest, 3, src, 1, 2)
    @test_throws BoundsError copyto!(dest, 1, src, 2, 2)
end

# ----- test Base.fill! ------------------------------------------------------#

X = DataValueArray{Int}(10, 2)
fill!(X, DataValue(10))
Y = DataValueArray{Float64}(10)
fill!(Y, rand(Float64))

@test X.values == fill(10, 10, 2)
@test isequal(X.isna, fill(false, 10, 2))
@test isequal(Y.isna, fill(false, 10))

fill!(X, DataValue())
@test isequal(X.isna, fill(true, 10, 2))

# ----- test Base.deepcopy ---------------------------------------------------#

Y1 = deepcopy(Y)
@test isequal(Y1, Y)
@assert !(Y === Y1)

# ----- test Base.resize! ----------------------------------------------------#

resize!(Y1, 20)
@test Y1.values[1:10] == Y.values[1:10]
@test Y1.isna[1:10] == Y.isna[1:10]
@test Y1.isna[11:20] == fill(true, 10)

resize!(Y1, 5)
@test Y1.values[1:5] == Y.values[1:5]
@test Y1.isna[1:5] == Y.isna[1:5]

# ----- test Base.reshape ----------------------------------------------------#

Y1 = reshape(copy(Y), length(Y), 1)
@test size(Y1) == (length(Y), 1)
@test all(i->isequal(Y1[i], Y[i]), 1:length(Y))
Y2 = reshape(Y1, 1, length(Y1))
@test size(Y2) == (1, length(Y1))
@test all(i->isequal(Y1[i], Y2[i]), 1:length(Y2))
# Test that arrays share the same data
Y2.values[1] += 1
Y2.isna[2] = true
@test all(i->isequal(Y1[i], Y2[i]), 1:length(Y2))

# ----- test Base.ndims ------------------------------------------------------#

for n in 1:4
    @test ndims(DataValueArray{Int}(collect(1:n)...)) == n
end

# ----- test Base.length -----------------------------------------------------#

@test length(DataValueArray{Int}(10)) == 10
@test length(DataValueArray{Int}(5, 5)) == 25
@test length(DataValueArray{Int}((3, 3, 3))) == 27

# ----- test Base.lastindex ------------------------------------------------------#

@test lastindex(DataValueArray(collect(1:10))) == 10
@test lastindex(DataValueArray([1, 2, nothing, 4, nothing])) == 5

# ----- test Base.find -------------------------------------------------------#

z = DataValueArray(rand(Bool, 10))
@test (LinearIndices(z))[findall(x->x!=0,z)] == (LinearIndices(z.values))[findall(z.values)]

z = DataValueArray([false, true, false, true, false, true])
@test isequal((LinearIndices(z))[findall(x->x!=0,z)], [2, 4, 6])

# ----- test dropna --------------------------------------------------------#

# dropna(X::DataValueVector)
z = DataValueArray([1, 2, 3, NA, 5, NA, 7, NA])
@test dropna(z) == [1, 2, 3, 5, 7]

# dropna(X::AbstractVector)
A = Any[1, 2, 3, DataValue(), 5, DataValue(), 7, DataValue()]
@test dropna(A) == [1, 2, 3, 5, 7]

# dropna(X::AbstractVector{<:DataValue})
B = [1, 2, 3, DataValue(), 5, DataValue(), 7, DataValue()]
@test dropna(B) == [1, 2, 3, 5, 7]
# assert dropna returns copy for !(DataValue <: eltype(X))
nullfree = [1, 2, 3, 4]
returned_copy = dropna(nullfree)
@test nullfree == returned_copy && !(nullfree === returned_copy)

# ----- test dropna! -------------------------------------------------------#

# for each, assert returned values are unwrapped and inplace change
# dropna!(X::DataValueVector)
@test dropna!(z) == [1, 2, 3, 5, 7]
@test isequal(z, DataValueArray([1, 2, 3, 5, 7]))

# dropna!(X::AbstractVector)
@test dropna!(A) == [1, 2, 3, 5, 7]
@test isequal(A, Any[1, 2, 3, 5, 7])

# dropna!(X::AbstractVector{<:DataValue})
@test dropna!(B) == [1, 2, 3, 5, 7]
@test isequal(B, DataValue[1, 2, 3, 5, 7])

# when no nulls present, dropna! returns input vector
returned_view = dropna!(nullfree)
@test nullfree == returned_view && nullfree === returned_view

# test that dropna! returns unwrapped values when DataValues are present
X = [false, 1, :c, "string", DataValue("I am not null"), DataValue()]
@test !any(x -> isa(x, DataValue), dropna!(X))
@test any(x -> isa(x, DataValue), X)
Y = Any[false, 1, :c, "string", DataValue("I am not null"), DataValue()]
@test !any(x -> isa(x, DataValue), dropna!(Y))
@test any(x -> isa(x, DataValue), Y)

# ----- test any(isna, X) --------------------------------------------------#

# any(isna, X::DataValueArray)
z = DataValueArray([1, 2, 3, NA, 5, NA, 7, NA])
@test any(isna, z) == true
@test any(isna, dropna(z)) == false
z = DataValueArray{Int}(10)
@test any(isna, z) == true

# any(isna, A::AbstractArray)
A2 = [DataValue(1), DataValue(2), DataValue(3)]
@test any(isna, A2) == false
push!(A2, DataValue{Int}())
@test any(isna, A2) == true

# any(isna, xs::NTuple)
@test any(isna, (DataValue(1), DataValue(2))) == false
@test any(isna, (DataValue{Int}(), DataValue(1), 3, 6)) == true

# any(isna, S::SubArray{T, N, U<:DataValueArray})
A = rand(10, 3, 3)
M = rand(Bool, 10, 3, 3)
X = DataValueArray(A, M)
i, j = rand(1:3), rand(1:3)
S = view(X, :, i, j)

@test any(isna, S) == any(isna, X[:, i, j])
X = DataValueArray(A)
S = view(X, :, i, j)
@test any(isna, S) == false


# ----- test all(isna, X) --------------------------------------------------#

# all(isna, X::DataValueArray)
z = DataValueArray{Int}(10)
@test all(isna, z) == true
z[1] = 10
@test all(isna, z) == false

# all(isna, X::AbstractArray{<:DataValue})
@test all(isna, DataValue{Int}[DataValue(), DataValue()]) == true
@test all(isna, DataValue{Int}[DataValue(1), DataValue()]) == false

# all(isna, X::Any)
@test all(isna, Any[DataValue(), DataValue()]) == true
@test all(isna, [1, 2]) == false
@test all(isna, 1:3) == false

# ----- test Base.isnan ------------------------------------------------------#

x = DataValueArray([1, 2, NaN, 4, 5, NaN, Inf, NA])
_x = map(isnan, x)
@test isequal(_x, [false, false, true, false,
                                false, true, false, false])

# ----- test Base.isfinite ---------------------------------------------------#

_x = map(isfinite, x)
@test isequal(_x, [true, true, false, true,
                                true, false, false, false])

# ----- test conversion methods ----------------------------------------------#

u = DataValueArray(collect(1:10))
v = DataValueArray{Int}(4, 4)
fill!(v, 4)
w = DataValueArray(['a', 'b', 'c', 'd', 'e', 'f', NA])
x = DataValueArray([(i, j, k) for i in 1:10, j in 1:10, k in 1:10])
y = DataValueArray([2, 4, 6, 8, 10])
z = DataValueArray([i*j for i in 1:10, j in 1:10])
_z = DataValueArray(reshape(collect(1:100), 10, 10),
                    convert(Array{Bool},
                            reshape([mod(j, 2) for i in 1:10, j in 1:10],
                                    (10, 10))))
_x = DataValueArray([false, true, false, NA, false, true, NA])
a = [i*j*k for i in 1:2, j in 1:2, k in 1:2]
b = collect(1:10)
c = [i for i in 1:10, j in 1:10]

e = convert(DataValueArray, a)
f = convert(DataValueArray{Float64}, b)
g = convert(DataValueArray, c)
h = convert(DataValueArray{Float64}, g)

@test_throws DataValueException convert(Array{Char, 1}, w)
@test convert(Array{Char, 1},
                DataValueArray(dropna(w))) == ['a', 'b', 'c', 'd', 'e', 'f']
@test_throws DataValueException convert(Array{Char}, w)
@test convert(Array{Float64}, u) == Float64[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
@test convert(Vector{Float64}, y) == Float64[2, 4, 6, 8, 10]
@test convert(Matrix{Float64}, z) == Float64[i*j for i in 1:10, j in 1:10]
@test_throws DataValueException convert(Array, w)
@test convert(Array, v) == [4 4 4 4; 4 4 4 4; 4 4 4 4; 4 4 4 4]
@test convert(Array, z) == [i*j for i in 1:10, j in 1:10]
@test convert(Array, u) == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
@test convert(Array, _x, false) == [false, true, false, false,
                                    false, true, false]
@test convert(Array{Int, 1}, _x, 0) == [0, 1, 0, 0, 0, 1, 0]
@test convert(Vector, _x, false) == [false, true, false, false,
                                    false, true, false]
@test sum(convert(Matrix, _z, 0)) == 2775
@test isequal(e[:, :, 1], DataValueArray([1 2; 2 4]))
@test isequal(f, DataValueArray(Float64[i for i in 1:10]))
@test isa(g, DataValueArray{Int, 2})
@test isa(h, DataValueArray{Float64, 2})

# Base.convert{T}(::Type{Vector}, X::DataValueVector{T})
X = DataValueArray([1, 2, 3, 4, 5])
@test convert(Vector, X) == [1, 2, 3, 4, 5]
push!(X, DataValue())
@test_throws DataValueException convert(Vector, X)

# Base.convert{T}(::Type{Matrix}, X::DataValueMatrix{T})
Y = DataValueArray([1 2; 3 4; 5 6; 7 8; 9 10])
@test convert(Matrix, Y) == [1 2; 3 4; 5 6; 7 8; 9 10]
Z = DataValueArray([1 2; 3 4; 5 6; 7 8; 9 NA])
@test_throws DataValueException convert(Matrix, Z)

# float(X::DataValueArray)
A = rand(Int, 20)
M = rand(Bool, 20)
X = DataValueArray(A, M)
@test isequal(map(float, X), DataValueArray(float(A), M))

# ----- test Base.hash (julia/base/hashing.jl:5) -----------------------------#

# Omitted for now, pending investigation into DataValueArray-specific
# method.
# TODO: reinstate testing once decision whether or not to implement
# DataValueArray-specific hash method is reached.

# ----- test unique (julia/base/set.jl:107) ----------------------------------#

x = DataValueArray([1, NA, -2, 1, NA, 4])
@assert isequal(unique(x), DataValueArray([1, NA, -2, 4]))
@assert isequal(unique(reverse(x)),
                DataValueArray([4, NA, 1, -2]))



end
