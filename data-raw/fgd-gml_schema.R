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
