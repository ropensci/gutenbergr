describe("gutenberg_get_mirror", {
  test_that("falls back when mirror list unavailable", {
    mock_mirror_logic(
      mirrors = NULL,
      is_working = function(url) url == "https://aleph.pglaf.org"
    )

    expect_message(
      expect_identical(gutenberg_get_mirror(), "https://aleph.pglaf.org"),
      "Falling back",
      class = "gutenbergr-msg-mirror-fallback"
    )

    expect_no_message(
      expect_identical(gutenberg_get_mirror(), "https://aleph.pglaf.org")
    )
  })

  test_that("errors if fallback mirror is also unavailable", {
    mock_mirror_logic(mirrors = NULL, is_working = FALSE)

    expect_error(
      gutenberg_get_mirror(),
      class = "gutenbergr-error-no_working_mirror"
    )
  })

  test_that("respects verbose", {
    mock_mirror_logic(gutenberg_mirror_opt = NULL)
    expect_no_message(gutenberg_get_mirror(verbose = FALSE))
  })

  test_that("uses existing option", {
    mock_mirror_logic(gutenberg_mirror_opt = "https://gutenberg.pglaf.org")
    expect_identical(
      gutenberg_get_mirror(),
      "https://gutenberg.pglaf.org"
    )
  })

  test_that("catches bad option", {
    mock_mirror_logic(
      gutenberg_mirror_opt = "https://not-a-gutenberg-mirror.org",
      mirrors = NULL,
      is_working = function(url) {
        if (url == "https://not-a-gutenberg-mirror.org") {
          return(FALSE)
        }
        url == "https://aleph.pglaf.org"
      }
    )

    expect_message(
      expect_message(
        expect_identical(gutenberg_get_mirror(), "https://aleph.pglaf.org"),
        "Checking for new mirror",
        class = "gutenbergr-msg-mirror-refresh"
      ),
      "Falling back",
      class = "gutenbergr-msg-mirror-fallback"
    )
  })
})

describe("is_working_gutenberg_mirror", {
  test_that("catches working mirror", {
    testthat::local_mocked_bindings(
      read_url = function(url) {
        if (grepl("README$", url)) {
          return(c("Some text", "GUTINDEX.ALL"))
        }
        character(0)
      },
      .package = "gutenbergr"
    )

    expect_true(is_working_gutenberg_mirror("https://gutenberg.pglaf.org"))
  })

  test_that("catches non-working mirror", {
    testthat::local_mocked_bindings(
      read_url = function(url) c("Not a mirror", "random text"),
      .package = "gutenbergr"
    )

    expect_false(is_working_gutenberg_mirror("https://www.not-gutenberg.org"))
  })

  test_that("returns FALSE when read_url errors", {
    testthat::local_mocked_bindings(
      read_url = function(url) stop("Connection failed"),
      .package = "gutenbergr"
    )

    expect_false(is_working_gutenberg_mirror("https://unreachable.example.com"))
  })
})

describe("gutenberg_get_all_mirrors", {
  test_that("works", {
    testthat::local_mocked_bindings(
      read_md_table = function(file, ...) {
        readRDS(test_path("fixtures", "mirror_table_raw.rds"))
      },
      .package = "gutenbergr"
    )

    mirrors <- gutenberg_get_all_mirrors()
    expect_s3_class(mirrors, "tbl_df")
    expect_true(nrow(mirrors) > 10)
  })

  test_that("errors for weird warnings", {
    testthat::local_mocked_bindings(
      read_md_table = function(file, ...) warning("Some other warning"),
      .package = "gutenbergr"
    )
    expect_error(
      gutenberg_get_all_mirrors(),
      class = "gutenbergr-error-mirror_table_reading"
    )
  })
})
