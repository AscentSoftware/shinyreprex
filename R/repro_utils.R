#' Call Checks
#'
#' @description
#' A set of helper functions that determine what type of call is being made within
#' an expression.
#'
#' @noRd
is_reactive_call <- function(x, env = rlang::caller_env(), parent_env = FALSE) {
  rlang::is_call(x) &&
    length(rlang::call_args(x)) == 0 &&
    (rlang::call_name(x) %in% names(env) ||
       (parent_env && rlang::call_name(x) %in% names(parent.env(env))))
}

is_reactive_val_call <- function(x, env = rlang::caller_env()) {
  is_reactive_call(x = x, env = env) &&
    inherits(env[[rlang::call_name(x)]], "reactiveVal")
}

is_subset_call <- function(x) {
  rlang::is_call(x, c("$", "[", "[["))
}

is_input_call <- function(x) {
  rlang::is_call(x, "$") &&
    identical(as.character(x[[2]]), "input")
}

#' Assign Reactive Call
#'
#' @noRd
assign_reactive_call <- function(x, repro_call) {
  if (length(repro_call@code) == 1) {
    rlang::call2("<-", as.symbol(rlang::call_name(x)), !!!repro_call@code)
  } else {
    rlang::call2(
      "<-",
      as.symbol(rlang::call_name(x)),
      rlang::call2("local", rlang::call2("{", !!!repro_call@code))
    )
  }
}

#' Get Call Package Name
#'
#' @noRd
get_pkg_name <- function(x, base_pkgs = NULL) {
  if (rlang::is_call(x[[1]], "::")) return(as.character(x[[1]][[2]]))

  pkg_name <- tryCatch(
    x |> rlang::call_name() |> get() |> environment() |> getNamespaceName() |> unname(),
    error = \(e) NULL
  )

  if (is.null(base_pkgs)) {
    base_pkgs <- rownames(utils::installed.packages(priority = "base"))
  }

  if (is.null(pkg_name) || pkg_name %in% base_pkgs) {
    NULL
  } else {
    pkg_name
  }
}
