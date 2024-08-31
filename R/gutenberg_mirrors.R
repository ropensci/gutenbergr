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
  if (parsed$domain == "www.gutenberg.lib.md.us") {
    # Broken mirror. PG has been contacted. For now, replace:
    parsed$domain <- "aleph.gutenberg.org" # nocov
  }

  mirror <- unclass(glue::glue_data(parsed, "{scheme}://{domain}"))
  maybe_message(verbose, "Using mirror {mirror}.")

  # set option for next time
  options(gutenberg_mirror = mirror)
  return(mirror)
}
