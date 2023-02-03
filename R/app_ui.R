#' Shiny application user interface
#'
#' @param request Internal parameter for `{shiny}`.
#' @noRd
app_ui = function(request) {
  shiny::tagList(

    shinyjs::useShinyjs(),
    shinybrowser::detect(),

    shiny::navbarPage(
      # title
      title = place_title_logo(),

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

                        # choose type of treeview
                        shiny::radioButtons(inputId = "widgetChoice",
                                            label = "Select treeview",
                                            choices = c(c("None" = ""), available_treeview()),
                                            inline = TRUE),

                        # choose type of mutation
                        shiny::selectizeInput(inputId = "mutationChoice",
                                              label = "Select mutation",
                                              choices = available_mutations()),

                        # choose type of sequence
                        shiny::selectizeInput(inputId = "sequenceChoice",
                                              label = "Select sequence",
                                              choices = NULL),

                        # markdown files to add description
                        shiny::uiOutput("tree_md_files"),

                        # show treeview widget
                        shiny::wellPanel(
                          ggiraph::girafeOutput("treeview"),
                          style = "background: white; height: 1800px;",
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
