#' Setup 'GRASS' environment.
#'
#' This function sets the 'GRASS' mapset to PERMANENT and sets its projection and extension.
#'
#' @param dem character; path to DEM.  
#' @param gisBase character; the directory path to GRASS binaries and libraries, containing 
#'   bin and lib subdirectories among others (see details).
#' @param epsg integer (deprecated); not used any more. Only included for compatibility with previous version.
#' @param sites (deprecated); not used any more. Only included for compatibility with previous version.
#' @param ... Optional arguments to be passed to \code{\link[rgrass7]{initGRASS}} (see details).
#'
#' @return Nothing. A GRASS session is initiated and the 'GRASS' mapset is set to PERMANENT. 
#'  The geographical projection, geographical extension, number of columns and number of 
#'  rows for the data and the resolution are defined by the dem. They are stored the DEFAULT_WIND file.
#'
#' @details A GRASS session is initiated using \code{\link[rgrass7]{initGRASS}}. The path to 
#'   the GRASS program must be provided as \code{gisBase}. For Linux, this might look like 
#'   "/usr/lib/grass78/" and for Windows "c:/Program Files/GRASS GIS 7.8".
#'   Optional arguments are for example 
#'   * \code{gisDbase}: the GRASS GISBASE directory for this session; defaults to tempdir()
#'   * \code{location}: name of the location for this session; defaults to tempfile()
#'   * \code{override}: TRUE for allowing to override an existing location.
#'
#' @note It is no longer required to initiate a GRASS session before using \code{\link[rgrass7]{initGRASS}}!
#' 
#' @author Mira Kattwinkel, \email{mira.kattwinkel@@gmx.net}
#' @export
#'
#' @examples
#' \donttest{
#' # path to GRASS
#' if(.Platform$OS.type == "windows"){
#'   gisbase = "c:/Program Files/GRASS GIS 7.6"
#'   } else {
#'   gisbase = "/usr/lib/grass78/"
#'   }
#' # path to the dem   
#' dem_path <- system.file("extdata", "nc", "elev_ned_30m.tif", package = "openSTARS")
#' setup_grass_environment(dem = dem_path, 
#'                         gisBase = gisbase, 
#'                         location = "nc_example_location",
#'                         override = TRUE)
#' gmeta()
#' }

setup_grass_environment <- function(dem, gisBase, epsg = NULL, sites = NULL, ...){
  if(!is.null(sites))
    message(writeLines(strwrap("'sites' is no longer a parameter of setup_grass_environment (see help).\n
                               The function will still execute normally. Please update your code.",
                               width = 80)))
  if(!is.null(epsg))
    message(writeLines(strwrap("'epsg' is no longer a parameter of setup_grass_environment (see help).\n
                               The function will still execute normally. Please update your code.",
                               width = 80)))
  
  use_sp()
  dem_grid <- rgdal::readGDAL(dem, silent = TRUE)
  initGRASS(gisBase = gisBase,
            SG = dem_grid,
            mapset = "PERMANENT",
            ...)
  execGRASS("g.proj", flags = c("c", "quiet"),
            parameters = list(
              georef = dem
            ))
}


#' Update attribute table.
#'
#' Wrapper for v.to.db to catch errors arising in some GRASS versions
#'
#' @param map character; name of the map where values should be uploaded.  
#' @param option character; what values should be uploaded
#' @param columns character; name of the column top upload data to
#' @param format character; data format of the new columns (if it must be created)
#' @param type character; feature type (default = "line")
#'
#' @return Nothing. Uses \href{https://grass.osgeo.org/grass78/manuals/v.to.db.html}{v.to.db}
#' to populate attribute values from vector features. 
#'
#' @details Since different versions of GRASS handle v.to.db differently (older versions <= 7.4 need
#'  the column to exists. while newer ones create the column) different implementations are
#'  necessary
#' 
#' @author Mira Kattwinkel, \email{mira.kattwinkel@@gmx.net}
#' @export
#' 
grass_v.to.db <- function(map, option, type = "line", columns, format){
  # MiKatt 20200724: 
  # Does not work with 7.4; gives 
  # DBMI-SQLite driver error:
  # Error in sqlite3_prepare():
  #  no such column: length_new
#   check <- try(execGRASS("v.to.db", flags = c("quiet"),
#                        parameters = list(
#                          map = map,
#                          option = option,
#                          type = type,
#                          columns = paste(columns, collapse = ","))), silent = TRUE)
# # create column first, then fill it version < 7.6
#   if(class(check) == "try-error"){
#     execGRASS("v.db.addcolumn", flags = "quiet",
#             parameters = list(
#               map = map,
#               columns = paste0(paste(columns, format), collapse = ",")
#             ))
#   execGRASS("v.to.db", flags = c("quiet"),
#             parameters = list(
#               map = map,
#               option = option,
#               type = type,
#               columns = paste(columns, collapse = ",")
#             ), ignore.stderr = TRUE)
#   }
  
  execGRASS("v.db.addcolumn", flags = "quiet",
            parameters = list(
              map = map,
              columns = paste0(paste(columns, format), collapse = ",")
            ))

  check <- try(execGRASS("v.to.db", flags = c("quiet"),
                         parameters = list(
                           map = map,
                           option = option,
                           type = type,
                           columns = paste(columns, collapse = ",")
                           ), ignore.stderr = TRUE), silent = TRUE)
  # use overwrite for Grass 7.8
  # still does not know overwrite flag!
  if(class(check) == "try-error"){
    execGRASS("v.db.dropcolumn", flags = "quiet",
              parameters = list(
                map = map,
                columns = paste0(columns, collapse = ",")
              ))
    
    execGRASS("v.to.db", flags = c("quiet"),
              parameters = list(
                map = map,
                option = option,
                type = type,
                columns = paste(columns, collapse = ",")
              ), ignore.stderr = TRUE)
  }
}