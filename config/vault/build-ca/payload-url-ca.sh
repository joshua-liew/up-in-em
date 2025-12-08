#!/bin/bash

tee payload-url-ca.json <<EOF
{
  "issuing_certificates": "${VAULT_ADDR}/v1/pki_root/ca",
  "crl_distribution_points": "${VAULT_ADDR}/v1/pki_root/crl"
}
EOF
