test_that("gutenberg_get_mirror falls back when mirror list unavailable", {
  local_mocked_bindings(
    gutenberg_get_all_mirrors = function() NULL,
    is_working_gutenberg_mirror = function(url) {
      url == "https://aleph.pglaf.org"
    },
    .package = "gutenbergr"
  )

  withr::local_options(gutenberg_mirror = NULL)

  expect_message(
    expect_identical(
      gutenberg_get_mirror(),
      "https://aleph.pglaf.org"
    ),
    "Falling back",
    class = "gutenbergr-msg-mirror-fallback"
  )

  expect_no_message(
    expect_identical(
      gutenberg_get_mirror(),
      "https://aleph.pglaf.org"
    )
  )
})

test_that("gutenberg_get_mirror errors if fallback mirror is also unavailable", {
  local_mocked_bindings(
    gutenberg_get_all_mirrors = function() NULL,
    is_working_gutenberg_mirror = function(url) FALSE,
    .package = "gutenbergr"
  )

  withr::local_options(gutenberg_mirror = NULL)

  expect_error(
    gutenberg_get_mirror(),
    class = "gutenbergr-error-no_working_mirror"
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
    gutenberg_get_mirror(),
    "https://gutenberg.pglaf.org"
  )
})

test_that("gutenberg_get_mirror catches bad option", {
  local_mocked_bindings(
    gutenberg_get_all_mirrors = function() NULL,
    is_working_gutenberg_mirror = function(url) {
      # Bad mirror returns FALSE, fallback mirror returns TRUE
      if (url == "https://not-a-gutenberg-mirror.org") {
        return(FALSE)
      }
      if (url == "https://aleph.pglaf.org") {
        return(TRUE)
      }
      FALSE
    },
    .package = "gutenbergr"
  )

  withr::local_options(gutenberg_mirror = "https://not-a-gutenberg-mirror.org")

  expect_message(
    expect_message(
      expect_identical(
        gutenberg_get_mirror(),
        "https://aleph.pglaf.org"
      ),
      "Checking for new mirror",
      class = "gutenbergr-msg-mirror-refresh"
    ),
    "Falling back",
    class = "gutenbergr-msg-mirror-fallback"
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
