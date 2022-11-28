#' function to return folder name
#' @param type Character string detailing type of widget to show
get_filename = function(type) {
  filename = switch(type,
                    "Logistic growth rate" = "tree-logistic_growth_rate.rds", # nolint
                    "Simple logistic growth rate" = "tree-simple_logistic_growth_rate.rds", # nolint
                    "Simple trait log odds" = "tree-sim_trait_logodds.rds" # nolint
  )
  filename = system.file("app", "www", "data", "treeview",
                         filename,
                         package = "tfpbrowser",
                         mustWork = TRUE)
  return(filename)
}

#' function to return list of all mutations
#' @param filename Character string for filename of csv containing mutations
get_unique_mutations = function(filename) {
  df = suppressMessages(readr::read_csv(filename))
  mutations = stringr::str_split(df$mutations, pattern = "\\|")
  mutations = mutations %>%
    unlist() %>%
    unique() %>%
    sort()
  return(mutations)
}

#' function to return list of all clusters from folder name
#' @param filename Character string for filename of folder containing all outputs
get_all_clusters = function(filename) {
  all_files = list.files(filename)
  has_no_dot = stringr::str_detect(all_files,
                                   pattern = "\\.",
                                   negate = TRUE)
  all_clusters = all_files[which(has_no_dot)]
  return(all_clusters)
}

#' Get all file names in a folder of the data relating to a single cluster
#' @param cluster_choice character relating to a folder name in inst/data
get_all_files = function(cluster_choice) {
  all_files = tibble::as_tibble(
    list.files(
      system.file("app", "www", "data", "scanner_output",
                  cluster_choice,
                  package = "tfpbrowser")
    )
  )
  all_files = all_files %>%
    dplyr::mutate(filetype = sub(".*\\.", "", .data$value))
  return(all_files)
}

#' function to tidy up table output
#' @param table_to_display Data frame or tibble containing messy outputs
reformat_table = function(table_to_display) {
  if (nrow(table_to_display) == 1) {
    output = table_to_display[, -1]$x
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
        dplyr::mutate(x = stringr::str_trim(.data$x),
                      y = stringr::str_trim(.data$y)) %>%
        `colnames<-`(.[1, ]) %>% # nolint
        dplyr::slice(-1)
    } else {
      output = tibble::tibble(x = "Nothing to display")
    }
  } else {
    output = janitor::clean_names(table_to_display,
                                  case = "title")
  }
  return(output)
}

#' function to create UI for the Well panel in the tabs
#' @param to_display UI element to be displayed in the well panel
display_panel = function(to_display) {
  shiny::wellPanel(
    shiny::fluidRow(
      shiny::column(
        12,
        align = "center",
        to_display,
        style = "height:400px;"
      )
    ),
    style = "background: white"
  )
}

#' function to filter files in each data folder based on file extension
#' @param filenames Vector of all file names in the folder
#' @param filetypes Vector of which filetypes to filter by
filter_by_filetype = function(filenames, filetypes) {
  matching_files = filenames %>%
    dplyr::filter(.data$filetype %in% .env[["filetypes"]]) %>%
    dplyr::pull(.data$value)

  file_names = stringr::str_to_title(
    stringr::str_replace_all(
      gsub("\\..*", "", matching_files), "_", " "))

  names(matching_files) = file_names
  return(matching_files)
}

#' function to create display panel inside tabset panel witin module
#' @param title Scalar string defining title of tab panel
#' @param chooser_id Scalar string of ID of the dropdown menu to display to choose files
#' @param download_button_id Scalar string of ID of the download button to download files
#' @param panel UI element to display on the right hand side of the panel
downloader_tab_panel = function(title,
                                chooser_id,
                                download_button_id,
                                panel) {
  shiny::tabPanel(
    title,
    shiny::br(),
    shiny::fluidRow(
      # drop down menu to select dataset
      shiny::column(3,
                    align = "center",
                    shiny::uiOutput(chooser_id),
                    shiny::br(),
                    shiny::uiOutput(download_button_id)
      ),
      # display data
      shiny::column(9, align = "center", panel)
    )
  )
}

#' function to get node id from data_id column of ggplot
#' @param tooltip_input Character vector of tooltip content
get_cluster_ID = function(tooltip_input) {
  # start searching the string after the "Cluster.ID" text
  # until the next new line
  match_matrix = stringr::str_match(tooltip_input, r"(Cluster.ID\s+#(\d+))")
  cluster_ids = as.numeric(match_matrix[, 2])
  return(cluster_ids)
}

#' function to get node id from data_id column of ggplot
#' @param widgetChoice From click of radio button to select widget to display
#' @param treeviewSelected Output from clicking on treeview plot
get_selected_cluster_id = function(widgetChoice,
                                   treeviewSelected) {
  filename = get_filename(widgetChoice)
  g = readRDS(filename)
  built = suppressWarnings(ggplot2::ggplot_build(g))
  n_layers = length(built$data)
  ids = built$data[n_layers][[1]]["data_id"]
  tooltips = built$data[n_layers][[1]]$tooltip

  tooltip_ids = get_cluster_ID(tooltips)
  ids$cluster_ids = tooltip_ids
  selected_cluster = as.numeric(ids[which(ids$data_id == treeviewSelected), 2])
  return(selected_cluster)
}
