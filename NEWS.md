# gutenbergr 0.2.0

* Changed to comply with CRAN policies for API packages. Tests that do connect to Project Gutenberg are skipped on CRAN, and are supplemented with tests that mock the connection.
* Added gutenberg_languages dataset with one-row-per-language-per-work, which substantially speeds up gutenberg_works.
* This adds a files argument to gutenberg_download that is generally used only for testing.
* Made changes to work with dplyr 1.0.0, removing filter_ and distinct_.
* Fixed links to https

# gutenbergr 0.1.5

* Make compatible with tidyr v1.0.0
* data_frame is deprecated, use tibble (thanks @evanodell for #21)
* ROpenSci updates to README (thanks @maelle for #23)

# gutenbergr 0.1.4

* Added curl to SUGGESTS, since if it's not installed `readr::read_lines` could fail

# gutenbergr 0.1.3

* The Project Gutenberg mirror in Maryland Public Libraries (http://www.gutenberg.lib.md.us) has been broken for months. When it is provided from robot/harvest, replaces with `http://aleph.gutenberg.org`.
* Changed test of .zip capability not to run on CRAN
* Removed rvest dependency

# gutenbergr 0.1.2

* Made compatible with change to `distinct` in dplyr 0.5 (which is about to be submitted to CRAN)
* Removed xml2 dependency

# gutenbergr 0.1.1

* Transferred repo ownership to [ropenscilabs](https://github.com/ropenscilabs)
* The license was changed from MIT to GPL-2. This is based on the realization that the catalog data is licensed under the GPL, and the package includes a processed version of the catalog data. (See [here](https://www.gutenberg.org/ebooks/offline_catalogs.html)).
* Updated datasets to 5/5/2016 and added a "date_updated" attribute to tell when they were last updated
* Added `all_languages` and `only_languages` arguments to `gutenberg_works`, allowing fine-grained control of languages. (For example, "either English or French" or "both English and French")
* Changed get_gutenberg_mirror to use xml2 directly, in order to handle AppVeyor
* Removed use of data() in `gutenberg_works`, since it slows down `gutenberg_works` about 2X
* Various documentation, vignette, and README adjustments in response to ROpenSci feedback.
* Added AppVeyor for Windows continuous integration
* Added code coverage information through codecov.io and covr, along with tests to improve coverage

# gutenbergr 0.1

* First version of package, including
  * `gutenberg_download` function, for downloading one or more works from Project Gutenberg using Gutenberg IDs
  * Datasets of Project Gutenberg metadata: `gutenberg_metadata`, `gutenberg_subjects`, `gutenberg_authors`
  * `gutenberg_works` function to retrieve filtered version of `gutenberg_metadata`
  * Introductory vignette including basic examples of downloading books
  * Unit tests for `gutenberg_download` and `gutenberg_works`
* Added a `NEWS.md` file to track changes to the package.
