@testset "Show" begin

using Base.Test
using DataArrays2

io = IOBuffer()
disp = TextDisplay(IOBuffer())

for typ in (Float64, Int, UInt, Char)
    for l in (10, 100, 1000)
        A1 = rand(typ, l)
        M1 = rand(Bool, l)
        X1 = DataArray2(A1)
        Y1 = DataArray2(A1, M1)

        show(io, X1)
        show(io, Y1)
        display(disp, X1)
        display(disp, Y1)
        typeof(X1)
        typeof(Y1)
    end

    for m in (10, 100), n in (10, 100)
        A2 = rand(typ, m, n)
        M2 = rand(Bool, m, n)
        X2 = DataArray2(A2)
        Y2 = DataArray2(A2, M2)

        show(io, X2)
        show(io, Y2)
        display(disp, X2)
        display(disp, Y2)
        typeof(X2)
        typeof(Y2)
    end

    nd = rand(3:5)
    sz = [ rand(3:5) for i in 1:nd ]
    A3 = rand(typ, sz...)
    M3 = rand(Bool, sz...)
    X3 = DataArray2(A3)
    Y3 = DataArray2(A3, M3)

    show(io, X3)
    show(io, Y3)
    display(disp, X3)
    display(disp, Y3)
    typeof(X3)
    typeof(Y3)

    X = DataArray2{typ}()
    show(io, X)
    display(disp, X)
    typeof(X)
end

end
