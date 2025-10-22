#!/bin/bash

echo "[ START ] Begin installation."
echo "[ INFO ] To abort the installation, use CTRL+C."

# Source environment variables
source $HOME/.local/share/upinem/install/_config.sh
# Check architecture and OS
source $INSTALL_DIR/_requirements.sh

# TODO: install dependencies for FreeRADIUS
# TODO: install FreeRADIUS
# TODO: install dependencies for Vault
# TODO: install Vault
# TODO: install CLI tool
