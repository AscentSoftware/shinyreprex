#' Render Reproducible Reactive
#'
#' @rdname render_reactive_reprex
#' @export
renderReactiveReprex <- function(x) {
  highlighter::renderHighlighter(reprex_reactive(x)) |>
    shiny::bindEvent(x)
}

#' @rdname render_reactive_reprex
#' @export
reactiveReprexOutput <- function(outputId) {
  highlighter::highlighterOutput(outputId)
}
