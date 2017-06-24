using BenchmarkTools, NullableArrays

immutable Array{T,B}
    data::T
    mask::B
end

data = rand(10_000_000)

v1 = Array(data, fill(true, 10_000_000))
v2 = Array(data, fill(UInt64(0), Int(10_000_000/64)))
v3 = NullableArray(data, fill(false, 10_000_000))

function foo1!(z,x,y)
    @inbounds @simd for i=1:length(z.mask)
        z.mask[i] = x.mask[i] | y.mask[i]
    end

    @inbounds @simd for i=1:length(z.data)
        z.data[i] = x.data[i] + y.data[i]
    end
end

function foo2!(z,x,y)
    broadcast!(+, z, x, y)
end


t1 = Array(rand(10_000_000), fill(true, 10_000_000))
t2 = Array(rand(10_000_000), fill(UInt64(0), Int(10_000_000/64)))
t3 = NullableArray(rand(10_000_000), fill(false, 10_000_000))

@benchmark foo1!(t1, v1, v1)
@benchmark foo1!(t2, v2, v2)
@benchmark foo2!(t3, v3, v3)