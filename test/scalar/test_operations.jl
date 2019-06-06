using DataValues
using Test
using Dates

@testset "Operations" begin

time_a = DataValue("14:00:00")
date_a = DataValue("01/01/2012")

@test DateTime(time_a,"HH:MM:SS") == DataValue(DateTime("14:00:00", "HH:MM:SS"))
@test DateTime(DataValue{String}(), "HH:MM:SS") == DataValue{DateTime}()

@test Date(date_a,"mm/dd/yyyy") == DataValue(Date("01/01/2012", "mm/dd/yyyy"))
@test Date(DataValue{String}(), "mm/dd/yyyy") == DataValue{Date}()

@test abs(DataValue(3.)) == DataValue(3.)
@test abs(DataValue{Float64}()) == DataValue{Float64}()

@test log(DataValue(3.)) == DataValue(log(3.))
@test log(DataValue{Float64}()) == DataValue{Float64}()

@test min(DataValue(3), DataValue(2)) == DataValue(2)
@test min(DataValue(3), DataValue{Int}()) == DataValue{Int}()
@test min(DataValue{Int}(), DataValue(3)) == DataValue{Int}()
@test min(DataValue{Int}(), DataValue{Int}()) == DataValue{Int}()

@test min(3, DataValue(2)) == DataValue(2)
@test min(3, DataValue{Int}()) == DataValue{Int}()
@test min(DataValue{Int}(), 3) == DataValue{Int}()
@test min(DataValue{Int}(2), 3) == DataValue{Int}(2)
@test min(DataValue{Int}(), DataValue{Int}()) == DataValue{Int}()

@test DataValue(3) + DataValue(2.) == DataValue(5.)
@test DataValue(3) + DataValue{Float64}() == DataValue{Float64}()
@test DataValue{Int}() + DataValue(2.) == DataValue{Float64}()
@test DataValue{Int}() + DataValue{Float64}() == DataValue{Float64}()
@test DataValue(3) + NA == DataValue{Int}()
@test NA + DataValue(2.) == DataValue{Float64}()
@test NA + NA == NA

@test 3 + DataValue(2.) == DataValue(5.)
@test 3 + DataValue{Float64}() == DataValue{Float64}()
@test 3 + NA == DataValue{Int}()

@test DataValue(3) + 2. == DataValue(5.)
@test DataValue{Int}() + 2. == DataValue{Float64}()
@test NA + 2. == DataValue{Float64}()

end

