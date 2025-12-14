#!/bin/bash

set -e
echo "* Setting up freeradius..."

# --------------------------------------------------------------
# Prep
# --------------------------------------------------------------

sudo cp -p ${FRAD_CONFIG_DIR}/radiusd.conf ${FRAD_CONFIG_DIR}/radiusd.conf.orig
sudo cp -p ${FRAD_CONFIG_DIR}/proxy.conf ${FRAD_CONFIG_DIR}/proxy.conf.orig
sudo cp -p ${FRAD_CONFIG_DIR}/clients.conf ${FRAD_CONFIG_DIR}/clients.conf.orig
sudo cp -pr ${FRAD_CONFIG_DIR}/mods-enabled ${FRAD_CONFIG_DIR}/mods-enabled.orig
sudo cp -pr ${FRAD_CONFIG_DIR}/sites-enabled ${FRAD_CONFIG_DIR}/sites-enabled.orig
sudo cp -pr ${FRAD_CONFIG_DIR}/certs ${FRAD_CONFIG_DIR}/certs.orig
# Empty the dirs
sudo rm -rf ${FRAD_CONFIG_DIR}/mods-enabled/*
sudo rm -rf ${FRAD_CONFIG_DIR}/sites-enabled/*
sudo rm -rf ${FRAD_CONFIG_DIR}/certs/*



