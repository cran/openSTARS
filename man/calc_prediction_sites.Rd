% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/calc_prediction_sites.R
\name{calc_prediction_sites}
\alias{calc_prediction_sites}
\title{Calculate prediction sites for 'SSN' object.}
\usage{
calc_prediction_sites(predictions, dist = NULL, nsites = 10, netIDs = NULL)
}
\arguments{
\item{predictions}{string giving the name for the prediction sites map.}

\item{dist}{number giving the distance between the points to create in map
units.}

\item{nsites}{integer giving the approximate number of sites to create}

\item{netIDs}{integer (optional): create prediction sites only on streams with
these netID(s).}
}
\description{
A vector (points) map of prediction sites is created and several
attributes are assigned.
}
\details{
Either \code{dist} or \code{nsites} must be provided. If \code{dist}
is NULL, it is estimated by dividing the total stream length in the map by
\code{nsites}; the number of sites actually derived might therefore be a bit
smaller than \code{nsites}.

Steps include: 
\itemize{ 
\item{Place points on edges with given distance from each other} 
\item{Save the point coordinates in NEAR_X and NEAR_Y.}
\item{Assign unique identifiers (needed by the 'SSN' package) 'pid'
and 'locID'.} 
\item{Get 'rid' and 'netID' of the stream segment the site
intersects with (from map 'edges').} 
\item{Calculate upstream distance for
each point ('upDist').} 
\item{Calculate distance ratio ('distRatio') between
position of the site on the edge (= distance traveled from lower end of the
edge to the site) and the total length of the edge.} }

'pid' and 'locID' are identical, unique numbers. 'upDist' is calculated using
\href{https://grass.osgeo.org/grass78/manuals/addons/r.stream.distance.html}{r.stream.distance}.
Points are created using
\href{https://grass.osgeo.org/grass78/manuals/v.segment.html}{v.segment}.
}
\note{
\code{\link{import_data}}, \code{\link{derive_streams}} and
 \code{\link{calc_edges}} must be run before.
}
\examples{
\donttest{
# Initiate and setup GRASS
dem_path <- system.file("extdata", "nc", "elev_ned_30m.tif", package = "openSTARS")
if(.Platform$OS.type == "windows"){
  grass_program_path = "c:/Program Files/GRASS GIS 7.6"
  } else {
  grass_program_path = "/usr/lib/grass78/"
  }

setup_grass_environment(dem = dem_path, 
                        gisBase = grass_program_path,      
                        remove_GISRC = TRUE,
                        override = TRUE
                        )
gmeta()
                        
# Load files into GRASS
dem_path <- system.file("extdata", "nc", "elev_ned_30m.tif", package = "openSTARS")
sites_path <- system.file("extdata", "nc", "sites_nc.shp", package = "openSTARS")
import_data(dem = dem_path, sites = sites_path)

# Derive streams from DEM
derive_streams(burn = 0, accum_threshold = 700, condition = TRUE, clean = TRUE)

check_compl_confluences()
calc_edges()
calc_sites()
calc_prediction_sites(predictions = "preds", dist = 2500)

library(sp)
dem <- readRAST('dem', ignore.stderr = TRUE, plugin = FALSE)
sites <- readVECT('sites', ignore.stderr = TRUE)
preds <- readVECT('preds', ignore.stderr = TRUE)
edges <- readVECT('edges', ignore.stderr = TRUE)
plot(dem, col = terrain.colors(20))
lines(edges, col = 'blue', lwd = 2)
points(sites, pch = 4)
points(preds, pch = 19, col = "darkred")
}
}
\author{
Mira Kattwinkel \email{mira.kattwinkel@gmx.net}
}
