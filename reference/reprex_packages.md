# Packages Required to Reproduce Reactives

Extract the set of non-base packages needed to reproduce one or more
[`shiny::reactive`](https://rdrr.io/pkg/shiny/man/reactive.html)
objects, with duplicates removed across every reactive passed.

Use this when building a custom UI around
[`reprex_lockfile()`](https://ascentsoftware.github.io/shinyreprex/reference/reprex_lockfile.md):
it gives you the list of detected packages to present to the user for
selection.

Packages are found by reading the expression held in each reactive
rather than by generating its script, so every branch of an `if` or
`switch` contributes. The result may therefore be a superset of the
[`library()`](https://rdrr.io/r/base/library.html) calls
[`reprex_reactive()`](https://ascentsoftware.github.io/shinyreprex/reference/reprex_reactive.md)
emits for the branch actually taken, on the basis that a lockfile is
safer holding a package that is not needed than missing one.

## Usage

``` r
reprex_packages(..., session = shiny::getDefaultReactiveDomain())
```

## Arguments

- ...:

  One or more
  [`shiny::reactive`](https://rdrr.io/pkg/shiny/man/reactive.html)
  objects to inspect. If none are supplied, every reactive registered
  against `session` by
  [`register_reactives()`](https://ascentsoftware.github.io/shinyreprex/reference/register_reactives.md)
  is used.

- session:

  The Shiny session to read registered reactives from. Only used when
  `...` is empty. Defaults to the current reactive domain.

## Value

A character vector of unique package names. Base packages are excluded,
as they require no installation.

## See also

[`reprex_lockfile()`](https://ascentsoftware.github.io/shinyreprex/reference/reprex_lockfile.md)
to turn this set into an `renv` lockfile, and
[`register_reactives()`](https://ascentsoftware.github.io/shinyreprex/reference/register_reactives.md)
to record reactives from within each module.

## Examples

``` r
library(shiny)

numeric_iris <- reactive(purrr::keep(iris, is.numeric))
styled_code <- reactive(styler::style_text("1 + 1"))

# Outside a running application, isolate supplies the reactive context
isolate(reprex_packages(numeric_iris, styled_code))
#> [1] "purrr"  "styler"
```
