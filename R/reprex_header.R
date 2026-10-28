#' Create an `ir` Header to Reproduce Reactives
#'
#' @description
#' Capture the exact package versions, R version and a dependency snapshot date
#' needed to reproduce one or more `shiny::reactive` objects, as a single
#' [ir](https://github.com/r-lib/ir) header. Prepending the header to the script
#' returned by [reprex_reactive()] lets the recipient run `ir run script.R`
#' with no separate lockfile or project to share.
#'
#' ## Snapshot Scope
#' As with [reprex_lockfile()], the package versions pinned are read from the
#' currently loaded library (`.libPaths()`), so they match the running Shiny
#' session that produced the reactives.
#'
#' @param ... One or more `shiny::reactive` objects to reproduce. If none are
#' supplied, every reactive registered by [register_reactives()] is used, so a
#' modular application can offer a whole-app header without threading
#' reactives up to the top level.
#' @param packages Character vector of package names to pin. If `NULL` (the
#' default), every package detected across `...` is used. Supplying this lets
#' the user narrow the set, or add a package the detector could not find (for
#' example one attached only for an operator or method).
#' @param exclude Character vector of package names to omit from the header.
#' @param r_version Whether to pin the R version the script was generated
#' under. `TRUE` (the default) pins the running `getRversion()` exactly;
#' `FALSE` omits the `r-version` field; a string is used as-is, for example
#' `">= 4.3"` to require a minimum rather than an exact version.
#' @param exclude_newer A `Date`, or a string coercible to one, naming the
#' Posit Package Manager snapshot `ir` resolves dependencies against. Defaults
#' to today, so dependencies are fixed as of the day the header is created.
#' @param isolated Whether `ir` installs packages into an isolated, per-script
#' library rather than reusing packages already available. Defaults to `TRUE`.
#' @param session The Shiny session to read registered reactives from. Only
#' used when `...` is empty and `packages` is `NULL`.
#'
#' @returns
#' A single string holding the `ir` header, including a trailing newline, ready
#' to be pasted above the output of [reprex_reactive()].
#'
#' @seealso [reprex_packages()] to inspect the detected set without building a
#' header, [reprex_lockfile()] for a whole-project `renv` lockfile, and
#' [register_reactives()] to record reactives from within each module.
#'
#' @examplesIf rlang::is_installed("shiny")
#' library(shiny)
#'
#' numeric_iris <- reactive(purrr::keep(iris, is.numeric))
#'
#' # Outside a running application, isolate supplies the reactive context
#' isolate(cat(reprex_header(numeric_iris, exclude_newer = "2025-05-15")))
#'
#' @export
reprex_header <- function(...,
                          packages = NULL,
                          exclude = NULL,
                          r_version = TRUE,
                          exclude_newer = Sys.Date(),
                          isolated = TRUE,
                          session = shiny::getDefaultReactiveDomain()) {
  packages <- resolve_reprex_packages(
    ...,
    packages = packages,
    exclude = exclude,
    session = session,
    empty_warning = "the header will pin only the R version and snapshot date"
  )

  header <- c(
    "#!/usr/bin/env -S ir run",
    header_packages(packages),
    header_r_version(r_version),
    sprintf("#| isolated: %s", tolower(isTRUE(isolated))),
    sprintf('#| exclude-newer: "%s"', as.character(as.Date(exclude_newer)))
  )

  paste0(paste(header, collapse = "\n"), "\n")
}

#' `ir` Header Lines Pinning Package Versions
#'
#' @description
#' Build the `packages:` field of an `ir` header, pinning each package to the
#' version currently installed.
#'
#' @param packages Character vector of package names to pin.
#'
#' @returns
#' A character vector of header lines, or `NULL` if `packages` is empty.
#'
#' @keywords internal
header_packages <- function(packages) {
  if (length(packages) == 0L) {
    return(NULL)
  }

  pinned <- vapply(
    packages,
    \(package) sprintf("%s==%s", package, as.character(utils::packageVersion(package))),
    character(1L)
  )

  c("#| packages:", sprintf("#|   - %s", pinned))
}

#' `ir` Header Line Pinning the R Version
#'
#' @description
#' Build the `r-version:` field of an `ir` header.
#'
#' @param r_version `TRUE` to pin the running `getRversion()` exactly, `FALSE`
#' to omit the field, or a string to use as the version constraint as-is.
#'
#' @returns
#' A single header line, or `NULL` if `r_version` is `FALSE`.
#'
#' @keywords internal
header_r_version <- function(r_version) {
  if (isFALSE(r_version)) {
    return(NULL)
  }

  version <- if (isTRUE(r_version)) {
    paste0("==", getRversion())
  } else {
    r_version
  }

  sprintf('#| r-version: "%s"', version)
}
