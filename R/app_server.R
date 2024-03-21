#' Shiny application server
#' @param input,output,session Internal parameters for `{shiny}`.
#' @noRd
app_server = function(input, output, session) {
  data_dir = get_data_dir()

  # Update the available treeviews & mutations
  shiny::observe({
    new_choices = c(
      c("None" = ""),
      available_treeview(data_dir = data_dir)
    )
    shiny::updateSelectInput(
      session = session,
      inputId = "widgetChoice",
      choices = new_choices
    )
  })

  shiny::observe({
    mutation_set = available_mutations(data_dir = data_dir)
    shiny::updateSelectInput(
      session = session,
      inputId = "mutationChoice",
      choices = mutation_set
    )
  })

  # Load treeview -----------------------------------------------------------
  imported_ggtree = shiny::reactive({
    shiny::req(input$widgetChoice)
    filename = get_filename(input$widgetChoice, data_dir)
    readRDS(filename)
  })

  # create ggiraph output from saved ggplot2 outputs
  output$treeview = ggiraph::renderGirafe({
    shiny::req(input$widgetChoice)

    # set the relative height/width of the ggiraph-based graphs
    is_dendrogram = grepl("^tree-", x = input$widgetChoice)
    width = shinybrowser::get_width() / 72
    height = if (is_dendrogram) {
      (1800 - 40) / 72
    } else {
      (600 - 40) / 72
    }

    create_girafe(
      ggobj = imported_ggtree(),
      widget_choice = input$widgetChoice,
      width_svg = width,
      height_svg = height,
      suppress_warnings = TRUE
    )
  }) %>%
    shiny::bindCache(input$widgetChoice)

  # Mutation colouring ------------------------------------------------------

  # disable dropdown unless mutation treeview
  shiny::observe({
    choice = ifelse(input$widgetChoice != "", input$widgetChoice, "")
    # toggle mutation dropdown
    shinyjs::toggleElement(
      id = "mutationChoice",
      condition = choice == "tree-mutations.rds"
    )
    # toggle sequence dropdown
    shinyjs::toggleElement(
      id = "sequenceChoice",
      condition = choice == "tree-sequences.rds"
    )
    # select input for sequences
    if (choice == "tree-sequences.rds") {
      avail_seqs = data.table::as.data.table(available_sequences(data_dir))
      names(avail_seqs) = "Sequences"
      shiny::updateSelectInput(
        inputId = "sequenceChoice",
        choices = avail_seqs
      )
    }
  })

  # get selected nodes from mutation choice
  shiny::observeEvent(input$mutationChoice, {
    nodeChoice = selected_mut_nodes(input$mutationChoice, data_dir)

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

  # Sequence colouring ------------------------------------------------------

  # get selected nodes from sequence choice
  shiny::observeEvent(input$sequenceChoice, {
    nodeChoice = selected_seq_nodes(input$sequenceChoice, data_dir)

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

  # Get click ---------------------------------------------------------------

  # get selected cluster id based on widget choice
  selected_cluster_id = shiny::reactive({
    shiny::req(input$widgetChoice)
    shiny::req(input$treeview_selected)
    get_selected_cluster_id(
      widgetChoice = input$widgetChoice,
      treeviewSelected = utils::tail(input$treeview_selected, 1),
      data_dir = data_dir
    )
  }) %>%
    shiny::bindCache(input$widgetChoice, input$treeview_selected)

  # output result of click
  output$select_text = shiny::renderText({
    paste("You have selected cluster ID:", selected_cluster_id())
  }) %>%
    shiny::bindCache(input$widgetChoice, input$treeview_selected)

  # select markdown file and display
  output$tree_md_files = shiny::renderUI({
    shiny::req(input$widgetChoice)
    fname = stringr::str_replace(input$widgetChoice, ".rds", ".md")
    shiny::includeMarkdown(system.file("app", "www", "content", "treeview",
      fname,
      package = "tfpbrowser",
      mustWork = TRUE
    ))
  })

  # Tables Tab --------------------------------------------------------------
  tablesServer(
    "table1",
    cluster_choice = selected_cluster_id,
    data_dir = data_dir
  )

  # Plots Tab ----------------------------------------------------------
  plotsServer(
    "plot1",
    cluster_choice = selected_cluster_id,
    data_dir = data_dir
  )

  # RDS Tab ----------------------------------------------------------
  rdsServer(
    "rds1",
    cluster_choice = selected_cluster_id,
    data_dir = data_dir
  )
} # end server function
