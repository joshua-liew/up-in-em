#!/bin/bash

tee payload-auth-create.json <<EOF
{
  "password": "$(cat $HOME/.vault_auth)",
  "token_policies": ["pki", "default"]
}
EOF
