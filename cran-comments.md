## gutenbergr 2.3.9100

This release is a re-submission after gutenbergr 2.3.0 was archived.

## Changes

Minor changes:

* Some examples in `gutenberg_download()` have been updated to `@examplesIf interactive()` to address graceful failure while preserving the interactive intent of the functions.
* urls in the README have been updated where necessary

## R CMD check results

0 errors | 0 warnings | 2 notes

* Package was archived on CRAN for policy violation On Internet access. 
* installed size is 5.3MB; sub-directories of 1Mb or more: data (4.9Mb). This due to the data requirements of the package and the text files from Project Gutenberg for use in the examples. We will strive to further reduce the size of the installed package in the next major release.


## Test environments

* local OS X install, R 4.3.2
    2 NOTEs: installed package size, found marked UTF-8 strings in the data directory. These strings are in the metadata from Project Gutenberg.

* Windows Server 2022 x64 (build 20348)
    NOTE: New submission

Package was archived on CRAN

Version contains large components (0.2.3.9100)

CRAN repository db overrides:
  X-CRAN-Comment: Archived on 2023-08-10 for policy violation.

## revdepcheck results

We checked 1 reverse dependencies, comparing R CMD check results across CRAN and dev versions of this package.

 * We saw 0 new problems
 * We failed to check 0 packages
