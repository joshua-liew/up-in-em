#!/bin/bash

set -e

echo "[ START ] Begin installation."
echo "[ INFO ] To abort the installation, use CTRL+C."

# Source environment variables
source $HOME/.local/share/upinem/install/_config.sh
# Check architecture and OS
source $INSTALL_DIR/_requirements.sh

# TODO: install dependencies for FreeRADIUS
# Clone the FreeRADIUS server repo
git clone https://github.com/FreeRADIUS/freeradius-server.git
# To switch branch do `git checkout <TAG_NAME>`
# e.g. `git checkout release_3_2_8`
# Switch CLI tool only when supported versions are known
sudo apt-get update >/dev/null
# C compiler REQUIRED to build
# To remove: `sudo apt-get purge build-essential`
# Then use: `sudo apt-get remove build-essential`
# To remove residual dependencies `sudo apt-get autoremove`
sudo apt-get install -y build-essential libtalloc-dev libkqueue-dev libssl-dev >/dev/null
# Dependencies for configuration
sudo apt-get install -y libcurl4-openssl-dev libjson-c-dev >/dev/null #rlm_rest
sudo apt-get install -y libmemcached-dev >/dev/null #rlm_cache_memcached
sudo apt-get install -y libhiredis-dev >/dev/null #rlm_cache_redis & rlm_redis
sudo apt-get install -y libsqlite3-dev >/dev/null #rlm_sql_sqlite
# cd first
./configure --disable-option-checking '--prefix=/usr/local'  '--without-experimental-modules' --cache-file=/dev/null --srcdir=.


# TODO: install dependencies for Vault
# TODO: install Vault
# TODO: install CLI tool
