app_dir <- function(name) {
  path <- system.file("examples-shiny", name, package = "shinyreprex")
  if (!nzchar(path)) skip(paste0("Example app '", name, "' is not installed"))
  path
}

test_that("The lockfile example app generates a script that reproduces its own output", {
  skip_if_not_installed("shiny")

  shiny::testServer(app_dir("lockfile"), {
    session$setInputs(
      min_width  = 0.5,
      summary_fn = "median",
      columns    = c("Sepal.Width", "Petal.Length"),
      update     = 1
    )

    expect_identical(reprex_packages(summary_tbl), "purrr")
    expect_identical(
      eval(parse(text = output$code), envir = new.env()),
      summary_tbl()
    )
  })
})

test_that("The lockfile example app offers a restorable lockfile from both the module and the custom picker", {
  skip_on_cran()
  skip_if_not_installed("shiny")
  skip_if_not_installed("renv")

  shiny::testServer(app_dir("lockfile"), {
    session$setInputs(
      min_width  = 0.5,
      summary_fn = "median",
      columns    = "Sepal.Width",
      update     = 1,
      packages   = "purrr"
    )

    # Reading a download output runs its content function and returns the path.
    for (lock in c(output$`lock-download`, output$custom_lock)) {
      parsed <- renv::lockfile_read(lock)
      expect_identical(parsed$R$Version, as.character(getRversion()))
      expect_identical(
        parsed$Packages$purrr$Version,
        as.character(utils::packageVersion("purrr"))
      )
    }
  })
})
