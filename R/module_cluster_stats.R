clusterStatsUI = function(id) {
  ns = shiny::NS(id)

  box_content = shiny::tagList(
    shiny::br(),

    # text to print choice
    shiny::textOutput(ns("select_text")),
    shiny::br(),

    # output options
    shiny::tabsetPanel(
      id = ns("plot_tabs"),

      # Tabs for "Tables", "Plots" and "RDS"
      tablesUI(ns("table1")),
      plotsUI(ns("plot1")),
      rdsUI(ns("rds1"))
    )
  )

  # Help icon for the cluster-statistics panel
  # - Clicking this icon does not lead to the underlying accordion_panel being expanded
  help_text = shiny::tags$p(
    "The 'Cluster statistics' panel can be used to view or download data about a cluster.",
    "First, select a cluster by clicking on a node in one of the tree-views or scatter plots."
  )
  help_popover = bsicons::bs_icon("question-circle", size = "1.5em") %>%
    bslib::popover(help_text) %>%
    htmltools::tagAppendAttributes(`data-bs-toggle` = "collapse", `data-bs-target` = NA)

  # Expandable panel containing the cluster-statistics details
  bslib::accordion(
    id = "cluster_stats_accordion",
    open = FALSE,
    bslib::accordion_panel(
      title = "Cluster statistics (click to expand)",
      box_content,
      icon = help_popover
    )
  )
}
