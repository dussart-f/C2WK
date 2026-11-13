#!/bin/bash

sudo apt update
sudo apt install -y rsyslog

# Modifiez le fichier de configuration /etc/rsyslog.conf

# Sauvegarde de la configuration d'origine
sudo cp /etc/rsyslog.conf /etc/rsyslog.conf.bak

# Configuration pour écouter sur UDP et TCP (port 514)
sudo bash -c 'cat << "EOF" > /etc/rsyslog.d/30-rsyslog-server.conf
# Modules de réception réseau
module(load="imudp")
input(type="imudp" port="514")

module(load="imtcp")
input(type="imtcp" port="514")

# Template personnalisé pour organiser les logs par IP/hostname des clients
template(name="RemoteLogs" type="string" string="/var/log/remote/%HOSTNAME%/%PROGRAMNAME%.log")

# Application de la règle pour tous les messages distants
*.* ?RemoteLogs
& stop
EOF'

sudo systemctl restart rsyslog
sudo systemctl enable rsyslog