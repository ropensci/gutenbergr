test_that("gutenberg_cache_dir returns character path", {
  with_gutenberg_cache({
    path <- gutenberg_cache_dir()
    expect_type(path, "character")
    expect_true(nzchar(path))
  })
})

test_that("gutenberg_set_cache(session) uses tempdir()", {
  with_gutenberg_cache({
    path <- gutenberg_set_cache("session", quiet = TRUE)
    expect_true(
      startsWith(
        normalizePath(path, mustWork = FALSE),
        normalizePath(tempdir(), mustWork = FALSE)
      )
    )
    expect_true(dir.exists(path))
  })
})

test_that("gutenberg_set_cache(persistent) returns default cache", {
  with_gutenberg_cache({
    path <- gutenberg_set_cache("persistent", quiet = TRUE)
    expect_type(path, "character")
  })
})

test_that("gutenberg_list_cache returns empty tibble when empty", {
  with_gutenberg_cache({
    out <- gutenberg_list_cache(quiet = TRUE)
    expect_s3_class(out, "tbl_df")
    expect_equal(nrow(out), 0)
  })
})

test_that("gutenberg_list_cache lists cached files", {
  with_gutenberg_cache({
    path <- gutenberg_cache_dir()
    saveRDS("test", file.path(path, "123.rds"))
    saveRDS("test", file.path(path, "456.rds"))

    out <- gutenberg_list_cache(quiet = TRUE)

    expect_equal(nrow(out), 2)
    expect_true(all(out$file %in% c("123.rds", "456.rds")))
    expect_true(all(out$size_mb > 0))
  })
})

test_that("gutenberg_delete_cache removes specific files by ID", {
  with_gutenberg_cache({
    path <- gutenberg_cache_path()

    file_105 <- file.path(path, "105.rds")
    file_109 <- file.path(path, "109.rds")
    saveRDS(list(id = 105), file_105)
    saveRDS(list(id = 109), file_109)

    n <- gutenberg_delete_cache(105, quiet = TRUE)
    expect_equal(n, 1)
    expect_false(file.exists(file_105))
    expect_true(file.exists(file_109))
    expect_message(gutenberg_delete_cache(999), "None of the specified IDs")
  })
})

test_that("gutenberg_clear_cache deletes cached files", {
  with_gutenberg_cache({
    path <- gutenberg_cache_dir()
    saveRDS("test", file.path(path, "1.rds"))
    saveRDS("test", file.path(path, "2.rds"))

    n <- suppressMessages(gutenberg_clear_cache())

    expect_equal(n, 2)
    expect_equal(length(list.files(path, pattern = "\\.rds$")), 0)
  })
})

test_that("session cache is detected as temporary", {
  with_gutenberg_cache({
    gutenberg_set_cache("session", quiet = TRUE)
    path <- gutenberg_cache_dir()

    is_session <- startsWith(
      normalizePath(path, winslash = "/", mustWork = FALSE),
      normalizePath(tempdir(), winslash = "/", mustWork = FALSE)
    )

    expect_true(is_session)
  })
})

test_that("gutenberg_set_cache toggles between different paths", {
  with_gutenberg_cache({
    session_path <- gutenberg_set_cache("session", quiet = TRUE)

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

    # dlr will now successfully create 'mock_persistent_path' because it's in a writable area
    persistent_path <- gutenberg_set_cache("persistent", quiet = TRUE)

    expect_false(identical(session_path, persistent_path))
    expect_equal(persistent_path, mock_persistent_path)
    expect_true(dir.exists(persistent_path))
  })
})
