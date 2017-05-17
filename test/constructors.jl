@testset "Constructor" begin

using Base.Test
using DataArrays2

# test Inner Constructor
@test_throws ArgumentError DataArray2([1, 2, 3, 4], [true, false, true])

# test (A::AbstractArray, m::Array{Bool}) constructor
v = [1, 2, 3, 4]
dv = DataArray2(v, fill(false, size(v)))

m = [1 2; 3 4]
dm = DataArray2(m, fill(false, size(m)))

t = Array{Int}(2, 2, 2)
t[1:2, 1:2, 1:2] = 1

dt = DataArray2(t, fill(false, size(t)))
dv = DataArray2(v, [false, false, false, false])

y2 = DataArray2([1, 2, 3, 4, 5, 6],
                    [true, false, false, false, false ,false])
@test isa(y2, DataVector2{Int})
@test y2.isnull[1]

# test (::AbstractArray) constructor
dv = DataArray2(v)
@test isa(dv, DataVector2{Int})

y = DataArray2([1, 2, 3, 4, 5, 6])
@test isa(y, DataVector2{Int})

z = DataArray2(1.:6.)
@test isa(z, DataVector2{Float64})

# test (::Type{T}, dims::Dims) constructor
u1 = DataArray2(Int, (5, ))
u2 = DataArray2(Int, (2, 2))
u3 = DataArray2(Int, (2, 2, 2))
@test isa(u1, DataVector2{Int})
@test isa(u2, DataMatrix2{Int})
@test isa(u3, DataArray2{Int, 3})

# test (::Type{T}, dims::Int...) constructor
x1 = DataArray2(Int, 2)
x2 = DataArray2(Int, 2, 2)
x3 = DataArray2(Int, 2, 2, 2)
@test isa(x1, DataVector2{Int})
@test isa(x2, DataMatrix2{Int})
@test isa(x3, DataArray2{Int, 3})

# test DataArray2{T}(dims::Dims)
d1, d2 = rand(1:100), rand(1:100)
X1 = DataArray2{Int}((d1,))
X2 = DataArray2{Int}((d1, d2))
@test isequal(X1, DataArray2(Array{Int}((d1,)), fill(true, (d1,))))
@test isequal(X2, DataArray2(Array{Int}((d1, d2)), fill(true, (d1, d2))))
for i in 1:5
    m = rand(3:5)
    dims = tuple([ rand(1:5) for i in 1:m ]...)
    X3 = DataArray2{Int}(dims)
    @test isequal(X3, DataArray2(Array{Int}(dims), fill(true, dims)))
end

# test DataArray2{T}(dims::Int...)
d1, d2 = rand(1:100), rand(1:100)
X1 = DataArray2{Int}(d1)
X2 = DataArray2{Int}(d1, d2)
@test isequal(X1, DataArray2(Array{Int}(d1), fill(true, d1)))
@test isequal(X2, DataArray2(Array{Int}(d1, d2), fill(true, d1, d2)))
for i in 1:5
    m = rand(3:5)
    dims = [ rand(1:5) for i in 1:m ]
    X3 = DataArray2{Int}(dims...)
    @test isequal(X3, DataArray2(Array{Int}(dims...), fill(true, dims...)))
end

# test DataArray2{T}(dims::Int...)
d1, d2 = rand(1:100), rand(1:100)
X1 = DataArray2{Int,1}(d1)
X2 = DataArray2{Int,2}(d1, d2)
@test isequal(X1, DataArray2(Array{Int,1}(d1), fill(true, d1)))
@test isequal(X2, DataArray2(Array{Int,2}(d1, d2), fill(true, d1, d2)))
for i in 1:5
    m = rand(3:5)
    dims = [ rand(1:5) for i in 1:m ]
    X3 = DataArray2{Int,length(dims)}(dims...)
    @test isequal(X3, DataArray2(Array{Int}(dims...), fill(true, dims...)))
end

# test (A::AbstractArray, ::Type{T}, ::Type{U}) constructor
z = DataArray2([1, nothing, 2, nothing, 3], Int, Void)
@test isa(z, DataVector2{Int})
@test z.isnull[2]
@test z.isnull[4]

# test (A::AbstractArray, ::Type{T}, na::Any) constructor
Z = DataArray2([1, "na", 2, 3, 4, 5, "na"], Int, "na")
@test isa(Z, DataVector2{Int})
@test Z.isnull == [false, true, false, false, false, false, true]

Y = DataArray2([1, nothing, 2, 3, 4, 5, nothing], Int, Void)
@test isequal(Y, Z)

# test DataArray2{T}()
X = DataArray2{Int}()
@test isequal(size(X), ())

# test conversion from arrays, arrays of DataValues and DataArrays2
miss1 = [false,false,false,false]
miss2 = [false,false,false,true]
for (a, miss) in zip(([1, 2, 3, 4],
                        # 1:4, # Currently does not work on 0.4, cf. JuliaLang/julia#16265
                        DataValue{Int}[DataValue(1), DataValue(2), DataValue(3), DataValue()],
                        DataArray2(DataValue{Int}[DataValue(1), DataValue(2), DataValue(3), DataValue()])),
                        (miss1, miss2, miss2))
    @test isa(DataArray2(a), DataArray2{Int,1})
    @test isequal(DataArray2(a), DataArray2{Int,1}([1,2,3,4],miss))
    @test isa(DataArray2{Int}(a), DataArray2{Int,1})
    @test isequal(DataArray2{Int}(a), DataArray2{Int,1}([1,2,3,4],miss))
    @test isa(DataArray2{Float64}(a), DataArray2{Float64,1})
    @test isequal(DataArray2{Float64}(a), DataArray2{Float64,1}([1.0,2.0,3.0,4.0],miss))
    @test isa(DataArray2{Int,1}(a), DataArray2{Int,1})
    @test isequal(DataArray2{Int,1}(a), DataArray2{Int,1}([1,2,3,4],miss))
    @test isa(DataArray2{Float64,1}(a), DataArray2{Float64,1})
    @test isequal(DataArray2{Float64,1}(a), DataArray2{Float64,1}([1.0,2.0,3.0,4.0],miss))

    @test isa(convert(DataArray2, a), DataArray2{Int,1})
    @test isequal(convert(DataArray2, a), DataArray2{Int,1}([1,2,3,4],miss))
    @test isa(convert(DataArray2{Int}, a), DataArray2{Int,1})
    @test isequal(convert(DataArray2{Int}, a), DataArray2{Int,1}([1,2,3,4],miss))
    @test isa(convert(DataArray2{Float64}, a), DataArray2{Float64,1})
    @test isequal(convert(DataArray2{Float64}, a), DataArray2{Float64,1}([1.0,2.0,3.0,4.0],miss))
    @test isa(convert(DataArray2{Int,1}, a), DataArray2{Int,1})
    @test isequal(convert(DataArray2{Int,1}, a), DataArray2{Int,1}([1,2,3,4],miss))
    @test isa(convert(DataArray2{Float64,1}, a), DataArray2{Float64,1})
    @test isequal(convert(DataArray2{Float64,1}, a), DataArray2{Float64,1}([1.0,2.0,3.0,4.0],miss))
end

# test conversion from Array{DataValue} without element type (issue #145)
@test isa(DataArray2(DataValue[DataValue(1), DataValue(2), DataValue(3), DataValue()]), DataArray2{Any})
@test isa(DataArray2{Int}(DataValue[DataValue(1), DataValue(2), DataValue(3), DataValue()]), DataArray2{Int})
@test isa(DataArray2{Float64}(DataValue[DataValue(1), DataValue(2), DataValue(3), DataValue()]), DataArray2{Float64})

@test isa(convert(DataArray2, DataValue[DataValue(1), DataValue(2), DataValue(3), DataValue()]), DataArray2{Any})
@test isa(convert(DataArray2{Int}, DataValue[DataValue(1), DataValue(2), DataValue(3), DataValue()]), DataArray2{Int})
@test isa(convert(DataArray2{Float64}, DataValue[DataValue(1), DataValue(2), DataValue(3), DataValue()]), DataArray2{Float64})

# converting a DataArray2 to unqualified type DataArray2 should be no-op
m = rand(10:100)
A = rand(m)
M = rand(Bool, m)
X = DataArray2(A, M)
@test X === convert(DataArray2, X)

end
