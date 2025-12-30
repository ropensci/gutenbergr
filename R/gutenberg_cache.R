#' Get the active cache directory
#'
#' @return Character path to cache dir (may not exist)
#' @keywords internal
gutenberg_cache_path <- function() {
  type <- getOption("gutenbergr_cache_type", "session")

  if (type == "session") {
    # Return the temp path directly
    return(file.path(tempdir(), "gutenbergr_cache"))
  } else {
    # If persistent, let dlr find the standard OS path.
    # We use as.character because dlr can sometimes return a fs_path object
    return(as.character(dlr::app_cache_dir("gutenbergr")))
  }
}

#' Get the active Gutenberg cache directory
#' @export
gutenberg_cache_dir <- function() {
  gutenberg_cache_path()
}

#' Ensure the Gutenberg cache directory exists
#'
#' @return Cache directory path (invisibly)
#' @keywords internal
gutenberg_ensure_cache_dir <- function() {
  path <- path.expand(gutenberg_cache_path())
  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE, showWarnings = FALSE)
  }
  invisible(path)
}

#' List cached .rds files
#'
#' @return Character vector of full paths
#' @keywords internal
gutenberg_cache_files <- function() {
  path <- gutenberg_cache_path()
  if (!dir.exists(path)) {
    return(character())
  }
  list.files(path, pattern = "\\.rds$", full.names = TRUE)
}

#' Set the Gutenberg cache type
#'
#' @param type Either "session" (default) or "persistent"
#' @param quiet Whether to alert on cache type and path
#' @export
gutenberg_set_cache <- function(
  type = c("session", "persistent"),
  quiet = FALSE
) {
  type <- match.arg(type)
  options(gutenbergr_cache_type = type)

  if (type == "session") {
    path <- file.path(tempdir(), "gutenbergr_cache")
    dlr::set_app_cache_dir("gutenbergr", cache_dir = path)
  } else {
    options(gutenbergr.dir = NULL)
  }

  gutenberg_ensure_cache_dir()
  path <- gutenberg_cache_path()
  if (!quiet) {
    cli::cli_alert_success("Cache set to {.val {type}}: {.path {path}}")
  }

  invisible(path)
}

#' Delete all files in cache path currently returned by \code{\link{gutenberg_cache_path}}
#' @export
gutenberg_clear_cache <- function() {
  files <- gutenberg_cache_files()
  n_files <- length(files)

  if (n_files > 0) {
    unlink(files)
  }

  cli::cli_alert_success("Deleted {n_files} cached file{?s}")
  invisible(n_files)
}

#' List files in the cache path currently returned by \code{\link{gutenberg_cache_path}}
#' @param quiet Whether to print the cache directory path
#' @export
gutenberg_list_cache <- function(quiet = FALSE) {
  cache_root <- gutenberg_cache_path()
  files <- gutenberg_cache_files()

  if (!quiet) {
    cli::cli_inform("Cache directory: {.path {cache_root}}")
  }

  if (length(files) == 0) {
    return(tibble::tibble(
      file = character(),
      size_mb = double(),
      modified = as.POSIXct(character()),
      path = character()
    ))
  }

  info <- file.info(files)

  tibble::tibble(
    file = basename(files),
    size_mb = info$size / 1024^2,
    modified = info$mtime,
    path = normalizePath(files, winslash = "/", mustWork = FALSE)
  )
}
