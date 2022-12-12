# gutenbergr 0.2.2

This release is a re-submission and maintainer change after gutenbergr 0.2.1 was archived.

## Changes

Major changes:

* New package maintainer: Myfanwy Johnston <mrowlan1@gmail.com>

Minor changes:

* Updated package metadata.

Miscellaneous:

* Documentation updates and fixes throughout (updated to latest version of roxygen2, resolved missing return value and examples, removed/updated broken urls)
* On advice to minimize server time in test environments, some gutenberg_download() and gutenberg_works() examples are now wrapped in donttest{}.

## Test environments

* local OS X install, R 4.2.1
    2 NOTEs: installed package size, found marked UTF-8 strings in the data directory. These strings are in the metadata from Project Gutenberg.
* Ubuntu 22.04.1 LTS (release & development)
    1 NOTE: installed package size
* Windows Server 2022, 10.0.20348
    1 NOTE: installed package size

## R CMD check results

0 errors | 0 warnings | 2 notes

The only NOTEs are that this is a new submission after the last was archived, and that installed size is  5.0Mb. This due to the data requirements of the package; that said, we reduced the number of test files in this release and are developing options that would further reduce the size of the installed package in the next release.
