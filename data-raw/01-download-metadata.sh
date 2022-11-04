# Bash script for downloading and parsing metadata files from gutemberg.org
#
# REQUIREMENTS:
#   gitberg: 
#        1) download from https://github.com/gitenberg-dev/gitberg
#        2) manual install: pip3 install .

# Downloads and unzip rdf files
# Runs on Ubuntu 20.04 / Linux Mint

f_name="rdf-files.tar.bz2"
temp_zip="/tmp/$f_name"

wget https://www.gutenberg.org/cache/epub/feeds/$f_name  -O $temp_zip -v 

tar -xf $temp_zip -C "/tmp"
