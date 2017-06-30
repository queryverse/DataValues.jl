using DataValues
using Base.Test

@testset "DataValues" begin

time_a = ?("14:00:00")
date_a = ?("01/01/2012")

@test DateTime(time_a,"HH:MM:SS") == DataValue(DateTime("14:00:00", "HH:MM:SS"))
@test DateTime(DataValue{String}(), "HH:MM:SS") == DataValue{DateTime}()

@test Date(date_a,"mm/dd/yyyy") == DataValue(Date("01/01/2012", "mm/dd/yyyy"))
@test Date(DataValue{String}(), "mm/dd/yyyy") == DataValue{Date}()

end
