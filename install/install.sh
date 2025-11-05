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
# Vault installation script(s)
# --------------------------------------------------------------
source ${INSTALL_DIR}/vault/_config-vault.sh
source ${INSTALL_DIR}/vault/install-vault.sh



# TODO: install CLI tool
