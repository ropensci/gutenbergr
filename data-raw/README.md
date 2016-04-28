This set of scripts produces the three .rda files in the [data](../data) directory. It is only moderately reproducible, as it needs to be run in a particular order and in a few cases even hardcodes paths. Expect it to be updated and improved soon.

If you're interested in parsing and processing the Gutenberg metadata yourself, the only file you really need is [metadata.json.gz](metadata.json.gz) (written by [gitenberg_meta.py](gitenberg_meta.py)), which contains one line with a JSON dictionary for every Project Gutenberg work. The JSON dictionary was produced from the Gutenberg RDF using the [gitberg Python package](https://github.com/gitenberg-dev/gitberg).

There are no guarantees about how often the metadata will be updated in the package. If you're interested in works that have been recently added or had their metadata edited on Project Gutenberg, you may want to run the scripts yourself.
