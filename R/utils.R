#' Read a file from a .zip URL
#'
#' Download, read, and delete a .zip file
#'
#' @param url URL to a .zip file
read_zip_url <- function(url) {
  tmp <- tempfile(fileext = ".zip")
  utils::download.file(url, tmp, quiet = TRUE)

  ret <- purrr::possibly(readr::read_lines, NULL)(tmp)
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
  if (.p[1] && any(.p)) {
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
