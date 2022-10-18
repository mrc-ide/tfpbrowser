# Module 1, which will allow to select a cluster ID
clusterid_ui = function(id) {
  ns = shiny::NS(id)
  shiny::tagList(
    # Add a slider to select a number
    shiny::selectInput(inputId = ns("cluster_id"),
                       label = "Choose a cluster id:",
                       choices = get_all_clusters(
                         filename = system.file("app", "www", "data",
                                                "scanner_output",
                                                package = "tfpbrowser",
                                                mustWork = TRUE)))
  )
}

clusterid_server = function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    # We return a reactive function from this server,
    # that can be passed along to other modules
    return(
      shiny::reactive({
        input$cluster_id
      })
    )
  }
  )
}
