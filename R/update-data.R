#' function to create a treeview with all grey nodes to display
#' @param treeview RDS file containing an existing treeview plot
#' @export
empty_treeview = function(treeview = "tree-logistic_growth_rate.rds") {
  filename = system.file("app", "www", "data", "treeview",
                         treeview,
                         package = "tfpbrowser",
                         mustWork = TRUE)
  g = readRDS(filename)
  built = suppressWarnings(ggplot2::ggplot_build(g))
  n_layers = length(built$data)
  plot_data = built$data[3][[1]]

  # get tooltips here as well to add back in

  new_g = g +
    ggplot2::guides(colour = "none") +
    ggnewscale::new_scale("size") +
    ggnewscale::new_scale("shape") +
    ggplot2::geom_point(data = plot_data, # make this interactive?
                        mapping = ggplot2::aes(x = x,
                                               y = y,
                                               size = size,
                                               shape = shape),
                        colour = "grey") +
    ggplot2::scale_size_identity(guide = "none") +
    ggplot2::scale_shape_identity(guide = "none")
  new_filename = file.path("inst", "app", "www", "data", "treeview",
                           "tree-mutations.rds")
  # need to add another layer / in cluster id
  # (if treeview mutation, use second last element to get cluster id)
  saveRDS(new_g, file = new_filename)
}
