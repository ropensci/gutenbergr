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

test_that("gutenberg_metadata has the expected shape", {
  expect_s3_class(gutenberg_metadata, c("tbl_df", "tbl", "data.frame"))
  expect_named(
    gutenberg_metadata,
    c(
      "gutenberg_id",
      "title",
      "author",
      "gutenberg_author_id",
      "language",
      "gutenberg_bookshelf",
      "rights",
      "has_text"
    )
  )
  expect_gte(nrow(gutenberg_metadata), 79491)
})

test_that("gutenberg_subjects has the expected shape", {
  expect_s3_class(gutenberg_subjects, c("tbl_df", "tbl", "data.frame"))
  expect_named(
    gutenberg_subjects,
    c("gutenberg_id", "subject_type", "subject")
  )
  expect_gte(nrow(gutenberg_subjects), 255000)
})

test_that("gutenberg_authors has the expected shape", {
  expect_s3_class(gutenberg_authors, c("tbl_df", "tbl", "data.frame"))
  expect_named(
    gutenberg_authors,
    c(
      "gutenberg_author_id",
      "author",
      "alias",
      "birthdate",
      "deathdate",
      "wikipedia",
      "aliases"
    )
  )
  expect_gte(nrow(gutenberg_authors), 26000)
})

test_that("gutenberg_languages has the expected shape", {
  expect_s3_class(gutenberg_languages, c("tbl_df", "tbl", "data.frame"))
  expect_named(
    gutenberg_languages,
    c("gutenberg_id", "language", "total_languages")
  )
  expect_gte(nrow(gutenberg_languages), 76000)
})
