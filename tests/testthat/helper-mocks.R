local_dl_and_read <- function(.env = parent.frame()) {
  local_mocked_bindings(
    dl_and_read = function(url) {
      filename <- stringr::str_replace_all(
        basename(url),
        "[^[:alnum:]]",
        "-"
      )
      path <- test_path("fixtures", filename)
      readr::read_lines(path)
    },
    .env = .env
  )
}
