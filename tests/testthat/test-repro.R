test_that("When a non-reactive call is passed to repro, error gets returned", {
  test_server <- function(input, output, session) {
    test_reactive <- reactive(input$foo)
  }

  shiny::testServer(
    test_server,
    expr = {
      expect_error(
        repro(iris),
        "Unable to generate reproducible code for iris, must be an unevaluated reactive object",
        fixed = TRUE
      )
    }
  )
})

test_that("When a reactive is evaluated into repro, specific error is returned to user", {
  test_server <- function(input, output, session) {
    test_reactive <- reactive(input$foo)
  }

  shiny::testServer(
    test_server,
    expr = {
      expect_error(
        repro(test_reactive()),
        "test_reactive has already been evaluated, please remove brackets to pass through reactive object",
        fixed = TRUE
      )
    }
  )
})

test_that("Able to reproduce a simple one-line reactive", {
  test_server <- function(input, output, session) {
    test_reactive <- reactive(input$foo)
  }

  shiny::testServer(
    test_server,
    expr = {
      repro_code <- repro(test_reactive)
      expect_identical(repro_code, "")

      session$setInputs(foo = "bar")

      repro_code <- repro(test_reactive)
      expect_identical(repro_code, "\"bar\"")
    }
  )
})

test_that("Able to reproduce a reactive stemming from another reactive", {
  test_server <- function(input, output, session) {
    iris_filt <- reactive(iris[with(iris, Sepal.Width > input$min_width), ])

    summary_tbl <- reactive({
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

test_that("When one non-standard package is used, it is added to the top of the script", {
  test_server <- function(input, output, session) {
    iris_filt <- reactive(iris[with(iris, Sepal.Width > input$min_width), ])

    summary_tbl <- reactive({
      purrr::map(
        head(names(iris), 4),
        dat = iris_filt(),
        fn = input$summary_fn,
        \(x, dat, fn) {
          aggregate(
            as.formula(paste(x, "~ Species")),
            data = dat,
            FUN = get(fn)
          )
        }
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
          "library(purrr)",
          "",
          "iris_filt <- iris[with(iris, Sepal.Width > 3.5), ]",
          "purrr::map(head(names(iris), 4),",
          "  dat = iris_filt, fn = \"median\",",
          "  function(x, dat, fn) {",
          "    aggregate(as.formula(paste(x, \"~ Species\")),",
          "      data = dat,",
          "      FUN = get(fn)",
          "    )",
          "  }",
          ")",
          sep = "\n"
        )
      )

      repro_result <- eval(parse(text = repro_code), envir = new.env())
      expect_s3_class(iris_filt, "reactive")
      expect_identical(repro_result, summary_tbl())
    }
  )
})
