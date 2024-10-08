% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gutenberg_strip.R
\name{gutenberg_strip}
\alias{gutenberg_strip}
\title{Strip header and footer content from a Project Gutenberg book}
\usage{
gutenberg_strip(text)
}
\arguments{
\item{text}{A character vector with lines of a book.}
}
\value{
A character vector with Project Gutenberg headers and footers removed
}
\description{
Strip header and footer content from a Project Gutenberg book. This
is based on some formatting guesses so it may not be perfect. It
will also not strip tables of contents, prologues, or other text
that appears at the start of a book.
}
\examples{
\dontshow{if (interactive()) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}

book <- gutenberg_works(title == "Pride and Prejudice") |>
  gutenberg_download(strip = FALSE)

head(book$text, 10)
tail(book$text, 10)

text_stripped <- gutenberg_strip(book$text)

head(text_stripped, 10)
tail(text_stripped, 10)
\dontshow{\}) # examplesIf}
}
