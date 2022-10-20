#' Cluster ID choice UI
#' Module to create a drop-down to select the cluster ID
#' Server returns a character relating to a data folder name
#' @param id ID for shiny module namespacing
#' @noRd
cluster_idUI = function(id) {
  ns = shiny::NS(id)
  shiny::tagList(
    shiny::selectInput(inputId = ns("cluster_id"),
                       label = "Choose a cluster id:",
                       choices = get_all_clusters(
                         filename = system.file("app", "www", "data",
                                                "scanner_output",
                                                package = "tfpbrowser",
                                                mustWork = TRUE)))
  )
}

#' Cluster ID choice server
#' @param id ID for shiny module namespacing
#' @noRd
cluster_idServer = function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    return(
      shiny::reactive({
        input$cluster_id
      })
    )
  }
  )
}
