<!-- badges: start -->
  [![R-CMD-check](https://github.com/jumpingrivers/tfpbrowser/workflows/R-CMD-check/badge.svg)](https://github.com/jumpingrivers/tfpbrowser/actions)
<!-- badges: end -->

# {tfpbrowser}

An R package to build a Shiny application to explore {tfpscanner} outputs. The outputs from {tfpscanner} should be stored in the `inst/app/www/data/` folder.

## Installation

```
remotes::install_github("mrc-ide/tfpbrowser")
```

## Running the Shiny application

```
tfpbrowser::run_app()
```

## Updating with new data

* Add the new data to `inst/app/www/data/`
* Run the code in `data-raw/all_clusters.R` to generate a new .rda file
* Re-install {tfpbrowser}

