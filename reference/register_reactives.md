# Register Reactives for Reproduction

Record reactives against the current Shiny session, so that
[`reprex_packages()`](https://ascentsoftware.github.io/shinyreprex/reference/reprex_packages.md)
and
[`reprex_lockfile()`](https://ascentsoftware.github.io/shinyreprex/reference/reprex_lockfile.md)
can be called with no arguments and still cover the whole application.

This avoids having to return reactives out of every module purely so a
single top-level call can see them. Each module registers what it owns,
and the session holds the collection.

### Namespacing

Registrations are namespaced by the calling module, so two modules may
register reactives of the same name without collision, and
re-registering the same name in the same module replaces the previous
entry rather than adding a duplicate.

### When to Register

Registering does not evaluate the reactive. Packages are resolved by
reading the expression held in the reactive, so it may be registered
while still gated behind
[`shiny::req()`](https://rdrr.io/pkg/shiny/man/req.html) or inputs that
have yet to be set. Registering at module setup is therefore both safe
and preferred, as it does not depend on the user having visited the
output first.

### Session Scope

The collection lives on the session, so it is discarded when the session
ends and is never shared between concurrent users of the same
application.

## Usage

``` r
register_reactives(..., session = shiny::getDefaultReactiveDomain())
```

## Arguments

- ...:

  One or more
  [`shiny::reactive`](https://rdrr.io/pkg/shiny/man/reactive.html)
  objects to register. Names are taken from the arguments, so
  `register_reactives(summary_tbl)` registers under `"summary_tbl"`.
  Supply names explicitly to override.

- session:

  The Shiny session to register against. Defaults to the current
  reactive domain, which inside a module is that module's session.

## Value

The registered reactives, invisibly, as a named list.

## See also

[`reprex_packages()`](https://ascentsoftware.github.io/shinyreprex/reference/reprex_packages.md)
and
[`reprex_lockfile()`](https://ascentsoftware.github.io/shinyreprex/reference/reprex_lockfile.md),
which read the registered collection when called with no reactives.

## Examples

``` r
if (FALSE) { # interactive()
library(shiny)

summaryServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    summary_tbl <- reactive(purrr::keep(iris, is.numeric))

    register_reactives(summary_tbl)

    summary_tbl
  })
}

# Elsewhere in the application, with no reactives threaded through:
# reprex_lockfile()
}
```
