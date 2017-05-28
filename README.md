# DataValues

[![Project Status: Active - The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![Build Status](https://travis-ci.org/davidanthoff/DataValues.jl.svg?branch=master)](https://travis-ci.org/davidanthoff/DataValues.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/v56tyamg56dqy79t/branch/master?svg=true)](https://ci.appveyor.com/project/davidanthoff/DataValues-jl/branch/master)
[![DataValues](http://pkg.julialang.org/badges/DataValues_0.6.svg)](http://pkg.julialang.org/?pkg=DataValues)
[![codecov](https://codecov.io/gh/davidanthoff/DataValues.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/davidanthoff/DataValues.jl)

## Overview

This package provides the type ``DataValue`` that is used to represent
missing data. Currently the main use of this type is in the
[Query.jl](https://github.com/davidanthoff/Query.jl) package. The type
is very similar to ``Nullable`` in julia base. It differs from ``Nullable``,
by providing a small number of  additional features that make common
operations on data easier.

This repo is based on the following principles/ideas:

- This type is meant to make life for data scientists as easy as possible.
That is the main guiding principle.
- We hook into the dot broadcasting mechanism from julia 0.6 to provide
lifting functionality for functions that don't have specific methods
for ``DataValue`` arguments.
- The ``&`` and ``|`` operators follow the [3VL](https://en.wikipedia.org/wiki/Three-valued_logic)
semantics for ``DataValue``s.
- Comparison operators like ``==``, ``<`` etc. on ``DataValue``s return
``Bool`` values, i.e. they are normal [predicates](https://en.wikipedia.org/wiki/Predicate_(mathematical_logic)).
- Common arithmetic inplace operators like ``+`` have methods that lift
``DataValue`` arguments without the use of the dot broadcast syntax.

Any help with this package would be greatly appreciated!

## Relationship of DataValues.jl with DataValueOperations.jl

The packages [DataValues.jl](https://github.com/davidanthoff/DataValues.jl)
and [DataValueOperations.jl](https://github.com/davidanthoff/DataValueOperations.jl)
go hand in hand. [DataValues.jl](https://github.com/davidanthoff/DataValues.jl)
provides the basic ``DataValue`` type, lifted methods for
a few very common functions (mostly infix operators) and call-site lifting
via the ``.`` broadcasting mechanism.
[DataValueOperations.jl](https://github.com/davidanthoff/DataValueOperations.jl)
provides as many lifted methods for all sorts of functions as possible.
It is an implementation of the white listing approach to lifting.

Why have two packages? There is currently a debate whether the call site
lifting via the ``.`` mechanism is a good solution to the lifting problem,
or whether it is too cumbersome. The two package solution for the
``DataValue`` approach allows users to try out the call site lifting approach
and compare it with a more traditional white list approach that is less
verbose. If users want to use the call site lifting approach, they should
use only the [DataValues.jl](https://github.com/davidanthoff/DataValues.jl)
package. If they want to try out the white list approach they should load
the [DataValueOperations.jl](https://github.com/davidanthoff/DataValueOperations.jl)
package. Please report back what you think of both approaches here or over
in the [data domain](https://discourse.julialang.org/c/domain/data) on the
julia forums!

My expectation is that eventually one of these approaches will be picked
as the only support one, and at that point this will go back to a one-package
solution.

In this setup the [DataValueOperations.jl](https://github.com/davidanthoff/DataValueOperations.jl)
package will change how the ``DataValue`` type behaves.
