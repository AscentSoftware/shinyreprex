#' Reproducing Code for Call Object
#'
#' @noRd
S7::method(repro_chunk, S7::class_call) <- function(x, ..., repro_code = Repro(), env = rlang::caller_env()) {
  call_env <- env
  call_name <- rlang::call_name(x) %||% "NULL"

  if (is_reactive_val_call(x, env)) {
    call_name <- ".__reactval"
    # Reactive object created within the module
  } else if (is_reactive_call(x, env)) {
    call_name <- ".__reactive"
    # Reactive object sent to the module
  } else if (is_reactive_call(x, parent.env(env))) {
    call_name <- ".__reactive"
    call_env <- parent.env(env)
  }

  class(x) <- c(call_name, class(x))

  repro_call_chunk(
    x = x,
    env = call_env,
    repro_code = repro_code
  )
}
