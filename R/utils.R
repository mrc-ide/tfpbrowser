#' function to return folder name
#' @param type Character string detailing type of widget to show
get_filename = function(type) {
  filename = switch(type,
                    "Logistic growth rate" = "tree-logistic_growth_rate-2021-11-27.rds", # nolint
                    "Simple logistic growth rate" = "tree-simple_logistic_growth_rate-2021-11-27.rds", # nolint
                    "Simple trait log odds" = "tree-sim_trait_logodds-2021-11-27.rds" # nolint
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
