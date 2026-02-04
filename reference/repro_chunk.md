# Reproduce Code Chunk

Evaluate a chunk of code to extract Shiny inputs and reactives,
replacing the inputs with the values selected by the user, and the
reactives with the code bodies used to generate them.

## Usage

``` r
repro_chunk(x, repro_code = Repro(), env = rlang::caller_env())
```

## Arguments

- x:

  [`shiny::reactive()`](https://rdrr.io/pkg/shiny/man/reactive.html)
  object to make reproducible

- repro_code:

  A `Repro` object to store calls found in `x`. By default it is empty,
  but if `x` is not the first call within an expression, this will have
  prior calls and pre-requesites that might be used in `x`.

- env:

  The environment `x` is defined in. By default it is the environment of
  where `repro` is called

## Value

A `Repro` object containing all the necessary code and packages to
recreate the provided expression when evaluated.

## Details

Whilst a default is provided to `env`, it is unlikely that this is the
same environment `x` is defined in. This allows the top-level `repro`
call
