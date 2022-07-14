library("dplyr")

# function to return folder name
get_filename = function(type) {
  filename = switch(type,
                    "Logistic growth rate" = "tree-logistic_growth_rate-2021-11-27.html", # nolint
                    "Simple logistic growth rate" = "tree-simple_logistic_growth_rate-2021-11-27.html", # nolint
                    "Simple trait log odds" = "tree-sim_trait_logodds-2021-11-27.html" # nolint
  )
  filename = file.path("data", "wcdemo", "treeview", filename)
  return(filename)
}

# function to return list of all mutations
get_unique_mutations = function(filename) {
  df = suppressMessages(readr::read_csv(filename))
  mutations = stringr::str_split(df$mutations, pattern = "\\|")
  mutations = mutations %>%
    unlist() %>%
    unique() %>%
    sort()
  return(mutations)
}

# function to return list of all clusters from folder name
get_all_clusters = function(filename = "www/data/wcdemo/scanner_output") {
  all_clusters = tibble::as_tibble(list.files(filename)) %>%
    dplyr::filter(stringr::str_detect(.data$value,
                                      pattern = "\\.",
                                      negate = TRUE)) %>%
    dplyr::pull(value)
  return(all_clusters)
}

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
