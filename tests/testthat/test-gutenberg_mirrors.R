test_that("gutenberg_get_mirror works with no option set", {
  local_dl_and_read()
  withr::local_options(gutenberg_mirror = NULL)
  expect_message(
    expect_identical(
      gutenberg_get_mirror(),
      "http://aleph.gutenberg.org"
    ),
    "Determining mirror"
  )
  expect_no_message(
    expect_identical(
      gutenberg_get_mirror(),
      "http://aleph.gutenberg.org"
    )
  )
})

test_that("gutenberg_get_mirror respects verbose", {
  local_dl_and_read()
  withr::local_options(gutenberg_mirror = NULL)
  expect_no_message(gutenberg_get_mirror(verbose = FALSE))
})

test_that("gutenberg_get_mirror uses existing option", {
  local_dl_and_read()
  withr::local_options(gutenberg_mirror = "mirror")
  expect_identical(
    gutenberg_get_mirror(), "mirror"
  )
})
