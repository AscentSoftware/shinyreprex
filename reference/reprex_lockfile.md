# Create a Lockfile to Reproduce Reactives

Capture the exact package versions, sources and R version needed to
reproduce one or more
[`shiny::reactive`](https://rdrr.io/pkg/shiny/man/reactive.html)
objects, as an `renv` lockfile. Restoring the lockfile with
[`renv::restore()`](https://rstudio.github.io/renv/reference/restore.html)
recreates the environment the reactives were generated in, including the
recursive dependency tree.

A single lockfile covers every reactive passed, so an application can
offer one download that reproduces all of its outputs.

### Snapshot Scope

The snapshot is taken from the currently loaded library
([`.libPaths()`](https://rdrr.io/r/base/libPaths.html)), so the versions
recorded are exactly those the running Shiny session used to produce the
reactives. `renv` resolves and records the full recursive dependency
tree of `packages`, so only the top-level set needs to be supplied.

### Isolation

The snapshot runs against a throwaway temporary project, so it never
writes `renv` infrastructure into, or otherwise modifies, the
application's own directory.

### Output Path

A relative `lockfile` is resolved against the working directory, not
against the temporary project used for the snapshot. The default
therefore writes `renv.lock` into whichever directory the application is
running from. Pass an absolute path to control where it lands; inside a
[`shiny::downloadHandler()`](https://rdrr.io/pkg/shiny/man/downloadHandler.html)
that is the `file` argument.

## Usage

``` r
reprex_lockfile(
  ...,
  packages = NULL,
  lockfile = "renv.lock",
  exclude = NULL,
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
  is used, so a modular application can offer a whole-app lockfile
  without threading reactives up to the top level.

- packages:

  Character vector of package names to snapshot. If `NULL` (the
  default), every package detected across `...` is used. Supplying this
  lets the user narrow the set, or add a package the detector could not
  find (for example one attached only for an operator or method).

- lockfile:

  Path to write the lockfile to. Defaults to `"renv.lock"`.

- exclude:

  Character vector of package names to omit from the snapshot.

- session:

  The Shiny session to read registered reactives from. Only used when
  `...` is empty and `packages` is `NULL`.

## Value

The absolute path the lockfile was written to, invisibly.

## See also

[`reprex_packages()`](https://ascentsoftware.github.io/shinyreprex/reference/reprex_packages.md)
to inspect the detected set without writing a lockfile, and
[`register_reactives()`](https://ascentsoftware.github.io/shinyreprex/reference/register_reactives.md)
to record reactives from within each module.

## Examples

``` r
if (FALSE) { # interactive()
library(shiny)

numeric_iris <- reactive(purrr::keep(iris, is.numeric))

isolate(reprex_lockfile(numeric_iris, lockfile = tempfile(fileext = ".lock")))
}
```
