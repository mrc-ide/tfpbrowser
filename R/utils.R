#' function to return treeview options
#'
#' @param   data_dir   The directory containing the data for the application.

available_treeview = function(data_dir) {
  all_trees = list.files(
    file.path(data_dir, "treeview"),
    pattern = "\\.rds$"
  )
  all_trees = factor(
    all_trees,
    c(
      stringr::str_subset(all_trees, "tree"),
      stringr::str_subset(all_trees, "sina")
    )
  )
  all_trees = as.character(sort(all_trees))
  names(all_trees) = all_trees %>%
    stringr::str_replace_all("_|-|\\.rds", " ") %>%
    stringr::str_trim() %>%
    stringr::str_to_title()
  return(all_trees)
}

#' function to return mutation options
#'
#' @param   data_dir   The directory containing the data for the application. Must contain a
#' `mutations` subdirectory

available_mutations = function(data_dir) {
  filepath = file.path(data_dir, "mutations", "defining_mutations.csv")
  all_muts = readr::read_csv(filepath, col_types = readr::cols())
  all_muts = all_muts %>%
    dplyr::pull(.data$mutation) %>%
    unique()
  return(all_muts)
}

#' Which nodes have a given mutation
#' @param chosen_mutation String for the user selected mutation
#' @param data_dir The data directory for the app. Must contain a "mutations" subdirectory.
selected_mut_nodes = function(chosen_mutation, data_dir) {
  filepath = file.path(data_dir, "mutations", "all_mutations.csv")
  all_muts = readr::read_csv(filepath, col_types = readr::cols())
  selected_nodes = all_muts %>%
    dplyr::filter(.data$mutation == chosen_mutation) %>%
    dplyr::pull(.data$cluster_id)
  return(selected_nodes)
}

#' Obtain the file-path for a tree-view
#' @param type Choice of tree-view widget to show
#' @param data_dir The data directory for the app. Must contain a "treeview" subdirectory.
get_filename = function(type, data_dir) {
  stopifnot(dir.exists(data_dir))

  filename = file.path(data_dir, "treeview", type)
  stopifnot(file.exists(filename))

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
    negate = TRUE
  )
  all_clusters = all_files[which(has_no_dot)]
  return(all_clusters)
}

#' Get all file names in a folder of the data relating to a single cluster
#' @param cluster_choice character relating to a folder name in inst/data
#' @param   data_dir   The data directory for the app. Must contain a `scanner_output` subdirectory
get_all_files = function(cluster_choice, data_dir) {
  cluster_dir = file.path(data_dir, "scanner_output", cluster_choice)
  all_files = tibble::as_tibble(
    list.files(cluster_dir)
  )
  all_files = all_files %>%
    dplyr::mutate(filetype = sub(".*\\.", "", .data$value))
  return(all_files)
}

#' function to tidy up table output
#' @param table_to_display Data frame or tibble containing messy outputs
reformat_table = function(table_to_display) {
  if (all(table_to_display[[1]] == seq_len(nrow(table_to_display)))) {
    table_to_display = table_to_display[, -1]
  }
  output = janitor::clean_names(table_to_display, case = "title")
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
      gsub("\\..*", "", matching_files), "_", " "
    )
  )

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
        shiny::selectInput(chooser_id,
          label = "Select type:",
          choices = NULL,
          selected = NULL
        ),
        shiny::br(),
        shiny::downloadButton(download_button_id,
          label = "Download"
        )
      ),
      # display data
      shiny::column(9, align = "center", panel)
    )
  )
}

#' function to get node id from data_id column of ggplot
#' TO BE REMOVED AFTER TOOLTIPS TFPSCANNER PR IS MERGED
#' @param tooltip_input Character vector of tooltip content
#' @export
get_cluster_ID = function(tooltip_input) {
  # start searching the string after the "Cluster.ID" text
  # until the next new line
  match_matrix = stringr::str_match(tooltip_input, pattern = r"(Cluster.ID\s+#(\d+))")
  cluster_ids = as.numeric(match_matrix[, 2])
  return(cluster_ids)
}

#' function to get node id from data_id column of ggplot
#' @param widgetChoice From click of radio button to select widget to display
#' @param treeviewSelected Output from clicking on treeview plot
#' @param   data_dir   The data directory for the app. Must contain a `treeview/node_lookup`
#' subdirectory.
get_selected_cluster_id = function(widgetChoice,
                                   treeviewSelected,
                                   data_dir) {
  filename = stringr::str_replace(widgetChoice, ".rds", ".csv")
  filepath = file.path(data_dir, "treeview", "node_lookup", filename)
  # load look up
  ids = readr::read_csv(filepath,
    col_types = list(readr::col_double(), readr::col_double())
  )
  selected_cluster = as.numeric(ids[which(ids$data_id == treeviewSelected), 2])
  return(selected_cluster)
}

#' function to return sequence options
#' @param   data_dir   The data directory for the app. Must contain a "sequences" subdirectory.
available_sequences = function(data_dir) {
  filepath = file.path(data_dir, "sequences", "all_sequences.csv")
  all_seq = readr::read_csv(filepath, col_types = readr::cols())
  all_seq = unique(all_seq$sequence)
  return(all_seq)
}

#' Which nodes have a given sequence
#' @param chosen_sequence String for the user selected sequence
#' @param data_dir The data directory for the app. Must contain a "sequences" subdirectory.
selected_seq_nodes = function(chosen_sequence, data_dir) {
  filepath = file.path(data_dir, "sequences", "all_sequences.csv")
  all_seq = readr::read_csv(filepath, col_types = readr::cols())
  selected_nodes = all_seq %>%
    dplyr::filter(.data$sequence == chosen_sequence) %>%
    dplyr::pull(.data$cluster_id)
  return(selected_nodes)
}
