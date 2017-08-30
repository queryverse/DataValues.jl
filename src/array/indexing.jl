# DataValueArray is dense and allows fast linear indexing.
Base.IndexStyle(::Type{<:DataValueArray}) = Base.IndexLinear()

# resolve ambiguity created by the two definitions that follow.
function Base.getindex{T,N}(X::DataValueArray{T,N})
    return X[1]
end

"""
    getindex{T,N}(X::DataValueArray{T,N}, I::Int...)

Retrieve a single entry from a `DataValueArray`. If the value in the entry
designated by `I` is present, then it will be returned wrapped in a
`DataValue{T}` container. If the value is missing, then this method returns
`DataValue{T}()`.
"""
@inline function Base.getindex{T,N}(X::DataValueArray{T,N}, I::Int...)
    if isbits(T)
        ifelse(X.isnull[I...], DataValue{T}(), DataValue{T}(X.values[I...]))
    else
        if X.isnull[I...]
            DataValue{T}()
        else
            DataValue{T}(X.values[I...])
        end
    end
end

"""
    getindex{T,N}(X::DataValueArray{T,N}, I::DataValue{Int}...)

Just as above, with the additional behavior that this method throws an error if
any component of the index `I` is missing.
"""
@inline function Base.getindex{T,N}(X::DataValueArray{T,N}, I::DataValue{Int}...)
    any(isnull, I) && throw(NullException())
    values = [ get(i) for i in I ]
    return getindex(X, values...)
end









"""
    setindex!(X::DataValueArray, v::DataValue, I::Int...)

Set the entry of `X` at position `I` equal to a `DataValue` value `v`. If
`v` is missing, then only `X.isnull` is updated to indicate that the entry at
index `I` is null. If `v` is not null, then `X.isnull` is updated to indicate
that the entry at index `I` is present and `X.values` is updated to store the
value wrapped in `v`.
"""
@inline function Base.setindex!(X::DataValueArray, v::DataValue, I::Int...)
    if isnull(v)
        X.isnull[I...] = true
    else
        X.isnull[I...] = false
        X.values[I...] = get(v)
    end
    return v
end

"""
    setindex!(X::DataValueArray, v::Any, I::Int...)

Set the entry of `X` at position `I` equal to `v`. This method always updates
`X.isnull` to indicate that the entry at index `I` is present and `X.values`
to store `v` at `I`.
"""
@inline function Base.setindex!(X::DataValueArray, v::Any, I::Int...)
    X.values[I...] = v
    X.isnull[I...] = false
    return v
end

@inline function Base.setindex!(X::DataValueArray, v::DataValue{Union{}}, I::Int...)
    X.isnull[I...] = true
    return v
end

# DA TODO disabled
# function unsafe_getindex_notnull(X::DataValueArray, I::Int...)
#     return DataValue(getindex(X.values, I...))
# end

# DA TODO disabled
# function unsafe_getvalue_notnull(X::DataValueArray, I::Int...)
#     return getindex(X.values, I...)
# end

# DA TODO disabled
# function Base.checkindex(::Type{Bool}, inds::AbstractUnitRange, i::DataValue)
#     isnull(i) ? throw(NullException()) : checkindex(Bool, inds, get(i))
# end

# DA TODO disabled
# function Base.checkindex{N}(::Type{Bool}, inds::AbstractUnitRange, I::DataValueArray{Bool, N})
#     any(isnull, I) && throw(NullException())
#     checkindex(Bool, inds, I.values)
# end

# DA TODO disabled
# function Base.checkindex{T<:Real}(::Type{Bool}, inds::AbstractUnitRange, I::DataValueArray{T})
#     any(isnull, I) && throw(NullException())
#     b = true
#     for i in 1:length(I)
#         @inbounds v = unsafe_getvalue_notnull(I, i)
#         b &= checkindex(Bool, inds, v)
#     end
#     return b
# end

# DA TODO disabled
# function Base.to_index(X::DataValueArray)
#     any(isnull, X) && throw(NullException())
#     Base.to_index(X.values)
# end
