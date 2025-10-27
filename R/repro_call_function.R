#' Function Method for Reproducing Code Call
#'
#' @description
#' TODO: Work out how
#'
#' @noRd
S7::method(repro_call_chunk, class_call_function) <- function(x, repro_code = Repro(), env = rlang::caller_env()) {
  repro_code@packages <- get_pkg_name(x)
  repro_code@code <- x
  repro_code
}
