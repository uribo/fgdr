context("test-util")

test_that("xml schema validation", {
  expect_warning(expect_true(xml_validate(
    x = read_xml(
      system.file("extdata/FG-GML-0000-00-00-DEM5A-dummy.xml",
                  package = "fgdr")
    ),
    schema = read_xml(system.file("extdata/FGD_GMLSchema.xsd",
                                  package = "fgdr"))
  )))
  expect_warning(expect_true(xml_validate(
    x = read_xml(
      system.file("extdata/FG-GML-0000-10-dem10b-dummy.xml",
                  package = "fgdr")
    ),
    schema = read_xml(system.file("extdata/FGD_GMLSchema.xsd",
                                  package = "fgdr"))
  )))
  expect_warning(expect_true(xml_validate(
    x = read_xml(
      system.file("extdata/FG-GML-0000-10-dem10b-dummy.xml",
                  package = "fgdr")
    ),
    schema = read_xml(system.file("extdata/FGD_GMLSchema.xsd",
                                  package = "fgdr"))
  )))
  suppressWarnings(expect_true(xml_validate(
    x = read_xml(
      system.file("extdata/FG-GML-000000-AdmPt-dummy.xml",
                  package = "fgdr")
    ),
    schema = read_xml(system.file("extdata/FGD_GMLSchema.xsd",
                                  package = "fgdr"))
  )))
})

test_that("dem validation", {
  expect_equal(dem_check(
    system.file("extdata/FG-GML-0000-00-00-DEM5A-dummy.xml",
                package = "fgdr"),
    .verbose = TRUE,
    options = "NOBLANKS"
  ),
  c(0L, 0L))
  res <-
    fgd_dem_file_info(system.file("extdata/FG-GML-0000-00-00-DEM5A-dummy.xml",
                                  package = "fgdr"))
  expect_is(res, "list")
  expect_length(res, 4)
  expect_named(res, c("xml_docs", "type", "is5m", "meshcode"))
  expect_equal(res$type, "DEM")
  expect_true(res$is5m)
  expect_equal(res$meshcode, "54400098")
  res <-
    fgd_dem_file_info(system.file("extdata/FG-GML-0000-10-dem10b-dummy.xml",
                                  package = "fgdr"))
  expect_is(res, "list")
  expect_length(res, 4)
  expect_named(res, c("xml_docs", "type", "is5m", "meshcode"))
  expect_equal(res$type, "DEM")
  expect_false(res$is5m)
  expect_equal(res$meshcode, "544000")
})

test_that("standard", {
  res <-
    fgd_file_info(system.file("extdata/FG-GML-000000-AdmPt-dummy.xml",
                              package = "fgdr"))
  expect_is(res, "list")
  expect_length(res, 2)
  expect_named(res, c("xml_docs", "type"))
  expect_equal(res$type, "AdmPt")
})
