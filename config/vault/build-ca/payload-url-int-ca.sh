#!/bin/bash

tee payload-url-int-ca.json <<EOF
{
  "issuing_certificates": "${VAULT_ADDR}/v1/pki_int/ca",
  "crl_distribution_points": "${VAULT_ADDR}/v1/pki_int/crl"
}
EOF
