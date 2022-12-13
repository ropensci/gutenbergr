library(gutenbergr)
library(fs)
library(xml2)
library(rlang)

# These are my targets
dplyr::glimpse(gutenberg_metadata)
dplyr::glimpse(gutenberg_authors)
dplyr::glimpse(gutenberg_languages)
dplyr::glimpse(gutenberg_subjects)

# temp_zip <- tempfile(fileext = ".tar.bz2")
# on.exit(unlink(temp_zip))
# utils::download.file(
#   url = "https://www.gutenberg.org/cache/epub/feeds/rdf-files.tar.bz2",
#   destfile = temp_zip,
#   mode = "wb"
# )
temp_dir <- tempdir()
# utils::untar(
#   tarfile = temp_zip,
#   exdir = temp_dir
# )
cache_dir <- fs::path(temp_dir, "cache", "epub")
rdf_paths <- fs::dir_ls(cache_dir, recurse = TRUE, glob = "*.rdf")

# Pull all of that data into a mostly-neat list.

# I'm doing authors just to prove the concept, even though it'll probably be
# slow and it'll be sad to throw it away.

all_metadata <- purrr::map(
  rdf_paths |> unname(),
  \(file) {
    meta <- xml2::read_xml(file) |>
      xml2::xml_find_first(".//pgterms:ebook")
    # Parse author data. Some files have 0 authors, and some have > 1.

    # authors_all <- xml2::xml_find_all(meta, ".//dcterms:creator/pgterms:agent")

    # Just get the first one to match the old file
    author <- xml2::xml_find_first(meta, ".//dcterms:creator/pgterms:agent")

    parse_author <- function(author) {
      author <- xml2::as_list(author)
      gutenberg_author_id <- as.integer(
        stringr::str_extract(attr(author, "about"), "\\d+$")
      )
      author_name <- author$name[[1]] %||% NA_character_
      birthdate <- as.integer(author$birthdate[[1]] %||% NA)
      deathdate <- as.integer(author$deathdate[[1]] %||% NA)

      # There can be more than one wikipedia URL. For now get it the same way
      # we already do, even though that's messy.
      webpages <- purrr::map_chr(author[names(author) == "webpage"], attr, "resource")
      wikipedia <- paste(webpages, collapse = "/")
      if (wikipedia == "") wikipedia <- NA_character_

      # Right now we have two columns, "alias" and "aliases". They should be a
      # single list column but we'll get there later.
      aliases <- purrr::map_chr(author[names(author) == "alias"], ~.x[[1]]) |>
        unname() |> unique()
      if (!length(aliases)) {
        alias <- NA_character_
        aliases <- NA_character_
      } else if (length(aliases) == 1) {
        alias <- aliases
        aliases <- NA_character_
      } else {
        alias <- NA_character_
        aliases <- paste(aliases, collapse = "/")
      }

      return(
        tibble::tibble(
          gutenberg_author_id = gutenberg_author_id,
          author = author_name,
          alias = alias,
          birthdate = birthdate,
          deathdate = deathdate,
          wikipedia = wikipedia,
          aliases = aliases
        )
      )
    }

    author_data <- parse_author(author)

    # author_data <- purrr::map_dfr(
    #   authors_all,
    #   parse_author
    # )

    return(
      list(
        metadata = tibble::tibble(),
        authors = author_data,
        languages = tibble::tibble(),
        subjects = tibble::tibble()
      )
    )
  }
)

new_gutenberg_authors <- purrr::map_dfr(all_metadata, ~.x$authors) |>
  dplyr::distinct(gutenberg_author_id, .keep_all = TRUE) |>
  dplyr::arrange(gutenberg_author_id)

waldo::compare(nrow(gutenberg_authors), nrow(new_gutenberg_authors))
gutenberg_authors |>
  dplyr::anti_join(new_gutenberg_authors, by = "gutenberg_author_id")
gutenberg_authors |>
  dplyr::anti_join(new_gutenberg_authors, by = "author")
