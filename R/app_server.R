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



  # Load treeview -----------------------------------------------------------

  # create plotly output from saved ggplot2 outputs
  output$treeview = plotly::renderPlotly({
    filename = get_filename(input$widgetChoice)
    g = readRDS(filename)
    plotly::ggplotly(p = g,
                     tooltip = c("key"))
  })

  # record click
  click_output = shiny::reactive({
    click_data = plotly::event_data("plotly_click")
    if (is.null(click_data)) {
      return("Click a point")
    }
    output = click_data$key
    return(output)
  })

  # output result of click
  output$select_text <- shiny::renderText({
    paste("You have selected cluster ID:", click_output())
  })

  ##### need to link click to drop down!!!!!!!!!!!!

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

  # RDS Tab ----------------------------------------------------------
  rdsServer(
    "rds1",
    cluster_choice = number_from_cluster_mod
  )

} # end server function
