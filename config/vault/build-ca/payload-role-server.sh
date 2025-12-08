#!/bin/bash

tee payload-role-server.json <<EOF
{
  "issuer_ref": "default",
  "max_ttl": "26280h",
  "allowed_domains": "radius.example.com, example.com",
  "allow_subdomains": true,
  "allow_bare_domains": true,
  "allow_glob_domains": true,
  "cn_validations": "hostname",
  "require_cn": true,
  "enforce_hostnames": true,
  "server_flag": true,
  "client_flag": false,
  "key_usage": ["DigitalSignature", "KeyEncipherment"],
  "ext_key_usage": ["ServerAuth"],
  "allowed_other_sans": "1.3.6.1.5.5.7.8.8;UTF8:*",
  "key_type": "rsa",
  "key_bits": 4096,
  "organization": "Aomori University",
  "country": "JP",
  "province": "Aomori-ken",
  "locality": "Aomori-shi"
}
EOF
