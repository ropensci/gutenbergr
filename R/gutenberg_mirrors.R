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
    return(mirror)
  }

  # figure out the mirror for this location from wget
  harvest_url <- "https://www.gutenberg.org/robot/harvest"
  maybe_message(
    verbose,
    "Determining mirror for Project Gutenberg from {harvest_url}."
  )
  wget_url <- glue::glue("{harvest_url}?filetypes[]=txt")
  lines <- read_url(wget_url)
  a <- stringr::str_subset(lines, stringr::fixed("<a href="))[1]
  mirror_full_url <- stringr::str_match(a, "href=\"(.*?)\"")[2]

  # parse and leave out the path
  parsed <- urltools::url_parse(mirror_full_url)
  mirror <- unclass(glue::glue_data(parsed, "{scheme}://{domain}"))
  maybe_message(verbose, "Using mirror {mirror}.")

  # set option for next time
  options(gutenberg_mirror = mirror)
  return(mirror)
}


#' Get all mirror data from Project Gutenberg
#'
#' Get all mirror data from
#' \url{https://www.gutenberg.org/MIRRORS.ALL}.
#' This only includes mirrors reported to Project
#' Gutenberg and verified to be relatively stable.
#' For more information on mirroring and getting
#' your own mirror listed, see
#' \url{https://www.gutenberg.org/help/mirroring.html}.
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
  mirrors <- suppressWarnings( # Table has extra row that causes vroom warning
    readMDTable::read_md_table(mirrors_url, warn = FALSE, show_col_types = FALSE) |>
      dplyr::slice(2:(dplyr::n() - 1))
  )

  return(mirrors)
}
