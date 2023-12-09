## Unexported functions for parsing the raw data.

download_raw_data <- function() {
  temp_zip <- tempfile(fileext = ".tar.bz2")
  on.exit(unlink(temp_zip))
  utils::download.file(
    url = "https://www.gutenberg.org/cache/epub/feeds/rdf-files.tar.bz2",
    destfile = temp_zip,
    mode = "wb"
  )
  temp_dir <- tempdir()
  utils::untar(
    tarfile = temp_zip,
    exdir = temp_dir
  )
  return(fs::path(temp_dir, "cache"))
}

parse_all_metadata <- function(file) {
  meta <- xml2::read_xml(file) |>
    xml2::xml_find_first(".//pgterms:ebook")

  gutenberg_id <- meta |>
    xml2::xml_attr("about") |>
    stringr::str_extract("\\w+$") |>
    as.integer()

  # Parse author data. Some files have 0 authors, and some have > 1.
  authors_all <- xml2::xml_find_all(meta, ".//dcterms:creator/pgterms:agent")
  author_data <- purrr::map(authors_all, parse_author) |>
    purrr::list_rbind()

  # Languages are relatively simple.
  languages <- meta |>
    xml2::xml_find_all(".//dcterms:language/rdf:Description/rdf:value") |>
    xml2::xml_text()
  language_data <- tibble::tibble(
    gutenberg_id = gutenberg_id,
    language = languages,
    total_languages = length(languages)
  )

  subjects_all <- xml2::xml_find_all(
    meta,
    ".//dcterms:subject/rdf:Description"
  )

  subjects_minimum <- list(
    tibble::tibble(subject_type = character(0), subject = character(0))
  )
  subject_data <- c(
    subjects_minimum,
    purrr::map(subjects_all, parse_subject)
  ) |>
    purrr::list_rbind() |>
    dplyr::mutate(
      gutenberg_id = gutenberg_id,
      .before = subject_type
    )

  title <- xml2::xml_find_first(meta, ".//dcterms:title") |>
    xml2::xml_text(trim = TRUE)

  bookshelf <- xml2::xml_find_all(
    meta, ".//pgterms:bookshelf/rdf:Description/rdf:value"
  ) |>
    xml2::xml_text(trim = TRUE) |>
    paste(collapse = "/")

  has_text <- xml2::xml_find_all(
    meta, ".//pgterms:file"
  ) |>
    xml2::xml_attr("about") |>
    stringr::str_detect("txt") |>
    any()

  rights <- xml2::xml_find_first(meta, "dcterms:rights") |>
    xml2::xml_text()

  if (nrow(author_data)) {
    metadata <- tibble::tibble(
      gutenberg_id = gutenberg_id,
      title = title,
      author = author_data$author,
      gutenberg_author_id = author_data$gutenberg_author_id,
      language = paste(languages, collapse = "/"),
      gutenberg_bookshelf = bookshelf,
      rights = rights,
      has_text = has_text
    )
  } else {
    metadata <- tibble::tibble(
      gutenberg_id = gutenberg_id,
      title = title,
      author = NA_character_,
      gutenberg_author_id = NA_integer_,
      language = paste(languages, collapse = "/"),
      gutenberg_bookshelf = bookshelf,
      rights = rights,
      has_text = has_text
    )
  }

  return(
    list(
      metadata = metadata,
      authors = author_data,
      languages = language_data,
      subjects = subject_data
    )
  )
}

parse_author <- function(author) {
  gutenberg_author_id <- author |>
    xml2::xml_attr("about") |>
    stringr::str_extract("\\d+$") |>
    as.integer()

  author_name <- author |>
    xml2::xml_find_first("pgterms:name") |>
    xml2::xml_text()

  birthdate <- author |>
    xml2::xml_find_first("pgterms:birthdate") |>
    xml2::xml_text() |>
    as.integer()
  deathdate <- author |>
    xml2::xml_find_first("pgterms:deathdate") |>
    xml2::xml_text() |>
    as.integer()

  # There can be more than one wikipedia URL.
  wikipedia <- author |>
    xml2::xml_find_all("pgterms:webpage") |>
    xml2::xml_attr("resource") |>
    paste(collapse = "|")
  if (wikipedia == "") wikipedia <- NA_character_

  # Right now we have two columns, "alias" and "aliases". They should be a
  # single list column but we'll get there later.
  aliases <- author |>
    xml2::xml_find_all("pgterms:alias") |>
    xml2::xml_text() |>
    unique()

  if (!length(aliases)) {
    alias <- NA_character_
    aliases <- NA_character_
  } else if (length(aliases) == 1) {
    # Our documentation implies this will be in both alias and aliases, so we'll
    # put it in both places.
    alias <- aliases
    aliases <- aliases
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

parse_subject <- function(subject) {
  subject_type <- subject |>
    xml2::xml_find_all("dcam:memberOf") |>
    xml2::xml_attr("resource") |>
    stringr::str_extract("\\w+$") |>
    tolower()

  if (!length(subject_type)) subject_type <- NA_character_

  subject_value <- subject |>
    xml2::xml_find_first("rdf:value") |>
    xml2::xml_text()

  if (!length(subject_value)) subject_value <- NA_character_

  return(
    tibble::tibble(
      subject_type = subject_type,
      subject = subject_value
    )
  )
}
