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


# --------------------------------------------------------------
# Vault installation script(s)
# --------------------------------------------------------------
source ${INSTALL_DIR}/vault/_config-vault.sh
source ${INSTALL_DIR}/vault/install-vault.sh
source ${INSTALL_DIR}/vault/setup-vault.sh
source ${INSTALL_DIR}/vault/build-ca-vault.sh


# --------------------------------------------------------------
# Freeradius installation script(s)
# --------------------------------------------------------------
source ${INSTALL_DIR}/freeradius/_config-freeradius.sh
source ${INSTALL_DIR}/freeradius/install-freeradius.sh
source ${INSTALL_DIR}/freeradius/setup-freeradius.sh


# TODO: install CLI tool
