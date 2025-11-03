#!/bin/bash

set -e

echo "[ START ] Begin installation."
echo "[ INFO ] To abort the installation, use CTRL+C."

# Source environment variables
source $HOME/.local/share/upinem/install/_config.sh
# Check architecture and OS
source $INSTALL_DIR/_requirements.sh

# TODO: install dependencies for FreeRADIUS
sudo apt-get update >/dev/null
# C compiler REQUIRED to build
# To remove: `sudo apt-get purge build-essential`
# Then use: `sudo apt-get remove build-essential`
# To remove residual dependencies `sudo apt-get autoremove`
echo "* Installing dependencies for freeradius..."
sudo apt-get install -y build-essential libtalloc-dev libkqueue-dev libssl-dev >/dev/null
# Dependencies for configuration
sudo apt-get install -y libcurl4-openssl-dev libjson-c-dev >/dev/null #rlm_rest
sudo apt-get install -y libmemcached-dev >/dev/null #rlm_cache_memcached
sudo apt-get install -y libhiredis-dev >/dev/null #rlm_cache_redis & rlm_redis
sudo apt-get install -y libsqlite3-dev >/dev/null #rlm_sql_sqlite
sudo apt-get install -y libgdbm-compat-dev >/dev/null #rlm_counter
echo "* Cloning freeradius-server repository..."
# Clone the FreeRADIUS server repo
git clone https://github.com/FreeRADIUS/freeradius-server.git $HOME/.local/src/freeradius-server && cd $_
# NOTE: building would be with the CLI tool
echo "* [ START ] Building freeradius..."
# Switch branch do `git checkout <TAG_NAME>`
# e.g. `git checkout release_3_2_8`
git checkout release_3_2_8 >/dev/null
# Switch CLI tool only when supported versions are known
./configure --prefix=$HOME/freeradius/ --with-modules='rlm_eap_tls,rlm_rest,rlm_sql_sqlite' --enable-strict-dependencies --enable-werror --enable-reproducible-builds --disable-option-checking --without-experimental-modules --cache-file=/dev/null --srcdir=. --without-rlm_eap_tnc --without-rlm_eap_ikev2 --without-rlm_krb5 --without-rlm_ldap --without-rlm_digest --without-rlm_dynamic_clients --without-rlm_eap_fast --without-rlm_eap_gc --without-rlm_eap_md5 --without-rlm_eap_sim --without-rlm_eap_teap --without-rlm_opendirectory --without-rlm_eap_securid --without-rlm_smsotp --without-rlm_soh --without-rlm_totp --without-rlm_wimax --without-rlm_yubikey --without-rlm_cache_rbtree --without-rlm_couchbase --without-rlm_dpsk --without-rlm_kafka --without-rlm_ldap --without-rlm_sql_db2 --without-rlm_sql_firebird --without-rlm_sql_freetds --without-rlm_sql_iodbc --without-rlm_sql_mongo --without-rlm_sql_mysql --without-rlm_sql_oracle --without-rlm_sql_postgresql --without-rlm_sql_unixodbc --without-rlm_exec --without-rlm_perl --without-rlm_python --without-rlm_python3 --without-rlm_ruby --without-rlm_proxy_rate_limit --without-rlm_pam --without-rlm_unbound >/dev/null 2>&1

make >/dev/null 2>&1
sudo make install >/dev/null 2>&1
cd -
export PATH=$HOME/freeradius/sbin:$HOME/freeradius/bin:$PATH
echo -e "export PATH=\$HOME/freeradius/sbin:\$HOME/freeradius/bin:\$PATH" >> $HOME/.bashrc
sudo chown -R joshua:joshua $HOME/freeradius

echo "* [ SUCCESS ] Build process for freeradius is complete!"

# TODO: install dependencies for Vault
# Golang is REQUIRED https://go.dev/wiki/Ubuntu
# For uninstallation: use add-apt-repository with --remove option
sudo add-apt-repository -y ppa:longsleep/golang-backports >/dev/null
sudo apt-get update >/dev/null
sudo apt-get install -y golang-go >/dev/null
export GOPATH=$HOME/go
export GOBIN=$HOME/go/bin
export PATH=$GOBIN:$PATH
echo -e "export GOPATH=$HOME/go" >> $HOME/.bashrc
echo -e "export GOPATH=$GOBIN" >> $HOME/.bashrc
# TODO: install Vault
mkdir -p ${GOPATH}/src/hashicorp && cd $_
git clone https://github.com/hashicorp/vault.git >/dev/null && cd vault
# Dependencies for build process
go get github.com/alvaroloes/enumer
make bootstrap >/dev/null 2>&1
make dev >/dev/null 2>&1
# TODO: install CLI tool
