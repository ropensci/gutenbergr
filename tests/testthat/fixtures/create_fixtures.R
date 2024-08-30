# Download files for download tests.
dl_fixture <- function(url, dir, ext = c(".zip", ".txt")) {
  if (missing(ext)) {
    ext <- stringr::str_extract(url, "\\.[^.]+$")
  }
  ext <- match.arg(ext)
  mode <- ifelse(.Platform$OS.type == "windows", "wb", "w")
  path <- test_path("fixtures", dir, basename(url))
  utils::download.file(url, path, mode = mode, quiet = TRUE)
}

dl_fixture("http://gutenberg.pglaf.org/0/2/2.zip", dir = "read_url")
dl_fixture("https://www.gutenberg.org/cache/epub/68283/pg68283.txt", dir = "read_url")
