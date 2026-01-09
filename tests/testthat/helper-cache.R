# Provides test-safe cache locations and options
with_gutenberg_cache <- function(code, type = "persistent") {
  withr::local_options(
    gutenbergr_cache_type = type
  )

  if (type == "persistent") {
    cache_root <- withr::local_tempdir("gutenbergr-test-")

    withr::local_options(
      gutenbergr_base_cache_dir = cache_root
    )

    gutenberg_ensure_cache_dir()
  } else {
    withr::local_options(
      gutenbergr_base_cache_dir = NULL
    )
  }

  force(code)
}
