#!/bin/bash

DOMAIN="je-le-trouve-beau-mon-domain"
MAILNAME_FILE="/etc/mailname"
MAIN_CF="/etc/postfix/main.cf"

apt-get update -y
apt-get install -y postfix mailutils

postconf -e "myhostname = localhost.$DOMAIN"
postconf -e "mydestination = \$myhostname, localhost, $DOMAIN, localhost.localdomain"
postconf -e "inet_interfaces = loopback-only"
postconf -e "inet_protocols = all"

systemctl restart postfix

echo "Ceci est un email de test généré automatiquement par le script Postfix." | mail -s "Test Subject" root@"$DOMAIN"