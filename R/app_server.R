#' Shiny application server
#' @param input,output,session Internal parameters for `{shiny}`.
#' @noRd
app_server = function(input, output, session) {

  # Load treeview -----------------------------------------------------------
  imported_ggtree = shiny::reactive({
    shiny::req(input$widgetChoice)
    filename = get_filename(input$widgetChoice)
    readRDS(filename)
  })

  # create ggiraph output from saved ggplot2 outputs
  output$treeview = ggiraph::renderGirafe({
    shiny::req(input$widgetChoice)
    # define tooltip
    tooltip_css = paste0(
      "background-color:black;",
      "color:grey;",
      "padding:14px;",
      "border-radius:8px;",
      "font-family:\"Courier New\",monospace;"
    )
    # set options
    if (input$widgetChoice == "tree-mutations.rds") {
      girafe_options = list(
        ggiraph::opts_selection(css = "fill:red;"),
        ggiraph::opts_selection_inv(css = "fill:grey;"),
        ggiraph::opts_sizing(rescale = FALSE),
        ggiraph::opts_zoom(max = 5),
        ggiraph::opts_tooltip(
          css = tooltip_css,
          use_fill = FALSE
        )
      )
    } else {
      girafe_options = list(
        ggiraph::opts_selection(type = "single"),
        ggiraph::opts_sizing(rescale = FALSE),
        ggiraph::opts_zoom(max = 5),
        ggiraph::opts_tooltip(
          css = tooltip_css,
          use_fill = FALSE
        )
      )
    }
    # set size
    w = shinybrowser::get_width() / 72
    h = (1800 - 40) / 72
    # make tree
    suppressWarnings(
      ggiraph::girafe(
        ggobj = imported_ggtree(),
        width_svg = w,
        height_svg = h,
        options = girafe_options
      )
    )
  }) %>%
    shiny::bindCache(input$widgetChoice)

  # disable dropdown unless mutation treeview
  shiny::observe({
    shiny::req(input$widgetChoice)
    shinyjs::toggleState(id = "mutationChoice",
                         condition = input$widgetChoice == "tree-mutations.rds")
  })

  # get selected nodes from mutation choice
  shiny::observeEvent(input$mutationChoice, {

    nodeChoice = selected_mut_nodes(input$mutationChoice)

    # the 'node' column contains integers that define the IDs for graph-nodes in the htmlwidget
    node_map = imported_ggtree()$data[c("cluster_id", "node")]
    selection_map = dplyr::filter(
      node_map,
      .data[["cluster_id"]] %in% nodeChoice
    )

    session$sendCustomMessage(
      # "<output_id>_set" defines the collection of selected nodes on the htmlwidget
      type = paste0("treeview", "_set"),
      #   but the nodes in the widget are ID's using strings, not integers
      message = as.character(selection_map[["node"]])
    )
  })

  # get selected cluster id based on widget choice
  selected_cluster_id = shiny::reactive({
    shiny::req(input$widgetChoice)
    shiny::req(input$treeview_selected)
    get_selected_cluster_id(widgetChoice = input$widgetChoice,
                            treeviewSelected = tail(input$treeview_selected, 1))
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
