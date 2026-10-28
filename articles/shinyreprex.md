# Introduction to shinyreprex

## Using shinyreprex

`reprex_reactive` takes a reactive object and converts it into a script
that can be reused outside of the Shiny application to reproduce the
result of the reactive. This can be sent to a simple
`verbatimTextOutput` or something more UX friendly such as the
[highlighter](https://federiva.github.io/highlighter/) package to
display the script in the UI.

A script on its own reproduces the *code*, but not the environment it
ran in. The remaining three functions close that gap:

| Function | Purpose |
|----|----|
| `reprex_reactive` | Turn a reactive into a stand-alone script |
| `reprex_packages` | List the packages needed to run that script |
| `reprex_lockfile` | Capture those packages, their versions and sources as an `renv` lockfile |
| `reprex_header` | Capture the same information as a single `ir` header, pasted above the script |
| `register_reactives` | Record reactives so the functions above can be called with no arguments |

A worked example covering all four ships with the package:

``` r

shiny::runExample("lockfile", package = "shinyreprex")
```

## Reproducing the Environment

`reprex_reactive` emits the
[`library()`](https://rdrr.io/r/base/library.html) calls a script needs,
but not the versions those packages were at. `reprex_lockfile` records
them, along with the R version and the full recursive dependency tree,
so the environment can be rebuilt rather than approximated.

``` r

output$lockfile <- downloadHandler(
  filename = function() "renv.lock",
  content = function(file) reprex_lockfile(summary_tbl, lockfile = file)
)
```

Whoever receives the lockfile restores it with `renv`:

``` r

renv::restore(lockfile = "renv.lock")
```

Use `reprex_packages` when you want to show the detected packages before
pinning them, for example to let the user narrow the set:

``` r

reprex_lockfile(summary_tbl, packages = input$packages, lockfile = file)
```

Supplying `packages` is also the escape hatch when the detector cannot
see a package, such as one attached only for an operator or an S3
method.

## Reproducing Without a Separate File

Sharing a lockfile means sharing two files: the script, and the
`renv.lock` that goes with it. `reprex_header` packs the same package
versions, R version and a dependency snapshot date into a comment block
at the top of the script itself, using
[`ir`](https://github.com/r-lib/ir), so there’s only the one file to
send. Pass `header = TRUE` to `reprex_reactive` to prepend it:

``` r

output$code <- renderText(reprex_reactive(summary_tbl, header = TRUE))
```

Arguments after `header` are forwarded to `reprex_header`, for example
to pin the snapshot date explicitly rather than defaulting to today:

``` r

reprex_reactive(summary_tbl, header = TRUE, exclude_newer = "2025-05-15")
```

Call `reprex_header` directly, rather than through `reprex_reactive`, to
cover several reactives with one header.

Whoever receives the script runs it with `ir run script.R`, with no
project or lockfile to restore first. `ir` resolves the recursive
dependency tree itself, by pinning CRAN and Bioconductor to the snapshot
named by `exclude_newer`, rather than recording every transitive package
explicitly as `reprex_lockfile` does. Everything said above about
`packages`, `exclude` and `register_reactives` for `reprex_lockfile`
applies the same way to `reprex_header`.

### Registering Reactives Across Modules

In a modular application the reactives worth reproducing live inside
their own modules. Rather than returning them all up to the top level,
each module registers what it owns:

``` r

summaryServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    summary_tbl <- reactive({
      aggregate(Sepal.Width ~ Species, data = iris, FUN = get(input$summary_fn))
    })

    register_reactives(summary_tbl)

    summary_tbl
  })
}
```

[`reprex_lockfile()`](https://ascentsoftware.github.io/shinyreprex/reference/reprex_lockfile.md)
and
[`reprex_packages()`](https://ascentsoftware.github.io/shinyreprex/reference/reprex_packages.md)
then cover the whole application when called with no arguments.
Registrations are namespaced by module, held on the session, and
discarded when the session ends, so they are never shared between
concurrent users.

## Best Practices

### Bind `reprex_reactive` call to Event

The code to reproduce a given reactive will be updated whenever an input
or reactive feeding into the provided reactive is updated, therefore it
is recommended to have the reactive as an event attached.

``` r

width_range <- reactive({
  iris_filt <- dplyr::filter(iris, Species == "versicolor")
  range(iris_filt$Petal.Width)
})

# Good
repro_range <- reactive(reprex_reactive(width_range)) |>
  bindEvent(width_range())
  
# Bad
repro_range <- reactive(reprex_reactive(width_range))
```

### Register Reactives at Module Setup

`register_reactives` does not evaluate the reactive it is given, so it
can be called as soon as the reactive is defined, even when that
reactive is still gated behind
[`shiny::req`](https://rdrr.io/pkg/shiny/man/req.html) or inputs that
have yet to be set. Registering at setup means a lockfile covers every
module regardless of which parts of the application the user happened to
visit.

``` r

# Good
summary_tbl <- reactive({
  shiny::req(input$summary_fn)
  aggregate(Sepal.Width ~ Species, data = iris, FUN = get(input$summary_fn))
})

register_reactives(summary_tbl)

# Bad - the reactive is only registered once the user has viewed the output,
# so a lockfile downloaded beforehand silently misses it
output$table <- renderTable({
  register_reactives(summary_tbl)
  summary_tbl()
})
```

### Put Side-Effects in Observers

This is general best-practice when developing Shiny applications, but
avoid putting code for its side effects in `reactive` expressions, and
instead create smaller reactive calls, and have observers running the
code not intended for reproducing outputs.

``` r

# Good
width_range <- reactive({
  iris_filt <- dplyr::filter(iris, Species == "versicolor")
  range(iris_filt$Petal.Width)
})

observe({
  updateSliderInput("width", width_range())
})

# Bad
width_range <- reactive({
  iris_filt <- dplyr::filter(iris, Species == "versicolor")
  widths <- range(iris_filt$Petal.Width)
  updateSliderInput("width", widths)
  widths
})

summary_data <- reactive({
  iris_filt <- dplyr::filter(iris, Species == "versicolor")
  shinyjs::toggle("table", condition = nrow(iris_filt) > 0L)
  dplyr::summarise(iris_filt, dplyr::across(where(is.numeric), mean))
})
```

### Create a Business Logic Package

In order that developers can easily recreate outputs generated in Shiny
applications, add any business logic, such as ETL, data manipulation and
modelling, to a separate package. This will allow users to recreate the
tables and plots generated in the app without having to install all the
packages associated with the application.

### Use Secrets in Reactives

If you are using secrets, such as environment variables, make sure that
they are defined within a reactive expression. If it is defined in the
module, or in the global environment, the secret will be written in the
assignment.

``` r

# Good
moduleServer(id, function(input, output, session) {
  my_reactive <- reactive({
    api_key <- Sys.getenv("MY_API_KEY")
    ...
  })
})

# Bad
moduleServer(id, function(input, output, session) {
  api_key <- Sys.getenv("MY_API_KEY")

  my_reactive <- reactive({
    ...
  })
})
```

## Limitations

Reproducible code is generated by reading the expression held in a
reactive, rather than by tracing what it does when it runs. That keeps
the process cheap and independent of the current inputs, but it sets
some boundaries worth knowing about.

### Only the Reactive Expression is Read

Calls made inside a function that is defined elsewhere are not visited,
so anything used only in that function is neither reproduced nor
detected as a package.

``` r

summarise_widths <- function(dat) dplyr::summarise(dat, mean(Petal.Width))

my_reactive <- reactive(summarise_widths(iris))
```

Here the script reproduces the call to `summarise_widths`, but `dplyr`
is not reported. Keeping the work inside the reactive, or moving it into
a package that the recipient installs, avoids this. See also *Create a
Business Logic Package* above.

### Non-Standard Evaluation is Best-Effort

Data-masking functions such as
[`dplyr::filter`](https://dplyr.tidyverse.org/reference/filter.html) or
`subset` refer to columns as if they were variables. Since the column
names are only distinguishable from real variables at run time, a
collision between the two can produce a misleading line in the script:

``` r

moduleServer(id, function(input, output, session) {
  Species <- "versicolor"

  my_reactive <- reactive(subset(iris, Species == "setosa"))
})
```

`Species` in the reactive is a column of `iris`, but a variable of the
same name exists in the module, so the script includes an unnecessary
`Species <- "versicolor"` assignment. The reproduced code still runs,
because `subset` masks the variable with the column, but the extra line
is misleading. Avoiding names that clash with the columns being masked
avoids this.

Similarly, an input captured with
[`rlang::quo`](https://rlang.r-lib.org/reference/defusing-advanced.html)
and spliced back in later cannot be resolved to its value, and appears
in the script with the `!!` still in place.

### Detected Packages Can Be a Superset

`reprex_packages` walks every branch of an `if` or `switch` rather than
evaluating the condition and following only the branch that would be
taken. A lockfile may therefore pin a package that the script does not
end up needing. This is deliberate: a lockfile holding a package that is
not needed is safer than one missing a package that is.
