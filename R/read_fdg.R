#' Read and Parse FDG's XML file
#'
#' @param file Path to XML file
#' @import sf
#' @import xml2
#' @importFrom purrr pmap
read_fdg <- function(file) {

  file_info <-
    fdg_file_info(file)

  xml_parsed <-
    fdg_line_parse(file)

  ids <-
    file_info$xml_docs %>%
    xml2::xml_find_all("/*/*/*[3]") %>%
    xml2::xml_attr("id")

  if (file_info$type == "AdmArea") {
    nms <-
      file_info$xml_docs %>%
      xml2::xml_find_all("/*/*/*[8]") %>%
      xml2::xml_text()

    list(xml_parsed, ids, nms) %>%
      purrr::pmap(
        ~ sf::st_linestring(matrix(unlist(..1),
                                   ncol = 2,
                                   byrow = TRUE)) %>%
          sf::st_sfc(crs = 4326) %>%
          sf::st_sf(
            gml_id = ..2,
            adm_name = ..3,
            geometry = .
          )
      )
  } else {
    list(xml_parsed, ids) %>%
      purrr::pmap(
        ~ sf::st_linestring(matrix(unlist(..1),
                                   ncol = 2,
                                   byrow = TRUE)) %>%
          sf::st_sfc(crs = 4326) %>%
          sf::st_sf(
            gml_id = ..2,
            geometry = .
          )
      )
  }
}
