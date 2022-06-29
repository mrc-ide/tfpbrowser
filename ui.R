library(dplyr)

# get list of clusters from folder
all_clusters = tibble::as_tibble(
  list.files(
    glue::glue("www/data/wcdemo/scanner_output")
  )) %>%
  filter(stringr::str_detect(value, pattern = "\\.", negate = TRUE)) %>%
  pull(value)

# define function to tidy up table output
reformat_table = function(table_to_display) {
  if (nrow(table_to_display) == 1) {
    output = table_to_display[, -1] %>%
      pull(.data$x)
    if (!is.na(output)) {
      output = output %>%
        stringr::str_split(pattern = "\n") %>%
        unlist() %>%
        stringr::str_trim() %>%
        tibble::as_tibble() %>%
        tidyr::separate(.data$value,
                        into = c("x", "y"),
                        sep = "  ",
                        extra = "merge") %>%
        mutate(x = stringr::str_trim(.data$x),
               y = stringr::str_trim(.data$y)) %>%
        `colnames<-`(.[1, ]) %>% # nolint
        slice(-1)
    } else {
      output = tibble::tibble(x = "Nothing to display")
    }
  } else {
    output = janitor::clean_names(table_to_display,
                                  case = "title")
  }
  return(output)
}

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
            #shiny::htmlOutput("treeview"),
            style = "height:600px;"
          ))
        ),
        # search bar for mutations (example only)
        shiny::br(),
        shiny::selectizeInput(inputId = "mutation",
                              label = "Search for mutation",
                              choices = c("Mutation 1", "Mutation 2"),
                              selected = NULL,
                              multiple = FALSE)
      ),

      # Right hand side - outputs ------------------------------------------
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
                           shiny::uiOutput("choose_table"),
                           # display table
                           shiny::wellPanel(
                             shiny::fluidRow(shiny::column(
                               12,
                               shiny::uiOutput("display_table"),
                               align = "center",
                               style = "height:400px;"))
                           ),
                           # download button to download current table
                           shiny::br(),
                           shiny::fluidRow(
                             shiny::column(12, align = "center",
                                    shiny::downloadButton("download_table",
                                                          label = "Download"))
                           )
           ),
           # Plots tab
           shiny::tabPanel("Plots",
                           # drop down menu to select plot
                           shiny::br(),
                           shiny::uiOutput("choose_plot"),
                           # display plot
                           shiny::wellPanel(
                             shiny::fluidRow(shiny::column(
                               12,
                               align = "center",
                               shiny::uiOutput("display_plot"),
                               style = "height:400px;"))
                           ),
                           # download button to download current plot
                           shiny::br(),
                           shiny::fluidRow(
                             shiny::column(12, align = "center",
                                    shiny::downloadButton("download_plot",
                                                          label = "Download"))
                           )
           )
        )
      ) # end right column
    ) # end fluid row
  ), # end "data" page

  # about page
  shiny::tabPanel(
    title = "About")

) #  end navbar page
