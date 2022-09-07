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
          # left hand side - show tree (static html output from tfpscanner)
          shiny::column(6,
            # choose type of treeviw
            shiny::radioButtons(inputId = "widgetChoice",
                                label = "Select widget",
                                choices = c(
                                  "Logistic growth rate",
                                  "Simple logistic growth rate",
                                  "Simple trait log odds"),
                                inline = TRUE),
            # show treeview widget
            shiny::wellPanel(
              shiny::htmlOutput("treeview"),
              style = "background: white",
            ),
            # search bar for mutations
            shiny::br(),
            # Options are stored server-side. See server.R
            shiny::selectizeInput(inputId = "mutations",
                                  label = "Search for mutation",
                                  choices = NULL,
                                  multiple = FALSE)
          ),

          # Right hand side - outputs ------------------------------------------
          shiny::column(6,
            # choose cluster id
            shiny::selectInput(inputId = "cluster_id",
                               label = "Choose a cluster id:",
                               choices = get_all_clusters(filename = system.file("app", "www", "data",
                                                                                 "scanner_output",
                                                                                 package = "tfpbrowser",
                                                                                 mustWork = TRUE))),
            # output options
            shiny::tabsetPanel(id = "plot_tabs",
             # Tables tab
             shiny::tabPanel("Tables",
                             # drop down menu to select table
                             shiny::br(),
                             shiny::uiOutput("choose_table"),
                             # display table
                             shiny::wellPanel(
                               shiny::fluidRow(shiny::column(
                                 12,
                                 reactable::reactableOutput("display_table"),
                                 align = "center",
                                 style = "height:400px;"
                               )),
                               style = "background: white"
                             ),
                             # download button to download current table
                             shiny::br(),
                             shiny::fluidRow(
                               shiny::column(12,
                                             align = "center",
                                             shiny::uiOutput("download_table_button") # nolint
                               )
                             )
             ),
             # Plots tab
             shiny::tabPanel("Plots",
                             # drop down menu to select plot
                             shiny::br(),
                             shiny::uiOutput("choose_plot"),
                             # display plot
                             shiny::wellPanel(
                               shiny::fluidRow(shiny::column(
                                 12,
                                 align = "center",
                                 shiny::uiOutput("display_plot"),
                                 style = "height:400px;")),
                               style = "background: white"
                             ),
                             # download button to download current plot
                             shiny::br(),
                             shiny::fluidRow(
                               shiny::column(12,
                                             align = "center",
                                             shiny::uiOutput("download_plot_button") #nolint
                               )
                             )
             )
           )
          ) # end right column
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
