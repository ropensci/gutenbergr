# Bash script for parsing metadata files from gutemberg.org
# Runs on Ubuntu 20.04 / Linux Mint
#  
# REQUIREMENTS (Python):
#   gitberg: 
#        1) download from https://github.com/gitenberg-dev/gitberg
#        2) manual install: pip3 install .

# parse each file individually
cash_dir="/tmp/cache/epub"

python3 data-raw/py/gitenberg_meta.py $cash_dir

