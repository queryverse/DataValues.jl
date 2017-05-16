
# ----- Outer Constructors -------------------------------------------------- #

# The following provides an outer constructor whose argument signature matches
# that of the inner constructor provided in typedefs.jl: constructs a DataArray2
# from an AbstractArray of values and an AbstractArray{Bool} mask.
function DataArray2{T, N}(A::AbstractArray{T, N},
                             m::AbstractArray{Bool, N}) # -> DataArray2{T, N}
    return DataArray2{T, N}(A, m)
end

# TODO: Uncomment this doc entry when Base Julia can parse it correctly.
# """
# Allow users to construct a quasi-uninitialized `DataArray2` object by
# specifing:
#
# * `T`: The type of its elements.
# * `dims`: The size of the resulting `DataArray2`.
#
# NOTE: The `values` field will be truly uninitialized, but the `isnull` field
# will be initialized to `true` everywhere, making every entry of a new
# `DataArray2` a null value by default.
# """
function DataArray2{T}(::Type{T}, dims::Dims) # -> DataArray2{T, N}
    return DataArray2(Array{T}(dims), fill(true, dims))
end

# Constructs an empty DataArray2 of type parameter T and number of dimensions
# equal to the number of arguments given in 'dims...', where the latter are
# dimension lengths.
function DataArray2(T::Type, dims::Int...) # -> DataArray2
    return DataArray2(T, dims)
end

@compat (::Type{DataArray2{T}}){T}(dims::Dims) = DataArray2(T, dims)
@compat (::Type{DataArray2{T}}){T}(dims::Int...) = DataArray2(T, dims)
if VERSION >= v"0.5.0-"
    @compat (::Type{DataArray2{T,N}}){T,N}(dims::Vararg{Int,N}) = DataArray2(T, dims)
else
    function Base.convert{T,N}(::Type{DataArray2{T,N}}, dims::Int...)
        length(dims) == N || throw(ArgumentError("Wrong number of arguments. Expected $N, got $(length(dims))."))
        DataArray2(T, dims)
    end
end

# The following method constructs a DataArray2 from an Array{Any} argument
# 'A' that contains some placeholder of type 'T' for null values.
#
# e.g.: julia> DataArray2([1, nothing, 2], Int, Void)
#       3-element DataArray2s.DataArray2{Int64,1}:
#       DataValue(1)
#       DataValue{Int64}()
#       DataValue(2)
#
#       julia> DataArray2([1, "notdefined", 2], Int, ASCIIString)
#       3-element DataArray2s.DataArray2{Int64,1}:
#       DataValue(1)
#       DataValue{Int64}()
#       DataValue(2)
#
# TODO: think about dispatching on T = Any in method above to call
# the following method passing 'T=Void' for pseudo-literal
# DataArray2 construction
function DataArray2{T, U}(A::AbstractArray,
                             ::Type{T}, ::Type{U}) # -> DataArray2{T, N}
    res = DataArray2(T, size(A))
    for i in 1:length(A)
        if !isa(A[i], U)
            @inbounds setindex!(res, A[i], i)
        end
    end
    return res
end

# The following method constructs a DataArray2 from an Array{Any} argument
# `A` that contains some placeholder value `na` for null values.
#
# e.g.: julia> DataArray2(Any[1, "na", 2], Int, "na")
#       3-element DataArray2s.DataArray2{Int64,1}:
#       DataValue(1)
#       DataValue{Int64}()
#       DataValue(2)
#
function DataArray2{T}(A::AbstractArray,
                             ::Type{T},
                             na::Any;
                             conversion::Base.Callable=Base.convert) # -> DataArray2{T, N}
    res = DataArray2(T, size(A))
    for i in 1:length(A)
        if !isequal(A[i], na)
            @inbounds setindex!(res, A[i], i)
        end
    end
    return res
end

# The following method allows for the construction of zero-element
# DataArray2s by calling the parametrized type on zero arguments.
@compat (::Type{DataArray2{T, N}}){T, N}() = DataArray2(T, ntuple(i->0, N))


# ----- Conversion to DataArray2s ---------------------------------------- #
# Also provides constructors from arrays via the fallback mechanism.

#----- Conversion from arrays (of non-DataValues) -----------------------------#
function Base.convert{S, T, N}(::Type{DataArray2{T, N}},
                               A::AbstractArray{S, N}) # -> DataArray2{T, N}
    DataArray2{T, N}(convert(Array{T, N}, A), fill(false, size(A)))
end

function Base.convert{S, T, N}(::Type{DataArray2{T}},
                               A::AbstractArray{S, N}) # -> DataArray2{T, N}
    convert(DataArray2{T, N}, A)
end

function Base.convert{T, N}(::Type{DataArray2},
                            A::AbstractArray{T, N}) # -> DataArray2{T, N}
    convert(DataArray2{T, N}, A)
end

#----- Conversion from arrays of DataValues -----------------------------------#
function Base.convert{S<:DataValue, T, N}(::Type{DataArray2{T, N}},
                                         A::AbstractArray{S, N}) # -> DataArray2{T, N}
   out = DataArray2{T, N}(Array{T}(size(A)), Array{Bool}(size(A)))
   for i = 1:length(A)
       if !(out.isnull[i] = isnull(A[i]))
           out.values[i] = A[i].value
       end
   end
   out
end

#----- Conversion from DataArray2s of a different type --------------------#
Base.convert{T, N}(::Type{DataArray2}, X::DataArray2{T,N}) = X

function Base.convert{S, T, N}(::Type{DataArray2{T}},
                               A::AbstractArray{DataValue{S}, N}) # -> DataArray2{T, N}
    convert(DataArray2{T, N}, A)
end

function Base.convert{T, N}(::Type{DataArray2},
                            A::AbstractArray{DataValue{T}, N}) # -> DataArray2{T, N}
    convert(DataArray2{T, N}, A)
end

function Base.convert{N}(::Type{DataArray2},
                         A::AbstractArray{DataValue, N}) # -> DataArray2{Any, N}
    convert(DataArray2{Any, N}, A)
end

function Base.convert{S, T, N}(::Type{DataArray2{T, N}},
                               A::DataArray2{S, N}) # -> DataArray2{T, N}
    DataArray2(convert(Array{T, N}, A.values), A.isnull)
end
