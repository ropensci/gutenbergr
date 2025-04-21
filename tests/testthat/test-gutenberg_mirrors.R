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
  withr::local_options(gutenberg_mirror = "https://gutenberg.pglaf.org")
  expect_identical(
    gutenberg_get_mirror(), "https://gutenberg.pglaf.org"
  )
})

test_that("gutenberg_get_mirror catches bad option", {
  withr::local_options(gutenberg_mirror = "https://not-a-gutenberg-mirror.org")
  expect_message(
    expect_message(
      expect_message(
        gutenberg_get_mirror(),
        "Checking for new mirror", class = "gutenbergr-msg-mirror-refresh"
      ), "Determining mirror", class = "gutenbergr-msg-mirror-finding"
    ), "Using mirror", class = "gutenbergr-msg-mirror-found"
  )
})

test_that("is_working_gutenberg_mirror catches working mirror", {
  local_dl_and_read()
  expect_true(
    is_working_gutenberg_mirror("https://gutenberg.pglaf.org")
  )
})

test_that("is_working_gutenberg_mirror catches non-working mirror", {
  expect_false(
    is_working_gutenberg_mirror("https://www.not-gutenberg.org")
  )
})

test_that("gutenberg_get_all_mirrors works", {
  # mirror_table_raw <- suppressWarnings(read_md_table(
  #   mirrors_url,
  #   warn = FALSE,
  #   force = TRUE,
  #   show_col_types = FALSE
  # ))
  # saveRDS(mirror_table_raw, test_path("fixtures", "mirror_table_raw.rds"))

  local_mocked_bindings(
    read_md_table = function(file, ...) {
      if (file == "https://www.gutenberg.org/MIRRORS.ALL") {
        return(
          readRDS(test_path("fixtures", "mirror_table_raw.rds"))
        )
      }
      stop("Unexpected path.")
    }
  )
  mirrors <- gutenberg_get_all_mirrors()
  expect_true(inherits(mirrors, "data.frame"))
  expect_true(inherits(mirrors, "tbl_df"))
  expect_equal(ncol(mirrors), 6)
  expect_true(nrow(mirrors) > 10)
})

test_that("gutenberg_get_all_mirrors errors for weird warnings", {
  local_mocked_bindings(
    read_md_table = function(file, ...) {
      warning("Some other warning")
    }
  )
  expect_error(
    gutenberg_get_all_mirrors(),
    class = "gutenbergr-error-mirror_table_reading"
  )
})
