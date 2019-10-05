#' Line element parsed
#'
#' @inheritParams dem_check
#' @importFrom xml2 xml_find_all
#' @importFrom rlang abort
#' @import purrr
#' @details type AdmArea, BldA, WA
fgd_line_parse <- function(file) {
  file_info <- fgd_file_info(file)
  if (!file_info$type %in% c("AdmBdry", "BldL",
                             "Cntr",
                             "CommBdry",
                             "Cstline",
                             "RailCL",
                             "RdCompt", "RdEdg",
                             "WA", "WL",
                             "WStrA", "WStrL",
                             "AdmArea", "BldA")) {
    rlang::abort("input irregular type file")
  }
  if (file_info$type %in% c("AdmArea")) {
    res <-
      file_info$xml_docs %>%
      xml2::xml_find_all("/*/*/*/gml:Surface/gml:patches/gml:PolygonPatch/gml:exterior/gml:Ring/gml:curveMember/gml:Curve/gml:segments/gml:LineStringSegment/gml:posList") %>% # nolint
      .line_parse()
  }
  if (file_info$type %in% c("AdmBdry", "BldL", "Cntr", "CommBdry", "Cstline",
                            "RailCL", "RdCompt", "RdEdg", "WL", "WStrL")) {
    res <-
      file_info$xml_docs %>%
      xml2::xml_find_all("/*/*/*/gml:Curve/gml:segments/gml:LineStringSegment/gml:posList") %>% # nolint
      .line_parse()
  }

  if (file_info$type %in% c("BldA", "WA", "WStrA")) {
    res <-
      file_info$xml_docs %>%
      xml2::xml_find_all("/*/*/*/gml:Surface/gml:patches/gml:PolygonPatch/gml:exterior/gml:Ring/gml:curveMember/gml:Curve/gml:segments/gml:LineStringSegment/gml:posList") %>% # nolint
      .line_parse()
  }
  res
}

fgd_point_parse <- function(file) {
  file_info <- fgd_file_info(file)
  if (!file_info$type %in% c("AdmPt", "CommPt", "ElevPt",
                             "GCP")) {
    rlang::abort("input irregular type file")
  }
  res <-
    file_info$xml_docs %>%
    xml2::xml_find_all("/*/*/*/gml:Point/gml:pos") %>% # nolint
    xml2::xml_contents() %>%
    as.character() %>%
    purrr::map(~ stringr::str_split(.x, "[:space:]")) %>%
    purrr::flatten() %>%
    purrr::map(~ as.numeric(rev(.x)))
  res
}

elem_to_line <- function(xml_parsed) {
  xml_parsed %>%
    purrr::map(
      ~ sf::st_linestring(matrix(unlist(.x),
                                 ncol = 2,
                                 byrow = TRUE))) %>%
    sf::st_sfc(crs = 6668)

}

fgd_file_info <- function(file, ...) {
  xmls <-
    xml2::read_xml(file, ...)
  type <-
    xmls %>%
    xml2::xml_child(search = 3) %>%
    xml2::xml_name()
  list(xml_docs = xmls, type = type)
}

fgd_dem_file_info <- function(file, ...) {

  file_info <-
    fgd_file_info(file, ...)

  is5m <-
    file_info$xml_docs %>%
    xml2::xml_find_first("/*/*[3]/*[6]") %>% # nolint
    xml2::xml_contents() %>%
    as.character() %>%
    stringr::str_detect("5m")

  meshcode <-
    file_info$xml_docs %>%
    xml2::xml_find_all("/*/*[3]/*[7]") %>% # nolint
    xml2::xml_contents() %>%
    as.character()

  list(xml_docs = file_info$xml_docs,
       type = file_info$type,
       is5m = is5m,
       meshcode = meshcode)

}
