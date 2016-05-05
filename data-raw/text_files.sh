#!/bin/bash

# run this script to find out which of the Gutenberg works
# have text files (as opposed to e.g. audiobooks)

# works only in UNIX-like environments

(for filename in ~/Downloads/cache/epub/*/*.rdf;
    do grep -p '<pgterms:file.*\d\.txt"' $filename;
    done) | egrep -o '/\d+/' | sed 's/\///g' | uniq > data-raw/ids_with_text.txt
