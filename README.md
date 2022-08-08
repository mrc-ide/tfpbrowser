# {tfpbrowser}

An R package to build a Shiny application to explore {tfpscanner} outputs. The outputs from {tfpscanner} should be stored in the `inst/www/data/` folder.

## Installation

```
remotes::install_github("mrc-ide/tfpbrowser")
```

## Running the Shiny application

```
tfpbrowser::run_app()
```

## Updating with new data

* Add the new data to `inst/www/data/`
* Run the code in `data-raw/all_clusters.R` to generate a new .rda file
* Re-install {tfpbrowser}

