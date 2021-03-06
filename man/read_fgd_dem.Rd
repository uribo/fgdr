% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read_fdg_dem.R
\name{read_fgd_dem}
\alias{read_fgd_dem}
\title{Read and Parse Fundamental Geospatial Data (FGD) dem file}
\usage{
read_fgd_dem(file, resolution = c(5, 10), return_class)
}
\arguments{
\item{file}{Path to XML file}

\item{resolution}{the number of dem mesh size resolution: 5m or 10m}

\item{return_class}{one of return object class: '\link[data.table:data.table]{data.table}'
for faster than data.frame, '\link{data.frame}', '\link[raster:raster]{raster}',
'\link[stars:st_as_stars]{stars}' or '\link[terra:rast]{terra}'}
}
\value{
A \link[tibble:tibble]{tibble} (data.frame), \link[raster:raster]{raster},
\link[stars:st_as_stars]{stars} or \link[terra:rast]{terra}
}
\description{
The JPGIS (GML) format file provided by FGD as input,
the digital elevation models in the file are read as a data.frame or
spatial object (raster, stars or terra).
Supporting FGD Version 4.1 (2016/10/31)
}
\examples{
fgd_5dem <- system.file("extdata/FG-GML-0000-00-00-DEM5A-dummy.xml", package = "fgdr")
read_fgd_dem(fgd_5dem,
             resolution = 5,
             return_class = "data.table")
read_fgd_dem(fgd_5dem,
             resolution = 5,
             return_class = "data.frame")
# return as raster
read_fgd_dem(fgd_5dem,
             resolution = 5,
             return_class = "raster")
# return as stars
fgd_10dem <- system.file("extdata/FG-GML-0000-10-dem10b-dummy.xml", package = "fgdr")
read_fgd_dem(fgd_10dem,
             resolution = 10,
             return_class = "stars")
}
\seealso{
\url{https://fgd.gsi.go.jp/download/ref_dem.html}
}
