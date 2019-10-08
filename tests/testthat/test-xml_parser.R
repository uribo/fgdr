context("test-xml_parser")

test_that("multiplication works", {
  expect_error(
    fgd_line_parse(
      system.file("extdata/FG-GML-000000-AdmPt-dummy.xml",
                  package = "fgdr")))
  res <-
    fgd_point_parse(
      system.file("extdata/FG-GML-000000-AdmPt-dummy.xml",
                  package = "fgdr"))
  expect_is(res, "list")
  expect_length(res, 1L)
})
