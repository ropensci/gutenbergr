# Utilize local fixtures
local_dl_and_read <- function(.env = parent.frame()) {
  local_mocked_bindings(
    dl_and_read = function(url) {
      filename <- stringr::str_replace_all(
        basename(url),
        "[^[:alnum:]]",
        "-"
      )
      path <- test_path("fixtures", filename)
      readr::read_lines(path)
    },
    .env = .env
  )
}

# Helper to centralize mirror mocking logic and option handling
mock_mirror_logic <- function(
  mirrors = NULL,
  is_working = TRUE,
  gutenberg_mirror_opt = NULL,
  .env = parent.frame()
) {
  withr::local_options(
    gutenberg_mirror = gutenberg_mirror_opt,
    .local_envir = .env
  )

  testthat::local_mocked_bindings(
    gutenberg_get_all_mirrors = function() mirrors,
    is_working_gutenberg_mirror = function(url) {
      if (is.function(is_working)) {
        return(is_working(url))
      }
      is_working
    },
    .package = "gutenbergr",
    .env = .env
  )
}
