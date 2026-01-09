#' Download one or more works using a Project Gutenberg ID
#'
#' Download one or more works by their Project Gutenberg IDs into a data frame
#' with one row per line per work. This can be used to download a single work of
#' interest or multiple at a time. You can look up the Gutenberg IDs of a work
#' using [gutenberg_works()] or the [gutenberg_metadata] dataset.
#'
#' @param gutenberg_id A vector of Project Gutenberg IDs, or a data frame
#'   containing a `gutenberg_id` column, such as from the results of
#'   [gutenberg_works()].
#' @param mirror A mirror URL to retrieve the books from. By default uses the
#'   mirror from [gutenberg_get_mirror()].
#' @param strip Whether to strip suspected headers and footers using
#'   [gutenberg_strip()].
#' @param meta_fields Additional fields describing each book, such as `title`
#'   and `author`, to add from [gutenberg_metadata].
#' @param verbose Whether to show messages about the Project Gutenberg mirror
#'   that was chosen.
#' @param use_cache Whether to use caching. Defaults to `TRUE`.
#'
#' * See [gutenberg_cache_set()] for details on configuring caching.
#' * See [gutenberg_cache_dir()] to check your current cache location.
#' * The files in the cache are `.rds` files that have already been processed
#'   into a `tbl_df`.
#'
#' @return A two column `tbl_df` (see [tibble::tibble()]) with one row for each
#'   line of the text or texts, with columns:
#' \describe{
#'   \item{gutenberg_id}{Integer column with the Project Gutenberg ID of
#'   each text}
#'   \item{text}{A character vector of lines of text}
#' }
#'
#' @examplesIf interactive()
#' # Download "The Count of Monte Cristo"
#' gutenberg_download(1184)
#'
#' # Download two books: "Wuthering Heights" and "Jane Eyre"
#' books <- gutenberg_download(c(768, 1260), meta_fields = "title")
#' books
#' dplyr::count(books, title)
#'
#' # Download all books from Jane Austen
#' austen <- gutenberg_works(author == "Austen, Jane") |>
#'   gutenberg_download(meta_fields = "title")
#' austen
#' dplyr::count(austen, title)
#'
#' @export
gutenberg_download <- function(
  gutenberg_id,
  mirror = gutenberg_get_mirror(verbose = verbose),
  strip = TRUE,
  meta_fields = character(),
  verbose = TRUE,
  use_cache = TRUE
) {
  urls <- gutenberg_url(gutenberg_id, mirror, verbose)
  downloaded <- purrr::imap(urls, function(url, id) {
    if (use_cache) {
      cache_dir <- gutenberg_cache_dir()
      cache_file <- file.path(cache_dir, paste0(id, ".rds"))

      if (file.exists(cache_file)) {
        readRDS(cache_file)
      } else {
        result <- try_gutenberg_download(url)
        if (!is.null(result)) {
          gutenberg_ensure_cache_dir()
          saveRDS(result, cache_file)
        }
        result
      }
    } else {
      try_gutenberg_download(url)
    }
  })
  downloaded <- purrr::discard(downloaded, is.null)

  if (strip) {
    downloaded <- purrr::map(downloaded, gutenberg_strip)
  }

  ret <- purrr::list_rbind(
    purrr::imap(
      downloaded,
      ~ tibble::tibble(
        gutenberg_id = as.integer(.y),
        text = .x,
      )
    )
  )

  gutenberg_add_metadata(ret, meta_fields)
}

#' Construct a Project Gutenberg url
#'
#' @inheritParams gutenberg_download
#'
#' @return A named character vector of urls.
#' @keywords internal
gutenberg_url <- function(gutenberg_id, mirror, verbose) {
  gutenberg_id <- flatten_gutenberg_id(gutenberg_id)
  mirror <- mirror %||% gutenberg_get_mirror(verbose = verbose)
  path <- gutenberg_path_from_id(gutenberg_id)
  rlang::set_names(
    stringr::str_c(mirror, path, gutenberg_id, gutenberg_id, sep = "/"),
    gutenberg_id
  )
}

#' Subset gutenberg_id from df if necessary
#'
#' @inheritParams gutenberg_download
#' @return A character vector of `gutenberg_id` values.
#' @keywords internal
flatten_gutenberg_id <- function(gutenberg_id) {
  if (is.data.frame(gutenberg_id)) {
    # Useful for output of gutenberg_works()
    gutenberg_id <- gutenberg_id[["gutenberg_id"]]
  }
  as.character(gutenberg_id)
}

#' Construct a Project Gutenberg path from an ID
#'
#' @inheritParams gutenberg_download
#' @return A character vector of paths.
#' @keywords internal
gutenberg_path_from_id <- function(gutenberg_id) {
  path <- stringr::str_replace_all(
    stringr::str_sub(gutenberg_id, 1, -2), # Drop last character.
    "(.)(?!$)", # Insert / after each character accept the last one.
    "\\1/"
  )
  path[nchar(gutenberg_id) == 1] <- "0"
  path
}

#' Try to download book using various URLs
#'
#' @param url The base URL of a book.
#'
#' @return A character vector of lines of text or `NULL` if the book could not be
#'   downloaded.
#' @keywords internal
try_gutenberg_download <- function(url) {
  suffix <- c("", "-8", "-0")
  ext <- c(".zip", ".txt")
  possible_urls <- glue::glue_data(
    expand.grid(url = url, suffix = suffix, ext = ext),
    "{url}{suffix}{ext}"
  )
  ret <- read_next(possible_urls)
  if (is.null(ret)) {
    cli::cli_warn(
      c(
        "!" = "Could not download a book at {url}.",
        "i" = "The book may have been archived.",
        "i" = "Alternatively, you may need to select a different mirror.",
        ">" = paste0(
          "See https://www.gutenberg.org/MIRRORS.ALL ",
          "or run `gutenberg_get_all_mirrors()` for options."
        )
      ),
      class = "gutenbergr-warning-download_failure"
    )
  }
  return(ret)
}

#' Join metadata fields to Gutenberg works
#'
#' @param gutenberg_tbl A two column `tbl_df` from [gutenberg_download()].
#' @inheritParams gutenberg_download
#'
#' @return A `tbl_df` of the Gutenberg works with joined metadata.
#' @keywords internal
gutenberg_add_metadata <- function(gutenberg_tbl, meta_fields) {
  meta_fields <- union("gutenberg_id", meta_fields)
  dplyr::left_join(
    gutenberg_tbl,
    gutenbergr::gutenberg_metadata[meta_fields],
    by = "gutenberg_id"
  )
}
