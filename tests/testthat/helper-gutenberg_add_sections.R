expect_section_fill <- function(result, rows, value) {
  expect_equal(
    result$section[rows],
    rep(value, length(rows))
  )
}
