#' Line element parsed
#'
#' @param file XML file download from fgd
#' @importFrom stringr str_split
#' @importFrom xml2 read_xml xml_find_all xml_text
#' @import purrr
#' @details type AdmArea, BldA, WA
fdg_line_parse <- function(file) {

  fgd_type <- fdg_file_type(file)

  if (!fgd_type$type %in% c("AdmArea", "BldA", "WA", "WL")) {
   rlang::abort("input irregular type file")
  }

  if (fgd_type$type %in% c("AdmArea")) {
    fgd_type$xml_docs %>%
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
  if (fgd_type$type %in% c("WL")) {
    fgd_type$xml_docs %>%
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

fdg_file_type <- function(file) {

  xmls <-
    xml2::read_xml(file)

  type <-
    xmls %>%
    xml2::xml_child(search = 3) %>%
    xml2::xml_name()

  list(xml_docs = xmls, type = type)

}
