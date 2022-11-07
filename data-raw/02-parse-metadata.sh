# Bash script for parsing metadata files from gutemberg.org
# Tested on Ubuntu 20.04 / Linux Mint
#
# REQUIREMENTS (Python):
#   gitberg:
#        1) download from https://github.com/gitenberg-dev/gitberg
#        2) manual install (or use venv): pip3 install .

# cache folder from previous script
cache_dir="/tmp/cache/epub"

# parse each rdf file from previous step
python3 data-raw/py/gitenberg_meta.py $cache_dir

