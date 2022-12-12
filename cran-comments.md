# gutenbergr 0.2.2

This is a re-submission and maintainer change after gutenbergr 0.2.1 was archived, which complies with the CRAN policies.

## Changes

* New package maintainer: Myfanwy Johnston <mrowlan1@gmail.com>

Minor changes:

* Updated package metadata.
* Updated documentation to comply 

Miscellaneous:

* Removed broken link

## Test environments

* local OS X install, R 4.2.1
* Ubuntu Linux 20.04.1 LTS, R-release, GCC
    2 NOTEs: new submission, elapsed server time

* Windows Server 2022, R-release, 32/64 bit
    2 NOTEs: new submission, 18981 marked UTF-8 strings. 
    The UTF-8 strings are in the data from gutenberg.org

## R CMD check results

0 errors | 0 warnings | 2 notes

The only NOTEs are that this is a new submission after the last was archived, and that installed size is  5.0Mb. This due to the data requirements of the package; that said, we reduced the number of test files in this release and are developing options that would further reduce the size of the installed package in the next release.
