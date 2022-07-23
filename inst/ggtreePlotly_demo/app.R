library(shiny)
library(ape)
library(ggtree)
library(plotly)

# Define UI for app that draws a histogram ----
ui <- shiny::fluidPage(

  shinyjs::useShinyjs(),

  # App title ----
  titlePanel("Treeview: ggtree"),

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
      plotly::plotlyOutput("ggTree")

    )
  )
)

# Define server logic required to draw a histogram ----
server <- function(input, output) {

  # set up info
  n_samples <- 7
  n_grp <- 5
  tree <- ape::rtree(n = n_samples)
  id <- tree$tip.label
  set.seed(42)
  grp <- sample(LETTERS[1:n_grp], size = n_samples, replace = T)
  dat <- tibble::tibble(id = id, grp = grp)

  # treeview new
  ggtree_input = shiny::reactive({
    p <- ggtree(tree)
  })

  ggtree_input_data = shiny::reactive({
    p = ggtree_input()
    metat <- p$data %>%
      dplyr::inner_join(dat, c('label' = 'id'))
    return(metat)
  })

  output$ggTree <- plotly::renderPlotly({
    p = ggtree_input()
    metat = ggtree_input_data()
    if (input$col_var1){
      p <- p +
        geom_point(data = metat,
                   aes(x = x,
                       y = y,
                       colour = grp,
                       key = node)) +
        ggplot2::theme(legend.position = "bottom")
    } else {
      p <- p +
        geom_point(data = metat,
                   aes(x = x,
                       y = y,
                       key = node),
                   colour = "black")
    }
    return(plotly::ggplotly(p))
  })

  # click on plot

  click_output = shiny::reactive({
    click_data <- event_data("plotly_click")
    if (is.null(click_data)) {
      return("Click a point")
    }
    output = click_data$key
    return(output)
  })

  output$select_text <- renderText({
    paste("You have selected node:", click_output())
  })

}

shinyApp(ui = ui, server = server)
