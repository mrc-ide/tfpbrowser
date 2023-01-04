#' function to create a treeview with all grey nodes to display
#' @param treeview RDS file containing an existing treeview plot
#' @export
empty_treeview = function(treeview = "tree-logistic_growth_rate.rds") {
  filename = system.file("app", "www", "data", "treeview",
                         treeview,
                         package = "tfpbrowser",
                         mustWork = TRUE)
  g = readRDS(filename)
  new_g = g +
    ggplot2::guides(colour = "none",
                    fill = "none",
                    shape = "none") +
    ggplot2::labs(title = "Colour: mutation")
  new_filename = file.path("inst", "app", "www", "data", "treeview",
                           "tree-mutations.rds")
  saveRDS(new_g, file = new_filename)
}
