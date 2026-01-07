test_that("Able to extract a simple value from a reactiveVal", {
  my_react_val <- shiny::reactiveVal(1L)
  react_val_call <- str2lang("my_react_val()")
  class(react_val_call) <- c(".__reactval", class(react_val_call))

  repro_react_val <- shiny::isolate(repro_call_chunk(react_val_call))

  expect_s7_class(repro_react_val, Repro)
  expect_identical(repro_react_val@code, list(str2lang("my_react_val <- 1L")))
  expect_identical(repro_react_val@calls, "my_react_val <- 1L")
})

test_that("Able to extract a vector from a reactiveVal", {
  my_react_val <- shiny::reactiveVal(letters)
  react_val_call <- str2lang("my_react_val()")
  class(react_val_call) <- c(".__reactval", class(react_val_call))
  letters_str <- paste0("my_react_val <- c(", paste0("\"", letters, "\"", collapse = ", "), ")")

  repro_react_val <- shiny::isolate(repro_call_chunk(react_val_call))
  expect_identical(deparse1(repro_react_val@code[[1]]), letters_str)
})

test_that("Able to extract a data.frame from a reactiveVal", {
  my_react_val <- shiny::reactiveVal(iris)
  react_val_call <- str2lang("my_react_val()")
  class(react_val_call) <- c(".__reactval", class(react_val_call))

  repro_react_val <- shiny::isolate(repro_call_chunk(react_val_call))
  expect_match(deparse1(repro_react_val@code[[1]]), "my_react_val <- data.frame(", fixed = TRUE)
  expect_match(repro_react_val@calls[1], "my_react_val <- data.frame(", fixed = TRUE)
})
