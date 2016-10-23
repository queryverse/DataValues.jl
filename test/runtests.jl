using NAables
using Base.Test

@testset begin
# 3VL

@test NAable(true) & NAable(true) == NAable(true)
@test NAable(true) & NAable(false) == NAable(false)
@test NAable(true) & NAable{Bool}() == NAable{Bool}()
@test NAable(false) & NAable(true) == NAable(false)
@test NAable(false) & NAable(false) == NAable(false)
@test NAable(false) & NAable{Bool}() == NAable(false)
@test NAable{Bool}() & NAable(true) == NAable{Bool}()
@test NAable{Bool}() & NAable(false) == NAable(false)
@test NAable{Bool}() & NAable{Bool}() == NAable{Bool}()

@test true & NAable(true) == NAable(true)
@test true & NAable(false) == NAable(false)
@test true & NAable{Bool}() == NAable{Bool}()
@test false & NAable(true) == NAable(false)
@test false & NAable(false) == NAable(false)
@test false & NAable{Bool}() == NAable(false)

@test NAable(true) & true == NAable(true)
@test NAable(true) & false == NAable(false)
@test NAable(false) & true == NAable(false)
@test NAable(false) & false == NAable(false)
@test NAable{Bool}() & true == NAable{Bool}()
@test NAable{Bool}() & false == NAable(false)

@test NAable(true) | NAable(true) == NAable(true)
@test NAable(true) | NAable(false) == NAable(true)
@test NAable(true) | NAable{Bool}() == NAable(true)
@test NAable(false) | NAable(true) == NAable(true)
@test NAable(false) | NAable(false) == NAable(false)
@test NAable(false) | NAable{Bool}() == NAable{Bool}()
@test NAable{Bool}() | NAable(true) == NAable(true)
@test NAable{Bool}() | NAable(false) == NAable{Bool}()
@test NAable{Bool}() | NAable{Bool}() == NAable{Bool}()

@test true | NAable(true) == NAable(true)
@test true | NAable(false) == NAable(true)
@test true | NAable{Bool}() == NAable(true)
@test false | NAable(true) == NAable(true)
@test false | NAable(false) == NAable(false)
@test false | NAable{Bool}() == NAable{Bool}()

@test NAable(true) | true == NAable(true)
@test NAable(true) | false == NAable(true)
@test NAable(false) | true == NAable(true)
@test NAable(false) | false == NAable(false)
@test NAable{Bool}() | true == NAable(true)
@test NAable{Bool}() | false == NAable{Bool}()

@test !NAable(true) == NAable(false)
@test !NAable(false) == NAable(true)
@test !NAable{Bool}() == NAable{Bool}()

# NA comparisons
@test (NAable(5)==NA) == false
@test (NAable{Int}()==NA) == true
@test (NA==NAable(5)) == false
@test (NA==NAable{Int}()) == true

@test (NAable(5)!=NA) == true
@test (NAable{Int}()!=NA) == false
@test (NA!=NAable(5)) == true
@test (NA!=NAable{Int}()) == false

:+, :-, :!, :~
@test +NAable(1) == NAable(+1)
@test +NAable{Int}() == NAable{Int}()
@test -NAable(1) == NAable(-1)
@test -NAable{Int}() == NAable{Int}()
@test ~NAable(1) == NAable(~1)
@test ~NAable{Int}() == NAable{Int}()

# TODO add ^, / back
for op in (:+, :-, :*, :%, :&, :|, :<<, :>>)
    @eval begin
        @test $op(NAable(3), NAable(5)) == NAable($op(3, 5))
        @test $op(NAable{Int}(), NAable(5)) == NAable{Int}()
        @test $op(NAable(3), NAable{Int}()) == NAable{Int}()
        @test $op(NAable{Int}(), NAable{Int}()) == NAable{Int}()

        @test $op(NAable{Int}(3), 5) == NAable($op(3, 5))
        @test $op(3, NAable{Int}(5)) == NAable($op(3, 5))
        @test $op(NAable{Int}(), 5) == NAable{Int}()
        @test $op(3, NAable{Int}()) == NAable{Int}()
    end
end

@test NAable(3)^2 == NAable(9)
@test NAable{Int}()^2 == NAable{Int}()

@test NAable(3) == NAable(3)
@test !(NAable(3) == NAable(4))
@test !(NAable{Int}() == NAable(3))
@test !(NAable{Float64}() == NAable(3))
@test !(NAable(3) == NAable{Int}())
@test !(NAable(3) == NAable{Float64}())
@test NAable{Int}() == NAable{Int}()
@test NAable{Int}() == NAable{Float64}()

@test NAable(3) == 3
@test 3 == NAable(3)
@test !(NAable(3) == 4)
@test !(4 == NAable(3))
@test !(NAable{Int}() == 3)
@test !(3 == NAable{Int}())

@test !(NAable(3) != NAable(3))
@test NAable(3) != NAable(4)
@test NAable{Int}() != NAable(3)
@test NAable{Float64}() != NAable(3)
@test NAable(3) != NAable{Int}()
@test NAable(3) != NAable{Float64}()
@test !(NAable{Int}() != NAable{Int}())
@test !(NAable{Int}() != NAable{Float64}())

@test !(NAable(3) != 3)
@test !(3 != NAable(3))
@test NAable(3) != 4
@test 4 != NAable(3)
@test NAable{Int}() != 3
@test 3 != NAable{Int}()

@test NAable(4) > NAable(3)
@test !(NAable(3) > NAable(4))
@test !(NAable(4) > NAable{Int}())
@test !(NAable{Int}() > NAable(3))
@test !(NAable{Int}() > NAable{Int}())

@test NAable(4) > 3
@test !(NAable(3) > 4)
@test !(NAable{Int}() > 3)

@test 4 > NAable(3)
@test !(3 > NAable(4))
@test !(4 > NAable{Int}())

@test lowercase(NAable("TEST"))==NAable("test")
@test lowercase(NAable{String}())==NAable{String}()

@test NAable("TEST")[2:end]==NAable("EST")
@test NAable{String}()[2:end]==NAable{String}()

@test length(NAable("TEST"))==NAable(4)
@test length(NAable{String}())==NAable{Int}()

end

type TestNType{T}
    v::NAable{T}
end

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

# NAable{T}() = new(true)
for T in types
    x = NAable{T}()
    @test x.hasvalue === false
    @test isa(x.value, T)
    @test eltype(NAable{T}) === T
    @test eltype(x) === T
end

# NAable{T}(value::T) = new(false, value)
for T in types
    x = NAable{T}(zero(T))
    @test x.hasvalue === true
    @test isa(x.value, T)
    @test x.value === zero(T)
    @test eltype(x) === T

    x = NAable{T}(one(T))
    @test x.hasvalue === true
    @test isa(x.value, T)
    @test x.value === one(T)
    @test eltype(x) === T
end

# NAable{T}(value::T, hasvalue::Bool) = new(hasvalue, value)
for T in types
    x = NAable{T}(zero(T), true)
    @test x.hasvalue === true
    @test isa(x.value, T)
    @test x.value === zero(T)
    @test eltype(x) === T

    x = NAable{T}(zero(T), false)
    @test x.hasvalue === false
    @test isa(x.value, T)
    @test eltype(NAable{T}) === T
    @test eltype(x) === T
end


# immutable NAException <: Exception
@test isa(NAException(), NAException)
@test_throws NAException throw(NAException())

# NAable{T}(value::T) = NAable{T}(value)
for T in types
    v = zero(T)
    x = NAable(v)
    @test x.hasvalue === true
    @test isa(x.value, T)
    @test x.value === v

    v = one(T)
    x = NAable(v)
    @test x.hasvalue === true
    @test isa(x.value, T)
    @test x.value === v
end

# show{T}(io::IO, x::NAable{T})
# TODO REENABLE
# io1 = IOBuffer()
# io2 = IOBuffer()
# for (i, T) in enumerate(types)
#     x1 = NAable{T}()
#     x2 = NAable(zero(T))
#     x3 = NAable(one(T))
#     show(io1, x1)
#     @test takebuf_string(io1) == @sprintf("NAable{%s}()", T)
#     show(io1, x2)
#     showcompact(io2, get(x2))
#     @test takebuf_string(io1) == @sprintf("NAable{%s}(%s)", T, takebuf_string(io2))
#     show(io1, x3)
#     showcompact(io2, get(x3))
#     @test takebuf_string(io1) == @sprintf("NAable{%s}(%s)", T, takebuf_string(io2))

#     a1 = [x2]
#     show(IOContext(io1, compact=false), a1)
#     show(IOContext(io2, compact=false), x2)
#     @test takebuf_string(io1) ==
#         @sprintf("NAable{%s}[%s]", string(T), takebuf_string(io2))

#     show(io1, a1)
#     show(IOContext(io2, compact=true), x2)
#     @test takebuf_string(io1) ==
#         @sprintf("NAable{%s}[%s]", string(T), takebuf_string(io2))
# end

# showcompact(io::IO, x::NAable)
# TODO REENABLE
# io1 = IOBuffer()
# io2 = IOBuffer()
# for (i, T) in enumerate(types)
#     x1 = NAable{T}()
#     x2 = NAable(zero(T))
#     x3 = NAable(one(T))
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
#         @sprintf("NAable{%s}[%s]", string(T), takebuf_string(io2))
# end

# get(x::NAable)
for T in types
    x1 = NAable{T}()
    x2 = NAable(zero(T))
    x3 = NAable(one(T))

    @test_throws NAException get(x1)
    @test get(x2) === zero(T)
    @test get(x3) === one(T)
end

@test_throws NAException get(NAable())

# get{S, T}(x::NAable{S}, y::T)
for T in types
    x0 = NAable()
    x1 = NAable{T}()
    x2 = NAable(zero(T))
    x3 = NAable(one(T))

    @test get(x0, zero(T)) === zero(T)
    @test get(x0, one(T)) === one(T)
    @test get(x1, zero(T)) === zero(T)
    @test get(x1, one(T)) === one(T)
    @test get(x2, one(T)) === zero(T)
    @test get(x3, zero(T)) === one(T)
end

# TODO REENABLE
# for T in types
#     # unsafe_get(x::NAable)
#     x1 = NAable{T}()
#     x2 = NAable(zero(T))
#     x3 = NAable(one(T))
#     a = rand(T)
#     x4 = NAable(a)

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

# @test_throws UndefRefError unsafe_get(NAable())
# @test_throws UndefRefError unsafe_get(NAable{String}())
# @test_throws UndefRefError unsafe_get(NAable{Array}())

for T in types
    # isna(x::NAable)
    x1 = NAable{T}()
    x2 = NAable(zero(T))
    x3 = NAable(one(T))

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

@test isna(NAable())

# function =={S, T}(x::NAable{S}, y::NAable{T})
# TODO Anthoff thinks that we don't want these semantics.
# for T in types
#     x0 = NAable()
#     x1 = NAable{T}()
#     x2 = NAable{T}()
#     x3 = NAable(zero(T))
#     x4 = NAable(one(T))

#     @test_throws NAException (x0 == x1)
#     @test_throws NAException (x0 == x2)
#     @test_throws NAException (x0 == x3)
#     @test_throws NAException (x0 == x4)

#     @test_throws NAException (x1 == x1)
#     @test_throws NAException (x1 == x2)
#     @test_throws NAException (x1 == x3)
#     @test_throws NAException (x1 == x4)

#     @test_throws NAException (x2 == x1)
#     @test_throws NAException (x2 == x2)
#     @test_throws NAException (x2 == x3)
#     @test_throws NAException (x2 == x4)

#     @test_throws NAException (x3 == x1)
#     @test_throws NAException (x3 == x2)
#     @test_throws NAException (x3 == x3)
#     @test_throws NAException (x3 == x4)

#     @test_throws NAException (x4 == x1)
#     @test_throws NAException (x4 == x2)
#     @test_throws NAException (x4 == x3)
#     @test_throws NAException (x4 == x4)
# end

# function hash(x::NAable, h::UInt)
for T in types
    x0 = NAable()
    x1 = NAable{T}()
    x2 = NAable{T}()
    x3 = NAable(zero(T))
    x4 = NAable(one(T))

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
end

for T in types
    x1 = TestNType{T}(NAable{T}())
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
#         # function isequal(x::NAable, y::NAable)
#         @test isequal(NAable(u), NAable(v)) === isequal(u, v)
#         @test isequal(NAable(u), NAable(u)) === true
#         @test isequal(NAable(v), NAable(v)) === true

#         @test isequal(NAable(u), NAable(v, false)) === false
#         @test isequal(NAable(u, false), NAable(v)) === false
#         @test isequal(NAable(u, false), NAable(v, false)) === true

#         @test isequal(NAable(u), NAable{T}()) === false
#         @test isequal(NAable{S}(), NAable(v)) === false
#         @test isequal(NAable{S}(), NAable{T}()) === true

#         @test isequal(NAable(u), NAable()) === false
#         @test isequal(NAable(), NAable(v)) === false
#         @test isequal(NAable{S}(), NAable()) === true
#         @test isequal(NAable(), NAable{T}()) === true
#         @test isequal(NAable(), NAable()) === true

#         # function isless(x::NAable, y::NAable)
#         if S <: Real && T <: Real
#             @test isless(NAable(u), NAable(v)) === isless(u, v)
#             @test isless(NAable(u), NAable(u)) === false
#             @test isless(NAable(v), NAable(v)) === false

#             @test isless(NAable(u), NAable(v, false)) === true
#             @test isless(NAable(u, false), NAable(v)) === false
#             @test isless(NAable(u, false), NAable(v, false)) === false

#             @test isless(NAable(u), NAable{T}()) === true
#             @test isless(NAable{S}(), NAable(v)) === false
#             @test isless(NAable{S}(), NAable{T}()) === false

#             @test isless(NAable(u), NAable()) === true
#             @test isless(NAable(), NAable(v)) === false
#             @test isless(NAable{S}(), NAable()) === false
#             @test isless(NAable(), NAable{T}()) === false
#             @test isless(NAable(), NAable()) === false
#         end
#     end
# end

# issue #9462
for T in types
    @test isa(convert(NAable{Number}, NAable(one(T))), NAable{Number})
    @test isa(convert(NAable{Number}, one(T)), NAable{Number})
    @test isa(convert(NAable{T}, one(T)), NAable{T})
    @test isa(convert(NAable{Any}, NAable(one(T))), NAable{Any})
    @test isa(convert(NAable{Any}, one(T)), NAable{Any})

    # one(T) is convertible to every type in types
    # let's test that with NAables
    for S in types
        @test isa(convert(NAable{T}, one(S)), NAable{T})
    end
end

@test isna(convert(NAable, nothing))
@test isna(convert(NAable{Int}, nothing))
@test isa(convert(NAable{Int}, nothing), NAable{Int})

@test convert(NAable, 1) === NAable(1)
@test convert(NAable, NAable(1)) === NAable(1)
@test isequal(convert(NAable, "a"), NAable("a"))
@test isequal(convert(NAable, NAable("a")), NAable("a"))

@test promote_type(NAable{Int}, Int) === NAable{Int}
@test promote_type(NAable{Union{}}, Int) === NAable{Int}
@test promote_type(NAable{Float64}, NAable{Int}) === NAable{Float64}
@test promote_type(NAable{Union{}}, NAable{Int}) === NAable{Int}
@test promote_type(NAable{Date}, NAable{DateTime}) === NAable{DateTime}

@test Base.promote_op(+, NAable{Int}, NAable{Int}) == NAable{Int}
@test Base.promote_op(-, NAable{Int}, NAable{Int}) == NAable{Int}
@test Base.promote_op(+, NAable{Float64}, NAable{Int}) == NAable{Float64}
@test Base.promote_op(-, NAable{Float64}, NAable{Int}) == NAable{Float64}
@test Base.promote_op(-, NAable{DateTime}, NAable{DateTime}) == NAable{Base.Dates.Millisecond}

# issue #11675
@test repr(NAable()) == "NA"

end

module NAableTestEnum
    using NAables
    io = IOBuffer()
    @enum TestEnum a b
    show(io, NAable(a))
    Base.Test.@test takebuf_string(io) == "NAable{NAableTestEnum.TestEnum}(a)"
end
