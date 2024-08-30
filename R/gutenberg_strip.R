#' Strip header and footer content from a Project Gutenberg book
#'
#' Strip header and footer content from a Project Gutenberg book. This
#' is based on some formatting guesses so it may not be perfect. It
#' will also not strip tables of contents, prologues, or other text
#' that appears at the start of a book.
#'
#' @param text A character vector with lines of a book.
#'
#' @return A character vector with Project Gutenberg headers and footers removed
#'
#' @examplesIf interactive()
#'
#' book <- gutenberg_works(title == "Pride and Prejudice") |>
#'   gutenberg_download(strip = FALSE)
#'
#' head(book$text, 10)
#' tail(book$text, 10)
#'
#' text_stripped <- gutenberg_strip(book$text)
#'
#' head(text_stripped, 10)
#' tail(text_stripped, 10)
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
