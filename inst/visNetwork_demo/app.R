library(shiny)
library(visNetwork)

# Define UI for app that draws a histogram ----
ui <- shiny::fluidPage(

  shinyjs::useShinyjs(),

  # App title ----
  titlePanel("Treeview: visNetwork"),

  # Sidebar layout with input and output definitions ----
  sidebarLayout(

    # Sidebar panel for inputs ----
    sidebarPanel(

      # Inputs

      shiny::checkboxInput("col_var1", "Colour by value:", FALSE),

      textOutput("select_text")

    ),

    # Main panel for displaying outputs ----
    mainPanel(

      # Output: Histogram ----
      visNetwork::visNetworkOutput("visTree")

    )
  )
)

# Define server logic required to draw a histogram ----
server <- function(input, output) {

  # set up info
  nodes = data.frame(id = 1:7,
                     var1 = c(1, 2, 3, 3, 3, 4, 4))
  edges = data.frame(
    from = c(1,2,2,2,3,3),
    to = c(2,3,4,5,6,7)
  )

  # treeview new
  output$visTree <- renderVisNetwork({
    if (input$col_var1 == TRUE) {
      col_choice  = tibble::tibble(var1 = unique(nodes$var1),
                           color = rcartocolor::carto_pal(n = length(unique(nodes$var1)), name = "Teal"))
      nodes = dplyr::left_join(nodes, col_choice, by = "var1")
    }
    visNetwork(nodes, edges, width = "100%") %>%
      visHierarchicalLayout(direction = "LR") %>%
      visNetwork::visEvents(select = "function(data) {
                Shiny.onInputChange('node_id', data.nodes);
                ;}")
  })

  output$select_text <- renderText({
    paste("You have selected:", input$node_id)
  })

  output$choose_id <- renderUI({
    selectInput("node_id", "Select node:",
                choices = nodes$id)
  })

}

shinyApp(ui = ui, server = server)
