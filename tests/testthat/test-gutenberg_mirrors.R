test_that("gutenberg_get_mirror works with no option set", {
  local_dl_and_read()
  withr::local_options(gutenberg_mirror = NULL)
  expect_message(
    expect_message(
      expect_identical(
        gutenberg_get_mirror(),
        "http://aleph.gutenberg.org"
      ),
      "Determining mirror",
      class = "gutenbergr-msg-mirror-finding"
    ),
    "Using mirror",
    class = "gutenbergr-msg-mirror-found"
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

test_that("gutenberg_get_all_mirrors works", {
  local_dl_and_read()
  mirrors <- gutenberg_get_all_mirrors()
  expect_true(inherits(mirrors, "data.frame"))
  expect_true(inherits(mirrors, "tbl_df"))
  expect_equal(ncol(mirrors), 6)
  expect_true(nrow(mirrors) > 10)
})
