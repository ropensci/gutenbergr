# gutenbergr 0.1.3

## Changes

* The Project Gutenberg mirror in Maryland Public Libraries (http://www.gutenberg.lib.md.us) has been broken for months. When it is provided from robot/harvest, replaces with `http://aleph.gutenberg.org`.
* Changed test of .zip capability not to run on CRAN
* Removed rvest dependency

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

There are currently no reverse dependencies on CRAN.
