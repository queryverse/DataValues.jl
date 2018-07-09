using Test
using DataValues

@testset "DataValueArray: SubArrays" begin

nd = rand(3:5)
sz = [ rand(3:10) for i in 1:nd ]
X = DataValueArray(rand(sz...), rand(Bool, sz...))

I = [ rand(1:sz[i]) for i in 1:nd ]
H = [ rand(1:sz[i]) for i in 1:nd ]

for i in 1:nd
    J = [ (x->x==i ? I[x] : Colon())(j) for j in 1:nd ]
    S = view(X, J...)
    H = [ (x->x==i ? I[x] : rand(1:sz[x]))(j) for j in 1:nd ]
    _H = H[findall(x->x!=i, collect(1:nd))]

    @test values(S, _H...) == X.values[H...]
    @test isna(S, _H...) == X.isna[H...]
    @test any(isna, S) == any(isna, X[J...])
end

end
