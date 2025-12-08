#!/bin/bash

set -e
echo "* Setting up vault..."

# --------------------------------------------------------------
# TLS & Server Configs
# --------------------------------------------------------------

echo "* * Configuring TLS for vault..."
sudo openssl req -x509 -newkey rsa:4096 -sha256 -days 365 \
  -nodes -keyout ${VAULT_CONFIG}/vault-key.pem -out ${VAULT_CONFIG}/vault-cert.pem \
  -subj "/CN=localhost" \
  -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"

# Create server configuration file
source ${UPINEM_PATH}/config/vault/vault-server.sh >/dev/null
sudo chmod 640 ./vault-server.hcl
sudo mv ./vault-server.hcl /etc/vault.d/
sudo chown vault:vault --recursive $VAULT_CONFIG

echo "* * Running vault as process with systemd..."
# Run the Vault binary as a process with systemd
source ${UPINEM_PATH}/config/vault/vault.service.sh >/dev/null
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

echo "* * Initializing vault..."
# Generate payload to initialize
source ${UPINEM_PATH}/config/vault/payload-init.sh >/dev/null
curl -s --request POST --data @payload-init.json ${VAULT_ADDR}/v1/sys/init \
  | jq > result-init.json
jq -r ".root_token" result-init.json > $HOME/.vault_token
jq -r ".keys[]" result-init.json > $HOME/.vault_unseal_key

# Generate payload to unseal
source ${UPINEM_PATH}/config/vault/payload-unseal.sh >/dev/null
curl -s --request POST --data @payload-unseal.json \
  ${VAULT_ADDR}/v1/sys/unseal >/dev/null


# --------------------------------------------------------------
# Enable PKI Secret Engine(s)
# --------------------------------------------------------------

export VAULT_TOKEN=$(cat $HOME/.vault_token) # WARNING: ROOT TOKEN

echo "* * Configuring vault to build CA..."
# PKI engine for Root CA
curl --header "X-Vault-Token: $VAULT_TOKEN" --request POST \
   --data '{"type":"pki", "description":"Root CA (upinem)"}' \
   ${VAULT_ADDR}/v1/sys/mounts/pki_root
curl --header "X-Vault-Token: $VAULT_TOKEN" --request POST \
   --data '{"max_lease_ttl":"87600h"}' \
   ${VAULT_ADDR}/v1/sys/mounts/pki_root/tune

# PKI engine for Intermediate CA
curl --header "X-Vault-Token: $VAULT_TOKEN" --request POST \
  --data '{"type":"pki", "description":"Intermediate CA (upinem)"}' \
  ${VAULT_ADDR}/v1/sys/mounts/pki_int
curl --header "X-Vault-Token: $VAULT_TOKEN" --request POST \
  --data '{"max_lease_ttl":"43800h"}' \
  ${VAULT_ADDR}/v1/sys/mounts/pki_int/tune


# --------------------------------------------------------------
# Create Policy & Generate User Token
# --------------------------------------------------------------

echo "* * Generate user to authenticate to vault..."
# Create policy
source ${UPINEM_PATH}/config/vault/payload-policy-pki.sh >/dev/null
curl --header "X-Vault-Token: $VAULT_TOKEN" --request POST \
    --data @payload-policy-pki.json \
    ${VAULT_ADDR}/v1/sys/policies/acl/pki

# Enable authpass auth method
curl --header "X-Vault-Token: $VAULT_TOKEN" --request POST \
  --data '{"type":"userpass", "description":"Userpass auth (upinem)"}' \
  ${VAULT_ADDR}/v1/sys/auth/userpass
openssl rand -base64 32 > $HOME/.vault_auth

# Create user
source ${UPINEM_PATH}/config/vault/payload-auth-create.sh >/dev/null
curl --header "X-Vault-Token: $VAULT_TOKEN" --request POST \
    --data @payload-auth-create.json \
    ${VAULT_ADDR}/v1/auth/userpass/users/${USER}
# Login as user
source ${UPINEM_PATH}/config/vault/payload-auth-login.sh >/dev/null
curl -s --request POST \
  --data @payload-auth-login.json  \
  ${VAULT_ADDR}/v1/auth/userpass/login/${USER} \
  | jq -r ".auth.client_token" > $HOME/.vault_token

export VAULT_TOKEN=$(cat $HOME/.vault_token) # NOTE: USER TOKEN
