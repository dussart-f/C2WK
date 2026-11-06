#!/bin/bash

DOMAIN="etna.nx"
ADMIN_EMAIL="postmaster@$DOMAIN"

DMARC_POLICY="v=DMARC1; p=quarantine; rua=mailto:$ADMIN_EMAIL; pct=100; adkim=r; aspf=r;"

BIND_ZONE_FILE="/etc/bind/db.$DOMAIN"

echo "_dmarc IN TXT \"$DMARC_POLICY\"" >> "$BIND_ZONE_FILE"

SERIAL=$(grep -o '[0-9]\{10\}' "$BIND_ZONE_FILE" | head -1)
if [ ! -z "$SERIAL" ]; then
    NEW_SERIAL=$((SERIAL + 1))
    sed -i "s/$SERIAL/$NEW_SERIAL/" "$BIND_ZONE_FILE"
    echo "[+] Numéro de série SOA mis à jour ($SERIAL -> $NEW_SERIAL)."
fi

postconf -e "milter_protocol = 2"
postconf -e "milter_default_action = accept"

# Vérification/Ajout des milters existants (ex: OpenDKIM ou Rspamd sur le port local)
CURRENT_SMTDP_MILTERS=$(postconf -h smtpd_milters 2>/dev/null || echo "")

if [ -z "$CURRENT_SMTDP_MILTERS" ] || [ "$CURRENT_SMTDP_MILTERS" = "no" ]; then
  # Si aucun milter n'est déclaré, on configure un milter par défaut (ex: OpenDKIM / OpenDMARC ou Rspamd)
  # Ici on branche un inet local (ex: port 12301 pour opendkim/opendmarc ou 11332 pour rspamd)
  echo "[*] Aucun milter détecté, ajout d'un service de filtrage milter local pour DMARC..."
  postconf -e "smtpd_milters = inet:127.0.0.1:12301"
  postconf -e "non_smtpd_milters = inet:127.0.0.1:12301"
else
  echo "[i] Des milters sont déjà configurés sur Postfix : $CURRENT_SMTDP_MILTERS"
fi

systemctl restart bind9
systemctl restart named
systemctl restart postfix