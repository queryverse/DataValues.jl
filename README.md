# DataValues

[![Project Status: Active - The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![Build Status](https://travis-ci.org/davidanthoff/DataValues.jl.svg?branch=master)](https://travis-ci.org/davidanthoff/DataValues.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/v56tyamg56dqy79t/branch/master?svg=true)](https://ci.appveyor.com/project/davidanthoff/DataValues-jl/branch/master)
[![DataValues](http://pkg.julialang.org/badges/DataValues_0.6.svg)](http://pkg.julialang.org/?pkg=DataValues)
[![codecov](https://codecov.io/gh/davidanthoff/DataValues.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/davidanthoff/DataValues.jl)

## Overview

This package provides the type ``DataValue`` that is used to represent
missing data.  The type is very similar to ``Nullable`` in julia base.
It differs from ``Nullable`` by providing a small number of  additional
features that make common operations on data easier.

Currently the main use of this type is in the
[Query.jl](https://github.com/davidanthoff/Query.jl),
[IterableTables.jl](https://github.com/davidanthoff/IterableTables.jl) and
[DataValueArrays.jl](https://github.com/davidanthoff/DataValueArrays.jl)
package.

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
- The package provides many lifted methods.
- One can access or unpack the value within a ``DataValue`` either via the
``get(x)`` function, or use the ``x[]`` syntax.

Any help with this package would be greatly appreciated!
