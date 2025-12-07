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

# Run the Vault binary as a process with systemd
source ${VAULT_REPO_DIR}/config/vault/vault.service.sh
sudo chmod 644 ./vault.service
sudo chown root:root ./vault.service
sudo mv ./vault.service /etc/systemd/system/
# Reference: https://developer.hashicorp.com/vault/docs/deploy/run-as-service
sudo systemctl daemon-reload
sudo systemctl enable vault.service
sudo systemctl start vault.service


# --------------------------------------------------------------
# Initialize & Unseal
# --------------------------------------------------------------

export VAULT_ADDR="https://127.0.0.1:8200"
export VAULT_CACERT=${VAULT_CONFIG}/vault-cert.pem
export CURL_CA_BUNDLE=$VAULT_CACERT

# Generate payload to initialize
source ${VAULT_REPO_DIR}/config/vault/payload-init.sh
curl --request POST --data @payload-init.json ${VAULT_ADDR}/v1/sys/init \
  | jq > result-init.json
jq -r ".root_token" result-init.json > .vault_token
jq -r ".keys[]" result-init.json > .vault_unseal_key

# Generate payload to unseal
source ${VAULT_REPO_DIR}/config/vault/payload-unseal.sh
curl -s --request POST --data @payload-unseal.json ${VAULT_ADDR}/v1/sys/unseal | jq
