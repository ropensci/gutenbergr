# run this script to find out which have text files
# works only in UNIX-like environments

(for filename in ~/Downloads/cache/epub/*/*.rdf;
    do grep -p '<pgterms:file.*\d\.txt"' $filename;
    done) | egrep -o '/(\d+)/' > have_text.txt
