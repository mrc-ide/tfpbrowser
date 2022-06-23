library(dplyr)
cluster_id = 1603
all_files = tibble::as_tibble(
  list.files(
    glue::glue("www/data/wcdemo/scanner_output/{cluster_id}")
    )
)
all_files = all_files %>%
  mutate(filetype = sub(".*\\.", "", value))

# list all cluster IDs
all_clusters = tibble::as_tibble(
  list.files(
    glue::glue("www/data/wcdemo/scanner_output")
  )) %>%
  filter(stringr::str_detect(value, pattern = "\\.", negate = TRUE)) %>%
  pull(value)
all_clusters

# list images (end with .png)
all_images = all_files %>%
  filter(filetype %in% c("png", "PNG")) %>%
  pull(value)
all_images

# list data files (end with .csv)
all_tables = all_files %>%
  filter(filetype %in% c("csv", "CSV")) %>%
  pull(value)
all_tables

# read table
all_tables[1]
table_file = glue::glue("www/data/wcdemo/scanner_output/{cluster_id}/{all_tables[1]}")
table_to_display = readr::read_csv(table_file)
reactable::reactable(table_to_display)
