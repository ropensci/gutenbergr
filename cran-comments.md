# gutenbergr 0.1.1

## Changes

* Transferred repo ownership to [ropenscilabs](https://github.com/ropenscilabs)
* The license was changed from MIT to GPL-2. This is based on the realization that the catalog data is licensed under the GPL, and the package includes a processed version of the catalog data. (See [here](https://www.gutenberg.org/wiki/Gutenberg:Feeds#The_Complete_Project_Gutenberg_Catalog)).
* Updated datasets to 5/5/2016 and added a "date_updated" attriute to tell when they were last updated
* Added `all_languages` and `only_languages` arguments to `gutenberg_works`, allowing fine-grained control of languages. (For example, "either English or French" or "both English and French")
* Changed get_gutenberg_mirror to use xml2 directly, in order to handle AppVeyor
* Removed use of data() in `gutenberg_works`, since it slows down `gutenberg_works` about 2X
* Various documentation, vignette, and README adjustments in response to ROpenSci feedback.
* Added AppVeyor for Windows continuous integration
* Added code coverage information through codecov.io and covr, along with tests to improve coverage

## Test environments

* local OS X install, R 3.3.0
* ubuntu 12.04 (on travis-ci), R 3.2.3
* win-builder (devel and release)

## R CMD check results

The NOTES are the same as the last release, described below.

0 errors | 0 warnings | 2 notes

The notes are:

    Possibly mis-spelled words in DESCRIPTION:
      metadata (8:36)

This word is correctly spelled.

    Found the following (possibly) invalid URLs:
	    URL: http://www.gutenberg.org/files/84/84.txt
		    From: inst/doc/intro.html
		    Status: 403
		    Message: Forbidden
	    URL: https://www.gutenberg.org/
		    From: inst/doc/intro.html
		    	  README.md
		    Status: Error
		    Message: libcurl error code 35
			    error:14077410:SSL routines:SSL23_GET_SERVER_HELLO:sslv3 alert handshake failure
    <several other URLs snipped for length>

These links appear in the README and the intro vignette, and are to Project
Gutenberg. Project Gutenberg blocks automated traffic, so these appear blocked
when accessed from CRAN/build_win/etc. The URLs are accurate.

    checking data for non-ASCII characters ... NOTE
      Note: found 13591 marked UTF-8 strings

The marked UTF-8 strings are in the gutenberg_metadata, gutenberg_author
and gutenberg_subject datasets. These accurately represent the titles and
author's names (e.g. "Brontë, Charlotte", or works in Chinese/Japanese)
from Project Gutenberg works, so I have elected not to change them.

## Reverse dependencies

This is a new release, so there are no reverse dependencies.
