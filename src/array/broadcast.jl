Base.Broadcast.promote_containertype(::Type{DataValueArray}, ::Type{DataValueArray}) = DataValueArray
Base.Broadcast.promote_containertype(::Type{Array}, ::Type{DataValueArray}) = DataValueArray
Base.Broadcast.promote_containertype(::Type{DataValueArray}, ::Type{Array}) = DataValueArray
Base.Broadcast.promote_containertype(::Type{DataValueArray}, _) = DataValueArray
Base.Broadcast.promote_containertype(_, ::Type{DataValueArray}) = DataValueArray

Base.Broadcast._containertype(::Type{<:DataValueArray}) = DataValueArray

Base.Broadcast.broadcast_indices(::Type{DataValueArray}, A) = indices(A)

@inline function broadcast_t(f, ::Type{T}, shape, A, Bs...) where {T}
    dest = Base.Broadcast.containertype(A, Bs...){eltype(T)}(Base.index_lengths(shape...))
    return broadcast!(f, dest, A, Bs...)
end

# This is mainly to handle isna.(x) since isna is probably the only
# function that can guarantee that NAs will never propagate
@inline function broadcast_t(f, ::Type{Bool}, shape, A, Bs...)
    dest = similar(BitArray, shape)
    return broadcast!(f, dest, A, Bs...)
end

# This one is almost identical to the version in Base and can hopefully be
# removed at some point. The main issue in Base is that it tests for
# isleaftype(T) which is false for Union{T,NAtype}. If the test in Base
# can be modified to cover simple unions of leaftypes then this method
# can probably be deleted and the two _t methods adjusted to match the Base
# invokation from Base.Broadcast.broadcast_c
@inline function Base.Broadcast.broadcast_c{S<:DataValueArray}(f, ::Type{S}, A, Bs...)
    T     = Base.Broadcast._broadcast_eltype(f, A, Bs...)
    shape = Base.Broadcast.broadcast_indices(A, Bs...)
    return broadcast_t(f, T, shape, A, Bs...)
end

# # This one is much faster than normal broadcasting but the method won't get called
# # in fusing operations like (!).(isna.(x))
# Base.broadcast(::typeof(isna), da::DataArray) = copy(da.na)
