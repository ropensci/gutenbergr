# R Script for finding out which of the Gutenberg works have text files
# (as opposed to e.g. audiobooks)

# This script uses parallel computing and substitutes previous UNIX MAC-only
# bash code

cache_dir <- "/tmp/cache/epub"
flag_file <- "/tmp/ids_with_text.rds"

all_files <- fs::dir_ls(cache_dir,
  recurse = TRUE,
  glob = "*.rdf"
)

read_single_rdf <- function(f_in) {
  cli::cli_alert_info("Processing {f_in}")
  this_str <- paste0(readr::read_lines(f_in), collapse = "\n")

  flag <- stringr::str_detect(this_str, '<pgterms:file.*\\d\\.txt"')
  this_id <- stringr::str_split(f_in, "/")[[1]][5]

  df_out <- dplyr::tibble(
    file = f_in,
    id = this_id,
    flag = flag
  )

  return(df_out)
}

future::plan(future::multisession, workers = 15)

df_flags <- furrr::future_map_dfr(all_files, read_single_rdf, .progress = TRUE)

readr::write_rds(df_flags, flag_file)
