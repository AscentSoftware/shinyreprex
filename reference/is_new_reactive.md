# Reactive Variables Definition Check

A helper function to check whether or not the reactive variables to be
added to the `Repro` object already exists. Used to avoid duplicate
definitions being added to a script.

## Usage

``` r
is_new_reactive(new, exisitng)
```

## Arguments

- new, exisitng:

  A named list of reactive variable definitions

## Value

A boolean stating whether or not there is at least one reactive
definition in `new` that doesn't exist in `existing`
