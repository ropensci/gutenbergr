#' Get the active cache directory path
#'
#' Calculates the path to the directory where Gutenberg files are stored,
#' based on the current `gutenbergr_cache_type` and `gutenbergr_base_cache_dir`
#' options.
#'
#' @return A character string representing the path to the cache directory.
#' @examplesIf interactive()
#' # Get current cache directory
#' gutenberg_cache_dir()
#'
#' @keywords cache
#' @inheritSection gutenberg_cache_set Cache options
#' @export
gutenberg_cache_dir <- function() {
  type <- getOption("gutenbergr_cache_type", "session")

  if (type == "session") {
    # Return the temp path directly
    return(file.path(tempdir(), "gutenbergr_cache"))
  }

  base_path <- getOption(
    "gutenbergr_base_cache_dir",
    tools::R_user_dir("gutenbergr", "cache")
  )

  file.path(as.character(base_path), "works_rds")
}

#' Ensure the Gutenberg cache directory exists
#'
#' Checks for the existence of the cache directory and creates it if it is missing.
#'
#' @return The cache directory path (invisibly).
#' @keywords internal
gutenberg_ensure_cache_dir <- function() {
  path <- path.expand(gutenberg_cache_dir())
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
  path <- gutenberg_cache_dir()
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
#' @param type Either `"session"` (default) or `"persistent"`.
#' * `"session"`: Files are stored in a [tempdir()].
#'   This is the default behavior.
#' * `"persistent"`: Files are stored in an OS-specific
#'   user cache directory under `works_rds/`. These files persist across sessions,
#'   preventing redundant downloads of the same files in the future.
#' @param verbose Whether to show the status message confirming the path.
#'
#' @section Cache options:
#' The following options control caching behavior:
#'
#' * `gutenbergr_cache_type`: Character string indicating how downloaded works
#'   are cached. Must be either `"session"` (default) or `"persistent"`.
#'
#' * `gutenbergr_base_cache_dir`: Base directory used for persistent caching when
#'   `gutenbergr_cache_type = "persistent"`.
#'   By default, this is an OS-specific cache directory determined by
#'   `tools::R_user_dir("gutenbergr", "cache")`. Advanced users may set this
#'   to a custom path.
#' @return The active cache path (invisibly).
#'
#' @examplesIf interactive()
#' # Set to persistent (survives R sessions)
#' gutenberg_cache_set("persistent")
#'
#' # Set back to session cache (temporary)
#' gutenberg_cache_set("session")
#'
#' # Check current cache location
#' gutenberg_cache_dir()
#'
#' @export
#' @keywords cache
gutenberg_cache_set <- function(
  type = getOption("gutenbergr_cache_type", "session"),
  verbose = TRUE
) {
  if (!type %in% c("session", "persistent")) {
    cli::cli_warn(c(
      "Invalid gutenbergr_cache_type: {.val {type}}. Defaulting to {.val session}.",
      "i" = "Must be either {.val session} or {.val persistent}.",
      "i" = "Set with {.code options(gutenbergr_cache_type = \"session\")} or {.code options(gutenbergr_cache_type = \"persistent\")}"
    ))
    type <- "session"
  }

  options(gutenbergr_cache_type = type)

  if (type == "session") {
    options(gutenbergr_base_cache_dir = NULL)
  } else {
    # For persistent mode, use default unless already set
    if (is.null(getOption("gutenbergr_base_cache_dir"))) {
      options(
        gutenbergr_base_cache_dir = tools::R_user_dir("gutenbergr", "cache")
      )
    }
  }

  gutenberg_ensure_cache_dir()
  path <- gutenberg_cache_dir()
  if (verbose) {
    cli::cli_alert_success("Cache set to {.val {type}}: {.path {path}}")
  }

  invisible(path)
}

#' Clear all files from the Gutenberg cache
#'
#' Deletes all cached `.rds` files in the directory currently returned by
#' [gutenberg_cache_dir()].
#'
#' @param verbose Whether to show the status message confirming the path.

#' @return The number of files deleted (invisibly).
#' @examplesIf interactive()
#' # Clear entire current cache
#' gutenberg_cache_clear_all()
#'
#' @keywords cache
#' @export
gutenberg_cache_clear_all <- function(verbose = TRUE) {
  files <- gutenberg_cache_files()
  n_files <- length(files)

  if (n_files > 0) {
    unlink(files)
  }

  if (verbose) {
    cli::cli_alert_success("Deleted {n_files} cached file{?s}")
  }

  invisible(n_files)
}

#' Delete specific files from the cache
#'
#' @param ids A numeric or character vector of Gutenberg IDs to remove
#'   from the current cache.
#' @param verbose Whether to show the status messages.
#'
#' @return The number of files successfully deleted (invisibly).
#' @examplesIf interactive()
#' # Remove specific books from cache
#' gutenberg_cache_remove_ids(c(1, 2))
#'
#' # Remove silently
#' gutenberg_cache_remove_ids(1, verbose = FALSE)
#'
#' @keywords cache
#' @export
gutenberg_cache_remove_ids <- function(ids, verbose = TRUE) {
  if (missing(ids) || length(ids) == 0) {
    cli::cli_abort("Please provide at least one Gutenberg ID to delete.")
  }

  cache_root <- gutenberg_cache_dir()
  target_files <- file.path(cache_root, paste0(ids, ".rds"))
  existing_files <- target_files[file.exists(target_files)]
  n_deleted <- length(existing_files)

  if (n_deleted > 0) {
    unlink(existing_files)
    if (verbose) {
      cli::cli_alert_success(
        "Deleted {n_deleted} cached file{?s} from {.path {cache_root}}"
      )
    }
  } else {
    if (verbose) {
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
#' returned by [gutenberg_cache_dir()].
#'
#' @param verbose Whether to show the status message showing the cache directory path.
#'
#' @return A [tibble::tibble()] with the following columns:
#' \describe{
#'     \item{title}{The title of the work.}
#'     \item{author}{The author(s) of the work.}
#'     \item{file}{The filename.}
#'     \item{size_mb}{Size of the file in megabytes.}
#'     \item{modified}{The last modification time.}
#'     \item{path}{The file's absolute path.}
#' }
#' @examplesIf interactive()
#' # List all works in the currently set cache
#' gutenberg_cache_list()
#'
#' # Suppress the directory path message
#' gutenberg_cache_list(verbose = FALSE)
#'
#' @keywords cache
#' @export
gutenberg_cache_list <- function(verbose = TRUE) {
  cache_root <- gutenberg_cache_dir()
  files <- gutenberg_cache_files()

  if (verbose) {
    cli::cli_inform("Cache directory: {.path {cache_root}}")
  }

  if (length(files) == 0) {
    return(tibble::tibble(
      title = character(),
      author = character(),
      file = character(),
      size_mb = double(),
      modified = as.POSIXct(character()),
      path = character()
    ))
  }

  info <- file.info(files)
  filenames <- basename(files)
  gutenberg_ids <- as.integer(sub("\\..*$", "", filenames))

  metadata <- tibble::tibble(gutenberg_id = gutenberg_ids) |>
    dplyr::left_join(
      gutenberg_metadata |>
        dplyr::select(gutenberg_id, title, author) |>
        dplyr::group_by(gutenberg_id) |>
        dplyr::summarise(
          title = dplyr::first(title),
          author = paste(author, collapse = " & "),
          .groups = "drop"
        ),
      by = "gutenberg_id"
    )

  tibble::tibble(
    title = metadata$title,
    author = metadata$author,
    file = filenames,
    size_mb = info$size / 1024^2,
    modified = info$mtime,
    path = normalizePath(files, winslash = "/", mustWork = FALSE)
  )
}
