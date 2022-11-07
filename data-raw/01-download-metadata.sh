# Bash script for downloading and parsing metadata files from gutenberg.org
#
# Tested on Ubuntu 22.04

# set file names
f_name="rdf-files.tar.bz2"
temp_zip="/tmp/$f_name"

# download file from gutenberg.org
wget https://www.gutenberg.org/cache/epub/feeds/$f_name  -O $temp_zip -v

# untar file into temp folder
tar -xf $temp_zip -C "/tmp"
