# Provides a test-safe cache location
with_gutenberg_cache <- function(code) {
  # Mock the prompt inside the dlr package call to utils::askYesNo
  testthat::local_mocked_bindings(
    askYesNo = function(...) TRUE,
    .package = "utils"
  )
  old <- dlr::app_cache_dir("gutenbergr")

  tmp <- tempfile("gutenbergr-test-")
  dir.create(tmp, recursive = TRUE)

  dlr::set_app_cache_dir("gutenbergr", cache_dir = tmp)

  on.exit(
    {
      dlr::set_app_cache_dir("gutenbergr", cache_dir = old)
      unlink(tmp, recursive = TRUE)
    },
    add = TRUE
  )

  force(code)
}
