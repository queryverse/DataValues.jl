__precompile__()
module DataValues

export DataValue, DataValueException, NA

export DataValueArray, DataValueVector, DataValueMatrix

export dropna, dropna!#, nullify!, padnull!, padnull 

include("scalar/core.jl")
include("scalar/broadcast.jl")
include("array.jl")
include("utils.jl")
include("scalar/operations.jl")

end
