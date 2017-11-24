function Base.split(str::DataValue{T}) where {T<:AbstractString}
    if isnull(str)
        return SubString{T}[]
    else
        return split(get(str))
    end
end

function Base.split(str::DataValue{T}, splitter; kwargs...) where {T<:AbstractString}
    if isnull(str)
        return SubString{T}[]
    else
        return split(get(str), splitter; kwargs...)
    end    
end
