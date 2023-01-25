#' place_title_logo
#'
#' @description Function to place the logo to the left of the title
#'
place_title_logo = function(){
  title = shiny::h4(
    shiny::img(
      src = "www/logo.png",
      contentType = "image/png",
      height = 80, width = 100),
    "tpfbrowser")

  return(title)
}
