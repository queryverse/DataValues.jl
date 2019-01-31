using DataValues
using Test

@testset "Base derived tests" begin

types = [
    Bool,
    Float16,
    Float32,
    Float64,
    Int128,
    Int16,
    Int32,
    Int64,
    Int8,
    UInt16,
    UInt32,
    UInt64,
    UInt8,
]

# DataValue{T}() = new(true)
for T in types
    x = DataValue{T}()
    @test x.hasvalue === false
    @test isa(x.value, T)
    @test eltype(DataValue{T}) === T
    @test eltype(x) === T
end

# DataValue{T}(value::T) = new(false, value)
for T in types
    x = DataValue{T}(zero(T))
    @test x.hasvalue === true
    @test isa(x.value, T)
    @test x.value === zero(T)
    @test eltype(x) === T

    x = DataValue{T}(one(T))
    @test x.hasvalue === true
    @test isa(x.value, T)
    @test x.value === one(T)
    @test eltype(x) === T
end

# DataValue{T}(value::T, hasvalue::Bool) = new(hasvalue, value)
for T in types
    x = DataValue{T}(zero(T), true)
    @test x.hasvalue === true
    @test isa(x.value, T)
    @test x.value === zero(T)
    @test eltype(x) === T

    x = DataValue{T}(zero(T), false)
    @test x.hasvalue === false
    @test isa(x.value, T)
    @test eltype(DataValue{T}) === T
    @test eltype(x) === T
end


# immutable DataValueException <: Exception
@test isa(DataValueException(), DataValueException)
@test_throws DataValueException throw(DataValueException())

# DataValue{T}(value::T) = DataValue{T}(value)
for T in types
    v = zero(T)
    x = DataValue(v)
    @test x.hasvalue === true
    @test isa(x.value, T)
    @test x.value === v

    v = one(T)
    x = DataValue(v)
    @test x.hasvalue === true
    @test isa(x.value, T)
    @test x.value === v
end

# show{T}(io::IO, x::DataValue{T})
# TODO REENABLE
# io1 = IOBuffer()
# io2 = IOBuffer()
# for (i, T) in enumerate(types)
#     x1 = DataValue{T}()
#     x2 = DataValue(zero(T))
#     x3 = DataValue(one(T))
#     show(io1, x1)
#     @test takebuf_string(io1) == @sprintf("DataValue{%s}()", T)
#     show(io1, x2)
#     showcompact(io2, get(x2))
#     @test takebuf_string(io1) == @sprintf("DataValue{%s}(%s)", T, takebuf_string(io2))
#     show(io1, x3)
#     showcompact(io2, get(x3))
#     @test takebuf_string(io1) == @sprintf("DataValue{%s}(%s)", T, takebuf_string(io2))

#     a1 = [x2]
#     show(IOContext(io1, compact=false), a1)
#     show(IOContext(io2, compact=false), x2)
#     @test takebuf_string(io1) ==
#         @sprintf("DataValue{%s}[%s]", string(T), takebuf_string(io2))

#     show(io1, a1)
#     show(IOContext(io2, compact=true), x2)
#     @test takebuf_string(io1) ==
#         @sprintf("DataValue{%s}[%s]", string(T), takebuf_string(io2))
# end

# showcompact(io::IO, x::DataValue)
# TODO REENABLE
# io1 = IOBuffer()
# io2 = IOBuffer()
# for (i, T) in enumerate(types)
#     x1 = DataValue{T}()
#     x2 = DataValue(zero(T))
#     x3 = DataValue(one(T))
#     showcompact(io1, x1)
#     @test takebuf_string(io1) == "#NA"
#     showcompact(io1, x2)
#     showcompact(io2, get(x2))
#     @test takebuf_string(io1) == takebuf_string(io2)
#     showcompact(io1, x3)
#     showcompact(io2, get(x3))
#     @test takebuf_string(io1) == takebuf_string(io2)

#     a1 = [x2]
#     showcompact(io1, a1)
#     showcompact(io2, x2)
#     @test takebuf_string(io1) ==
#         @sprintf("DataValue{%s}[%s]", string(T), takebuf_string(io2))
# end

# get(x::DataValue)
for T in types
    x1 = DataValue{T}()
    x2 = DataValue(zero(T))
    x3 = DataValue(one(T))

    @test_throws DataValueException get(x1)
    @test_throws DataValueException x1[]
    @test get(x2) === x2[] === zero(T)
    @test get(x3) === x3[] === one(T)
end

@test_throws DataValueException get(DataValue())

# get{S, T}(x::DataValue{S}, y::T)
for T in types
    x0 = DataValue()
    x1 = DataValue{T}()
    x2 = DataValue(zero(T))
    x3 = DataValue(one(T))

    @test get(x0, zero(T)) === zero(T)
    @test get(x0, one(T)) === one(T)
    @test get(x1, zero(T)) === zero(T)
    @test get(x1, one(T)) === one(T)
    @test get(x2, one(T)) === zero(T)
    @test get(x3, zero(T)) === one(T)
end

# TODO REENABLE
# for T in types
#     # unsafe_get(x::DataValue)
#     x1 = DataValue{T}()
#     x2 = DataValue(zero(T))
#     x3 = DataValue(one(T))
#     a = rand(T)
#     x4 = DataValue(a)

#     @test isa(unsafe_get(x1), T)
#     @test unsafe_get(x2) === zero(T)
#     @test unsafe_get(x3) === one(T)
#     @test unsafe_get(x4) === a

#     # unsafe_get(x)
#     x2 = zero(T)
#     x3 = one(T)
#     x4 = rand(T)

#     @test unsafe_get(x2) === zero(T)
#     @test unsafe_get(x3) === one(T)
#     @test unsafe_get(x4) === x4
# end

# @test_throws UndefRefError unsafe_get(DataValue())
# @test_throws UndefRefError unsafe_get(DataValue{String}())
# @test_throws UndefRefError unsafe_get(DataValue{Array}())

for T in types
    # isna(x::DataValue)
    x1 = DataValue{T}()
    x2 = DataValue(zero(T))
    x3 = DataValue(one(T))

    @test isna(x1) === true
    @test isna(x2) === false
    @test isna(x3) === false

    # isna(x)
    x1 = zero(T)
    x2 = one(T)
    x3 = rand(T)

    @test isna(x1) === false
    @test isna(x2) === false
    @test isna(x3) === false
end

@test isna(DataValue())

# function =={S, T}(x::DataValue{S}, y::DataValue{T})
# TODO Anthoff thinks that we don't want these semantics.
# for T in types
#     x0 = DataValue()
#     x1 = DataValue{T}()
#     x2 = DataValue{T}()
#     x3 = DataValue(zero(T))
#     x4 = DataValue(one(T))

#     @test_throws DataValueException (x0 == x1)
#     @test_throws DataValueException (x0 == x2)
#     @test_throws DataValueException (x0 == x3)
#     @test_throws DataValueException (x0 == x4)

#     @test_throws DataValueException (x1 == x1)
#     @test_throws DataValueException (x1 == x2)
#     @test_throws DataValueException (x1 == x3)
#     @test_throws DataValueException (x1 == x4)

#     @test_throws DataValueException (x2 == x1)
#     @test_throws DataValueException (x2 == x2)
#     @test_throws DataValueException (x2 == x3)
#     @test_throws DataValueException (x2 == x4)

#     @test_throws DataValueException (x3 == x1)
#     @test_throws DataValueException (x3 == x2)
#     @test_throws DataValueException (x3 == x3)
#     @test_throws DataValueException (x3 == x4)

#     @test_throws DataValueException (x4 == x1)
#     @test_throws DataValueException (x4 == x2)
#     @test_throws DataValueException (x4 == x3)
#     @test_throws DataValueException (x4 == x4)
# end

# function hash(x::DataValue, h::UInt)
for T in types
    x0 = DataValue()
    x1 = DataValue{T}()
    x2 = DataValue{T}()
    x3 = DataValue(zero(T))
    x4 = DataValue(one(T))

    @test isa(hash(x0), UInt)
    @test isa(hash(x1), UInt)
    @test isa(hash(x2), UInt)
    @test isa(hash(x3), UInt)
    @test isa(hash(x4), UInt)

    @test hash(x0) == hash(x2)
    @test hash(x0) != hash(x3)
    @test hash(x0) != hash(x4)
    @test hash(x1) == hash(x2)
    @test hash(x1) != hash(x3)
    @test hash(x1) != hash(x4)
    @test hash(x2) != hash(x3)
    @test hash(x2) != hash(x4)
    @test hash(x3) != hash(x4)

    @test hash(x3) == hash(zero(T))
    @test hash(x4) == hash(one(T))
end

for T in types
    x1 = TestNType{T}(DataValue{T}())
    @test isna(x1.v)
    x1.v = one(T)
    @test !isna(x1.v)
    @test get(x1.v, one(T)) === one(T)
end

# Operators
# TODO REENABLE
# TestTypes = Union{Base.NullSafeTypes, BigInt, BigFloat,
#                   Complex{Int}, Complex{Float64}, Complex{BigFloat},
#                   Rational{Int}, Rational{BigInt}}.types
# for S in TestTypes, T in TestTypes
#     u0 = zero(S)
#     u1 = one(S)
#     if S <: AbstractFloat
#         u2 = S(NaN)
#     elseif S <: Complex && S.parameters[1] <: AbstractFloat
#         u2 = S(NaN, NaN)
#     else
#         u2 = u1
#     end

#     v0 = zero(T)
#     v1 = one(T)
#     if T <: AbstractFloat
#         v2 = T(NaN)
#     elseif T <: Complex && T.parameters[1] <: AbstractFloat
#         v2 = T(NaN, NaN)
#     else
#         v2 = v1
#     end

#     for u in (u0, u1, u2), v in (v0, v1, v2)
#         # function isequal(x::DataValue, y::DataValue)
#         @test isequal(DataValue(u), DataValue(v)) === isequal(u, v)
#         @test isequal(DataValue(u), DataValue(u)) === true
#         @test isequal(DataValue(v), DataValue(v)) === true

#         @test isequal(DataValue(u), DataValue(v, false)) === false
#         @test isequal(DataValue(u, false), DataValue(v)) === false
#         @test isequal(DataValue(u, false), DataValue(v, false)) === true

#         @test isequal(DataValue(u), DataValue{T}()) === false
#         @test isequal(DataValue{S}(), DataValue(v)) === false
#         @test isequal(DataValue{S}(), DataValue{T}()) === true

#         @test isequal(DataValue(u), DataValue()) === false
#         @test isequal(DataValue(), DataValue(v)) === false
#         @test isequal(DataValue{S}(), DataValue()) === true
#         @test isequal(DataValue(), DataValue{T}()) === true
#         @test isequal(DataValue(), DataValue()) === true

#         # function isless(x::DataValue, y::DataValue)
#         if S <: Real && T <: Real
#             @test isless(DataValue(u), DataValue(v)) === isless(u, v)
#             @test isless(DataValue(u), DataValue(u)) === false
#             @test isless(DataValue(v), DataValue(v)) === false

#             @test isless(DataValue(u), DataValue(v, false)) === true
#             @test isless(DataValue(u, false), DataValue(v)) === false
#             @test isless(DataValue(u, false), DataValue(v, false)) === false

#             @test isless(DataValue(u), DataValue{T}()) === true
#             @test isless(DataValue{S}(), DataValue(v)) === false
#             @test isless(DataValue{S}(), DataValue{T}()) === false

#             @test isless(DataValue(u), DataValue()) === true
#             @test isless(DataValue(), DataValue(v)) === false
#             @test isless(DataValue{S}(), DataValue()) === false
#             @test isless(DataValue(), DataValue{T}()) === false
#             @test isless(DataValue(), DataValue()) === false
#         end
#     end
# end

# issue #9462
for T in types
    @test isa(convert(DataValue{Number}, DataValue(one(T))), DataValue{Number})
    @test isa(convert(DataValue{Number}, one(T)), DataValue{Number})
    @test isa(convert(DataValue{T}, one(T)), DataValue{T})
    @test isa(convert(DataValue{Any}, DataValue(one(T))), DataValue{Any})
    @test isa(convert(DataValue{Any}, one(T)), DataValue{Any})

    # one(T) is convertible to every type in types
    # let's test that with DataValues
    for S in types
        @test isa(convert(DataValue{T}, one(S)), DataValue{T})
    end
end

@test isna(convert(DataValue, nothing))
@test isna(convert(DataValue{Int}, nothing))
@test isa(convert(DataValue{Int}, nothing), DataValue{Int})

@test convert(DataValue, 1) === DataValue(1)
@test convert(DataValue, DataValue(1)) === DataValue(1)
@test isequal(convert(DataValue, "a"), DataValue("a"))
@test isequal(convert(DataValue, DataValue("a")), DataValue("a"))

@test promote_type(DataValue{Int}, Int) === DataValue{Int}
@test promote_type(DataValue{Union{}}, Int) === DataValue{Int}
@test promote_type(DataValue{Float64}, DataValue{Int}) === DataValue{Float64}
@test promote_type(DataValue{Union{}}, DataValue{Int}) === DataValue{Int}
@test promote_type(DataValue{Date}, DataValue{DateTime}) === DataValue{DateTime}

@test Base.promote_op(+, DataValue{Int}, DataValue{Int}) == DataValue{Int}
@test Base.promote_op(-, DataValue{Int}, DataValue{Int}) == DataValue{Int}
@test Base.promote_op(+, DataValue{Float64}, DataValue{Int}) == DataValue{Float64}
@test Base.promote_op(-, DataValue{Float64}, DataValue{Int}) == DataValue{Float64}
@test Base.promote_op(-, DataValue{DateTime}, DataValue{DateTime}) == DataValue{Dates.Millisecond}

# issue #11675
# @test repr(DataValue()) == "NULL"

end
