#' Generic Method for Reproducing Code
#'
#' @description
#' Standard response is to return the called object
#'
#' @noRd
S7::method(repro_call_chunk, class_call_subset) <- function(x, repro_code = Repro(), env = rlang::caller_env()) {
  if (is_input_call(x)) {
    eval_call <- eval(x, envir = env)
  } else if (is_reactive_values_call(x, env)) {
    reactive_val <- eval(x, envir = env)
    eval_call <- rlang::call2("<-", rlang::call_args(x)[[2]], reactive_val)
  } else {
    class(x) <- c(".__generic", class(x))
    return(
      repro_call_chunk(
        x = x,
        repro_code = repro_code,
        env = env
      )
    )
  }

  repro_code@packages <- get_pkg_name(x)
  repro_code@code <- eval_call
  repro_code
}
