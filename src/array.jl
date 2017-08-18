export DataValueArray, DataValueVector, DataValueMatrix, dropna, dropna!

immutable DataValueArray{T,N} <: AbstractArray{DataValue{T},N}
    values::Array{T,N}
    isnull::Array{Bool,N}

    function DataValueArray{T,N}(d::NTuple{N,Int}) where {T,N}
        new{T,N}(Array{T,N}(d), fill(true, d))
    end

    function DataValueArray{T,N}(d::Vararg{Int,N}) where {T,N}
        new{T,N}(Array{T,N}(d), fill(true, d))
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

DataValueArray{T}(d::Vararg{Int,N}) where {T,N} = DataValueArray{T,N}(d)

function DataValueArray{T}(m::Int) where {T}
    res = DataValueArray{T,1}(m)
    fill!(res.isnull, true)
    return res
end

function DataValueArray(data::Array{T,N}) where {T<:DataValue,N}
    S = eltype(eltype(data))
    new_array = DataValueArray{S,N}(size(data))
    for i in eachindex(data)
        new_array[i] = data[i]
    end
    return new_array
end

const DataValueVector{T} = DataValueArray{T, 1}
const DataValueMatrix{T} = DataValueArray{T, 2}

function Base.convert(::Type{DataValueArray}, A::AbstractArray{T,N}) where {T,N}
    convert(DataValueArray{T, N}, A)
end

function Base.convert(::Type{DataValueArray{T}}, A::AbstractArray{S,N}) where {T,S,N}
    convert(DataValueArray{T, N}, A)
end

function Base.convert(::Type{DataValueArray{T, N}}, A::AbstractArray{S, N}) where {S,T,N}
    DataValueArray{T, N}(convert(Array{T, N}, A), fill(false, size(A)))
end

Base.isnull(X::DataValueArray, I::Int...) = X.isnull[I...]
Base.values(X::DataValueArray, I::Int...) = X.values[I...]

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

"""
similar(X::DataValueArray, [T], [dims])

Allocate an uninitialized `DataValueArray` of element type `T` and with
size `dims`. If unspecified, `T` and `dims` default to the element type and size
equal to that of `X`.
"""
function Base.similar{T}(X::DataValueArray, ::Type{T}, dims::Dims)
    T<:DataValue ? DataValueArray{eltype(T)}(dims) : DataValueArray{T}(dims)
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


"""
convert(T, X::DataValueArray)

Convert `X` to an `AbstractArray` of type `T`. Note that if `X` contains any
null entries then calling `convert` without supplying a replacement value for
null entries will result in an error.

Currently supported return type arguments include: `Array`, `Array{T}`,
`Vector`, `Matrix`.

convert(T, X::DataValueArray, replacement)

Convert `X` to an `AbstractArray` of type `T` and replace all null entries of
`X` with `replacement` in the result.
"""
function Base.convert{S, T, N}(::Type{Array{S, N}},
                           X::DataValueArray{T, N}) # -> Array{S, N}
    if any(isnull, X)
        throw(NullException())
    else
        return convert(Array{S, N}, X.values)
    end
end

Base.convert{T, N}(::Type{DataValueArray}, X::DataValueArray{T,N}) = X

function Base.convert{S, T, N}(::Type{DataValueArray{T, N}}, A::DataValueArray{S, N})
    DataValueArray(convert(Array{T, N}, A.values), A.isnull)
end


function Base.convert{S, T, N}(::Type{Array{S}},
                           X::DataValueArray{T, N}) # -> Array{S, N}
    return convert(Array{S, N}, X)
end

function Base.convert{T}(::Type{Vector}, X::DataValueVector{T}) # -> Vector{T}
    return convert(Array{T, 1}, X)
end

function Base.convert{T}(::Type{Matrix}, X::DataValueMatrix{T}) # -> Matrix{T}
    return convert(Array{T, 2}, X)
end

function Base.convert{T, N}(::Type{Array},
                        X::DataValueArray{T, N}) # -> Array{T, N}
    return convert(Array{T, N}, X)
end

# Conversions with replacements for handling null values

function Base.convert{S, T, N}(::Type{Array{S, N}},
                           X::DataValueArray{T, N},
                           replacement::Any) # -> Array{S, N}
    replacementS = convert(S, replacement)
    res = Array{S}(size(X))
    for i in 1:length(X)
        if X.isnull[i]
            res[i] = replacementS
        else
            res[i] = X.values[i]
        end
    end
    return res
end

function Base.convert{T}(::Type{Vector},
                     X::DataValueVector{T},
                     replacement::Any) # -> Vector{T}
    return convert(Array{T, 1}, X, replacement)
end

function Base.convert{T}(::Type{Matrix},
                     X::DataValueMatrix{T},
                     replacement::Any) # -> Matrix{T}
    return convert(Array{T, 2}, X, replacement)
end

function Base.convert{T, N}(::Type{Array},
                        X::DataValueArray{T, N},
                        replacement::Any) # -> Array{T, N}
    return convert(Array{T, N}, X, replacement)
end

"""
deleteat!(X::DataValueVector, inds)

Delete the entry at `inds` from `X` and then return `X`. Note that `inds` may
be either a single scalar index or a collection of sorted, pairwise unique
indices. Subsequent items after deleted entries are shifted down to fill the
resulting gaps.
"""
function Base.deleteat!(X::DataValueVector, inds)
    deleteat!(X.values, inds)
    deleteat!(X.isnull, inds)
    return X
end

Base.promote_rule(::Type{DataValueArray{T,N}}, ::Type{Array{T,N}}) where {T,N} = DataValueArray{T,N}
Base.promote_rule(::Type{Array{T,N}}, ::Type{DataValueArray{T,N}}) where {T,N} = DataValueArray{T,N}
Base.promote_rule(::Type{DataValueArray{T,N}}, ::Type{Array{S,N}}) where {T,S,N} = DataValueArray{Base.promote_type(T,S),N}
Base.promote_rule(::Type{Array{S,N}}, ::Type{DataValueArray{T,N}}) where {T,S,N} = DataValueArray{Base.promote_type(T,S),N}
