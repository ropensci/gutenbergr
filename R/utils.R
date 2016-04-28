#' Read a file from a .zip URL
#'
#' Download, read, and delete a .zip file
#'
#' @param url URL to a .zip file
read_zip_url <- function(url) {
  tmp <- tempfile(fileext = ".zip")
  download.file(url, tmp, quiet = TRUE)

  ret <- purrr::possibly(readr::read_lines, NULL)(tmp)
  unlink(tmp)

  ret
}
