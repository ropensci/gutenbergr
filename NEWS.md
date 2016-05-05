# gutenbergr 0.1.0.9000

* The license was changed from MIT to GPL-2. This is based on the realization that the catalog data is licensed under the GPL, and the package includes a processed version of the catalog data. (See [here](https://www.gutenberg.org/wiki/Gutenberg:Feeds#The_Complete_Project_Gutenberg_Catalog)).
* Updated datasets to 5/5/2016 and added a "date_updated" attriute to tell when they were last updated
* Various documentation, vignette, and README adjustments in response to ROpenSci feedback.
* Added AppVeyor for Windows continuous integration
* Added code coverage information through codecov.io and covr

# gutenbergr 0.1

* First version of package, including
  * `gutenberg_download` function, for downloading one or more works from Project Gutenberg using Gutenberg IDs
  * Datasets of Project Gutenberg metadata: `gutenberg_metadata`, `gutenberg_subjects`, `gutenberg_authors`
  * `gutenberg_works` function to retrieve filtered version of `gutenberg_metadata`
  * Introductory vignette including basic examples of downloading books
  * Unit tests for `gutenberg_download` and `gutenberg_works`
* Added a `NEWS.md` file to track changes to the package.
