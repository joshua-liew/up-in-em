tee payload-signed.json <<EOF
{
  "certificate": $(cat intermediate.cert.pem)
}
EOF

