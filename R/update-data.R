#' function to create a treeview with all grey nodes to display
#' @param treeview RDS file containing an existing treeview plot
#' @param types Character vector of new variables to colour by
#' @export
empty_treeview = function(treeview = "tree-logistic_growth_rate.rds",
                          types = c("mutations", "sequences")) {
  filename = system.file("app", "www", "data", "treeview",
                         treeview,
                         package = "tfpbrowser",
                         mustWork = TRUE)
  g = readRDS(filename)
  make_treeview_type = function(type) { # nolint
    new_g = g +
      ggplot2::scale_colour_gradient(low = "grey", high = "grey") +
      ggplot2::guides(colour = "none",
                      fill = "none",
                      shape = "none") +
      ggplot2::labs(title = glue::glue("Colour: {type}"))
    new_filename = file.path("inst", "app", "www", "data", "treeview",
                             glue::glue("tree-{type}.rds"))
    saveRDS(new_g, file = new_filename)
  }
  purrr::walk(.x = types, .f = ~make_treeview_type(.x))
}

#' function to create lookup for a single treeview
#' @param widgetChoice rds filename for selected treeview output
#' from radio button
create_node_lookup = function(widgetChoice) {
  filename = get_filename(widgetChoice)
  g = readRDS(filename)
  built = suppressWarnings(ggplot2::ggplot_build(g))
  if (widgetChoice %in% c("sina-logistic_growth_rate.rds",
                          "sina-simple_logistic_growth_rate.rds")) {
    ids = built$data[1][[1]]["data_id"]
    tooltips = built$data[1][[1]]$tooltip
    tooltip_ids = get_cluster_ID(tooltips)
  } else {
    n_layers = length(built$data)
    ids = built$data[n_layers][[1]]["data_id"]
    tooltips = built$data[n_layers][[1]]$tooltip
    tooltip_ids = suppressWarnings(readr::parse_number(tooltips))
  }
  ids$cluster_ids = tooltip_ids
  filename = stringr::str_replace(widgetChoice, ".rds", ".csv")
  filepath = file.path("inst", "app", "www", "data", "treeview", "node_lookup",
                       filename)
  readr::write_csv(ids, file = filepath)
}

#' function to create lookups for nodes for all treeviews
#' @export
create_all_node_lookups = function() {
  # get list of all widgets
  all_widgets = available_treeview()
  purrr::walk(.x = all_widgets, .f = ~create_node_lookup(.x))
}

#' function to get lookup table of clusterID and sequence
#' @param selected_folder Folder name relating to a single clusterID
process_seq_table = function(selected_folder) {
  sequences = system.file("app", "www", "data", "scanner_output",
                          selected_folder, "sequences.csv",
                          package = "tfpbrowser")
  sequences = suppressMessages(readr::read_csv(sequences))
  if (nrow(sequences) > 0) {
    seq_names = unique(sequences$sequence_name)
    output = tibble::tibble(cluster_id = rep(selected_folder, length(seq_names)),
                            sequence = seq_names)
    return(output)
  }
}

#' function to save a CSV file of all sequences for all clusterIDs
#' @export
get_sequences_lookup = function() {
  all_files = list.files(
    system.file("app", "www", "data", "scanner_output",
                package = "tfpbrowser")
  )
  output = purrr::map_dfr(.x = all_files, .f = ~process_seq_table(.x))
  filepath = file.path("inst", "app", "www", "data", "sequences",
                       "all_sequences.csv")
  readr::write_csv(output, file = filepath)
}

#' function to be run anytime the data is updated
#' wrapper around other required functions
#' ideally these will be added to {tfpscanner} in the longer term
#' and the outputs transferred instead
#' @param treeview RDS file containing an existing treeview plot
#' @export
update_data = function(treeview = "tree-logistic_growth_rate.rds") {
  # create blank treeview
  empty_treeview(treeview = treeview)
  # save csv files with node lookups
  create_all_node_lookups()
  # get CSV of sequences vs clusterIDs
  get_sequences_lookup()
}
