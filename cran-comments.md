## Test environments
* local OS X install, R 3.2.3
* ubuntu 12.04 (on travis-ci), R 3.2.3
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 1 note

The one note is 

    checking data for non-ASCII characters ... NOTE
      Note: found 13591 marked UTF-8 strings

The marked UTF-8 strings are in the gutenberg_metadata, gutenberg_author
and gutenberg_subject datasets. These accurately represent the titles and
author's names (e.g. "Brontë, Charlotte") from Project Gutenberg works,
so I have elected not to change them.

## Reverse dependencies

This is a new release, so there are no reverse dependencies.
