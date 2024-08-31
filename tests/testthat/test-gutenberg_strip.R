test_that("gutenberg_strip strips header and footer", {
  to_strip <- readLines(test_path("fixtures", "109-to-strip.txt"))
  test_result <- gutenberg_strip(to_strip)
  expected_result <- c(
    "Renascence and Other Poems",
    "by Edna St. Vincent Millay"
  )
  expect_identical(test_result, expected_result)
})
