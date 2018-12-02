context("test-xml_parser")

test_that("multiplication works", {

  expect_error(
    fgd_line_parse("FG-GML-000000-AdmPt-dummy.xml")
  )
  res <-
    fgd_point_parse("FG-GML-000000-AdmPt-dummy.xml")
  expect_is(res, "list")
  expect_length(res, 1L)
})
