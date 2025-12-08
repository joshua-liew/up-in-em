#!/bin/bash

tee test-client-eapol.conf <<EOF
network={
        ssid="test"
        key_mgmt=WPA-EAP
        eap=TLS
        identity="test@example.com"
        ca_cert="/tmp/certs/ca.pem"
        client_cert="/tmp/certs/clients/test-client.pem"
        private_key="/tmp/certs/clients/test-client.key"
        eapol_flags=3
}
EOF
