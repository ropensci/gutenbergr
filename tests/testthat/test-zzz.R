describe(".onLoad()", {
  test_that(".onLoad creates directory when type is persistent", {
    with_gutenberg_cache(type = "persistent", {
      .onLoad(NULL, NULL)
      cache_path <- gutenberg_cache_dir()
      expect_true(dir.exists(cache_path))
    })
  })

  test_that(".onLoad creates directory when type is session", {
    with_gutenberg_cache(type = "session", {
      .onLoad(NULL, NULL)
      cache_path <- gutenberg_cache_dir()
      expect_true(dir.exists(cache_path))
    })
  })

  test_that("warns and defaults to session when cache type is invalid", {
    with_gutenberg_cache(
      {
        options(gutenbergr_cache_type = "invalid_type")

        expect_warning(
          .onLoad(NULL, NULL),
          "Invalid gutenbergr_cache_type.*Defaulting to"
        )

        expect_identical(
          getOption("gutenbergr_cache_type"),
          "session"
        )

        path <- gutenberg_cache_dir()
        expect_true(
          startsWith(
            normalizePath(path, mustWork = FALSE),
            normalizePath(tempdir(), mustWork = FALSE)
          )
        )
      },
      type = "session"
    )
  })
})

describe(".onAttach()", {
  test_that("shows session cache message when type is session", {
    with_gutenberg_cache(type = "session", {
      expect_message(
        .onAttach(NULL, NULL, interactive_session = TRUE),
        "session \\(temporary\\)"
      )
      path <- gutenberg_cache_dir()
      expect_message(
        .onAttach(NULL, NULL, interactive_session = TRUE),
        path,
        fixed = TRUE
      )
    })
  })

  test_that("shows persistent cache message when type is persistent", {
    with_gutenberg_cache(type = "persistent", {
      testthat::local_mocked_bindings(
        gutenberg_cache_dir = function() "/fake/persistent/path"
      )
      expect_message(
        .onAttach(NULL, NULL, interactive_session = TRUE),
        "persistent"
      )
      expect_message(
        .onAttach(NULL, NULL, interactive_session = TRUE),
        "/fake/persistent/path",
        fixed = TRUE
      )
    })
  })

  test_that("message contains 'gutenbergr: using' prefix", {
    with_gutenberg_cache({
      expect_message(
        .onAttach(NULL, NULL, interactive_session = TRUE),
        "gutenbergr: using"
      )
    })
  })

  test_that("message contains 'cache directory:' label", {
    with_gutenberg_cache({
      expect_message(
        .onAttach(NULL, NULL, interactive_session = TRUE),
        "cache directory:"
      )
    })
  })

  test_that("no message shown in non-interactive mode", {
    with_gutenberg_cache({
      expect_silent(
        .onAttach(NULL, NULL, interactive_session = FALSE)
      )
    })
  })
})
