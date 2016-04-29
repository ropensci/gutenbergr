#' Download a book using its Gutenberg ID
#'
#' @param gutenberg_id A vector of Project Gutenberg ID
#' @param mirror Optionally a mirror URL to retrieve the books from
#' @param strip Whether to strip suspected headers and footers
#' @param ... Extra arguments passed to \code{\link{gutenberg_strip}}
#'
#' @import dplyr
#'
#' @export
gutenberg_download <- function(gutenberg_id, mirror = NULL, strip = TRUE, ...) {
  if (is.null(mirror)) {
    mirror <- gutenberg_get_mirror()
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
    ret <-
      ret %>%
      group_by(gutenberg_id) %>%
      do(data_frame(text = gutenberg_strip(.$text))) %>%
      ungroup()
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
