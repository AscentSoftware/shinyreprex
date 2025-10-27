test_that("Able to extract the 'if' part of an if/else statement", {
  test_server <- function(input, output, session) {
    summary_tbl <- reactive({
      if (input$min_width > 3) {
        iris[with(iris, Sepal.Width > input$min_width), ]
      } else {
        iris[with(iris, Sepal.Width < input$min_width), ]
      }
    })
  }

  shiny::testServer(
    test_server,
    expr = {
      session$setInputs(min_width = 3.5)

      repro_code <- repro(summary_tbl)
      expect_identical(repro_code, "iris[with(iris, Sepal.Width > 3.5), ]")
    }
  )
})

test_that("Able to extract the 'else' part of an if/else statement", {
  test_server <- function(input, output, session) {
    summary_tbl <- reactive({
      if (input$min_width > 3) {
        iris[with(iris, Sepal.Width > input$min_width), ]
      } else {
        iris[with(iris, Sepal.Width < input$min_width), ]
      }
    })
  }

  shiny::testServer(
    test_server,
    expr = {
      session$setInputs(min_width = 2.5)

      repro_code <- repro(summary_tbl)
      expect_identical(repro_code, "iris[with(iris, Sepal.Width < 2.5), ]")
    }
  )
})

test_that("Able to extract the 'else if' part of an if/else statement", {
  test_server <- function(input, output, session) {
    summary_tbl <- reactive({
      if (input$min_width > 3) {
        iris[with(iris, Sepal.Width > input$min_width), ]
      } else if (input$species == "versicolor") {
        iris[with(iris, Species == input$species & Sepal.Width > input$min_width), ]
      } else {
        iris[with(iris, Sepal.Width < input$min_width), ]
      }
    })
  }

  shiny::testServer(
    test_server,
    expr = {
      session$setInputs(min_width = 2.5, species = "versicolor")

      repro_code <- repro(summary_tbl)
      expect_identical(repro_code, "iris[with(iris, Species == \"versicolor\" & Sepal.Width > 2.5), ]")
    }
  )
})

test_that("Able to extract the 'else if' part of an if/else if/else statement", {
  test_server <- function(input, output, session) {
    summary_tbl <- reactive({
      if (input$min_width > 3) {
        iris[with(iris, Sepal.Width > input$min_width), ]
      } else if (input$species == "versicolor") {
        iris[with(iris, Species == input$species & Sepal.Width > input$min_width), ]
      } else {
        iris[with(iris, Sepal.Width < input$min_width), ]
      }
    })
  }

  shiny::testServer(
    test_server,
    expr = {
      session$setInputs(min_width = 2.5, species = "setosa")

      repro_code <- repro(summary_tbl)
      expect_identical(repro_code, "iris[with(iris, Sepal.Width < 2.5), ]")
    }
  )
})
