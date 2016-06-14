#' Get a filtered table of Gutenberg work metadata
#'
#' Get a table of Gutenberg work metadata that has been filtered by some common
#' (settable) defaults, along with the option to add additional filters.
#' This function is for convenience when working with common conditions
#' when pulling a set of books to analyze.
#' For more detailed filtering of the entire Project Gutenberg
#' metadata, use the \link{gutenberg_metadata} and related datasets.
#'
#' @param ... Additional filters, given as expressions using the variables
#' in the \link{gutenberg_metadata} dataset (e.g. \code{author == "Austen, Jane"})
#' @param languages Vector of languages to include
#' @param only_text Whether the works must have Gutenberg text attached. Works
#' without text (e.g. audiobooks) cannot be downloaded with
#' \code{\link{gutenberg_download}}
#' @param rights Values to allow in the \code{rights} field. By default allows
#' public domain in the US or "None", while excluding works under copyright.
#' NULL allows any value of Rights
#' @param distinct Whether to return only one distinct combination of each
#' title and gutenberg_author_id. If multiple occur (that fulfill the other
#' conditions), it uses the one with the lowest ID
#' @param all_languages Whether, if multiple languages are given, all of them
#' need to be present in a work. For example, if \code{c("en", "fr")} are given,
#' whether only \code{en/fr} as opposed to English or French works should be
#' returned
#' @param only_languages Whether to exclude works that have other languages
#' besides the ones provided. For example, whether to include \code{en/fr}
#' when English works are requested
#'
#' @return A tbl_df (see the tibble or dplyr packages) with one row for
#' each work, in the same format as \link{gutenberg_metadata}.
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
#' library(dplyr)
#'
#' gutenberg_works()
#'
#' # filter conditions
#' gutenberg_works(author == "Shakespeare, William")
#'
#' # language specifications
#'
#' gutenberg_works(languages = "es") %>%
#'   count(language, sort = TRUE)
#'
#' gutenberg_works(languages = c("en", "es")) %>%
#'   count(language, sort = TRUE)
#'
#' gutenberg_works(languages = c("en", "es"), all_languages = TRUE) %>%
#'   count(language, sort = TRUE)
#'
#' gutenberg_works(languages = c("en", "es"), only_languages = FALSE) %>%
#'   count(language, sort = TRUE)
#'
#' @export
gutenberg_works <- function(..., languages = "en",
                            only_text = TRUE,
                            rights = c("Public domain in the USA.", "None"),
                            distinct = TRUE,
                            all_languages = FALSE,
                            only_languages = TRUE) {
  dots <- lazyeval::lazy_dots(...)
  if (length(dots) > 0 && any(names(dots) != "")) {
    stop("Use == expressions, not named arguments, as extra arguments to ",
         "gutenberg_works. E.g. use gutenberg_works(author == 'Dickens, Charles') ",
         "not gutenberg_works(author = 'Dickens, Charles').")
  }
  ret <- filter_(gutenberg_metadata, .dots = dots)

  if (!is.null(languages)) {
    lang_spl <- ret %>%
      select(gutenberg_id, language) %>%
      tidyr::unnest(language = stringr::str_split(language, "/")) %>%
      group_by(gutenberg_id) %>%
      mutate(total = n()) %>%
      ungroup()

    lang_filt <- lang_spl %>%
      filter(language %in% languages) %>%
      group_by(gutenberg_id) %>%
      mutate(number = n()) %>%
      ungroup()

    if (all_languages) {
      lang_filt <- lang_filt %>%
        filter(number >= length(languages))
    }
    if (only_languages) {
      lang_filt <- lang_filt %>%
        filter(total == number)
    }

    ret <- ret %>%
      filter(gutenberg_id %in% lang_filt$gutenberg_id)
  }

  if (!is.null(rights)) {
    .rights <- rights
    ret <- filter(ret, rights %in% .rights)
  }

  if (only_text) {
    ret <- filter(ret, has_text)
  }

  if (distinct) {
    ret <- distinct_(ret, "title", "gutenberg_author_id", .keep_all = TRUE)
    # in older versions of dplyr, distinct_ didn't need .keep_all
    if (any(colnames(ret) == ".keep_all")) {
      ret$.keep_all <- NULL
    }
  }

  ret
}
