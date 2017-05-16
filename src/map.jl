invoke_map!{F, N}(f::F, dest, As::Vararg{DataArray2, N}) =
    invoke(map!, Tuple{F, AbstractArray, Vararg{AbstractArray, N}}, f, dest, As...)

"""
    map(f, As::DataArray2...)

Call `map` with DataValue lifting semantics and return a `DataArray2`.
Lifting means calling function `f` on the the values wrapped inside `DataValue` entries
of the input arrays, and returning null if any entry is missing.

Note that this method's signature specifies the source `As` arrays as all
`DataArray2`s. Thus, calling `map` on arguments consisting
of both `Array`s and `DataArray2`s will fall back to the standard implementation
of `map` (i.e. without lifting).
"""
function Base.map{F}(f::F, As::DataArray2...)
    T = nullable_broadcast_eltype(f, As...)
    dest = similar(DataArray2{T}, size(As[1]))
    invoke_map!(f, dest, As...)
end

"""
    map!(f, dest::DataArray2, As::DataArray2...)

Call `map!` with DataValue lifting semantics.
Lifting means calling function `f` on the the values wrapped inside `DataValue` entries
of the input arrays, and returning null if any entry is missing.

Note that this method's signature specifies the destination `dest` array as well as the
source `As` arrays as all `DataArray2`s. Thus, calling `map!` on a arguments
consisting of both `Array`s and `DataArray2`s will fall back to the standard implementation
of `map!` (i.e. without lifting).
"""
function Base.map!{F}(f::F, dest::DataArray2, As::DataArray2...)
    invoke_map!(f, dest, As...)
end

# This definition is needed to avoid dispatch loops going back to the above one
function Base.map!{F}(f::F, dest::DataArray2)
    invoke_map!(f, dest, dest)
end
