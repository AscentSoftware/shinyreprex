# Reactive Expression and Environment

Extract the unevaluated body of a reactive, along with the environment
it was assigned in.

### Environments

The `Observable` object attached to the given reactive is extracted.
Within the `Observable`, the `.origFunc` contains the environment that
the reactive expression was created - the parent environment being the
module that the reactive is assigned in. This allows the variables in
the module to be found and set as pre-requisites for the given reactive.

If `bindCache` or `bindEvent` are used, then the environment found is
the call within the relevant function. To get to the module environment,
we find that the `reactive` is assigned as "`wrappedFunc`", so that is
used to find the module environment.

## Usage

``` r
reactive_expression(x)
```

## Arguments

- x:

  A [`shiny::reactive`](https://rdrr.io/pkg/shiny/man/reactive.html)
  object

## Value

A list with two elements: `body`, the unevaluated body of the reactive,
and `env`, the module environment the reactive was assigned in.
