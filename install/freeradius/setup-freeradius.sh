#!/bin/bash

set -e
echo "* Setting up freeradius..."

# --------------------------------------------------------------
# Prep
# --------------------------------------------------------------

sudo mv ${FRAD_CONFIG_DIR}/radiusd.conf ${FRAD_CONFIG_DIR}/radiusd.conf.orig
sudo mv ${FRAD_CONFIG_DIR}/proxy.conf ${FRAD_CONFIG_DIR}/proxy.conf.orig
sudo mv ${FRAD_CONFIG_DIR}/clients.conf ${FRAD_CONFIG_DIR}/clients.conf.orig
sudo cp -pr ${FRAD_CONFIG_DIR}/mods-enabled ${FRAD_CONFIG_DIR}/mods-enabled.orig
sudo cp -pr ${FRAD_CONFIG_DIR}/sites-enabled ${FRAD_CONFIG_DIR}/sites-enabled.orig
sudo cp -pr ${FRAD_CONFIG_DIR}/certs ${FRAD_CONFIG_DIR}/certs.orig
# Empty the dirs
sudo rm -rf ${FRAD_CONFIG_DIR}/mods-enabled/*
sudo rm -rf ${FRAD_CONFIG_DIR}/sites-enabled/*
sudo rm -rf ${FRAD_CONFIG_DIR}/certs/*


# --------------------------------------------------------------
# Generate Config(s)
# --------------------------------------------------------------

source ${UPINEM_PATH}/config/freeradius/upinem.radiusd.conf.sh >/dev/null
source ${UPINEM_PATH}/config/freeradius/upinem.proxy.conf.sh >/dev/null
source ${UPINEM_PATH}/config/freeradius/upinem.clients.conf.sh >/dev/null
source ${UPINEM_PATH}/config/freeradius/mods.eap-tls.sh >/dev/null
source ${UPINEM_PATH}/config/freeradius/sites.eduroam.sh >/dev/null


# --------------------------------------------------------------
# Setup Configs
# --------------------------------------------------------------

# Move configs
sudo cp radiusd.conf $FRAD_CONFIG_DIR
sudo cp proxy.conf $FRAD_CONFIG_DIR
sudo cp clients.conf $FRAD_CONFIG_DIR
sudo cp eap-tls ${FRAD_CONFIG_DIR}/mods-available
sudo cp eduroam ${FRAD_CONFIG_DIR}/sites-available
# Set privileges
sudo chmod 640 ${FRAD_CONFIG_DIR}/radiusd.conf
sudo chmod 640 ${FRAD_CONFIG_DIR}/proxy.conf
sudo chmod 640 ${FRAD_CONFIG_DIR}/clients.conf
sudo chmod 640 ${FRAD_CONFIG_DIR}/mods-available/eap-tls
sudo chmod 640 ${FRAD_CONFIG_DIR}/sites-available/eduroam

# Enable modules
source ${UPINEM_PATH}/config/freeradius/mods.txt.sh >/dev/null
xargs -I {mod} \ 
  sudo ln -sr /etc/freeradius/mods-available/{mod} \
  /etc/freeradius/mods-enabled/{mod} < mods.txt
# Enable virtual servers (sites)
source ${UPINEM_PATH}/config/freeradius/sites.txt.sh >/dev/null
xargs -I {site} \ 
  sudo ln -sr /etc/freeradius/sites-available/{site} \
  /etc/freeradius/sites-enabled/{site} < sites.txt

# Set permissions
sudo chown freeradius:freeradius -Rh $FRAD_CONFIG_DIR
