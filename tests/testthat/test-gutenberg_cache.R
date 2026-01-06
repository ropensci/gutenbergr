describe("gutenberg_cache_dir()", {
  test_that("returns character path", {
    with_gutenberg_cache({
      path <- gutenberg_cache_dir()
      expect_type(path, "character")
      expect_true(nzchar(path))
    })
  })

  test_that("returns session cache path when in session mode", {
    with_gutenberg_cache(type = "session", {
      path <- gutenberg_cache_dir()
      expect_type(path, "character")
      expect_true(startsWith(
        normalizePath(path, mustWork = FALSE),
        normalizePath(tempdir(), mustWork = FALSE)
      ))
    })
  })

  test_that("returns persistent cache path when in persistent mode", {
    with_gutenberg_cache(type = "persistent", {
      path <- gutenberg_cache_dir()
      expect_type(path, "character")
      expected_path <- dlr::app_cache_dir("gutenbergr")
      expect_equal(
        normalizePath(path, mustWork = FALSE),
        normalizePath(expected_path, mustWork = FALSE)
      )
    })
  })
})

describe("gutenberg_set_cache()", {
  test_that("session mode uses tempdir()", {
    with_gutenberg_cache({
      path <- gutenberg_set_cache("session", verbose = FALSE)
      expect_true(
        startsWith(
          normalizePath(path, mustWork = FALSE),
          normalizePath(tempdir(), mustWork = FALSE)
        )
      )
      expect_true(dir.exists(path))
    })
  })

  test_that("persistent mode returns default cache", {
    with_gutenberg_cache({
      path <- gutenberg_set_cache("persistent", verbose = FALSE)
      expect_type(path, "character")
    })
  })

  test_that("toggles between different paths", {
    with_gutenberg_cache({
      session_path <- gutenberg_set_cache("session", verbose = FALSE)

      # Define a separate, writable temp path for the mock persistent storage
      mock_persistent_path <- tempfile("mock_persistent_")
      withr::defer(unlink(mock_persistent_path, recursive = TRUE))

      # Mock dlr to return this specific temp path when 'persistent' is requested
      testthat::local_mocked_bindings(
        app_cache_dir = function(appname, cache_dir = NULL) {
          if (is.null(cache_dir)) {
            return(mock_persistent_path)
          }
          return(cache_dir)
        },
        .package = "dlr"
      )

      persistent_path <- gutenberg_set_cache("persistent", verbose = FALSE)
      expect_false(identical(session_path, persistent_path))
      expect_equal(persistent_path, mock_persistent_path)
      expect_true(dir.exists(persistent_path))
    })
  })

  test_that("session cache is detected as temporary", {
    with_gutenberg_cache({
      gutenberg_set_cache("session", verbose = FALSE)
      path <- gutenberg_cache_dir()

      is_session <- startsWith(
        normalizePath(path, winslash = "/", mustWork = FALSE),
        normalizePath(tempdir(), winslash = "/", mustWork = FALSE)
      )

      expect_true(is_session)
    })
  })

  test_that("emits success message when verbose = TRUE", {
    with_gutenberg_cache({
      expect_message(
        gutenberg_set_cache("session", verbose = TRUE),
        "Cache set to"
      )
    })
  })
})

describe("gutenberg_list_cache()", {
  test_that("returns empty tibble when cache is empty", {
    with_gutenberg_cache({
      out <- gutenberg_list_cache(verbose = FALSE)
      expect_s3_class(out, "tbl_df")
      expect_equal(nrow(out), 0)
      expect_named(
        out,
        c("title", "file", "size_mb", "modified", "path"),
        ignore.order = TRUE
      )
    })
  })

  test_that("lists cached files with correct metadata", {
    with_gutenberg_cache({
      path <- gutenberg_cache_dir()
      saveRDS("test", file.path(path, "123.rds"))
      saveRDS("test", file.path(path, "456.rds"))
      out <- gutenberg_list_cache(verbose = FALSE)
      expect_equal(nrow(out), 2)
      expect_true(all(out$file %in% c("123.rds", "456.rds")))
      expect_true(all(out$size_mb > 0))
      expect_true("title" %in% names(out))
      expect_type(out$title, "character")
    })
  })

  test_that("includes titles from metadata when available", {
    with_gutenberg_cache({
      path <- gutenberg_cache_dir()
      # 84: Frankenstein"
      # 1342: Pride and Prejudice
      saveRDS("test", file.path(path, "84.rds"))
      saveRDS("test", file.path(path, "1342.rds"))

      out <- gutenberg_list_cache(verbose = FALSE)

      expect_equal(nrow(out), 2)
      expect_true(any(!is.na(out$title)))
    })
  })

  test_that("handles files with IDs not in metadata", {
    with_gutenberg_cache({
      path <- gutenberg_cache_dir()
      saveRDS("test", file.path(path, "9999999.rds"))
      out <- gutenberg_list_cache(verbose = FALSE)
      expect_equal(nrow(out), 1)
      expect_true(is.na(out$title[1]))
    })
  })

  test_that("informs about directory when verbose = TRUE", {
    with_gutenberg_cache({
      expect_message(
        gutenberg_list_cache(verbose = TRUE),
        "Cache directory:"
      )
    })
  })
})

describe("gutenberg_cache_remove_ids()", {
  test_that("removes specific files by ID", {
    with_gutenberg_cache({
      path <- gutenberg_cache_dir()
      file_105 <- file.path(path, "105.rds")
      file_109 <- file.path(path, "109.rds")
      saveRDS(list(id = 105), file_105)
      saveRDS(list(id = 109), file_109)

      n <- gutenberg_cache_remove_ids(105, verbose = FALSE)
      expect_equal(n, 1)
      expect_false(file.exists(file_105))
      expect_true(file.exists(file_109))
    })
  })

  test_that("handles non-existent IDs gracefully", {
    with_gutenberg_cache({
      expect_message(
        gutenberg_cache_remove_ids(999),
        "None of the specified IDs"
      )
    })
  })

  test_that("messages on success and missing when verbose = TRUE", {
    with_gutenberg_cache({
      path <- gutenberg_cache_dir()
      saveRDS(list(id = 1), file.path(path, "1.rds"))

      expect_message(
        gutenberg_cache_remove_ids(1, verbose = TRUE),
        "Deleted 1 cached file"
      )

      expect_message(
        gutenberg_cache_remove_ids(999, verbose = TRUE),
        "None of the specified IDs"
      )
    })
  })
})

describe("gutenberg_cache_clear_all()", {
  test_that("deletes all cached files", {
    with_gutenberg_cache({
      path <- gutenberg_cache_dir()
      saveRDS("test", file.path(path, "1.rds"))
      saveRDS("test", file.path(path, "2.rds"))

      n <- suppressMessages(gutenberg_cache_clear_all())

      expect_equal(n, 2)
      expect_equal(length(list.files(path, pattern = "\\.rds$")), 0)
    })
  })

  test_that("emits success message", {
    with_gutenberg_cache({
      path <- gutenberg_cache_dir()
      saveRDS("test", file.path(path, "1.rds"))

      expect_message(
        gutenberg_cache_clear_all(),
        "Deleted 1 cached file"
      )
    })
  })
})
