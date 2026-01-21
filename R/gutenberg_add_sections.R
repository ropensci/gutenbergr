#' Add a section column to a Gutenberg tibble
#'
#' @description
#' Identifies section markers (chapters, cantos, letters, etc.) in Project
#' Gutenberg texts and adds a column indicating which section each line belongs to.
#' Sections are forward-filled, so all text between markers belongs to the
#' previous section.
#'
#' @param data A [tibble::tibble] returned by [gutenberg_download].
#' @param pattern A regex pattern to identify headers. Must match the specific
#'   formatting of your book. See Details and Examples for common patterns.
#' @param format_fn Optional function to format section text. Receives the
#'   matched text and returns formatted text. Common options include
#'   [stringr::str_to_title] and [stringr::str_to_upper] but a custom function
#'   can also be provided.
#' @param ignore_case Logical; should pattern matching be case-insensitive?
#'   Default is `TRUE`.
#' @param group_by Character vector of column names to group by before filling
#'   sections. Defaults to `"gutenberg_id"` if that column exists, otherwise `NULL`.
#'   Set to `NULL` to treat entire dataset as one document.
#'
#' @details
#' ## Common Patterns for Project Gutenberg Books
#'
#' Different books use different formatting for their section markers. Here are
#' patterns for common formats:
#'
#' - **Dante's Inferno (1001)**: `"^CANTO [IVXLCDM]+"`
#' - **A Christmas Carol (46)**: `"^STAVE [IVXLCDM]+"`
#' - **Frankenstein (84)**: `"^(Letter|Chapter) [0-9]+"`
#' - **Pride and Prejudice (1342)**: `"^Chapter [0-9]+"`
#' - **Moby Dick (2701)**: `"^CHAPTER [0-9]+\\."`
#' - **Paradise Lost (26)**: `"^BOOK [IVXLCDM]+"`
#' - **Shakespeare plays**: `"^(ACT|SCENE) [IVXLCDM]+"`
#' - **Letter-based books**: `"^Letter [IVXLCDM0-9]+"`
#'
#' Use [gutenberg_works()] to search for books and examine a few lines with
#' [gutenberg_download()] to determine the exact format before writing your pattern.
#'
#' @return A [tibble::tibble()] with an added `section` column containing the section marker
#'   for each row. Rows before the first section marker will have `NA`.
#'
#' @examples
#' \dontrun{
#' # Pride and Prejudice - Chapters with numbers
#' pride_and_prejudice <- gutenberg_download(1342) |>
#'   gutenberg_add_sections(pattern = "^Chapter [0-9]+")
#'
#' # Convert to numeric for analysis
#' pride_and_prejudice <- gutenberg_download(1342) |>
#'   gutenberg_add_sections(
#'     pattern = "^Chapter [0-9]+",
#'     format_fn = function(x) as.numeric(stringr::str_extract(x, "\\d+"))
#'   )
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
#' # Classic Brontë works - Chapters with Roman Numerals
#' # Remove trailing periods from section text
#' bronte_sisters <- gutenberg_download(c(1260, 768, 969, 9182, 767)) |>
#'  gutenberg_add_sections(
#'    pattern = "^\\s*CHAPTER [IVXLCDM]+",
#'    format_fn = function(x) str_remove(x, "\\.$")
#' )
#'
#' # Disable automatic grouping for multiple books
#' # Treat as one continuous document
#' books <- gutenberg_download(c(1342, 84)) |>
#'   gutenberg_add_sections(
#'     pattern = "^Chapter [0-9]+",
#'     group_by = NULL
#'   )
#' }
#'
#' @export
gutenberg_add_sections <- function(
  data,
  pattern,
  format_fn = NULL,
  ignore_case = TRUE,
  group_by = NULL
) {
  # Default to gutenberg_id if it exists and group_by not specified
  if (is.null(group_by) && "gutenberg_id" %in% colnames(data)) {
    group_by <- "gutenberg_id"
  }

  # Group if grouping variable(s) specified
  if (!is.null(group_by)) {
    data <- dplyr::group_by(data, dplyr::across(dplyr::all_of(group_by)))
  }

  data <- data %>%
    dplyr::mutate(
      is_header = stringr::str_detect(
        text,
        stringr::regex(pattern, ignore_case = ignore_case)
      ),
      section = dplyr::if_else(
        is_header,
        stringr::str_squish(text),
        NA_character_
      )
    )

  # Apply formatting function if provided
  if (!is.null(format_fn)) {
    data <- data %>%
      dplyr::mutate(
        section = ifelse(!is.na(section), format_fn(section), NA)
      )
  }

  data <- data %>%
    tidyr::fill(section, .direction = "down") %>%
    dplyr::select(-is_header)

  # Ungroup if we grouped
  if (!is.null(group_by)) {
    data <- dplyr::ungroup(data)
  }

  return(data)
}
