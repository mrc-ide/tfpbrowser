clusterStatsUI = function(id) {
  ns = NS(id)

  # use details and summary to create expandable section
  htmltools::tags$details(
    # preview of expandable section
    htmltools::tags$summary("Cluster statistics (click to expand)"),
    shiny::br(),

    # text to print choice
    shiny::textOutput(ns("select_text")),
    shiny::br(),

    # output options
    shiny::tabsetPanel(
      id = ns("plot_tabs"),

      # Tables tab
      tablesUI(ns("table1")),

      # Plots tab
      plotsUI(ns("plot1")),

      # RDS tab
      rdsUI(ns("rds1"))
    )
  )
}
