#!/bin/bash

set -e

# --------------------------------------------------------------
# Dependencies
# --------------------------------------------------------------

echo "* Installing dependencies for vault..."
echo "* Essential dependencies: golang"
sudo add-apt-repository -y ppa:longsleep/golang-backports >/dev/null
sudo apt-get update >/dev/null
sudo apt-get install -y golang-go >/dev/null


# --------------------------------------------------------------
# Build process
# --------------------------------------------------------------

#mkdir -p ${GOPATH}/src/hashicorp && cd $_
echo "* Cloning vault repository..."
git clone https://github.com/hashicorp/vault.git ${VAULT_REPO_DIR} && cd $_

echo "* [ START ] Building vault..."
echo "* Installing golang modules..."
go get github.com/alvaroloes/enumer
# Step 1: Bootstrapping the installation
echo "* Bootstrapping the build process..."
make bootstrap >/dev/null 2>&1
# Step 2: Install
echo "* Building the vault binary..."
make dev >/dev/null 2>&1
echo "* [ SUCCESS ] Build process for vault is complete!"
