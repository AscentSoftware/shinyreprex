# `ir` Header Line Pinning the R Version

Build the `r-version:` field of an `ir` header.

## Usage

``` r
header_r_version(r_version)
```

## Arguments

- r_version:

  `TRUE` to pin the running
  [`getRversion()`](https://rdrr.io/r/base/numeric_version.html)
  exactly, `FALSE` to omit the field, or a string to use as the version
  constraint as-is.

## Value

A single header line, or `NULL` if `r_version` is `FALSE`.
