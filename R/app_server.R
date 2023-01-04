#' Shiny application server
#' @param input,output,session Internal parameters for `{shiny}`.
#' @noRd
app_server = function(input, output, session) {

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
    w = shinybrowser::get_width() / 72
    h = (1800 - 40) / 72
    suppressWarnings(ggiraph::girafe(ggobj = g,
                                     width_svg = w,
                                     height_svg = h,
                    options = list(
                      ggiraph::opts_selection(
                        type = "single"),
                      ggiraph::opts_sizing(rescale = FALSE),
                      ggiraph::opts_zoom(max = 5),
                      ggiraph::opts_tooltip(
                        css = tooltip_css,
                        use_fill = FALSE)
                      )
                    ))
  })

  # disable dropdown unless mutation treeview
  shiny::observe({
    shiny::req(input$widgetChoice)
    shinyjs::toggleState(id = "mutationChoice",
                         condition = input$widgetChoice == "tree-mutations.rds")
  })

  # get selected cluster id based on widget choice
  selected_cluster_id = shiny::reactive({
    get_selected_cluster_id(widgetChoice = input$widgetChoice,
                            treeviewSelected = input$treeview_selected)
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
