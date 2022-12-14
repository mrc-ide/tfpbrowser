#' Shiny application user interface
#'
#' @param request Internal parameter for `{shiny}`.
#' @noRd
app_ui = function(request) {
  shiny::tagList(

    shinyjs::useShinyjs(),

    shiny::navbarPage(
      # title
      title = "tfpbrowser",

      header = add_ext_resources(),
      # theme
      theme = bslib::bs_theme(version = 4,
                              bootswatch = "minty",
                              bg = "#EBEEEE",
                              fg = "#002147",
                              primary = "#003E74",
                              secondary = "#9D9D9D"),

      # Input widgets
      shiny::tabPanel(
        title = "Data",

        shiny::fluidRow(
          shiny::column(12,
                        # use details and summary to create expandable section
                        htmltools::tags$details(
                          # preview of expandable section
                          htmltools::tags$summary("Download Files (click to expand)"),

                          shiny::br(),

                          # text to print choice
                          shiny::textOutput("select_text"),
                          shiny::br(),

                          # output options
                          shiny::tabsetPanel(id = "plot_tabs",

                                             # Tables tab
                                             tablesUI("table1"),

                                             # Plots tab
                                             plotsUI("plot1"),

                                             # RDS tab
                                             rdsUI("rds1")

                          )
                        )
                        )
          ), # end fluid row

        # Bottom row - show tree (static html output from tfpscanner)
        shiny::fluidRow(

          shiny::column(12,

            # choose type of treeviw
            shiny::radioButtons(inputId = "widgetChoice",
                                label = "Select treeview",
                                choices = c(
                                  "Logistic growth rate",
                                  "Simple logistic growth rate",
                                  "Simple trait log odds",
                                  "Mutations"),
                                inline = TRUE),

            # show treeview widget
            shiny::wellPanel(
              ggiraph::girafeOutput("treeview"),
              style = "background: white",
            ),
            shiny::br()
          )
        ) # end fluid row
      ), # end "data" page

      # about page
      shiny::tabPanel(
        title = "About",
        shiny::includeMarkdown(system.file("app", "www", "content", "about.md",
                                           package = "tfpbrowser",
                                           mustWork = TRUE))
        )

    ) # end navbar page
  ) # end tag list

}
