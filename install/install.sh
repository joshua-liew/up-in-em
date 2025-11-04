#!/bin/bash

set -e

echo "[ START ] Begin installation."
echo "[ INFO ] To abort the installation, use CTRL+C."

# --------------------------------------------------------------
# Setup
# --------------------------------------------------------------
# Source environment variables
source ${UPINEM_PATH}/install/_config.sh
# Check architecture and OS
source ${INSTALL_DIR}/_requirements.sh
# Create directory for server configuration/settings
mkdir -p ${CONFIG_DIR}


# --------------------------------------------------------------
# Freeradius installation script(s)
# --------------------------------------------------------------
source ${INSTALL_DIR}/freeradius/_config-freeradius.sh
source ${INSTALL_DIR}/freeradius/install-freeradius.sh


# --------------------------------------------------------------
# Freeradius installation script(s)
# --------------------------------------------------------------
source ${INSTALL_DIR}/vault/_config-vault.sh
source ${INSTALL_DIR}/vault/install-vault.sh

echo "* Configuring vault..."
# https://developer.hashicorp.com/vault/docs/get-vault/install-binary
# Step 1: Configure the environment
echo "* Configuring environment for vault..."
export VAULT_DATA=/opt/vault/data
export VAULT_CONFIG=/etc/vault.d
sudo mv $(which vault) /usr/bin
sudo setcap cap_ipc_lock=+ep $(readlink -f $(which vault))
sudo mkdir -p ${VAULT_DATA}
sudo mkdir -p ${VAULT_CONFIG}
# Step 2: Configure user permissions
echo "* Configuring user permissions for vault..."
sudo useradd --system --home ${VAULT_DATA} --shell /sbin/nologin vault
sudo chown vault:vault ${VAULT_DATA}
sudo chmod -R 750 ${VAULT_DATA}


# TODO: install CLI tool
