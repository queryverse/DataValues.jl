
# ----- Outer Constructors -------------------------------------------------- #

# The following provides an outer constructor whose argument signature matches
# that of the inner constructor provided in typedefs.jl: constructs a DataValueArray
# from an AbstractArray of values and an AbstractArray{Bool} mask.
function DataValueArray(d::AbstractArray{T,N}, m::AbstractArray{Bool,N}) where {T,N}
    return DataValueArray{T,N}(d, m)
end

function DataValueArray{T}(d::NTuple{N,Int}) where {T,N}
    return DataValueArray{T,N}(Array{T,N}(d), fill(true, d))    
end

function DataValueArray{T,N}(d::NTuple{N,Int}) where {T,N}
    return DataValueArray{T,N}(Array{T,N}(d), fill(true, d))    
end

function DataValueArray{T}(d::Vararg{Int,N}) where {T,N}
    return DataValueArray{T,N}(Array{T,N}(d), fill(true, d))    
end

function DataValueArray{T,N}(d::Vararg{Int,N}) where {T,N}
    return DataValueArray{T,N}(Array{T,N}(d), fill(true, d))    
end

function DataValueArray(data::AbstractArray{T,N}) where {T<:DataValue,N}
    S = eltype(eltype(data))
    new_array = DataValueArray{S,N}(Array{S}(size(data)), Array{Bool}(size(data)))
    for i in eachindex(data)
        new_array[i] = data[i]
    end
    return new_array
end

function DataValueArray{S}(data::AbstractArray{T,N}) where {S,T<:DataValue,N}
    new_array = DataValueArray{S,N}(Array{S}(size(data)), Array{Bool}(size(data)))
    for i in eachindex(data)
        new_array[i] = data[i]
    end
    return new_array
end

function DataValueArray{S,N}(data::AbstractArray{T,N}) where {S,T<:DataValue,N}
    new_array = DataValueArray{S,N}(Array{S}(size(data)), Array{Bool}(size(data)))
    for i in eachindex(data)
        new_array[i] = data[i]
    end
    return new_array
end

# The following method allows for the construction of zero-element
# DataValueArrays by calling the parametrized type on zero arguments.
function DataValueArray{T,N}() where {T,N}
    return DataValueArray{T}(ntuple(i->0, N))
end

# ----- Conversion to DataValueArrays ---------------------------------------- #
# Also provides constructors from arrays via the fallback mechanism.

#----- Conversion from arrays (of non-DataValues) -----------------------------#
function Base.convert(::Type{DataValueArray{T,N}}, A::AbstractArray{S,N}) where {S,T,N}
    return DataValueArray{T,N}(convert(Array{T,N}, A), fill(false, size(A)))
end

function Base.convert(::Type{DataValueArray{T}}, A::AbstractArray{S,N}) where {S,T,N}
    return convert(DataValueArray{T,N}, A)
end

function Base.convert(::Type{DataValueArray}, A::AbstractArray{T,N}) where {T,N}
    return convert(DataValueArray{T,N}, A)
end

#----- Conversion from DataValueArrays of a different type --------------------#
function Base.convert(::Type{DataValueArray}, X::DataValueArray{T,N}) where {T,N}
    return X
end

function Base.convert(::Type{DataValueArray{T}}, A::AbstractArray{DataValue{S},N}) where {S,T,N}
    return convert(DataValueArray{T, N}, A)
end

function Base.convert(::Type{DataValueArray}, A::AbstractArray{DataValue{T},N}) where {T,N}
    return convert(DataValueArray{T,N}, A)
end

function Base.convert(::Type{DataValueArray}, A::AbstractArray{DataValue, N}) where {N}
    return convert(DataValueArray{Any,N}, A)
end

function Base.convert(::Type{DataValueArray{T,N}}, A::DataValueArray{S,N}) where {S,T,N}
    return DataValueArray(convert(Array{T,N}, A.values), A.isnull)
end
