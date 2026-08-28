# Environment of a Called Reactive

Find the environment holding the reactive a call refers to, checking the
expression's own environment before the environment it was passed in
from.

## Usage

``` r
call_reactive_env(expr, env)
```

## Arguments

- expr:

  An expression to check

- env:

  The environment the expression belongs to

## Value

The environment holding the reactive, or `NULL` if the call is not to a
reactive.
