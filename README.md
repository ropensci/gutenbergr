<!-- README.md is generated from README.Rmd. Please edit that file -->



gutenbergr: R package to search and download public domain texts from Project Gutenberg
----------------

**Authors:** [David Robinson](http://varianceexplained.org/)<br/>
**License:** [MIT](https://opensource.org/licenses/MIT)

[![Build Status](https://travis-ci.org/ropenscilabs/gutenbergr.svg?branch=master)](https://travis-ci.org/ropenscilabs/gutenbergr)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/gutenbergr)](http://cran.r-project.org/package=gutenbergr)
[![Appveyor Build status](https://ci.appveyor.com/api/projects/status/i41bhbh87sb87w8o?svg=true)](https://ci.appveyor.com/project/ropenscilabs/gutenbergr)
[![Coverage Status](https://img.shields.io/codecov/c/github/ropenscilabs/gutenbergr/master.svg)](https://codecov.io/github/ropenscilabs/gutenbergr?branch=master)

Download and process public domain works from the [Project Gutenberg](https://www.gutenberg.org/) collection. Includes

* A function `gutenberg_download()` that downloads one or more works from Project Gutenberg by ID: e.g., `gutenberg_download(84)` downloads the text of Frankenstein.
* Metadata for all Project Gutenberg works as R datasets, so that they can be searched and filtered:
  * `gutenberg_metadata` contains information about each work, pairing Gutenberg ID with title, author, language, etc
  * `gutenberg_authors` contains information about each author, such as aliases and birth/death year
  * `gutenberg_subjects` contains pairings of works with Library of Congress subjects and topics

### Installation

Install the package with:


```r
install.packages("gutenbergr")
```

Or install the development version using [devtools](https://github.com/hadley/devtools) with:


```r
devtools::install_github("ropenscilabs/gutenbergr")
```

### Examples

The `gutenberg_works()` function retrieves, by default, a table of metadata for all unique English-language Project Gutenberg works that have text associated with them. (The `gutenberg_metadata` dataset has all Gutenberg works, unfiltered).



Suppose we wanted to download Emily Bronte's "Wuthering Heights." We could find the book's ID by filtering:


```r
library(dplyr)
library(gutenbergr)

gutenberg_works() %>%
  filter(title == "Wuthering Heights")
#> Source: local data frame [1 x 8]
#>
#>   gutenberg_id             title        author gutenberg_author_id language
#>          (int)             (chr)         (chr)               (int)    (chr)
#> 1          768 Wuthering Heights Brontë, Emily                 405       en
#>                                   gutenberg_bookshelf
#>                                                 (chr)
#> 1 Gothic Fiction/Movie Books/Best Books Ever Listings
#> Variables not shown: rights (chr), has_text (lgl)

# or just:
gutenberg_works(title == "Wuthering Heights")
#> Source: local data frame [1 x 8]
#>
#>   gutenberg_id             title        author gutenberg_author_id language
#>          (int)             (chr)         (chr)               (int)    (chr)
#> 1          768 Wuthering Heights Brontë, Emily                 405       en
#>                                   gutenberg_bookshelf
#>                                                 (chr)
#> 1 Gothic Fiction/Movie Books/Best Books Ever Listings
#> Variables not shown: rights (chr), has_text (lgl)
```

Since we see that it has `gutenberg_id` 768, we can download it with the `gutenberg_download()` function:


```r
wuthering_heights <- gutenberg_download(768)
wuthering_heights
#> Source: local data frame [12,085 x 2]
#>
#>    gutenberg_id                                                                    text
#>           (int)                                                                   (chr)
#> 1           768                                                       WUTHERING HEIGHTS
#> 2           768
#> 3           768
#> 4           768                                                               CHAPTER I
#> 5           768
#> 6           768
#> 7           768   1801.--I have just returned from a visit to my landlord--the solitary
#> 8           768 neighbour that I shall be troubled with.  This is certainly a beautiful
#> 9           768 country!  In all England, I do not believe that I could have fixed on a
#> 10          768    situation so completely removed from the stir of society.  A perfect
#> ..          ...                                                                     ...
```

`gutenberg_download` can download multiple books when given multiple IDs. It also takes a `meta_fields` argument that will add variables from the metadata.


```r
# 1260 is the ID of Jane Eyre
books <- gutenberg_download(c(768, 1260), meta_fields = "title")
books
#> Source: local data frame [32,744 x 3]
#>
#>    gutenberg_id                                                                    text
#>           (int)                                                                   (chr)
#> 1           768                                                       WUTHERING HEIGHTS
#> 2           768
#> 3           768
#> 4           768                                                               CHAPTER I
#> 5           768
#> 6           768
#> 7           768   1801.--I have just returned from a visit to my landlord--the solitary
#> 8           768 neighbour that I shall be troubled with.  This is certainly a beautiful
#> 9           768 country!  In all England, I do not believe that I could have fixed on a
#> 10          768    situation so completely removed from the stir of society.  A perfect
#> ..          ...                                                                     ...
#>                title
#>                (chr)
#> 1  Wuthering Heights
#> 2  Wuthering Heights
#> 3  Wuthering Heights
#> 4  Wuthering Heights
#> 5  Wuthering Heights
#> 6  Wuthering Heights
#> 7  Wuthering Heights
#> 8  Wuthering Heights
#> 9  Wuthering Heights
#> 10 Wuthering Heights
#> ..               ...

books %>%
  count(title)
#> Source: local data frame [2 x 2]
#>
#>                         title     n
#>                         (chr) (int)
#> 1 Jane Eyre: An Autobiography 20659
#> 2           Wuthering Heights 12085
```

It can also take the output of `gutenberg_works` directly. For example, we could get the text of all Aristotle's works, each annotated with both `gutenberg_id` and `title`, using:


```r
aristotle_books <- gutenberg_works(author == "Aristotle") %>%
  gutenberg_download(meta_fields = "title")

aristotle_books
#> Source: local data frame [39,950 x 3]
#>
#>    gutenberg_id                                                                   text
#>           (int)                                                                  (chr)
#> 1          1974                                               THE POETICS OF ARISTOTLE
#> 2          1974
#> 3          1974                                                           By Aristotle
#> 4          1974
#> 5          1974                                         A Translation By S. H. Butcher
#> 6          1974
#> 7          1974
#> 8          1974        [Transcriber's Annotations and Conventions: the translator left
#> 9          1974 intact some Greek words to illustrate a specific point of the original
#> 10         1974   discourse. In this transcription, in order to retain the accuracy of
#> ..          ...                                                                    ...
#>                       title
#>                       (chr)
#> 1  The Poetics of Aristotle
#> 2  The Poetics of Aristotle
#> 3  The Poetics of Aristotle
#> 4  The Poetics of Aristotle
#> 5  The Poetics of Aristotle
#> 6  The Poetics of Aristotle
#> 7  The Poetics of Aristotle
#> 8  The Poetics of Aristotle
#> 9  The Poetics of Aristotle
#> 10 The Poetics of Aristotle
#> ..                      ...
```

### FAQ

#### What do I do with the text once I have it?

* The [Natural Language Processing CRAN View](https://cran.r-project.org/view=NaturalLanguageProcessing) suggests many R packages related to text mining, especially around the [tm package](https://cran.r-project.org/package=tm).
* The [tidytext](https://github.com/juliasilge/tidytext) package is useful for tokenization and analysis, especially since gutenbergr downloads books as a data frame already.
* You could match the `wikipedia` column in `gutenberg_author` to Wikipedia content with the [WikipediR](https://cran.r-project.org/package=WikipediR) package or to pageview statistics with the [wikipediatrend](https://cran.r-project.org/package=wikipediatrend) package.
* If you're considering an analysis based on author name, you may find the [humaniformat](https://cran.r-project.org/package=humaniformat) (for extraction of first names) and [gender](https://cran.r-project.org/package=gender) (prediction of gender from first names) packages useful. (Note that humaniformat has a `format_reverse` function for reversing "Last, First" names).

#### How were the metadata R files generated?

See the [data-raw](data-raw) directory for the scripts that generate these datasets. As of now, these were generated from [the Project Gutenberg catalog](https://www.gutenberg.org/wiki/Gutenberg:Feeds#The_Complete_Project_Gutenberg_Catalog) on **05 May 2016**.

#### Do you respect the rules regarding robot access to Project Gutenberg?

Yes! The package respects [these rules](https://www.gutenberg.org/wiki/Gutenberg:Information_About_Robot_Access_to_our_Pages) and complies to the best of our ability. Namely:

* Project Gutenberg allows wget to harvest Project Gutenberg using [this list of links](http://www.gutenberg.org/robot/harvest?filetypes[]=html). The gutenbergr package visits that page once to find the recommended mirror for the user's location.
* We retrieve the book text directly from that mirror using links in the same format. For example, Frankenstein (book 84) is retrieved from `http://www.gutenberg.lib.md.us/8/84/84.zip`.
* We retrieve the .zip file rather than txt to minimize bandwidth on the mirror.

Still, this package is *not* the right way to download the entire Project Gutenberg corpus (or all from a particular language). For that, follow [their recommendation](https://www.gutenberg.org/wiki/Gutenberg:Information_About_Robot_Access_to_our_Pages) to use wget or set up a mirror. This package is recommended for downloading a single work, or works for a particular author or topic.

### Code of Conduct

This project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

[![ropensci\_footer](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
