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
    if (is_working_gutenberg_mirror(mirror)) {
      return(mirror)
    } else {
      maybe_message(
        verbose,
        paste0(
          "Mirror {mirror} set by options(gutenberg_mirror = {mirror}) is not ",
          "accessible. It may not be a Gutenberg mirror or may no longer be ",
          "maintained. Checking for new mirror."
        ),
        class = "mirror-refresh"
      )
    }
  }

  # Default to mirror maintained by Project Gutenberg
  all_mirrors <- gutenberg_get_all_mirrors()
  mirror_full_url <- dplyr::filter(
    all_mirrors,
    .data$provider == "Project Gutenberg",
    stringr::str_starts(.data$url, "https")
  ) |>
    utils::head(1) |>
    dplyr::pull(.data$url)

  # parse and leave out any path
  parsed <- urltools::url_parse(mirror_full_url)
  mirror <- unclass(glue::glue_data(parsed, "{scheme}://{domain}"))
  maybe_message(
    verbose,
    "Using mirror {mirror}.",
    class = "mirror-found"
  )

  # set option for next time
  options(gutenberg_mirror = mirror)
  return(mirror)
}


#' Get all mirror data from Project Gutenberg
#'
#' Get all mirror data from \url{https://www.gutenberg.org/MIRRORS.ALL}. This
#' only includes mirrors reported to Project Gutenberg and verified to be
#' relatively stable. For more information on mirroring and getting your own
#' mirror listed, see \url{https://www.gutenberg.org/help/mirroring.html}.
#'
#' @return A tbl_df of Project Gutenberg mirrors and related data
#' \describe{
#'
#'   \item{continent}{Continent where the mirror is located}
#'
#'   \item{nation}{Nation where the mirror is located}
#'
#'   \item{location}{Location of the mirror}
#'
#'   \item{provider}{Provider of the mirror}
#'
#'   \item{url}{URL of the mirror}
#'
#'   \item{note}{Special notes}
#' }
#' @examplesIf interactive()
#'
#' gutenberg_get_all_mirrors()
#'
#' @export
gutenberg_get_all_mirrors <- function() {
  mirrors_url <- "https://www.gutenberg.org/MIRRORS.ALL"
  mirrors <- purrr::quietly(read_md_table)(
    mirrors_url,
    warn = FALSE,
    force = TRUE,
    show_col_types = FALSE
  )
  if (
    length(mirrors$warnings) &&
      !(length(mirrors$warnings) == 1 &&
        all(stringr::str_detect(
          mirrors$warnings,
          "One or more parsing issues"
        )))
  ) {
    cli::cli_abort(
      "Unexpected warning in {.code read_md_table()}.",
      class = "gutenbergr-error-mirror_table_reading"
    )
  }
  mirrors <- dplyr::slice(mirrors$result, 2:(dplyr::n() - 1))

  return(mirrors)
}

#' Check if an http(s) or ftp(s) `url` resolves to a working Gutenberg mirror.
#'
#' Checks for a root level `README` file at `url` with reference to
#' `GUTINDEX.ALL`. If this exists, `url` is most likely a working
#' Gutenberg mirror.
#'
#' @return Boolean: whether the `url` resolves to a mirror.
#'
#' @keywords internal
is_working_gutenberg_mirror <- function(url) {
  base_url <- sub("/+$", "", url)
  readme_url <- paste0(base_url, "/README")
  readme <- read_url(readme_url)
  contains_pg_string <- any(grepl("GUTINDEX.ALL", readme))
  contains_pg_string
}
