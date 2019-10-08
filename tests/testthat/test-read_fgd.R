context("test-read_fgd")

test_that("Successd on dummies", {
  res <-
    read_fgd(file = system.file("extdata/FG-GML-000000-AdmPt-dummy.xml",
                                package = "fgdr"))
  expect_s3_class(res, "sf")
  expect_equal(dim(res), c(1, 9))
  expect_named(res, c("gml_id", "type", "name", "adm_code",
                      "life_span_from", "development_date",
                      "org_gi_level", "visibility", "geometry"))
})
