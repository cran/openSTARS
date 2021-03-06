% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/calc_sites.R
\name{calc_sites}
\alias{calc_sites}
\title{Calculate sites for SSN object.}
\usage{
calc_sites(
  locid_col = NULL,
  pid_col = NULL,
  predictions = NULL,
  maxdist = NULL
)
}
\arguments{
\item{locid_col}{character (optional); column name in the sites attribute 
table giving a unique site identifier. If not provided, it is created
automatically (based on the 'cat' field; default).}

\item{pid_col}{character (optional); column name in the sites attribute table 
that distinguishes between repeated measurements at a sampling site, e.g. by 
date. If not provided, it is created automatically.}

\item{predictions}{character vector (optional); names for prediction sites 
(loaded with \code{import_data}).}

\item{maxdist}{integer (optional); maximum snapping distance in map units (see details).
Sites farther away from edges will be deleted.}
}
\description{
A vector (points) map 'sites' is derived and several attributes
are assigned.
}
\details{
Steps include:
\itemize{
\item{Snap points to derived network (edges). 'dist'
gives the distance of the original position to the closest streams segment. 
If this is a too large value consider running \code{\link{derive_streams}} again with
smaller value for \code{accum_threshold} and/or \code{min_stream_length}.}
\item{Save the new point coordinates in NEAR_X and NEAR_Y.}
\item{Assign unique 'pid' and 'locID' (needed by the 'SSN' package).}
\item{Get 'rid' and 'netID' of the
stream segment the site intersects with (from map "edges").}
\item{Calculate upstream distance for each point ('upDist').}
\item{Calculate distance ratio
('ratio') between position of site on edge (distance traveled from lower
end of the edge to the site) and the total length of the edge.} }
Often, survey sites do not lay exactly on the stream network (due to GPS imprecision,
stream representation as lines, derivation of streams from dem, etc.). To
assign an exact position of the sites on the network they are moved to the
closest stream segment (snapped) using the GRASS function
\href{https://grass.osgeo.org/grass78/manuals/v.distance.html}{v.distance}.

If \code{locid_col} and \code{pid_col} are not provided, 'pid' and 'locID' 
are identical, unique numbers. If they are provided, they are created based
on these columns (as numbers, not as text). Note that measurements
can be joined to the sites at a later step (including multiple parameters and
multiple measurements) using \code{\link{merge_sites_measurements}}. 
Then, 'pid' is updated accordingly. 

'upDist' is calculated using
\href{https://grass.osgeo.org/grass78/manuals/v.distance.html}{v.distance} with 
upload = "to_along" which gives the distance along the stream segment to the next
upstream node ('distalong'). 'upDist' is the difference between the 'upDist' 
of the edge the point lies on and 'distalong'.

The unit for distances (= map units) can be found out using 
execGRASS("g.proj", flags = "p").

If prediction sites have been created outside of this package they can be 
processed here as well. They must have been imported with \code{\link{import_data}}
before. Alternatively, prediction sites can be created using
\code{\link{calc_prediction_sites}}.
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

# Check and correct complex confluences (there are no complex confluences in this
# example date set; set accum_threshold in derive_streams to a smaller value
# to create complex confluences)
cj <- check_compl_confluences()
if(cj){
  correct_compl_confluences()
}

# Prepare edges
calc_edges()

# Prepare site
calc_sites()

# Plot data
library(sp)
dem <- readRAST('dem', ignore.stderr = TRUE, plugin = FALSE)
edges <- readVECT('edges', ignore.stderr = TRUE)
sites <- readVECT('sites', ignore.stderr = TRUE)
sites_o <- readVECT('sites_o', ignore.stderr = TRUE)
plot(dem, col = terrain.colors(20),axes = TRUE)
lines(edges, col = 'blue')
points(sites, pch = 4)
points(sites_o, pch = 1)
legend("topright", pch = c(1, 4), legend = c("original", "corrected"))
}
}
\author{
Mira Kattwinkel \email{mira.kattwinkel@gmx.net}, Eduard Szoecs, 
\email{eduardszoecs@gmail.com},
}
