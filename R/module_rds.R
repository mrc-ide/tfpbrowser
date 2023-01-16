#' rds tab UI
#' Module to create a tabset panel to allow the download of the rds file
#' @param id ID for shiny module namespacing
#' @noRd
rdsUI = function(id) {
  ns = shiny::NS(id)
  # RDS files tab panel
  downloader_tab_panel(title = "RDS Files",
                       chooser_id = ns("rds_type"),
                       download_button_id = ns("download_rds"),
                       panel = display_panel(shiny::uiOutput(ns("display_rds"))))
}

#' rds tab Server
#' @param id ID for shiny module namespacing
#' @param cluster_choice which cluster to display the data for
#' @noRd
rdsServer = function(id, cluster_choice) {
  shiny::moduleServer(id, function(input, output, session) {
    ns = session$ns

    # all available rds
    all_files = shiny::reactive({
      return(get_all_files(cluster_choice()))
    }) %>%
      shiny::bindCache(cluster_choice())

    # drop down for rds
    shiny::observeEvent(all_files(), {
      all_rds = filter_by_filetype(filenames = all_files(),
                                   filetypes = c("rds", "RDS"))
      shiny::updateSelectInput(session,
                               "rds_type",
                               label = "Select RDS file:",
                               choices = all_rds)
    })

    # get rds file
    rds_file = shiny::reactive({
      shiny::req(cluster_choice())
      rds_file = system.file("app", "www", "data", "scanner_output",
                              cluster_choice(), input$rds_type,
                              package = "tfpbrowser")
      return(rds_file)
    }) %>%
      shiny::bindCache(cluster_choice(), input$rds_type)

    # check if plots available
    rds_avail = shiny::reactive({
      src = fs::path_rel(rds_file(), system.file("app", package = "tfpbrowser"))
      if (length(src) != 0) {
        return(grepl(".rds", tolower(src)))
      } else {
        return(FALSE)
      }
    })

    # display message if rds available
    output$display_rds = shiny::renderUI({
      if (rds_avail()) {
        shiny::p("Click below to download the file.", style = "color: black; text-align: left")
      } else {
        shiny::p("No RDS files available.", style = "color: red; text-align: left")
      }
    })

    # disable download button if no rds files available
    shiny::observe({
      if (rds_avail() == TRUE) {
        shinyjs::enable("download_rds")
      } else {
        shinyjs::disable("download_rds")
      }
    })

    # download plot
    output$download_rds = shiny::downloadHandler(
      filename = function() {
        glue::glue("{cluster_choice()}_{input$rds_type}")
      },
      content = function(file) {
        file.copy(rds_file(), file)
      }
    )

    shiny::observeEvent(input$rds_type, {
      shinyjs::toggleState("rds_type", condition = input$rds_type != "")
    })

  })

}
