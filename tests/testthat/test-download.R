context("Download books")

library(stringr)
suppressPackageStartupMessages(library(dplyr))

test_that("Can download Charles Dickens' Christmas Carol and Jane Austen's Persuasion", {
  books <- gutenberg_download(c(46, 105), meta_fields = c("title", "author"))

  # should be at least a substantial amount of text in each
  expect_gt(sum(books$gutenberg_id == 46), 3000)
  expect_gt(sum(books$gutenberg_id == 105), 3000)

  # should have meta-data about each
  expect_equal(c("gutenberg_id", "text", "title", "author"), colnames(books))
  expect_equal(sum(books$gutenberg_id == 46), sum(books$author == "Dickens, Charles"))
  expect_equal(sum(books$gutenberg_id == 105), sum(books$author == "Austen, Jane"))

  # expect many mentions of protagonists Scrooge and Anne
  expect_gt(sum(str_detect(books$text, "Scrooge")), 300)
  expect_gt(sum(str_detect(books$text, "Anne")), 300)

  # expect that Gutenberg is not mentioned: footer and header were stripped
  expect_equal(sum(str_detect(books$text, regex("gutenberg", ignore_case = TRUE))), 0)
})
