#!/bin/bash

FAIL2BAN_JAIL_LOCAL="/etc/fail2ban/jail.local"

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y fail2ban

# Création ou écriture du fichier jail.local pour surcharger les règles par défaut
cat << 'EOF' > "$FAIL2BAN_JAIL_LOCAL"
[DEFAULT]
# Durée du ban (en secondes) : ici 1 heure (3600s)
bantime = 3600

# Fenêtre de temps pour compter les échecs : ici 10 minutes (600s)
findtime = 600

# Nombre d'échecs autorisés avant le bannissement
maxretry = 5

# Mode d'action par défaut (iptables / nftables)
banaction = iptables-multiport

[postfix]
enabled = true
port    = smtp,smtps,submission
logpath = /var/log/mail.log
backend = auto

[postfix-sasl]
enabled = true
port    = smtp,smtps,submission
logpath = /var/log/mail.log
backend = auto

[dovecot]
enabled = true
port    = imap,imaps,pop3,pop3s
logpath = /var/log/mail.log
backend = auto
EOF


systemctl restart fail2ban
systemctl enable fail2ban