# requires the gitberg package
# https://github.com/gitenberg-dev/gitberg

# install with
# pip install xgitberg

### Running
# run with path to epub folder downloaded from
# https://www.gutenberg.org/wiki/Gutenberg:Feeds#The_Complete_Project_Gutenberg_Catalog

# For example:
# python gitenberg_meta.py ~/Downloads/cache/epub

import sys
import os
import json
import gzip

from gitenberg.metadata.pg_rdf import pg_rdf_to_json

infolder = sys.argv[1]
outfile = os.path.join("data-raw", "metadata.json.gz")

outputs = []

for i, (dirpath, dirnames, filenames) in enumerate(os.walk(infolder)):

    # skip empty folder
    if len(filenames) == 0:
        continue

    infile = os.path.join(dirpath, filenames[0])

    # filter files
    if not infile.endswith(".rdf"):
        continue


    if (i % 100) == 0:
        print(f"Iteration #{i} | file {infile}")

    j = pg_rdf_to_json(infile)
    outputs.append(json.dumps(j))

with gzip.open(outfile, "wt") as outf:
  outf.write("\n".join(outputs) + "\n")
