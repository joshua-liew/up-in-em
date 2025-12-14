#!/bin/bash

tee radiusd.conf <<'EOF'
name = radiusd
prefix          = /usr/local
exec_prefix     = ${prefix}
sysconfdir      = ${prefix}/etc
libdir          = ${exec_prefix}/lib
sbindir         = ${exec_prefix}/sbin
checkrad        = ${sbindir}/checkrad
localstatedir   = /var
logdir          = ${localstatedir}/log/freeradius
radacctdir      = ${logdir}/radacct
run_dir         = ${localstatedir}/run/freeradius
pidfile         = ${run_dir}/freeradius.pid
raddbdir        = /etc/freeradius
confdir         = ${raddbdir}
modconfdir      = ${confdir}/mods-config
certdir         = ${confdir}/certs
cadir           = ${confdir}/certs
db_dir          = ${raddbdir}
max_request_time = 30
cleanup_delay = 5
max_requests = 16384
hostname_lookups = no
log {
        destination = files
        colourise = yes
        file = ${logdir}/freeradius.log
        syslog_facility = daemon
        stripped_names = no
        auth = no
        auth_badpass = no
        auth_goodpass = no
        msg_denied = "You are already logged in - access denied"
}
ENV { }
security {
        user    = freeradius
        group   = freeradius
        allow_core_dumps = no
        max_attributes = 200
        reject_delay = 1
        status_server = yes
        require_message_authenticator = auto
        limit_proxy_state = auto
        allow_vulnerable_openssl = no
}
proxy_requests = yes
$INCLUDE proxy.conf
$INCLUDE clients.conf
thread pool {
        start_servers = 5
        max_servers = 32
        min_spare_servers = 3
        max_spare_servers = 10
        max_requests_per_server = 0
        auto_limit_acct = no
}
modules {
        $INCLUDE mods-enabled/
}
policy {
        $INCLUDE policy.d/
}
$INCLUDE sites-enabled/
EOF
