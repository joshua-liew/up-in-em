#!/bin/bash

tee payload-auth-login.json <<EOF
{
  "password": "$(cat $HOME/.vault_auth)"
}
EOF
