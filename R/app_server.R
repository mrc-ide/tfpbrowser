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
  output$treeview = ggiraph::renderGirafe({
    filename = get_filename(input$widgetChoice)
    g = readRDS(filename)
    tooltip_css = paste0(
      "background-color:black;",
      "color:grey;",
      "padding:14px;",
      "border-radius:8px;",
      "font-family:\"Courier New\",monospace;"
    )
    suppressWarnings(ggiraph::girafe(ggobj = g,
                    options = list(
                      ggiraph::opts_selection(
                        type = "single"),
                      ggiraph::opts_sizing(
                        width = 0.8),
                      ggiraph::opts_tooltip(
                        css = tooltip_css,
                        use_fill = FALSE)
                      )
                    ))
  })

  # get look up table for data_id vs cluster id
  # I know this code isn't great, and should probably be in a module
  # but I'm hoping that this code doesn't stay in the app
  # after this week
  selected_cluster_id = shiny::reactive({
    filename = get_filename(input$widgetChoice)
    g = readRDS(filename)
    built = suppressWarnings(ggplot2::ggplot_build(g))
    n_layers = length(built$data)
    ids = built$data[n_layers][[1]]["data_id"]
    tooltip_ids = get_cluster_ID(built$data[n_layers][[1]]$tooltip)
    ids = ids %>%
      dplyr::mutate(cluster_ids = tooltip_ids)
    selected_cluster = as.numeric(ids[which(ids$data_id == input$treeview_selected), 2])
    return(selected_cluster)
  })

  # output result of click
  output$select_text = shiny::renderText({
    paste("You have selected cluster ID:", selected_cluster_id())
  })

  # Tables Tab --------------------------------------------------------------
  tablesServer(
    "table1",
    cluster_choice = selected_cluster_id
  )

  # Plots Tab ----------------------------------------------------------
  plotsServer(
    "plot1",
    cluster_choice = selected_cluster_id
  )

  # RDS Tab ----------------------------------------------------------
  rdsServer(
    "rds1",
    cluster_choice = selected_cluster_id
  )

} # end server function
