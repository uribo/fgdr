context("test-util")

test_that("xml schema validation", {

  expect_warning(
    expect_true(
      xml_validate(x = read_xml("FG-GML-0000-00-00-DEM5A-dummy.xml"),
                         schema = read_xml("FGD_GMLSchema.xsd"))
    )
  )
  expect_warning(
    expect_true(
      xml_validate(x = read_xml("FG-GML-0000-10-dem10b-dummy.xml"),
                         schema = read_xml("FGD_GMLSchema.xsd"))
    )
  )
  expect_warning(
    expect_true(
      xml_validate(x = read_xml("FG-GML-0000-10-dem10b-dummy.xml"),
                         schema = read_xml("FGD_GMLSchema.xsd"))
    )
  )
  suppressWarnings(
    expect_true(
      xml_validate(x = read_xml("FG-GML-000000-AdmPt-dummy.xml"),
                         schema = read_xml("FGD_GMLSchema.xsd"))
    )
  )
})

test_that("dem validation", {
  expect_equal(
      dem_check("FG-GML-0000-00-00-DEM5A-dummy.xml",
                .verbose = TRUE,
                options = "NOBLANKS"),
      c("0", "0"))
  res <-
    fgd_dem_file_info("FG-GML-0000-00-00-DEM5A-dummy.xml")
  expect_is(res, "list")
  expect_length(res, 4)
  expect_named(res, c("xml_docs", "type", "is5m", "meshcode"))
  expect_equal(res$type, "DEM")
  expect_true(res$is5m)
  expect_equal(res$meshcode, "00000000")

  res <-
    fgd_dem_file_info("FG-GML-0000-10-dem10b-dummy.xml")
  expect_is(res, "list")
  expect_length(res, 4)
  expect_named(res, c("xml_docs", "type", "is5m", "meshcode"))
  expect_equal(res$type, "DEM")
  expect_false(res$is5m)
  expect_equal(res$meshcode, "000000")

})

test_that("standard", {
  res <-
    fgd_file_info("FG-GML-000000-AdmPt-dummy.xml")
  expect_is(res, "list")
  expect_length(res, 2)
  expect_named(res, c("xml_docs", "type"))
  expect_equal(res$type, "AdmPt")
})
