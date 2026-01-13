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
