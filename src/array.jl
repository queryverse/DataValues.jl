immutable DataValueArray{T,N} <: AbstractArray{DataValue{T},N}
    values::Array{T,N}
    isnull::Array{Bool,N}

    function DataValueArray{T, N}(d::AbstractArray{T, N}, m::AbstractArray{Bool, N}) where {T, N}
        if size(d) != size(m)
            msg = "values and missingness arrays must be the same size"
            throw(ArgumentError(msg))
        end
        new(d, m)
    end
end

function DataValueArray{T,N}(A::AbstractArray{T,N}, m::AbstractArray{Bool,N})
    return DataValueArray{T, N}(A, m)
end

function (::Type{DataValueArray{T,N}}){T,N}(dims::Vararg{Int,N})
    return DataValueArray(Array{T}(dims), fill(true, dims))
end

Array{T,N}(d::NTuple{N,Int}) where {T<:DataValue,N} =DataValueArray{eltype(T),N}(d)
Array{T,1}(m::Int) where {T<:DataValue} = DataValueArray{eltype(T),1}(m)
Array{T,2}(m::Int, n::Int) where {T<:DataValue} = DataValueArray{eltype(T),2}(m,n)
Array{T,3}(m::Int, n::Int, o::Int) where {T<:DataValue} = DataValueArray{eltype(T),3}(m,n,o)
Array{T,N}(d::Vararg{Int,N}) where {T<:DataValue,N} = DataValueArray{eltype(T),N}(d)

Base.size(X::DataValueArray) = size(X.values)

Base.IndexStyle(::Type{<:DataValueArray}) = Base.IndexLinear()

@inline function Base.getindex{T,N}(X::DataValueArray{T,N}, i::Int)
    if isbits(T)
        ifelse(X.isnull[i], DataValue{T}(), DataValue{T}(X.values[i]))
    else
        if X.isnull[i]
            DataValue{T}()
        else
            DataValue{T}(X.values[i])
        end
    end
end

@inline function Base.setindex!(X::DataValueArray, v::DataValue, i::Int)
    if isnull(v)
        X.isnull[i] = true
    else
        X.isnull[i] = false
        X.values[i] = get(v)
    end
    return v
end

@inline function Base.setindex!(X::DataValueArray, v::Any, i::Int)
    X.values[i] = v
    X.isnull[i] = false
    return v
end

@inline function Base.setindex!(X::DataValueArray, v::DataValue{Union{}}, i::Int)
    X.isnull[i] = true
    return v
end
