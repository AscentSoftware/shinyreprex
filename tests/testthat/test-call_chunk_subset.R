test_that("Subset chunk maintains the same for a static value like regular R objects", {
  subset_call <- str2lang("iris$Sepal.Width")
  class(react_val_call) <- c("$", class(react_val_call))

  repro_subset <- repro_call_chunk(subset_call)
  expect_s7_class(repro_subset, Repro)
  expect_identical(repro_subset@code, list(subset_call))
  expect_identical(repro_subset@calls, "iris$Sepal.Width")
})
