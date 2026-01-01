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
    old_type <- getOption("gutenbergr_cache_type")
    old_path <- dlr::app_cache_dir("gutenbergr")

    on.exit(
      {
        options(gutenbergr_cache_type = old_type)
        dlr::set_app_cache_dir("gutenbergr", cache_dir = old_path)
      },
      add = TRUE
    )

    options(gutenbergr_cache_type = "invalid_type")

    expect_warning(
      .onLoad(NULL, NULL),
      "Invalid gutenbergr_cache_type. Defaulting to 'session'."
    )

    path <- gutenberg_cache_dir()
    expect_true(startsWith(
      normalizePath(path, mustWork = FALSE),
      normalizePath(tempdir(), mustWork = FALSE)
    ))
  })
})

describe(".onAttach()", {
  test_that("shows session cache message when type is session", {
    with_gutenberg_cache(type = "session", {
      expect_message(
        .onAttach(NULL, NULL),
        "session \\(temporary\\)"
      )

      path <- gutenberg_cache_dir()
      expect_message(
        .onAttach(NULL, NULL),
        path,
        fixed = TRUE
      )
    })
  })

  test_that("shows persistent cache message when type is persistent", {
    with_gutenberg_cache(type = "persistent", {
      # Mock the path to appear as non-temp
      testthat::local_mocked_bindings(
        gutenberg_cache_dir = function() "/fake/persistent/path"
      )

      expect_message(
        .onAttach(NULL, NULL),
        "persistent"
      )

      expect_message(
        .onAttach(NULL, NULL),
        "/fake/persistent/path",
        fixed = TRUE
      )
    })
  })

  test_that("message contains 'gutenbergr: using' prefix", {
    with_gutenberg_cache({
      expect_message(
        .onAttach(NULL, NULL),
        "gutenbergr: using"
      )
    })
  })

  test_that("message contains 'cache directory:' label", {
    with_gutenberg_cache({
      expect_message(
        .onAttach(NULL, NULL),
        "cache directory:"
      )
    })
  })
})
