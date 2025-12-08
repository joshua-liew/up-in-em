#!/bin/bash

tee payload-gen-server.json <<EOF
{
  "common_name": "radius.example.com",
  "alt_names": "radius.example.com, upinem.example.com",
  "other_sans": "1.3.6.1.5.5.7.8.8;UTF8:*.example.com",
  "ttl": "8760h",
  "format": "pem_bundle"
}
EOF
