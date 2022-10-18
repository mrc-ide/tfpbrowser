plotsUI = function(id) {
  ns = shiny::NS(id)
  # Plots tab panel
  shiny::tabPanel("Plots",
                  # drop down menu to select plot
                  shiny::br(),
                  shiny::uiOutput(ns("choose_plot")),
                  # display plot
                  shiny::wellPanel(
                    shiny::fluidRow(shiny::column(
                      12,
                      align = "center",
                      shiny::uiOutput(ns("display_plot")),
                      style = "height:400px;")),
                    style = "background: white"
                  ),
                  # download button to download current plot
                  shiny::br(),
                  shiny::fluidRow(
                    shiny::column(12,
                                  align = "center",
                                  shiny::uiOutput(ns("download_plot_button")) #nolint
                    )
                  )
  )
}

plotsServer = function(id, cluster_choice) {
  shiny::moduleServer(id, function(input, output, session) {
    ns = session$ns
    # Plots Tab ---------------------------------------------------------------

    # all available plots
    all_files = shiny::reactive({
      all_files = tibble::as_tibble(
        list.files(
          system.file("app", "www", "data", "scanner_output",
                      cluster_choice(),
                      package = "tfpbrowser")
        )
      )
      all_files = all_files %>%
        dplyr::mutate(filetype = sub(".*\\.", "", .data$value))
      return(all_files)
    })

    # drop down for plots
    output$choose_plot = shiny::renderUI({
      all_images = all_files() %>%
        dplyr::filter(.data$filetype %in% c("png", "PNG")) %>%
        dplyr::pull(.data$value)
      images_names = stringr::str_to_title(
        stringr::str_replace_all(
          gsub("\\..*", "", all_images), "_", " "))
      names(all_images) = images_names
      shiny::selectInput(ns("plot_type"),
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
    })

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
        shinyjs::enable("download_plot_button")
      } else {
        shinyjs::disable("download_plot_button")
      }
    })

    # download plot button
    output$download_plot_button = shiny::renderUI({
      shiny::downloadButton("download_plot",
                            label = "Download")
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
