#' @title Read and Parse Fundamental Geospatial Data (FGD) file
#'
#' @description The JPGIS (GML) format file provided by FGD as input,
#' the fundamental items in the file is read as an 'sf' object.
#' Supporting FGD Version 4.1 (2016/10/31).
#' @details Support following items:
#' Administrative Area ('AdmArea'), Administrative Boundary ('AdmBdry'),
#' Representative point of Administrative Area ('AdmPt'), Building Area ('BldA'),
#' Building Outline ('BldL'), Contour ('Cntr'), Community Boundary ('CommBdry'),
#' Representative Point of Community Area ('CommPt'), Coastline ('Cstline'),
#' Elevation Point ('ElevPt'), Geodetic Control Point ('GCP'),
#' Railroad Track Centerline ('RailCL'), Road Component ('RdCompt'),
#' Road Edge ('RdEdg'), Water Area ('WA'), Water Line ('WL') and
#' Waterside Structure Line ('WStrL').
#' @seealso \url{https://fgd.gsi.go.jp/download/ref_kihon.html}
#' @param file Path to XML file
#' @import sf
#' @import xml2
#' @importFrom purrr pmap reduce list_modify
#' @importFrom tibble new_tibble
#' @return A [sf][sf::st_sf]
#' @export
#' @examples
#' # Administrative Area
#' read_fgd(system.file("extdata/FG-GML-000000-AdmPt-dummy.xml", package = "fgdr"))
read_fgd <- function(file) { # nolint
  file_info <-
    fgd_file_info(file)
  ids <-
    file_info$xml_docs %>%
    xml2::xml_find_all("/*/*/*[3]") %>% # nolint
    xml2::xml_attr("id")

  if (file_info$type %in% c("Cntr")) {
    res <-
      sf::st_sf(
        gml_id = ids,
        type = extract_xml_value(file_info$xml_docs, name = "type", name_length = 7),
        alti = extract_xml_value(file_info$xml_docs, name = "alti", name_length = 7),
        geometry = fgd_line_parse(file),
        stringsAsFactors = FALSE)
  }

  if (file_info$type %in% c("ElevPt")) {
    res <-
      list(xml_parsed = fgd_point_parse(file),
           ids,
           type = extract_xml_value(file_info$xml_docs, name = "type", name_length = 8),
           alti = extract_xml_value(file_info$xml_docs, name = "alti", name_length = 8)) %>%
      purrr::pmap(
        ~ sf::st_point(matrix(unlist(..1),
                              ncol = 2,
                              byrow = TRUE)) %>%
          sf::st_sfc(crs = 6668) %>%
          sf::st_sf(
            gml_id = ..2,
            type = ..3,
            alti = ..4,
            geometry = .)) %>%
      purrr::reduce(rbind)
  }

  if (file_info$type %in% c("CommBdry")) {
    res <-
      sf::st_sf(
        gml_id = ids,
        type = extract_xml_value(file_info$xml_docs, name = "type", name_length = 7),
        geometry = fgd_line_parse(file),
        stringsAsFactors = FALSE)
  }

  if (file_info$type %in% c("CommPt")) {
    res <-
      list(xml_parsed = fgd_point_parse(file),
           ids,
           nms = extract_xml_value(file_info$xml_docs, name = "name", name_length = 9),
           type = extract_xml_value(file_info$xml_docs, name = "type", name_length = 9)) %>%
      purrr::pmap(
        ~ sf::st_point(matrix(unlist(..1),
                              ncol = 2,
                              byrow = TRUE)) %>%
          sf::st_sfc(crs = 6668) %>%
          sf::st_sf(
            gml_id = ..2,
            name = ..3,
            type = ..4,
            geometry = .,
            stringsAsFactors = FALSE)) %>%
      purrr::reduce(rbind)
  }

  if (file_info$type == "Cstline") {
    res <-
      sf::st_sf(
        gml_id = ids,
        type = extract_xml_value(file_info$xml_docs, name = "type", name_length = 6),
        geometry = fgd_line_parse(file),
        stringsAsFactors = FALSE)
  }

  if (file_info$type %in% c("AdmBdry")) {
    res <-
      sf::st_sf(
        gml_id = ids,
        type = extract_xml_value(file_info$xml_docs,
                                 name = "type",
                                 name_length = 7),
        geometry = fgd_line_parse(file),
        stringsAsFactors = FALSE)
  }

  if (file_info$type %in% c("AdmArea", "AdmPt")) {
    nms <-
      extract_xml_value(file_info$xml_docs, name = "name", name_length = 9)
    type <-
      extract_xml_value(file_info$xml_docs, name = "type", name_length = 9)
    adm_code <-
      sprintf("%05d",
              extract_xml_value(file_info$xml_docs, name = "admCode", name_length = 9))
    if (file_info$type %in% c("AdmArea")) {
      res <-
        sf::st_sf(
          gml_id = ids,
          type = type,
          name = nms,
          adm_code = adm_code,
          geometry = fgd_line_parse(file),
          stringsAsFactors = FALSE
          ) %>%
        sf::st_polygonize() %>%
        extract_polygon()
    }

    if (file_info$type %in% c("AdmPt")) {
      res <-
        sf::st_sf(
          gml_id = ids,
          type = type,
          name = nms,
          adm_code = adm_code,
          geometry =
            fgd_point_parse(file) %>%
            purrr::map(st_point) %>%
            sf::st_sfc(crs = 6668),
          stringsAsFactors = FALSE)
    }
  }

  if (file_info$type %in% c("BldA", "BldL")) {
    xml_parsed <-
      fgd_line_parse(file)
    bld_type <-
      extract_xml_value(file_info$xml_docs, name = "type", name_length = 6)

    if (file_info$type == "BldA") {
      res <-
        sf::st_sf(
          gml_id = ids,
          type = bld_type,
          geometry = xml_parsed,
          stringsAsFactors = FALSE
          ) %>%
        sf::st_polygonize() %>%
        extract_polygon()
    }

    if (file_info$type == "BldL") {
      res <-
        sf::st_sf(
          gml_id = ids,
          type = bld_type,
          geometry = xml_parsed,
          stringsAsFactors = FALSE)
    }
  }

  if (file_info$type %in% c("GCP")) {
    res <-
      list(xml_parsed = fgd_point_parse(file),
           ids,
           org_name = extract_xml_value(file_info$xml_docs, name = "orgName", name_length = 15),
           type = extract_xml_value(file_info$xml_docs, name = "type", name_length = 15),
           gcp_class = extract_xml_value(file_info$xml_docs, name = "gcpClass", name_length = 15),
           gcp_code = extract_xml_value(file_info$xml_docs, name = "gcpCode", name_length = 15),
           nms = extract_xml_value(file_info$xml_docs, name = "name", name_length = 15),
           breite = extract_xml_value(file_info$xml_docs, name = "B", name_length = 15),
           leange = extract_xml_value(file_info$xml_docs, name = "L", name_length = 15),
           alti = extract_xml_value(file_info$xml_docs, name = "alti", name_length = 15),
           alti_acc = extract_xml_value(file_info$xml_docs, name = "altiAcc", name_length = 15)) %>%
      purrr::pmap(
        ~ sf::st_point(matrix(unlist(..1),
                              ncol = 2,
                              byrow = TRUE)) %>%
          sf::st_sfc(crs = 6668) %>%
          sf::st_sf(
            gml_id = ..2,
            org_name = ..3,
            type = ..4,
            gcp_class = ..5,
            gcp_code = ..6,
            name = ..7,
            breite = ..8,
            leange = ..9,
            alti = ..10,
            alti_acc = ..11,
            geometry = .,
            stringsAsFactors = FALSE)
      ) %>%
      purrr::reduce(rbind)
  }

  if (file_info$type %in% c("RailCL")) {
    res <-
      sf::st_sf(
        gml_id = ids,
        type = extract_xml_value(file_info$xml_docs, name = "type", name_length = 7),
        geometry = fgd_line_parse(file),
        stringsAsFactors = FALSE)
  }

  if (file_info$type %in% c("RdCompt", "RdEdg")) {
    res <-
      sf::st_sf(
        gml_id = ids,
        type = extract_xml_value(file_info$xml_docs, name = "type", name_length = 8),
        adm_office = extract_xml_value(file_info$xml_docs, name = "admOffice", name_length = 8),
        geometry = fgd_line_parse(file),
        stringsAsFactors = FALSE)
  }

  if (file_info$type %in% c("WA", "WL")) {
    xml_parsed <-
      fgd_line_parse(file)
    type <-
      extract_xml_value(file_info$xml_docs, name = "type", name_length = 6)

    if (file_info$type %in% c("WL")) {
      res <-
        sf::st_sf(
          gml_id = ids,
          type = type,
          geometry = xml_parsed,
          stringsAsFactors = FALSE)
    } else if (file_info$type %in% c("WA")) {
      res <-
        sf::st_sf(
          gml_id = ids,
          type = type,
          geometry = xml_parsed,
          stringsAsFactors = FALSE
          ) %>%
        sf::st_polygonize() %>%
        extract_polygon()
    }
  }

  if (file_info$type %in% c("WStrA", "WStrL")) {
    xml_parsed <-
      fgd_line_parse(file)
    type <-
      extract_xml_value(file_info$xml_docs, name = "type", name_length = 7)
    if (file_info$type %in% c("WStrA")) {
      res <-
        sf::st_sf(
          gml_id = ids,
          type = type,
          geometry = xml_parsed,
          stringsAsFactors = FALSE) %>%
        sf::st_polygonize() %>%
        extract_polygon()
    } else if (file_info$type %in% c("WStrL")) {
      res <-
        sf::st_sf(
          gml_id = ids,
          type = type,
          geometry = xml_parsed,
          stringsAsFactors = FALSE)
    }
  }

  elem_vis <-
    file_info$xml_docs %>%
    xml2::xml_find_all("/*/*/*[5]") %>%
    xml2::xml_text()

  res <-
    res %>% purrr::list_modify(
      life_span_from = file_info$xml_docs %>%
        xml2::xml_find_all("/*/*/*[2]/*['timePosition']") %>%
        xml2::xml_text() %>%
        readr::parse_date(),
      development_date = file_info$xml_docs %>%
        xml2::xml_find_all("/*/*/*[3]/*['timePosition']") %>%
        xml2::xml_text() %>%
        readr::parse_date(),
      org_gi_level = extract_xml_value(file_info$xml_docs, name = "orgGILvl"),
      visibility = ifelse(
        elem_vis %in% c(intToUtf8(c(34920, 31034)),
                        intToUtf8(c(38750, 34920, 31034))),
        elem_vis,
        NA_character_)) %>%
    tibble::new_tibble(subclass = "sf", nrow = nrow(res))
  res[, names(res)[!names(res) %in% attr(res, "sf_column")]]
}
