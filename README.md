
<!-- README.md is generated from README.Rmd. Please edit that file -->

# gutenbergr <a href="https://docs.ropensci.org/gutenbergr/"><img src="man/figures/logo.png" align="right" height="160" alt="gutenbergr website" /></a>

<!-- badges: start -->

[![CRAN
version](https://www.r-pkg.org/badges/version/gutenbergr)](https://CRAN.R-project.org/package=gutenbergr)
[![CRAN
checks](https://badges.cranchecks.info/summary/gutenbergr.svg?label=CRAN%20Status)](https://cran.r-project.org/web/checks/check_results_gutenbergr.html)
[![rOpenSci
peer-review](https://badges.ropensci.org/41_status.svg)](https://github.com/ropensci/software-review/issues/41)
[![Project Status:
Active](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
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

Search, download, and process public domain texts from the [Project
Gutenberg](https://www.gutenberg.org/) collection.

## Installation

<div class=".pkgdown-release">

Install the released version from [CRAN](https://cran.r-project.org/):

``` r
install.packages("gutenbergr")
```

</div>

<div class=".pkgdown-devel">

Install the development version from [GitHub](https://github.com/):

``` r
# install.packages("pak")
pak::pak("ropensci/gutenbergr")
```

</div>

## Quick Start

Load the package:

``` r
library(gutenbergr)
library(dplyr)
```

We’ll get and set our Project Gutenberg mirror:

``` r
gutenberg_get_mirror()
```

    #> [1] "https://aleph.pglaf.org"

Search through the metadata to find a book:

``` r
gutenberg_works(title == "Persuasion")
```

    #> # A tibble: 1 × 8
    #>   gutenberg_id title      author       gutenberg_author_id language
    #>          <int> <chr>      <chr>                      <int> <fct>   
    #> 1          105 Persuasion Austen, Jane                  68 en      
    #>   gutenberg_bookshelf                           rights                    has_text
    #>   <chr>                                         <fct>                     <lgl>   
    #> 1 Category: Novels/Category: British Literature Public domain in the USA. TRUE

*Persuasion*’s `gutenberg_id` is 105. We’ll use it to download it. We’ll
set our cache option to `"persistent"` so that we don’t have to
re-download it later.

``` r
options(gutenbergr_cache_type = "persistent")
persuasion <- gutenberg_download(105)
```

``` r
persuasion
```

    #> # A tibble: 8,357 × 2
    #>    gutenberg_id text            
    #>           <int> <chr>           
    #>  1          105 "Persuasion"    
    #>  2          105 ""              
    #>  3          105 ""              
    #>  4          105 "by Jane Austen"
    #>  5          105 ""              
    #>  6          105 "(1818)"        
    #>  7          105 ""              
    #>  8          105 ""              
    #>  9          105 ""              
    #> 10          105 ""              
    #> # ℹ 8,347 more rows

Multiple works can be downloaded at once. We’ll add `title` data from
the metadata.

``` r
books <- gutenberg_download(c(105, 161), meta_fields = "title")
```

``` r
books |> count(title)
```

    #> # A tibble: 2 × 2
    #>   title                           n
    #>   <chr>                       <int>
    #> 1 Persuasion                   8357
    #> 2 Renascence, and Other Poems  1222

## Vignettes

See the following vignettes for more advanced usage of gutenbergr.

- [Getting Started with
  gutenbergr](https://docs.ropensci.org/gutenbergr/articles/intro.html) -
  explore metadata and download books
- [Text Mining with gutenbergr and
  tidytext](https://docs.ropensci.org/gutenbergr/articles/text-mining.html) -
  complete analysis workflow with
  [tidytext](https://github.com/juliasilge/tidytext)

## FAQ

### How were the metadata files generated?

See the
[`data-raw`](https://github.com/ropensci/gutenbergr/tree/master/data-raw)
directory for scripts. Metadata was generated from [the Project
Gutenberg
catalog](https://www.gutenberg.org/ebooks/offline_catalogs.html) on **11
January 2026**.

### Do you respect robot access rules?

Yes! The package follows [Project Gutenberg’s
rules](https://www.gutenberg.org/policy/robot_access.html):

- Retrieves books directly from mirrors using the authorized link format
- Prioritizes `.zip` files to minimize bandwidth
- Supports session and persistent caching
- This package is designed for downloading individual works or small
  collections, not the entire corpus. For bulk downloads, [set up a
  mirror](https://www.gutenberg.org/policy/robot_access.html).

See their [Terms of
Use](https://www.gutenberg.org/policy/terms_of_use.html) for details.

## Contributing

See
[`CONTRIBUTING.md`](https://docs.ropensci.org/gutenbergr/CONTRIBUTING.html).

Note that this package is released with a [Contributor Code of
Conduct](https://ropensci.org/code-of-conduct/). By contributing to this
project, you agree to abide by its terms.

[![ropensci_footer](https://ropensci.org/public_images/github_footer.png)](https://ropensci.org/)
