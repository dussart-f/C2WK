#!/bin/bash

DOMAIN="etna.nx"
SELECTOR="default"
OPENDKIM_CONF="/etc/opendkim.conf"
KEY_DIR="/etc/opendkim/keys/$DOMAIN"
POSTFIX_MAIN="/etc/postfix/main.cf"


export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y opendkim opendkim-tools


mkdir -p "$KEY_DIR"
opendkim-genkey -b 2048 -s "$SELECTOR" -d "$DOMAIN" -D "$KEY_DIR"

chown -R opendkim:opendkim /etc/opendkim
chmod 700 /etc/opendkim/keys
chmod 600 "$KEY_DIR/$SELECTOR.private"

# Écriture de la configuration principale d'OpenDKIM
cat << EOF > "$OPENDKIM_CONF"
AutoRestart          Yes
AutoRestartRate      10/1h
Umask                002
Syslog               Yes
SyslogSuccess        Yes
LogWhy               Yes
Canonicalization     relaxed/relaxed
Mode                 sv
SubDomains           No
Identifier           OpenDKIM
Socket               inet:12301@localhost
PidFile              /var/run/opendkim/opendkim.pid
SignatureAlgorithm   rsa-sha256

UserID               opendkim:opendkim

KeyFile              $KEY_DIR/$SELECTOR.private
Selector             $SELECTOR
Domain               $DOMAIN

InternalHosts        refile:/etc/opendkim/TrustedHosts
ExternalIgnoreList   refile:/etc/opendkim/TrustedHosts
KeyTable             refile:/etc/opendkim/KeyTable
SigningTable         refile:/etc/opendkim/SigningTable
EOF

# configurer les hotes de confiance
cat << EOF > /etc/opendkim/TrustedHosts
127.0.0.1
localhost
192.168.1.0/24
*.$DOMAIN
$DOMAIN
EOF

# association de la clé
cat << EOF > /etc/opendkim/KeyTable
${SELECTOR}._domainkey.${DOMAIN} ${DOMAIN}:${SELECTOR}:${KEY_DIR}/${SELECTOR}.private
EOF

# définition des adresses mails à signer avec cette clé
cat << EOF > /etc/opendkim/SigningTable
*@${DOMAIN} ${SELECTOR}._domainkey.${DOMAIN}
EOF

# Ajout des filtres Milter DKIM dans Postfix (main.cf)
postconf -e "milter_protocol = 2"
postconf -e "milter_default_action = accept"
postconf -e "smtpd_milters = inet:127.0.0.1:12301"
postconf -e "non_smtpd_milters = inet:127.0.0.1:12301"

systemctl restart opendkim
systemctl restart postfix