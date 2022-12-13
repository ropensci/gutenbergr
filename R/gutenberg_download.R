#' Download one or more works using a Project Gutenberg ID
#'
#' Download one or more works by their Project Gutenberg IDs into
#' a data frame with one row per line per work. This can be used to download
#' a single work of interest or multiple at a time. You can look up the
#' Gutenberg IDs of a work using the \code{gutenberg_works()} function or
#' the \code{gutenberg_metadata} dataset.
#'
#' @param gutenberg_id A vector of Project Gutenberg ID, or a data frame
#' containing a \code{gutenberg_id} column, such as from the results of
#' a \code{gutenberg_works()} call
#' @param mirror Optionally a mirror URL to retrieve the books from. By
#' default uses the mirror from \code{\link{gutenberg_get_mirror}}
#' @param strip Whether to strip suspected headers and footers using the
#' \code{\link{gutenberg_strip}} function
#' @param meta_fields Additional fields, such as \code{title} and \code{author},
#' to add from \link{gutenberg_metadata} describing each book. This is useful
#' when returning multiple
#' @param verbose Whether to show messages about the Project Gutenberg
#' mirror that was chosen
#' @param files A vector of .zip file paths. If given, this reads from the
#' files rather than from the site. This is mostly used for testing when
#' the Project Gutenberg website may not be available.
#' @param ... Extra arguments passed to \code{\link{gutenberg_strip}}, currently
#' unused
#'
#' @details Note that if \code{strip = TRUE}, this tries to remove the
#' Gutenberg header and footer using the \code{\link{gutenberg_strip}}
#' function. This is not an exact process since headers and footers differ
#' between books. Before doing an in-depth analysis you may want to check
#' the start and end of each downloaded book.
#'
#' @return A two column tbl_df (a type of data frame; see tibble or
#' dplyr packages) with one row for each line of the text or texts,
#' with columns
#' \describe{
#'   \item{gutenberg_id}{Integer column with the Project Gutenberg ID of
#'   each text}
#'   \item{text}{A character vector}
#' }
#'
#' @examples
#' \donttest{
#' library(dplyr)
#'
#' # download The Count of Monte Cristo
#' gutenberg_download(1184)
#'
#' # download two books: Wuthering Heights and Jane Eyre
#' books <- gutenberg_download(c(768, 1260), meta_fields = "title")
#' books
#' books %>% count(title)
#'
#' # download all books from Jane Austen
#' austen <- gutenberg_works(author == "Austen, Jane") %>%
#'   gutenberg_download(meta_fields = "title")
#'
#' austen
#' austen %>%
#'   count(title)
#' }
#'
#' @export
gutenberg_download <- function(gutenberg_id, mirror = NULL, strip = TRUE,
                               meta_fields = NULL, verbose = TRUE,
                               files = NULL, ...) {
  if (is.null(mirror)) {
    mirror <- gutenberg_get_mirror(verbose = verbose)
  }

  if (inherits(gutenberg_id, "data.frame")) {
    # extract the gutenberg_id column. This is useful for working
    # with the output of gutenberg_works()
    gutenberg_id <- gutenberg_id[["gutenberg_id"]]
  }

  id <- as.character(gutenberg_id)

  path <- id %>%
    stringr::str_sub(1, -2) %>%
    stringr::str_split("") %>%
    purrr::map_chr(stringr::str_c, collapse = "/")

  path <- ifelse(nchar(id) == 1, "0", path)

  full_url <- stringr::str_c(mirror, path, id,
    stringr::str_c(id, ".zip"),
    sep = "/"
  )
  names(full_url) <- id

  try_download <- function(url) {
    ret <- read_zip_url(url)
    if (!is.null(ret)) {
      return(ret)
    }
    base_url <- stringr::str_replace(url, ".zip$", "")
    for (suffix in c("-8", "-0")) {
      new_url <- glue::glue("{base_url}{suffix}.zip")
      ret <- read_zip_url(new_url)
      if (!is.null(ret)) {
        return(ret)
      }
    }

    cli::cli_warn(
      c(
        "!" = "Could not download a book at {url}.",
        "i" = "The book may have been archived.",
        "i" = "Alternatively, You may need to select a different mirror.",
        ">" = "See https://www.gutenberg.org/MIRRORS.ALL for options."
      )
    )

    NULL
  }

  # run this on all requested books
  if (!is.null(files)) {
    # Read from local files instead (used for testing)
    downloaded <- files %>%
      stats::setNames(id) %>%
      purrr::map(readr::read_lines)
  } else {
    downloaded <- full_url %>%
      purrr::map(try_download)
  }

  ret <- downloaded %>%
    purrr::discard(is.null) %>%
    purrr::map_df(~ dplyr::tibble(text = .), .id = "gutenberg_id") %>%
    dplyr::mutate(gutenberg_id = as.integer(gutenberg_id))

  if (strip) {
    ret <- ret %>%
      dplyr::group_by(gutenberg_id) %>%
      dplyr::do(dplyr::tibble(text = gutenberg_strip(.$text, ...))) %>%
      dplyr::ungroup()
  }

  if (length(meta_fields) > 0) {
    meta_fields <- unique(c("gutenberg_id", meta_fields))

    utils::data(
      "gutenberg_metadata",
      package = "gutenbergr",
      envir = environment()
    )
    md <- gutenberg_metadata[meta_fields]

    ret <- ret %>%
      dplyr::inner_join(md, by = "gutenberg_id")
  }

  ret
}


#' Strip header and footer content from a Project Gutenberg book
#'
#' Strip header and footer content from a Project Gutenberg book. This
#' is based on some formatting guesses so it may not be perfect. It
#' will also not strip tables of contents, prologues, or other text
#' that appears at the start of a book.
#'
#' @param text A character vector with lines of a book
#'
#' @return A character vector with Project Gutenberg headers and footers removed
#'
#' @examples
#'\donttest{
#' library(dplyr)
#' book <- gutenberg_works(title == "Pride and Prejudice") %>%
#'   gutenberg_download(strip = FALSE)
#'
#' head(book$text, 10)
#' tail(book$text, 10)
#'
#' text_stripped <- gutenberg_strip(book$text)
#'
#' head(text_stripped, 10)
#' tail(text_stripped, 10)
#'}
#'
#' @export
gutenberg_strip <- function(text) {
  text[is.na(text)] <- ""

  starting_regex <- "(^\\*\\*\\*.*PROJECT GUTENBERG|END.*SMALL PRINT)"
  text <- discard_start_while(
    text, !stringr::str_detect(text, starting_regex)
  )[-1]
  # also discard rest of "paragraph"
  text <- discard_start_while(text, text != "")

  ending_regex <- paste(
    "^(End of .*Project Gutenberg.*",
    "\\*\\*\\*.*END OF.*PROJECT GUTENBERG)",
    sep = "|"
  )
  text <- keep_while(text, !stringr::str_detect(text, ending_regex))

  # strip empty lines from start and end
  text <- discard_start_while(text, text == "")

  # also paragraphs at the start that are meta-data
  start_paragraph_regex <- paste(
    "(produced by",
    "prepared by",
    "transcribed from",
    "project gutenberg",
    "^special thanks",
    "^note: )",
    sep = "|"
  )
  while (
    length(text) > 0 &&
      stringr::str_detect(stringr::str_to_lower(text[1]), start_paragraph_regex)
  ) {
    # get rid of that paragraph, then the following whitespace
    text <- discard_start_while(text, text != "")
    text <- discard_start_while(text, text == "")
  }

  text <- discard_end_while(text, text == "")

  text
}


#' Get the recommended mirror for Gutenberg files
#'
#' Get the recommended mirror for Gutenberg files and set the global \code{gutenberg_mirror} options.
#'
#' @param verbose Whether to show messages about the Project Gutenberg
#' mirror that was chosen
#'
#' @return A character vector of the url for mirror to be used
#' @examples
#' gutenberg_get_mirror()
#'
#' @export
gutenberg_get_mirror <- function(verbose = TRUE) {
  mirror <- getOption("gutenberg_mirror")
  if (!is.null(mirror)) {
    return(mirror)
  }

  # figure out the mirror for this location from wget
  if (verbose) {
    message(
      "Determining mirror for Project Gutenberg from ",
      "https://www.gutenberg.org/robot/harvest"
    )
  }
  wget_url <- "https://www.gutenberg.org/robot/harvest?filetypes[]=txt"
  lines <- readr::read_lines(wget_url)
  a <- lines[stringr::str_detect(lines, stringr::fixed("<a href="))][1]
  mirror_full_url <- stringr::str_match(a, "href=\"(.*?)\"")[2]

  # parse and leave out the path
  parsed <- urltools::url_parse(mirror_full_url)
  mirror <- glue::glue("{parsed$scheme}://{parsed$domain}")

  if (mirror == "https://www.gutenberg.lib.md.us") { # nocov start
    # this mirror is broken (PG has been contacted)
    # for now, replace:
    mirror <- "https://aleph.gutenberg.org"
  } # nocov end

  if (verbose) {
    message("Using mirror ", mirror)
  }

  # set option for next time
  options(gutenberg_mirror = mirror)

  return(mirror)
}
