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

## Configuring the deployed app

Data presented by the app can be obtained from an arbitrary directory on the server.
To configure the data-directory, use the environment variable `APP_DATA_DIR`.
For example, if the app is to present data from the directory `/home/me/tfpdata/`, then the app can
be configured from the command line:

```bash
APP_DATA_DIR=/home/me/tfpdata/
# start the app
```

... or from inside R:

```r
Sys.setenv("APP_DATA_DIR" = "/home/me/tfpdata/")
pkgload::load_all()
run_app()
```

An alternative way to specify this data directory is to add the line
`APP_DATA_DIR="/home/me/tfpdata/"` to a `.Renviron` file in the project root.

