# get_pkg_name ----
test_that("Able to extract package name from pkg::fn call", {
  expect_identical(get_pkg_name(str2lang("rlang::sym('foo')")), "rlang")
})

test_that("Able to extract package name from unnamespaced function call", {
  expect_identical(get_pkg_name(str2lang("repro_chunk('foo')")), "shinyrepro")
})

test_that("When extract package from function call, base R packages are ignored", {
  expect_null(get_pkg_name(str2lang("nzchar('foo')")))
})
