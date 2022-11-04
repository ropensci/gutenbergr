### Before running, you first need to run two scrips:

# First:

# 01-download-metadata.sh

# 02-parse-metadata
#   which creates data-raw/metadata.json.gz, and

# 03-parse-text-files.R
#   which creates "/tmp/ids_with_text.rds"

library(purrr)
library(dplyr)
library(readr)
library(jsonlite)
library(stringr)
library(tidyr)

flag_file <- "/tmp/ids_with_text.rds"

metadata_lines <- read_lines("data-raw/metadata.json.gz")

# This is assuming the file was created the same day it was downloaded
# That assumption might be off: this is not perfect and you may need
# to adjust
updated <- as.Date(file.info("data-raw/metadata.json.gz")$mtime)

gutenberg_metadata_raw <- fromJSON(str_c("[", str_c(metadata_lines, collapse = ","), "]")) %>%
  jsonlite::flatten() %>%
  tbl_df()

# select columns, and combine some list columns into "/"-delimited character
# vector columns

collapse_col <- function(x) {
  x %>%
    map_if(negate(is.null), str_c, collapse = "/") %>%
    map_if(is.null, function(e) NA) %>%
    unlist()
}

ids_with_text <- read_rds(flag_file) |>
  filter(flag) |>
  pull(id) |>
  as.integer()

gutenberg_metadata <-
  gutenberg_metadata_raw %>%
  transmute(gutenberg_id = as.integer(identifiers.gutenberg),
            title = collapse_col(title),
            author = creator.author.agent_name,
            gutenberg_author_id = as.integer(creator.author.gutenberg_agent_id),
            language = collapse_col(map(language, sort)),
            gutenberg_bookshelf = collapse_col(gutenberg_bookshelf),
            rights,
            has_text = gutenberg_id %in% ids_with_text) %>%
  arrange(gutenberg_id)

gutenberg_subjects <- gutenberg_metadata_raw %>%
  transmute(gutenberg_id = as.integer(identifiers.gutenberg), subjects) %>%
  filter(!map_lgl(subjects, is.null)) %>%
  mutate(subjects = map(subjects, as.data.frame, stringsAsFactors = FALSE)) %>%
  unnest(subjects) %>%
  rename(subject_type = V1, subject = V2) %>%
  arrange(gutenberg_id)

gutenberg_authors <- gutenberg_metadata_raw %>%
  distinct(creator.author.gutenberg_agent_id, .keep_all = TRUE) %>%
  select(contains("creator.author.")) %>%
  filter(!is.na(creator.author.agent_name)) %>%
  mutate(creator.author.gutenberg_agent_id = as.integer(creator.author.gutenberg_agent_id)) |>
  unique()

colnames(gutenberg_authors) <- str_replace(colnames(gutenberg_authors),
                                           "creator.author.", "")

# reorder and rename columns
gutenberg_authors <- gutenberg_authors %>%
  transmute(gutenberg_author_id = gutenberg_agent_id,
            author = agent_name,
            alias, birthdate, deathdate,
            wikipedia = collapse_col(wikipedia),
            aliases = collapse_col(aliases)) %>%
  arrange(gutenberg_author_id)

# Keep the languages as its own table
gutenberg_languages <- gutenberg_metadata %>%
  select(gutenberg_id, language) %>%
  mutate(language = stringr::str_split(language, "/")) %>%
  tidyr::unnest(language) %>%
  group_by(gutenberg_id) %>%
  mutate(total_languages = n()) %>%
  ungroup()

attr(gutenberg_metadata, "date_updated") <- updated
attr(gutenberg_subjects, "date_updated") <- updated
attr(gutenberg_authors, "date_updated") <- updated
attr(gutenberg_languages, "date_updated") <- attr(gutenberg_metadata, "date_updated")

usethis::use_data(gutenberg_metadata, overwrite = TRUE)
usethis::use_data(gutenberg_subjects, overwrite = TRUE)
usethis::use_data(gutenberg_authors, overwrite = TRUE)
usethis::use_data(gutenberg_languages, overwrite = TRUE)
