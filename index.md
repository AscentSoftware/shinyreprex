# shinyreprex

## Overview

The aim of **shinyreprex** is to be able to recreate any reactive or
output that is available in a Shiny application outside of said
application.

In static documents, like Quarto, it is easy to include the code chunk
by including code folding. Due to the interactiveness of Shiny, this
isn’t as easy to include out of the box. Reactive depend on inputs set
by the user, and need to be replaced in the reactive expressions to be
able to run in an environment outside of Shiny.

## Installation

To get the latest version of shinyreprex, install from GitHub:

``` r
require(remotes)
remotes::install_github("AscentSoftware/shinyreprex")
```

## Usage

The following examples takes a couple of inputs, and uses one of them in
one reactive, and the other in another reactive. The second reactive is
a table output, which can be passed to `reprex_reactive` to re-create
the code that generates the table seen in the UI.

``` r
library(shiny)
library(shinyreprex)

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
    ),
    actionButton("update", "Update")
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
  }) |>
    bindEvent(input$update)

  summary_tbl <- reactive({
    aggregate(
      Sepal.Width ~ Species,
      data = iris_filt(),
      FUN = get(input$summary_fn)
    )
  }) |>
    bindEvent(input$update)

  output$table <- renderTable(summary_tbl())
  output$code <- renderText(reprex_reactive(summary_tbl))
}

shinyApp(ui, server)
```
