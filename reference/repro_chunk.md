# Reproduce Code Chunk

A short description...

## Usage

``` r
repro_chunk(x, ..., env = rlang::caller_env())
```

## Arguments

- x:

  [`reactive`](https://rdrr.io/pkg/shiny/man/reactive.html) object to
  make reproducible

- ...:

  Additional arguments to pass to other methods

- env:

  The environment `x` is defined in. By default it is the environment of
  where `repro` is called

## Value

A
[`Repro`](https://jubilant-dollop-5lekoky.pages.github.io/reference/repro_s7.md)
object containing all the necessary code and packages to recreate the
provided expression when evaluated.

## Details

Whilst a default is provided to `env`, it is unlikely that this is the
same environment `x` is defined in. This is more of a placeholder for
sending the correct environment to
