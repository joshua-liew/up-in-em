#!/bin/bash

tee payload-gen-int-ca.json <<EOF
{
  "common_name": "Upinem AOU Intermediate CA",
  "ttl": "43800h",
  "max_path_length": 0,
  "permitted_email_addresses": "example.com, example.org",
  "format": "pem_bundle",
  "use_csr_values": true,
  "csr": $(cat pki_intermediate.csr)
}
EOF
