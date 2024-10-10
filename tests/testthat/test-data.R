test_that("All four datasets have a date-updated", {
  d1 <- attr(gutenberg_metadata, "date_updated")
  d2 <- attr(gutenberg_subjects, "date_updated")
  d3 <- attr(gutenberg_authors, "date_updated")
  d4 <- attr(gutenberg_languages, "date_updated")

  expect_s3_class(d1, "Date")
  expect_s3_class(d2, "Date")
  expect_s3_class(d3, "Date")
  expect_s3_class(d4, "Date")
})
