# `ir` Header Lines Pinning Package Versions

Build the `packages:` field of an `ir` header, pinning each package to
the version currently installed.

## Usage

``` r
header_packages(packages)
```

## Arguments

- packages:

  Character vector of package names to pin.

## Value

A character vector of header lines, or `NULL` if `packages` is empty.
