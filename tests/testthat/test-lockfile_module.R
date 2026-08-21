test_that("lockfileUI returns a download control namespaced to the module id", {
  ui <- lockfileUI("lock", "Grab it")
  expect_s3_class(ui, "shiny.tag")
  expect_match(as.character(ui), "lock-download", fixed = TRUE)
  expect_match(as.character(ui), "Grab it", fixed = TRUE)
})

test_that("lockfileServer wires into an app without error", {
  server <- function(input, output, session) {
    r <- reactive(iris[iris$Petal.Width > input$w, ])
    lockfileServer("lock", r)
  }

  # Constructing the module inside testServer runs its setup; a broken wiring
  # would throw here. The download content itself is exercised via
  # reprex_lockfile()'s own tests rather than a live renv snapshot.
  shiny::testServer(server, {
    session$setInputs(w = 1)
    succeed()
  })
})
