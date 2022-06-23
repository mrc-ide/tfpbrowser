server = function(input, output) {

  # load static html for treeview
  output$treeview = shiny::renderUI({
    shiny::div(
      style = "width:100%; align:center",
      id = "treeview",
      tags$iframe(src = "data/wcdemo/treeview/tree-logistic_growth_rate-2021-11-27.html",
                  width = 750,
                  height = 600)
    )
  })

  # download plot button
  output$download_plot = downloadHandler(
    filename = function() {
      paste("plot-", Sys.Date(), ".png", sep = "")
    },
    content = function(con) {
    }
  )

  # download table button
  output$download_table = downloadHandler(
    filename = function() {
      paste("table-", Sys.Date(), ".csv", sep = "")
    },
    content = function(con) {
    }
  )

}
