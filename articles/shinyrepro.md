# Introduction to shinyrepro

``` r
library(shinyrepro)
```

## Using shinyrepro

There is a single exported function, `repro`, that will take a reactive
object, and returns a character vector of the code required to run
outside of Shiny to re-create the specified reactive.

## Limitations

### Anonymous Functions

Currently it is hard to check the contents of anonymous functions for
inputs and/or reactive objects, such as functions used in the `apply`
family functions or
[`purrr::map`](https://purrr.tidyverse.org/reference/map.html). The
workaround for this is to have them as named arguments, therefore they
are sent to the anonymous function as updated in shinyrepro.

``` r
# Bad
purrr::map_dbl(1:10, \(x) x * input$mult)

# Good
purrr::map_dbl(1:10, mult = input$mult, \(x, mult) x * mult)
```
