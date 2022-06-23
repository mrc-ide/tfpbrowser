cluster_id = 1601

library(dplyr)
all_clusters = tibble::as_tibble(
  list.files(
    glue::glue("www/data/wcdemo/scanner_output")
  )) %>%
  filter(stringr::str_detect(value, pattern = "\\.", negate = TRUE)) %>%
  pull(value)

ui = shiny::navbarPage(
  # title
  title = "tfpbrowser",

  # theme
  theme = bslib::bs_theme(version = 4,
                          bootswatch = "minty",
                          bg = "#EBEEEE",
                          fg = "#002147",
                          primary = "#003E74",
                          secondary = "#9D9D9D"),

  # Input widgets
  shiny::tabPanel(
    title = "Data",
    shiny::fluidRow(
      # left hand side - show tree (static html output from tfpscanner)
      shiny::column(6,
        # show treeview widget
        shiny::wellPanel(
          shiny::fluidRow(shiny::column(
            6,
            align = "center",
            shiny::htmlOutput("treeview"),
            style = "height:600px;"
          ))
        ),
        # search bar for mutations
        shiny::br(),
        shiny::selectizeInput(inputId = "mutation",
                              label = "Search for mutation",
                              choices = c("Mutation 1", "Mutation 2"),
                              selected = NULL,
                              multiple = FALSE)
      ),


# Right hand side - show outputs ------------------------------------------
      shiny::column(6,
        # choose cluster id
        shiny::selectInput(inputId = "cluster_id",
                           label = "Choose a cluster id:",
                           choices = all_clusters),
        # output options
        shiny::tabsetPanel(id = "plot_tabs",
                           # Tables tab
                           shiny::tabPanel("Tables",
                                           # drop down menu to select plot
                                           shiny::br(),
                                           shiny::selectInput("table_type",
                                                              "Select table type:",
                                                              c("Table 1" = "table1",
                                                                "Table 2" = "table2")),
                                           # display table
                                           shiny::wellPanel(
                                             shiny::fluidRow(shiny::column(
                                               12,
                                               reactable::reactable(
                                                 suppressMessages(
                                                   readr::read_csv(
                                                     "www/data/wcdemo/scanner_output/1603/cocirculating_lineages.csv"
                                                   )
                                                 )
                                               ),
                                               align = "center",
                                               style = "height:400px;"))
                                           ),
                                           # download button to download current table
                                           shiny::br(),
                                           fluidRow(
                                             column(12, align = "center",
                                                    downloadButton("download_table",
                                                                   label = "Download"))
                                           )
                           ),

                           # Plots tab
                           shiny::tabPanel("Plots",
                                           # drop down menu to select plot
                                           shiny::br(),
                                           shiny::selectInput("plot_type",
                                                              "Select plot type:",
                                                              c("Type 1" = "type1",
                                                                "Type 2" = "type2")),
                                           # display plot
                                           shiny::wellPanel(
                                             shiny::fluidRow(shiny::column(
                                               12,
                                               align = "center",
                                               shiny::img(src = "data/wcdemo/scanner_output/1602/frequency.png",
                                                          width = "400px"),
                                               style = "height:400px;"))
                                           ),
                                           # download button to download current plot
                                           shiny::br(),
                                           fluidRow(
                                             column(12, align = "center",
                                                    downloadButton("download_plot",
                                                                   label = "Download"))
                                           )
                           )
      )) # end right column
    ) # end fluid row
  ), # end "data" page

  # about page
  shiny::tabPanel(
    title = "About")

) #  end navbar page
