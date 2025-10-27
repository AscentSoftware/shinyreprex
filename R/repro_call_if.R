#' Generic Method for Reproducing Code
#'
#' @description
#' Standard response is to return the called object
#'
#' @noRd
S7::method(repro_call_chunk, class_call_if) <- function(x, repro_code = Repro(), env = rlang::caller_env()) {
  if_args <- rlang::call_args(x)
  check <- eval(if_args[[1]], envir = env)

  # Adapts for if ... else if ... else
  if (!check && rlang::is_call(if_args[[3]], "if")) {
    return(repro_chunk(if_args[[3]], env = env))
  }
  check_calls <- purrr::map(as.list(if_args[[3 - check]])[-1], repro_chunk, env = env)
  repro_code@packages <- purrr::map(check_calls, "packages") |> unlist()
  repro_code@prerequisites <- purrr::map(check_calls, "prerequisites") |>
    purrr::discard(identical, list()) |>
    unlist(recursive = FALSE)
  eval_call <- purrr::map(check_calls, "code") |> unlist(recursive = FALSE)

  repro_code@packages <- get_pkg_name(x)
  repro_code@code <- eval_call
  repro_code
}
