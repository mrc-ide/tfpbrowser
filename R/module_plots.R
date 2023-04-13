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
    ns = session$ns # nolint

    # disable dropdown initially
    shiny::observe({
      shinyjs::disable("plot_type")
    })

    # all available plots
    all_files = shiny::reactive({
      return(get_all_files(cluster_choice()))
    }) %>%
      shiny::bindCache(cluster_choice())

    # drop down for plots
    shiny::observeEvent(all_files(), {
      all_images = filter_by_filetype(filenames = all_files(),
                                      filetypes = c("png", "PNG"))
      if (length(all_images) != 0) {
        shinyjs::enable("plot_type")
      } else {
        shinyjs::disable("plot_type")
      }
      shiny::updateSelectInput(session,
                               "plot_type",
                               label = "Select plot type:",
                               choices = all_images)
    })

    # the path to the plot, from the server's perspective
    plot_file = shiny::reactive({
      shiny::req(cluster_choice())
      plot_file = system.file("app", "www", "data", "scanner_output",
                              cluster_choice(), input$plot_type,
                              package = "tfpbrowser")
      return(plot_file)
    }) %>%
      shiny::bindCache(cluster_choice(), input$plot_type)

    # the path to the plot, from the browser's perspective
    plot_url = shiny::reactive({
      shiny::req(plot_file())
      fs::path_rel(plot_file(),
                   system.file("app", package = "tfpbrowser"))
    })

    # check if plots available
    plot_avail = shiny::reactive({
      src = plot_url()
      if (length(src) != 0) {
        return(grepl(".png", tolower(src)))
      } else {
        return(FALSE)
      }
    })

    # display plot if available
    output$display_plot = shiny::renderUI({
      if (plot_avail()) {
        shiny::img(src = plot_url(), width = "400px")
      } else {
        shiny::p("No plots available.", style = "color: red; text-align: left")
      }
    })

    # disable download button if no plots available
    shiny::observeEvent(plot_avail(), {
      shinyjs::toggleState("download_plot", condition = plot_avail())
    })

    shiny::observeEvent(input$plot_type, {
      shinyjs::toggleState("download_plot", condition = input$plot_type != "")
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

  })

}
