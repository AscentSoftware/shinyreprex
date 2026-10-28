# Resolve the Packages to Pin

Shared by
[`reprex_lockfile()`](https://ascentsoftware.github.io/shinyreprex/reference/reprex_lockfile.md)
and
[`reprex_header()`](https://ascentsoftware.github.io/shinyreprex/reference/reprex_header.md):
detect packages from `...` when `packages` is `NULL`, remove any named
in `exclude`, and warn when the resulting set is empty, wording the
warning to say whether the set was detected or supplied by the caller.

## Usage

``` r
resolve_reprex_packages(..., packages, exclude, session, empty_warning)
```

## Arguments

- ...:

  Passed to
  [`reprex_packages()`](https://ascentsoftware.github.io/shinyreprex/reference/reprex_packages.md)
  when `packages` is `NULL`.

- packages:

  Character vector of package names, or `NULL` to detect them from
  `...`.

- exclude:

  Character vector of package names to remove from the result.

- session:

  The Shiny session to read registered reactives from. Only used when
  `...` is empty and `packages` is `NULL`.

- empty_warning:

  Text describing what happens when the resolved set is empty,
  substituted into
  `"No non-base packages {detect_term}; {empty_warning}"`.

## Value

A character vector of package names.
