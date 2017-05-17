@testset "DataVector" begin

using DataArrays2
using Base.Test

A = [1:10...]
B = [1:5...]

X = DataArray2(A)
Y = DataArray2(B)

#--- Base.push!

# Base.push!{T, V}(X::DataVector2{T}, v::V)
Z = DataVector2{Int}()
push!(Z, 5)
@test isequal(Z[1], DataValue(5))

# Base.push!{T, V}(X::DataVector2{T}, v::DataValue{V})
push!(Z, DataValue())
@test isequal(Z, DataArray2([5, 1], [false, true]))
push!(Z, DataValue(5))
@test isequal(Z, DataArray2([5, 1, 5], [false, true, false]))

ZZ = DataVector2{Int}()
push!(ZZ, 5, DataValue(), DataValue(5))
@test isequal(ZZ, Z)

#--- Base.pop!

# Base.pop!(X::DataArray2)
@test isequal(pop!(Z), DataValue(5))
@test isequal(pop!(Z), DataValue{Int}())
@test isequal(pop!(Z), DataValue(5))

#--- Base.unshift!

# Base.unshift!(X::DataVector2, v)
@test isequal(unshift!(X, 3), DataArray2(vcat(3, [1:10...])))

# Base.unshift!(X::DataVector2, v::DataValue)
@test isequal(unshift!(X, DataValue(2)),
                DataArray2(vcat([2, 3], [1:10...])))
@test isequal(unshift!(X, DataValue{Int}()),
                DataArray2(vcat([1, 2, 3], [1:10...]),
                            vcat(true, fill(false, 12))
                )
        )

@test isequal(unshift!(Y, 1, DataValue(), DataValue(3)),
                DataArray2([1, 2, 3, 1, 2, 3, 4, 5],
                            [false, true, false, false,
                            false, false, false, false]
                )
        )

#--- Base.shift!

# Base.shift!{T}(X::DataVector2{T})
Z = DataArray2([1:10...])

@test isequal(shift!(Z), DataValue(1))
@test isequal(Z, DataArray2([2:10...]))

unshift!(Z, DataValue{Int}())

@test isequal(shift!(Z), DataValue{Int}())

#--- test Base.splice!

# Base.splice!(X::DataVector2, i::Integer, ins=_default_splice)
A = [1:10...]
B = [1:10...]
X = DataArray2(B)

i = rand(1:10)
@test isequal(splice!(X, i), DataValue(splice!(A, i)))
@test isequal(X, DataArray2(A))

i = rand(1:9)
j = rand(1:9)
@test isequal(splice!(X, i, j), DataValue(splice!(A, i, j)))
@test isequal(X, DataArray2(A))

A = [1:10...]
B = [1:10...]
X = DataArray2(B)
i = rand(1:5)
n = rand(3:5)
@test isequal(splice!(X, i, [1:n...]), DataValue(splice!(A, i, [1:n...])))
@test isequal(X, DataArray2(A))

# Base.splice!{T<:Integer}(X::DataVector2,
#                          rng::UnitRange{T},
#                          ins=_default_splice)

# test with length(rng) > length(ins)
A = [1:20...]
B = [1:20...]
X = DataArray2(B)
f = rand(1:7)
d = rand(3:5)
l = f + d
ins = [1, 2]
@test isequal(splice!(X, f:l, ins),
                DataArray2(splice!(A, f:l, ins)))
@test isequal(X, DataArray2(A))

i = rand(1:length(X))
@test isequal(splice!(X, 1:i), DataArray2(splice!(A, 1:i)))

A = [1:20...]
B = [1:20...]
X = DataArray2(B)
f = rand(10:15)
d = rand(3:5)
l = f + d
ins = [1, 2]
@test isequal(splice!(X, f:l, ins),
                DataArray2(splice!(A, f:l, ins)))
@test isequal(X, DataArray2(A))

# test with length(rng) < length(ins)
A = [1:20...]
B = [1:20...]
X = DataArray2(B)
f = rand(1:7)
d = rand(3:5)
l = f + d
ins = [1, 2, 3, 4, 5, 6, 7]
@test isequal(splice!(X, f:l, ins),
                DataArray2(splice!(A, f:l, ins)))
@test isequal(X, DataArray2(A))

A = [1:20...]
B = [1:20...]
X = DataArray2(B)
f = rand(10:15)
d = rand(3:5)
l = f + d
ins = [1, 2, 3, 4, 5, 6, 7]
@test isequal(splice!(X, f:l, ins),
                DataArray2(splice!(A, f:l, ins)))
@test isequal(X, DataArray2(A))

#--- test Base.deleteat!

# Base.deleteat!(X::DataArray2, inds)
X = DataArray2(1:10)
@test isequal(deleteat!(X, 1), DataArray2(2:10))

#--- test Base.append!

# Base.append!(X::DataVector2, items::AbstractVector)
@test isequal(append!(X, [11, 12]),
                DataArray2(2:12))
@test isequal(append!(X, [DataValue(13), DataValue(14)]),
                DataArray2(2:14))
@test isequal(append!(X, [DataValue(15), DataValue{Int}()]),
                DataArray2(DataValue{Int}[2:15..., DataValue()]))

#--- test Base.prepend!

# Base.prepend!(X::DataVector2, items::AbstractVector)

X = DataArray2(3:12)
@test isequal(prepend!(X, [1, 2]),
                DataArray2(1:12))
@test isequal(prepend!(X, [DataValue(-1), DataValue(0)]),
                DataArray2(-1:12))
@test isequal(prepend!(X, [DataValue{Int}(), DataValue(-2)]),
                DataArray2(DataValue{Int}[DataValue(), -2:12...]))

#--- test Base.sizehint!

# Base.sizehint!(X::DataVector2, newsz::Integer)
sizehint!(X, 20)

#--- test padnull!

# padnull!{T}(X::DataVector2{T}, front::Integer, back::Integer)
X = DataArray2(1:5)
padnull!(X, 2, 3)
@test length(X.values) == 10
@test X.isnull == vcat(true, true, fill(false, 5), true, true, true)

# padnull(X::DataVector2, front::Integer, back::Integer)
X = DataArray2(1:5)
Y = padnull(X, 2, 3)
@test length(Y.values) == 10
@test Y.isnull == vcat(true, true, fill(false, 5), true, true, true)

#--- test Base.reverse!/Base.reverse

y = DataArray2([nothing, 2, 3, 4, nothing, 6], Int, Void)
@assert isequal(reverse(y),
                DataArray2([6, nothing, 4, 3, 2, nothing], Int, Void))

# check case where only nothing occurs in final position
@assert isequal(unique(DataArray2([1, 2, 1, nothing], Int, Void)),
                DataArray2([1, 2, nothing], Int, Void))

# Base.reverse!(X::DataVector2, s=1, n=length(X))
# check for case where isbits(eltype(X)) = false
Z = DataArray2(Array{Int, 1}[[1, 2], [3, 4], [5, 6]])
@test isequal(reverse!(Z),
                DataArray2(Array{Int, 1}[[5, 6], [3, 4], [1, 2]]))

# Base.reverse!(X::DataVector2, s=1, n=length(X))
# check for case where isbits(eltype(X)) = false & any(isnull, X) = true
A = fill([1,2], 20)
Z = DataArray2(Array{Int, 1}, 20)
i = rand(2:7)
for i in [i-1, i, i+1, 20 - (i + 2), 20 - (i - 1)]
    Z[i] = [1, 2]
end
vals = Z.values
nulls = Z.isnull
@test isequal(reverse!(Z), DataArray2(A, reverse!(Z.isnull)))

## empty!(X::DataVector2)
n = rand(1:1_000)
A, M = rand(n), rand(Bool, n)
X = DataArray2(A, M)
empty!(X)
@test isempty(X)

end
