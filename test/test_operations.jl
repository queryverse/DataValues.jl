using DataValues
using Base.Test

@testset "DataValues" begin

date_a = ?("14:00:00")

@test DateTime(date_a,"HH:MM:SS") == DataValue(DateTime("14:00:00", "HH:MM:SS"))

end
