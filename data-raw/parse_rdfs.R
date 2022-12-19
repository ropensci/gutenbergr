library(fs)
library(dplyr)
library(gutenbergr)
library(here)
library(purrr)
library(stringr)
library(tibble)
library(xml2)

source(here::here("data-raw", "parsers.R"))

cache_dir <- download_raw_data()
rdf_paths <- unname(fs::dir_ls(cache_dir, recurse = TRUE, glob = "*.rdf"))

all_metadata <- purrr::map(
  rdf_paths,
  parse_all_metadata
)

new_gutenberg_authors <- purrr::map_dfr(all_metadata, ~.x$authors) |>
  dplyr::distinct(gutenberg_author_id, .keep_all = TRUE) |>
  dplyr::arrange(gutenberg_author_id)

new_gutenberg_languages <- purrr::map_dfr(all_metadata, ~.x$languages) |>
  dplyr::arrange(gutenberg_id, language)

new_gutenberg_metadata <- purrr::map_dfr(all_metadata, ~.x$metadata) |>
  dplyr::arrange(gutenberg_id, gutenberg_author_id)

new_gutenberg_subjects <- purrr::map_dfr(all_metadata, ~.x$subjects) |>
  dplyr::arrange(gutenberg_id)

waldo::compare(nrow(gutenberg_authors), nrow(new_gutenberg_authors))
waldo::compare(nrow(gutenberg_subjects), nrow(new_gutenberg_subjects))
waldo::compare(nrow(gutenberg_languages), nrow(new_gutenberg_languages))
waldo::compare(nrow(gutenberg_metadata), nrow(new_gutenberg_metadata))

gutenberg_authors <- new_gutenberg_authors
gutenberg_subjects <- new_gutenberg_subjects
gutenberg_languages <- new_gutenberg_languages
gutenberg_metadata <- new_gutenberg_metadata

# The old updated date was just a fancy way to get the timestamp of when it was
# downloaded. Since we're doing this on the scale of months not seconds, using
# the time right now makes sense.
updated <- lubridate::date(lubridate::now(tzone = "UTC"))

attr(gutenberg_authors, "date_updated") <- updated
attr(gutenberg_languages, "date_updated") <- updated
attr(gutenberg_metadata, "date_updated") <- updated
attr(gutenberg_subjects, "date_updated") <- updated

usethis::use_data(gutenberg_authors, overwrite = TRUE, compress = "xz")
usethis::use_data(gutenberg_languages, overwrite = TRUE, compress = "bzip2")
usethis::use_data(gutenberg_metadata, overwrite = TRUE, compress = "xz")
usethis::use_data(gutenberg_subjects, overwrite = TRUE, compress = "xz")

# Clean up.
unlink(cache_dir, recursive = TRUE)
rm(
  all_metadata,
  gutenberg_authors,
  gutenberg_languages,
  gutenberg_metadata,
  gutenberg_subjects,
  new_gutenberg_authors,
  new_gutenberg_languages,
  new_gutenberg_metadata,
  new_gutenberg_subjects,
  cache_dir,
  rdf_paths,
  temp_dir,
  download_raw_data,
  parse_all_metadata,
  parse_author,
  parse_subject
)
