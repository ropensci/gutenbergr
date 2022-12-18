# gutenbergr 0.2.3

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
    NOTEs: installed package size, found marked UTF-8 strings in the data directory. These strings are in the metadata from Project Gutenberg.

* Ubuntu Linux 20.04.1 LTS, R-release, GCC
    NOTEs: new submission, installed package size, examples with CPU (user + system) or elapsed time > 5s

* Fedora Linux, R-devel, clang, gfortran
    NOTEs: new submission, installed package size, examples with CPU (user + system) or elapsed time > 5s, Skipping checking HTML validation: no command 'tidy' found

* Windows Server 2022, 10.0.20348
    NOTE: marked UTF-8 strings; see above

## R CMD check results

0 errors | 0 warnings | 2 notes

The NOTEs are: 1) new submission after the package was archived, and 2) installed size is  5.0Mb. This due to the data requirements of the package and the text files from Project Gutenberg for use in the examples. We reduced the number of files in this release and will strive to further reduce the size of the installed package in the next release.
