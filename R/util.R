#' DEM input file status check
#'
#' @param file XML file download from fgd
#' @param .verbose `logical`. suppress info input XML file's about DEM information.
#' @param ... Additional arguments passed on to other functions.
#' @import xml2
dem_check <- function(file, .verbose = TRUE, ...) {
  file_info <-
    fgd_file_info(file, ...)
  if (file_info$type != "DEM") {
    rlang::inform("Input files must be DEM format")
  } else {
    value_order <-
      file_info$xml_docs %>%
      xml2::xml_find_all("/*/*/*/gml:coverageFunction/gml:GridFunction/gml:sequenceRule") %>% # nolint
      xml2::xml_attr(attr = "order")
    if (value_order != "+x-y")
      rlang::inform("check input file format")
    start_point <-
      file_info$xml_docs %>%
      xml2::xml_find_all("/*/*/*/gml:coverageFunction/gml:GridFunction/gml:startPoint") %>% # nolint
      xml2::xml_text() %>%
      stringr::str_split("[[:space:]]") %>%
      unlist() %>%
      as.integer()
    if (.verbose == TRUE)
      if (!all.equal(start_point, c(0L, 0L)))
        rlang::inform("Data is not given from the starting point.\nCheck these coordinate")
    start_point
  }
}

set_coords <- function(raster, meshcode, as_stars = FALSE) {
  mesh <-
    meshcode %>%
    jpmesh::export_mesh() %>%
    sf::st_transform(crs = 6668)
  bb <-
    mesh %>%
    sf::st_bbox() %>%
    as.numeric()

  if (inherits(raster, "SpatRaster")) {
    terra::ext(raster) <-
      terra::ext(bb[1], bb[3], bb[2], bb[4])
    terra::crs(raster) <-
      "epsg:6668"
    return(raster)
  }
  # TODO: until stars::st_set_bbox() is released on CRAN,
  # it seems there's no means to set extent on stars objects
  # so we need to do it before converting to stars.
  raster::extent(raster) <-
    raster::extent(bb[1], bb[3], bb[2], bb[4])
  if (as_stars) {
    raster <-
      stars::st_as_stars(raster)
    sf::st_crs(raster) <-
      6668
  } else {
    # Depending on the version of PROJ, we'll see warning like
    # "Discarded datum Japanese_Geodetic_Datum_2011 in CRS definition"
    # But, as raster doesn't provide a way to specify it by EPSG code directly,
    # we just need to suppress the warning here...
    suppressWarnings(
      raster::crs(raster) <-
        sf::st_crs(6668)$proj4string
    )
  }
  raster
}

.line_parse <- function(xml_node) {
  xml_node %>%
    xml2::xml_contents() %>%
    xml2::xml_text(trim = TRUE) %>%
    stringr::str_split("\n") %>%
    purrr::map(~ stringr::str_split(.x, "[:space:]")) %>%
    purrr::map(
      ~ purrr::flatten_chr(.x) %>%
        rev() %>%
        as.numeric() %>%
        matrix(., ncol = 2, byrow = TRUE)) %>%
    purrr::map(
      ~ sf::st_linestring(.x)) %>%
    sf::st_sfc(crs = 6668)
}

extract_polygon <- function(d) {
  rowname <- NULL
  na_rows <-
    which(st_is_empty(d$geometry) == TRUE)

  if (length(na_rows) > 0) {
    d_empty <-
      d[na_rows, ]
    d_fill <-
      d[-na_rows, ] %>%
      sf::st_collection_extract("POLYGON")
    res <-
      rbind(d_empty, d_fill) %>%
      tibble::rownames_to_column()
    res$rowname <- as.numeric(res$rowname)
    res <-
      res[with(res, order(rowname)), ]
    res <-
      base::subset(res, select = -rowname)
  } else {
    res <-
      d %>%
      sf::st_collection_extract("POLYGON") %>%
      tibble::remove_rownames()
  }
  res
}

extract_xml_value <- function(x, name, name_length = 8) {
  . <- NULL
  x1 <-
    x %>%
    xml2::xml_find_all("/*/*") %>% # nolint
    purrr::set_names(seq(from = 1, to = length(.)))
  contents <-
    x %>%
    xml2::xml_find_all("/*/*/*") # nolint
  contents_name <-
    contents %>%
    xml2::xml_name()
  x_loc <-
    which(contents_name %in% name)
  x_vec <-
    contents[x_loc] %>%
    xml2::xml_contents() %>%
    as.character()
  if (length(x1) - 2 != length(x_vec)) {
    x2 <-
      seq(from = 3, to = length(x1)) %>%
      purrr::map_lgl(
        ~ x1[[.x]] %>%
          xml2::xml_length() == name_length) %>%
      purrr::set_names(seq(from = 3, to = length(x1)))
    na_loc <-
      x2 %>%
      purrr::keep(~ .x == FALSE) %>%
      names() %>%
      as.numeric()
    x_vec <-
      seq(1, length(x_vec)) %>%
      purrr::map(
        function(x) {
          tmp <- x %in% na_loc
          if (tmp == TRUE) {
            res <- c(NA_real_, x_vec[x])
          } else {
            res <- x_vec[x]
          }
          res
        }
      ) %>%
      purrr::reduce(c)
  }
  utils::type.convert(x_vec, as.is = TRUE)
}
