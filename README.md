
DataArrays2.jl
=================
[![Build Status](https://travis-ci.org/davidanthoff/DataArrays2.jl.svg?branch=master)](https://travis-ci.org/davidanthoff/DataArrays2.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/4lyet4un2wv4altx/branch/master?svg=true)](https://ci.appveyor.com/project/davidanthoff/dataarrays2-jl/branch/master)
[![DataArrays2](http://pkg.julialang.org/badges/DataArrays2_0.6.svg)](http://pkg.julialang.org/?pkg=DataArrays2)
[![codecov.io](http://codecov.io/github/davidanthoff/DataArrays2.jl/coverage.svg?branch=master)](http://codecov.io/github/davidanthoff/DataArrays2.jl?branch=master)

DataArrays2.jl provides the `DataArray2{T, N}` type and its respective interface for use in storing and managing data with missing values.


`DataArray2{T, N}` is implemented as a subtype of `AbstractArray{DataValue{T}, N}` and inherits functionality from the `AbstractArray` interface.

Missing Values
==============
The central contribution of DataArrays2.jl is to provide a data structure that uses a single type, namely `DataValue{T}` to represent both present and missing values. `DataValue{T}` is a specialized container type that contains precisely either one or zero values. A `DataValue{T}` object that contains a value represents a present value of type `T` that, under other circumstances, might have been missing, whereas an empty `DataValue{T}` object represents a missing value that, under other circumstances, would have been of type `T` had it been present.

Indexing into a `DataArray2{T}` is thus "type-stable" in the sense that `getindex(X::DataArray2{T}, i)` will always return an object of type `DataValue{T}` regardless of whether the returned entry is present or missing. In general, this behavior more robustly supports the Julia compiler's ability to produce specialized lower-level code than do analogous data structures that use a token `NA` type to represent missingness.

Constructors
============
There are a number of ways to construct a `DataArray2` object. Passing a single `Array{T, N}` object to the `DataArray2()` constructor will create a `DataArray2{T, N}` object with all present values:
```julia
julia> julia> DataArray2(collect(1:5))
5-element DataArray2{Int64,1}:
 1
 2
 3
 4
 5
 ```
 To indicate that certain values ought to be represented as missing, one can pass an additional `Array{Bool, N}` argument; any index `i` for which the latter argument contains a `true` entry will return an missing value from the resultant `DataArray2` object:
 ```julia
julia> X = DataArray2([1, 2, 3, 4, 5], [true, false, false, true, false])
5-element DataArray2{Int64,1}:
 #NULL
     2
     3
 #NULL
     5
 ```
 Note that the sizes of the two `Array` arguments passed to the above constructor method must be equal.
 
 `DataArray2`s are designed to look and feel like regular `Array`s where possible and appropriate. Thus `display`ing a `DataArray2` object prints the values of present entries and `#NULL` designator for missing entries. It is important to note, however, that there is no such `#NULL` object, and that indexing into a `DataArray2` *always* returns a `DataValue` object, regardless of whether the entry at the specified index is missing or present:

```julia
julia> X[1]
DataValue{Int64}()

julia> X[2]
DataValue(2)
```

One can initialize an empty `DataArray2` object by calling `DataArray2(T, dims)`, where `T` is the desired element type of the resultant `DataArray2` and `dims` is either a tuple or sequence of integer arguments designating the size of the resultant `DataArray2`:

```julia
julia> DataArray2(Char, 3, 3)
3x3 DataArray2{Char,2}:
 #NULL  #NULL  #NULL
 #NULL  #NULL  #NULL
 #NULL  #NULL  #NULL
 ```

Indexing
========
Indexing into a `DataArray2{T}` is just like indexing into a regular `Array{T}`, except that the returned object will always be of type `DataValue{T}` rather than type `T`. One can expect any indexing pattern that works on an `Array` to work on a `DataArray2`. This includes using a `DataArray2` to index into any container object that sufficiently implements the `AbstractArray` interface:
```julia
julia> A = [1:5...]
5-element Array{Int64,1}:
 1
 2
 3
 4
 5

julia> X = DataArray2([2, 3])
2-element DataArray2{Int64,1}:
 2
 3

julia> A[X]
2-element Array{Int64,1}:
 2
 3
 ```
 Note, however, that attempting to index into any such `AbstractArray` with a null value will incur an error:
```julia
julia> Y = DataArray2([2, 3], [true, false])
2-element DataArray2{Int64,1}:
 #NULL
     3      

julia> A[Y]
ERROR: NullException()
 in _checkbounds at /Users/David/.julia/v0.4/DataArrays2/src/indexing.jl:73
 in getindex at abstractarray.jl:424
 ```

`DataArray2` Implementation Details
======================
Under the hood of each `DataArray2{T, N}` object are two fields: a `values::Array{T, N}` field and an `isnull::Array{Bool, N}` field:
```julia
julia> fieldnames(DataArray2)
2-element Array{Symbol,1}:
 :values
 :isnull
 ```
The `isnull` array designates whether indexing into an `X::DataArray2` at a given index `i` ought to return a present or missing value.
