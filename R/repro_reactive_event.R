#' Reproducing Code for Reactive Object
#'
#' @noRd
S7::method(repro_chunk, class_event_reactive) <- function(x, ..., repro_code = Repro(), env = rlang::caller_env()) {
  observer <- attr(x, "observable", exact = TRUE)
  module_env <- rlang::env_parent(env = environment(observer$.origFunc))

  # Accounts for bindEvent and bindCache
  while ("wrappedFunc" %in% names(attributes(module_env$valueFunc))) {
    inner_reactive <- attr(module_env$valueFunc, "wrappedFunc", exact = TRUE)
    module_env <- rlang::env_parent(env = environment(inner_reactive))
  }

  reactive_exprs <- as.list(rlang::fn_body(inner_reactive))[-1]
  for (reactive_expr in reactive_exprs) {
    repro_code <- repro_chunk(reactive_expr, repro_code = repro_code, env = module_env)
  }

  repro_code
}
