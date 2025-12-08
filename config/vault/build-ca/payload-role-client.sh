#!/bin/bash

tee payload-role-client.json <<EOF
{
  "issuer_ref": "default",
  "max_ttl": "26280h",
  "allowed_domains": "example.com, example.org",
  "allow_subdomains": true,
  "allow_bare_domains": true,
  "allow_glob_domains": false,
  "cn_validations": "email",
  "require_cn": true,
  "enforce_hostnames": false,
  "server_flag": false,
  "client_flag": true,
  "key_usage": ["DigitalSignature", "KeyAgreement"],
  "ext_key_usage": ["ClientAuth"],
  "key_type": "rsa",
  "key_bits": 4096,
  "organization": "Aomori University",
  "country": "JP",
  "province": "Aomori-ken",
  "locality": "Aomori-shi"
}
EOF
