library(testthat)
library(tfpbrowser)

test_check("tfpbrowser")

shinytest2::test_app()
