#!/bin/bash

tee payload-unseal.json <<EOF
{
  "key": "$(cat $HOME/.vault_unseal_key)"
}
EOF
