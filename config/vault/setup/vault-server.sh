#!/bin/bash

tee vault-server.hcl <<EOF
api_addr                = "https://127.0.0.1:8200"
cluster_addr            = "https://127.0.0.1:8201"
cluster_name            = "upinem-vault-server"
disable_mlock           = true
ui                      = false

log_level               = "info"
log_requests_level      = "info"
log_format              = "standard"
log_file                = "${VAULT_LOG}/vault.log"
log_rotate_max_files    = "28"

listener "tcp" {
address       = "127.0.0.1:8200"
tls_cert_file = "${VAULT_CONFIG}/vault-cert.pem"
tls_key_file  = "${VAULT_CONFIG}/vault-key.pem"
}

backend "raft" {
path    = "${VAULT_DATA}"
node_id = "upinem-vault-server"
}
EOF
