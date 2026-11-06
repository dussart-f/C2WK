#!/bin/bash

DOMAIN_NAME="je-le-trouve-beau-mon-domain-donc-il-est-beau.com"
NAMED_CONF="/etc/bind/named.conf"
IP=$(hostname -I)

IFS='.' read -r o1 o2 o3 o4 <<< "$IP"

REVERSE_ZONE="${o3}.${o2}.${o1}.in-addr.arpa"
ZONE_FILE="/etc/bind/db.${o1}.${o2}.${o3}"
PTR_LAST_OCTET="$o4"

cat << EOF > "${ZONE_FILE}"
\$TTL 86400
@   IN  SOA ns1.${DOMAIN_NAME}. root.${DOMAIN_NAME}. (
        2026102601 ; Serial
        3600       ; Refresh
        1800       ; Retry
        604800     ; Expire
        86400 )    ; Minimum TTL

@   IN  NS  ns1.${DOMAIN_NAME}.
${PTR_LAST_OCTET}  IN  PTR  me.je-le-trouve-beau-mon-domain-donc-il-est-beau.com
EOF

if ! grep -q "${REVERSE_ZONE}" "${NAMED_CONF}"; then
    cat << EOF >> "${NAMED_CONF}"

zone "${REVERSE_ZONE}" {
    type master;
    file "${ZONE_FILE}";
};
EOF
fi


named-checkconf

named-checkzone "$REVERSE_ZONE" "$ZONE_FILE"

systemctl restart bind9