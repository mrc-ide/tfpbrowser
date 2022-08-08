# code to obtain list of all clusters
library("dplyr")
fname = system.file("app", "www", "data", "wcdemo",
                    "scanner_output",
                    package = "tfpbrowser",
                    mustWork = TRUE)
all_clusters = tfpbrowser::get_all_clusters(filename = fname)
usethis::use_data(all_clusters, overwrite = TRUE)
