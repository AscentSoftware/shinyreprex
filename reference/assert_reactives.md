# Reactive Object Check

Confirm every object supplied is an unevaluated reactive, raising an
error that names the calling function so the message points at the
user's call.

## Usage

``` r
assert_reactives(reactives, fn_name)
```

## Arguments

- reactives:

  A list of objects to check

- fn_name:

  Name of the calling function, used in the error message

## Value

`NULL`, invisibly. Called for its side effect of raising an error.
