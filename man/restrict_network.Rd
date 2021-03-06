% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/restrict_network.R
\name{restrict_network}
\alias{restrict_network}
\title{Restrict edges to certain stream networks}
\usage{
restrict_network(
  sites = NULL,
  keep_netIDs = NULL,
  delete_netIDs = NULL,
  keep = TRUE,
  filename = "edges_o"
)
}
\arguments{
\item{sites}{name(s) of sites.}

\item{keep_netIDs}{numeric (optional); vector of netIDs to keep}

\item{delete_netIDs}{numeric (optional); vector of netIDs to delete}

\item{keep}{boolean; should the original 'edges' be saved? Default is TRUE.}

\item{filename}{character string; file name to save the original edges vector file; 
defaults to 'edges_o'.}
}
\value{
Nothing. The function updates 'edges' and (if keep = TRUE) saves 
the original file to the file name provided.
}
\description{
When the stream network is derived from a DEM, the network will cover the whole
extent of the DEM input. However, the observation sites might be restricted
to a certain area, i.e. to certain networks. This function deletes edges
that belong to networks (based on their netID) without sites (observation or prediction).
This can help to save computation time before calculating edge attributes.
}
\examples{
\donttest{
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
lakes_path <- system.file("extdata", "nc", "lakes.shp", package = "openSTARS")
import_data(dem = dem_path, sites = sites_path)

# Derive streams from DEM
derive_streams(burn = 0, accum_threshold = 100, condition = TRUE, clean = TRUE)

# Check and correct complex confluences (there are no complex confluences in this
# example date set; set accum_threshold in derive_streams to a smaller value
# to create complex confluences)
cj <- check_compl_confluences()
if(cj){
  correct_compl_confluences()
}

calc_edges()
calc_sites()
restrict_network(sites = "sites", keep = TRUE, filename = "edges_o")

# plot
library(sp)
edges <- readVECT('edges', ignore.stderr = TRUE)
edges_o <- readVECT('edges_o', ignore.stderr = TRUE)
sites <- readVECT('sites', ignore.stderr = TRUE)
plot(edges_o, col = "lightblue", lwd = 2)
lines(edges, col = "blue4", lty = 2) 
points(sites, pch = 16, col = "red")
legend("topright", col = c("red", "lightblue", "blue4"), lty = c(NA, 1, 2),
       lwd = c(NA,2,1), pch = c(16,NA,NA),
       legend = c("sites", "edges original", "edges restricted"))
}
}
\author{
Mira Kattwinkel  \email{mira.kattwinkel@gmx.net}
}
