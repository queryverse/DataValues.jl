using Compat

@compat DataSubArray2{T,N,P<:DataValueArray,IV,LD} = SubArray{T,N,P,IV,LD}

@inline function Base.isnull(V::DataSubArray2, I::Int...)
    @boundscheck checkbounds(V, I...)
    @inbounds return V.parent.isnull[Base.reindex(V, V.indexes, I)...]
end

@inline function Base.values(V::DataSubArray2, I::Int...)
    @boundscheck checkbounds(V, I...)
    @inbounds return V.parent.values[Base.reindex(V, V.indexes, I)...]
end

@compat FastDataSubArray2{T,N,P<:DataValueArray,IV} = SubArray{T,N,P,IV,true}

@inline function Base.isnull(V::FastDataSubArray2, i::Int)
    @boundscheck checkbounds(V, i)
    @inbounds return V.parent.isnull[V.first_index + V.stride1*i-1]
end

@inline function Base.values(V::FastDataSubArray2, i::Int)
    @boundscheck checkbounds(V, i)
    @inbounds return V.parent.values[V.first_index + V.stride1*i-1]
end

# We can avoid a multiplication if the first parent index is a Colon or UnitRange
@compat FastDataContiguousSubArray2{T,N,P<:DataValueArray,I<:Tuple{Union{Colon, UnitRange}, Vararg{Any}}} = SubArray{T,N,P,I,true}

@inline function Base.isnull(V::FastDataContiguousSubArray2, i::Int)
    @boundscheck checkbounds(V, i)
    @inbounds return V.parent.isnull[V.first_index + i - 1]
end

@inline function Base.values(V::FastDataContiguousSubArray2, i::Int)
    @boundscheck checkbounds(V, i)
    @inbounds return V.parent.values[V.first_index + i - 1]
end
