#' Get a filtered table of Gutenberg work metadata
#'
#' Get a table of Gutenberg work metadata that has been filtered by some common
#' (settable) defaults, along with the option to add additional filters. This
#' function is for convenience when working with common conditions when pulling
#' a set of books to analyze. For more detailed filtering of the entire Project
#' Gutenberg metadata, use the [gutenberg_metadata] and related datasets.
#'
#' @param ... Additional filters, given as expressions using the variables in
#'   the [gutenberg_metadata] dataset (e.g. `author == "Austen, Jane"`).
#' @param languages Vector of languages to include.
#' @param only_text Whether the works must have Gutenberg text attached. Works
#'   without text (e.g. audiobooks) cannot be downloaded with
#'   [gutenberg_download()].
#' @param rights Values to allow in the `rights` field. By default allows
#'   public domain in the US or "None", while excluding works under copyright.
#'   `NULL` allows any value of Rights.
#' @param distinct Whether to return only one distinct combination of each title
#'   and `gutenberg_author_id`. If multiple occur (that fulfill the other
#'   conditions), it uses the one with the lowest ID.
#' @param all_languages Whether, if multiple languages are given, all of them
#'   need to be present in a work. For example, if `c("en", "fr")` are
#'   given, whether only `en/fr` as opposed to English or French works
#'   should be returned.
#' @param only_languages Whether to exclude works that have other languages
#'   besides the ones provided. For example, whether to include `en/fr`
#'   when English works are requested.
#'
#' @return A [tibble::tibble()] with one row for each work, in the same format 
#'   as [gutenberg_metadata].
#'
#' @details By default, returns:
#' * English-language works.
#' * Works that are in text format in Gutenberg (as opposed to audio).
#' * Works whose text is not under copyright.
#' * At most one distinct field for each title/author pair.
#'
#' @examplesIf interactive()
#' library(dplyr)
#'
#' # Default: English, text-based, public domain works
#' gutenberg_works()
#'
#' # Filter conditions using ...
#' gutenberg_works(author == "Shakespeare, William")
#'
#' # Language specifications
#' gutenberg_works(languages = "es") |>
#'   count(language, sort = TRUE)
#'
#' # Filter for works that are specifically English AND French
#' gutenberg_works(languages = c("en", "fr"), all_languages = TRUE)
#'
#' @export
gutenberg_works <- function(
  ...,
  languages = "en",
  only_text = TRUE,
  rights = c("Public domain in the USA.", "None"),
  distinct = TRUE,
  all_languages = FALSE,
  only_languages = TRUE
) {
  rlang::check_dots_unnamed(
    error = function(e) {
      cli::cli_abort(
        c(
          x = "We detected a named input.",
          i = "Use == expressions, not named arguments.",
          i = "For example, use gutenberg_works(author == 'Dickens, Charles'),",
          i = "not gutenberg_works(author = 'Dickens, Charles')."
        ),
        call = rlang::env_parent()
      )
    }
  )
  ret <- dplyr::filter(gutenberg_metadata, ...)

  if (!is.null(languages)) {
    lang_filt <- gutenberg_languages |>
      dplyr::filter(.data$language %in% languages) |>
      dplyr::count(.data$gutenberg_id, .data$total_languages)

    if (all_languages) {
      lang_filt <- lang_filt |>
        dplyr::filter(.data$n >= length(languages))
    }
    if (only_languages) {
      lang_filt <- lang_filt |>
        dplyr::filter(.data$total_languages <= n)
    }

    ret <- ret |>
      dplyr::semi_join(lang_filt, by = "gutenberg_id")
  }

  if (!is.null(rights)) {
    ret <- dplyr::filter(ret, .data$rights %in% .env$rights)
  }

  if (only_text) {
    ret <- dplyr::filter(ret, .data$has_text)
  }

  if (distinct) {
    ret <- dplyr::distinct(
      ret,
      .data$title,
      .data$gutenberg_author_id,
      .keep_all = TRUE
    )
  }

  ret
}
