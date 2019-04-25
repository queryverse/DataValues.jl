__precompile__()
module DataValues

using Dates

import Nullables

export DataValue, DataValueException, NA

export DataValueArray, DataValueVector, DataValueMatrix

export isna, hasvalue, dropna, dropna!, padna!, padna

include("scalar/core.jl")
# TODO 0.7 migration, enable again
# include("scalar/broadcast.jl")
include("scalar/operations.jl")

include("array/typedefs.jl")
include("array/constructors.jl")
include("array/indexing.jl")
include("array/datavaluevector.jl")
include("array/primitives.jl")
# TODO 0.7 migration, enable again
# include("array/broadcast.jl")
include("array/reduce.jl")
include("array/promotion.jl")

# include("utils.jl")

import TablesAPI
TablesAPI.nondatavaluetype(::Type{DataValue{T}}) where {T} = Union{T, Missing}
TablesAPI.unwrap(x::DataValue) = isna(x) ? missing : DataValues.unsafe_get(x)
TablesAPI.datavaluetype(::Type{T}) where {T <: DataValue} = T
TablesAPI.datavaluetype(::Type{Union{T, Missing}}) where {T} = DataValue{T}
TablesAPI.datavaluetype(::Type{Missing}) = DataValue{Union{}}
TablesAPI.scalarconvert(::Type{T}, ::Missing) where {T <: DataValue} = T()

end
