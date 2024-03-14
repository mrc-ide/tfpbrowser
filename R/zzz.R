#' .onload
#'
#' @param ... not currently used
#'
#' @description Mounts /www folder in browser so logo image can be found in app
#'
.onload = function(...) {
  shiny::addResourcePath(
    "www",
    system.file("www",
      package = "tfpbrowser",
      mustWork = TRUE
    )
  )
}
