#' function to create a treeview with all grey nodes to display
#' @param treeview RDS file containing an existing treeview plot
#' @param types Character vector of new variables to colour by
#' @param data_dir   The directory where data should be read from / written to.
#' @export
empty_treeview <- function(treeview = "tree-logistic_growth_rate.rds",
                           types = c("mutations", "sequences"),
                           data_dir) {
  filename <- file.path(data_dir, "treeview", treeview)
  stopifnot(file.exists(filename))
  g <- readRDS(filename)

  make_treeview_type <- function(type) { # nolint
    new_g <- g +
      ggplot2::scale_colour_gradient(low = "grey", high = "grey") +
      ggplot2::guides(
        colour = "none",
        fill = "none",
        shape = "none"
      ) +
      ggplot2::labs(title = glue::glue("Colour: {type}"))
    new_filename <- file.path(data_dir, "treeview", glue::glue("tree-{type}.rds"))
    saveRDS(new_g, file = new_filename)
  }

  purrr::walk(.x = types, .f = ~ make_treeview_type(.x))
}

#' function to create lookup for a single treeview
#' @param widgetChoice rds filename for selected treeview output
#' from radio button
#' @param   data_dir   The directory where the data should be read from / written to.
create_node_lookup <- function(widgetChoice, data_dir) {
  filename <- get_filename(widgetChoice, data_dir)
  g <- readRDS(filename)
  built <- suppressWarnings(ggplot2::ggplot_build(g))
  if (widgetChoice %in% c(
    "sina-logistic_growth_rate.rds",
    "sina-simple_logistic_growth_rate.rds"
  )) {
    ids <- built$data[1][[1]]["data_id"]
    tooltips <- built$data[1][[1]]$tooltip
    tooltip_ids <- get_cluster_ID(tooltips)
  } else {
    n_layers <- length(built$data)
    ids <- built$data[n_layers][[1]]["data_id"]
    tooltips <- built$data[n_layers][[1]]$tooltip
    tooltip_ids <- suppressWarnings(readr::parse_number(tooltips))
  }
  ids$cluster_ids <- tooltip_ids
  filename <- stringr::str_replace(widgetChoice, ".rds", ".csv")
  filepath <- file.path(data_dir, "treeview", "node_lookup", filename)
  readr::write_csv(ids, file = filepath)
}

#' function to create lookups for nodes for all treeviews
#'
#' @param   data_dir   The directory where the data should be read from / written to.
#' @export
create_all_node_lookups <- function(data_dir) {
  # get list of all widgets
  all_widgets <- available_treeview(data_dir)
  purrr::walk(.x = all_widgets, .f = ~ create_node_lookup(.x, data_dir = data_dir))
}

#' function to get lookup table of clusterID and sequence
#' @param selected_folder Folder name relating to a single clusterID
#' @param   data_dir   The data directory for the application. Must have a `scanner_output`
#' subdirectory.
process_seq_table <- function(selected_folder, data_dir) {
  sequences <- file.path(data_dir, "scanner_output", selected_folder, "sequences.csv")
  sequences <- suppressMessages(readr::read_csv(sequences))
  if (nrow(sequences) > 0) {
    seq_names <- unique(sequences$sequence_name)
    output <- tibble::tibble(
      cluster_id = rep(selected_folder, length(seq_names)),
      sequence = seq_names
    )
    return(output)
  }
}

#' function to save a CSV file of all sequences for all clusterIDs
#'
#' @param   data_dir   The data directory for the application. Must have a `scanner_output`
#' subdirectory.
#'
#' @export
get_sequences_lookup <- function(data_dir) {
  all_files <- list.files(
    file.path(data_dir, "scanner_output")
  )
  output <- purrr::map_dfr(.x = all_files, .f = ~ process_seq_table(.x, data_dir))
  filepath <- file.path(data_dir, "sequences", "all_sequences.csv")
  readr::write_csv(output, file = filepath)
}

#' function to be run anytime the data is updated
#' wrapper around other required functions
#' ideally these will be added to {tfpscanner} in the longer term
#' and the outputs transferred instead
#' @param treeview RDS file containing an existing treeview plot
#' @export
update_data <- function(treeview = "tree-logistic_growth_rate.rds") {
  data_dir <- system.file("app", "www", "data", package = "tfpbrowser")

  # create blank treeview
  empty_treeview(treeview = treeview, data_dir = data_dir)

  # save csv files with node lookups
  create_all_node_lookups(data_dir)

  # get CSV of sequences vs clusterIDs
  get_sequences_lookup(data_dir)
}
