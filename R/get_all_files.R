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
