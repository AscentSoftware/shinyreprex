#' Generic Method for Reproducing Code
#'
#' @description
#' Standard response is to return the called object
#'
#' @noRd
S7::method(repro_call_chunk, class_call_reactive) <- function(x, repro_code = Repro(), env = rlang::caller_env()) {
  repro_call <- repro_chunk(env[[rlang::call_name(x)]])
  repro_code@packages <- repro_call@packages
  eval_call <- assign_reactive_call(x, repro_call)

  repro_code@packages <- get_pkg_name(x)
  repro_code@code <- eval_call
  repro_code
}
