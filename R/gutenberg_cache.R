#' Get the active cache directory path
#'
#' Calculates the path to the directory where Gutenberg files are stored,
#' based on the current `gutenbergr_cache_type` option.
#'
#' @return A character string representing the path to the cache directory.
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
#'
#' @return A character string representing the path to the cache directory.
#' @export
gutenberg_cache_dir <- function() {
  gutenberg_cache_path()
}

#' Ensure the Gutenberg cache directory exists
#'
#' Checks for the existence of the cache directory and creates it if it is missing.
#'
#' @return The cache directory path (invisibly).
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
#' Retrieves a list of all `.rds` files currently stored in the Gutenberg cache.
#'
#' @return A character vector of full file paths.
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
#' Configures whether the cache should be temporary (per-session) or
#' persistent across sessions.
#'
#' @param type Either "session" (default) or "persistent".
#' @param quiet Whether to suppress the status message confirming the path.
#'
#' @return The active cache path (invisibly).
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

#' Clear all files from the Gutenberg cache
#'
#' Deletes all cached `.rds` files in the directory currently returned by
#' [gutenberg_cache_path()].
#'
#' @return The number of files deleted (invisibly).
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

#' Delete specific files from the cache
#'
#' @param ids A numeric or character vector of Gutenberg IDs to remove
#'   from the current cache.
#' @param quiet Whether to suppress the status messages.
#'
#' @return The number of files successfully deleted (invisibly).
#' @export
gutenberg_delete_cache <- function(ids, quiet = FALSE) {
  if (missing(ids) || length(ids) == 0) {
    cli::cli_abort("Please provide at least one Gutenberg ID to delete.")
  }

  cache_root <- gutenberg_cache_path()
  target_files <- file.path(cache_root, paste0(ids, ".rds"))
  existing_files <- target_files[file.exists(target_files)]
  n_deleted <- length(existing_files)

  if (n_deleted > 0) {
    unlink(existing_files)
    if (!quiet) {
      cli::cli_alert_success(
        "Deleted {n_deleted} cached file{?s} from {.path {cache_root}}"
      )
    }
  } else {
    if (!quiet) {
      cli::cli_alert_info(
        "None of the specified IDs ({.val {ids}}) were found in the current cache."
      )
    }
  }

  invisible(n_deleted)
}

#' List files in the Gutenberg cache
#'
#' Provides a detailed list of files currently stored in the directory
#' returned by [gutenberg_cache_path()].
#'
#' @param quiet Whether to suppress the status message showing the cache directory path.
#'
#' @return A [tibble::tibble] with the following columns:
#'   \describe{
#'     \item{file}{The filename.}
#'     \item{size_mb}{Size of the file in megabytes.}
#'     \item{modified}{The last modification time.}
#'     \item{path}{The file's absolute path.}
#'   }
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
