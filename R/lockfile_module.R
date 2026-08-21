#' Lockfile Download Module
#'
#' @description
#' A Shiny module offering a single download control that writes an `renv`
#' lockfile reproducing one or more reactives (see [reprex_lockfile()]).
#'
#' `lockfileUI()` returns a plain [shiny::downloadButton()], so it can be
#' dropped wherever a control fits - inside a `bslib::nav_menu()`, a sidebar, or
#' a toolbar - without pulling in any layout of its own.
#'
#' To build a bespoke interface instead, skip the module and call
#' [reprex_packages()] to populate your own package picker, feeding the choice
#' back through the `packages` argument of [reprex_lockfile()].
#'
#' @param id Module id, shared between `lockfileUI()` and `lockfileServer()`.
#' @param label Button label.
#' @param ... One or more `shiny::reactive` objects to reproduce.
#' @param packages Packages to snapshot, passed to [reprex_lockfile()]. May be a
#' reactive (for example one fed by a user's own package picker), in which case
#' it is resolved when the download is requested. `NULL` snapshots every
#' detected package.
#' @param filename Name of the downloaded lockfile.
#'
#' @returns
#' `lockfileUI()` returns a Shiny UI tag. `lockfileServer()` is called for its
#' side effect and returns the module's return value invisibly.
#'
#' @examplesIf interactive() && rlang::is_installed(c("shiny", "renv", "bslib"))
#' library(shiny)
#'
#' ui <- bslib::page_navbar(
#'   title = "Demo",
#'   bslib::nav_panel(
#'     "Table",
#'     sliderInput("w", "Minimum petal width", 0, 2.5, 0.5, step = 0.1),
#'     tableOutput("table")
#'   ),
#'   bslib::nav_spacer(),
#'   bslib::nav_item(lockfileUI("lock", "Download renv.lock"))
#' )
#'
#' server <- function(input, output, session) {
#'   filtered <- reactive(purrr::keep(iris, is.numeric)[iris$Petal.Width > input$w, ])
#'
#'   output$table <- renderTable(head(filtered()))
#'   lockfileServer("lock", filtered)
#' }
#'
#' shinyApp(ui, server)
#'
#' @seealso
#' A fuller worked example, covering both this module and a custom package
#' picker, ships with the package:
#' `shiny::runApp(system.file("examples-shiny/lockfile", package = "shinyreprex"))`
#'
#' @name lockfile_module
NULL

#' @rdname lockfile_module
#' @export
lockfileUI <- function(id, label = "Download lockfile") {
  shiny::downloadButton(shiny::NS(id, "download"), label)
}

#' @rdname lockfile_module
#' @export
lockfileServer <- function(id, ..., packages = NULL, filename = "renv.lock") {
  reactives <- list(...)

  shiny::moduleServer(id, function(input, output, session) {
    output$download <- shiny::downloadHandler(
      filename = function() filename,
      content = function(file) {
        pkgs <- if (shiny::is.reactive(packages)) packages() else packages
        do.call(
          reprex_lockfile,
          c(reactives, list(packages = pkgs, lockfile = file))
        )
      }
    )
  })
}
