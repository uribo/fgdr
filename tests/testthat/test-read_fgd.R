context("test-read_fgd")

test_that("Successd on dummies", {
  res <-
    read_fgd(file = "FG-GML-000000-AdmPt-dummy.xml")
  expect_s3_class(res, "sf")
  expect_equal(dim(res), c(1, 3))
  expect_named(res, c("gml_id", "adm_name", "geometry"))
})
