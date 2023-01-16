#' Plots tab UI
#' Module to create a tabset panel to display png files as image
#' and allow the download of the png file
#' @param id ID for shiny module namespacing
#' @noRd
plotsUI = function(id) {
  ns = shiny::NS(id)
  # Plots tab panel
  downloader_tab_panel(title = "Plots",
                       chooser_id = ns("plot_type"),
                       download_button_id = ns("download_plot"),
                       panel = display_panel(shiny::uiOutput(ns("display_plot"))))

}

#' Plots tab Server
#' @param id ID for shiny module namespacing
#' @param cluster_choice which cluster to display the data for
#' @noRd
plotsServer = function(id, cluster_choice) {
  shiny::moduleServer(id, function(input, output, session) {
    ns = session$ns

    # all available plots
    all_files = shiny::reactive({
      return(get_all_files(cluster_choice()))
    }) %>%
      shiny::bindCache(cluster_choice())

    # drop down for plots
    shiny::observeEvent(all_files(), {
      all_images = filter_by_filetype(filenames = all_files(),
                                      filetypes = c("png", "PNG"))
      shiny::updateSelectInput(session,
                               "plot_type",
                               label = "Select plot type:",
                               choices = all_images)
    })

    # get plot file
    plot_file = shiny::reactive({
      shiny::req(cluster_choice())
      plot_file = system.file("app", "www", "data", "scanner_output",
                              cluster_choice(), input$plot_type,
                              package = "tfpbrowser")
      return(plot_file)
    }) %>%
      shiny::bindCache(cluster_choice(), input$plot_type)

    # check if plots available
    plot_avail = shiny::reactive({
      src = fs::path_rel(plot_file(), system.file("app", package = "tfpbrowser"))
      if (length(src) != 0) {
        return(grepl(".png", tolower(src)))
      } else {
        return(FALSE)
      }
    })

    # display plot if available
    output$display_plot = shiny::renderUI({
      if (plot_avail()) {
        shiny::img(src = fs::path_rel(plot_file(),
                                      system.file("app", package = "tfpbrowser")),
                   width = "400px")
      } else {
        shiny::p("No plots available.", style = "color: red; text-align: left")
      }
    })

    # disable download button if no plots available
    shiny::observe({
      if (plot_avail() == TRUE) {
        shinyjs::enable("download_plot")
      } else {
        shinyjs::disable("download_plot")
      }
    })

    # download plot
    output$download_plot = shiny::downloadHandler(
      filename = function() {
        glue::glue("{cluster_choice()}_{input$plot_type}")
      },
      content = function(file) {
        file.copy(plot_file(), file)
      }
    )

    shiny::observeEvent(input$plot_type, {
      shinyjs::toggleState("plot_type", condition = input$plot_type != "")
    })

  })

}
