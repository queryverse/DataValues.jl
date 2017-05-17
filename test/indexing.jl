@testset "Indexing" begin

using Base.Test
using DataValueArrays
import DataValueArrays: unsafe_getindex_notnull,
                        unsafe_getvalue_notnull

x = DataValueArray(Int, (5, 2))

for i in eachindex(x)
    x[i] = i
end

for i in eachindex(x)
    y = x[i]
    @test isa(y, DataValue{Int})
    @test get(y) === i
end

for i in eachindex(x)
    x[i] = DataValue{Int}()
end

for i in eachindex(x)
    y = x[i]
    @test isa(y, DataValue{Int})
    @test isnull(y)
end

_values = rand(10, 10)
_isnull = rand(Bool, 10, 10)
X = DataValueArray(_values, _isnull)

# Base.getindex{T, N}(X::DataValueArray{T, N})
@test isequal(getindex(X), X[1])

# Base.getindex{T, N}(X::DataValueArray{T, N}, I::DataValue{Int}...)
@test_throws NullException getindex(X, DataValue{Int}(), DataValue{Int}())
if _isnull[1]
    @test isnull(getindex(X, DataValue(1)))
else
    @test isequal(getindex(X, DataValue(1)), DataValue(_values[1]))
end

# Scalar getindex
for i = 1:100
    if _isnull[i]
        @test isnull(X[i])
    else
        @test isequal(X[i], DataValue(_values[i]))
    end
end
for i = 1:10, j = 1:10
    if _isnull[i, j]
        @test isnull(X[i, j])
    else
        @test isequal(X[i, j], DataValue(_values[i, j]))
    end
end

# getindex with AbstractVectors
rg = 2:9
v = X[rg]
for i = 1:length(rg)
    if _isnull[rg[i]]
        @test isnull(v[i])
    else
        @test isequal(v[i], DataValue(_values[rg[i]]))
    end
end

v = X[rg, 9]
for i = 1:length(rg)
    if _isnull[rg[i], 9]
        @test isnull(v[i])
    else
        @test isequal(v[i], DataValue(_values[rg[i], 9]))
    end
end

rg2 = 5:7
v = X[rg, rg2]
for j = 1:length(rg2), i = 1:length(rg)
    if _isnull[rg[i], rg2[j]]
        @test isnull(v[i, j])
    else
        @test isequal(v[i, j], DataValue(_values[rg[i], rg2[j]]))
    end
end

# range indexing
Z_values = reshape(collect(1:125), (5,5,5))
Z = DataValueArray(Z_values)

if VERSION > v"0.5.0-dev+1195" # PR #13612 in JuliaLang
    @test isequal(Z[1, 1:4, 1], DataValueArray([1, 6, 11, 16]))
else
    @test isequal(Z[1, 1:4, 1], DataValueArray([1 6 11 16]))
end

# getindex with AbstractVector{Bool}
b = bitrand(10, 10)
rg = find(b)
v = X[b]
for i = 1:length(rg)
    if _isnull[rg[i]]
        @test isnull(v[i])
    else
        @test isequal(v[i], DataValue(_values[rg[i]]))
    end
end

# getindex with DataValueVector with null entries throws error
@test_throws NullException X[DataValueArray([1, 2, 3, nothing], Int, Void)]

# getindex with DataValueVector and non-null entries
@test isequal(X[DataValueArray([1, 2, 3])], X[[1, 2, 3]])

# indexing with DataValues

n = rand(1:5)
siz = [ rand(2:5) for i in n ]
A = rand(siz...)
M = rand(Bool, siz...)
Z = DataValueArray(A, M)
i = rand(1:length(Z))
@test isequal(Z[DataValue(i)], Z[i])
I = [ rand(1:size(Z,i)) for i in 1:n ]
NI = [ DataValue(i) for i in I ]
@test isequal(Z[NI...], Z[I...])

#----- test setindex! -----#

# setindex! with scalar indices
_values = rand(10, 10)
for i = 1:100
    X[i] = _values[i]
end
@test isequal(X, DataValueArray(_values))

_values = rand(10, 10)
for i = 1:10, j = 1:10
    X[i, j] = _values[i, j]
end
@test isequal(X, DataValueArray(_values))

_values = rand(10, 10)
for i = 1:10, j = 1:10
    X[i, j] = DataValue(_values[i, j])
end
@test isequal(X, DataValueArray(_values))


# ----- test nullify! -----#
_isnull = bitrand(10, 10)
for i = 1:100
    _isnull[i] && (nullify!(X, i))
end

# setindex! with scalar and vector indices
rg = 2:9
_values[rg] = 1.0
X[rg] = 1.0
for i = 1:length(rg)
    @test isequal(X[rg[i]], DataValue(1.0))
end

# setindex! with NA and vector indices
rg = 5:13
_isnull[rg] = true
nullify!(X, rg)
for i = 1:length(rg)
    @test isnull(X[rg[i]])
end

# setindex! with vector and vector indices
rg = 12:67
_values[rg] = rand(length(rg))
X[rg] = _values[rg]
for i = 1:length(rg)
    @test isequal(X[rg[i]], DataValue(_values[rg[i]]))
end

#----- test UNSAFE INDEXING -----#

X = DataValueArray([1, 2, 3, 4, 5], [true, false, false, false, false])

@test isequal(unsafe_getindex_notnull(X, 1), DataValue(1))
@test isequal(unsafe_getindex_notnull(X, 2), DataValue(2))
@test isequal(unsafe_getvalue_notnull(X, 1), 1)
@test isequal(unsafe_getvalue_notnull(X, 2), 2)

#----- test Base.checkbounds -----#

X = DataValueArray([1:10...])
b = vcat(false, fill(true, 9))

if VERSION >= v"0.5.0-dev+4697"
    # Base.checkindex(::Type{Bool}, inds::UnitRange, i::DataValue)
    @test_throws NullException checkindex(Bool, 1:1, DataValue{Int}())
    @test checkindex(Bool, 1:10, DataValue(1)) == true
    @test isequal(X[DataValue(1)], DataValue(1))

    # Base.checkindex{N}(::Type{Bool}, inds::UnitRange, I::DataValueArray{Bool, N})
    @test checkindex(Bool, 1:5, DataValueArray([true, false, true, false, true]))
    @test isequal(X[b], DataValueArray([2:10...]))

    # Base.checkindex{T<:Real}(::Type{Bool}, inds::UnitRange, I::DataValueArray{T})
    @test checkindex(Bool, 1:10, DataValueArray([1:10...]))
    @test checkindex(Bool, 1:10, DataValueArray([10, 11])) == false
    @test_throws BoundsError checkbounds(X, DataValueArray([10, 11]))
else
    # Base.checkbounds{T<:Real}(::Type{Bool}, sz::Int, x::DataValue{T})
    @test_throws NullException checkbounds(Bool, 1, DataValue(1, true))
    @test checkbounds(Bool, 10, DataValue(1)) == true
    @test isequal(X[DataValue(1)], DataValue(1))

    # Base.checkbounds(::Type{Bool}, sz::Int, X::DataValueVector{Bool})
    @test checkbounds(Bool, 5, DataValueArray([true, false, true, false, true]))
    @test isequal(X[b], DataValueArray([2:10...]))

    # Base.checkbounds{T<:Real}(::Type{Bool}, sz::Int, I::DataValueArray{T})
    @test checkbounds(Bool, 10, DataValueArray([1:10...]))
    @test checkbounds(Bool, 10, DataValueArray([10, 11])) == false
    @test_throws BoundsError checkbounds(X, DataValueArray([10, 11]))
end

#---- test Base.to_index -----#

# Base.to_index(X::DataValueArray)
@test Base.to_index(X) == [1:10...]
push!(X, DataValue{Int}())
@test_throws NullException Base.to_index(X)

end
