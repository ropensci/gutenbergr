library(fs)
library(dplyr)
library(here)
library(purrr)
library(stringr)
library(tibble)
# library(tictoc)
library(xml2)

source(here::here("data-raw", "parsers.R"))

# Grab the timestamp when we *started* this process. Don't update again until
# the source data is after this timestamp. Note that we don't actually *use*
# this timestamp yet, other than to inform users.
updated <- lubridate::date(lubridate::now(tzone = "UTC"))

# tictoc::tic()
cache_dir <- download_raw_data()
rdf_paths <- unname(fs::dir_ls(cache_dir, recurse = TRUE, glob = "*.rdf"))

all_metadata <- purrr::map(
  rdf_paths,
  parse_all_metadata
)

new_gutenberg_authors <- purrr::map(all_metadata, ~ .x$authors) |>
  purrr::list_rbind() |>
  dplyr::distinct(gutenberg_author_id, .keep_all = TRUE) |>
  dplyr::arrange(gutenberg_author_id)

new_gutenberg_languages <- purrr::map(all_metadata, ~ .x$languages) |>
  purrr::list_rbind() |>
  dplyr::distinct() |>
  dplyr::arrange(gutenberg_id, language) |>
  dplyr::mutate(language = as.factor(language))

new_gutenberg_metadata <- purrr::map(all_metadata, ~ .x$metadata) |>
  purrr::list_rbind() |>
  dplyr::arrange(gutenberg_id, gutenberg_author_id) |>
  dplyr::mutate(
    language = as.factor(language),
    rights = as.factor(rights)
  )

new_gutenberg_subjects <- purrr::map_dfr(all_metadata, ~ .x$subjects) |>
  dplyr::distinct() |>
  dplyr::arrange(gutenberg_id) |>
  dplyr::mutate(subject_type = as.factor(subject_type))

gutenberg_authors <- new_gutenberg_authors
gutenberg_subjects <- new_gutenberg_subjects
gutenberg_languages <- new_gutenberg_languages
gutenberg_metadata <- new_gutenberg_metadata

attr(gutenberg_authors, "date_updated") <- updated
attr(gutenberg_languages, "date_updated") <- updated
attr(gutenberg_metadata, "date_updated") <- updated
attr(gutenberg_subjects, "date_updated") <- updated

usethis::use_data(gutenberg_authors, overwrite = TRUE, compress = "xz")
usethis::use_data(gutenberg_languages, overwrite = TRUE, compress = "bzip2")
usethis::use_data(gutenberg_metadata, overwrite = TRUE, compress = "xz")
usethis::use_data(gutenberg_subjects, overwrite = TRUE, compress = "xz")

# Fix format.
# tools::resaveRdaFiles("data/")
# tools::checkRdaFiles("data/")

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
  download_raw_data,
  parse_all_metadata,
  parse_author,
  parse_subject,
  updated
)
# tictoc::toc()
