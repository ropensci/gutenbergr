context("Download books")

library(stringr)
suppressPackageStartupMessages(library(dplyr))

test_that("Can download Charles Dickens' Christmas Carol and Jane Austen's Persuasion", {
  books <- gutenberg_download(c(46, 105))

  # should be at least a substantial amount of text in each
  expect_gt(sum(books$gutenberg_id == 46), 3000)
  expect_gt(sum(books$gutenberg_id == 105), 3000)

  # expect many mentions of protagonists Scrooge and Anne
  expect_gt(sum(str_detect(books$text, "Scrooge")), 300)
  expect_gt(sum(str_detect(books$text, "Anne")), 300)

  # expect that Gutenberg is not mentioned: footer and header were stripped
  expect_equal(sum(str_detect(books$text, regex("gutenberg", ignore_case = TRUE))), 0)
})
