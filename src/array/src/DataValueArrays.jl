__precompile__(true)

module DataValueArrays

using Reexport
@reexport using Base.Cartesian
@reexport using DataValues

export DataValueArray,
       DataValueVector,
       DataValueMatrix,

       # Macros

       # Methods
       dropnull,
       dropnull!,
       nullify!,
       padnull!,
       padnull

include("typedefs.jl")
include("constructors.jl")
include("primitives.jl")
include("indexing.jl")
include("broadcast.jl")
include("map.jl")
include("nullablevector.jl")
include("reduce.jl")
include("subarray.jl")

end
