test_that(".onLoad creates directory when type is persistent", {
  with_gutenberg_cache({
    withr::with_options(list(gutenbergr_cache_type = "persistent"), {
      .onLoad(NULL, NULL)

      # Verify the directory exists in the temp location
      cache_path <- dlr::app_cache_dir("gutenbergr")
      expect_true(dir.exists(cache_path))
    })
  })
})
