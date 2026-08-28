# Registered Reactives

The reactives registered against a session by
[`register_reactives()`](https://ascentsoftware.github.io/shinyreprex/reference/register_reactives.md).

## Usage

``` r
registered_reactives(session)
```

## Arguments

- session:

  A Shiny session object, or `NULL` when called outside Shiny

## Value

A named list of reactives, empty if none have been registered.
