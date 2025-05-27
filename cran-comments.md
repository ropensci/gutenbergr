## R CMD check results

0 errors | 1 warnings | 2 note

* Warning is this: "LaTeX errors when creating PDF version. This typically indicates Rd problems. LaTeX errors found:". There isn't anything after the ":". My current suspicion is that it's an artefact from old-style documentation. I'm rewriting documentation to try to remove this warning.
* Note 1: Maintainer change from Myfanwy Johnston <mrowlan1@gmail.com> to Jon Harmon <jonthegeek@gmail.com>. Myfanwy will send an email confirming the change.
* Note 2: non-standard file found in check directory: 'gutenbergr-manual.tex'. I suspect this is related to the warning, and hope to eliminate both.
