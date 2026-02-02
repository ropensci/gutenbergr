#' Read a file from a URL
#'
#' Quietly download, read, and delete file
#'
#' @param url URL to a file
#' @return A character vector of lines of text or `NULL` if the file could not be
#'   downloaded.
#' @keywords internal
read_url <- function(url) {
  return(suppressWarnings(purrr::possibly(dl_and_read)(url)))
}

#' Loop through paths to find a file
#'
#' @param possible_urls URLs to try.
#'
#' @return A character vector of lines of text or `NULL` if the book could not be
#'   downloaded.
#' @keywords internal
read_next <- function(possible_urls) {
  if (length(possible_urls)) {
    read_url(possible_urls[[1]]) %||% read_next(possible_urls[-1])
  }
}

#' Download and read a file
#'
#' @inheritParams read_url
#'
#' @return A character vector with one element for each line.
#' @keywords internal
dl_and_read <- function(url) {
  # nocov start
  mode <- ifelse(.Platform$OS.type == "windows", "wb", "w")
  tmp <- tempfile()
  on.exit(unlink(tmp))
  utils::download.file(
    url,
    tmp,
    mode = mode,
    quiet = TRUE,
    headers = c(
      "User-Agent" = "gutenbergr (https://github.com/ropensci/gutenbergr)"
    )
  )
  readr::read_lines(tmp)
} # nocov end

#' Discard all values at the start of .x while .p is true
#'
#' @param .x Vector
#' @param .p Logical vector
#' @return A vector the same type as `.x` with leading elements removed.
#' @keywords internal
discard_start_while <- function(.x, .p) {
  if (.p[1] && any(!.p)) {
    .x <- utils::tail(.x, -(min(which(!.p)) - 1))
  }
  .x
}

#' Keep values at the start of .x while .p is true
#'
#' @param .x Vector
#' @param .p Logical vector
#' @return A vector the same type as `.x` with only leading elements where `.p` is `TRUE`.
#' @keywords internal
keep_while <- function(.x, .p) {
  if (.p[1] && any(!.p)) {
    .x <- utils::head(.x, min(which(!.p)) - 1)
  }
  .x
}

#' Discard all values at the end of .x while .p is true
#'
#' @param .x Vector
#' @param .p Logical vector
#' @return A vector the same type as `.x` with trailing elements removed.
#' @keywords internal
discard_end_while <- function(.x, .p) {
  rev(discard_start_while(rev(.x), rev(.p)))
}

#' Display a message conditionally
#'
#' @param verbose Logical; whether to display the message.
#' @param message Message to display.
#' @param class Optional message class.
#' @param ... Additional arguments passed to `cli::cli_inform()`.
#' @param call The execution environment of the calling function.
#' @return Invisibly returns `NULL`. Called for its side effect of displaying a message.
#' @keywords internal
maybe_message <- function(
  verbose,
  message,
  class = NULL,
  ...,
  call = rlang::caller_env()
) {
  if (verbose) {
    if (length(class)) {
      class <- paste0("gutenbergr-msg-", class)
    } else {
      class <- "gutenbergr-msg"
    }
    cli::cli_inform(message, class = class, ..., .envir = call)
  }
}
