#' Generic Method for Reproducing Code
#'
#' @description
#' Standard response is to return the called object
#'
#' @noRd
S7::method(repro_call_chunk, class_call_reactval) <- function(x, repro_code = Repro(), env = rlang::caller_env()) {
  reactive_val <- eval(x, envir = env)
  eval_call <- rlang::call2("<-", as.symbol(rlang::call_name(x)), reactive_val)

  repro_code@packages <- get_pkg_name(x)
  repro_code@code <- eval_call
  repro_code
}
