#' Reproduce Code
#'
#' @description
#' Construct the code within a given `shiny::reactive` object
#' to be able to re-create the output outside of a Shiny session.
#'
#' @param x `shiny::reactive` object to make reproducible
#' @param header Whether to prepend a [reprex_header()] pinning the packages,
#' R version and a dependency snapshot date `x` needs, so the returned script
#' is reproducible as a single file. Defaults to `FALSE`.
#' @param ... Passed on to [reprex_header()] when `header` is `TRUE`, for
#' example `exclude_newer` or `isolated`. Ignored, with a warning, otherwise.
#'
#' @returns
#' A character string, that when printed (using `base::cat`),
#' displays the script that reproduces the contents of `x`, optionally preceded
#' by the `ir` header from [reprex_header()].
#'
#' @seealso [reprex_header()] to build the header on its own, for example to
#' cover several reactives with one header.
#'
#' @examples
#' library(shiny)
#'
#' ui <- fluidPage(
#'   h1("Reproducible Code Example"),
#'   inputPanel(
#'     sliderInput(
#'       "min_width",
#'       "Minimum Petal Width",
#'       min(iris$Petal.Width),
#'       max(iris$Petal.Width),
#'       min(iris$Petal.Width),
#'       step = 0.1
#'     ),
#'     selectInput(
#'       "summary_fn",
#'       "Summary Function",
#'       c("Mean" = "mean", "Median" = "median", "SD" = "sd"),
#'       selected = "mean"
#'     )
#'   ),
#'   fluidRow(
#'     column(
#'       width = 5,
#'       h2("Table"),
#'       tableOutput("table")
#'     ),
#'     column(
#'       width = 7,
#'       h2("Code"),
#'       verbatimTextOutput("code")
#'     )
#'   )
#' )
#'
#' server <- function(input, output, session) {
#'   iris_filt <- reactive({
#'     iris[with(iris, Petal.Width > input$min_width), ]
#'   })
#'
#'   summary_tbl <- reactive({
#'     aggregate(
#'       Sepal.Width ~ Species,
#'       data = iris_filt(),
#'       FUN = get(input$summary_fn)
#'     )
#'   })
#'
#'   output$table <- renderTable(summary_tbl())
#'   output$code <- renderText(reprex_reactive(summary_tbl))
#'
#'   # A single file, reproducible with `ir run script.R`
#'   output$code_with_header <- renderText(
#'     reprex_reactive(summary_tbl, header = TRUE, exclude_newer = "2025-05-15")
#'   )
#' }
#'
#' if (interactive()) {
#'   shinyApp(ui, server)
#' }
#'
#' @export
reprex_reactive <- function(x, header = FALSE, ...) {
  if (!inherits(x, "reactiveExpr")) {
    x_name <- rlang::caller_arg(x)

    if (is.character(x_name) && grepl("^[A-Za-z0-9_\\.]+\\(\\)$", x_name)) {
      stop(
        sub("()", "", x_name, fixed = TRUE),
        " has already been evaluated, please remove brackets to pass through reactive object"
      )
    } else {
      stop("Unable to generate reproducible code for ", x_name, ", must be an unevaluated reactive object")
    }
  }

  if (!isTRUE(header) && ...length() > 0L) {
    cli::cli_warn("{.arg ...} is ignored unless {.code header = TRUE}")
  }

  script <- repro_chunk(x)@script

  if (isTRUE(header)) {
    paste0(reprex_header(x, ...), script)
  } else {
    script
  }
}
