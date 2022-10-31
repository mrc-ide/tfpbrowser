#' Tables tab UI
#' Module to create a tabset panel to display csv files in a tables
#' and allow the download of the csv file
#' @param id ID for shiny module namespacing
#' @noRd
tablesUI = function(id) {
  ns = shiny::NS(id)
  # Plots tab panel
  shiny::tabPanel("Tables",

                  # drop down menu to select table
                  shiny::br(),
                  shiny::uiOutput(ns("choose_table")),

                  # display table
                  display_panel(reactable::reactableOutput(ns("display_table"))),

                  # download button to download current table
                  shiny::br(),
                  shiny::fluidRow(
                    shiny::column(12,
                                  align = "center",
                                  shiny::uiOutput(ns("download_table_button")) # nolint
                    )
                  )
  )
}

#' Tables tab Server
#' @param id ID for shiny module namespacing
#' @param cluster_choice which cluster to display the data for
#' @noRd
tablesServer = function(id, cluster_choice) {
  shiny::moduleServer(id, function(input, output, session) {
    ns = session$ns
    # all available tables
    all_files = shiny::reactive({
      return(get_all_files(cluster_choice()))
    })

    # drop down for tables
    output$choose_table = shiny::renderUI({
      all_tables = all_files() %>%
        dplyr::filter(.data$filetype %in% c("csv", "CSV")) %>%
        dplyr::pull(.data$value)
      tables_names = stringr::str_to_title(
        stringr::str_replace_all(
          gsub("\\..*", "", all_tables), "_", " "))
      names(all_tables) = tables_names
      shiny::selectInput(ns("table_type"),
                         label = "Select table type:",
                         choices = all_tables)
    })

    # get table file path
    table_file = shiny::reactive({
      shiny::req(cluster_choice())
      table_file = system.file("app", "www", "data", "scanner_output",
                               cluster_choice(), input$table_type,
                               package = "tfpbrowser")
      return(table_file)
    })

    # check if table available
    table_avail = shiny::reactive({
      src = table_file()
      if (length(src) != 0) {
        return(grepl(".csv", tolower(src)))
      } else {
        return(FALSE)
      }
    })

    # display table if available
    output$display_table = reactable::renderReactable({
      shiny::req(table_file())
      if (table_avail()) {
        table_to_display = suppressMessages(readr::read_csv(table_file()))
        table_to_display_nice = reformat_table(table_to_display)
        reactable::reactable(table_to_display_nice,
                             striped = TRUE,
                             defaultPageSize = 8,
                             wrap = FALSE,
                             height = 400)
      } else {
        shiny::p("No tables available.", style = "color: red; text-align: left")
      }
    })

    # disable download button if no tables available
    shiny::observe({
      if (table_avail() == TRUE) {
        shinyjs::enable("download_table_button")
      } else {
        shinyjs::disable("download_table_button")
      }
    })

    # download table button
    output$download_table_button = shiny::renderUI({
      shiny::downloadButton(ns("download_table"),
                            label = "Download")
    })

    # download table
    output$download_table = shiny::downloadHandler(
      filename = function() {
        glue::glue("{cluster_choice()}_{input$table_type}")
      },
      content = function(file) {
        file.copy(table_file(), file)
      }
    )

    shiny::observeEvent(input$table_type, {
      shinyjs::toggleState("table_type", condition = input$table_type != "")
    })

  })
}
