#' Get a filtered table of Gutenberg work metadata
#'
#' Get a table of Gutenberg work metadata that has been filtered by some common
#' (settable) defaults, along with the option to add additional filters
#' This function is for convenience when working with common conditions
#' when pulling a set of books to analyze.
#' For more detailed filtering of the entire Project Gutenberg
#' metadata, use the \link{gutenberg_metadata} and related datasets.
#'
#' @param ... Additional filters, given as expressions using the variables
#' in the \link{gutenberg_metadata} dataset (e.g. \code{author == "Austen, Jane"})
#' @param languages Vector of languages to include (note that it will not
#' return cases with multiple languages unless they are specified)
#' @param only_text Whether the works must have Gutenberg text attached. Works
#' without text (e.g. audiobooks) cannot be downloaded with
#' \code{\link{gutenberg_download}}.
#' @param rights Values to allow in the \code{rights} field. By default allows
#' public domain in the US or "None", while excluding works under copyright.
#' @param distinct Whether to return only one distinct combination of each
#' title and gutenberg_author_id. If multiple occur (that fulfill the other
#' conditions), it uses the one with the lowest ID.
#'
#' @details By default, returns
#'
#' \itemize{
#'   \item{English-language works}
#'   \item{That are in text format in Gutenberg (as opposed to audio)}
#'   \item{Whose text is not under copyright}
#'   \item{At most one distinct field for each title/author pair}
#' }
#'
#' @examples
#'
#' gutenberg_works()
#'
#' # filter conditions
#' gutenberg_works(author == "Shakespeare, William")
#'
#' # changing default options
#' gutenberg_works(rights = NULL)
#' gutenberg_works(languages = "de")
#'
#' @export
gutenberg_works <- function(..., languages = "en",
                            only_text = TRUE,
                            rights = c("Public domain in the USA.", "None"),
                            distinct = TRUE) {
  utils::data("gutenberg_metadata", package = "gutenbergr", envir = environment())
  ret <- filter(gutenberg_metadata, ...)

  if (!is.null(languages)) {
    ret <- filter(ret, language %in% languages)
  }

  if (!is.null(rights)) {
    .rights <- rights
    ret <- filter(ret, rights %in% .rights)
  }

  if (only_text) {
    ret <- filter(ret, has_text)
  }

  if (distinct) {
    ret <- distinct_(ret, "title", "gutenberg_author_id")
  }

  ret
}
