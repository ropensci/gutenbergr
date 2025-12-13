#!/usr/bin/env Rscript

## Datasets to use in examples, tests, and vignettes.
devtools::load_all(".")
sample_books <- gutenberg_download(
  c(109, 105),
  meta_fields = c("title", "author"),
  mirror = "https://aleph.pglaf.org/"
)
usethis::use_data(sample_books, overwrite = TRUE, compress = "bzip2")

# Fix format.
# tools::resaveRdaFiles("data/")
# tools::checkRdaFiles("data/")

rm(sample_books)
