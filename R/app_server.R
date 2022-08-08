#' Shiny application server
#' @param input,output,session Internal parameters for `{shiny}`.
#' @noRd
app_server = function(input, output, session) {
  # Load mutation selectize options on server-side
  # (quicker loading on slower browsers)
  # This is because there is a lot of options
  # client-side processing is slow
  updateSelectizeInput(session,
                       "mutations",
                       choices = get_unique_mutations(
                         system.file("app", "www", "data", "wcdemo",
                                     "sarscov2-audacity-westerncape2021.csv",
                                     package = "tfpbrowser",
                                     mustWork = TRUE)),
                       server = TRUE)

  # load static html for treeview
  output$treeview = shiny::renderUI({
    filename = get_filename(input$widgetChoice)
    shiny::div(
      style = "width:100%; align:center",
      id = "treeview",
      htmltools::tags$iframe(src = filename, # nolint
                             width = "100%",
                             height = 600)
    )
  })

  # list of all files
  all_files = shiny::reactive({
    all_files = tibble::as_tibble(
      list.files(
        glue::glue("www/data/wcdemo/scanner_output/{input$cluster_id}")
      )
    )
    all_files = all_files %>%
      dplyr::mutate(filetype = sub(".*\\.", "", .data$value))
    return(all_files)
  })


  # Tables Tab --------------------------------------------------------------

  # drop down for tables
  output$choose_table = shiny::renderUI({
    all_tables = all_files() %>%
      dplyr::filter(.data$filetype %in% c("csv", "CSV")) %>%
      dplyr::pull(.data$value)
    tables_names = stringr::str_to_title(
      stringr::str_replace_all(
        gsub("\\..*", "", all_tables), "_", " "))
    names(all_tables) = tables_names
    shiny::selectInput("table_type",
                       label = "Select table type:",
                       choices = all_tables)
  })

  # get table file path
  table_file = shiny::reactive({
    shiny::req(input$cluster_id)
    table_file = glue::glue("www/data/wcdemo/scanner_output/{input$cluster_id}/{input$table_type}") # nolint
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
  output$display_table = shiny::renderUI({
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
    shiny::downloadButton("download_table",
                          label = "Download")
  })

  # download table
  output$download_table = shiny::downloadHandler(
    filename = function() {
      glue::glue("{input$cluster_id}_{input$table_type}")
    },
    content = function(file) {
      file.copy(table_file(), file)
    }
  )

  # Plots Tab ---------------------------------------------------------------

  # drop down for plots
  output$choose_plot = shiny::renderUI({
    all_images = all_files() %>%
      dplyr::filter(.data$filetype %in% c("png", "PNG")) %>%
      dplyr::pull(.data$value)
    images_names = stringr::str_to_title(
      stringr::str_replace_all(
        gsub("\\..*", "", all_images), "_", " "))
    names(all_images) = images_names
    shiny::selectInput("plot_type",
                       label = "Select plot type:",
                       choices = all_images)
  })

  # get plot file
  plot_file = shiny::reactive({
    shiny::req(input$cluster_id)
    plot_file = glue::glue("www/data/wcdemo/scanner_output/{input$cluster_id}/{input$plot_type}") # nolint
    return(plot_file)
  })

  # check if plots available
  plot_avail = shiny::reactive({
    src = substring(plot_file(), 5)
    if (length(src) != 0) {
      return(grepl(".png", tolower(src)))
    } else {
      return(FALSE)
    }
  })

  # display plot if available
  output$display_plot = shiny::renderUI({
    if (plot_avail()) {
      shiny::img(src = substring(plot_file(), 5),
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
      glue::glue("{input$cluster_id}_{input$plot_type}")
    },
    content = function(file) {
      file.copy(plot_file(), file)
    }
  )

  shiny::observeEvent(input$plot_type, {
    shinyjs::toggleState("plot_type", condition = input$plot_type != "")
  })

  shiny::observeEvent(input$table_type, {
    shinyjs::toggleState("table_type", condition = input$table_type != "")
  })

} # end server function
