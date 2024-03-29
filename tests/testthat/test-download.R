# These tests are currently skipped on CRAN, which has issues connecting
# to Project Gutenberg. See test-mock for tests that are performed without
# connecting to PG.

library(stringr)
suppressPackageStartupMessages(library(dplyr))

test_that("gutenberg_get_mirror works", {
  skip_on_cran()
  m <- gutenberg_get_mirror()

  expect_is(m, "character")

  # expect we can get something from it
  mirror_text <- readr::read_lines(m)
  expect_true(str_detect(mirror_text[1], "<html>"))
})


test_that("Can download Dickens' Christmas Carol & Austen's Persuasion", {
  skip_on_cran()
  books <- gutenberg_download(c(46, 105), meta_fields = c("title", "author"))

  # should be at least a substantial amount of text in each
  expect_gt(sum(books$gutenberg_id == 46), 3000)
  expect_gt(sum(books$gutenberg_id == 105), 3000)

  # should have meta-data about each
  expect_equal(c("gutenberg_id", "text", "title", "author"), colnames(books))
  expect_equal(
    sum(books$gutenberg_id == 46),
    sum(books$author == "Dickens, Charles")
  )
  expect_equal(
    sum(books$gutenberg_id == 105),
    sum(books$author == "Austen, Jane")
  )

  # expect many mentions of protagonists Scrooge and Anne
  expect_gt(sum(str_detect(books$text, "Scrooge")), 300)
  expect_gt(sum(str_detect(books$text, "Anne")), 300)

  # expect that Gutenberg is not mentioned: footer and header were stripped
  expect_equal(
    sum(str_detect(books$text, regex("gutenberg", ignore_case = TRUE))),
    0
  )
})


test_that("Can download books from a data frame with gutenberg_id column", {
  skip_on_cran()
  d <- gutenberg_works(title == "The United States Constitution") %>%
    gutenberg_download()
  expect_true(inherits(d, "data.frame"))
  expect_gt(nrow(d), 10)
  expect_true(all(d$gutenberg_id == 5))
})


test_that("We can download a file that only has a -8 version", {
  skip_on_cran()
  d <- gutenberg_download(8438)
  expect_gt(sum(str_detect(d$text, "Aristotle")), 50)
})


test_that("Trying to download a non-existent book raises a warning", {
  skip_on_cran()
  expect_warning(d <- gutenberg_download(c(5, 1000000)), "Could not download")
  expect_true(inherits(d, "data.frame"))
  expect_true(all(d$gutenberg_id == 5))
})
