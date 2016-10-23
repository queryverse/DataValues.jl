# NAables

## Overview

This package provides the type ``NAable`` that is used to represent missing data in the julia data stack. The type is very similar to ``Nullable`` in the julia base library.

This repo is based on the following principles/ideas:

- This type is meant to make life for data scientists as easy as possible. That is the main guiding principle.
- We provided as many lifted methods as possible for all sorts of functions. This package follows what is know as the "whitelist" approach to lifting.
- This package does not have a single hard rule about lifting semantics. Instead, decisions are made case by case. As guiding principles are identifed, we will add them to this list.
- A first principle is that the ``&`` and ``|`` operators follow the [3VL](https://en.wikipedia.org/wiki/Three-valued_logic) semantics.
- A second principle is that lifted versions of [predicates](https://en.wikipedia.org/wiki/Predicate_(mathematical_logic)) return a ``Bool`` value. For example all comparison operators like ``==`` return a ``Bool``.
- A third principle is that mathematical functions like ``+`` or ``log`` return a missing value if any of their inputs is missing.

This package reuses the function ``isna`` and the value ``NA`` from the DataArrays.jl package for now. Once ``DataArrays`` is no longer used by [DataFrames.jl](), this dependency will be dropped and `` const NA = NAable{Union{}}()`` will be defined

Any help with this package would be greatly appreciated! Please do submit PRs both for more lifted functions, more tests and better performing implementations of what is here already.
 