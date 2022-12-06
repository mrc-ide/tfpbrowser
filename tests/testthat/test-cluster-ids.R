test_that("cluster id is parsed from tooltip correctly", {
  tooltip = c("Statistics:\n                                             \n------------------  -------------------------\nCluster.ID          #1605                    \nCluster.size        25                       \nDate.range          2021-01-01 -> 2021-06-21 \nExample.sequence    EPI_ISL_4817051", # nolint
              "Statistics:\n                                             \n------------------  -------------------------\nCluster.ID          #1920                    \nCluster.size        65                       \nDate.range          2021-06-02 -> 2021-10-22 \nExample.sequence    EPI_ISL_6436444") # nolint
  cluster_ids = get_cluster_ID(tooltip)
  expect_equal(cluster_ids, c(1605, 1920))
})
