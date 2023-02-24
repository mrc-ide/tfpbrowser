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

* Add the new data to relevant folders in `inst/app/www/data/`
* Re-install {tfpbrowser}
* Run `tfpbrowser::update_data()`

