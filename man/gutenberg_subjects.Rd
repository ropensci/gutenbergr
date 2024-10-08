% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{gutenberg_subjects}
\alias{gutenberg_subjects}
\title{Gutenberg metadata about the subject of each work}
\format{
A tbl_df (see tibble or dplyr) with one row for each pairing
of work and subject, with columns:
\describe{
\item{gutenberg_id}{ID describing a work that can be joined with
\link{gutenberg_metadata}}
\item{subject_type}{Either "lcc" (Library of Congress Classification) or
"lcsh" (Library of Congress Subject Headings)}
\item{subject}{Subject}
}
}
\usage{
gutenberg_subjects
}
\description{
Gutenberg metadata about the subject of each work, particularly
Library of Congress Classifications (lcc) and Library of Congress
Subject Headings (lcsh).
}
\details{
Find more information about Library of Congress Categories
here: \url{https://www.loc.gov/catdir/cpso/lcco/}, and about
Library of Congress Subject Headings here:
\url{https://id.loc.gov/authorities/subjects.html}.

To find the date on which this metadata was last updated,
run \code{attr(gutenberg_subjects, "date_updated")}.
}
\examples{
\dontshow{if (interactive()) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}

library(dplyr)
library(stringr)

gutenberg_subjects |>
  filter(subject_type == "lcsh") |>
  count(subject, sort = TRUE)

sherlock_holmes_subjects <- gutenberg_subjects |>
  filter(str_detect(subject, "Holmes, Sherlock"))

sherlock_holmes_subjects

sherlock_holmes_metadata <- gutenberg_works() |>
  filter(author == "Doyle, Arthur Conan") |>
  semi_join(sherlock_holmes_subjects, by = "gutenberg_id")

sherlock_holmes_metadata

\donttest{
holmes_books <- gutenberg_download(sherlock_holmes_metadata$gutenberg_id)

holmes_books
}

# date last updated
attr(gutenberg_subjects, "date_updated")
\dontshow{\}) # examplesIf}
}
\seealso{
\link{gutenberg_metadata}, \link{gutenberg_authors}
}
\keyword{datasets}
