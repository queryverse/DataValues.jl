using DataValues
using Test

@testset "Broadcast" begin

dv1 = DataValue(3)
dv2 = DataValue(5)
dv3 = DataValue{Int}()

@test log.(Ref(dv1)) .+ Ref(dv2) == DataValue(log(3) + 5)
@test log.(Ref(dv1)) .+ Ref(dv2) .- Ref(dv3) == DataValue{Float64}()

@test Ref(dv1) .+ 2 == DataValue(5)
@test 2 .+ Ref(dv1) == DataValue(5)

@test Ref(dv1) .+ (1,3) == (DataValue(4), DataValue(6))
@test (1,3) .+ Ref(dv1) == (DataValue(4), DataValue(6))

end
