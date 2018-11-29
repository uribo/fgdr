#' Read and Parse FDG's XML file
#'
#' @param file Path to XML file
#' @import sf
#' @import xml2
#' @importFrom purrr pmap
read_fdg <- function(file) {

  . <- NULL

  file_info <-
    fdg_file_info(file)

  ids <-
    file_info$xml_docs %>%
    xml2::xml_find_all("/*/*/*[3]") %>%
    xml2::xml_attr("id")

  if (file_info$type %in% c("Cntr")) {

    xml_parsed <-
      fdg_line_parse(file)

    type <-
      file_info$xml_docs %>%
      xml2::xml_find_all("/*/*/*[6]") %>%
      xml2::xml_contents() %>%
      as.character()

    alti <-
      file_info$xml_docs %>%
      xml2::xml_find_all("/*/*/*[7]") %>%
      xml2::xml_contents() %>%
      as.character() %>%
      as.numeric()

    res <-
      list(xml_parsed, ids, type, alti) %>%
      purrr::pmap(
        ~ sf::st_linestring(matrix(unlist(..1),
                                   ncol = 2,
                                   byrow = TRUE)) %>%
          sf::st_sfc(crs = 4326) %>%
          sf::st_sf(
            gml_id = ..2,
            type = ..3,
            alti = ..4,
            geometry = .
          )
      )

  }

  if (file_info$type %in% c("ElevPt")) {

    xml_parsed <-
      fdg_point_parse(file)

    type <-
      file_info$xml_docs %>%
      xml2::xml_find_all("/*/*/*[7]") %>%
      xml2::xml_contents() %>%
      as.character()

    alti <-
      file_info$xml_docs %>%
      xml2::xml_find_all("/*/*/*[8]") %>%
      xml2::xml_contents() %>%
      as.character() %>%
      as.numeric()

    res <-
      list(xml_parsed, ids, type, alti) %>%
      purrr::pmap(
        ~ sf::st_point(matrix(unlist(..1),
                              ncol = 2,
                              byrow = TRUE)) %>%
          sf::st_sfc(crs = 4326) %>%
          sf::st_sf(
            gml_id = ..2,
            type = ..3,
            alti = ..4,
            geometry = .
          )
      ) %>%
      purrr::reduce(rbind)

  }

  if (file_info$type %in% c("CommBdry")) {
    xml_parsed <-
      fdg_line_parse(file)

    bdry_type <-
      file_info$xml_docs %>%
      xml2::xml_find_all("/*/*/*[7]") %>%
      xml2::xml_contents() %>%
      as.character()

    res <-
      list(xml_parsed, ids, bdry_type) %>%
      purrr::pmap(
        ~ sf::st_linestring(matrix(unlist(..1),
                                   ncol = 2,
                                   byrow = TRUE)) %>%
          sf::st_sfc(crs = 4326) %>%
          sf::st_sf(
            gml_id = ..2,
            bdry_type = ..3,
            geometry = .
          )
      ) %>%
      purrr::reduce(rbind)
  }

  if (file_info$type %in% c("CommPt")) {

    xml_parsed <-
      fdg_point_parse(file)

    type <-
      file_info$xml_docs %>%
      xml2::xml_find_all("/*/*/*[7]") %>%
      xml2::xml_contents() %>%
      as.character()

    nms <-
      file_info$xml_docs %>%
      xml2::xml_find_all("/*/*/*[8]") %>%
      xml2::xml_text()

    res <-
      list(xml_parsed, ids, nms, type) %>%
      purrr::pmap(
        ~ sf::st_point(matrix(unlist(..1),
                              ncol = 2,
                              byrow = TRUE)) %>%
          sf::st_sfc(crs = 4326) %>%
          sf::st_sf(
            gml_id = ..2,
            comm_name = ..3,
            comm_type = ..4,
            geometry = .
          )
      ) %>%
      purrr::reduce(rbind)

  }

  if (file_info$type %in% c("AdmBdry")) {

    xml_parsed <-
      fdg_line_parse(file)

    type <-
      file_info$xml_docs %>%
      xml2::xml_find_all("/*/*/*[7]") %>%
      xml2::xml_contents() %>%
      as.character()

    res <-
      list(xml_parsed, ids, type) %>%
      purrr::pmap(
        ~ sf::st_linestring(matrix(unlist(..1),
                              ncol = 2,
                              byrow = TRUE)) %>%
          sf::st_sfc(crs = 4326) %>%
          sf::st_sf(
            gml_id = ..2,
            type = ..3,
            geometry = .
          )
      ) %>%
      purrr::reduce(rbind)

  }

  if (file_info$type %in% c("AdmArea", "AdmPt")) {
    nms <-
      file_info$xml_docs %>%
      xml2::xml_find_all("/*/*/*[8]") %>%
      xml2::xml_text()

    if (file_info$type %in% c("AdmArea")) {

      xml_parsed <-
        fdg_line_parse(file)

      res <-
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
            ) %>%
            sf::st_polygonize() %>%
            sf::st_collection_extract("POLYGON")
        ) %>%
        purrr::reduce(rbind)
    }

    if (file_info$type %in% c("AdmPt")) {

      xml_parsed <-
        fdg_point_parse(file)

      res <-
        xml_parsed %>%
        purrr::map(st_point) %>%
        sf::st_sfc(crs = 4326) %>%
        sf::st_sf(
          gml_id = ids,
          adm_name = nms,
          geometry = .
        )

    }
  }

  if (file_info$type %in% c("BldA", "BldL")) {

    bld_type <-
      file_info$xml_docs %>%
      xml2::xml_find_all("/*/*/*[6]") %>%
      xml2::xml_contents() %>%
      as.character()

    xml_parsed <-
      fdg_line_parse(file)

      if (file_info$type == "BldA") {

        res <-
          list(xml_parsed, ids, bld_type) %>%
          purrr::pmap(
            ~ sf::st_linestring(matrix(unlist(..1),
                                       ncol = 2,
                                       byrow = TRUE)) %>%
              sf::st_sfc(crs = 4326) %>%
              sf::st_sf(
                gml_id = ..2,
                bld_type = ..3,
                geometry = .
              ) %>%
              sf::st_polygonize() %>%
              sf::st_collection_extract("POLYGON"))

        if (length(res) >= 10000) {
          rlang::inform("There are over 10,000 elements. Because there are many cases, will be return it as a list.")
        } else {
          res <-
            res %>%
            purrr::reduce(rbind)
        }
      }

    if (file_info$type == "BldL") {

        res <-
          list(xml_parsed, ids, bld_type) %>%
          purrr::pmap(
            ~ sf::st_linestring(matrix(unlist(..1),
                                       ncol = 2,
                                       byrow = TRUE)) %>%
              sf::st_sfc(crs = 4326) %>%
              sf::st_sf(
                gml_id = ..2,
                bld_type = ..3,
                geometry = .
              )
          )

      }
  }

  if (file_info$type %in% c("GCP")) {

    xml_parsed <-
      fdg_point_parse(file)

    org_name <-
      file_info$xml_docs %>%
      xml2::xml_find_all("/*/*/*[7]") %>%
      xml2::xml_contents() %>%
      as.character()

    type <-
      file_info$xml_docs %>%
      xml2::xml_find_all("/*/*/*[8]") %>%
      xml2::xml_contents() %>%
      as.character()

    gcp_class <-
      file_info$xml_docs %>%
      xml2::xml_find_all("/*/*/*[9]") %>%
      xml2::xml_contents() %>%
      as.character()

    gcp_code <-
      file_info$xml_docs %>%
      xml2::xml_find_all("/*/*/*[10]") %>%
      xml2::xml_contents() %>%
      as.character()

    nms <-
      file_info$xml_docs %>%
      xml2::xml_find_all("/*/*/*[11]") %>%
      xml2::xml_contents() %>%
      as.character()

    breite <-
      file_info$xml_docs %>%
      xml2::xml_find_all("/*/*/*[12]") %>%
      xml2::xml_contents() %>%
      as.character() %>%
      as.double()

    leange <-
      file_info$xml_docs %>%
      xml2::xml_find_all("/*/*/*[13]") %>%
      xml2::xml_contents() %>%
      as.character() %>%
      as.double()

    alti <-
      file_info$xml_docs %>%
      xml2::xml_find_all("/*/*/*[14]") %>%
      xml2::xml_contents() %>%
      as.character() %>%
      as.double()

    alti_acc <-
      file_info$xml_docs %>%
      xml2::xml_find_all("/*/*/*[15]") %>%
      xml2::xml_contents() %>%
      as.character() %>%
      as.integer()

    res <-
      list(xml_parsed, ids, org_name, type,
           gcp_class, gcp_code, nms, breite, leange, alti, alti_acc) %>%
      purrr::pmap(
        ~ sf::st_point(matrix(unlist(..1),
                              ncol = 2,
                              byrow = TRUE)) %>%
          sf::st_sfc(crs = 4326) %>%
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
            geometry = .
          )
      ) %>%
      purrr::reduce(rbind)
  }

  if (file_info$type %in% c("RailCL")) {

    xml_parsed <-
      fdg_line_parse(file)

    type <-
      file_info$xml_docs %>%
      xml2::xml_find_all("/*/*/*[7]") %>%
      xml2::xml_contents() %>%
      as.character()

    res <-
      list(xml_parsed, ids, type) %>%
      purrr::pmap(
        ~ sf::st_linestring(matrix(unlist(..1),
                                   ncol = 2,
                                   byrow = TRUE)) %>%
          sf::st_sfc(crs = 4326) %>%
          sf::st_sf(
            gml_id = ..2,
            type = ..3,
            geometry = .
          )
      ) %>%
      purrr::reduce(rbind)

  }

  if (file_info$type %in% c("RdCompt", "RdEdg")) {

    xml_parsed <-
      fdg_line_parse(file)

    type <-
      file_info$xml_docs %>%
      xml2::xml_find_all("/*/*/*[7]") %>%
      xml2::xml_contents() %>%
      as.character()

    adm_office <-
      file_info$xml_docs %>%
      xml2::xml_find_all("/*/*/*[8]") %>%
      xml2::xml_contents() %>%
      as.character()

    res <-
      list(xml_parsed, ids, type, adm_office) %>%
      purrr::pmap(
        ~ sf::st_linestring(matrix(unlist(..1),
                                   ncol = 2,
                                   byrow = TRUE)) %>%
          sf::st_sfc(crs = 4326) %>%
          sf::st_sf(
            gml_id = ..2,
            type = ..3,
            adm_office = ..4,
            geometry = .
          )
      )

    if (length(res) >= 10000) {
      rlang::inform("There are over 10,000 elements. Because there are many cases, will be return it as a list.")
    } else {
      res <-
        res %>%
        purrr::reduce(rbind)
    }

  }

  if (file_info$type %in% c("WA", "WL")) {

    xml_parsed <-
      fdg_line_parse(file)

    type <-
      file_info$xml_docs %>%
      xml2::xml_find_all("/*/*/*[6]") %>%
      xml2::xml_contents() %>%
      as.character()

    res <-
      list(xml_parsed, ids, type) %>%
      purrr::pmap(
        ~ sf::st_linestring(matrix(unlist(..1),
                                   ncol = 2,
                                   byrow = TRUE)) %>%
          sf::st_sfc(crs = 4326) %>%
          sf::st_sf(
            gml_id = ..2,
            type = ..3,
            geometry = .
          )
      )
  }

  if (file_info$type %in% c("WStrA")) {

    xml_parsed <-
      fdg_line_parse(file)

    type <-
      file_info$xml_docs %>%
      xml2::xml_find_all("/*/*/*[7]") %>%
      xml2::xml_contents() %>%
      as.character()

    res <-
      list(xml_parsed, ids, type) %>%
      purrr::pmap(
        ~ sf::st_linestring(matrix(unlist(..1),
                                   ncol = 2,
                                   byrow = TRUE)) %>%
          sf::st_sfc(crs = 4326) %>%
          sf::st_sf(
            gml_id = ..2,
            type = ..3,
            geometry = .
          )
      ) %>%
      purrr::reduce(rbind)
  }

  res
}
