Base.isnull(X::DataValueArray, I::Int...) = X.isnull[I...]
Base.values(X::DataValueArray, I::Int...) = X.values[I...]

"""
    size(X::DataValueArray, [d::Real])

Return a tuple containing the lengths of each dimension of `X`, or if `d` is
specific, the length of `X` along dimension `d`.
"""
Base.size(X::DataValueArray) = size(X.values)

"""
    similar(X::DataValueArray, [T], [dims])

Allocate an uninitialized `DataValueArray` of element type `T` and with
size `dims`. If unspecified, `T` and `dims` default to the element type and size
equal to that of `X`.
"""
function Base.similar(X::DataValueArray, ::Type{T}, dims::Dims) where {T}
    return T<:DataValue ? DataValueArray{eltype(T)}(dims) : DataValueArray{T}(dims)
end

"""
    copy(X::DataValueArray)

Return a shallow copy of `X`; the outer structure of `X` will be copied, but
all elements will be identical to those of `X`.
"""
function Base.copy(X::DataValueArray{T}) where {T}
    return Base.copy!(similar(X, T), X)
end

# DA This was my version, not clear which one is better
# function Base.copy!{T}(dest::DataValueArray{T},
#     src::DataValueArray{T})
# length(dest) >= length(src) || throw(BoundsError())

# n = length(src)

# if isbits(T)
# unsafe_copy!(pointer(dest.values, 1), pointer(src.values, 1), n)
# else
# ccall(:jl_array_ptr_copy, Void, (Any, Ptr{Void}, Any, Ptr{Void}, Int),
# dest.values, pointer(dest.values, 1), src.values, pointer(src.values, 1), n)
# end
# unsafe_copy!(pointer(dest.isnull, 1), pointer(src.isnull, 1), n)
# return dest
# end

"""
    copy!(dest::DataValueArray, src::DataValueArray)

Copy the initialized values of a source DataValueArray into the respective
indices of the destination DataValueArray. If an entry in `src` is null, then
this method nullifies the respective entry in `dest`.
"""
function Base.copy!(dest::DataValueArray, src::DataValueArray)
    if isbits(eltype(dest)) && isbits(eltype(src))
        copy!(dest.values, src.values)
    else
        dest_values = dest.values
        src_values = src.values
        length(dest_values) >= length(src_values) || throw(BoundsError())
        # copy only initilialized values from src into dest
        for i in 1:length(src_values)
            @inbounds !(src.isnull[i]) && (dest.values[i] = src.values[i])
        end
    end
    copy!(dest.isnull, src.isnull)
    return dest
end

"""
    fill!(X::DataValueArray, x::DataValue)

Fill `X` with the value `x`. If `x` is empty, then `fill!(X, x)` nullifies each
entry of `X`. Otherwise, `fill!(X, x)` fills `X.values` with the value of `x`
and designates each entry of `X` as present.
"""
function Base.fill!(X::DataValueArray, x::DataValue)
    if isnull(x)
        fill!(X.isnull, true)
    else
        fill!(X.values, get(x))
        fill!(X.isnull, false)
    end
    return X
end

"""
    fill!(X::DataValueArray, x::DataValue)

Fill `X` with the value `x` and designate each entry as present. If `x` is an
object reference, all elements will refer to the same object. Note that
`fill!(X, Foo())` will return `X` filled with the result of evaluating `Foo()`
once.
"""
function Base.fill!(X::DataValueArray, x::Any)
    fill!(X.values, x)
    fill!(X.isnull, false)
    return X
end

"""
    Base.deepcopy(X::DataValueArray)

Return a `DataValueArray` object whose internal `values` and `isnull` fields are
deep copies of `X.values` and `X.isnull` respectively.
"""
function Base.deepcopy(X::DataValueArray)
    return DataValueArray(deepcopy(X.values), deepcopy(X.isnull))
end

"""
    resize!(X::DataValueVector, n::Int)

Resize a one-dimensional `DataValueArray` `X` to contain precisely `n` elements.
If `n` is greater than the current length of `X`, then each new entry will be
designated as null.
"""
function Base.resize!(X::DataValueArray{T,1}, n::Int) where {T}
    resize!(X.values, n)
    oldn = length(X.isnull)
    resize!(X.isnull, n)
    X.isnull[oldn+1:n] = true
    return X
end

function Base.reshape(X::DataValueArray, dims::Dims)
    return DataValueArray(reshape(X.values, dims), reshape(X.isnull, dims))
end

"""
    ndims(X::DataValueArray)

Returns the number of dimensions of `X`.
"""
Base.ndims(X::DataValueArray) = ndims(X.values)

"""
    length(X::DataValueArray)

Returns the maximum index `i` for which `getindex(X, i)` is valid.
"""
Base.length(X::DataValueArray) = length(X.values)

"""
    endof(X::DataValueArray)

Returns the last entry of `X`.
"""
Base.endof(X::DataValueArray) = endof(X.values)

# DA Unclear whether I want that
# function Base.find(X::DataValueArray{Bool})
#     ntrue = 0
#     @inbounds for (i, isnull) in enumerate(X.isnull)
#         ntrue += !isnull && X.values[i]
#     end
#     res = Array{Int}(ntrue)
#     ind = 1
#     @inbounds for (i, isnull) in enumerate(X.isnull)
#         if !isnull && X.values[i]
#             res[ind] = i
#             ind += 1
#         end
#     end
#     return res
# end

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

# DA I don't think we want this
# """
#     isnan(X::DataValueArray)

# Test whether each entry of `X` is null and if not, test whether the entry is
# not a number (`NaN`). Return the results as `DataValueArray{Bool}`. Note that
# null entries of `X` will be reflected by null entries of the resultant
# `DataValueArray`.
# """
# function Base.isnan(X::DataValueArray) # -> DataValueArray{Bool}
#     return DataValueArray(isnan.(X.values), copy(X.isnull))
# end

# DA I don't think we want this
# """
#     isfinite(X::DataValueArray)

# Test whether each entry of `X` is null and if not, test whether the entry is
# finite. Return the results as `DataValueArray{Bool}`. Note that
# null entries of `X` will be reflected by null entries of the resultant
# `DataValueArray`.
# """
# function Base.isfinite(X::DataValueArray) # -> DataValueArray{Bool}
#     res = Array{Bool}(size(X))
#     for i in eachindex(X)
#         if !X.isnull[i]
#             res[i] = isfinite(X.values[i])
#         end
#     end
#     return DataValueArray(res, copy(X.isnull))
# end


# DA CONTINUE HERE

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
function Base.convert(::Type{Array{S, N}}, X::DataValueArray{T, N}) where {S,T,N}
    if any(isnull, X)
        throw(NullException())
    else
        return convert(Array{S, N}, X.values)
    end
end

function Base.convert(::Type{Array{S}}, X::DataValueArray{T, N}) where {S,T,N} # -> Array{S, N}
    return convert(Array{S, N}, X)
end

function Base.convert(::Type{Vector}, X::DataValueVector{T}) where {T} # -> Vector{T}
    return convert(Array{T, 1}, X)
end

function Base.convert(::Type{Matrix}, X::DataValueMatrix{T}) where {T} # -> Matrix{T}
    return convert(Array{T, 2}, X)
end

function Base.convert(::Type{Array},
                            X::DataValueArray{T, N}) where {T,N} # -> Array{T, N}
    return convert(Array{T, N}, X)
end

# Conversions with replacements for handling null values

function Base.convert(::Type{Array{S, N}},
                               X::DataValueArray{T, N},
                               replacement::Any) where {S,T,N} # -> Array{S, N}
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

function Base.convert(::Type{Vector},
                         X::DataValueVector{T},
                         replacement::Any) where {T} # -> Vector{T}
    return convert(Array{T, 1}, X, replacement)
end

function Base.convert(::Type{Matrix},
                         X::DataValueMatrix{T},
                         replacement::Any) where {T} # -> Matrix{T}
    return convert(Array{T, 2}, X, replacement)
end

function Base.convert(::Type{Array},
                            X::DataValueArray{T, N},
                            replacement::Any) where {T,N} # -> Array{T, N}
    return convert(Array{T, N}, X, replacement)
end

# DA Not sure whether I want to keep this
# """
#     float(X::DataValueArray)

# Return a copy of `X` in which each non-null entry is converted to a floating
# point type. Note that this method will throw an error for arguments `X` whose
# element type is not "isbits".
# """
# function Base.float(X::DataValueArray) # -> DataValueArray{T, N}
#     isbits(eltype(X)) || error()
#     return DataValueArray(float(X.values), copy(X.isnull))
# end

Base.any(::typeof(isnull), X::DataValueArray) = Base.any(X.isnull)
Base.all(::typeof(isnull), X::DataValueArray) = Base.all(X.isnull)
