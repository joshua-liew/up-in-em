#!/bin/bash

set -e

# --------------------------------------------------------------
# Dependencies
# --------------------------------------------------------------

echo "* Installing dependencies for freeradius..."
sudo apt-get update >/dev/null
echo "* Essential dependencies: build-essential, libtalloc, libkqueue, libssl"
sudo apt-get install -y build-essential libtalloc-dev libkqueue-dev libssl-dev >/dev/null
echo "* Module dependencies: libcurl, libjson, libsqlite3"
sudo apt-get install -y libcurl4-openssl-dev libjson-c-dev >/dev/null #rlm_rest
sudo apt-get install -y libmemcached-dev >/dev/null #rlm_cache_memcached
sudo apt-get install -y libhiredis-dev >/dev/null #rlm_cache_redis,rlm_redis
sudo apt-get install -y libsqlite3-dev >/dev/null #rlm_sql_sqlite
sudo apt-get install -y libgdbm-compat-dev >/dev/null #rlm_counter


# --------------------------------------------------------------
# Build process
# --------------------------------------------------------------

echo "* Cloning freeradius-server repository..."
git clone https://github.com/FreeRADIUS/freeradius-server.git ${FRAD_REPO_DIR} && cd $_

echo "* [ START ] Building freeradius..."
# TODO: pull out build process with another tool
# Switch CLI tool only when supported versions are known
git checkout release_3_2_8 >/dev/null
# Step 1: Configure the installation
echo "* Configuring the freeradius installation..."
./configure --prefix=${FRAD_DIR} --with-raddbdir=${FRAD_CONFIG_DIR} --with-modules='rlm_eap_tls,rlm_rest,rlm_sql_sqlite' --enable-strict-dependencies --enable-werror --enable-reproducible-builds --disable-option-checking --without-experimental-modules --cache-file=/dev/null --srcdir=. --without-rlm_eap_tnc --without-rlm_eap_ikev2 --without-rlm_krb5 --without-rlm_ldap --without-rlm_digest --without-rlm_dynamic_clients --without-rlm_eap_fast --without-rlm_eap_gc --without-rlm_eap_md5 --without-rlm_eap_sim --without-rlm_eap_teap --without-rlm_opendirectory --without-rlm_eap_securid --without-rlm_smsotp --without-rlm_soh --without-rlm_totp --without-rlm_wimax --without-rlm_yubikey --without-rlm_cache_rbtree --without-rlm_couchbase --without-rlm_dpsk --without-rlm_kafka --without-rlm_ldap --without-rlm_sql_db2 --without-rlm_sql_firebird --without-rlm_sql_freetds --without-rlm_sql_iodbc --without-rlm_sql_mongo --without-rlm_sql_mysql --without-rlm_sql_oracle --without-rlm_sql_postgresql --without-rlm_sql_unixodbc --without-rlm_exec --without-rlm_perl --without-rlm_python --without-rlm_python3 --without-rlm_ruby --without-rlm_proxy_rate_limit --without-rlm_pam --without-rlm_unbound >/dev/null 2>&1
# Step 2: Make-ing the installation
echo "* Make-ing the freeradius installation..."
make >/dev/null 2>&1
# Step 3: Installation
echo "* Installing freeradius..."
sudo make install >/dev/null 2>&1
echo "* [ SUCCESS ] Build process for freeradius is complete!"


# ----------------------------------------------------------
# Configuration process
# ----------------------------------------------------------

cd - >/dev/null
# Step 1: Configure the environment
echo "* Configuring environment for freeradius..."
sudo mv ${FRAD_DIR}/bin/* /usr/local/sbin
sudo mv ${FRAD_DIR}/sbin/* /usr/local/sbin
sudo mv $(which radiusd) /usr/local/bin
# Step 2: Configure user permissions
echo "* Configuring user permissions for freeradius..."
sudo useradd --system --home ${FRAD_DIR} --shell /sbin/nologin freeradius
sudo chown freeradius:freeradius ${FRAD_CONFIG_DIR}
