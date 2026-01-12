
<!-- README.md is generated from README.Rmd. Please edit that file -->

# gutenbergr

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/gutenbergr)](https://CRAN.R-project.org/package=gutenbergr)
[![rOpenSci
peer-review](https://badges.ropensci.org/41_status.svg)](https://github.com/ropensci/software-review/issues/41)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![R-CMD-check](https://github.com/ropensci/gutenbergr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ropensci/gutenbergr/actions/workflows/R-CMD-check.yaml)
[![Integration
Tests](https://github.com/ropensci/gutenbergr/actions/workflows/integration-tests.yaml/badge.svg)](https://github.com/ropensci/gutenbergr/actions/workflows/integration-tests.yaml)
[![Codecov test
coverage](https://codecov.io/gh/ropensci/gutenbergr/graph/badge.svg)](https://app.codecov.io/gh/ropensci/gutenbergr)
[![Monthly
Downloads](https://cranlogs.r-pkg.org/badges/gutenbergr)](https://CRAN.R-project.org/package=gutenbergr)
[![Total
Downloads](https://cranlogs.r-pkg.org/badges/grand-total/gutenbergr)](https://CRAN.R-project.org/package=gutenbergr)
<!-- badges: end -->

Download and process public domain works from the [Project
Gutenberg](https://www.gutenberg.org/) collection. Includes

- A function `gutenberg_download()` that downloads one or more works
  from Project Gutenberg by ID: for instance, `gutenberg_download(84)`
  downloads the text of “Frankenstein”.
- Metadata for all Project Gutenberg works as R datasets, so that they
  can be searched and filtered:
  - `gutenberg_metadata` contains information about each work, pairing
    Gutenberg ID with title, author, language, etc
  - `gutenberg_authors` contains information about each author, such as
    aliases and birth/death year
  - `gutenberg_subjects` contains pairings of works with Library of
    Congress subjects and topics

## Installation

<div class=".pkgdown-release">

Install the released version of gutenbergr from
[CRAN](https://cran.r-project.org/):

``` r
install.packages("gutenbergr")
```

</div>

<div class=".pkgdown-devel">

Install the development version of gutenbergr from
[GitHub](https://github.com/):

``` r
# install.packages("pak")
pak::pak("ropensci/gutenbergr")
```

</div>

## Examples

The `gutenberg_works()` function retrieves, by default, a table of
metadata for all unique English-language Project Gutenberg works that
have text associated with them. (The `gutenberg_metadata` dataset has
all Gutenberg works, unfiltered).

Suppose we wanted to download Emily Bronte’s “Wuthering Heights.” We
could find the book’s ID by filtering:

``` r
library(gutenbergr)
library(dplyr)
conflicted::conflict_prefer_all("dplyr", quiet = TRUE)
gutenberg_get_mirror()
#> [1] "https://aleph.pglaf.org"

gutenberg_works() |>
  filter(title == "Wuthering Heights")
#> # A tibble: 1 × 8
#>   gutenberg_id title             author        gutenberg_author_id language
#>          <int> <chr>             <chr>                       <int> <fct>   
#> 1          768 Wuthering Heights Brontë, Emily                 405 en      
#>   gutenberg_bookshelf                                                                rights has_text
#>   <chr>                                                                              <fct>  <lgl>   
#> 1 Best Books Ever Listings/Gothic Fiction/Movie Books/Category: Novels/Category: Cl… Publi… TRUE

# or just:
gutenberg_works(title == "Wuthering Heights")
#> # A tibble: 1 × 8
#>   gutenberg_id title             author        gutenberg_author_id language
#>          <int> <chr>             <chr>                       <int> <fct>   
#> 1          768 Wuthering Heights Brontë, Emily                 405 en      
#>   gutenberg_bookshelf                                                                rights has_text
#>   <chr>                                                                              <fct>  <lgl>   
#> 1 Best Books Ever Listings/Gothic Fiction/Movie Books/Category: Novels/Category: Cl… Publi… TRUE
```

Since we see that it has `gutenberg_id` 768, we can download it with the
`gutenberg_download()` function:

``` r
wuthering_heights <- gutenberg_download(768)
wuthering_heights
#> # A tibble: 12,342 × 2
#>    gutenberg_id text               
#>           <int> <chr>              
#>  1          768 "Wuthering Heights"
#>  2          768 ""                 
#>  3          768 "by Emily Brontë"  
#>  4          768 ""                 
#>  5          768 ""                 
#>  6          768 ""                 
#>  7          768 ""                 
#>  8          768 "CHAPTER I"        
#>  9          768 ""                 
#> 10          768 ""                 
#> # ℹ 12,332 more rows
```

`gutenberg_download` can download multiple books when given multiple
IDs. It also takes a `meta_fields` argument that will add variables from
the metadata.

``` r
# 1260 is the ID of Jane Eyre
books <- gutenberg_download(c(768, 1260), meta_fields = "title")
books
#> # A tibble: 33,343 × 3
#>    gutenberg_id text                title            
#>           <int> <chr>               <chr>            
#>  1          768 "Wuthering Heights" Wuthering Heights
#>  2          768 ""                  Wuthering Heights
#>  3          768 "by Emily Brontë"   Wuthering Heights
#>  4          768 ""                  Wuthering Heights
#>  5          768 ""                  Wuthering Heights
#>  6          768 ""                  Wuthering Heights
#>  7          768 ""                  Wuthering Heights
#>  8          768 "CHAPTER I"         Wuthering Heights
#>  9          768 ""                  Wuthering Heights
#> 10          768 ""                  Wuthering Heights
#> # ℹ 33,333 more rows

books |>
  count(title)
#> # A tibble: 2 × 2
#>   title                           n
#>   <chr>                       <int>
#> 1 Jane Eyre: An Autobiography 21001
#> 2 Wuthering Heights           12342
```

It can also take the output of `gutenberg_works` directly. For example,
we could get the text of all Aristotle’s works, each annotated with both
`gutenberg_id` and `title`, using:

``` r
aristotle_books <- gutenberg_works(author == "Aristotle") |>
  gutenberg_download(meta_fields = "title")

aristotle_books
#> # A tibble: 43,801 × 3
#>    gutenberg_id text                                                                    
#>           <int> <chr>                                                                   
#>  1         1974 "THE POETICS OF ARISTOTLE"                                              
#>  2         1974 ""                                                                      
#>  3         1974 "By Aristotle"                                                          
#>  4         1974 ""                                                                      
#>  5         1974 "A Translation By S. H. Butcher"                                        
#>  6         1974 ""                                                                      
#>  7         1974 ""                                                                      
#>  8         1974 "[Transcriber's Annotations and Conventions: the translator left"       
#>  9         1974 "intact some Greek words to illustrate a specific point of the original"
#> 10         1974 "discourse. In this transcription, in order to retain the accuracy of"  
#>    title                   
#>    <chr>                   
#>  1 The Poetics of Aristotle
#>  2 The Poetics of Aristotle
#>  3 The Poetics of Aristotle
#>  4 The Poetics of Aristotle
#>  5 The Poetics of Aristotle
#>  6 The Poetics of Aristotle
#>  7 The Poetics of Aristotle
#>  8 The Poetics of Aristotle
#>  9 The Poetics of Aristotle
#> 10 The Poetics of Aristotle
#> # ℹ 43,791 more rows
```

## FAQ

### What do I do with the text once I have it?

- The [Natural Language Processing CRAN
  View](https://CRAN.R-project.org/view=NaturalLanguageProcessing)
  suggests many R packages related to text mining, especially around the
  [tm package](https://cran.r-project.org/package=tm).
- The [tidytext](https://github.com/juliasilge/tidytext) package is
  useful for tokenization and analysis, especially since gutenbergr
  downloads books as a data frame already.
- You could match the `wikipedia` column in `gutenberg_author` to
  Wikipedia content with the
  [WikipediR](https://cran.r-project.org/package=WikipediR) package or
  to pageview statistics with the
  [wikipediatrend](https://cran.r-project.org/package=wikipediatrend)
  package.
- If you’re considering an analysis based on author name, you may find
  the [humaniformat](https://cran.r-project.org/package=humaniformat)
  (for extraction of first names) and
  [gender](https://cran.r-project.org/package=gender) (prediction of
  gender from first names) packages useful. (Note that humaniformat has
  a `format_reverse` function for reversing “Last, First” names).

### How were the metadata R files generated?

See the
[data-raw](https://github.com/ropensci/gutenbergr/tree/master/data-raw)
directory for the scripts that generate these datasets. As of now, these
were generated from [the Project Gutenberg
catalog](https://www.gutenberg.org/ebooks/offline_catalogs.html) on **11
January 2026**.

### Do you respect the rules regarding robot access to Project Gutenberg?

Yes! The package respects [these
rules](https://www.gutenberg.org/policy/robot_access.html) and complies
to the best of our ability. Namely:

- Project Gutenberg allows harvesting with automated software using
  [this list of
  links](https://www.gutenberg.org/robot/harvest?filetypes%5B%5D=html).
- We retrieve the book text directly from a default or user-specified
  mirror using links in the same format. For example, “Frankenstein”
  (book 84) is retrieved from `https://aleph.pglaf.org/8/84/84-0.txt`.
- We give priority to retrieving `.zip` files to minimize bandwidth on
  the mirror. `.txt` files are only retrieved if there is no `.zip`.
- gutenbergr supports both session and persistent caching of downloaded
  files to prevent redownloading.

Still, this package is *not* the right way to download the entire
Project Gutenberg corpus (or all from a particular language). For that,
follow [their
recommendation](https://www.gutenberg.org/policy/robot_access.html) to
set up a mirror. This package is recommended for downloading a single
work, or works for a particular author or topic. See their [Terms of
Service](https://www.gutenberg.org/policy/terms_of_use.html) for
details.

## Contributing

See
[`CONTRIBUTING.md`](https://docs.ropensci.org/gutenbergr/CONTRIBUTING.html).

Please note that this package is released with a [Contributor Code of
Conduct](https://ropensci.org/code-of-conduct/). By contributing to this
project, you agree to abide by its terms.

[![ropensci_footer](https://ropensci.org/public_images/github_footer.png)](https://ropensci.org/)
