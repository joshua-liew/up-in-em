#!/bin/bash

set -e

# --------------------------------------------------------------
# TLS & Server Configs
# --------------------------------------------------------------
sudo openssl req -x509 -newkey rsa:4096 -sha256 -days 365 \
  -nodes -keyout ${VAULT_CONFIG}/vault-key.pem -out ${VAULT_CONFIG}/vault-cert.pem \
  -subj "/CN=localhost" \
  -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"

# Create server configuration file
source ${VAULT_REPO_DIR}/config/vault/vault-server.sh
sudo chmod 640 ./vault-server.hcl
sudo mv ./vault-server.hcl /etc/vault.d/
sudo chown vault:vault --recursive $VAULT_CONFIG
export VAULT_ADDR="https://127.0.0.1:8200"
export VAULT_CACERT=${VAULT_CONFIG}/vault-cert.pem
export CURL_CA_BUNDLE=$VAULT_CACERT

# TODO: create systemd service file for Vault
