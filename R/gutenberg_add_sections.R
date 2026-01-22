#' Add a section column to a Gutenberg tibble
#'
#' @description
#' Identifies section markers (chapters, cantos, letters, etc.) in Project
#' Gutenberg texts and adds a column indicating which section each line belongs to.
#' Sections are forward-filled, so all text between markers belongs to the
#' previous section.
#'
#' @param data A [tibble::tibble] with a `text` column containing the text to analyze.
#'   Typically `data` should be piped from [gutenberg_download] and contain a
#'   `gutenberg_id` column, but this is not required.
#' @param pattern A regex pattern to identify headers. Must match the specific
#'   formatting of your book. See Details and Examples for common patterns.
#' @param format_fn Optional function to format section text. Receives the
#'   matched text and returns formatted text. Common options include
#'   [stringr::str_to_title] and [stringr::str_to_upper] but a custom function
#'   can also be provided.
#' @param ignore_case Logical; should pattern matching be case-insensitive?
#'   Default is `TRUE`.
#' @param group_by Character vector of column names to group by before filling
#'   sections, or `NULL` to disable grouping. Defaults to `"auto"`, which
#'   automatically uses `"gutenberg_id"` if that column exists. Set to `NULL`
#'   to treat the entire dataset as one document, or specify custom column
#'   names for grouping (e.g., `group_by = "book_title"`).
#' @param section_col Character string specifying the name of the section column
#'   to create. Defaults to `"section"`.
#'
#' @details
#' ## Common Section Patterns for Project Gutenberg Books
#'
#' Different books use different formatting for their section markers. Here are
#' patterns for common formats:
#'
#' - Chapters with Roman numerals: `"^Chapter [IVXLCDM]+"`
#' - Chapters with Arabic numerals: `"^Chapter [0-9]+"`
#' - Books (e.g., *Paradise Lost*): `"^BOOK [IVXLCDM]+"`
#' - Cantos (e.g., *Dante's Inferno*): `"^CANTO [IVXLCDM]+"`
#' - Staves (e.g., *A Christmas Carol*): `"^STAVE [IVXLCDM]+"`
#' - Parts or sections: `"^(PART|SECTION) [IVXLCDM0-9]+"`
#' - Letters: `"^Letter [IVXLCDM0-9]+"`
#' - Plays (acts and scenes): `"^(ACT|SCENE) [IVXLCDM]+"`
#' - Multiple formats (e.g., *Frankenstein*): `"^(Letter|Chapter) [0-9]+"`
#'
#' Use [gutenberg_works()] to search for books and examine a few lines with
#' [gutenberg_download()] to determine the exact format before writing your pattern.
#'
#' @return A [tibble::tibble] with an added column named according to
#'   `section_col`, containing the section marker for each row. Rows before the
#'   first section marker will have `NA`.
#'
#' @examples
#' \dontrun{
#'
#' # Dante's Inferno - Cantos with Roman numerals
#' inferno <- gutenberg_download(1001) |>
#'   gutenberg_add_sections(pattern = "^CANTO [IVXLCDM]+")
#'
#' # Frankenstein - Letters and Chapters, normalized to title case
#' frankenstein <- gutenberg_download(84) |>
#'   gutenberg_add_sections(
#'     pattern = "^(Letter|Chapter) [0-9]+",
#'     format_fn = stringr::str_to_title
#'   )
#'
#' # Classic Brontë works - Chapters with Roman numerals
#' # Remove trailing periods from section text
#' # Consider using `options(gutenbergr_cache_type = "persistent")`
#' # to prevent redownloading in the future.
#' bronte_sisters <- gutenberg_download(
#'   c(1260, 768, 969, 9182, 767),
#'   meta_fields = c("author", "title")
#' ) |>
#'   gutenberg_add_sections(
#'     pattern = "^\\s*CHAPTER [IVXLCDM]+",
#'     format_fn = function(x) str_remove(x, "\\.$")
#'   )
#' }
#'
#' # Leo Tolstoy's War and Peace
#' # Add two custom named columns for hierarchical sections
#' war_and_peace <- gutenberg_download(2600) |>
#'   gutenberg_add_sections(
#'     pattern = "^BOOK [A-Z]+",
#'     section_col = "book"
#'   ) |>
#'  gutenberg_add_sections(
#'    pattern = "^CHAPTER [IVXLCDM]+",
#'    section_col = "chapter"
#'  )
#'
#' @export
gutenberg_add_sections <- function(
  data,
  pattern,
  ignore_case = TRUE,
  format_fn = NULL,
  group_by = "auto",
  section_col = "section"
) {
  # Default to gutenberg_id if it exists and group_by is "auto"
  if (identical(group_by, "auto")) {
    if ("gutenberg_id" %in% colnames(data)) {
      group_by <- "gutenberg_id"
    } else {
      group_by <- NULL
    }
  }

  # Group if grouping variable(s) specified
  if (!is.null(group_by)) {
    data <- dplyr::group_by(
      data,
      dplyr::across(dplyr::all_of(group_by))
    )
  }

  section_sym <- rlang::sym(section_col)

  data <- data |>
    dplyr::mutate(
      is_header = stringr::str_detect(
        text,
        stringr::regex(pattern, ignore_case = ignore_case)
      ),
      !!section_sym := dplyr::if_else(
        is_header,
        stringr::str_squish(text),
        NA_character_
      )
    )

  # Apply formatting function if provided
  if (!is.null(format_fn)) {
    data <- data |>
      dplyr::mutate(
        !!section_sym := {
          out <- format_fn(!!section_sym)
          out[is.na(!!section_sym)] <- NA
          out
        }
      )
  }

  data <- data |>
    tidyr::fill(!!section_sym, .direction = "down") |>
    dplyr::select(-is_header)

  # Ungroup if we grouped
  if (!is.null(group_by)) {
    data <- dplyr::ungroup(data)
  }

  data
}
