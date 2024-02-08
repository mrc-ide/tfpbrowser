#' Add external resources to the shiny app
#'
#' Function is internally used to add external resources inside the Shiny application.
#'
#' @param   data_dir   The (server-side) file-path for the directory containing the data for
#'   presentation. This should contain a `scanner_output` subdirectory, which will be mounted as
#'   /data/scanner_output/ in the browser.

add_ext_resources = function(data_dir) {
  shiny::addResourcePath(
    "www", system.file("app/www", package = "tfpbrowser", mustWork = TRUE)
  )
  shiny::addResourcePath(
    "data/scanner_output", file.path(data_dir, "scanner_output")
  )
  shiny::tags$head(
    shinyjs::useShinyjs(),
    shiny::tags$link(rel = "stylesheet", type = "text/css", href = "www/tfpbrowser-style.css")
  )
}
