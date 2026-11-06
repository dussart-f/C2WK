#!/bin/bash

apt-get update
apt-get install -y bind9 bind9utils

cp -a /etc/bind/named.conf.options \
    /etc/bind/named.conf.options.bak

{
    echo "options {"
    echo "  directory "/var/cache/bind";"
    echo "  <listen-on { 127.0.0.1; };"
    echo "  listen-on-v6 { ::1; };"
    echo "}"

} > "/etc/bind/named.conf.options"

systemctl restart bind9

nslookup 'exemple.com'
nslookup 'google.com'
nslookup 'etna.io'

hostname