
# ----- Outer Constructors -------------------------------------------------- #

# The following provides an outer constructor whose argument signature matches
# that of the inner constructor provided in typedefs.jl: constructs a DataValueArray
# from an AbstractArray of values and an AbstractArray{Bool} mask.
function DataValueArray{T,N}(d::AbstractArray{T,N}, m::AbstractArray{Bool,N})
    return DataValueArray{T,N}(d, m)
end

function DataValueArray{T}(d::NTuple{N,Int}) where {T,N}
    return DataValueArray{T,N}(Array{T,N}(d), fill(true, d))    
end

function DataValueArray{T}(d::Vararg{Int,N}) where {T,N}
    return DataValueArray{T,N}(Array{T,N}(d), fill(true, d))    
end

# DA Do I need to keep these?
(::Type{DataValueArray{T}}){T}(dims::Dims) = DataValueArray(T, dims)
(::Type{DataValueArray{T}}){T}(dims::Int...) = DataValueArray(T, dims)
(::Type{DataValueArray{T,N}}){T,N}(dims::Vararg{Int,N}) = DataValueArray(T, dims)

# NEW
function DataValueArray(data::Array{T,N}) where {T<:DataValue,N}
    S = eltype(eltype(data))
    new_array = DataValueArray{S,N}(size(data))
    for i in eachindex(data)
        new_array[i] = data[i]
    end
    return new_array
end

# DA Do I need to keep these?
# The following method allows for the construction of zero-element
# DataValueArrays by calling the parametrized type on zero arguments.
(::Type{DataValueArray{T, N}}){T, N}() = DataValueArray(T, ntuple(i->0, N))

# DA Continue to check the following

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
