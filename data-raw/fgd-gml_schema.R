#####################################
# XML Schema
# http://www.data.go.jp/data/en/dataset/mlit_20140919_3102/resource/d348b555-b57f-4e1f-ae0c-51d1d028e378
#####################################
if (dir.exists("data-raw") == FALSE)
  dir.create("data-raw")

dl_url <-
  "https://fgd.gsi.go.jp/otherdata/spec/FGD_GMLSchemaV4.1.zip"

dl_file <-
  paste0("data-raw/", basename(dl_url))

path2xsd <-
  "data-raw/FGD_GMLSchemaV4.1/FGD_GMLSchema.xsd"

if (file.exists(path2xsd) == FALSE) {

  curl::curl_download(
    url = dl_url,
    destfile = dl_file
  )

  unzip(dl_file, exdir = "data-raw")
  unlink(dl_file)
}

# Modify xsd --------------------------------------------------------------
if (file.exists("test/testthat/FGD_GMLSchema.xsd") == FALSE) {
  str <- readLines(path2xsd)

  str <- sub('xmlns="http://fgd.gsi.go.jp/spec/2008/FGD_GMLSchema"',
             'xmlns:default="http://fgd.gsi.go.jp/spec/2008/FGD_GMLSchema"', str)

  cat(paste(str, collapse = "\n"),
      file = paste0("test/testthat/", basename(path2xsd)),
      append = FALSE)
}

# Create dummy XML --------------------------------------------------------
set.seed(123)
library(xml2)
library(magrittr)
library(zeallot)

# 1/2 DEM -------------------------------------------------------------
c(str_dummry_dem5, str_dummry_dem10) %<-%
  purrr::map(
    c("data-raw/FG-GML-5135-63-DEM5A/FG-GML-5135-63-00-DEM5A-20161001.xml",
      "data-raw/FG-GML-5440-10-dem10b-20161001.xml"),
    ~ sub('xmlns="http://fgd.gsi.go.jp/spec/2008/FGD_GMLSchema"',
          'xmlns:default="http://fgd.gsi.go.jp/spec/2008/FGD_GMLSchema"',
          readLines(.x))
  )

dem_types <-
  c("データなし", "内水面", "地表面", "海水面", "その他")

# 10m ---------------------------------------------------------------------
docs_dem10 <-
  read_xml(paste0(str_dummry_dem10, collapse = "\n"), options = "HUGE")

docs_dem10 %>%
  xml_find_first("/*/gml:description") %>%
  xml_set_text("基盤地図情報メタデータ ID=dummy:00-00")

docs_dem10 %>%
  xml_find_first("/*/gml:name") %>%
  xml_set_text("基盤地図情報ダウンロードデータ（GML版dummy）")

docs_dem10 %>%
  xml_find_first("/Dataset/DEM/fid") %>%
  xml_set_text("fgoid:00-00000-0-0-00000")

docs_dem10 %>%
  xml_find_first("/Dataset/DEM/lfSpanFr/gml:timePosition") %>%
  xml_set_text("2018-12-01")

docs_dem10 %>%
  xml_find_first("/Dataset/*/devDate/gml:timePosition") %>%
  xml_set_text("2018-12-01")

docs_dem10 %>%
  xml_find_first("/Dataset/DEM/orgMDId") %>%
  xml_set_text("Dummy")

# 共通...
# xml_find_first("/*/gml:name")
# xml_find_first("/Dataset/DEM/lfSpanFr/gml:timePosition")
# xml_find_first("/Dataset/*/devDate/gml:timePosition")
# xml_find_first("/Dataset/DEM/orgMDId")
# xml_find_first("/Dataset/DEM/coverage/gml:boundedBy/gml:Envelope/gml:lowerCorner")
# xml_find_first("/Dataset/DEM/coverage/gml:boundedBy/gml:Envelope/gml:upperCorner")

docs_dem10 %>%
  xml_find_first("/Dataset/DEM/mesh") %>%
  xml_set_text("000000")

docs_dem10 %>%
  xml_find_first("/Dataset/DEM/coverage/gml:boundedBy/gml:Envelope/gml:lowerCorner") %>%
  xml_set_text("0.0 0.000")
docs_dem10 %>%
  xml_find_first("/Dataset/DEM/coverage/gml:boundedBy/gml:Envelope/gml:upperCorner") %>%
  xml_set_text("0.0 0.000")

docs_dem10 %>%
  xml2::xml_find_all("/*/*/*/gml:rangeSet/gml:DataBlock/gml:tupleList") %>%
  xml_set_text(
    paste0(
      "\n",
      paste(
        # error when size = 843750
        sample(dem_types, size = 10, replace = TRUE),
        "-9999.",
        sep = ",",
        collapse = "\n"
      ),
      "\n"
    )
  )

docs_dem10 %>%
  xml_find_all("/Dataset/DEM/coverage/gml:coverageFunction/gml:GridFunction/gml:startPoint") %>%
  xml_set_text("0 0")

cat(paste(as.character(docs_dem10), collapse = "\n"),
    file = paste0("test/testthat/", "FG-GML-0000-10-dem10b-dummy.xml"),
    append = FALSE)


# 5m ----------------------------------------------------------------------
docs <-
  read_xml(paste0(str_dummry_dem5, collapse = "\n"))

docs %>%
  xml_find_first("/*/gml:description") %>%
  xml_set_text("基盤地図情報メタデータ ID=dummy:00-0000")

docs %>%
  xml_find_first("/*/gml:name") %>%
  xml_set_text("基盤地図情報ダウンロードデータ（GML版dummy）")

docs %>%
  xml_find_first("/Dataset/DEM/fid") %>%
  xml_set_text("fgoid:00-00000-00-00000-00000000")

docs %>%
  xml_find_first("/Dataset/DEM/lfSpanFr/gml:timePosition") %>%
  xml_set_text("2018-12-01")

docs %>%
  xml_find_first("/Dataset/*/devDate/gml:timePosition") %>%
  xml_set_text("2018-12-01")

docs %>%
  xml_find_first("/Dataset/DEM/orgMDId") %>%
  xml_set_text("Dummy")

docs %>%
  xml_find_first("/Dataset/DEM/mesh") %>%
  xml_set_text("00000000")

docs %>%
  xml_find_first("/Dataset/DEM/coverage/gml:boundedBy/gml:Envelope/gml:lowerCorner") %>%
  xml_set_text("0.0 0.000")
docs %>%
  xml_find_first("/Dataset/DEM/coverage/gml:boundedBy/gml:Envelope/gml:upperCorner") %>%
  xml_set_text("0.0 0.000")

docs %>%
  xml_find_first("/Dataset/DEM/coverage/gml:rangeSet/gml:DataBlock/gml:tupleList") %>%
  xml_set_text(
    paste0(
      "\n",
      paste(
        # size = 33750
        sample(dem_types, size = 10, replace = TRUE),
        "-9999.",
        sep = ",",
        collapse = "\n"
      ),
      "\n"
    )
  )

docs %>%
  xml_find_all("/Dataset/DEM/coverage/gml:coverageFunction/gml:GridFunction/gml:startPoint") %>%
  xml_set_text("0 0")

cat(paste(as.character(docs), collapse = "\n"),
    file = paste0("test/testthat/", "FG-GML-0000-00-00-DEM5A-dummy.xml"),
    append = FALSE)

# 2/2 Standard ---------------------------------------------------------------------
c(str_dummry) %<-%
  purrr::map(
    c("data-raw/PackDLMap/FG-GML-523345-ALL-20180701/FG-GML-523345-AdmPt-20180701-0001.xml"),
    ~ sub('xmlns="http://fgd.gsi.go.jp/spec/2008/FGD_GMLSchema"',
          'xmlns:default="http://fgd.gsi.go.jp/spec/2008/FGD_GMLSchema"',
          readLines(.x))
  )

docs <-
  read_xml(paste0(str_dummry, collapse = "\n"))

docs %>%
  xml_find_first("/*/gml:description") %>%
  xml_set_text("基盤地図情報メタデータ ID=dummy:00-0000")

docs %>%
  xml_find_first("/*/gml:name") %>%
  xml_set_text("基盤地図情報ダウンロードデータ（GML版dummy）")

docs %>%
  xml_find_first("/*/AdmPt") %>%
  xml_set_attrs(c("gml:id" = "K6_0000000000_1"))

docs %>%
  xml_find_first("/*/AdmPt/fid") %>%
  xml_set_text("00000-00000-i-00")

docs %>%
  xml_find_first("/*/AdmPt/lfSpanFr") %>%
  xml_set_attrs(c("gml:id" = "K6_0000000000_1-1"))

docs %>%
  xml_find_first("/Dataset/*/lfSpanFr/gml:timePosition") %>%
  xml_set_text("2018-12-01")

docs %>%
  xml_find_first("/*/AdmPt/devDate") %>%
  xml_set_attrs(c("gml:id" = "K6_0000000000_1-2"))

docs %>%
  xml_find_first("/Dataset/*/devDate/gml:timePosition") %>%
  xml_set_text("2018-12-01")

docs %>%
  xml_find_first("/Dataset/AdmPt/pos/gml:Point") %>%
  xml_set_attrs(c("gml:id" = "K6_0000000000_1",
                  "srsName" = "fguuid:jgd2011.bl"))

docs %>%
  xml_find_first("/Dataset/AdmPt/pos/gml:Point") %>%
  xml_set_text("36.1035 140.0850")

docs %>%
  xml_find_first("/Dataset/AdmPt/name") %>%
  xml_set_text("dummy")

docs %>%
  xml_find_first("/Dataset/AdmPt/admCode") %>%
  xml_set_text("00000")

cat(paste(as.character(docs), collapse = "\n"),
    file = paste0("test/testthat/", "FG-GML-000000-AdmPt-dummy.xml"),
    append = FALSE)

