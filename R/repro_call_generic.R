#' Generic Method for Reproducing Code
#'
#' @description
#' Standard response is to return the called object
#'
#' @noRd
S7::method(repro_call_chunk, S7::class_any) <- function(x, repro_code = Repro(), env = rlang::caller_env()) {
  reactive_calls <- vapply(rlang::call_args(x), is_any_reactive_call, env = env, logical(1L))
  repro_args <- lapply(rlang::call_args(x), \(x) repro_chunk(x, env = env))
  eval_args <- purrr::map(repro_args, "code") |> unlist(recursive = FALSE)

  if (any(reactive_calls)) {
    pre_reactive_calls <- unname(repro_args[reactive_calls])

    pre_req_args <- purrr::map(pre_reactive_calls, \(y) rlang::call_args(y@code[[1]])[[1]])
    repro_code@prerequisites <- purrr::set_names(
      purrr::map(pre_reactive_calls, "code"),
      pre_req_args
    )

    eval_args[reactive_calls] <- pre_req_args
  } else {
    repro_code@prerequisites <- purrr::map(repro_args, "prerequisites") |>
      purrr::discard(identical, list()) |>
      unlist(recursive = FALSE)
  }

  if (rlang::is_call(x[[1]], "::")) pkg <- as.character(x[[1]][[2]]) else pkg <- NULL
  eval_call <- rlang::call2(rlang::call_name(x), !!!eval_args, .ns = pkg)
  repro_code@packages <- purrr::map(repro_args, "packages") |> unlist()

  repro_code@packages <- get_pkg_name(x)
  repro_code@code <- eval_call
  repro_code
}
