test_that("tfpbrowser app initial values are consistent", {
  # Don't run these tests on the CRAN build servers
  skip_on_cran()

  shiny_app <- tfpbrowser::run_app()
  app <- shinytest2::AppDriver$new(shiny_app, name = "tfpbrowser")
  app$expect_values()
})
