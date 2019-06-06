using DataValues
using Test
using Dates
using InteractiveUtils

@testset "Core" begin

@testset "Missing integration" begin

@test DataValue(missing) == NA
@test DataValue{Int}(missing) == DataValue{Int}()
@test convert(Missing, NA) === missing

end

@testset "conversion" begin

@test DataValue{Float64}(2) == DataValue(2.)
@test convert(Union{Missing,Int}, DataValue(2)) == 2
@test convert(Union{Missing,Int}, DataValue{Int}()) === missing
@test convert(Union{Missing,Int}, NA) === missing

@test convert(DataValue{Int}, DataValue(3)) == DataValue(3)

end

@testset "isna" begin

@test DataValues.isna(NA) == true
@test DataValues.isna(DataValue()) == true
@test DataValues.isna(DataValue{Int}()) == true
@test DataValues.isna(DataValue(3)) == false

end

@testset "Show" begin

io = IOBuffer()
show(IOContext(io, :compact => true), DataValue(3))
@test String(take!(io)) == "3"

io = IOBuffer()
show(IOContext(io, :compact => true), DataValue{Int}())
@test String(take!(io)) == "#NA"

end

@testset "Unpack" begin

@test get(DataValue("test"), "default") == "test"
@test get(DataValue{String}(), "default") == "default"

@test DataValues.unsafe_get(DataValue(3)) == 3

end

@testset "Hasvalue" begin

@test hasvalue(DataValue(3)) == true
@test hasvalue(DataValue{Int}()) == false

end

@testset "zero" begin

@test zero(DataValue{Int}) == DataValue(0)
@test zero(DataValue(3)) == DataValue(0)

@test zero(DataValue{Float64}) == DataValue(0.)
@test zero(DataValue(3.)) == DataValue(0.)

for T in (subtypes(Dates.DatePeriod)..., subtypes(Dates.TimePeriod)...)
    @test zero(DataValue{T}()) == T(0)
end

@test zero(DataValue(Year(3))) == zero(Year)
@test zero(DataValue{Year}) == zero(Year)

end

@testset "Comparisons" begin

@test (DataValue(3) == NA) == false
@test (DataValue{Int}() == NA) == true

@test (NA == DataValue(3)) == false
@test (NA == DataValue{Int}()) == true

@test (DataValue(3) != NA) == true
@test (DataValue{Int}() != NA) == false

@test (NA != DataValue(3)) == true
@test (NA != DataValue{Int}()) == false

@test (NA == NA) == true

@test isless(DataValue{Int}(), DataValue{Int}()) == false
@test isless(DataValue{Int}(), DataValue{Int}(3)) == false
@test isless(DataValue{Int}(3), DataValue{Int}()) == true
@test isless(DataValue{Int}(3), DataValue{Int}(5)) == true

@test isless(3, DataValue{Int}()) == true
@test isless(3, DataValue{Int}(2)) == false

@test isless(DataValue{Int}(), 3) == false
@test isless(DataValue{Int}(2), 3) == true

@test isless(NA, NA) == false
@test isless(3, NA) == true
@test isless(NA, 3) == false

end

@testset "Promotion" begin

@test promote(DataValue(3), 5) == (DataValue(3), DataValue(5))
@test promote(DataValue(3), 5.) == (DataValue(3.), DataValue(5.))

end

# 3VL

@test DataValue(true) & DataValue(true) == DataValue(true)
@test DataValue(true) & DataValue(false) == DataValue(false)
@test DataValue(true) & DataValue{Bool}() == DataValue{Bool}()
@test DataValue(false) & DataValue(true) == DataValue(false)
@test DataValue(false) & DataValue(false) == DataValue(false)
@test DataValue(false) & DataValue{Bool}() == DataValue(false)
@test DataValue{Bool}() & DataValue(true) == DataValue{Bool}()
@test DataValue{Bool}() & DataValue(false) == DataValue(false)
@test DataValue{Bool}() & DataValue{Bool}() == DataValue{Bool}()

@test true & DataValue(true) == DataValue(true)
@test true & DataValue(false) == DataValue(false)
@test true & DataValue{Bool}() == DataValue{Bool}()
@test false & DataValue(true) == DataValue(false)
@test false & DataValue(false) == DataValue(false)
@test false & DataValue{Bool}() == DataValue(false)

@test DataValue(true) & true == DataValue(true)
@test DataValue(true) & false == DataValue(false)
@test DataValue(false) & true == DataValue(false)
@test DataValue(false) & false == DataValue(false)
@test DataValue{Bool}() & true == DataValue{Bool}()
@test DataValue{Bool}() & false == DataValue(false)

@test DataValue(true) | DataValue(true) == DataValue(true)
@test DataValue(true) | DataValue(false) == DataValue(true)
@test DataValue(true) | DataValue{Bool}() == DataValue(true)
@test DataValue(false) | DataValue(true) == DataValue(true)
@test DataValue(false) | DataValue(false) == DataValue(false)
@test DataValue(false) | DataValue{Bool}() == DataValue{Bool}()
@test DataValue{Bool}() | DataValue(true) == DataValue(true)
@test DataValue{Bool}() | DataValue(false) == DataValue{Bool}()
@test DataValue{Bool}() | DataValue{Bool}() == DataValue{Bool}()

@test true | DataValue(true) == DataValue(true)
@test true | DataValue(false) == DataValue(true)
@test true | DataValue{Bool}() == DataValue(true)
@test false | DataValue(true) == DataValue(true)
@test false | DataValue(false) == DataValue(false)
@test false | DataValue{Bool}() == DataValue{Bool}()

@test DataValue(true) | true == DataValue(true)
@test DataValue(true) | false == DataValue(true)
@test DataValue(false) | true == DataValue(true)
@test DataValue(false) | false == DataValue(false)
@test DataValue{Bool}() | true == DataValue(true)
@test DataValue{Bool}() | false == DataValue{Bool}()

@test !DataValue(true) == DataValue(false)
@test !DataValue(false) == DataValue(true)
@test !DataValue{Bool}() == DataValue{Bool}()

# NA comparisons
# @test (DataValue(5)==NA) == false
# @test (DataValue{Int}()==NA) == true
# @test (NA==DataValue(5)) == false
# @test (NA==DataValue{Int}()) == true

# @test (DataValue(5)!=NA) == true
# @test (DataValue{Int}()!=NA) == false
# @test (NA!=DataValue(5)) == true
# @test (NA!=DataValue{Int}()) == false

:+, :-, :!, :~
@test +DataValue(1) == DataValue(+1)
@test +DataValue{Int}() == DataValue{Int}()
@test -DataValue(1) == DataValue(-1)
@test -DataValue{Int}() == DataValue{Int}()
@test ~DataValue(1) == DataValue(~1)
@test ~DataValue{Int}() == DataValue{Int}()

# TODO add ^, / back
for op in (:+, :-, :*, :%, :&, :|, :<<, :>>)
    @eval begin
        @test $op(DataValue(3), DataValue(5)) == DataValue($op(3, 5))
        @test $op(DataValue{Int}(), DataValue(5)) == DataValue{Int}()
        @test $op(DataValue(3), DataValue{Int}()) == DataValue{Int}()
        @test $op(DataValue{Int}(), DataValue{Int}()) == DataValue{Int}()

        @test $op(DataValue{Int}(3), 5) == DataValue($op(3, 5))
        @test $op(3, DataValue{Int}(5)) == DataValue($op(3, 5))
        @test $op(DataValue{Int}(), 5) == DataValue{Int}()
        @test $op(3, DataValue{Int}()) == DataValue{Int}()
    end
end

@test DataValue(Int16(4)) / DataValue(Int32(2)) == DataValue(2.)
@test DataValue{Int16}() / DataValue(Int32(2)) == DataValue{Float64}()
@test DataValue(Int16(4)) / DataValue{Int32}() == DataValue{Float64}()
@test DataValue{Int16}() / DataValue{Int32}() == DataValue{Float64}()
@test Int16(4) / DataValue(Int32(2)) == DataValue(2.)
@test Int16(4) / DataValue{Int32}() == DataValue{Float64}()
@test DataValue{Int16}(4) / Int32(2) == DataValue{Float64}(2.)
@test DataValue{Int16}() / Int32(2) == DataValue{Float64}()

@test DataValue(3)^2 == DataValue(9)
@test DataValue{Int}()^2 == DataValue{Int}()

@test DataValue(3) == DataValue(3)
@test !(DataValue(3) == DataValue(4))
@test !(DataValue{Int}() == DataValue(3))
@test !(DataValue{Float64}() == DataValue(3))
@test !(DataValue(3) == DataValue{Int}())
@test !(DataValue(3) == DataValue{Float64}())
@test DataValue{Int}() == DataValue{Int}()
@test DataValue{Int}() == DataValue{Float64}()

@test DataValue(3) == 3
@test 3 == DataValue(3)
@test !(DataValue(3) == 4)
@test !(4 == DataValue(3))
@test !(DataValue{Int}() == 3)
@test !(3 == DataValue{Int}())

@test !(DataValue(3) != DataValue(3))
@test DataValue(3) != DataValue(4)
@test DataValue{Int}() != DataValue(3)
@test DataValue{Float64}() != DataValue(3)
@test DataValue(3) != DataValue{Int}()
@test DataValue(3) != DataValue{Float64}()
@test !(DataValue{Int}() != DataValue{Int}())
@test !(DataValue{Int}() != DataValue{Float64}())

@test !(DataValue(3) != 3)
@test !(3 != DataValue(3))
@test DataValue(3) != 4
@test 4 != DataValue(3)
@test DataValue{Int}() != 3
@test 3 != DataValue{Int}()

@test DataValue(4) > DataValue(3)
@test !(DataValue(3) > DataValue(4))
@test !(DataValue(4) > DataValue{Int}())
@test !(DataValue{Int}() > DataValue(3))
@test !(DataValue{Int}() > DataValue{Int}())

@test DataValue(4) > 3
@test !(DataValue(3) > 4)
@test !(DataValue{Int}() > 3)

@test 4 > DataValue(3)
@test !(3 > DataValue(4))
@test !(4 > DataValue{Int}())

@test lowercase(DataValue("TEST"))==DataValue("test")
@test lowercase(DataValue{String}())==DataValue{String}()

@test DataValue("TEST")[2:end]==DataValue("EST")
@test DataValue{String}()[2:end]==DataValue{String}()

@test length(DataValue("TEST"))==DataValue(4)
@test length(DataValue{String}())==DataValue{Int}()

@test DataValue{Int} == DataValue{Int}
@test DataValue(43) == DataValue(43)

io = IOBuffer()

show(io, DataValue(enum_val_a))
@test String(take!(io)) == "DataValue{TestEnum}(enum_val_a)"

end
