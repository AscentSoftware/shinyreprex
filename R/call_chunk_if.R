#' Generic Method for Reproducing Code
#'
#' @description
#' Standard response is to return the called object
#'
#' Only the branch matching the current value of the condition is included in the
#' output. A braced branch is unwrapped into its component expressions, whereas an
#' unbraced branch is walked as a single expression.
#'
#' @noRd
S7::method(repro_call_chunk, class_call_if) <- function(x, repro_code = Repro(), env = rlang::caller_env()) {
  if_args <- rlang::call_args(x)
  check <- eval(if_args[[1]], envir = env)

  # Adapts for if ... else if ... else
  if (!check && rlang::is_call(if_args[[3]], "if")) {
    return(repro_chunk(if_args[[3]], env = env))
  }

  branch <- if_args[[3 - check]]
  branch_exprs <- if (rlang::is_call(branch, "{")) as.list(branch)[-1L] else list(branch)

  check_calls <- purrr::map(branch_exprs, repro_chunk, env = env)
  repro_code@packages <- purrr::map(check_calls, "packages") |> unlist()
  repro_code@prerequisites <- purrr::map(check_calls, "prerequisites") |>
    purrr::discard(identical, list()) |>
    unlist(recursive = FALSE)
  eval_call <- purrr::map(check_calls, "code") |> unlist(recursive = FALSE)

  repro_code@packages <- get_pkg_name(x)
  repro_code@code <- eval_call
  repro_code
}
