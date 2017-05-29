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
- Common arithmetic inplace operators like ``+`` have methods that lift
``DataValue`` arguments without the use of the dot broadcast syntax.
- The package provides a configurable whitelist approach to lifting (see
below).

Any help with this package would be greatly appreciated!

## Configurable whitelist lifting

There is currently a debate whether the call site lifting via the ``.``
mechanism is a good solution to the lifting problem, or whether it is
too cumbersome. To gain some data on this question, the package here
implements both the ``.`` mechanism and a more traditional whitelist
approach to lifting. The ``.`` call-site lifting approach is always enabled,
but users can manually enable or disable the whitelist approach by calling
the ``enable_whitelist_lifting()`` and ``disable_whitelist_lifting()``
functions. A call to either of these functions will enable or disable whitelist
lifting as a configuration in the julia package itself, i.e. that choice
is remembered across julia instances. Whitelist lifting is enabled by
default in the package.

When whitelist lifting is enabled, the package aims to add methods with
``DataValue`` arguments to many functions from julia base. If you come
across a function that is missing whitelist lifted methods, please open
a PR or an issue so that we can add those methods.

My expectation is that eventually one of these approaches (``.`` lifting
and whitelist lifting) will be picked as the only supported one, or maybe
someone will find a third, even better option.

Feedback on these two options would be most welcome. In particular, I would
very much appreciate any feedback on whether the ``.`` lifting approach
is indeed too cumbersome or not. Please report back what you think of both
approaches here or over in the [data domain](https://discourse.julialang.org/c/domain/data)
on the julia forums!
