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
# Dependencies for build process
echo "* Installing dependencies for freeradius..."
go get github.com/alvaroloes/enumer
echo "* Cloning vault repository..."
# Clone the Vault repo
git clone https://github.com/hashicorp/vault.git >/dev/null && cd vault
echo "* [ START ] Building vault..."
make bootstrap >/dev/null 2>&1
make dev >/dev/null 2>&1
echo "* [ SUCCESS ] Build process for vault is complete!"
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
