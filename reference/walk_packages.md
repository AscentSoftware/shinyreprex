# Collect Packages From an Expression

Walk an expression and collect the packages of every call found within
it, without reproducing any of the code. This is a deliberately cheap
alternative to
[`repro_chunk()`](https://ascentsoftware.github.io/shinyreprex/reference/repro_chunk.md)
for the cases that only need the package list, such as
[`reprex_packages()`](https://ascentsoftware.github.io/shinyreprex/reference/reprex_packages.md)
and
[`reprex_lockfile()`](https://ascentsoftware.github.io/shinyreprex/reference/reprex_lockfile.md).

### Why Not Reproduce the Code

Reproducing a chunk substitutes reactive and input values into the
expression, which means constructing every module variable as code via
[`constructive::construct`](https://cynkra.github.io/constructive/reference/construct.html).
For a module holding a data frame that dominates the run time, and all
of it is discarded when only the packages are wanted.

### Branches Are Not Evaluated

Every branch of an `if` or `switch` is walked, rather than evaluating
the condition and following only the branch that would be taken. A
lockfile is safer for containing a package that turns out not to be
needed than for missing one, and not evaluating keeps the walk both
faster and independent of the current input values.

## Usage

``` r
walk_packages(expr, env, seen = character(), packages = character())
```

## Arguments

- expr:

  An expression to walk

- env:

  The environment the expression belongs to, used to identify calls to
  other reactives

- seen:

  Names of reactives already walked, preventing a reactive that is
  referenced more than once from being walked repeatedly

- packages:

  Packages collected so far

## Value

A character vector of unique package names, excluding base packages.
