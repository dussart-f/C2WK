#!/bin/bash

CERT_DIR="/etc/ssl/certs"
PRIVATE_DIR="/etc/ssl/private"
DOMAIN="etna.nx"

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "$PRIVATE_DIR/postfix.key" \
  -out "$CERT_DIR/postfix.crt" \
  -subj "/C=FR/ST=Ile-de-France/L=Paris/O=ETNA/CN=$DOMAIN"

#TLS pour les connexions entrantes (serveur)
postconf -e "smtpd_use_tls = yes"
postconf -e "smtpd_tls_cert_file = $CERT_DIR/postfix.crt"
postconf -e "smtpd_tls_key_file = $PRIVATE_DIR/postfix.key"
postconf -e "smtpd_tls_session_cache_database = btree:\${data_directory}/smtpd_scache"

#TLS pour les connexions sortantes (client)
postconf -e "smtp_use_tls = yes"
postconf -e "smtp_tls_session_cache_database = btree:\${data_directory}/smtp_scache"


postconf -e "smtpd_tls_security_level = may"
postconf -e "smtp_tls_security_level = may"

systemctl restart postfix