# Session Reactive Store

Fetch (creating on first use) the environment holding this session's
registered reactives. An environment is used so that registrations from
module servers mutate a single shared collection.

## Usage

``` r
reprex_store(session)
```

## Arguments

- session:

  A Shiny session object

## Value

An environment with a `reactives` element, a named list of reactives.
