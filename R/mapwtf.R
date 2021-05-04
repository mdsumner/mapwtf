globalVariables("topo")


#' @importFrom stats runif
any_proj <- function(proj = "laea", lon_0=runif(1L, -180, 180), lat_0=runif(1L, -90, 90), ...) {
  l <- c(as.list(c(proj = proj, lon_0 = lon_0, lat_0 = lat_0)), list(...))
  paste(paste0("+", names(l), "=", unlist(l)), collapse = " ")
}

#' Generate a gridded region anywhere
#'
#' @param width buffer with in metres
#' @param ... proj4 parameters passed to internal function
#'
#' @return RasterLayer
#' @export
#' @importFrom raster extent raster
#' @importFrom geosphere randomCoordinates
#' @examples
#' any_region()
any_region <- function(width = 50000, ...) {

  proj <- any_proj(...)
  pt <- matrix(as.numeric(c(unlist(lapply(strsplit(strsplit(proj, "+lon_0=")[[1]][2], " "), "[", 1)),
               unlist(lapply(strsplit(strsplit(proj, "+lat_0=")[[1]][2], " "), "[", 1)))), nrow = 1)
  xy <- rgdal::project(pt, proj)
  raster::raster(raster::extent(xy[1] - width, xy[1] + width, xy[2] - width, xy[2] + width),
                 crs = proj, nrows = 180, ncols = 180)
}


#' Fill a projected raster with topography from the topo data set
#'
#' @param x a projected raster
#'
#' @return the raster with topography values in it
#' @export
#' @importFrom croc lonlat2bin
#' @examples
#' populate_topo(any_region())
populate_topo <- function(x) {
  xy <- rgdal::project(raster::coordinates(x), raster::projection(x), inv = TRUE)
  bin <- croc::lonlat2bin(xy[,1], xy[,2], attr(topo, "nrows"))
  x[] <- topo$z[bin]
  x
}


#' plot a rough graticule over a projected raster
#'
#' @param x a projected raster
#'
#' @return side effect draws on existing plot
#' @export
#'
#' @importFrom rgdal project
#' @importFrom raster setValues projection coordinates contour
#' @examples
#' x <- any_region()
#' raster::plot(raster::extent(x))
#' grat(x)
grat <- function(x) {
  xy <- raster::coordinates(x)
  ll <- rgdal::project(xy, raster::projection(x), inv = TRUE)
  contour(raster::setValues(x, ll[,1]), add = TRUE)
  contour(raster::setValues(x, ll[,2]), add = TRUE)
}
