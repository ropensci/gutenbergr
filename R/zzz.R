.onLoad <- function(libname, pkgname) {
  gutenberg_cache_set(verbose = FALSE)
  gutenberg_ensure_cache_dir()
}

.onAttach <- function(libname, pkgname, interactive_session = interactive()) {
  if (!interactive_session) {
    return(invisible())
  }

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
