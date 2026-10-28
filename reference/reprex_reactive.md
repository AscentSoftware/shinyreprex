# Reproduce Code

Construct the code within a given
[`shiny::reactive`](https://rdrr.io/pkg/shiny/man/reactive.html) object
to be able to re-create the output outside of a Shiny session.

## Usage

``` r
reprex_reactive(x, header = FALSE, ...)
```

## Arguments

- x:

  [`shiny::reactive`](https://rdrr.io/pkg/shiny/man/reactive.html)
  object to make reproducible

- header:

  Whether to prepend a
  [`reprex_header()`](https://ascentsoftware.github.io/shinyreprex/reference/reprex_header.md)
  pinning the packages, R version and a dependency snapshot date `x`
  needs, so the returned script is reproducible as a single file.
  Defaults to `FALSE`.

- ...:

  Passed on to
  [`reprex_header()`](https://ascentsoftware.github.io/shinyreprex/reference/reprex_header.md)
  when `header` is `TRUE`, for example `exclude_newer` or `isolated`.
  Ignored, with a warning, otherwise.

## Value

A character string, that when printed (using
[`base::cat`](https://rdrr.io/r/base/cat.html)), displays the script
that reproduces the contents of `x`, optionally preceded by the `ir`
header from
[`reprex_header()`](https://ascentsoftware.github.io/shinyreprex/reference/reprex_header.md).

## See also

[`reprex_header()`](https://ascentsoftware.github.io/shinyreprex/reference/reprex_header.md)
to build the header on its own, for example to cover several reactives
with one header.

## Examples

``` r
library(shiny)

ui <- fluidPage(
  h1("Reproducible Code Example"),
  inputPanel(
    sliderInput(
      "min_width",
      "Minimum Petal Width",
      min(iris$Petal.Width),
      max(iris$Petal.Width),
      min(iris$Petal.Width),
      step = 0.1
    ),
    selectInput(
      "summary_fn",
      "Summary Function",
      c("Mean" = "mean", "Median" = "median", "SD" = "sd"),
      selected = "mean"
    )
  ),
  fluidRow(
    column(
      width = 5,
      h2("Table"),
      tableOutput("table")
    ),
    column(
      width = 7,
      h2("Code"),
      verbatimTextOutput("code")
    )
  )
)

server <- function(input, output, session) {
  iris_filt <- reactive({
    iris[with(iris, Petal.Width > input$min_width), ]
  })

  summary_tbl <- reactive({
    aggregate(
      Sepal.Width ~ Species,
      data = iris_filt(),
      FUN = get(input$summary_fn)
    )
  })

  output$table <- renderTable(summary_tbl())
  output$code <- renderText(reprex_reactive(summary_tbl))

  # A single file, reproducible with `ir run script.R`
  output$code_with_header <- renderText(
    reprex_reactive(summary_tbl, header = TRUE, exclude_newer = "2025-05-15")
  )
}

if (interactive()) {
  shinyApp(ui, server)
}
```
