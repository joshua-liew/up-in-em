#!/bin/bash

set -e
echo "* Building private CA with vault..."
export VAULT_TOKEN=$(cat $HOME/.vault_token) # NOTE: USER TOKEN
export VAULT_ADDR="https://127.0.0.1:8200"
export VAULT_CACERT=${VAULT_CONFIG}/vault-cert.pem
export CURL_CA_BUNDLE=$VAULT_CACERT

# --------------------------------------------------------------
# Generate Root CA
# --------------------------------------------------------------

# Generate root certificate
source ${UPINEM_PATH}/config/vault/build-ca/payload-gen-root-ca.sh >/dev/null
curl --header "X-Vault-Token: $VAULT_TOKEN" --request POST \
  --data @payload-gen-root-ca.json \
  $VAULT_ADDR/v1/pki_root/root/generate/internal \
  | jq -r ".data.certificate" > root_ca.pem

# Create root CA role
source ${UPINEM_PATH}/config/vault/build-ca/payload-role-root-ca.sh >/dev/null
curl -s --header "X-Vault-Token: $VAULT_TOKEN" --request POST \
  --data @payload-role-root-ca.json \
  $VAULT_ADDR/v1/pki_root/roles/root-ca-role

# Configure URLs for root CA
source ${UPINEM_PATH}/config/vault/build-ca/payload-url-root-ca.sh >/dev/null
curl --header "X-Vault-Token: $VAULT_TOKEN" --request POST \
  --data @payload-url-ca.json \
  $VAULT_ADDR/v1/pki_root/config/urls


# --------------------------------------------------------------
# Generate Intermediate CA
# --------------------------------------------------------------


# --------------------------------------------------------------
# Generate Server Certificates
# --------------------------------------------------------------


# --------------------------------------------------------------
# Generate Client Certificates
# --------------------------------------------------------------


