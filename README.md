
DataValueArrays.jl
=================
[![Build Status](https://travis-ci.org/davidanthoff/DataValueArrays.jl.svg?branch=master)](https://travis-ci.org/davidanthoff/DataValueArrays.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/hspknlh93ma48ixr/branch/master?svg=true)](https://ci.appveyor.com/project/davidanthoff/datavaluearrays-jl/branch/master)(https://ci.appveyor.com/project/davidanthoff/DataValueArrays-jl/branch/master)
[![DataValueArrays](http://pkg.julialang.org/badges/DataValueArrays_0.6.svg)](http://pkg.julialang.org/?pkg=DataValueArrays)
[![codecov.io](http://codecov.io/github/davidanthoff/DataValueArrays.jl/coverage.svg?branch=master)](http://codecov.io/github/davidanthoff/DataValueArrays.jl?branch=master)

DataValueArrays.jl provides the `DataValueArray{T, N}` type and its respective interface for use in storing and managing data with missing values.

`DataValueArray{T, N}` is implemented as a subtype of `AbstractArray{DataValue{T}, N}` and inherits functionality from the `AbstractArray` interface.

Missing Values
==============
The central contribution of DataValueArrays.jl is to provide a data structure that uses a single type, namely `DataValue{T}` to represent both present and missing values. `DataValue{T}` is a specialized container type that contains precisely either one or zero values. A `DataValue{T}` object that contains a value represents a present value of type `T` that, under other circumstances, might have been missing, whereas an empty `DataValue{T}` object represents a missing value that, under other circumstances, would have been of type `T` had it been present.

Indexing into a `DataValueArray{T}` is thus "type-stable" in the sense that `getindex(X::DataValueArray{T}, i)` will always return an object of type `DataValue{T}` regardless of whether the returned entry is present or missing. In general, this behavior more robustly supports the Julia compiler's ability to produce specialized lower-level code than do analogous data structures that use a token `NA` type to represent missingness.

Constructors
============
There are a number of ways to construct a `DataValueArray` object. Passing a single `Array{T, N}` object to the `DataValueArray()` constructor will create a `DataValueArray{T, N}` object with all present values:
```julia
julia> julia> DataValueArray(collect(1:5))
5-element DataValueArray{Int64,1}:
 1
 2
 3
 4
 5
 ```
 To indicate that certain values ought to be represented as missing, one can pass an additional `Array{Bool, N}` argument; any index `i` for which the latter argument contains a `true` entry will return an missing value from the resultant `DataValueArray` object:
 ```julia
julia> X = DataValueArray([1, 2, 3, 4, 5], [true, false, false, true, false])
5-element DataValueArray{Int64,1}:
 #NULL
     2
     3
 #NULL
     5
 ```
 Note that the sizes of the two `Array` arguments passed to the above constructor method must be equal.
 
 `DataValueArray`s are designed to look and feel like regular `Array`s where possible and appropriate. Thus `display`ing a `DataValueArray` object prints the values of present entries and `#NULL` designator for missing entries. It is important to note, however, that there is no such `#NULL` object, and that indexing into a `DataValueArray` *always* returns a `DataValue` object, regardless of whether the entry at the specified index is missing or present:

```julia
julia> X[1]
DataValue{Int64}()

julia> X[2]
DataValue(2)
```

One can initialize an empty `DataValueArray` object by calling `DataValueArray(T, dims)`, where `T` is the desired element type of the resultant `DataValueArray` and `dims` is either a tuple or sequence of integer arguments designating the size of the resultant `DataValueArray`:

```julia
julia> DataValueArray(Char, 3, 3)
3x3 DataValueArray{Char,2}:
 #NULL  #NULL  #NULL
 #NULL  #NULL  #NULL
 #NULL  #NULL  #NULL
 ```

Indexing
========
Indexing into a `DataValueArray{T}` is just like indexing into a regular `Array{T}`, except that the returned object will always be of type `DataValue{T}` rather than type `T`. One can expect any indexing pattern that works on an `Array` to work on a `DataValueArray`. This includes using a `DataValueArray` to index into any container object that sufficiently implements the `AbstractArray` interface:
```julia
julia> A = [1:5...]
5-element Array{Int64,1}:
 1
 2
 3
 4
 5

julia> X = DataValueArray([2, 3])
2-element DataValueArray{Int64,1}:
 2
 3

julia> A[X]
2-element Array{Int64,1}:
 2
 3
 ```
 Note, however, that attempting to index into any such `AbstractArray` with a null value will incur an error:
```julia
julia> Y = DataValueArray([2, 3], [true, false])
2-element DataValueArray{Int64,1}:
 #NULL
     3      

julia> A[Y]
ERROR: NullException()
 in _checkbounds at /Users/David/.julia/v0.4/DataValueArrays/src/indexing.jl:73
 in getindex at abstractarray.jl:424
 ```

`DataValueArray` Implementation Details
======================
Under the hood of each `DataValueArray{T, N}` object are two fields: a `values::Array{T, N}` field and an `isnull::Array{Bool, N}` field:
```julia
julia> fieldnames(DataValueArray)
2-element Array{Symbol,1}:
 :values
 :isnull
 ```
The `isnull` array designates whether indexing into an `X::DataValueArray` at a given index `i` ought to return a present or missing value.
