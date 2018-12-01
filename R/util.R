#' DEM input file status check
#'
#' @inherit fgd_line_parse
#' @param .verbose `logical`. suppress info input XML file's about DEM information.
#' @param ... Additional arguments passed on to other functions.
dem_check <- function(file, .verbose = TRUE, ...) {

  file_info <-
    fgd_file_info(file, ...)

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

set_coords <- function(raster, meshcode){

  mesh <-
    meshcode %>%
    jpmesh::export_mesh()

  bb <-
    mesh %>%
    sf::st_bbox() %>%
    as.numeric()

  raster::extent(raster) <-
    raster::extent(bb[1], bb[3], bb[2], bb[4])
  raster::crs(raster) <-
    mesh %>%
    sf::as_Spatial() %>%
    sp::proj4string()
  raster
}

.line_parse <- function(xml_node) {
  xml_node %>%
    xml2::xml_contents() %>%
    purrr::map(
      ~ xml2::xml_text(.x, trim = TRUE) %>%
        stringr::str_split("\n") %>%
        purrr::flatten() %>%
        purrr::map(~ stringr::str_split(.x, "[:space:]")) %>%
        purrr::flatten() %>%
        purrr::map(~ as.numeric(rev(.x)))
    )
}
