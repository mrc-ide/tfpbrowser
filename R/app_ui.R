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
            cluster_idUI("choice1"),

            # output options
            shiny::tabsetPanel(id = "plot_tabs",

             # Tables tab
             tablesUI("table1"),

             # Plots tab
             plotsUI("plot1")

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
