#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y dovecot-imapd dovecot-pop3d

DOVECOT_CONF="/etc/dovecot/dovecot.conf"
DOVECOT_IMAP_CONF="/etc/dovecot/conf.d/10-master.conf"
DOVECOT_MAIL_CONF="/etc/dovecot/conf.d/10-mail.conf"
DOVECOT_AUTH_CONF="/etc/dovecot/conf.d/10-auth.conf"
DOVECOT_SSL_CONF="/etc/dovecot/conf.d/10-ssl.conf"

#location mail
if grep -q "^#mail_location =" "$DOVECOT_MAIL_CONF" || ! grep -q "mail_location =" "$DOVECOT_MAIL_CONF"; then
  sed -i 's|^#\?mail_location =.*|mail_location = mbox:~/mail:INBOX=/var/spool/mail/%u|' "$DOVECOT_MAIL_CONF"
fi

#forcé le IMAP
if grep -q "^#protocols =" /etc/dovecot/dovecot.conf; then
  sed -i 's/^#protocols =.*/protocols = imap pop3/' /etc/dovecot/dovecot.conf
elif ! grep -q "protocols =" /etc/dovecot/dovecot.conf; then
  echo "protocols = imap pop3" >> /etc/dovecot/dovecot.conf
fi

#authentification clair
sed -i 's/^#\?disable_plaintext_auth =.*/disable_plaintext_auth = no/' "$DOVECOT_AUTH_CONF"

#authentification SSL
sed -i 's/^#\?ssl =.*/ssl = yes/' "$DOVECOT_SSL_CONF"

systemctl restart dovecot
