# Reproduce Code

Construct the code within a given
[`reactive`](https://rdrr.io/pkg/shiny/man/reactive.html) object to be
able to re-create the output outside of a Shiny session.

## Usage

``` r
repro(x)
```

## Arguments

- x:

  [`reactive`](https://rdrr.io/pkg/shiny/man/reactive.html) object to
  make reproducible

## Value

A character string, that when printed (using
[`cat`](https://rdrr.io/r/base/cat.html)), displays the script that
reproduces the contents of `x`.

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
  output$code <- renderText(repro(summary_tbl))
}

if (interactive()) {
  shinyApp(ui, server)
}
```
