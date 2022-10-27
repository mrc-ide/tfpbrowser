#' Shiny application server
#' @param input,output,session Internal parameters for `{shiny}`.
#' @noRd
app_server = function(input, output, session) {

  # Load mutation selectize options on server-side
  # (quicker loading on slower browsers)
  # This is because there is a lot of options
  # client-side processing is slow
  shiny::updateSelectizeInput(session,
                       "mutations",
                       choices = get_unique_mutations(
                         system.file("app", "www", "data",
                                     "sarscov2-audacity-westerncape2021.csv",
                                     package = "tfpbrowser",
                                     mustWork = TRUE)),
                       server = TRUE)

  # load static html for treeview
  output$treeview = shiny::renderUI({
    filename = get_filename(input$widgetChoice)
    shiny::div(
      style = "width:100%; align:center",
      id = "treeview",
      htmltools::tags$iframe(src = filename,
                             width = "100%",
                             height = 600)
    )
  })

  # Choose Cluster ID -------------------------------------------------------
  number_from_cluster_mod = cluster_idServer("choice1")

  # Tables Tab --------------------------------------------------------------
  tablesServer(
    "table1",
    cluster_choice = number_from_cluster_mod
  )

  # Plots Tab ----------------------------------------------------------
  plotsServer(
    "plot1",
    cluster_choice = number_from_cluster_mod
  )

} # end server function
