# Provides test-safe cache locations
with_gutenberg_cache <- function(code, type = "persistent") {
  # Mock the prompt inside the dlr package call to utils::askYesNo
  testthat::local_mocked_bindings(
    askYesNo = function(...) TRUE,
    .package = "utils"
  )

  old_type <- getOption("gutenbergr_cache_type")
  old_path <- dlr::app_cache_dir("gutenbergr")

  if (type == "persistent") {
    tmp <- tempfile("gutenbergr-test-")
    dir.create(tmp, recursive = TRUE)
    options(gutenbergr_cache_type = "persistent")
    dlr::set_app_cache_dir("gutenbergr", cache_dir = tmp)

    on.exit(
      {
        options(gutenbergr_cache_type = old_type)
        dlr::set_app_cache_dir("gutenbergr", cache_dir = old_path)
        unlink(tmp, recursive = TRUE)
      },
      add = TRUE
    )
  } else {
    options(gutenbergr_cache_type = "session")

    on.exit(
      {
        options(gutenbergr_cache_type = old_type)
        dlr::set_app_cache_dir("gutenbergr", cache_dir = old_path)
      },
      add = TRUE
    )
  }

  force(code)
}
