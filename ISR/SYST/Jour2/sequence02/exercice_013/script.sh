#!/bin/bash

DOMAIN="etna.nx"
# Récupération automatique de l'IP publique ou locale principale du serveur (ou personnalisable)
SERVER_IP=$(hostname -I)

SPF_RECORD="v=spf1 ip4:$SERVER_IP mx ~all"

BIND_ZONE_FILE="/etc/bind/db.$DOMAIN"


echo "@ IN TXT \"$SPF_RECORD\"" >> "$BIND_ZONE_FILE"

SERIAL=$(grep -o '[0-9]\{10\}' "$BIND_ZONE_FILE" | head -1)
if [ ! -z "$SERIAL" ]; then
    NEW_SERIAL=$((SERIAL + 1))
    sed -i "s/$SERIAL/$NEW_SERIAL/" "$BIND_ZONE_FILE"
fi


systemctl restart bind9
systemctl restart named