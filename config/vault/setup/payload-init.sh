#!/bin/bash

tee payload-init.json <<EOF
{
  "secret_shares": 1,
  "secret_threshold": 1
}
EOF
