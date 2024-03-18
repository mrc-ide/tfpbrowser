#' Obtain the optionally-specified data directory for the app
#'
#' The user can specify a data-directory by specifying the environment variable `APP_DATA_DIR`.
#' When given, this directory must have subdirectories: `mutations`, `scanner_output`, `sequences`,
#' `treeview`.
#' When not specified, data will be taken from the package-embedded directory `/app/www/data`.
#'
#' @return   Scalar string. The data-directory for use in the app.

get_data_dir = function() {
  Sys.getenv(
    "APP_DATA_DIR",
    system.file("app", "www", "data", package = "tfpbrowser")
  )
}
