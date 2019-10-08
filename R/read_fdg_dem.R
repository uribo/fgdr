#' @title Read and Parse Fundamental Geospatial Data (FGD) dem file
#'
#' @description The JPGIS (GML) format file provided by FGD as input,
#' the digital elevation models in the file are read as a data.frame or spatial object (raster or stars).
#' Supporting FGD Version 4.1 (2016/10/31)
#' @seealso \url{https://fgd.gsi.go.jp/download/ref_dem.html}
#'
#' @inheritParams read_fgd
#' @param resolution the number of dem mesh size resolution: 5m or 10m
#' @param return_class one of return object class: 'df' ([data.frame][data.frame], default),
#' '[raster][raster::raster]' or '[stars][stars::st_as_stars]'
#' @import xml2
#' @importFrom magrittr use_series
#' @importFrom purrr reduce
#' @importFrom raster raster
#' @importFrom rlang arg_match warn
#' @importFrom tibble add_row
#' @importFrom readr read_csv
#' @importFrom stars st_as_stars
#' @return A [tibble][tibble::tibble] (data.frame), [raster][raster::raster] or [stars][stars::st_as_stars]
#' @export
#' @examples
#' fgd_5dem <- system.file("extdata/FG-GML-0000-00-00-DEM5A-dummy.xml", package = "fgdr")
#' read_fgd_dem(fgd_5dem,
#'              resolution = 5)
#' # return as raster
#' read_fgd_dem(fgd_5dem,
#'              resolution = 5,
#'              return_class = "raster")
#' # return as stars
#' fgd_10dem <- system.file("extdata/FG-GML-0000-10-dem10b-dummy.xml", package = "fgdr")
#' read_fgd_dem(fgd_10dem,
#'              resolution = 10,
#'              return_class = "stars")
read_fgd_dem <- function(file, resolution = c(5, 10),
                         return_class = c("df", "raster", "stars")) {
  . <- value <- NULL
  output_type <-
    rlang::arg_match(return_class)
  if (resolution == 5) {
    grid_size <- list(x = 225, y = 150)
    xml_opts <- "NOBLANKS"
  } else if (resolution == 10) {
    grid_size <- list(x = 1125, y = 750)
    xml_opts <- "HUGE"
  }
  checked <-
    dem_check(file, .verbose = FALSE, options = xml_opts)
  file_info <-
    fgd_dem_file_info(file, options = xml_opts)
  df_dem <-
    file_info$xml_docs %>%
    xml2::xml_find_all("/*/*/*/gml:rangeSet/gml:DataBlock/gml:tupleList") %>% # nolint
    xml2::xml_contents() %>%
    as.character() %>%
    readr::read_csv(col_names = c("type", "value"),
                    col_types = c("cd"))
  df_dem$value[df_dem$type == "\u30c7\u30fc\u30bf\u306a\u3057"] <- NA_real_
  if (identical(checked, c("0", "0"))) {
    df_dem_full <-
      df_dem
  } else {
    df_dem_full <-
      df_dem %>%
      tibble::add_row(
        type = rep("\u30c7\u30fc\u30bf\u306a\u3057",
                   times = (as.numeric(checked[1]) + as.numeric(checked[2]) * grid_size$x)),
        value = NA_real_,
        .before = 0)
  }
  if (nrow(df_dem_full) < purrr::reduce(grid_size, `*`)) {
    df_dem_full <-
      df_dem_full %>%
      tibble::add_row(
        type = rep("\u30c7\u30fc\u30bf\u306a\u3057",
                   times = (purrr::reduce(grid_size, `*`) - nrow(.))),
        value = NA_real_
      )
  }
  res <-
    df_dem_full %>%
    tibble::as_tibble()
  if (output_type == "stars") {

  }
  if (output_type == "df") {
    res
  } else if (output_type %in% c("raster", "stars")) {
    res <-
      res %>%
      magrittr::use_series(value) %>%
      matrix(nrow = grid_size$x, ncol = grid_size$y) %>%
      t() %>%
      raster::raster() %>%
      set_coords(meshcode = file_info$meshcode)
    if (output_type == "raster") {
      res
    } else if (output_type == "stars") {
      stars::st_as_stars(res)
    }
  }
}
