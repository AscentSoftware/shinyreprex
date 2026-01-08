# Call Checks

A set of helper functions that determine what type of call is being made
within an expression.

`is_reactive_call` checks whether or not the call is evaluating a
[`reactive`](https://rdrr.io/pkg/shiny/man/reactive.html) variable.

`is_reactive_val_call` checks whether or not the call is evaluating a
[`reactiveVal`](https://rdrr.io/pkg/shiny/man/reactiveVal.html)
variable.

`is_reactive_values_call` checks whether or not the call is evaluating
an item within a
[`reactiveValues`](https://rdrr.io/pkg/shiny/man/reactiveValues.html)
variable.

`is_any_reactive_call` checks whether or not the call points to
evaluating a `reactive`, `reactiveVal` or `reactiveValues`.

`is_input_call` checks whether or not the call points to evaluate an
input value.

`is_session_user_data` checks whether or not the call points to evaluate
an object within `session$userData`

## Usage

``` r
is_reactive_call(x, env = rlang::caller_env())

is_reactive_val_call(x, env = rlang::caller_env())

is_reactive_values_call(x, env = rlang::caller_env())

is_any_reactive_call(x, env = rlang::caller_env())

is_input_call(x)

is_session_user_data(x)
```

## Arguments

- x:

  An R call object

- env:

  The environment the call is being made, by default it is the
  environment calling the check, but is likely the environment the call
  is being made i.e. the reactive expression.

## Value

A boolean value determining whether or not the call check has passed.
