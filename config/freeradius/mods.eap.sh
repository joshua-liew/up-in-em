#!/bin/bash

tee eap <<'EOF'
eap {
    default_eap_type = tls
    timer_expire = 60
    ignore_unknown_eap_types = no
    max_sessions = ${max_requests}
    tls-config tls-common {
        private_key_file = ${certdir}/server.key
        certificate_file = ${certdir}/server.pem
        ca_file = ${cadir}/ca.pem
        ca_path = ${cadir}
        auto_chain = yes
        cipher_list = "DEFAULT"
        cipher_server_preference = no
        tls_min_version = "1.2"
        tls_max_version = "1.2"
        ecdh_curve = ""
    }
    tls {
        tls = tls-common
    }
}
EOF
