#' Line element parsed
#'
#' @param file XML file download from fgd
#' @importFrom stringr str_split
#' @importFrom xml2 read_xml xml_find_all xml_text
#' @import purrr
#' @details type AdmArea, BldA, WA
fdg_line_parse <- function(file) {

  file_info <- fdg_file_info(file)

  if (!file_info$type %in% c("AdmArea", "BldA", "WA", "WL")) {
   rlang::abort("input irregular type file")
  }

  if (file_info$type %in% c("AdmArea")) {
    file_info$xml_docs %>%
      xml2::xml_find_all("/*/*/*/gml:Surface/gml:patches/gml:PolygonPatch/gml:exterior/gml:Ring/gml:curveMember/gml:Curve/gml:segments/gml:LineStringSegment/gml:posList") %>%
      purrr::map(
        ~ xml2::xml_text(.x, trim = TRUE) %>%
          stringr::str_split("\n") %>%
          purrr::flatten() %>%
          purrr::map(~ stringr::str_split(.x, "[:space:]")) %>%
          purrr::flatten() %>%
          purrr::map(~ as.numeric(rev(.x)))
      )
  }
  if (file_info$type %in% c("WL")) {
    file_info$xml_docs %>%
      xml2::xml_find_all("/*/*/*/*/*/*") %>%
      purrr::map(
        ~ xml2::xml_text(.x, trim = TRUE) %>%
          stringr::str_split("\n") %>%
          purrr::flatten() %>%
          purrr::map(~ stringr::str_split(.x, "[:space:]")) %>%
          purrr::flatten() %>%
          purrr::map(~ as.numeric(rev(.x)))
      )
  }
}

fdg_file_info <- function(file, ...) {

  xmls <-
    xml2::read_xml(file, ...)

  type <-
    xmls %>%
    xml2::xml_child(search = 3) %>%
    xml2::xml_name()

  list(xml_docs = xmls, type = type)

}

fdg_dem_file_info <- function(file, ...) {

  file_info <-
    fdg_file_info(file, ...)

  is5m <-
    file_info$xml_docs %>%
    xml2::xml_find_first("/*/*[3]/*[6]") %>%
    xml2::xml_contents() %>%
    as.character() %>%
    stringr::str_detect("5m")

  meshcode <-
    file_info$xml_docs %>%
    xml2::xml_find_all("/*/*[3]/*[7]") %>%
    xml2::xml_contents() %>%
    as.character()

  list(xml_docs = file_info$xml_docs,
       type = file_info$type,
       is5m = is5m,
       meshcode = meshcode)

}
