# shinyrepro

The aim of {shinyrepro} is to be able to recreate any output that is
available in a Shiny application outside of the application itself.

## Installation

To get the latest version of {shinyrepro}, install from GitHub:

``` r
require(remotes)
remotes::install_github("AscentSoftware/shinyrepro")
```

## Usage

{shinyrepro} has one exported function,
[`repro()`](https://jubilant-dollop-5lekoky.pages.github.io/reference/repro.md),
that takes a reactive object and converts it into a script that can be
reused outside of the Shiny application to reproduce the result of the
reactive. This can be sent to a simple `verbatimTextOutput` or something
more UX friendly such as the {highlighter} package to display the script
in the UI.

### Example

``` r
library(shiny)
library(shinyrepro)

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

shinyApp(ui, server)
```
