import Base: convert, getindex, setindex!, similar, in
using DataValues

## Constructors and converters
## (special methods for AbstractArray{DataValue}, to avoid wrapping DataValue inside DataValue)

DataValueCategoricalArray{T, N}(::Type{DataValue{T}}, dims::NTuple{N,Int}; ordered=false) =
    DataValueCategoricalArray{T, N}(zeros(DefaultRefType, dims), CategoricalPool(ordered))
DataValueCategoricalArray{T}(::Type{DataValue{T}}, dims::Int...; ordered=false) =
    DataValueCategoricalArray(T, dims; ordered=ordered)

@compat (::Type{DataValueCategoricalArray{DataValue{T}, N, R}}){T, N, R}(dims::NTuple{N,Int};
                                                                       ordered=false) =
    DataValueCategoricalArray(zeros(R, dims), CategoricalPool{T, R}(ordered))
@compat (::Type{DataValueCategoricalArray{DataValue{T}, N}}){T, N}(dims::NTuple{N,Int};
                                                                 ordered=false) =
    DataValueCategoricalArray{T}(dims; ordered=ordered)
@compat (::Type{DataValueCategoricalArray{DataValue{T}}}){T}(m::Int;
                                                           ordered=false) =
    DataValueCategoricalArray{T}((m,); ordered=ordered)
@compat (::Type{DataValueCategoricalArray{DataValue{T}}}){T}(m::Int, n::Int;
                                                           ordered=false) =
    DataValueCategoricalArray{T}((m, n); ordered=ordered)
@compat (::Type{DataValueCategoricalArray{DataValue{T}}}){T}(m::Int, n::Int, o::Int;
                                                           ordered=false) =
    DataValueCategoricalArray{T}((m, n, o); ordered=ordered)

@compat (::Type{DataValueCategoricalArray{DataValue{CategoricalValue{T, R}}, N, R}}){T, N, R}(dims::NTuple{N,Int};
                                                                                            ordered=false) =
    DataValueCategoricalArray{T, N, R}(dims; ordered=ordered)
@compat (::Type{DataValueCategoricalArray{DataValue{CategoricalValue{T}}, N, R}}){T, N, R}(dims::NTuple{N,Int};
                                                                                         ordered=false) =
    DataValueCategoricalArray{T, N, R}(dims; ordered=ordered)
@compat (::Type{DataValueCategoricalArray{DataValue{CategoricalValue{T, R}}, N}}){T, N, R}(dims::NTuple{N,Int};
                                                                                         ordered=false) =
    DataValueCategoricalArray{T, N, R}(dims; ordered=ordered)
@compat (::Type{DataValueCategoricalArray{DataValue{CategoricalValue{T}}, N}}){T, N}(dims::NTuple{N,Int};
                                                                                   ordered=false) =
    DataValueCategoricalArray{T, N}(dims; ordered=ordered)
# @compat (::Type{DataValueCategoricalArray{DataValue{CategoricalValue}, N}}){N}(dims::NTuple{N,Int};
#                                                                               ordered=false) =
#     DataValueCategoricalArray{String, N}(dims; ordered=ordered)
# @compat (::Type{DataValueCategoricalArray{DataValue{CategoricalValue}}}){N}(dims::NTuple{N,Int};
#                                                                            ordered=false) =
#     DataValueCategoricalArray{String, N}(dims; ordered=ordered)

@compat (::Type{DataValueCategoricalVector{DataValue{T}}}){T}(m::Int; ordered=false) =
    DataValueCategoricalArray{T}((n,); ordered=ordered)
@compat (::Type{DataValueCategoricalMatrix{DataValue{T}}}){T}(m::Int, n::Int; ordered=false) =
    DataValueCategoricalArray{T}((m, n); ordered=ordered)

@compat (::Type{DataValueCategoricalArray}){T<:DataValue}(A::AbstractArray{T};
                                                        ordered=_isordered(A)) =
    DataValueCategoricalArray{eltype(T)}(A, ordered=ordered)
@compat (::Type{DataValueCategoricalVector}){T<:DataValue}(A::AbstractVector{T};
                                                         ordered=_isordered(A)) =
    DataValueCategoricalVector{eltype(T)}(A, ordered=ordered)
@compat (::Type{DataValueCategoricalMatrix}){T<:DataValue}(A::AbstractMatrix{T};
                                                         ordered=_isordered(A)) =
    DataValueCategoricalMatrix{eltype(T)}(A, ordered=ordered)

"""
    DataValueCategoricalArray(A::AbstractArray, missing::AbstractArray{Bool};
                             ordered::Bool=false)

Similar to definition above, but marks as null entries for which the corresponding entry
in `missing` is `true`.
"""
function DataValueCategoricalArray{T, N}(A::AbstractArray{T, N},
                                        missing::AbstractArray{Bool, N};
                                        ordered=false)
    res = DataValueCategoricalArray{T, N}(size(A); ordered=ordered)
    @inbounds for (i, x, m) in zip(eachindex(res), A, missing)
        res[i] = ifelse(m, DataValue{T}(), x)
    end

    if method_exists(isless, (T, T))
        levels!(res, sort(levels(res)))
    end

    res
end

"""
    DataValueCategoricalVector(A::AbstractVector, missing::AbstractVector{Bool};
                              ordered::Bool=false)

Similar to definition above, but marks as null entries for which the corresponding entry
in `missing` is `true`.
"""
DataValueCategoricalVector{T}(A::AbstractVector{T},
                             missing::AbstractVector{Bool};
                             ordered=false) =
    DataValueCategoricalArray(A, missing; ordered=ordered)

"""
    DataValueCategoricalMatrix(A::AbstractMatrix, missing::AbstractMatrix{Bool};
                              ordered::Bool=false)

Similar to definition above, but marks as null entries for which the corresponding entry
in `missing` is `true`.
"""
DataValueCategoricalMatrix{T}(A::AbstractMatrix{T},
                             missing::AbstractMatrix{Bool};
                             ordered=false) =
    DataValueCategoricalArray(A, missing; ordered=ordered)

@inline function getindex(A::DataValueCategoricalArray, I...)
    @boundscheck checkbounds(A, I...)
    # Let Array indexing code handle everything
    @inbounds r = A.refs[I...]

    if isa(r, Array)
        return ordered!(arraytype(A)(r, deepcopy(A.pool)),
                        isordered(A))
    else
        S = eltype(eltype(A))
        if r > 0
            @inbounds return DataValue{S}(A.pool[r])
        else
            return DataValue{S}()
        end
    end
end

@inline function setindex!(A::DataValueCategoricalArray, v::DataValue, I::Real...)
    @boundscheck checkbounds(A, I...)
    if isnull(v)
        @inbounds A.refs[I...] = 0
    else
        @inbounds A[I...] = get(v)
    end
end

levels!(A::DataValueCategoricalArray, newlevels::Vector; nullok=false) = _levels!(A, newlevels, nullok=nullok)

droplevels!(A::DataValueCategoricalArray) = levels!(A, _unique(Array, A.refs, A.pool))

unique{T}(A::DataValueCategoricalArray{T}) = _unique(DataValueArray{T}, A.refs, A.pool)

function in{T, N, R}(x::DataValue, y::DataValueCategoricalArray{T, N, R})
    ref = get(y.pool, get(x), zero(R))
    ref != 0 ? ref in y.refs : false
end

function in{S<:CategoricalValue, T, N, R}(x::DataValue{S}, y::DataValueCategoricalArray{T, N, R})
    v = get(x)
    if v.pool === y.pool
        return v.level in y.refs
    else
        ref = get(y.pool, index(v.pool)[v.level], zero(R))
        return ref != 0 ? ref in y.refs : false
    end
end

in{T, N, R}(x::Any, y::DataValueCategoricalArray{T, N, R}) = false
in{T, N, R}(x::CategoricalValue, y::DataValueCategoricalArray{T, N, R}) = false
