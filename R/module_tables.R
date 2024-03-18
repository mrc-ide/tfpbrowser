#' Tables tab UI
#' Module to create a tabset panel to display csv files in a tables
#' and allow the download of the csv file
#' @param id ID for shiny module namespacing
#' @noRd
tablesUI = function(id) {
  ns = shiny::NS(id)
  # Tables tab panel
  downloader_tab_panel(
    title = "Tables",
    chooser_id = ns("table_type"),
    download_button_id = ns("download_table"),
    panel = display_panel(reactable::reactableOutput(ns("display_table")))
  )
}

#' Tables tab Server
#' @param id ID for shiny module namespacing
#' @param cluster_choice which cluster to display the data for
#' @param   data_dir   The data directory for the app.
#' @noRd
tablesServer = function(id, cluster_choice, data_dir) {
  shiny::moduleServer(id, function(input, output, session) {
    ns = session$ns # nolint

    # disable dropdown initially
    shiny::observe({
      shinyjs::disable("table_type")
    })

    # all available tables
    all_files = shiny::reactive({
      return(get_all_files(cluster_choice(), data_dir = data_dir))
    }) %>%
      shiny::bindCache(cluster_choice())

    # drop down for tables
    shiny::observeEvent(all_files(), {
      all_tables = filter_by_filetype(
        filenames = all_files(),
        filetypes = c("csv", "CSV")
      )
      if (length(all_tables) != 0) {
        shinyjs::enable("table_type")
      } else {
        shinyjs::disable("table_type")
      }
      shiny::updateSelectInput(session,
        "table_type",
        label = "Select table type:",
        choices = all_tables
      )
    })

    # get table file path
    table_file = shiny::reactive({
      shiny::req(cluster_choice())
      table_file = file.path(data_dir, "scanner_output", cluster_choice(), input$table_type)
      return(table_file)
    }) %>%
      shiny::bindCache(cluster_choice(), input$table_type)

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
          height = 400
        )
      } else {
        shiny::p("No tables available.", style = "color: red; text-align: left")
      }
    })

    # disable download button if no tables available
    shiny::observeEvent(table_avail(), {
      shinyjs::toggleState("download_table", condition = table_avail())
    })

    shiny::observeEvent(input$table_type, {
      shinyjs::toggleState("download_table", condition = input$table_type != "")
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
  })
}
