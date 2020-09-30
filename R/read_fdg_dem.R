#' @title Read and Parse Fundamental Geospatial Data (FGD) dem file
#'
#' @description The JPGIS (GML) format file provided by FGD as input,
#' the digital elevation models in the file are read as a data.frame or
#' spatial object (raster, stars or terra).
#' Supporting FGD Version 4.1 (2016/10/31)
#' @seealso \url{https://fgd.gsi.go.jp/download/ref_dem.html}
#'
#' @inheritParams read_fgd
#' @param resolution the number of dem mesh size resolution: 5m or 10m
#' @param return_class one of return object class: '[data.table][data.table::data.table]'
#' for faster than data.frame, '[data.frame][data.frame]', '[raster][raster::raster]',
#' '[stars][stars::st_as_stars]' or '[terra][terra::rast]'
#' @import xml2
#' @importFrom data.table fread
#' @importFrom purrr pluck reduce
#' @importFrom raster raster
#' @importFrom rlang arg_match warn
#' @importFrom tibble add_row
#' @importFrom readr read_csv
#' @importFrom terra rast
#' @importFrom stars st_as_stars
#' @return A [tibble][tibble::tibble] (data.frame), [raster][raster::raster],
#' [stars][stars::st_as_stars] or [terra][terra::rast]
#' @export
#' @examples
#' fgd_5dem <- system.file("extdata/FG-GML-0000-00-00-DEM5A-dummy.xml", package = "fgdr")
#' read_fgd_dem(fgd_5dem,
#'              resolution = 5,
#'              return_class = "data.table")
#' read_fgd_dem(fgd_5dem,
#'              resolution = 5,
#'              return_class = "data.frame")
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
                         return_class) {
  . <- value <- NULL
  output_type <-
    rlang::arg_match(
      return_class,
      c("data.table", "data.frame", "raster", "stars", "terra"))
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
  input_x <-
    file_info$xml_docs %>%
    xml2::xml_find_all("/*/*/*/gml:rangeSet/gml:DataBlock/gml:tupleList") %>% # nolint
    xml2::xml_contents() %>%
    as.character()
  if (output_type == "data.table") {
    df_dem <-
      input_x %>%
      data.table::fread(col.names = c("type", "value"),
                        colClasses = c("character", "double"))
  } else {
    df_dem <-
      input_x %>%
      readr::read_csv(col_names = c("type", "value"),
                      col_types = c("cd"))
  }
  df_dem$value[df_dem$type == "\u30c7\u30fc\u30bf\u306a\u3057"] <- NA_real_
  if (identical(checked, c(0L, 0L))) {
    df_dem_full <-
      df_dem
  } else {
    df_dem_full <-
      df_dem %>%
      tibble::add_row(
        type = rep("\u30c7\u30fc\u30bf\u306a\u3057",
                   times = (as.numeric(checked[1]) + as.numeric(checked[2]) * grid_size$x)), # nolint
        value = NA_real_,
        .before = 0)
  }
  if (nrow(df_dem_full) < purrr::reduce(grid_size, `*`)) {
    df_dem_full <-
      df_dem_full %>%
      tibble::add_row(
        type = rep("\u30c7\u30fc\u30bf\u306a\u3057",
                   times = (purrr::reduce(grid_size, `*`) - nrow(.))),
        value = NA_real_)
  }
  if (output_type %in% c("data.table", "data.frame")) {
    res <-
      df_dem_full %>%
      purrr::modify_at(2,
                       ~ units::set_units(.x, "m"))
    return(res)
  }

  rast_mat <-
    df_dem_full %>%
    purrr::pluck("value") %>%
    matrix(nrow = grid_size$x, ncol = grid_size$y) %>%
    t()
  if (output_type == "terra") {
    res <- rast_mat %>%
      terra::rast() %>%
      set_coords(meshcode = file_info$meshcode)
    return(res)
  }
  # output_type is "raster" or "stars"
  res <-
    rast_mat %>%
    raster::raster()
  res %>%
    set_coords(meshcode = file_info$meshcode, as_stars = identical(output_type, "stars"))
}
