immutable DataValueArray{T,N} <: AbstractArray{DataValue{T},N}
    values::Array{T,N}
    isnull::Array{Bool,N}

    function DataValueArray{T,N}(d::NTuple{N,Int}) where {T,N}
        new{T,N}(Array{T,N}(d), Array{Bool,N}(d))
    end

    function DataValueArray{T,N}(d::Vararg{Int,N}) where {T,N}
        new{T,N}(Array{T,N}(d), Array{Bool,N}(d))
    end    

    function DataValueArray{T,N}(d::AbstractArray{T, N}, m::AbstractArray{Bool, N}) where {T,N}
        if size(d) != size(m)
            msg = "values and missingness arrays must be the same size"
            throw(ArgumentError(msg))
        end
        new(d, m)
    end
end

function DataValueArray{T,N}(d::AbstractArray{T,N}, m::AbstractArray{Bool,N})
    return DataValueArray{T,N}(d, m)
end

DataValueArray{T}(d::NTuple{N,Int}) where {T,N} = DataValueArray{T,N}(d)

function DataValueArray{T}(m::Int) where {T}
    res = DataValueArray{T,1}(m)
    fill!(res.isnull, true)
    return res
end

const DataValueVector{T} = DataValueArray{T, 1}
const DataValueMatrix{T} = DataValueArray{T, 2}

function Base.convert(::Type{DataValueArray}, a::AbstractArray{T,N}) where {T,N}
    DataValueArray{T,N}(a, fill(false, size(a)))
end

function Base.convert(::Type{DataValueArray{T}}, a::AbstractArray{S,N}) where {T,S,N}
    DataValueArray{T,N}(convert(Array{S},a), fill(false, size(a)))
end

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

function Base.push!{T, V}(X::DataValueVector{T}, v::V)
    push!(X.values, v)
    push!(X.isnull, false)
    return X
end

function Base.push!{T, V}(X::DataValueVector{T}, v::DataValue{V})
    if isnull(v)
        resize!(X.values, length(X.values) + 1)
        push!(X.isnull, true)
    else
        push!(X.values, v.value)
        push!(X.isnull, false)
    end
    return X
end

function Base.push!{T}(X::DataValueVector{T}, v::DataValue{Union{}})
    resize!(X.values, length(X.values) + 1)
    push!(X.isnull, true)
    return X
end

function Base.pop!{T}(X::DataValueVector{T})
    val, isnull = pop!(X.values), pop!(X.isnull)
    isnull ? DataValue{T}() : DataValue(val)
end

function Base.copy!{T}(dest::DataValueArray{T},
                    src::DataValueArray{T})
    length(dest) >= length(src) || throw(BoundsError())

    n = length(src)

    if isbits(T)
        unsafe_copy!(pointer(dest.values, 1), pointer(src.values, 1), n)
    else
        ccall(:jl_array_ptr_copy, Void, (Any, Ptr{Void}, Any, Ptr{Void}, Int),
              dest.values, pointer(dest.values, 1), src.values, pointer(src.values, 1), n)
    end
    unsafe_copy!(pointer(dest.isnull, 1), pointer(src.isnull, 1), n)
    return dest
end
function Base.copy!{T}(dest::DataValueArray{T},
                    src::DataValueArray{T})
    length(dest) >= length(src) || throw(BoundsError())

    n = length(src)

    if isbits(T)
        unsafe_copy!(pointer(dest.values, 1), pointer(src.values, 1), n)
    else
        ccall(:jl_array_ptr_copy, Void, (Any, Ptr{Void}, Any, Ptr{Void}, Int),
              dest.values, pointer(dest.values, 1), src.values, pointer(src.values, 1), n)
    end
    unsafe_copy!(pointer(dest.isnull, 1), pointer(src.isnull, 1), n)
    return dest
end

"""
dropna(X::AbstractVector)

Return a vector containing only the non-missing entries of `X`,
unwrapping `DataValue` entries. A copy is always returned, even when
`X` does not contain any missing values.
"""
function dropna{T}(X::AbstractVector{T})
    if !(DataValue <: T) && !(T <: DataValue)
        return copy(X)
    else
        Y = filter(x->!isnull(x), X)
        res = similar(Y, eltype(T))
        for i in eachindex(Y, res)
            @inbounds res[i] = isa(Y[i], DataValue) ? Y[i].value : Y[i]
        end
        return res
    end
end
dropna(X::DataValueVector) = X.values[(!).(X.isnull)]

"""
dropna!(X::AbstractVector)

Remove missing entries of `X` in-place and return a `Vector` view of the
unwrapped `DataValue` entries. If no missing values are present, this is a no-op
and `X` is returned.
"""
function dropna!{T}(X::AbstractVector{T})                 # -> AbstractVector
    if !(DataValue <: T) && !(T <: DataValue)
        return X
    else
        deleteat!(X, find(isnull, X))
        res = similar(X, eltype(T))
        for i in eachindex(X, res)
            @inbounds res[i] = isa(X[i], DataValue) ? X[i].value : X[i]
        end
        return res
    end
end

"""
dropna!(X::DataValueVector)

Remove missing entries of `X` in-place and return a `Vector` view of the
unwrapped `DataValue` entries.
"""
# TODO: replace `find(X.isnull)` with `X.isnull` when
# https://github.com/JuliaLang/julia/pull/20465 is merged and part of
# current release (either v0.6 or v1.0)
dropna!(X::DataValueVector) = deleteat!(X, find(X.isnull)).values # -> Vector
