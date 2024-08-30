local_dl_and_read <- function(.env = parent.frame()) {
  local_mocked_bindings(
    dl_and_read = function(url, ext) {
      path <- test_path("fixtures", "read_url", basename(url))
      readr::read_lines(path)
    },
    .env = .env
  )
}
