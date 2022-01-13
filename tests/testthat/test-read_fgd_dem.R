context("test-read_fgd_dem")

test_that("Successed on dummies", {
  res_df <-
    read_fgd_dem(file = system.file("extdata/FG-GML-0000-00-00-DEM5A-dummy.xml",
                                    package = "fgdr"),
                 resolution = 5,
                 return_class = "data.frame")
  expect_is(res_df, "data.frame")
  expect_identical(as.character(res_df[1, 1]),
                   paste(intToUtf8(c(12381, 12398, 20182), multiple = TRUE), collapse = ""))
  expect_s3_class(res_df, "tbl_df")
  expect_equal(dim(res_df), c(33750, 2))
  expect_named(res_df, c("type", "value"))
  res_dt <-
    read_fgd_dem(file = system.file("extdata/FG-GML-0000-00-00-DEM5A-dummy.xml",
                                    package = "fgdr"),
                 resolution = 5,
                 return_class = "data.table")
  expect_is(res_dt, "data.table")
  expect_equal(dim(res_dt), dim(res_df))
  expect_identical(
    lapply(res_dt$type, utf8ToInt),
    lapply(res_df$type, utf8ToInt))

  res <-
    read_fgd_dem(system.file("extdata/FG-GML-0000-00-00-DEM5A-dummy.xml",
                             package = "fgdr"),
                 resolution = 5,
                 return_class = "raster")
  expect_s4_class(res, "RasterLayer")
  expect_equal(unique(raster::getValues(res)), c(-9999L, NA_real_))

  res <-
    read_fgd_dem(system.file("extdata/FG-GML-0000-10-dem10b-dummy.xml",
                             package = "fgdr"),
                 resolution = 10,
                 return_class = "data.frame")
  expect_is(res, "data.frame")
  expect_s3_class(res, "tbl_df")
  expect_equal(dim(res), c(843750, 2))
  expect_named(res, c("type", "value"))
  expect_equal(
    units::drop_units(unique(res$value)),
    c(-9999L, NA_real_))
  res_stars <-
    read_fgd_dem(system.file("extdata/FG-GML-0000-10-dem10b-dummy.xml",
                             package = "fgdr"),
                 resolution = 10,
                 return_class = "stars")
  expect_s3_class(res_stars, "stars")
  expect_equal(c(res_stars$layer),
               units::drop_units(res$value))
  res_raster <-
    read_fgd_dem(system.file("extdata/FG-GML-0000-10-dem10b-dummy.xml",
                             package = "fgdr"),
                 resolution = 10,
                 return_class = "raster")
  expect_s4_class(res_raster, "RasterLayer")
  expect_equal(raster::values(res_raster),
               units::drop_units(res$value))
  res_terra <-
    read_fgd_dem(system.file("extdata/FG-GML-0000-10-dem10b-dummy.xml",
                             package = "fgdr"),
                 resolution = 10,
                 return_class = "terra")
  expect_s4_class(res_terra, "SpatRaster")
  expect_equal(c(terra::values(res_terra)),
               units::drop_units(res$value))
})
