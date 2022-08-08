# code to obtain list of all clusters
library("dplyr")
all_clusters = tfpbrowser::get_all_clusters()
usethis::use_data(all_clusters, overwrite = TRUE)
