.onLoad <- function(libname, pkgname) {
  cache_type <- getOption("gutenbergr_cache_type", "session")
  if (!(cache_type %in% c("session", "persistent"))) {
    warning("Invalid gutenbergr_cache_type. Defaulting to 'session'.")
    cache_type <- "session"
  }

  gutenberg_set_cache(cache_type, quiet = TRUE)
  gutenberg_ensure_cache_dir()
  invisible()
}

.onAttach <- function(libname, pkgname) {
  path <- gutenberg_cache_dir()

  # If the cache directory lives under tempdir(), treat it as session-based
  is_session <- startsWith(
    normalizePath(path, winslash = "/", mustWork = FALSE),
    normalizePath(tempdir(), winslash = "/", mustWork = FALSE)
  )

  type_str <- if (is_session) {
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
