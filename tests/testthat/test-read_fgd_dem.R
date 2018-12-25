context("test-read_fgd_dem")

test_that("Successed on dummies", {

  res <-
    read_fgd_dem(file = "FG-GML-0000-00-00-DEM5A-dummy.xml",
                 resolution = 5)
  expect_is(res, "data.frame")
  expect_s3_class(res, "tbl_df")
  expect_equal(dim(res), c(33750, 2))
  expect_named(res, c("type", "value"))

  res <-
    read_fgd_dem("FG-GML-0000-00-00-DEM5A-dummy.xml",
                 resolution = 5,
                 return_class = "raster")
  expect_s4_class(res, "RasterLayer")
  expect_equal(unique(raster::getValues(res)), c(-9999L, NA_real_))

  res <-
    read_fgd_dem("FG-GML-0000-10-dem10b-dummy.xml",
                 resolution = 10)
  expect_is(res, "data.frame")
  expect_s3_class(res, "tbl_df")
  expect_equal(dim(res), c(843750, 2))
  expect_named(res, c("type", "value"))
  expect_equal(unique(res$value), c(-9999L, NA_real_))

})
