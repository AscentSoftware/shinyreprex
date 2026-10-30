# Create an `ir` Header to Reproduce Reactives

Capture the exact package versions, R version and a dependency snapshot
date needed to reproduce one or more
[`shiny::reactive`](https://rdrr.io/pkg/shiny/man/reactive.html)
objects, as a single [ir](https://github.com/r-lib/ir) header.
Prepending the header to the script returned by
[`reprex_reactive()`](https://ascentsoftware.github.io/shinyreprex/reference/reprex_reactive.md)
lets the recipient run `ir run script.R` with no separate lockfile or
project to share.

### Snapshot Scope

As with
[`reprex_lockfile()`](https://ascentsoftware.github.io/shinyreprex/reference/reprex_lockfile.md),
the package versions pinned are read from the currently loaded library
([`.libPaths()`](https://rdrr.io/r/base/libPaths.html)), so they match
the running Shiny session that produced the reactives.

## Usage

``` r
reprex_header(
  ...,
  packages = NULL,
  exclude = NULL,
  r_version = TRUE,
  exclude_newer = Sys.Date(),
  isolated = TRUE,
  session = shiny::getDefaultReactiveDomain()
)
```

## Arguments

- ...:

  One or more
  [`shiny::reactive`](https://rdrr.io/pkg/shiny/man/reactive.html)
  objects to reproduce. If none are supplied, every reactive registered
  by
  [`register_reactives()`](https://ascentsoftware.github.io/shinyreprex/reference/register_reactives.md)
  is used, so a modular application can offer a whole-app header without
  threading reactives up to the top level.

- packages:

  Character vector of package names to pin. If `NULL` (the default),
  every package detected across `...` is used. Supplying this lets the
  user narrow the set, or add a package the detector could not find (for
  example one attached only for an operator or method).

- exclude:

  Character vector of package names to omit from the header.

- r_version:

  Whether to pin the R version the script was generated under. `TRUE`
  (the default) pins the running
  [`getRversion()`](https://rdrr.io/r/base/numeric_version.html)
  exactly; `FALSE` omits the `r-version` field; a string is used as-is,
  for example `">= 4.3"` to require a minimum rather than an exact
  version.

- exclude_newer:

  A `Date`, or a string coercible to one, naming the Posit Package
  Manager snapshot `ir` resolves dependencies against. Defaults to
  today, so dependencies are fixed as of the day the header is created.

- isolated:

  Whether `ir` installs packages into an isolated, per-script library
  rather than reusing packages already available. Defaults to `TRUE`.

- session:

  The Shiny session to read registered reactives from. Only used when
  `...` is empty and `packages` is `NULL`.

## Value

A single string holding the `ir` header, including a trailing newline,
ready to be pasted above the output of
[`reprex_reactive()`](https://ascentsoftware.github.io/shinyreprex/reference/reprex_reactive.md).

## See also

[`reprex_packages()`](https://ascentsoftware.github.io/shinyreprex/reference/reprex_packages.md)
to inspect the detected set without building a header,
[`reprex_lockfile()`](https://ascentsoftware.github.io/shinyreprex/reference/reprex_lockfile.md)
for a whole-project `renv` lockfile, and
[`register_reactives()`](https://ascentsoftware.github.io/shinyreprex/reference/register_reactives.md)
to record reactives from within each module.

## Examples

``` r
library(shiny)

numeric_iris <- reactive(purrr::keep(iris, is.numeric))

# Outside a running application, isolate supplies the reactive context
isolate(cat(reprex_header(numeric_iris, exclude_newer = "2025-05-15")))
#> #!/usr/bin/env -S ir run
#> #| packages:
#> #|   - purrr==1.2.2
#> #| r-version: "==4.6.2"
#> #| isolated: true
#> #| exclude-newer: "2025-05-15"
```
