__precompile__()
module CategoricalArrays
    export CategoricalPool, CategoricalValue
    export AbstractCategoricalArray, AbstractCategoricalVector, AbstractCategoricalMatrix,
           CategoricalArray, CategoricalVector, CategoricalMatrix
    export AbstractDataValueCategoricalArray, AbstractDataValueCategoricalVector,
           AbstractDataValueCategoricalMatrix,
           DataValueCategoricalArray, DataValueCategoricalVector, DataValueCategoricalMatrix
    export LevelsException

    export categorical, compress, decompress, droplevels!, levels, levels!, isordered, ordered!
    export cut, recode, recode!

    using Compat
    using DataValues

    include("typedefs.jl")

    include("buildfields.jl")

    include("pool.jl")
    include("value.jl")

    include("array.jl")
    include("nullablearray.jl")
    include("subarray.jl")

    include("extras.jl")
    include("recode.jl")

    include("deprecated.jl")
end
