
# ----- Outer Constructors -------------------------------------------------- #

# The following provides an outer constructor whose argument signature matches
# that of the inner constructor provided in typedefs.jl: constructs a DataValueArray
# from an AbstractArray of values and an AbstractArray{Bool} mask.
function DataValueArray{T, N}(A::AbstractArray{T, N},
                             m::AbstractArray{Bool, N}) # -> DataValueArray{T, N}
    return DataValueArray{T, N}(A, m)
end

# TODO: Uncomment this doc entry when Base Julia can parse it correctly.
# """
# Allow users to construct a quasi-uninitialized `DataValueArray` object by
# specifing:
#
# * `T`: The type of its elements.
# * `dims`: The size of the resulting `DataValueArray`.
#
# NOTE: The `values` field will be truly uninitialized, but the `isnull` field
# will be initialized to `true` everywhere, making every entry of a new
# `DataValueArray` a null value by default.
# """
function DataValueArray{T}(::Type{T}, dims::Dims) # -> DataValueArray{T, N}
    return DataValueArray(Array{T}(dims), fill(true, dims))
end

# Constructs an empty DataValueArray of type parameter T and number of dimensions
# equal to the number of arguments given in 'dims...', where the latter are
# dimension lengths.
function DataValueArray(T::Type, dims::Int...) # -> DataValueArray
    return DataValueArray(T, dims)
end

@compat (::Type{DataValueArray{T}}){T}(dims::Dims) = DataValueArray(T, dims)
@compat (::Type{DataValueArray{T}}){T}(dims::Int...) = DataValueArray(T, dims)
if VERSION >= v"0.5.0-"
    @compat (::Type{DataValueArray{T,N}}){T,N}(dims::Vararg{Int,N}) = DataValueArray(T, dims)
else
    function Base.convert{T,N}(::Type{DataValueArray{T,N}}, dims::Int...)
        length(dims) == N || throw(ArgumentError("Wrong number of arguments. Expected $N, got $(length(dims))."))
        DataValueArray(T, dims)
    end
end

# The following method constructs a DataValueArray from an Array{Any} argument
# 'A' that contains some placeholder of type 'T' for null values.
#
# e.g.: julia> DataValueArray([1, nothing, 2], Int, Void)
#       3-element DataValueArrays.DataValueArray{Int64,1}:
#       DataValue(1)
#       DataValue{Int64}()
#       DataValue(2)
#
#       julia> DataValueArray([1, "notdefined", 2], Int, ASCIIString)
#       3-element DataValueArrays.DataValueArray{Int64,1}:
#       DataValue(1)
#       DataValue{Int64}()
#       DataValue(2)
#
# TODO: think about dispatching on T = Any in method above to call
# the following method passing 'T=Void' for pseudo-literal
# DataValueArray construction
function DataValueArray{T, U}(A::AbstractArray,
                             ::Type{T}, ::Type{U}) # -> DataValueArray{T, N}
    res = DataValueArray(T, size(A))
    for i in 1:length(A)
        if !isa(A[i], U)
            @inbounds setindex!(res, A[i], i)
        end
    end
    return res
end

# The following method constructs a DataValueArray from an Array{Any} argument
# `A` that contains some placeholder value `na` for null values.
#
# e.g.: julia> DataValueArray(Any[1, "na", 2], Int, "na")
#       3-element DataValueArrays.DataValueArray{Int64,1}:
#       DataValue(1)
#       DataValue{Int64}()
#       DataValue(2)
#
function DataValueArray{T}(A::AbstractArray,
                             ::Type{T},
                             na::Any;
                             conversion::Base.Callable=Base.convert) # -> DataValueArray{T, N}
    res = DataValueArray(T, size(A))
    for i in 1:length(A)
        if !isequal(A[i], na)
            @inbounds setindex!(res, A[i], i)
        end
    end
    return res
end

# The following method allows for the construction of zero-element
# DataValueArrays by calling the parametrized type on zero arguments.
@compat (::Type{DataValueArray{T, N}}){T, N}() = DataValueArray(T, ntuple(i->0, N))


# ----- Conversion to DataValueArrays ---------------------------------------- #
# Also provides constructors from arrays via the fallback mechanism.

#----- Conversion from arrays (of non-DataValues) -----------------------------#
function Base.convert{S, T, N}(::Type{DataValueArray{T, N}},
                               A::AbstractArray{S, N}) # -> DataValueArray{T, N}
    DataValueArray{T, N}(convert(Array{T, N}, A), fill(false, size(A)))
end

function Base.convert{S, T, N}(::Type{DataValueArray{T}},
                               A::AbstractArray{S, N}) # -> DataValueArray{T, N}
    convert(DataValueArray{T, N}, A)
end

function Base.convert{T, N}(::Type{DataValueArray},
                            A::AbstractArray{T, N}) # -> DataValueArray{T, N}
    convert(DataValueArray{T, N}, A)
end

#----- Conversion from arrays of DataValues -----------------------------------#
function Base.convert{S<:DataValue, T, N}(::Type{DataValueArray{T, N}},
                                         A::AbstractArray{S, N}) # -> DataValueArray{T, N}
   out = DataValueArray{T, N}(Array{T}(size(A)), Array{Bool}(size(A)))
   for i = 1:length(A)
       if !(out.isnull[i] = isnull(A[i]))
           out.values[i] = A[i].value
       end
   end
   out
end

#----- Conversion from DataValueArrays of a different type --------------------#
Base.convert{T, N}(::Type{DataValueArray}, X::DataValueArray{T,N}) = X

function Base.convert{S, T, N}(::Type{DataValueArray{T}},
                               A::AbstractArray{DataValue{S}, N}) # -> DataValueArray{T, N}
    convert(DataValueArray{T, N}, A)
end

function Base.convert{T, N}(::Type{DataValueArray},
                            A::AbstractArray{DataValue{T}, N}) # -> DataValueArray{T, N}
    convert(DataValueArray{T, N}, A)
end

function Base.convert{N}(::Type{DataValueArray},
                         A::AbstractArray{DataValue, N}) # -> DataValueArray{Any, N}
    convert(DataValueArray{Any, N}, A)
end

function Base.convert{S, T, N}(::Type{DataValueArray{T, N}},
                               A::DataValueArray{S, N}) # -> DataValueArray{T, N}
    DataValueArray(convert(Array{T, N}, A.values), A.isnull)
end
