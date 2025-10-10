test_that("Able to extract reactive object from bindCache", {
  test_server <- function(input, output, session) {
    iris_filt <- reactive(iris[with(iris, Sepal.Width > input$min_width), ]) |>
      bindCache(input$min_width)

    summary_tbl <- reactive({
      aggregate(
        Sepal.Width ~ Species,
        data = iris_filt(),
        FUN = get(input$summary_fn)
      )
    }) |>
      bindCache(iris_filt(), input$summary_fn)
  }

  shiny::testServer(
    test_server,
    expr = {
      session$setInputs(min_width = 3.5, summary_fn = "median")

      repro_code <- repro(summary_tbl)
      expect_identical(
        repro_code,
        paste(
          "iris_filt <- iris[with(iris, Sepal.Width > 3.5), ]",
          "aggregate(Sepal.Width ~ Species, data = iris_filt, FUN = get(\"median\"))",
          sep = "\n"
        )
      )
    }
  )
})

test_that("Able to extract reactive object from bindEvent", {
  test_server <- function(input, output, session) {
    iris_filt <- reactive(iris[with(iris, Sepal.Width > input$min_width), ]) |>
      bindEvent(input$min_width)

    summary_tbl <- reactive({
      aggregate(
        Sepal.Width ~ Species,
        data = iris_filt(),
        FUN = get(input$summary_fn)
      )
    }) |>
      bindEvent(iris_filt(), input$summary_fn)
  }

  shiny::testServer(
    test_server,
    expr = {
      session$setInputs(min_width = 3.5, summary_fn = "median")

      repro_code <- repro(summary_tbl)
      expect_identical(
        repro_code,
        paste(
          "iris_filt <- iris[with(iris, Sepal.Width > 3.5), ]",
          "aggregate(Sepal.Width ~ Species, data = iris_filt, FUN = get(\"median\"))",
          sep = "\n"
        )
      )
    }
  )
})

test_that("Able to extract reactive object from bindEvent and bindCache", {
  test_server <- function(input, output, session) {
    iris_filt <- reactive(iris[with(iris, Sepal.Width > input$min_width), ]) |>
      bindCache(iris_filt(), input$summary_fn) |>
      bindEvent(input$min_width)

    summary_tbl <- reactive({
      aggregate(
        Sepal.Width ~ Species,
        data = iris_filt(),
        FUN = get(input$summary_fn)
      )
    }) |>
      bindCache(iris_filt(), input$summary_fn) |>
      bindEvent(iris_filt(), input$summary_fn)
  }

  shiny::testServer(
    test_server,
    expr = {
      session$setInputs(min_width = 3.5, summary_fn = "median")

      repro_code <- repro(summary_tbl)
      expect_identical(
        repro_code,
        paste(
          "iris_filt <- iris[with(iris, Sepal.Width > 3.5), ]",
          "aggregate(Sepal.Width ~ Species, data = iris_filt, FUN = get(\"median\"))",
          sep = "\n"
        )
      )
    }
  )


})

test_that("Able to extract reactive object from eventReactive", {
  test_server <- function(input, output, session) {
    iris_filt <- eventReactive(input$min_width, iris[with(iris, Sepal.Width > input$min_width), ])

    summary_tbl <- eventReactive(list(iris_filt(), input$summary_fn), {
      aggregate(
        Sepal.Width ~ Species,
        data = iris_filt(),
        FUN = get(input$summary_fn)
      )
    })
  }

  shiny::testServer(
    test_server,
    expr = {
      session$setInputs(min_width = 3.5, summary_fn = "median")

      repro_code <- repro(summary_tbl)
      expect_identical(
        repro_code,
        paste(
          "iris_filt <- iris[with(iris, Sepal.Width > 3.5), ]",
          "aggregate(Sepal.Width ~ Species, data = iris_filt, FUN = get(\"median\"))",
          sep = "\n"
        )
      )
    }
  )
})
