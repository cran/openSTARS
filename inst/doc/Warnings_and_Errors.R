## ----echo=FALSE---------------------------------------------------------------
knitr::opts_chunk$set(
  eval = TRUE,
  warning = FALSE,
  message = FALSE,
  collapse = TRUE,
  comment = "#>"
)

## ----github_install, eval = FALSE---------------------------------------------
#    devtools::install_github("MiKatt/openSTARS", ref = "dev")

## ----windows settings, eval = FALSE-------------------------------------------
#    # GRASS in QGIS installation
#    #set Path; must be done BEFORE initGRASS
#    Sys.setenv(PATH=paste0("C:/Program Files/QGIS 2.18/bin",";", Sys.getenv("PATH")))
#    initGRASS(gisBase = "c:/Program Files/QGIS 2.18/apps/grass/grass-7.0.5",
#              home = tempdir(),
#              gisDbase = "C:/GRASSDB"
#             )
#    # set System Variables; must be done AFTER initGRASS
#    Sys.setenv(GRASS_PYTHON="C:/Program Files/QGIS 2.18/bin/python.exe")
#    Sys.setenv(PYTHONHOME="C:/Program Files/QGIS 2.18/apps/Python27")
#    Sys.setenv(GDAL_DATA="C:/Program Files/QGIS 2.18/share/gdal")

