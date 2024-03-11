#' Convert a ggplot object into an interactive {ggiraph} object
#'
#' @param   ggobj   The ggplot2/ggtree object.
#' @param   widget_choice   Scalar character. Describes the type of plot that is contained in
#'   `ggobj`. Typically a file basename that includes the file extension, of the form "tree-XXX.rds"
#'   (for `{ggtree}` objects) or "sina-XXX.rds" (for `{ggplot2}` scatter plots).
#' @param   width_svg,height_svg   Scalar numeric. The width/height of the output plot.
#' @param   suppress_warnings   Scalar logical. Should warnings from `ggiraph::girafe()` be printed
#'   to the console?
create_girafe = function(
    ggobj,
    widget_choice,
    width_svg,
    height_svg,
    suppress_warnings = FALSE) {
  # define tooltip
  tooltip_css = paste0(
    "background-color:black;",
    "color:grey;",
    "padding:14px;",
    "border-radius:8px;",
    "font-family:\"Courier New\",monospace;"
  )

  # set options
  if (widget_choice == "tree-mutations.rds") {
    girafe_options = list(
      ggiraph::opts_selection(css = "fill:red;"),
      ggiraph::opts_selection_inv(css = "fill:grey;"),
      ggiraph::opts_sizing(rescale = FALSE),
      ggiraph::opts_zoom(max = 5),
      ggiraph::opts_tooltip(
        css = tooltip_css,
        use_fill = FALSE
      )
    )
  } else {
    girafe_options = list(
      ggiraph::opts_selection(type = "single"),
      ggiraph::opts_sizing(rescale = FALSE),
      ggiraph::opts_zoom(max = 5),
      ggiraph::opts_tooltip(
        css = tooltip_css,
        use_fill = FALSE
      )
    )
  }

  create_widget = function() {
    ggiraph::girafe(
      ggobj = ggobj,
      width_svg = width_svg,
      height_svg = height_svg,
      options = girafe_options
    )
  }

  # make tree
  if (suppress_warnings) {
    suppressWarnings(create_widget())
  } else {
    create_widget()
  }
}
