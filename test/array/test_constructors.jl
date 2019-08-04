using Test
using DataValues

@testset "DataValueArray: Constructor" begin

# test Inner Constructor
@test_throws ArgumentError DataValueArray([1, 2, 3, 4], [true, false, true])

# test (A::AbstractArray, m::Array{Bool}) constructor
v = [1, 2, 3, 4]
dv = DataValueArray(v, fill(false, size(v)))

m = [1 2; 3 4]
dm = DataValueArray(m, fill(false, size(m)))

t = Array{Int}(undef, 2, 2, 2)
t[1:2, 1:2, 1:2] .= 1

dt = DataValueArray(t, fill(false, size(t)))
dv = DataValueArray(v, [false, false, false, false])

y2 = DataValueArray([1, 2, 3, 4, 5, 6],
                    [true, false, false, false, false ,false])
@test isa(y2, DataValueVector{Int})
@test y2.isna[1]

# test (::AbstractArray) constructor
dv = DataValueArray(v)
@test isa(dv, DataValueVector{Int})

y = DataValueArray([1, 2, 3, 4, 5, 6])
@test isa(y, DataValueVector{Int})

z = DataValueArray(1.:6.)
@test isa(z, DataValueVector{Float64})

# test (::Type{T}, dims::Dims) constructor
u1 = DataValueArray{Int}((5, ))
u2 = DataValueArray{Int}((2, 2))
u3 = DataValueArray{Int}((2, 2, 2))
@test isa(u1, DataValueVector{Int})
@test isa(u2, DataValueMatrix{Int})
@test isa(u3, DataValueArray{Int, 3})

# test (::Type{T}, dims::Int...) constructor
x1 = DataValueArray{Int}(2)
x2 = DataValueArray{Int}(2, 2)
x3 = DataValueArray{Int}(2, 2, 2)
@test isa(x1, DataValueVector{Int})
@test isa(x2, DataValueMatrix{Int})
@test isa(x3, DataValueArray{Int, 3})

# test DataValueArray{T}(dims::Dims)
d1, d2 = rand(1:100), rand(1:100)
X1 = DataValueArray{Int}((d1,))
X2 = DataValueArray{Int}((d1, d2))
X3 = DataValueArray{Int}(undef, (d1, d2))
@test isequal(X1, DataValueArray(Array{Int}(undef, d1), fill(true, (d1,))))
@test isequal(X2, DataValueArray(Array{Int}(undef, d1, d2), fill(true, (d1, d2))))
@test isequal(X2, X3)
for i in 1:5
    m = rand(3:5)
    dims = tuple([ rand(1:5) for i in 1:m ]...)
    X3 = DataValueArray{Int}(dims)
    @test isequal(X3, DataValueArray(Array{Int}(undef, dims), fill(true, dims)))
end

# test DataValueArray{T,N}(dims::Dims)
d1, d2 = rand(1:100), rand(1:100)
X1 = DataValueArray{Int,1}((d1,))
X2 = DataValueArray{Int,2}((d1, d2))
X3 = DataValueArray{Int, 2}(undef, (d1, d2))
@test isequal(X1, DataValueArray(Array{Int}(undef, d1), fill(true, (d1,))))
@test isequal(X2, DataValueArray(Array{Int}(undef, d1, d2), fill(true, (d1, d2))))
@test isequal(X2, X3)
for i in 1:5
    m = rand(3:5)
    dims = tuple([ rand(1:5) for i in 1:m ]...)
    X3 = DataValueArray{Int,m}(dims)
    @test isequal(X3, DataValueArray(Array{Int}(undef, dims), fill(true, dims)))
end

# test DataValueArray{T}(dims::Int...)
d1, d2 = rand(1:100), rand(1:100)
X1 = DataValueArray{Int}(d1)
X2 = DataValueArray{Int}(d1, d2)
X3 = DataValueArray{Int}(undef, d1, d2)
@test isequal(X1, DataValueArray(Array{Int}(undef, d1), fill(true, d1)))
@test isequal(X2, DataValueArray(Array{Int}(undef, d1, d2), fill(true, d1, d2)))
@test isequal(X2, X3)
for i in 1:5
    m = rand(3:5)
    dims = [ rand(1:5) for i in 1:m ]
    X3 = DataValueArray{Int}(dims...)
    @test isequal(X3, DataValueArray(Array{Int}(undef, dims...), fill(true, dims...)))
end

# test DataValueArray{T}(dims::Int...)
d1, d2 = rand(1:100), rand(1:100)
X1 = DataValueArray{Int,1}(d1)
X2 = DataValueArray{Int,2}(d1, d2)
X3 = DataValueArray{Int,2}(undef, d1, d2)
@test isequal(X1, DataValueArray(Array{Int,1}(undef, d1), fill(true, d1)))
@test isequal(X2, DataValueArray(Array{Int,2}(undef, d1, d2), fill(true, d1, d2)))
@test isequal(X2, X3)
for i in 1:5
    m = rand(3:5)
    dims = [ rand(1:5) for i in 1:m ]
    X3 = DataValueArray{Int,length(dims)}(dims...)
    @test isequal(X3, DataValueArray(Array{Int}(undef, dims...), fill(true, dims...)))
end

# test (A::AbstractArray{DataValue}) constructor
z = DataValueArray([1, NA, 2, NA, 3])
@test isa(z, DataValueVector{Int})
@test z.isna[2]
@test z.isna[4]

# test DataValueArray{T}()
X = DataValueArray{Int}()
@test isequal(size(X), ())

# test conversion from arrays, arrays of DataValues and DataValueArrays
miss1 = [false,false,false,false]
miss2 = [false,false,false,true]
for (a, miss) in zip(([1, 2, 3, 4],
                        # 1:4, # Currently does not work on 0.4, cf. JuliaLang/julia#16265
                        DataValue{Int}[DataValue(1), DataValue(2), DataValue(3), DataValue()],
                        DataValueArray(DataValue{Int}[DataValue(1), DataValue(2), DataValue(3), DataValue()])),
                        (miss1, miss2, miss2))
    @test isa(DataValueArray(a), DataValueArray{Int,1})
    @test isequal(DataValueArray(a), DataValueArray{Int,1}([1,2,3,4],miss))
    @test isa(DataValueArray{Int}(a), DataValueArray{Int,1})
    @test isequal(DataValueArray{Int}(a), DataValueArray{Int,1}([1,2,3,4],miss))
    @test isa(DataValueArray{Float64}(a), DataValueArray{Float64,1})
    @test isequal(DataValueArray{Float64}(a), DataValueArray{Float64,1}([1.0,2.0,3.0,4.0],miss))
    @test isa(DataValueArray{Int,1}(a), DataValueArray{Int,1})
    @test isequal(DataValueArray{Int,1}(a), DataValueArray{Int,1}([1,2,3,4],miss))
    @test isa(DataValueArray{Float64,1}(a), DataValueArray{Float64,1})
    @test isequal(DataValueArray{Float64,1}(a), DataValueArray{Float64,1}([1.0,2.0,3.0,4.0],miss))

    @test isa(convert(DataValueArray, a), DataValueArray{Int,1})
    @test isequal(convert(DataValueArray, a), DataValueArray{Int,1}([1,2,3,4],miss))
    @test isa(convert(DataValueArray{Int}, a), DataValueArray{Int,1})
    @test isequal(convert(DataValueArray{Int}, a), DataValueArray{Int,1}([1,2,3,4],miss))
    @test isa(convert(DataValueArray{Float64}, a), DataValueArray{Float64,1})
    @test isequal(convert(DataValueArray{Float64}, a), DataValueArray{Float64,1}([1.0,2.0,3.0,4.0],miss))
    @test isa(convert(DataValueArray{Int,1}, a), DataValueArray{Int,1})
    @test isequal(convert(DataValueArray{Int,1}, a), DataValueArray{Int,1}([1,2,3,4],miss))
    @test isa(convert(DataValueArray{Float64,1}, a), DataValueArray{Float64,1})
    @test isequal(convert(DataValueArray{Float64,1}, a), DataValueArray{Float64,1}([1.0,2.0,3.0,4.0],miss))
end

# test conversion from Array{DataValue} without element type (issue #145)
@test isa(DataValueArray(DataValue[DataValue(1), DataValue(2), DataValue(3), DataValue()]), DataValueArray{Any})
@test isa(DataValueArray{Int}(DataValue[DataValue(1), DataValue(2), DataValue(3), DataValue()]), DataValueArray{Int})
@test isa(DataValueArray{Float64}(DataValue[DataValue(1), DataValue(2), DataValue(3), DataValue()]), DataValueArray{Float64})

@test isa(convert(DataValueArray, DataValue[DataValue(1), DataValue(2), DataValue(3), DataValue()]), DataValueArray{Any})
@test isa(convert(DataValueArray{Int}, DataValue[DataValue(1), DataValue(2), DataValue(3), DataValue()]), DataValueArray{Int})
@test isa(convert(DataValueArray{Float64}, DataValue[DataValue(1), DataValue(2), DataValue(3), DataValue()]), DataValueArray{Float64})

# test conversion from Any array
@test convert(DataValueArray{Float64}, Any[1., 2., 3.]) isa DataValueVector{Float64}
@test convert(DataValueArray{Float64}, Any[1., NA, 3.]) isa DataValueVector{Float64}
@test convert(DataValueArray{Float64}, Any[DataValue(1.), DataValue{Float64}(), 3.]) isa DataValueVector{Float64}

# converting a DataValueArray to unqualified type DataValueArray should be no-op
m = rand(10:100)
A = rand(m)
M = rand(Bool, m)
X = DataValueArray(A, M)
@test X === convert(DataValueArray, X)

end
