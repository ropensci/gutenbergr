#' Download one or more works using a Project Gutenberg ID
#'
#' Download one or more works by their Project Gutenberg IDs into a data frame
#' with one row per line per work. This can be used to download a single work of
#' interest or multiple at a time. You can look up the Gutenberg IDs of a work
#' using [gutenberg_works()] or the \link{gutenberg_metadata} dataset.
#'
#' @param gutenberg_id A vector of Project Gutenberg IDs, or a data frame
#'   containing a `gutenberg_id` column, such as from the results of
#'   [gutenberg_works()].
#' @param mirror A mirror URL to retrieve the books from. By default uses the
#'   mirror from [gutenberg_get_mirror()].
#' @param strip Whether to strip suspected headers and footers using
#'   [gutenberg_strip()].
#' @param meta_fields Additional fields describing each book, such as `title`
#'   and `author`, to add from \link{gutenberg_metadata}.
#' @param verbose Whether to show messages about the Project Gutenberg mirror
#'   that was chosen
#'
#' @return A two column `tbl_df` (see [tibble::tibble()]) with one row for each
#'   line of the text or texts, with columns
#' \describe{
#'   \item{gutenberg_id}{Integer column with the Project Gutenberg ID of
#'   each text}
#'   \item{text}{A character vector of lines of text}
#' }
#'
#' @examplesIf interactive()
#'   # download The Count of Monte Cristo
#'   gutenberg_download(1184)
#'
#'   # download two books: Wuthering Heights and Jane Eyre
#'   books <- gutenberg_download(c(768, 1260), meta_fields = "title")
#'   books
#'   dplyr::count(books, title)
#'
#'   # download all books from Jane Austen
#'   austen <- gutenberg_works(author == "Austen, Jane") %>%
#'     gutenberg_download(meta_fields = "title")
#'   austen
#'   dplyr::count(austen, title)
#'
#' @export
gutenberg_download <- function(gutenberg_id,
                               mirror = NULL,
                               strip = TRUE,
                               meta_fields = character(),
                               verbose = TRUE) {
  url <- gutenberg_url(gutenberg_id, mirror, verbose)
  downloaded <- purrr::map(url, try_gutenberg_download)
  downloaded <- purrr::discard(downloaded, is.null)
  if (strip) {
    downloaded <- purrr::map(downloaded, gutenberg_strip)
  }
  ret <- purrr::list_rbind(c(
    list(empty = tibble::tibble(gutenberg_id = integer(), text = character())),
    purrr::imap(
      downloaded,
      ~ tibble::tibble(text = .x, gutenberg_id = as.integer(.y))
    )
  ))

  gutenberg_add_metadata(ret, meta_fields)
}

#' Construct a Project Gutenberg url
#'
#' @inheritParams gutenberg_download
#'
#' @return A named character vector of urls
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
#' @return A character vector of gutenberg_ids.
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
#' @return A character vector of lines of text or NULL if the book could not be
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
        "i" = "Alternatively, You may need to select a different mirror.",
        ">" = "See https://www.gutenberg.org/MIRRORS.ALL for options."
      )
    )
  }
  return(ret)
}

#' Loop through paths to find a file
#'
#' @param possible_urls URLs to try.
#'
#' @return A character vector of lines of text or NULL if the book could not be
#'   downloaded.
#' @keywords internal
read_next <- function(possible_urls) {
  if (length(possible_urls)) {
    read_url(possible_urls[[1]]) %||% read_next(possible_urls[-1])
  }
}

#' Get the recommended mirror for Gutenberg files
#'
#' Get the recommended mirror for Gutenberg files and set the global
#' `gutenberg_mirror` options.
#'
#' @param verbose Whether to show messages about the Project Gutenberg mirror
#'   that was chosen
#'
#' @return A character vector with the url for the chosen mirror.
#'
#' @examplesIf interactive()
#'
#' gutenberg_get_mirror()
#'
#' @export
gutenberg_get_mirror <- function(verbose = TRUE) {
  mirror <- getOption("gutenberg_mirror")
  if (!is.null(mirror)) {
    return(mirror)
  }

  # figure out the mirror for this location from wget
  harvest_url <- "https://www.gutenberg.org/robot/harvest"
  maybe_message(
    verbose,
    "Determining mirror for Project Gutenberg from {harvest_url}."
  )
  wget_url <- glue::glue("{harvest_url}?filetypes[]=txt")
  lines <- read_url(wget_url)
  a <- stringr::str_subset(lines, stringr::fixed("<a href="))[1]
  mirror_full_url <- stringr::str_match(a, "href=\"(.*?)\"")[2]

  # parse and leave out the path
  parsed <- urltools::url_parse(mirror_full_url)
  if (parsed$domain == "www.gutenberg.lib.md.us") {
    # Broken mirror. PG has been contacted. For now, replace:
    parsed$domain <- "aleph.gutenberg.org" # nocov
  }

  mirror <- unclass(glue::glue_data(parsed, "{scheme}://{domain}"))
  maybe_message(verbose, "Using mirror {mirror}.")

  # set option for next time
  options(gutenberg_mirror = mirror)
  return(mirror)
}

gutenberg_add_metadata <- function(gutenberg_tbl, meta_fields) {
  meta_fields <- union("gutenberg_id", meta_fields)
  dplyr::left_join(
    gutenberg_tbl,
    gutenbergr::gutenberg_metadata[meta_fields],
    by = "gutenberg_id"
  )
}
