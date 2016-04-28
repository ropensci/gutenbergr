#' Gutenberg metadata about each work
#'
#' Selected fields of metadata about each of the Project Gutenberg
#' works. These were collected using the gitenberg Python package,
#' particularly the \code{pg_rdf_to_json} function.
#'
#' @format A tbl_df with one row for each work in Project Gutenberg
#' and the following columns:
#' \describe{
#'   \item{gutenberg_id}{Numeric ID, used to retrieve works from
#'   Project Gutenberg}
#'   \item{title}{Title}
#'   \item{author}{Author, if a single one given. Given as last name
#'   first (e.g. "Doyle, Arthur Conan")}
#'   \item{author_id}{Project Gutenberg author ID}
#'   \item{language}{Language code, separated by / if multiple}
#'   \item{gutenberg_bookshelf}{Which collection or collections this
#'   is found in, separated by / if multiple}
#'   \item{rights}{Generally one of three options: "Public domain in the USA."
#'   (the most common by far), "Copyrighted. Read the copyright notice inside this book
#'   for details.", or "None".}
#'   \item{has_text}{Whether there is a file containing digits followed by
#'   \code{.txt} in Project Gutenberg for this record (as opposed to, for
#'   example, audiobooks). If not, cannot be retrieved with
#'   \code{\link{gutenberg_download}}}
#' }
#'
#' @examples
#'
#' library(dplyr)
#' library(stringr)
#'
#' gutenberg_metadata
#'
#' gutenberg_metadata %>%
#'   count(author, sort = TRUE)
#'
#' # look for Shakespeare, excluding collections (containing "Works") and translations
#' shakespeare_metadata <- gutenberg_metadata %>%
#'   filter(author == "Shakespeare, William",
#'          language == "en",
#'          !str_detect(title, "Works"),
#'          has_text,
#'          !str_detect(rights, "Copyright")) %>%
#'          distinct(title)
#'
#' \dontrun{
#' shakespeare_works <- gutenberg_download(shakespeare_metadata$gutenberg_id)
#' }
#'
#' # note that gutenberg_works() function is a shortcut to some of the above
#'
#' shakespeare_metadata2 <- gutenberg_works(author == "Shakespeare, William",
#'                                          !str_detect(title, "Works"))
#'
#' @seealso \link{gutenberg_works}, \link{gutenberg_authors}, \link{gutenberg_subjects}
"gutenberg_metadata"


#' Gutenberg metadata about the subject of each work
#'
#' Gutenberg metadata about the subject of each work, particularly
#' Library of Congress Classifications (lcc) and Library of Congress
#' Subject Headings (lcsh).
#'
#' @format A tbl_df with one row for each pairing of work and subject, with
#' columns:
#' \describe{
#'   \item{gutenberg_id}{ID describing a work that can be joined with
#'   \link{gutenberg_metadata}}
#'   \item{subject_type}{Either "lcc" (Library of Congress Classification) or
#'   "lcsh" (Library of Congress Subject Headings)}
#'   \item{subject}{Subject}
#' }
#'
#' @examples
#'
#' library(dplyr)
#' library(stringr)
#'
#' gutenberg_subjects %>%
#'   filter(subject_type == "lcsh") %>%
#'   count(subject, sort = TRUE)
#'
#' sherlock_holmes_subjects <- gutenberg_subjects %>%
#'   filter(str_detect(subject, "Holmes, Sherlock"))
#'
#' sherlock_holmes_subjects
#'
#' sherlock_holmes_metadata <- gutenberg_works() %>%
#'   filter(author == "Doyle, Arthur Conan") %>%
#'   semi_join(sherlock_holmes_subjects, by = "gutenberg_id")
#'
#' sherlock_holmes_metadata
#'
#' \dontrun{
#' holmes_books <- gutenberg_download(sherlock_holmes_metadata$gutenberg_id)
#'
#' holmes_books
#' }
#'
#' @seealso \link{gutenberg_metadata}, \link{gutenberg_authors}
"gutenberg_subjects"


#' Metadata about Project Gutenberg authors
#'
#' Data frame with metadata about each author of a Project
#' Gutenberg work. For space only metadata from people that have
#' been the single author of a work (not multiple authors,
#' contributors, etc) are included.
#'
#' @format A tbl_df with one row for each author, with the columns
#' \describe{
#'   \item{gutenberg_author_id}{Unique identifier for the author that can
#'   be used to join with the \link{gutenberg_metadata} dataset}
#'   \item{author}{The \code{agent_name} field from the original metadata}
#'   \item{alias}{Alias}
#'   \item{birthdate}{Year of birth}
#'   \item{deathdate}{Year of death}
#'   \item{wikipedia}{Link to Wikipedia article on the author. If there
#'   are multiple, they are "/"-delimited}
#'   \item{aliases}{List column of character vectors of aliases. If there
#'   are multiple, they are "/"-delimited}
#' }
#'
#' @seealso \link{gutenberg_metadata}, \link{gutenberg_subjects}
"gutenberg_authors"
