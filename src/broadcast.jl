using Base.Broadcast: check_broadcast_indices, broadcast_indices

Base.@pure nullable_eltypestuple(a) = Tuple{eltype(eltype(a))}
Base.@pure nullable_eltypestuple(T::Type) = Tuple{Type{eltype(T)}}
Base.@pure nullable_eltypestuple(a, b...) =
    Tuple{nullable_eltypestuple(a).types..., nullable_eltypestuple(b...).types...}

Base.@pure function nullable_broadcast_eltype(f, As...)
    T = Core.Inference.return_type(f, nullable_eltypestuple(As...))
    T === Union{} ? Any : T
end

invoke_broadcast!{F, N}(f::F, dest, As::Vararg{DataValueArray, N}) =
    invoke(broadcast!, Tuple{F, AbstractArray, Vararg{AbstractArray, N}}, f, dest, As...)

function Base.broadcast{F}(f::F, As::DataValueArray...)
    T = nullable_broadcast_eltype(f, As...)
    dest = similar(DataValueArray{T}, broadcast_indices(As...))
    invoke_broadcast!(f, dest, As...)
end

function Base.broadcast!{F}(f::F, dest::DataValueArray, As::DataValueArray...)
    invoke_broadcast!(f, dest, As...)
end

# To fix ambiguity
function Base.broadcast!{F}(f::F, dest::DataValueArray)
    invoke_broadcast!(f, dest)
end
