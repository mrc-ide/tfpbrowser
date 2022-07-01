server = function(input, output) {

  # load static html for treeview
  output$treeview = shiny::renderUI({
    shiny::div(
      style = "width:100%; align:center",
      id = "treeview",
      tags$iframe(src = "data/wcdemo/treeview/tree-logistic_growth_rate-2021-11-27.html", # nolint
                  width="100%",
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

  # define function to tidy up table output - go in R/ folder
  reformat_table = function(table_to_display) {
    if (nrow(table_to_display) == 1) {
      output = table_to_display[, -1] %>%
        pull(.data$x)
      if (!is.na(output)) {
        output = output %>%
          stringr::str_split(pattern = "\n") %>%
          unlist() %>%
          stringr::str_trim() %>%
          tibble::as_tibble() %>%
          tidyr::separate(.data$value,
                          into = c("x", "y"),
                          sep = "  ",
                          extra = "merge") %>%
          mutate(x = stringr::str_trim(.data$x),
                 y = stringr::str_trim(.data$y)) %>%
          `colnames<-`(.[1, ]) %>% # nolint
          slice(-1)
      } else {
        output = tibble::tibble(x = "Nothing to display")
      }
    } else {
      output = janitor::clean_names(table_to_display,
                                    case = "title")
    }
    return(output)
  }

  output$display_table = shiny::renderUI({
    shiny::req(table_file())
    table_to_display = suppressMessages(readr::read_csv(table_file()))
    table_to_display_nice = reformat_table(table_to_display)
    reactable::reactable(table_to_display_nice,
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
