# gutenbergr 0.2.0

This is a re-submission after gutenbergr 0.1.5 was archived, which complies with the CRAN policies. My sincere apologies for not fixing the issue sooner, and I hope it can be returned to CRAN.

## Changes

Major changes:

* Fixed to comply with CRAN policies for API packages. Tests that do connect to Project Gutenberg are skipped on CRAN, and are supplemented with tests that mock the connection.

Minor changes:

* Added gutenberg_languages dataset with one-row-per-language-per-work, which substantially speeds up gutenberg_works.

Miscellaneous:

* Made changes to work with dplyr 1.0.0, removing filter_ and distinct_.
* Fixed links to https

## Test environments

* local OS X install, R 4.0.2
* Ubuntu 16.04.6 LTS (on travis-ci)
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 1 notes

The only NOTE is that this is a new submission after the last was archived.
