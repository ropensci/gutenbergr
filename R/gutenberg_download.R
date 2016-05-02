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
#' a \code{gutenberg_works()} call.
#' @param mirror Optionally a mirror URL to retrieve the books from. By
#' default uses the mirror from \code{\link{gutenberg_get_mirror}}.
#' @param strip Whether to strip suspected headers and footers using the
#' \code{\link{gutenberg_strip}} function
#' @param meta_fields Additional fields, such as \code{title} and \code{author},
#' to add from \link{gutenberg_metadata} describing each book. This is useful
#' when returning multiple.
#' @param ... Extra arguments passed to \code{\link{gutenberg_strip}}, currently
#' unused
#'
#' @details Note that if \code{strip = TRUE}, this tries to remove the
#' Gutenberg header and footer using the \code{\link{gutenberg_strip}}
#' function. This is not an exact process since headers and footers differ
#' between books. Before doing an in-depth analysis you may want to check
#' the start and end of each downloaded book.
#'
#' @return A two column data frame with one row for each line of the
#' text or texts, with columns
#' \describe{
#'   \item{gutenberg_id}{Integer column with the Project Gutenberg ID of
#'   each text}
#'   \item{text}{A character vector}
#' }
#'
#' @examples
#'
#' \dontrun{
#' # load dplyr first to display tbl_dfs appropriately
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
#'  count(title)
#' }
#'
#' @import dplyr
#'
#' @export
gutenberg_download <- function(gutenberg_id, mirror = NULL, strip = TRUE,
                               meta_fields = NULL, ...) {
  if (is.null(mirror)) {
    mirror <- gutenberg_get_mirror()
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
    sapply(stringr::str_c, collapse = "/")

  path <- ifelse(nchar(id) == 1, "0", path)

  full_url <- stringr::str_c(mirror, path, id,
                             stringr::str_c(id, ".zip"),
                             sep = "/")
  names(full_url) <- id

  try_download <- function(url) {
    ret <- read_zip_url(url)
    if (!is.null(ret)) {
      return(ret)
    }
    base_url <- stringr::str_replace(url, ".zip$", "")
    for (suffix in c("-8", "-0")) {
      new_url <- paste0(base_url, suffix, ".zip")
      ret <- read_zip_url(new_url)
      if (!is.null(ret)) {
        return(ret)
      }
    }
    warning("Could not download a book at ", url)

    NULL
  }

  # run this on all requested books
  ret <- full_url %>%
    purrr::map(try_download) %>%
    purrr::discard(is.null) %>%
    purrr::map_df(~data_frame(text = .), .id = "gutenberg_id") %>%
    mutate(gutenberg_id = as.integer(gutenberg_id))

  if (strip) {
    ret <- ret %>%
      group_by(gutenberg_id) %>%
      do(data_frame(text = gutenberg_strip(.$text, ...))) %>%
      ungroup()
  }

  if (length(meta_fields) > 0) {
    meta_fields <- unique(c("gutenberg_id", meta_fields))

    utils::data("gutenberg_metadata", package = "gutenbergr", envir = environment())
    md <- gutenberg_metadata[meta_fields]

    ret <- ret %>%
      inner_join(md, by = "gutenberg_id")
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
#' @export
gutenberg_strip <- function(text) {
  text[is.na(text)] <- ""

  starting_regex <- "(^\\*\\*\\*.*PROJECT GUTENBERG|END.*SMALL PRINT)"
  text <- discard_start_while(text, !stringr::str_detect(text, starting_regex))[-1]
  # also discard rest of "paragraph"
  text <- discard_start_while(text, text != "")

  ending_regex <- "^(End of .*Project Gutenberg.*|\\*\\*\\*.*END OF.*PROJECT GUTENBERG)"
  text <- keep_while(text, !stringr::str_detect(text, ending_regex))

  # strip empty lines from start and end
  text <- discard_start_while(text, text == "")

  # also paragraphs at the start that are meta-data
  start_paragraph_regex <- "(produced by|prepared by|transcribed from|project gutenberg|^note: )"
  while (length(text) > 0 &&
         stringr::str_detect(stringr::str_to_lower(text[1]), start_paragraph_regex)) {
    # get rid of that paragraph, then the following whitespace
    text <- discard_start_while(text, text != "")
    text <- discard_start_while(text, text == "")
  }

  text <- discard_end_while(text, text == "")

  text
}


#' Get the recommended mirror for Gutenberg files
#'
#' Get the recommended mirror for Gutenberg files by accessing
#' the wget harvest path, which is
#' \url{http://www.gutenberg.org/robot/harvest?filetypes[]=txt}.
#' Also set the global \code{gutenberg_mirror} option
#'
#' @export
gutenberg_get_mirror <- function() {
  mirror <- getOption("gutenberg_mirror")
  if (!is.null(mirror)) {
    return(mirror)
  }

  # figure out the mirror for this location from wget
  message("Determining mirror for Gutenberg http://www.gutenberg.org/robot/harvest")
  wget_url <- "http://www.gutenberg.org/robot/harvest?filetypes[]=txt"
  mirror_full_url <- xml2::read_html(wget_url) %>%
    rvest::html_nodes("a") %>%
    .[[1]] %>%
    rvest::html_attr("href")

  # parse and leave out the path
  parsed <- urltools::url_parse(mirror_full_url)
  mirror <- paste0(parsed$scheme, "://", parsed$domain)

  # set option for next time
  options(gutenberg_mirror = mirror)

  return(mirror)
}
