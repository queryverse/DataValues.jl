# === Design Notes ===
#
# `DataValueArray{T, N}` is a struct-of-arrays representation of
# `Array{DataValue{T}, N}`. This makes it easy to define complicated operations
# (e.g. matrix multiplication) by reusing the existing definition for
# `Array{T}`.
#
# One complication when defining functions that operate on the internal fields
# of a `DataValueArray` is that developers must take care to ensure that they
# do not index into an undefined entry in the `values` field. This is not a
# problem for `isbits` types, which are never `#undef`, but will trigger
# an exception for any other type.
#
# TODO: Ensure that size(values) == size(isnull) using inner constructor.
"""
`DataValueArray{T, N}` is an efficient alternative to `Array{DataValue{T}, N}`.
It allows users to easily define operations on arrays with null values by
reusing operations that only work on arrays without any null values.
"""
immutable DataValueArray{T, N} <: AbstractArray{DataValue{T}, N}
    values::Array{T, N}
    isnull::Array{Bool, N}

    function DataValueArray{T, N}(d::AbstractArray{T, N}, m::AbstractArray{Bool, N}) where {T, N}
        if size(d) != size(m)
            msg = "values and missingness arrays must be the same size"
            throw(ArgumentError(msg))
        end
        new(d, m)
    end
end

DataValueVector{T} = DataValueArray{T, 1}
DataValueMatrix{T} = DataValueArray{T, 2}
