clusterStatsUI = function(id) {
  ns = NS(id)

  box_content = tagList(
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

  # use details and summary to create expandable section
  htmltools::tags$details(
    # preview of expandable section
    htmltools::tags$summary("Cluster statistics (click to expand)"),
    box_content
  )
}
