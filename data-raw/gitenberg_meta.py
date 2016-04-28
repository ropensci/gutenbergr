# requires the gitberg package
# https://github.com/gitenberg-dev/gitberg

import sys
import os
import json
import gzip

from gitenberg.metadata.pg_rdf import pg_rdf_to_json

# hardcoded for now
infolder = os.path.expanduser(os.path.join("~", "Downloads", "cache", "epub"))
outfile = os.path.join("data-raw", "metadata.json.gz")

with gzip.GzipFile(outfile, "w") as outf:
    for i, (dirpath, dirnames, filenames) in enumerate(os.walk(infolder)):
        if (i % 100) == 0:
            print i

        infile = os.path.join(dirpath, filenames[0])

        if not infile.endswith(".rdf"):
            continue

        j = pg_rdf_to_json(infile)
        outf.write(json.dumps(j) + "\n")

