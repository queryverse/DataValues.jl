using DataValues
using Base.Test

@testset "Broadcast" begin

dv1 = DataValue(3)
dv2 = DataValue(5)
dv3 = DataValue{Int}()

@test log.(dv1) .+ dv2 == DataValue(log(3) + 5)
@test log.(dv1) .+ dv2 .- dv3 == DataValue{Float64}()

end
