module TestDataValueArray

using Base.Test
using CategoricalArrays
using DataValues
using CategoricalArrays: DefaultRefType
using Compat

for ordered in (false, true)
    for R in (CategoricalArrays.DefaultRefType, UInt8, UInt, Int8, Int)
        # Vector with no null values
        for a in (["b", "a", "b"],
                  DataValue{String}["b", "a", "b"],
                  DataValueArray(["b", "a", "b"]))
            x = DataValueCategoricalVector{String, R}(a, ordered=ordered)
            na = eltype(a) <: DataValue ? a : convert(Array{DataValue{String}}, a)

            @test x == na
            @test isordered(x) === ordered
            @test levels(x) == sort(map(get, unique(na)))
            @test size(x) === (3,)
            @test length(x) === 3

            @test convert(DataValueCategoricalArray, x) === x
            @test convert(DataValueCategoricalArray{String}, x) === x
            @test convert(DataValueCategoricalArray{String, 1}, x) === x
            @test convert(DataValueCategoricalArray{String, 1, R}, x) === x
            @test convert(DataValueCategoricalArray{String, 1, DefaultRefType}, x) == x
            @test convert(DataValueCategoricalArray{String, 1, UInt8}, x) == x

            @test convert(DataValueCategoricalVector, x) === x
            @test convert(DataValueCategoricalVector{String}, x) === x
            @test convert(DataValueCategoricalVector{String, R}, x) === x
            @test convert(DataValueCategoricalVector{String, DefaultRefType}, x) == x
            @test convert(DataValueCategoricalVector{String, UInt8}, x) == x

            @test convert(DataValueCategoricalArray, a) == x
            @test convert(DataValueCategoricalArray{String}, a) == x
            @test convert(DataValueCategoricalArray{String, 1}, a) == x
            @test convert(DataValueCategoricalArray{String, 1, R}, a) == x
            @test convert(DataValueCategoricalArray{String, 1, DefaultRefType}, a) == x
            @test convert(DataValueCategoricalArray{String, 1, UInt8}, a) == x

            @test convert(DataValueCategoricalVector, a) == x
            @test convert(DataValueCategoricalVector{String}, a) == x
            @test convert(DataValueCategoricalVector{String, R}, a) == x
            @test convert(DataValueCategoricalVector{String, DefaultRefType}, a) == x
            @test convert(DataValueCategoricalVector{String, UInt8}, a) == x

            @test DataValueCategoricalArray{String}(a, ordered=ordered) == x
            @test DataValueCategoricalArray{String, 1}(a, ordered=ordered) == x
            @test DataValueCategoricalArray{String, 1, R}(a, ordered=ordered) == x
            @test DataValueCategoricalArray{String, 1, DefaultRefType}(a, ordered=ordered) == x
            @test DataValueCategoricalArray{String, 1, UInt8}(a, ordered=ordered) == x

            @test DataValueCategoricalVector(a, ordered=ordered) == x
            @test DataValueCategoricalVector{String}(a, ordered=ordered) == x
            @test DataValueCategoricalVector{String, R}(a, ordered=ordered) == x
            @test DataValueCategoricalVector{String, DefaultRefType}(a, ordered=ordered) == x
            @test DataValueCategoricalVector{String, UInt8}(a, ordered=ordered) == x

            for (y, R1, R2, comp) in ((a, DefaultRefType, UInt8, true),
                                      (a, DefaultRefType, DefaultRefType, false),
                                      (x, R, UInt8, true),
                                      (x, R, R, false))
                x2 = categorical(y, ordered=ordered)
                @test x2 == y
                if eltype(y) <: DataValue
                    @test isa(x2, DataValueCategoricalVector{String, R1})
                else
                    @test isa(x2, CategoricalVector{String, R1})
                end
                @test isordered(x2) === ordered

                x2 = categorical(y, comp, ordered=ordered)
                @test x2 == y
                if eltype(y) <: DataValue
                    @test isa(x2, DataValueCategoricalVector{String, R2})
                else
                    @test isa(x2, CategoricalVector{String, R2})
                end
                @test isordered(x2) === ordered
            end

            x2 = compress(x)
            @test x2 == x
            @test isa(x2, DataValueCategoricalVector{String, UInt8})
            @test isordered(x2) === isordered(x)
            @test levels(x2) == levels(x)

            x2 = copy(x)
            @test x2 == x
            @test isordered(x2) === isordered(x)
            @test typeof(x2) === typeof(x)
            @test levels(x2) == levels(x)

            if !isordered(x)
                @test ordered!(x, true) === x
                @test isordered(x) === true
            end
            @test get(x[1] > x[2])
            @test get(x[3] > x[2])

            @test ordered!(x, false) === x
            @test isordered(x) === false
            @test_throws Exception x[1] > x[2]
            @test_throws Exception x[3] > x[2]

            @test x[1] === DataValue(x.pool.valindex[1])
            @test x[2] === DataValue(x.pool.valindex[2])
            @test x[3] === DataValue(x.pool.valindex[1])
            @test_throws BoundsError x[4]

            x2 = x[:]
            @test typeof(x2) === typeof(x)
            @test x2 == x
            @test x2 !== x
            @test levels(x2) == levels(x)
            @test levels(x2) !== levels(x)
            @test isordered(x2) == isordered(x)

            x2 = x[2:3]
            @test typeof(x2) === typeof(x)
            @test x2 == DataValue{String}["a", "b"]
            @test levels(x2) == levels(x)
            @test levels(x2) !== levels(x)
            @test isordered(x2) == isordered(x)

            x2 = x[1:1]
            @test typeof(x2) === typeof(x)
            @test x2 == DataValue{String}["b"]
            @test levels(x2) == levels(x)
            @test levels(x2) !== levels(x)
            @test isordered(x2) == isordered(x)

            x2 = x[2:1]
            @test typeof(x2) === typeof(x)
            @test isempty(x2)
            @test levels(x2) == levels(x)
            @test levels(x2) !== levels(x)
            @test isordered(x2) == isordered(x)

            x[1] = x[2]
            @test x[1] === DataValue(x.pool.valindex[2])
            @test x[2] === DataValue(x.pool.valindex[2])
            @test x[3] === DataValue(x.pool.valindex[1])

            x[3] = "c"
            @test x[1] === DataValue(x.pool.valindex[2])
            @test x[2] === DataValue(x.pool.valindex[2])
            @test x[3] === DataValue(x.pool.valindex[3])
            @test levels(x) == ["a", "b", "c"]

            x[2:3] = "b"
            @test x[1] === DataValue(x.pool.valindex[2])
            @test x[2] === DataValue(x.pool.valindex[1])
            @test x[3] === DataValue(x.pool.valindex[1])
            @test levels(x) == ["a", "b", "c"]

            @test droplevels!(x) === x
            @test levels(x) == ["a", "b"]
            @test x[1] === DataValue(x.pool.valindex[1])
            @test x[2] === DataValue(x.pool.valindex[2])
            @test x[3] === DataValue(x.pool.valindex[2])
            @test levels(x) == ["a", "b"]

            @test levels!(x, ["b", "a"]) === x
            @test levels(x) == ["b", "a"]
            @test x[1] === DataValue(x.pool.valindex[1])
            @test x[2] === DataValue(x.pool.valindex[2])
            @test x[3] === DataValue(x.pool.valindex[2])
            @test levels(x) == ["b", "a"]

            @test_throws ArgumentError levels!(x, ["a"])
            @test_throws ArgumentError levels!(x, ["e", "b"])
            @test_throws ArgumentError levels!(x, ["e", "a", "b", "a"])

            @test levels!(x, ["e", "a", "b"]) === x
            @test levels(x) == ["e", "a", "b"]
            @test x[1] === DataValue(x.pool.valindex[1])
            @test x[2] === DataValue(x.pool.valindex[2])
            @test x[3] === DataValue(x.pool.valindex[2])
            @test levels(x) == ["e", "a", "b"]

            x[1] = "c"
            @test x[1] === DataValue(x.pool.valindex[4])
            @test x[2] === DataValue(x.pool.valindex[2])
            @test x[3] === DataValue(x.pool.valindex[2])
            @test levels(x) == ["e", "a", "b", "c"]

            @test_throws ArgumentError levels!(x, ["e", "c"])
            @test levels!(x, ["e", "c"], nullok=true) === x
            @test levels(x) == ["e", "c"]
            @test x[1] === DataValue(x.pool.valindex[2])
            @test x[2] === eltype(x)()
            @test x[3] === eltype(x)()
            @test levels(x) == ["e", "c"]

            push!(x, "e")
            @test length(x) == 4
            @test isequal(x, DataValueArray(["c", "", "", "e"], [false, true, true, false]))
            @test levels(x) == ["e", "c"]

            push!(x, "zz")
            @test length(x) == 5
            @test isequal(x, DataValueArray(["c", "", "", "e", "zz"], [false, true, true, false, false]))
            @test levels(x) == ["e", "c", "zz"]

            push!(x, x[1])
            @test length(x) == 6
            @test isequal(x, DataValueArray(["c", "", "", "e", "zz", "c"], [false, true, true, false, false, false]))
            @test levels(x) == ["e", "c", "zz"]

            push!(x, eltype(x)())
            @test length(x) == 7
            @test isequal(x, DataValueArray(["c", "", "", "e", "zz", "c", ""], [false, true, true, false, false, false, true]))
            @test isnull(x[end])
            @test levels(x) == ["e", "c", "zz"]

            append!(x, x)
            @test isequal(x, DataValueArray(["c", "", "", "e", "zz", "c", "", "c", "", "", "e", "zz", "c", ""], [false, true, true, false, false, false, true, false, true, true, false, false, false, true]))
            @test levels(x) == ["e", "c", "zz"]
            @test isordered(x) === false
            @test length(x) == 14

            b = ["z","y","x"]
            y = DataValueCategoricalVector{String, R}(b)
            append!(x, y)
            @test length(x) == 17
            @test isordered(x) === false
            @test levels(x) == ["e", "c", "zz", "x", "y", "z"]
            @test isequal(x, DataValueArray(["c", "", "", "e", "zz", "c", "", "c", "", "", "e", "zz", "c", "", "z", "y", "x"], [false, true, true, false, false, false, true, false, true, true, false, false, false, true, false, false, false]))

            empty!(x)
            @test isordered(x) === false
            @test length(x) == 0
            @test levels(x) == ["e", "c", "zz", "x", "y", "z"]
        end


        # Vector with null values
        for a in (DataValue{String}["a", "b", DataValue()],
                  DataValueArray(DataValue{String}["a", "b", DataValue()]))
            x = DataValueCategoricalVector{String, R}(a, ordered=ordered)

            @test x == a
            @test levels(x) == map(get, filter(x->!isnull(x), unique(a)))
            @test size(x) === (3,)
            @test length(x) === 3

            @test convert(DataValueCategoricalArray, x) === x
            @test convert(DataValueCategoricalArray{String}, x) === x
            @test convert(DataValueCategoricalArray{String, 1}, x) === x
            @test convert(DataValueCategoricalArray{String, 1, R}, x) === x
            @test convert(DataValueCategoricalArray{String, 1, DefaultRefType}, x) == x
            @test convert(DataValueCategoricalArray{String, 1, UInt8}, x) == x

            @test convert(DataValueCategoricalVector, x) === x
            @test convert(DataValueCategoricalVector{String}, x) === x
            @test convert(DataValueCategoricalVector{String, R}, x) === x
            @test convert(DataValueCategoricalVector{String, DefaultRefType}, x) == x
            @test convert(DataValueCategoricalVector{String, UInt8}, x) == x

            @test convert(DataValueCategoricalArray, a) == x
            @test convert(DataValueCategoricalArray{String}, a) == x
            @test convert(DataValueCategoricalArray{String, 1}, a) == x
            @test convert(DataValueCategoricalArray{String, 1, R}, a) == x
            @test convert(DataValueCategoricalArray{String, 1, DefaultRefType}, a) == x
            @test convert(DataValueCategoricalArray{String, 1, UInt8}, a) == x

            @test convert(DataValueCategoricalVector, a) == x
            @test convert(DataValueCategoricalVector{String}, a) == x
            @test convert(DataValueCategoricalVector{String, R}, a) == x
            @test convert(DataValueCategoricalVector{String, DefaultRefType}, a) == x
            @test convert(DataValueCategoricalVector{String, UInt8}, a) == x

            @test DataValueCategoricalArray{String}(a, ordered=ordered) == x
            @test DataValueCategoricalArray{String, 1}(a, ordered=ordered) == x
            @test DataValueCategoricalArray{String, 1, R}(a, ordered=ordered) == x
            @test DataValueCategoricalArray{String, 1, DefaultRefType}(a, ordered=ordered) == x
            @test DataValueCategoricalArray{String, 1, UInt8}(a, ordered=ordered) == x

            @test DataValueCategoricalVector(a, ordered=ordered) == x
            @test DataValueCategoricalVector{String}(a, ordered=ordered) == x
            @test DataValueCategoricalVector{String, R}(a, ordered=ordered) == x
            @test DataValueCategoricalVector{String, DefaultRefType}(a, ordered=ordered) == x
            @test DataValueCategoricalVector{String, UInt8}(a, ordered=ordered) == x

            for (y, R1, R2, comp) in ((a, DefaultRefType, UInt8, true),
                                      (a, DefaultRefType, DefaultRefType, false),
                                      (x, R, UInt8, true),
                                      (x, R, R, false))
                x2 = categorical(y, ordered=ordered)
                @test x2 == y
                @test isa(x2, DataValueCategoricalVector{String, R1})
                @test isordered(x2) === ordered

                x2 = categorical(y, comp, ordered=ordered)
                @test x2 == y
                @test isa(x2, DataValueCategoricalVector{String, R2})
                @test isordered(x2) === ordered
            end

            x2 = compress(x)
            @test x2 == x
            @test isa(x2, DataValueCategoricalVector{String, UInt8})
            @test levels(x2) == levels(x)

            x2 = copy(x)
            @test x2 == x
            @test typeof(x2) === typeof(x)
            @test levels(x2) == levels(x)

            @test x[1] === DataValue(x.pool.valindex[1])
            @test x[2] === DataValue(x.pool.valindex[2])
            @test x[3] === eltype(x)()
            @test_throws BoundsError x[4]

            x2 = x[:]
            @test typeof(x2) === typeof(x)
            @test x2 == x
            @test x2 !== x
            @test levels(x2) == levels(x)
            @test levels(x2) !== levels(x)
            @test isordered(x2) == isordered(x)

            x2 = x[2:3]
            @test typeof(x2) === typeof(x)
            @test x2 == DataValue{String}["b", DataValue()]
            @test levels(x2) == levels(x)
            @test levels(x2) !== levels(x)
            @test isordered(x2) == isordered(x)

            x2 = x[1:1]
            @test typeof(x2) === typeof(x)
            @test x2 == DataValue{String}["a"]
            @test levels(x2) == levels(x)
            @test levels(x2) !== levels(x)
            @test isordered(x2) == isordered(x)

            x2 = x[2:1]
            @test typeof(x2) === typeof(x)
            @test isempty(x2)
            @test levels(x2) == levels(x)
            @test levels(x2) !== levels(x)
            @test isordered(x2) == isordered(x)

            x[1] = "b"
            @test x[1] === DataValue(x.pool.valindex[2])
            @test x[2] === DataValue(x.pool.valindex[2])
            @test x[3] === eltype(x)()

            x[3] = "c"
            @test x[1] === DataValue(x.pool.valindex[2])
            @test x[2] === DataValue(x.pool.valindex[2])
            @test x[3] === DataValue(x.pool.valindex[3])
            @test levels(x) == ["a", "b", "c"]

            x[1] = DataValue()
            @test x[1] === eltype(x)()
            @test x[2] === DataValue(x.pool.valindex[2])
            @test x[3] === DataValue(x.pool.valindex[3])
            @test levels(x) == ["a", "b", "c"]

            x[2:3] = DataValue()
            @test x[1] === eltype(x)()
            @test x[2] === eltype(x)()
            @test x[3] === eltype(x)()
            @test levels(x) == ["a", "b", "c"]
        end


        # Vector created from range (i.e. non-Array AbstractArray),
        # direct conversion to a vector with different eltype
        a = 0.0:0.5:1.5
        x = DataValueCategoricalVector{Float64, R}(a, ordered=ordered)

        @test x == map(DataValue, a)
        @test isordered(x) === ordered
        @test levels(x) == unique(a)
        @test size(x) === (4,)
        @test length(x) === 4

        @test convert(DataValueCategoricalArray, x) === x
        @test convert(DataValueCategoricalArray{Float64}, x) === x
        @test convert(DataValueCategoricalArray{Float64, 1}, x) === x
        @test convert(DataValueCategoricalArray{Float64, 1, R}, x) === x
        @test convert(DataValueCategoricalArray{Float64, 1, DefaultRefType}, x) == x
        @test convert(DataValueCategoricalArray{Float64, 1, UInt8}, x) == x

        @test convert(DataValueCategoricalVector, x) === x
        @test convert(DataValueCategoricalVector{Float64}, x) === x
        @test convert(DataValueCategoricalVector{Float64, R}, x) === x
        @test convert(DataValueCategoricalVector{Float64, DefaultRefType}, x) == x
        @test convert(DataValueCategoricalVector{Float64, UInt8}, x) == x

        @test convert(DataValueCategoricalArray, a) == x
        @test convert(DataValueCategoricalArray{Float64}, a) == x
        @test convert(DataValueCategoricalArray{Float32}, a) == x
        @test convert(DataValueCategoricalArray{Float64, 1}, a) == x
        @test convert(DataValueCategoricalArray{Float32, 1}, a) == x
        @test convert(DataValueCategoricalArray{Float64, 1, R}, a) == x
        @test convert(DataValueCategoricalArray{Float32, 1, R}, a) == x
        @test convert(DataValueCategoricalArray{Float64, 1, DefaultRefType}, a) == x
        @test convert(DataValueCategoricalArray{Float32, 1, DefaultRefType}, a) == x
        @test convert(DataValueCategoricalArray{Float64, 1, UInt8}, a) == x
        @test convert(DataValueCategoricalArray{Float32, 1, UInt8}, a) == x

        @test convert(DataValueCategoricalVector, a) == x
        @test convert(DataValueCategoricalVector{Float64}, a) == x
        @test convert(DataValueCategoricalVector{Float32}, a) == x
        @test convert(DataValueCategoricalVector{Float64, R}, a) == x
        @test convert(DataValueCategoricalVector{Float32, R}, a) == x
        @test convert(DataValueCategoricalVector{Float64, DefaultRefType}, a) == x
        @test convert(DataValueCategoricalVector{Float32, DefaultRefType}, a) == x
        @test convert(DataValueCategoricalVector{Float64, UInt8}, a) == x
        @test convert(DataValueCategoricalVector{Float32, UInt8}, a) == x

        @test DataValueCategoricalArray{Float64}(a, ordered=ordered) == x
        @test DataValueCategoricalArray{Float32}(a, ordered=ordered) == x
        @test DataValueCategoricalArray{Float64, 1}(a, ordered=ordered) == x
        @test DataValueCategoricalArray{Float32, 1}(a, ordered=ordered) == x
        @test DataValueCategoricalArray{Float64, 1, R}(a, ordered=ordered) == x
        @test DataValueCategoricalArray{Float32, 1, R}(a, ordered=ordered) == x
        @test DataValueCategoricalArray{Float64, 1, DefaultRefType}(a, ordered=ordered) == x
        @test DataValueCategoricalArray{Float32, 1, DefaultRefType}(a, ordered=ordered) == x

        @test DataValueCategoricalVector(a, ordered=ordered) == x
        @test DataValueCategoricalVector{Float64}(a, ordered=ordered) == x
        @test DataValueCategoricalVector{Float32}(a, ordered=ordered) == x
        @test DataValueCategoricalVector{Float64, R}(a, ordered=ordered) == x
        @test DataValueCategoricalVector{Float32, R}(a, ordered=ordered) == x
        @test DataValueCategoricalVector{Float64, DefaultRefType}(a, ordered=ordered) == x
        @test DataValueCategoricalVector{Float32, DefaultRefType}(a, ordered=ordered) == x

        for (y, R1, R2, comp) in ((a, DefaultRefType, UInt8, true),
                                  (a, DefaultRefType, DefaultRefType, false),
                                  (x, R, UInt8, true),
                                  (x, R, R, false))
            x2 = categorical(y, ordered=ordered)
            @test x2 == collect(y)
            if eltype(y) <: DataValue
                @test isa(x2, DataValueCategoricalVector{Float64, R1})
            else
                @test isa(x2, CategoricalVector{Float64, R1})
            end
            @test isordered(x2) === ordered

            x2 = categorical(y, comp, ordered=ordered)
            @test x2 == collect(y)
            if eltype(y) <: DataValue
                @test isa(x2, DataValueCategoricalVector{Float64, R2})
            else
                @test isa(x2, CategoricalVector{Float64, R2})
            end
            @test isordered(x2) === ordered
        end

        x2 = compress(x)
        @test x2 == x
        @test isordered(x2) === isordered(x)
        @test isa(x2, DataValueCategoricalVector{Float64, UInt8})
        @test levels(x2) == levels(x)

        x2 = copy(x)
        @test x2 == x
        @test isordered(x2) === isordered(x)
        @test typeof(x2) === typeof(x)
        @test levels(x2) == levels(x)

        @test x[1] === DataValue(x.pool.valindex[1])
        @test x[2] === DataValue(x.pool.valindex[2])
        @test x[3] === DataValue(x.pool.valindex[3])
        @test x[4] === DataValue(x.pool.valindex[4])
        @test_throws BoundsError x[5]

        x2 = x[:]
        @test typeof(x2) === typeof(x)
        @test x2 == x
        @test x2 !== x
        @test levels(x2) == levels(x)
        @test levels(x2) !== levels(x)
        @test isordered(x2) == isordered(x)

        x2 = x[1:2]
        @test typeof(x2) === typeof(x)
        @test x2 == DataValue{Float64}[0.0, 0.5]
        @test levels(x2) == levels(x)
        @test levels(x2) !== levels(x)
        @test isordered(x2) == isordered(x)

        x2 = x[1:1]
        @test typeof(x2) === typeof(x)
        @test x2 == DataValue{Float64}[0.0]
        @test levels(x2) == levels(x)
        @test levels(x2) !== levels(x)
        @test isordered(x2) == isordered(x)

        x2 = x[2:1]
        @test typeof(x2) === typeof(x)
        @test isempty(x2)
        @test levels(x2) == levels(x)
        @test levels(x2) !== levels(x)
        @test isordered(x2) == isordered(x)

        x[2] = 1
        @test x[1] === DataValue(x.pool.valindex[1])
        @test x[2] === DataValue(x.pool.valindex[3])
        @test x[3] === DataValue(x.pool.valindex[3])
        @test x[4] === DataValue(x.pool.valindex[4])
        @test levels(x) == unique(a)

        x[1:2] = -1
        @test x[1] === DataValue(x.pool.valindex[5])
        @test x[2] === DataValue(x.pool.valindex[5])
        @test x[3] === DataValue(x.pool.valindex[3])
        @test x[4] === DataValue(x.pool.valindex[4])
        @test levels(x) == vcat(unique(a), -1)

        push!(x, 2.0)
        @test length(x) == 5
        @test isequal(x, DataValueArray([-1.0, -1.0, 1.0, 1.5, 2.0]))
        @test isordered(x) === ordered
        @test levels(x) == [0.0,  0.5,  1.0,  1.5, -1.0,  2.0]

        push!(x, x[1])
        @test length(x) == 6
        @test isequal(x, DataValueArray([-1.0, -1.0, 1.0, 1.5, 2.0, -1.0]))
        @test isordered(x) === ordered
        @test levels(x) == [0.0,  0.5,  1.0,  1.5, -1.0,  2.0]

        append!(x, x)
        @test length(x) == 12
        @test isequal(x, DataValueArray([-1.0, -1.0, 1.0, 1.5, 2.0, -1.0, -1.0, -1.0, 1.0, 1.5, 2.0, -1.0]))
        @test isordered(x) === ordered
        @test levels(x) == [0.0,  0.5,  1.0,  1.5, -1.0,  2.0]

        b = [2.5, 3.0, -3.5]
        y = DataValueCategoricalVector{Float64, R}(b)
        append!(x, y)
        @test length(x) == 15
        @test isequal(x, DataValueArray([-1.0, -1.0, 1.0, 1.5, 2.0, -1.0, -1.0, -1.0, 1.0, 1.5, 2.0, -1.0, 2.5, 3.0, -3.5]))
        @test isordered(x) === ordered
        @test levels(x) == [0.0, 0.5, 1.0, 1.5, -1.0, 2.0, -3.5, 2.5, 3.0]

        empty!(x)
        @test length(x) == 0
        @test isordered(x) === ordered
        @test levels(x) == [0.0, 0.5, 1.0, 1.5, -1.0, 2.0, -3.5, 2.5, 3.0]

        # Matrix with no null values
        for a in (["a" "b" "c"; "b" "a" "c"],
                  DataValue{String}["a" "b" "c"; "b" "a" "c"],
                  DataValueArray(["a" "b" "c"; "b" "a" "c"]))
            na = eltype(a) <: DataValue ? a : convert(Array{DataValue{String}}, a)
            x = DataValueCategoricalMatrix{String, R}(a, ordered=ordered)

            @test x == na
            @test isordered(x) === ordered
            @test levels(x) == map(get, unique(na))
            @test size(x) === (2, 3)
            @test length(x) === 6

            @test convert(DataValueCategoricalArray, x) === x
            @test convert(DataValueCategoricalArray{String}, x) === x
            @test convert(DataValueCategoricalArray{String, 2}, x) === x
            @test convert(DataValueCategoricalArray{String, 2, R}, x) === x
            @test convert(DataValueCategoricalArray{String, 2, DefaultRefType}, x) == x
            @test convert(DataValueCategoricalArray{String, 2, UInt8}, x) == x

            @test convert(DataValueCategoricalMatrix, x) === x
            @test convert(DataValueCategoricalMatrix{String}, x) === x
            @test convert(DataValueCategoricalMatrix{String, R}, x) === x
            @test convert(DataValueCategoricalMatrix{String, DefaultRefType}, x) == x
            @test convert(DataValueCategoricalMatrix{String, UInt8}, x) == x

            @test convert(DataValueCategoricalArray, a) == x
            @test convert(DataValueCategoricalArray{String}, a) == x
            @test convert(DataValueCategoricalArray{String, 2, R}, a) == x
            @test convert(DataValueCategoricalArray{String, 2, DefaultRefType}, a) == x
            @test convert(DataValueCategoricalArray{String, 2, UInt8}, a) == x

            @test convert(DataValueCategoricalMatrix, a) == x
            @test convert(DataValueCategoricalMatrix{String}, a) == x
            @test convert(DataValueCategoricalMatrix{String, R}, a) == x
            @test convert(DataValueCategoricalMatrix{String, DefaultRefType}, a) == x
            @test convert(DataValueCategoricalMatrix{String, UInt8}, a) == x

            @test DataValueCategoricalArray{String}(a, ordered=ordered) == x
            @test DataValueCategoricalArray{String, 2}(a, ordered=ordered) == x
            @test DataValueCategoricalArray{String, 2}(a, ordered=ordered) == x
            @test DataValueCategoricalArray{String, 2, R}(a, ordered=ordered) == x
            @test DataValueCategoricalArray{String, 2, DefaultRefType}(a, ordered=ordered) == x
            @test DataValueCategoricalArray{String, 2, UInt8}(a, ordered=ordered) == x

            @test DataValueCategoricalMatrix(a, ordered=ordered) == x
            @test DataValueCategoricalMatrix{String}(a, ordered=ordered) == x
            @test DataValueCategoricalMatrix{String, R}(a, ordered=ordered) == x
            @test DataValueCategoricalMatrix{String, DefaultRefType}(a, ordered=ordered) == x
            @test DataValueCategoricalMatrix{String, UInt8}(a, ordered=ordered) == x

            for (y, R1, R2, comp) in ((a, DefaultRefType, UInt8, true),
                                      (a, DefaultRefType, DefaultRefType, false),
                                      (x, R, UInt8, true),
                                      (x, R, R, false))
            x2 = categorical(y, ordered=ordered)
            @test x2 == y
            if eltype(y) <: DataValue
                @test isa(x2, DataValueCategoricalMatrix{String, R1})
            else
                @test isa(x2, CategoricalMatrix{String, R1})
            end
            @test isordered(x2) === ordered

            x2 = categorical(y, comp, ordered=ordered)
            @test x2 == y
            if eltype(y) <: DataValue
                @test isa(x2, DataValueCategoricalMatrix{String, R2})
            else
                @test isa(x2, CategoricalMatrix{String, R2})
            end
            @test isordered(x2) === ordered
            end

            x2 = compress(x)
            @test x2 == x
            @test isa(x2, DataValueCategoricalMatrix{String, UInt8})
            @test isordered(x2) === isordered(x)
            @test levels(x2) == levels(x)

            x2 = copy(x)
            @test x2 == x
            @test typeof(x2) === typeof(x)
            @test isordered(x2) === isordered(x)
            @test levels(x2) == levels(x)

            @test x[1] === DataValue(x.pool.valindex[1])
            @test x[2] === DataValue(x.pool.valindex[2])
            @test x[3] === DataValue(x.pool.valindex[2])
            @test x[4] === DataValue(x.pool.valindex[1])
            @test x[5] === DataValue(x.pool.valindex[3])
            @test x[6] === DataValue(x.pool.valindex[3])
            @test_throws BoundsError x[7]

            @test x[1,1] === DataValue(x.pool.valindex[1])
            @test x[2,1] === DataValue(x.pool.valindex[2])
            @test x[1,2] === DataValue(x.pool.valindex[2])
            @test x[2,2] === DataValue(x.pool.valindex[1])
            @test x[1,3] === DataValue(x.pool.valindex[3])
            @test x[2,3] === DataValue(x.pool.valindex[3])
            @test_throws BoundsError x[1,4]
            @test_throws BoundsError x[4,1]
            @test_throws BoundsError x[4,4]

            @test x[1:2,:] == x
            @test typeof(x[1:2,:]) === typeof(x)
            @test x[1:2,1] == DataValue{String}["a", "b"]
            @test typeof(x[1:2,1]) === DataValueCategoricalVector{String, R}

            x[1] = "z"
            @test x[1] === DataValue(x.pool.valindex[4])
            @test x[2] === DataValue(x.pool.valindex[2])
            @test x[3] === DataValue(x.pool.valindex[2])
            @test x[4] === DataValue(x.pool.valindex[1])
            @test x[5] === DataValue(x.pool.valindex[3])
            @test x[6] === DataValue(x.pool.valindex[3])
            @test levels(x) == ["a", "b", "c", "z"]

            x[1,:] = "a"
            @test x[1] === DataValue(x.pool.valindex[1])
            @test x[2] === DataValue(x.pool.valindex[2])
            @test x[3] === DataValue(x.pool.valindex[1])
            @test x[4] === DataValue(x.pool.valindex[1])
            @test x[5] === DataValue(x.pool.valindex[1])
            @test x[6] === DataValue(x.pool.valindex[3])
            @test levels(x) == ["a", "b", "c", "z"]

            x[1,1:2] = "z"
            @test x[1] === DataValue(x.pool.valindex[4])
            @test x[2] === DataValue(x.pool.valindex[2])
            @test x[3] === DataValue(x.pool.valindex[4])
            @test x[4] === DataValue(x.pool.valindex[1])
            @test x[5] === DataValue(x.pool.valindex[1])
            @test x[6] === DataValue(x.pool.valindex[3])
            @test levels(x) == ["a", "b", "c", "z"]
        end


        # Matrix with null values
        for a in (DataValue{String}["a" DataValue() "c"; "b" "a" DataValue()],
                  DataValueArray(DataValue{String}["a" DataValue() "c"; "b" "a" DataValue()]))
            x = DataValueCategoricalMatrix{String, R}(a, ordered=ordered)

            @test x == a
            @test isordered(x) === ordered
            @test levels(x) == map(get, filter(x->!isnull(x), unique(a)))
            @test size(x) === (2, 3)
            @test length(x) === 6

            @test convert(DataValueCategoricalArray, x) === x
            @test convert(DataValueCategoricalArray{String}, x) === x
            @test convert(DataValueCategoricalArray{String, 2}, x) === x
            @test convert(DataValueCategoricalArray{String, 2, R}, x) === x
            @test convert(DataValueCategoricalArray{String, 2, DefaultRefType}, x) == x
            @test convert(DataValueCategoricalArray{String, 2, UInt8}, x) == x

            @test convert(DataValueCategoricalMatrix, x) === x
            @test convert(DataValueCategoricalMatrix{String}, x) === x
            @test convert(DataValueCategoricalMatrix{String, R}, x) === x
            @test convert(DataValueCategoricalMatrix{String, DefaultRefType}, x) == x
            @test convert(DataValueCategoricalMatrix{String, UInt8}, x) == x

            @test convert(DataValueCategoricalArray, a) == x
            @test convert(DataValueCategoricalArray{String}, a) == x
            @test convert(DataValueCategoricalArray{String, 2, R}, a) == x
            @test convert(DataValueCategoricalArray{String, 2, DefaultRefType}, a) == x
            @test convert(DataValueCategoricalArray{String, 2, UInt8}, a) == x

            @test convert(DataValueCategoricalMatrix, a) == x
            @test convert(DataValueCategoricalMatrix{String}, a) == x
            @test convert(DataValueCategoricalMatrix{String, R}, a) == x
            @test convert(DataValueCategoricalMatrix{String, DefaultRefType}, a) == x
            @test convert(DataValueCategoricalMatrix{String, UInt8}, a) == x

            @test DataValueCategoricalArray{String}(a, ordered=ordered) == x
            @test DataValueCategoricalArray{String, 2}(a, ordered=ordered) == x
            @test DataValueCategoricalArray{String, 2}(a, ordered=ordered) == x
            @test DataValueCategoricalArray{String, 2, R}(a, ordered=ordered) == x
            @test DataValueCategoricalArray{String, 2, DefaultRefType}(a, ordered=ordered) == x
            @test DataValueCategoricalArray{String, 2, UInt8}(a, ordered=ordered) == x

            @test DataValueCategoricalMatrix(a, ordered=ordered) == x
            @test DataValueCategoricalMatrix{String}(a, ordered=ordered) == x
            @test DataValueCategoricalMatrix{String, R}(a, ordered=ordered) == x
            @test DataValueCategoricalMatrix{String, DefaultRefType}(a, ordered=ordered) == x
            @test DataValueCategoricalMatrix{String, UInt8}(a, ordered=ordered) == x

            for (y, R1, R2, comp) in ((a, DefaultRefType, UInt8, true),
                                      (a, DefaultRefType, DefaultRefType, false),
                                      (x, R, UInt8, true),
                                      (x, R, R, false))
                x2 = categorical(y, ordered=ordered)
                @test x2 == y
                @test isa(x2, DataValueCategoricalMatrix{String, R1})
                @test isordered(x2) === ordered

                x2 = categorical(y, comp, ordered=ordered)
                @test x2 == y
                @test isa(x2, DataValueCategoricalMatrix{String, R2})
                @test isordered(x2) === ordered
            end

            x2 = compress(x)
            @test x2 == x
            @test isa(x2, DataValueCategoricalMatrix{String, UInt8})
            @test isordered(x2) === isordered(x)
            @test levels(x2) == levels(x)

            x2 = copy(x)
            @test x2 == x
            @test typeof(x2) === typeof(x)
            @test isordered(x2) === isordered(x)
            @test levels(x2) == levels(x)

            @test x[1] === DataValue(x.pool.valindex[1])
            @test x[2] === DataValue(x.pool.valindex[2])
            @test x[3] === eltype(x)()
            @test x[4] === DataValue(x.pool.valindex[1])
            @test x[5] === DataValue(x.pool.valindex[3])
            @test x[6] === eltype(x)()
            @test_throws BoundsError x[7]

            @test x[1,1] === DataValue(x.pool.valindex[1])
            @test x[2,1] === DataValue(x.pool.valindex[2])
            @test x[1,2] === eltype(x)()
            @test x[2,2] === DataValue(x.pool.valindex[1])
            @test x[1,3] === DataValue(x.pool.valindex[3])
            @test x[2,3] === eltype(x)()
            @test_throws BoundsError x[1,4]
            @test_throws BoundsError x[4,1]
            @test_throws BoundsError x[4,4]

            x2 = x[1:2,:]
            @test typeof(x2) === typeof(x)
            @test x2 == x
            @test levels(x2) == levels(x)
            @test levels(x2) !== levels(x)
            @test isordered(x2) == isordered(x)

            x2 = x[:,[1, 3]]
            @test typeof(x2) === typeof(x)
            @test x2 == DataValue{String}["a" "c"; "b" DataValue()]
            @test levels(x2) == levels(x)
            @test levels(x2) !== levels(x)
            @test isordered(x2) == isordered(x)

            x2 = x[1:1,2]
            @test isa(x2, DataValueCategoricalVector{String, R})
            @test x2 == [DataValue()]
            @test levels(x2) == levels(x)
            @test levels(x2) !== levels(x)
            @test isordered(x2) == isordered(x)

            x2 = x[1:0,:]
            @test typeof(x2) === typeof(x)
            @test size(x2) == (0,3)
            @test levels(x2) == levels(x)
            @test levels(x2) !== levels(x)
            @test isordered(x2) == isordered(x)

            @test_throws BoundsError x[1:4, :]
            @test_throws BoundsError x[1:1, -1:1]
            @test_throws BoundsError x[4, :]

            x[1] = "z"
            @test x[1] === DataValue(x.pool.valindex[4])
            @test x[2] === DataValue(x.pool.valindex[2])
            @test x[3] === eltype(x)()
            @test x[4] === DataValue(x.pool.valindex[1])
            @test x[5] === DataValue(x.pool.valindex[3])
            @test x[6] === eltype(x)()
            @test levels(x) == ["a", "b", "c", "z"]

            x[1,:] = "a"
            @test x[1] === DataValue(x.pool.valindex[1])
            @test x[2] === DataValue(x.pool.valindex[2])
            @test x[3] === DataValue(x.pool.valindex[1])
            @test x[4] === DataValue(x.pool.valindex[1])
            @test x[5] === DataValue(x.pool.valindex[1])
            @test x[6] === eltype(x)()
            @test levels(x) == ["a", "b", "c", "z"]

            x[1,1:2] = DataValue("z")
            @test x[1] === DataValue(x.pool.valindex[4])
            @test x[2] === DataValue(x.pool.valindex[2])
            @test x[3] === DataValue(x.pool.valindex[4])
            @test x[4] === DataValue(x.pool.valindex[1])
            @test x[5] === DataValue(x.pool.valindex[1])
            @test x[6] === eltype(x)()
            @test levels(x) == ["a", "b", "c", "z"]

            x[1] = DataValue()
            @test x[1] === eltype(x)()
            @test x[2] === DataValue(x.pool.valindex[2])
            @test x[3] === DataValue(x.pool.valindex[4])
            @test x[4] === DataValue(x.pool.valindex[1])
            @test x[5] === DataValue(x.pool.valindex[1])
            @test x[6] === eltype(x)()
            @test levels(x) == ["a", "b", "c", "z"]

            x[1,1:2] = DataValue()
            @test x[1] === eltype(x)()
            @test x[2] === DataValue(x.pool.valindex[2])
            @test x[3] === eltype(x)()
            @test x[4] === DataValue(x.pool.valindex[1])
            @test x[5] === DataValue(x.pool.valindex[1])
            @test x[6] === eltype(x)()
            @test levels(x) == ["a", "b", "c", "z"]

            x[:,2] = DataValue()
            @test x[1] === eltype(x)()
            @test x[2] === DataValue(x.pool.valindex[2])
            @test x[3] === eltype(x)()
            @test x[4] === eltype(x)()
            @test x[5] === DataValue(x.pool.valindex[1])
            @test x[6] === eltype(x)()
            @test levels(x) == ["a", "b", "c", "z"]

            x[1,2] = DataValue("a")
            @test x[1] === eltype(x)()
            @test x[2] === DataValue(x.pool.valindex[2])
            @test x[3] === DataValue(x.pool.valindex[1])
            @test x[4] === eltype(x)()
            @test x[5] === DataValue(x.pool.valindex[1])
            @test x[6] === eltype(x)()
            @test levels(x) == ["a", "b", "c", "z"]

            x[2,1] = DataValue()
            @test x[1] === eltype(x)()
            @test x[2] === eltype(x)()
            @test x[3] === DataValue(x.pool.valindex[1])
            @test x[4] === eltype(x)()
            @test x[5] === DataValue(x.pool.valindex[1])
            @test x[6] === eltype(x)()
            @test levels(x) == ["a", "b", "c", "z"]

            # Constructor with values plus missingness array
            x = DataValueCategoricalArray(1:3, [true, false, true], ordered=ordered)
            @test x == DataValue{Int}[DataValue(), 2, DataValue()]
            @test isordered(x) == ordered
            @test levels(x) == [2]

            x = DataValueCategoricalVector(1:3, [true, false, true], ordered=ordered)
            @test x == DataValue{Int}[DataValue(), 2, DataValue()]
            @test isordered(x) === ordered
            @test levels(x) == [2]

            x = DataValueCategoricalMatrix([1 2; 3 4], [true false; false true],
                                          ordered=ordered)
            @test x == DataValue{Int}[DataValue() 2; 3 DataValue()]
            @test isordered(x) === ordered
            @test levels(x) == [2, 3]
        end


        # Uninitialized array
        v = Any[DataValueCategoricalArray(2, ordered=ordered),
                DataValueCategoricalArray{String}(2, ordered=ordered),
                DataValueCategoricalArray{String, 1}(2, ordered=ordered),
                DataValueCategoricalArray{String, 1, R}(2, ordered=ordered),
                DataValueCategoricalVector(2, ordered=ordered),
                DataValueCategoricalVector{String}(2, ordered=ordered),
                DataValueCategoricalVector{String, R}(2, ordered=ordered),
                DataValueCategoricalArray(2, 3, ordered=ordered),
                DataValueCategoricalArray{String}(2, 3, ordered=ordered),
                DataValueCategoricalArray{String, 2}(2, 3, ordered=ordered),
                DataValueCategoricalArray{String, 2, R}(2, 3, ordered=ordered),
                DataValueCategoricalMatrix(2, 3, ordered=ordered),
                DataValueCategoricalMatrix{String}(2, 3, ordered=ordered),
                DataValueCategoricalMatrix{String, R}(2, 3, ordered=ordered)]

        for x in v
            @test isordered(x) === ordered
            @test isnull(x[1])
            @test isnull(x[2])
            @test levels(x) == []

            x2 = compress(x)
            @test x2 == x
            @test isa(x2, DataValueCategoricalArray{String, ndims(x), UInt8})
            @test isordered(x2) === isordered(x)
            @test levels(x2) == []

            x2 = copy(x)
            @test x2 == x
            @test typeof(x2) === typeof(x)
            @test isordered(x2) === isordered(x)
            @test levels(x2) == []

            x[1] = "c"
            @test x[1] === DataValue(x.pool.valindex[1])
            @test isnull(x[2])
            @test levels(x) == ["c"]

            x[1] = "a"
            @test x[1] === DataValue(x.pool.valindex[2])
            @test isnull(x[2])
            @test levels(x) == ["c", "a"]

            x[2] = DataValue()
            @test x[1] === DataValue(x.pool.valindex[2])
            @test x[2] === eltype(x)()
            @test levels(x) == ["c", "a"]

            x[1] = DataValue("b")
            @test x[1] === DataValue(x.pool.valindex[3])
            @test x[2] === eltype(x)()
            @test levels(x) == ["c", "a", "b"]
        end
    end
end

# Test vcat with nulls
ca1 = DataValueCategoricalArray(["a", "b"], [false, true])
ca2 = DataValueCategoricalArray(["b", "a"], [true, false])
r = vcat(ca1, ca2)
@test r == DataValueCategoricalArray(["a", "", "", "a"], [false, true, true, false])
@test levels(r) == ["a"]
@test !isordered(r)
ordered!(ca1,true)
@test !isordered(vcat(ca1, ca2))
ordered!(ca2,true)
@test isordered(vcat(ca1, ca2))
ordered!(ca1,false)
@test !isordered(vcat(ca1, ca2))

# vcat with all nulls
ca1 = DataValueCategoricalArray(["a", "b"], [false, true])
ca2 = DataValueCategoricalArray(["a", "b"], [true, true])
r = vcat(ca1, ca2)
@test isequal(r, DataValueCategoricalArray(["a", "", "", ""], [false, true, true, true]))
@test levels(r) == ["a"]
@test !isordered(r)

# vcat with all nulls preserves isordered
# needed for instance when expanding an array with nulls
# such as vcat of DataFrame with missing columns
ordered!(ca1, true)
@test isempty(levels(ca2))
r = vcat(ca1, ca2)
@test isordered(r)

# vcat with all empty array
ca1 = DataValueCategoricalArray(0)
ca2 = DataValueCategoricalArray(["a", "b"], [true, false])
r = vcat(ca1, ca2)
@test isequal(r, DataValueCategoricalArray(["", "b"], [true, false]))
@test levels(r) == ["b"]
@test !isordered(r)

# vcat with all nulls and empty
ca1 = DataValueCategoricalArray(0)
ca2 = DataValueCategoricalArray(["a", "b"], [true, true])
r = vcat(ca1, ca2)
@test isequal(r, DataValueCategoricalArray(["", ""], [true, true]))
@test levels(r) == String[]
@test !isordered(r)

ordered!(ca1, true)
@test isempty(levels(ca2))
r = vcat(ca1, ca2)
@test isordered(r)

ca1 = DataValueCategoricalArray(["a", "b"], [false, true])
ca2 = DataValueCategoricalArray{String}(2)
ordered!(ca1, true)
@test isempty(levels(ca2))
r = vcat(ca1, ca2)
@test isequal(r, DataValueCategoricalArray(["a", "", "", ""], [false, true, true, true]))
@test isordered(r)


# Test unique() and levels()

x = DataValueCategoricalArray(["Old", "Young", "Middle", DataValue(), "Young"])
@test levels(x) == ["Middle", "Old", "Young"]
@test unique(x) == DataValueArray(["Middle", "Old", "Young", DataValue()])
@test levels!(x, ["Young", "Middle", "Old"]) === x
@test levels(x) == ["Young", "Middle", "Old"]
@test unique(x) == DataValueArray(["Young", "Middle", "Old", DataValue()])
@test levels!(x, ["Young", "Middle", "Old", "Unused"]) === x
@test levels(x) == ["Young", "Middle", "Old", "Unused"]
@test unique(x) == DataValueArray(["Young", "Middle", "Old", DataValue()])
@test levels!(x, ["Unused1", "Young", "Middle", "Old", "Unused2"]) === x
@test levels(x) == ["Unused1", "Young", "Middle", "Old", "Unused2"]
@test unique(x) == DataValueArray(["Young", "Middle", "Old", DataValue()])

x = DataValueCategoricalArray([DataValue{String}()])
@test isa(levels(x), Vector{String}) && isempty(levels(x))
@test unique(x) == DataValueArray{String}(1)
@test levels!(x, ["Young", "Middle", "Old"]) === x
@test levels(x) == ["Young", "Middle", "Old"]
@test unique(x) == DataValueArray{String}(1)

# To test short-circuit after 1000 elements
x = DataValueCategoricalArray(repeat(1:1500, inner=10))
@test levels(x) == collect(1:1500)
@test unique(x) == DataValueArray(1:1500)
@test levels!(x, [1600:-1:1; 2000]) === x
x[3] = DataValue()
@test levels(x) == [1600:-1:1; 2000]
@test unique(x) == DataValueArray([1500:-1:3; 2; 1; DataValue()])

end
