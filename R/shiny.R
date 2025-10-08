#' Reproduced Code Output
#'
#' @inheritParams shiny::textOutput
#'
#' @rdname reproOutput
#' @export
reproOutput <- function(outputId) {
  shiny::tags$pre(id = outputId, class = "shiny-text-output")
}

#' @inheritParams shiny::renderText
#'
#' @rdname reproOutput
#' @export
renderRepro <- function(expr, env = parent.frame(), quoted = FALSE, outputArgs = list(), sep = " ") {
  func <- shiny::installExprFunction(expr, "func", env, quoted, label = "renderRepro")

  shiny::createRenderFunction(
    func,
    function(value, session, name, ...) {
      if (inherits(value, "Repro")) value@script else repro(value)@script
    },
    shiny::textOutput,
    outputArgs
  )
}
