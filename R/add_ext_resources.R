#' Add external resources to the shiny app
#'
#' Function is internally used to add external
#' resources inside the Shiny application.
add_ext_resources = function() {
  shiny::addResourcePath(
    "www", app_sys("app/www")
  )
  shiny::tags$head(
    shinyjs::useShinyjs()
  )
}
