#### reprex_header ####
test_that("An empty package set warns differently depending on whether it was detected or selected", {
  test_server <- function(input, output, session) {
    base_only <- reactive(nrow(iris))
    with_purrr <- reactive(purrr::keep(iris, is.numeric))
  }

  shiny::testServer(test_server, {
    expect_warning(
      reprex_header(base_only),
      "No non-base packages detected",
      fixed = TRUE
    )

    expect_warning(
      reprex_header(with_purrr, packages = character()),
      "No non-base packages selected",
      fixed = TRUE
    )
  })
})

test_that("The header pins the detected packages' installed versions", {
  test_server <- function(input, output, session) {
    a <- reactive(purrr::map(seq_len(input$n), function(x) x * 2))
  }

  shiny::testServer(test_server, {
    session$setInputs(n = 3)
    header <- reprex_header(a, exclude_newer = "2025-05-15")

    expect_true(startsWith(header, "#!/usr/bin/env -S ir run\n"))
    expect_match(header, "#| packages:", fixed = TRUE)
    expect_match(
      header,
      sprintf("#|   - purrr==%s", utils::packageVersion("purrr")),
      fixed = TRUE
    )
    expect_match(header, '#| exclude-newer: "2025-05-15"', fixed = TRUE)
  })
})

test_that("exclude removes a package from the header", {
  test_server <- function(input, output, session) {
    a <- reactive(purrr::map(seq_len(input$n), function(x) x * 2))
  }

  shiny::testServer(test_server, {
    session$setInputs(n = 3)

    expect_warning(
      header <- reprex_header(a, exclude = "purrr"),
      "No non-base packages detected",
      fixed = TRUE
    )

    expect_false(grepl("purrr", header, fixed = TRUE))
  })
})

test_that("r_version controls the r-version field", {
  test_server <- function(input, output, session) {
    a <- reactive(purrr::map(seq_len(input$n), function(x) x * 2))
  }

  shiny::testServer(test_server, {
    session$setInputs(n = 3)

    pinned <- reprex_header(a)
    expect_match(pinned, sprintf('#| r-version: "==%s"', getRversion()), fixed = TRUE)

    omitted <- reprex_header(a, r_version = FALSE)
    expect_false(grepl("r-version", omitted, fixed = TRUE))

    constrained <- reprex_header(a, r_version = ">= 4.3")
    expect_match(constrained, '#| r-version: ">= 4.3"', fixed = TRUE)
  })
})

test_that("isolated controls the isolated field", {
  test_server <- function(input, output, session) {
    a <- reactive(purrr::map(seq_len(input$n), function(x) x * 2))
  }

  shiny::testServer(test_server, {
    session$setInputs(n = 3)

    expect_match(reprex_header(a), "#| isolated: true", fixed = TRUE)
    expect_match(reprex_header(a, isolated = FALSE), "#| isolated: false", fixed = TRUE)
  })
})

test_that("A header covering the whole application is created from registered reactives alone", {
  test_server <- function(input, output, session) {
    shiny::moduleServer("alpha", function(input, output, session) {
      numeric_cols <- reactive(purrr::keep(iris, is.numeric))
      register_reactives(numeric_cols)
    })

    shiny::moduleServer("beta", function(input, output, session) {
      styled <- reactive(styler::style_text("1+1"))
      register_reactives(styled)
    })
  }

  shiny::testServer(test_server, {
    header <- reprex_header()

    expect_match(header, "purrr==", fixed = TRUE)
    expect_match(header, "styler==", fixed = TRUE)
  })
})
