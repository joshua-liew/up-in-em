#!/bin/bash

tee payload-gen-test-client.json <<EOF
{
  "common_name": "test@example.com",
  "alt_names": "test@example.com",
  "ttl": "8760h"
}
EOF
