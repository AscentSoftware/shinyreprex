#' Reproducing Code for Call Object
#'
#' @noRd
S7::method(repro_chunk, S7::class_call) <- function(x, ..., repro_code = Repro(), env = rlang::caller_env()) {
  if (is.null(rlang::call_name(x))) {
    eval_call <- x
  } else if (rlang::is_call(x, c("req", "validate"))) {
    return(repro_code)
  } else if (is_input_call(x)) {
    eval_call <- eval(x, envir = env)
  } else if (is_reactive_val_call(x, env)) {
    reactive_val <- eval(x, envir = env)
    eval_call <- rlang::call2("<-", as.symbol(rlang::call_name(x)), reactive_val)
  } else if (is_reactive_call(x, env)) {
    repro_call <- repro_chunk(env[[rlang::call_name(x)]])
    repro_code@packages <- repro_call@packages
    eval_call <- assign_reactive_call(x, repro_call)
  } else if (is_reactive_call(x, parent.env(env))) {
    repro_call <- repro_chunk(parent.env(env)[[rlang::call_name(x)]])
    repro_code@packages <- repro_call@packages
    eval_call <- assign_reactive_call(x, repro_call)
  } else if (rlang::is_call(x, "function")) {
    # TODO: work out how to get expression from within anonymous function body
    eval_call <- x
  } else {
    reactive_calls <- vapply(rlang::call_args(x), is_reactive_call, env = env, parent_env = TRUE, logical(1L))
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
  }

  repro_code@packages <- get_pkg_name(x)
  repro_code@code <- eval_call
  repro_code
}
