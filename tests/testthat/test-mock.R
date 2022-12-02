test_that("Can parse local files", {
  mock_files <- system.file("extdata",
    c("109.zip", "105.zip"),
    package = "gutenbergr"
  )

  books <- gutenberg_download(c(109, 105),
    meta_fields = c("title", "author"),
    mirror = "http://aleph.gutenberg.org",
    files = mock_files
  )

  # should be at least a substantial amount of text in each
  expect_gt(sum(books$gutenberg_id == 109), 1000)
  expect_gt(sum(books$gutenberg_id == 105), 3000)

  # should have meta-data about each
  expect_equal(c("gutenberg_id", "text", "title", "author"), colnames(books))
  expect_equal(
    sum(books$gutenberg_id == 109),
    sum(books$author == "Millay, Edna St. Vincent")
  )
  expect_equal(
    sum(books$gutenberg_id == 105),
    sum(books$author == "Austen, Jane")
  )

  # expect mentions of reindeer and Anne
  expect_gt(sum(str_detect(books$text, "love")), 50)
  expect_gt(sum(str_detect(books$text, "Anne")), 300)

  # expect that Gutenberg is not mentioned: footer and header were stripped
  expect_equal(
    sum(str_detect(books$text, regex("gutenberg", ignore_case = TRUE))),
    0
  )
})
