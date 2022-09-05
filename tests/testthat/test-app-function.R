test_that("tfpbrowser app initial values are consistent", {
  if (interactive()) {
    shiny_app <- tfpbrowser::run_app()
    app <- shinytest2::AppDriver$new(shiny_app,
                                     name = "tfpbrowser")
    navbar_tab_items = app$get_text(".nav-item")
    observed_navbar_tab_items = stringr::str_squish(navbar_tab_items)
    expected_navbar_tab_items = c("Data", "About", "Tables", "Plots")
    testthat::expect_equal(observed_navbar_tab_items, expected_navbar_tab_items)
  }
})

