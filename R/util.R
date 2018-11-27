#' DEM input file status check
#'
#' @inherit fdg_line_parse
#' @param .verbose `logical`. suppress info input XML file's about DEM information.
#' @param ... Additional arguments passed on to other functions.
dem_check <- function(file, .verbose = TRUE, ...) {

  file_info <-
    fdg_file_info(file, ...)

  if (file_info$type != "DEM") {
    rlang::inform("Input files must be DEM format")
  } else {
    value_order <-
      file_info$xml_docs %>%
      xml2::xml_find_all("/*/*/*/gml:coverageFunction/gml:GridFunction/gml:sequenceRule") %>%
      xml2::xml_attr(attr = "order")

    if (value_order != "+x-y")
      rlang::inform("check input file format")

    start_point <-
      file_info$xml_docs %>%
      xml2::xml_find_all("/*/*/*/gml:coverageFunction/gml:GridFunction/gml:startPoint") %>%
      xml2::xml_text() %>%
      stringr::str_split("[[:space:]]") %>%
      unlist() %>%
      as.numeric()

    if (start_point != c(0, 0) && rlang::is_true(.verbose))
      rlang::inform("Data is not given from the starting point.\nCheck these coordinate")

    start_point
  }

}
