library(gutenbergr)

dplyr::glimpse(gutenberg_metadata)
dplyr::glimpse(gutenberg_authors)
dplyr::glimpse(gutenberg_languages)
dplyr::glimpse(gutenberg_subjects)

temp_zip <- tempfile(fileext = ".tar.bz2")
on.exit(unlink(temp_zip))
utils::download.file(
  url = "https://www.gutenberg.org/cache/epub/feeds/rdf-files.tar.bz2",
  destfile = temp_zip,
  mode = "wb"
)

library(rdflib)
temp_dir <- tempdir()
utils::untar(
  tarfile = temp_zip,
  exdir = temp_dir
)
cache_dir <- fs::path(temp_dir, "cache", "epub")

rdf_paths <- fs::dir_ls(cache_dir, recurse = TRUE, glob = "*.rdf")

working_rdf <- rdflib::rdf()
purrr::walk(
  head(rdf_paths),
  rdflib::rdf_parse,
  rdf = working_rdf
)

library(jsonld)

old_opt <- options(rdf_print_format = "jsonld")
working_rdf
rdflib::rdf_serialize(
  working_rdf,
  here::here("data-raw", "testing.json"),
  format = "jsonld"
)
testing <- jsonlite::read_json(here::here("data-raw", "testing.json"))
testing <- jsonld::jsonld_flatten(here::here("data-raw", "testing.json"))
jsonld::jsonld_frame(testing)
testing <- jsonld::jsonld_from_rdf(working_rdf)

options(old_opt)

sparql <- "SELECT * WHERE {?s ?p ?o}"
testing <- rdf_query(working_rdf, sparql)

rdflib::rdf_free(working_rdf)
