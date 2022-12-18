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

  # get selected cluster id based on widget choice
  selected_cluster_id = shiny::reactive({
    get_selected_cluster_id(widgetChoice = input$widgetChoice,
                            treeviewSelected = input$treeview_selected)
  }) %>%
    shiny::bindCache(input$widgetChoice, input$treeview_selected)

  # output result of click
  output$select_text = shiny::renderText({
    paste("You have selected cluster ID:", selected_cluster_id())
  }) %>%
    shiny::bindCache(input$widgetChoice, input$treeview_selected)

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
