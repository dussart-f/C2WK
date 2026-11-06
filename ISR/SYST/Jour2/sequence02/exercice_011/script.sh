#!/bin/bash

POSTFIX_MAIN="/etc/postfix/main.cf"

export DEBIAN_FRONTEND=noninteractive

# Installer les dépendances pour ajouter les dépôts si ce n'est pas fait
apt-get update -y
apt-get install -y curl lsb-release gnupg

# Ajouter la clé GPG et le dépôt officiel Rspamd
mkdir -p /etc/apt/keyrings
curl -fsSL https://rspamd.com/apt-stable/gpg -o /etc/apt/keyrings/rspamd.asc

echo "deb [signed-by=/etc/apt/keyrings/rspamd.asc] http://rspamd.com/apt-stable/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/rspamd.list

apt-get update -y
apt-get install -y rspamd

systemctl start rspamd

postconf -e "smtpd_milters = inet:127.0.0.1:11332"
postconf -e "non_smtpd_milters = inet:127.0.0.1:11332"
postconf -e "milter_default_action = accept"

systemctl restart postfix