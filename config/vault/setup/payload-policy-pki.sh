#!/bin/bash

tee payload-policy-pki.json <<EOF
{
  "policy": "path \"sys/mounts\" {\n  capabilities = [\"read\", \"list\"]\n}\n\npath \"pki*\" {\n  capabilities = [\"create\", \"read\", \"update\", \"delete\", \"list\", \"sudo\", \"patch\"]\n}\n"
}
EOF
