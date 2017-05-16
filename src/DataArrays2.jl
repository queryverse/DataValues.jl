__precompile__(true)

module DataArrays2

using Compat
using Compat.view
using Reexport
@reexport using Base.Cartesian
@reexport using DataValues

export DataArray2,
       DataVector2,
       DataMatrix2,

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
include("show.jl")
include("subarray.jl")

end
