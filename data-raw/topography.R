library(croc)
nrows <- 2160
bins <- initbin(nrows)
ll <- bin2lonlat(1:bins$totbins, nrows)
library(terra)

topo <- rast(raadtools::topofile("gebco_08"))

z <- extract(topo, ll)

topo <- tibble::tibble(bin = as.integer(1:bins$totbins), z = as.integer(z$elevation))
attr(topo, "nrows") <- nrows
usethis::use_data(topo, compress = "xz")





