#' Read a file from a URL
#'
#' Download, read, and delete file
#'
#' @param url URL to a file
#' @param ext Extension of the file to read
read_url <- function(url, ext = c(".zip", ".txt")) {
  f <- function(tmp) {
    mode <- ifelse(.Platform$OS.type == "windows", "wb", "w")
    utils::download.file(url, tmp, mode = mode, quiet = TRUE)
    readr::read_lines(tmp)
  }
  tmp <- tempfile(fileext = ext)
  ret <- suppressWarnings(purrr::possibly(f, NULL)(tmp))
  unlink(tmp)

  ret
}


#' Discard all values at the start of .x while .p is true
#'
#' @param .x Vector
#' @param .p Logical vector
#'
#' @noRd
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
#'
#' @noRd
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
#'
#' @noRd
discard_end_while <- function(.x, .p) {
  rev(discard_start_while(rev(.x), rev(.p)))
}
