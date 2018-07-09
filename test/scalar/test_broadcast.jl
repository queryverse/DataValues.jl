using DataValues
using Test

@testset "Broadcast" begin

dv1 = DataValue(3)
dv2 = DataValue(5)
dv3 = DataValue{Int}()

@test log.(dv1) .+ dv2 == DataValue(log(3) + 5)
@test log.(dv1) .+ dv2 .- dv3 == DataValue{Float64}()

@test dv1 .+ 2 == DataValue(5)
@test 2 .+ dv1 == DataValue(5)

# TODO 0.7 reenable
# @test dv1 .+ Nullable(2) == DataValue(5)
# @test Nullable(2) .+ dv1 == DataValue(5)

@test dv1 .+ (1,3) == (DataValue(4), DataValue(6))
@test (1,3) .+ dv1 == (DataValue(4), DataValue(6))

end
