server = function(input, output) {

  # load static html for treeview
  output$treeview = shiny::renderUI({
    shiny::div(
      style = "width:100%; align:center",
      id = "treeview",
      tags$iframe(src = "data/wcdemo/treeview/tree-logistic_growth_rate-2021-11-27.html", # nolint
                  width = 750,
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
      mutate(filetype = sub(".*\\.", "", .data$value))
    return(all_files)
  })


# Tables Tab --------------------------------------------------------------

  # drop down for tables
  output$choose_table = shiny::renderUI({
    all_tables = all_files() %>%
      filter(.data$filetype %in% c("csv", "CSV")) %>%
      pull(.data$value)
    shiny::selectInput("table_type",
                       label = "Select table type:",
                       choices = all_tables)
  })

  # display table
  table_file = shiny::reactive({
    table_file = glue::glue("www/data/wcdemo/scanner_output/{input$cluster_id}/{input$table_type}") # nolint
    return(table_file)
  })

  output$display_table = shiny::renderUI({
    table_to_display = suppressMessages(readr::read_csv(table_file()))
    table_to_display = reformat_table(table_to_display)
    reactable::reactable(table_to_display,
                         striped = TRUE,
                         defaultPageSize = 8,
                         wrap = FALSE,
                         height = 400)
  })

  # download table button
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
      filter(.data$filetype %in% c("png", "PNG")) %>%
      pull(.data$value)
    shiny::selectInput("plot_type",
                       label = "Select plot type:",
                       choices = all_images)
  })

  # display plot
  plot_file = shiny::reactive({
    plot_file = glue::glue("www/data/wcdemo/scanner_output/{input$cluster_id}/{input$plot_type}") # nolint
    return(plot_file)
  })

  output$display_plot = shiny::renderUI({
    src = substring(plot_file(), 5)
    shiny::img(src = src,
               width = "400px")
  })

  # download plot button
  output$download_plot = shiny::downloadHandler(
    filename = function() {
      glue::glue("{input$cluster_id}_{input$plot_type}")
    },
    content = function(file) {
      file.copy(plot_file(), file)
    }
  )

}
