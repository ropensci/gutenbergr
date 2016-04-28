# you first need to run:

# python data-raw/gitenberg_metadata.py

# which creates data-raw/metadata.json.gz

library(purrr)
library(dplyr)
library(readr)
library(jsonlite)
library(stringr)
library(tidyr)

metadata_lines <- read_lines("data-raw/metadata.json.gz")

gutenberg_metadata_raw <- fromJSON(str_c("[", str_c(metadata_lines, collapse = ","), "]")) %>%
  jsonlite::flatten() %>%
  tbl_df()

# select columns, and combine some list columns into  character
# vector columns

collapse_col <- function(x) {
  x %>%
    map_if(negate(is.null), str_c, collapse = "/") %>%
    map_if(is.null, function(e) NA) %>%
    unlist()
}

ids_with_text <- read_lines("data-raw/have_text.txt") %>%
  unique() %>%
  extract_numeric() %>%
  as.integer()

gutenberg_metadata <-
  gutenberg_metadata_raw %>%
  transmute(gutenberg_id = as.integer(identifiers.gutenberg),
            title = collapse_col(title),
            author = creator.author.agent_name,
            gutenberg_author_id = as.integer(creator.author.gutenberg_agent_id),
            language = collapse_col(language),
            gutenberg_bookshelf = collapse_col(gutenberg_bookshelf),
            rights,
            has_text = gutenberg_id %in% ids_with_text) %>%
  arrange(gutenberg_id)

gutenberg_subjects <- gutenberg_metadata_raw %>%
  transmute(gutenberg_id = as.integer(identifiers.gutenberg), subjects) %>%
  filter(!map_lgl(subjects, is.null)) %>%
  mutate(subjects = map(subjects, as.data.frame, stringsAsFactors = FALSE)) %>%
  unnest(subjects) %>%
  rename(subject_type = V1, subject = V2)

gutenberg_authors <- gutenberg_metadata_raw %>%
  distinct(creator.author.gutenberg_agent_id) %>%
  select(contains("creator.author.")) %>%
  filter(!is.na(creator.author.agent_name)) %>%
  mutate(creator.author.gutenberg_agent_id = as.integer(creator.author.gutenberg_agent_id))

colnames(gutenberg_authors) <- str_replace(colnames(gutenberg_authors),
                                           "creator.author.", "")

# reorder and rename columns
gutenberg_authors <- gutenberg_authors %>%
  transmute(gutenberg_author_id = gutenberg_agent_id,
            author = agent_name,
            alias, birthdate, deathdate,
            wikipedia = collapse_col(wikipedia),
            aliases = collapse_col(aliases))

devtools::use_data(gutenberg_metadata, overwrite = TRUE)
devtools::use_data(gutenberg_subjects, overwrite = TRUE)
devtools::use_data(gutenberg_authors, overwrite = TRUE)
