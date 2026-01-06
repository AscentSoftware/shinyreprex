# Reproducible Code

An S7 object that holds the code and packages required to re-create a
given reactive.

## Usage

``` r
Repro(code = list(), packages = character(0), prerequisites = list())
```

## Arguments

- code:

  Code chunks found in a given expression

- packages:

  Packages found in the function calls in the code and/or pre-requisites

- prerequisites:

  Code chunks used to generate reactive objects found in the code
