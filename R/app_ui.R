#' Shiny application user interface
#'
#' @param request Internal parameter for `{shiny}`.
#' @noRd
app_ui = function(request) {
  data_dir = get_data_dir()

  shiny::tagList(
    shinyjs::useShinyjs(),
    shinybrowser::detect(),
    shiny::navbarPage(
      # title
      title = place_title_logo(),
      header = add_ext_resources(data_dir),
      # theme
      theme = bslib::bs_theme(
        version = 5,
        bootswatch = "minty",
        bg = "#EBEEEE",
        fg = "#002147",
        primary = "#003E74",
        secondary = "#9D9D9D"
      ),

      # Input widgets
      shiny::tabPanel(
        title = "Data",
        shiny::fluidRow(
          shiny::column(12, clusterStatsUI(id = NULL))
        ), # end fluid row

        # Bottom row - show tree (static html output from tfpscanner)
        shiny::fluidRow(
          shiny::column(12,
            id = "view-container",
            shiny::div(
              id = "view-selection",
              htmltools::tags$details(
                id = "sidebar-toggle",
                open = "open",
                `aria-role` = "button",
                `aria-label` = "Toggle sidebar visibility",
                htmltools::tags$summary(
                  shiny::span(">>"),
                  shiny::span("<<")
                )
              ),
              # choose type of treeview
              shiny::selectInput(
                inputId = "widgetChoice",
                label = "View",
                choices = c("None" = ""),
                selectize = FALSE
              ),

              # choose type of mutation
              shiny::selectInput(
                inputId = "mutationChoice",
                label = "Mutation",
                choices = character(0),
                selectize = FALSE
              ),

              # choose type of sequence
              shiny::selectInput(
                inputId = "sequenceChoice",
                label = "Sequence",
                choices = NULL,
                selectize = FALSE
              ),
            ),
            shiny::div(
              id = "view-graphic",
              # markdown files to add description
              shiny::uiOutput("tree_md_files"),

              # show treeview widget
              shiny::wellPanel(
                ggiraph::girafeOutput("treeview"),
                style = "background: white; height: 1800px;",
              ),
              shiny::br()
            )
          )
        ) # end fluid row
      ), # end "data" page

      # about page
      shiny::tabPanel(
        title = "About",
        shiny::includeMarkdown(
          system.file("app", "www", "content", "about.md", package = "tfpbrowser", mustWork = TRUE)
        )
      )
    ) # end navbar page
  ) # end tag list
}
