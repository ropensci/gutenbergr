# Download files for download tests.
dl_fixture <- function(url) {
  filename <- stringr::str_replace_all(
    basename(url),
    "[^[:alnum:]]",
    "-"
  )
  writeLines(
    dl_and_read(url),
    test_path("fixtures", filename)
  )
}

dl_fixture("http://gutenberg.pglaf.org/0/2/2.zip")
dl_fixture("https://www.gutenberg.org/cache/epub/68283/pg68283.txt")
dl_fixture("https://www.gutenberg.org/robot/harvest?filetypes[]=txt")
dl_fixture("http://aleph.gutenberg.org/1/0/105/105-0.zip")
dl_fixture("http://aleph.gutenberg.org/1/0/109/109.zip")
