library("dplyr")

get_filename = function(type) {
  filename = switch(type,
                    "Logistic growth rate" = "tree-logistic_growth_rate-2021-11-27.html",
                    "Simple logistic growth rate" = "tree-simple_logistic_growth_rate-2021-11-27.html",
                    "Simple trait log odds" = "tree-sim_trait_logodds-2021-11-27.html"
  )
  filename = file.path("data", "wcdemo", "treeview", filename)
  return(filename)
}

get_unique_mutations = function(filename) {
  df = readr::read_csv(filename)
  mutations = stringr::str_split(df$mutations, pattern = "\\|")
  mutations = mutations %>%
    unlist() %>%
    unique() %>%
    sort()
  return(mutations)
}
