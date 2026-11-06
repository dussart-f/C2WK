#!/bin/bash

DOVECOT_AUTH_CONF="/etc/dovecot/conf.d/10-auth.conf"
DOVECOT_MASTER_CONF="/etc/dovecot/conf.d/10-master.conf"

# activation d'authentification (plain login)
if grep -q "^#auth_mechanisms =" "$DOVECOT_AUTH_CONF" || ! grep -q "auth_mechanisms =" "$DOVECOT_AUTH_CONF"; then
  sed -i 's/^#\?auth_mechanisms =.*/auth_mechanisms = plain login/' "$DOVECOT_AUTH_CONF"
fi

# configuration du socket d'authentification Dovecot
cat << 'EOF' >> "$DOVECOT_MASTER_CONF"

service auth {
  unix_listener /var/spool/postfix/private/auth {
    mode = 0660
    user = postfix
    group = postfix
  }
}
EOF

systemctl restart dovecot

# Activation de l'authentification SMTP SASL pour Postfix
postconf -e "smtpd_sasl_type = dovecot"
postconf -e "smtpd_sasl_path = private/auth"
postconf -e "smtpd_sasl_auth_enable = yes"

postconf -e "broken_sasl_auth_clients = yes"
postconf -e "smtpd_recipient_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination"

systemctl restart postfix