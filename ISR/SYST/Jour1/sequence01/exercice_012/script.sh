#!/bin/bash

DOMAIN="je-le-trouve-beau-mon-domain-donc-il-est-beau.com"
ZONE_FILE="/etc/bind/db.je-le-trouve-beau-mon-domain"
NAMED_CONF="/etc/bind/named.conf"
CSV_FILE="skynetHostIPs.csv"

echo "[+] 2. Génération de l'en-tête du fichier de zone ${ZONE_FILE}..."
TODAY=$(date +%Y%m%d)
NEW_SERIAL="${TODAY}01"

cat << EOF > "$ZONE_FILE"
\$TTL 86400
@   IN  SOA ns1.${DOMAIN}. root.${DOMAIN}. (
        ${NEW_SERIAL} ; Serial
        3600       ; Refresh
        1800       ; Retry
        604800     ; Expire
        86400 )    ; Minimum TTL

@   IN  NS  ns1.${DOMAIN}.
ns1 IN  A   127.0.0.1
www IN  A   127.0.0.1

; --- Enregistrements générés automatiquement depuis ${CSV_FILE} ---
EOF


awk -F',' 'NR > 1 {
    # Nettoyage des espaces potentiels
    gsub(/^[ \t]+|[ \t]+$/, "", $2);
    gsub(/^[ \t]+|[ \t]+$/, "", $3);
    gsub(/^[ \t]+|[ \t]+$/, "", $4);
    
    # Conversion du hostname en minuscules pour la conformité DNS
    h = tolower($2);
    
    # Écriture des enregistrements A et AAAA
    print h " IN A " $3;
    print h " IN AAAA " $4;
}' "$CSV_FILE" >> "$ZONE_FILE"


named-checkconf
named-checkzone "$DOMAIN" "$ZONE_FILE"

systemctl restart bind9