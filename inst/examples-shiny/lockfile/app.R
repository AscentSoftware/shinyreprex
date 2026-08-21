library(shiny)
library(shinyreprex)

# Demonstrates the two ways to offer a lockfile alongside a reprex:
#   1. `lockfileUI`/`lockfileServer` - a single control, dropped in the navbar.
#   2. `reprex_packages` - feeding a custom picker, wired up by hand.

ui <- bslib::page_navbar(
  title = "shinyreprex",

  bslib::nav_panel(
    "Reproduce",
    bslib::layout_sidebar(
      sidebar = bslib::sidebar(
        sliderInput(
          "min_width",
          "Minimum petal width",
          min(iris$Petal.Width),
          max(iris$Petal.Width),
          min(iris$Petal.Width),
          step = 0.1
        ),
        selectInput(
          "summary_fn",
          "Summary function",
          c(Mean = "mean", Median = "median", `Std. dev` = "sd")
        ),
        checkboxGroupInput(
          "columns",
          "Columns to summarise",
          c("Sepal.Length", "Sepal.Width", "Petal.Length"),
          selected = "Sepal.Width"
        ),
        actionButton("update", "Update", class = "btn-primary")
      ),
      bslib::layout_columns(
        bslib::card(bslib::card_header("Output"), tableOutput("table")),
        bslib::card(bslib::card_header("Reproducible script"), verbatimTextOutput("code"))
      )
    )
  ),

  bslib::nav_panel(
    "Environment",
    bslib::card(
      bslib::card_header("Choose what to pin"),
      p(
        "The packages below were detected in the reactive by ", code("reprex_packages()"),
        ". Narrow the selection, or add a package the detector could not see, then ",
        "download a lockfile scoped to that choice."
      ),
      uiOutput("package_picker"),
      downloadButton("custom_lock", "Download selected", class = "btn-secondary")
    )
  ),

  bslib::nav_spacer(),
  bslib::nav_item(lockfileUI("lock", "Download renv.lock"))
)

server <- function(input, output, session) {
  iris_filt <- reactive({
    iris[iris$Petal.Width >= input$min_width, ]
  }) |>
    bindEvent(input$update, ignoreNULL = FALSE)

  summary_tbl <- reactive({
    purrr::map(
      input$columns,
      dat = iris_filt(),
      fn = input$summary_fn,
      \(col, dat, fn) {
        aggregate(as.formula(paste(col, "~ Species")), data = dat, FUN = get(fn))
      }
    ) |>
      purrr::reduce(merge, by = "Species")
  }) |>
    bindEvent(input$update, ignoreNULL = FALSE)

  output$table <- renderTable(summary_tbl())

  # Bound to the reactive so the script only refreshes when the output does.
  output$code <- renderText(reprex_reactive(summary_tbl)) |>
    bindEvent(summary_tbl())

  # 1. The drop-in: one control in the navbar, pinning everything detected.
  lockfileServer("lock", summary_tbl)

  # 2. The custom path: same engine, user-selected packages.
  detected <- reactive(reprex_packages(summary_tbl)) |>
    bindEvent(summary_tbl())

  output$package_picker <- renderUI({
    checkboxGroupInput("packages", NULL, choices = detected(), selected = detected())
  })

  output$custom_lock <- downloadHandler(
    filename = function() "renv.lock",
    content = function(file) {
      reprex_lockfile(summary_tbl, packages = input$packages, lockfile = file)
    }
  )
}

shinyApp(ui, server)
