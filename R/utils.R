#' Read a file from a URL
#'
#' Quietly download, read, and delete file
#'
#' @param url URL to a file
#' @keywords internal
read_url <- function(url) {
  return(suppressWarnings(purrr::possibly(dl_and_read)(url)))
}


#' Download and read a file
#'
#' @inheritParams read_url
#'
#' @return A character vector with one element for each line.
#' @keywords internal
dl_and_read <- function(url) { # nocov start
  mode <- ifelse(.Platform$OS.type == "windows", "wb", "w")
  tmp <- tempfile()
  on.exit(unlink(tmp))
  utils::download.file(url, tmp, mode = mode, quiet = TRUE)
  readr::read_lines(tmp)
} # nocov end

#' Discard all values at the start of .x while .p is true
#'
#' @param .x Vector
#' @param .p Logical vector
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
#' @keywords internal
keep_while <- function(.x, .p) {
  if (.p[1] && any(!.p)) {
    .x <- utils::head(.x, min(which(!.p)) - 1)
  }
  .x
}


#' Discard all values at the start of .x while .p is true
#'
#' @param .x Vector
#' @param .p Logical vector
#' @keywords internal
discard_end_while <- function(.x, .p) {
  rev(discard_start_while(rev(.x), rev(.p)))
}

maybe_message <- function(verbose,
                          message,
                          class = NULL,
                          ...,
                          call = rlang::caller_env()) {
  if (verbose) {
    if (length(class)) {
      class <- paste0("gutenbergr-msg-", class)
    } else {
      class <- "gutenbergr-msg"
    }
    cli::cli_inform(message, class = class, ..., .envir = call)
  }
}
