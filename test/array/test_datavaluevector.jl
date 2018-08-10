using DataValues
using Test

@testset "DataValueArray: DataVector" begin

A = [1:10...]
B = [1:5...]

X = DataValueArray(A)
Y = DataValueArray(B)

#--- Base.push!

# Base.push!{T, V}(X::DataValueVector{T}, v::V)
Z = DataValueVector{Int}()
push!(Z, 5)
@test isequal(Z[1], DataValue(5))

# Base.push!{T, V}(X::DataValueVector{T}, v::DataValue{V})
push!(Z, DataValue())
@test isequal(Z, DataValueArray([5, 1], [false, true]))
push!(Z, DataValue(5))
@test isequal(Z, DataValueArray([5, 1, 5], [false, true, false]))

Z2 = copy(Z)
push!(Z2, DataValue{Int}())
@test isequal(Z2, DataValueArray([5, NA, 5, NA]))

ZZ = DataValueVector{Int}()
push!(ZZ, 5, DataValue(), DataValue(5))
@test isequal(ZZ, Z)

#--- Base.pop!

# Base.pop!(X::DataValueArray)
@test isequal(pop!(Z), DataValue(5))
@test isequal(pop!(Z), DataValue{Int}())
@test isequal(pop!(Z), DataValue(5))

#--- Base.pushfirst!

# Base.pushfirst!(X::DataValueVector, v)
@test isequal(pushfirst!(X, 3), DataValueArray(vcat(3, [1:10...])))

# Base.pushfirst!(X::DataValueVector, v::DataValue)
@test isequal(pushfirst!(X, DataValue(2)),
                DataValueArray(vcat([2, 3], [1:10...])))
@test isequal(pushfirst!(X, DataValue{Int}()),
                DataValueArray(vcat([1, 2, 3], [1:10...]),
                            vcat(true, fill(false, 12))
                )
        )

@test isequal(pushfirst!(Y, 1, DataValue(), DataValue(3)),
                DataValueArray([1, 2, 3, 1, 2, 3, 4, 5],
                            [false, true, false, false,
                            false, false, false, false]
                )
        )

#--- Base.popfirst!

# Base.popfirst!{T}(X::DataValueVector{T})
Z = DataValueArray([1:10...])

@test isequal(popfirst!(Z), DataValue(1))
@test isequal(Z, DataValueArray([2:10...]))

pushfirst!(Z, DataValue{Int}())

@test isequal(popfirst!(Z), DataValue{Int}())

#--- test Base.splice!

# Base.splice!(X::DataValueVector, i::Integer, ins=_default_splice)
A = [1:10...]
B = [1:10...]
X = DataValueArray(B)

i = rand(1:10)
@test isequal(splice!(X, i), DataValue(splice!(A, i)))
@test isequal(X, DataValueArray(A))

i = rand(1:9)
j = rand(1:9)
@test isequal(splice!(X, i, j), DataValue(splice!(A, i, j)))
@test isequal(X, DataValueArray(A))

A = [1:10...]
B = [1:10...]
X = DataValueArray(B)
i = rand(1:5)
n = rand(3:5)
@test isequal(splice!(X, i, [1:n...]), DataValue(splice!(A, i, [1:n...])))
@test isequal(X, DataValueArray(A))

# Base.splice!{T<:Integer}(X::DataValueVector,
#                          rng::UnitRange{T},
#                          ins=_default_splice)

# test with length(rng) > length(ins)
A = [1:20...]
B = [1:20...]
X = DataValueArray(B)
f = rand(1:7)
d = rand(3:5)
l = f + d
ins = [1, 2]
@test isequal(splice!(X, f:l, ins),
                DataValueArray(splice!(A, f:l, ins)))
@test isequal(X, DataValueArray(A))

i = rand(1:length(X))
@test isequal(splice!(X, 1:i), DataValueArray(splice!(A, 1:i)))

A = [1:20...]
B = [1:20...]
X = DataValueArray(B)
f = rand(10:15)
d = rand(3:5)
l = f + d
ins = [1, 2]
@test isequal(splice!(X, f:l, ins),
                DataValueArray(splice!(A, f:l, ins)))
@test isequal(X, DataValueArray(A))

# test with length(rng) < length(ins)
A = [1:20...]
B = [1:20...]
X = DataValueArray(B)
f = rand(1:7)
d = rand(3:5)
l = f + d
ins = [1, 2, 3, 4, 5, 6, 7]
@test isequal(splice!(X, f:l, ins),
                DataValueArray(splice!(A, f:l, ins)))
@test isequal(X, DataValueArray(A))

A = [1:20...]
B = [1:20...]
X = DataValueArray(B)
f = rand(10:15)
d = rand(3:5)
l = f + d
ins = [1, 2, 3, 4, 5, 6, 7]
@test isequal(splice!(X, f:l, ins),
                DataValueArray(splice!(A, f:l, ins)))
@test isequal(X, DataValueArray(A))

#--- test Base.deleteat!

# Base.deleteat!(X::DataValueArray, inds)
X = DataValueArray(1:10)
@test isequal(deleteat!(X, 1), DataValueArray(2:10))

#--- test Base.append!

# Base.append!(X::DataValueVector, items::AbstractVector)
@test isequal(append!(X, [11, 12]),
                DataValueArray(2:12))
@test isequal(append!(X, [DataValue(13), DataValue(14)]),
                DataValueArray(2:14))
@test isequal(append!(X, [DataValue(15), DataValue{Int}()]),
                DataValueArray(DataValue{Int}[2:15..., DataValue()]))

#--- test Base.prepend!

# Base.prepend!(X::DataValueVector, items::AbstractVector)

X = DataValueArray(3:12)
@test isequal(prepend!(X, [1, 2]),
                DataValueArray(1:12))
@test isequal(prepend!(X, [DataValue(-1), DataValue(0)]),
                DataValueArray(-1:12))
@test isequal(prepend!(X, [DataValue{Int}(), DataValue(-2)]),
                DataValueArray(DataValue{Int}[DataValue(), -2:12...]))

X2 = DataValueArray([1,NA,4])
prepend!(X2, X2)
@test isequal(X2, DataValueArray([1,NA,4,1,NA,4]))

#--- test Base.sizehint!

# Base.sizehint!(X::DataValueVector, newsz::Integer)
sizehint!(X, 20)

#--- test padna!

# padna!{T}(X::DataValueVector{T}, front::Integer, back::Integer)
X = DataValueArray(1:5)
padna!(X, 2, 3)
@test length(X.values) == 10
@test X.isna == vcat(true, true, fill(false, 5), true, true, true)

# padna(X::DataValueVector, front::Integer, back::Integer)
X = DataValueArray(1:5)
Y = padna(X, 2, 3)
@test length(Y.values) == 10
@test Y.isna == vcat(true, true, fill(false, 5), true, true, true)

#--- test Base.reverse!/Base.reverse

y = DataValueArray([NA, 2, 3, 4, NA, 6])
@assert isequal(reverse(y),
                DataValueArray([6, NA, 4, 3, 2, NA]))

# check case where only nothing occurs in final position
@assert isequal(unique(DataValueArray([1, 2, 1, NA])),
                DataValueArray([1, 2, NA]))

# Base.reverse!(X::DataValueVector, s=1, n=length(X))
# check for case where isbitstype(eltype(X)) = false
Z = DataValueArray(Array{Int, 1}[[1, 2], [3, 4], [5, 6]])
@test isequal(reverse!(Z),
                DataValueArray(Array{Int, 1}[[5, 6], [3, 4], [1, 2]]))

# Base.reverse!(X::DataValueVector, s=1, n=length(X))
# check for case where isbitstype(eltype(X)) = false & any(isna, X) = true
A = fill([1,2], 20)
Z = DataValueArray{Array{Int, 1}}(20)
i = rand(2:7)
for i in [i-1, i, i+1, 20 - (i + 2), 20 - (i - 1)]
    Z[i] = [1, 2]
end
vals = Z.values
nulls = Z.isna
@test isequal(reverse!(Z), DataValueArray(A, reverse!(Z.isna)))

## empty!(X::DataValueVector)
n = rand(1:1_000)
A, M = rand(n), rand(Bool, n)
X = DataValueArray(A, M)
empty!(X)
@test isempty(X)

end
