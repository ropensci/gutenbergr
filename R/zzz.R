.onLoad <- function(libname, pkgname) {
  gutenberg_set_cache(verbose = FALSE)
  gutenberg_ensure_cache_dir()
}

.onAttach <- function(libname, pkgname) {
  path <- gutenberg_cache_dir()
  type <- getOption("gutenbergr_cache_type", "session")

  type_str <- if (type == "session") {
    "session (temporary)"
  } else {
    "persistent"
  }

  packageStartupMessage(
    "gutenbergr: using ",
    type_str,
    " cache\n",
    "  cache directory: ",
    path
  )

  invisible()
}
