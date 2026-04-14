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
  with_gutenberg_cache({
    test_result <- gutenberg_download(
      c(109, 105),
      meta_fields = c("title", "author"),
      mirror = "http://aleph.gutenberg.org"
    )
  })
  expect_identical(test_result, gutenbergr::sample_books)
})

test_that("try_gutenberg_download errors informatively with no return", {
  local_mocked_bindings(
    read_next = function(url) {
      return(NULL)
    }
  )
  expect_warning(
    try_gutenberg_download("https://example.com"),
    class = "gutenbergr-warning-download_failure"
  )
})

test_that("gutenberg_download actually caches a file", {
  with_gutenberg_cache({
    mock_mirror_logic(gutenberg_mirror_opt = "http://mock-mirror.com")

    testthat::local_mocked_bindings(
      try_gutenberg_download = function(url) c("Line 1", "Line 2"),
      gutenberg_add_metadata = function(tbl, ...) tbl,
      .package = "gutenbergr"
    )

    gutenberg_download(109, use_cache = TRUE, strip = FALSE)

    cache_path <- gutenberg_cache_dir()
    expect_true(file.exists(file.path(cache_path, "109.rds")))
    expect_equal(nrow(gutenberg_cache_list(verbose = FALSE)), 1)
  })
})

test_that("gutenberg_tidy_metadata returns one row per gutenberg_id", {
  test_meta <- tibble::tibble(
    gutenberg_id = c(1, 1, 2),
    title = c("Book A", "Book A", "Book B"),
    author = c("Author 1", "Author 2", "Author 3")
  )

  out <- gutenberg_tidy_metadata(test_meta, c("title", "author"))

  # ID 1 should be squashed into a single row
  expect_equal(nrow(out), 2)
  expect_equal(sum(out$gutenberg_id == 1), 1)
})

test_that("gutenberg_tidy_metadata collapses multiple authors with separator", {
  test_meta <- tibble::tibble(
    gutenberg_id = 1,
    author = c("Gilbert, W. S.", "Sullivan, Arthur")
  )

  out <- gutenberg_tidy_metadata(test_meta, "author", sep = " & ")
  expect_equal(out$author, "Gilbert, W. S. & Sullivan, Arthur")

  out_alt <- gutenberg_tidy_metadata(test_meta, "author", sep = " | ")
  expect_equal(out_alt$author, "Gilbert, W. S. | Sullivan, Arthur")
})

test_that("gutenberg_tidy_metadata handles NAs and unique values", {
  test_meta <- tibble::tibble(
    gutenberg_id = c(1, 1, 2),
    title = c("Same", "Same", "Different"),
    author = c("Author A", NA, NA)
  )

  out <- gutenberg_tidy_metadata(test_meta, c("title", "author"))

  # Unique should prevent "Same & Same"
  expect_equal(out$title[out$gutenberg_id == 1], "Same")

  # NA should be ignored in the join for ID 1
  expect_equal(out$author[out$gutenberg_id == 1], "Author A")

  # If all are NA, should return a true NA_character_
  expect_true(is.na(out$author[out$gutenberg_id == 2]))
  expect_type(out$author, "character")
})

test_that("gutenberg_tidy_metadata handles empty or specific field requests", {
  test_meta <- tibble::tibble(
    gutenberg_id = 1,
    title = "Title",
    author = "Author"
  )

  # Should return NULL for empty fields
  expect_null(gutenberg_tidy_metadata(test_meta, character()))

  # Should only include requested columns
  out <- gutenberg_tidy_metadata(test_meta, "title")
  expect_named(out, c("gutenberg_id", "title"))
  expect_false("author" %in% names(out))
})

test_that("gutenberg_tidy_metadata handles literal duplicates in source metadata", {
  # Sometimes Gutenberg metadata has two identical rows for the same work
  test_meta <- tibble::tibble(
    gutenberg_id = c(1, 1),
    title = c("Redundant", "Redundant")
  )

  out <- gutenberg_tidy_metadata(test_meta, "title")
  expect_equal(nrow(out), 1)
  expect_equal(out$title, "Redundant")
})
