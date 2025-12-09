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
curl -s --header "X-Vault-Token: $VAULT_TOKEN" --request POST \
  --data @payload-gen-root-ca.json \
  ${VAULT_ADDR}/v1/pki_root/root/generate/internal \
  | jq -r ".data.certificate" > root_ca.pem

# Create root CA role
source ${UPINEM_PATH}/config/vault/build-ca/payload-role-root-ca.sh >/dev/null
curl -s --header "X-Vault-Token: $VAULT_TOKEN" --request POST \
  --data @payload-role-root-ca.json \
  ${VAULT_ADDR}/v1/pki_root/roles/root-ca-role >/dev/null


# Configure URLs for root CA
source ${UPINEM_PATH}/config/vault/build-ca/payload-url-root-ca.sh >/dev/null
curl -s --header "X-Vault-Token: $VAULT_TOKEN" --request POST \
  --data @payload-url-root-ca.json \
  ${VAULT_ADDR}/v1/pki_root/config/urls >/dev/null


# --------------------------------------------------------------
# Generate Intermediate CA
# --------------------------------------------------------------

# Generate CSR for int CA
source ${UPINEM_PATH}/config/vault/build-ca/payload-gen-int-csr.sh >/dev/null
curl -s -H "X-Vault-Token: $VAULT_TOKEN" --request POST \
  --data @payload-gen-int-csr.json \
  ${VAULT_ADDR}/v1/pki_int/intermediate/generate/internal \
  | jq -c '.data | .csr' > pki_intermediate.csr

# Sign the int CA's CSR with the root CA
source ${UPINEM_PATH}/config/vault/build-ca/payload-gen-int-ca.sh >/dev/null
curl --silent --header "X-Vault-Token: $VAULT_TOKEN" --request POST \
  --data @payload-gen-int-ca.json \
  ${VAULT_ADDR}/v1/pki_root/issuer/root-ca/sign-intermediate \
  | jq '.data | .certificate' > intermediate.cert.pem

# Import int CA cert
source ${UPINEM_PATH}/config/vault/build-ca/payload-signed.sh >/dev/null
curl --silent --header "X-Vault-Token: $VAULT_TOKEN" --request POST \
  --data @payload-signed.json \
  ${VAULT_ADDR}/v1/pki_int/intermediate/set-signed >/dev/null

# Configure URLs for int CA
source ${UPINEM_PATH}/config/vault/build-ca/payload-url-int-ca.sh >/dev/null
curl -s -H "X-Vault-Token: $VAULT_TOKEN" --request POST \
  --data @payload-url-int-ca.json \
  ${VAULT_ADDR}/v1/pki_int/config/urls >/dev/null


# --------------------------------------------------------------
# Generate Server Certificates
# --------------------------------------------------------------

# Create server role
source ${UPINEM_PATH}/config/vault/build-ca/payload-role-server.sh >/dev/null
curl -s --header "X-Vault-Token: $VAULT_TOKEN" --request POST \
  --data @payload-role-server.json \
  ${VAULT_ADDR}/v1/pki_int/roles/eap-tls-server > /dev/null

# Issue server cert
source ${UPINEM_PATH}/config/vault/build-ca/payload-gen-server.sh >/dev/null
curl -s --header "X-Vault-Token: $VAULT_TOKEN" --request POST \
  --data @payload-gen-server.json \
  ${VAULT_ADDR}/v1/pki_int/issue/eap-tls-server \
  | jq > result-server-cert.json

# Extract private key, cert, & ca chain
jq -r '.data.private_key' result-server-cert.json > server.key
jq -r '.data.certificate' result-server-cert.json \
| grep -E 'BEGIN CERTIFICATE|END CERTIFICATE|' \
| awk '
    BEGIN {cert_found=0}
    /BEGIN CERTIFICATE/ { cert_found=1; print; next }
    cert_found { print }
    /END CERTIFICATE/ { exit }
' > server.pem
jq -r '.data.ca_chain[]' result-server-cert.json > ca.pem


# --------------------------------------------------------------
# Generate Client Certificates
# --------------------------------------------------------------

# Create client role
source ${UPINEM_PATH}/config/vault/build-ca/payload-role-client.sh >/dev/null
curl -s --header "X-Vault-Token: $VAULT_TOKEN" --request POST \
  --data @payload-role-client.json \
  ${VAULT_ADDR}/v1/pki_int/roles/eap-tls-client >/dev/null

# Issue test (client) credentials
source ${UPINEM_PATH}/config/vault/build-ca/payload-gen-test-client.sh >/dev/null
curl --header "X-Vault-Token: $VAULT_TOKEN" --request POST \
  --data @payload-gen-test-client.json \
  ${VAULT_ADDR}/v1/pki_int/issue/eap-tls-client \
  | jq > result-test-client.json
jq -r '.data.private_key' result-test-client.json > test-client.key
jq -r '.data.certificate' result-test-client.json > test-client.pem
# Create eapol test suite
source ${UPINEM_PATH}/config/vault/build-ca/test-client-eapol.sh >/dev/null
mkdir -p /tmp/certs/clients/
sudo cp -p ./test-client-eapol.conf /tmp/
sudo cp -p ./test-client.key /tmp/certs/clients/
sudo cp -p ./test-client.pem /tmp/certs/clients/
sudo cp -p ./ca.pem /tmp/certs/


# --------------------------------------------------------------
# TODO: Port necessary parts into FreeRADIUS
# --------------------------------------------------------------

