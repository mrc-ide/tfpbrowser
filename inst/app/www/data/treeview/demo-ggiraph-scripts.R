library(ape)
library(ggtree)

# function to create ggplot2 tree object
create_treeview = function(n_samples, n_grp) {
  # simulate date
  tree = ape::rtree(n = n_samples)
  id = tree$tip.label
  set.seed(42)
  grp = sample(LETTERS[1:n_grp], size = n_samples, replace = T)
  dat = tibble::tibble(id = id, grp = grp)
  # treeview
  p = ggtree(tree)
  metat = p$data %>%
    dplyr::inner_join(dat, c('label' = 'id'))
  p = p +
    ggiraph::geom_point_interactive(data = metat,
               aes(x = x,
                   y = y,
                   colour = grp,
                   data_id = node)) +
    ggplot2::theme(legend.position = "none")
  return(p)
}

# crate three random trees with same filenames as existing html files
set.seed(1234)
g = suppressWarnings(create_treeview(1000, 200))
g
saveRDS(g, file = "inst/app/www/data/treeview/tree-logistic_growth_rate-2021-11-27.rds")

g = suppressWarnings(create_treeview(1000, 180))
g
saveRDS(g, file = "inst/app/www/data/treeview/tree-simple_logistic_growth_rate-2021-11-27.rds")

g = suppressWarnings(create_treeview(1000, 250))
g
saveRDS(g, file = "inst/app/www/data/treeview/tree-sim_trait_logodds-2021-11-27.rds")


