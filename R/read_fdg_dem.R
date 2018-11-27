#' Read and Parse FDG's XML dem file
#'
#' @inheritParams read_fdg
#' @param resolution the number of dem mesh size resolution: 5m or 10m
#' @param return_class one of return object class: 'df' (data.frame), 'raster'
#' @import xml2
#' @importFrom magrittr use_series
#' @importFrom purrr reduce
#' @importFrom raster raster
#' @importFrom rlang arg_match
#' @importFrom tibble add_row
#' @importFrom utils read.delim
read_fdg_dem <- function(file, resolution = c(5, 10), return_class = c("df", "raster")) {

  . <- value <- NULL

  output_type <-
    rlang::arg_match(return_class)

  if (resolution == 5) {
    grid_size <- list(x = 225, y = 150)
    xml_opts = "NOBLANKS"
  } else if (resolution == 10) {
    grid_size <- list(x = 1125, y = 750)
    xml_opts = "HUGE"
  }

  checked <-
    dem_check(file, .verbose = FALSE, options = xml_opts)

  df_dem <-
    xml2::read_xml(file, options = xml_opts) %>%
    xml2::xml_find_all("/*/*/*/gml:rangeSet/gml:DataBlock/gml:tupleList") %>%
    xml2::xml_contents() %>%
    as.character() %>%
    utils::read.delim(text = ., sep = ",",
               stringsAsFactors = FALSE,
               col.names = c("type", "value"))

  if (identical(checked, c(0, 0))) {
    df_dem_full <-
      df_dem %>%
      tibble::add_row(
        type = rep("\u30c7\u30fc\u30bf\u306a\u3057",
                   times = (purrr::reduce(grid_size, `*`) - nrow(.))),
        value = -9999
      )
  } else {
    df_dem_full <-
      df_dem %>%
      tibble::add_row(
        type = rep("\u30c7\u30fc\u30bf\u306a\u3057",
                   times = (checked[1] + checked[2])),
        value = -9999,
        .before = 0)
  }

  if (nrow(df_dem_full) < purrr::reduce(grid_size, `*`)) {
    df_dem_full <-
      df_dem_full %>%
      tibble::add_row(
        type = rep("\u30c7\u30fc\u30bf\u306a\u3057",
                   times = (purrr::reduce(grid_size, `*`) - nrow(.))),
        value = -9999
      )
  }

  res <-
    df_dem_full %>%
    tibble::as_tibble()

  switch(output_type,
         df = res,
         raster = res %>%
      magrittr::use_series(value) %>%
      matrix(nrow = grid_size$x, ncol = grid_size$y) %>%
      t() %>%
      raster::raster()
  )
}
