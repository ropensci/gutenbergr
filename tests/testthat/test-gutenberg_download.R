test_that("gutenberg_url constructs a url from an id", {
  expect_identical(
    gutenberg_url(c(1, 23, 456), mirror = "base", verbose = FALSE),
    c(
      `1` = "base/0/1/1",
      `23` = "base/2/23/23",
      `456` = "base/4/5/456/456"
    )
  )
})

test_that("flatten_gutenberg_id works", {
  expect_identical(
    flatten_gutenberg_id(c(1, 23, 456)),
    c("1", "23", "456")
  )
  expect_identical(
    flatten_gutenberg_id(data.frame(gutenberg_id = c(1, 23, 456))),
    c("1", "23", "456")
  )
})

test_that("gutenberg_download works", {
  local_dl_and_read()
  test_result <- gutenberg_download(
    c(109, 105),
    meta_fields = c("title", "author"),
    mirror = "http://aleph.gutenberg.org"
  )
  expect_identical(test_result, gutenbergr::sample_books)
})
