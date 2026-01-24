test_that("gutenberg_download and gutenberg_add_sections work with single book", {
  skip_if_not_integration()
  skip_on_cran()
  skip_if_offline()

  result <- gutenberg_download(
    2, # US Bill of Rights
    strip = TRUE,
    verbose = FALSE,
    use_cache = FALSE
  ) |>
    gutenberg_add_sections(
      pattern = "^[IVX]+$"
    )

  expect_s3_class(result, "tbl_df")
  expect_named(result, c("gutenberg_id", "text", "section"))
  expect_true(nrow(result) > 0)
  expect_equal(unique(result$gutenberg_id), 2)
  expect_type(result$text, "character")

  all_text <- paste(result$text, collapse = " ")
  expect_true(nchar(all_text) > 100)

  sections <- unique(result$section[!is.na(result$section)])
  expect_equal(length(sections), 10)
})

test_that("gutenberg_download and gutenberg_add_sections work with multiple books and auto-grouping", {
  skip_if_not_integration()
  skip_on_cran()
  skip_if_offline()

  result <- gutenberg_download(
    c(84, 2), # Frankenstein (Letters + Chapters) and Bill of Rights (Articles)
    strip = TRUE,
    verbose = FALSE,
    use_cache = FALSE
  ) |>
    gutenberg_add_sections(
      pattern = "^(Letter \\d+|Chapter \\d+|[IVX]+)$"
    )

  expect_s3_class(result, "tbl_df")
  expect_named(result, c("gutenberg_id", "text", "section"))
  expect_true(nrow(result) > 0)
  expect_setequal(unique(result$gutenberg_id), c(84, 2))

  counts <- table(result$gutenberg_id)
  expect_true(all(counts > 0))

  # Frankenstein has 4 letters + 24 chapters = 28 sections
  frankenstein_section_nrows <- result |>
    dplyr::filter(gutenberg_id == 84, !is.na(section)) |>
    dplyr::distinct(section) |>
    nrow()
  expect_equal(frankenstein_section_nrows, 28)

  # Bill of Rights has 10 articles
  bill_section_nrows <- result |>
    dplyr::filter(gutenberg_id == 2, !is.na(section)) |>
    dplyr::distinct(section) |>
    nrow()
  expect_equal(bill_section_nrows, 10)

  # Count letters and chapters
  frankenstein_sections <- result |>
    dplyr::filter(gutenberg_id == 84, !is.na(section)) |>
    dplyr::pull(section) |>
    unique()

  letter_count <- sum(grepl("^Letter", frankenstein_sections))
  chapter_count <- sum(grepl("^Chapter", frankenstein_sections))
  expect_equal(letter_count, 4)
  expect_equal(chapter_count, 24)
})

test_that("gutenberg_download with meta_fields works with real API", {
  skip_if_not_integration()
  skip_on_cran()
  skip_if_offline()

  result <- gutenberg_download(
    1,
    meta_fields = c("title", "author"),
    strip = TRUE,
    verbose = FALSE,
    use_cache = FALSE
  )

  expect_s3_class(result, "tbl_df")
  expect_true(all(
    c("gutenberg_id", "text", "title", "author") %in% names(result)
  ))
  expect_true(nrow(result) > 0)

  expect_equal(length(unique(result$title)), 1)
  expect_true(!is.na(unique(result$title)))
})

test_that("gutenberg_download strip parameter works with real API", {
  skip_if_not_integration()
  skip_on_cran()
  skip_if_offline()

  result_stripped <- gutenberg_download(
    1,
    strip = TRUE,
    verbose = FALSE,
    use_cache = FALSE
  )

  result_unstripped <- gutenberg_download(
    1,
    strip = FALSE,
    verbose = FALSE,
    use_cache = FALSE
  )

  expect_true(nrow(result_unstripped) > nrow(result_stripped))
  expect_true(nrow(result_stripped) > 0)
  expect_true(nrow(result_unstripped) > 0)
})

test_that("gutenberg_download caching works with real API", {
  skip_if_not_integration()
  skip_on_cran()
  skip_if_offline()

  with_gutenberg_cache({
    # First download - should hit the API
    network_result <- gutenberg_download(
      1,
      strip = TRUE,
      verbose = FALSE,
      use_cache = TRUE
    )

    cache_files <- gutenberg_cache_list(verbose = FALSE)
    expect_true(nrow(cache_files) > 0)
    expect_true(cache_files$file %in% c("1.rds"))

    # Second download - should use cache
    # We can't directly test if it used cache, but we can verify results match
    cache_result <- gutenberg_download(
      1,
      strip = TRUE,
      verbose = FALSE,
      use_cache = TRUE
    )

    expect_identical(network_result, cache_result)
  })
})

test_that("gutenberg_download works with data frame input", {
  skip_if_not_integration()
  skip_on_cran()
  skip_if_offline()

  books_df <- data.frame(gutenberg_id = c(1, 2))

  result <- gutenberg_download(
    books_df,
    strip = TRUE,
    verbose = FALSE,
    use_cache = FALSE
  )

  expect_s3_class(result, "tbl_df")
  expect_true(nrow(result) > 0)
  expect_setequal(unique(result$gutenberg_id), c(1, 2))
})
