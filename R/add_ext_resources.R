#' Add external resources to the shiny app
#'
#' Function is internally used to add external
#' resources inside the Shiny application.
add_ext_resources = function() {
  shiny::addResourcePath(
    "www", system.file("app/www", package = "tfpbrowser", mustWork = TRUE)
  )
  shiny::tags$head(
    shinyjs::useShinyjs()
  )
}
