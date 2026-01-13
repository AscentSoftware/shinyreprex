# Introduction to shinyrepro

## Using shinyrepro

There is a single exported function, `repro`, that takes a reactive
object and converts it into a script that can be reused outside of the
Shiny application to reproduce the result of the reactive. This can be
sent to a simple `verbatimTextOutput` or something more UX friendly such
as the {highlighter} package to display the script in the UI.

## Best Practices

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

So that developers can easily recreate outputs generated in Shiny
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
