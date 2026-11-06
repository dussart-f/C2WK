#!/bin/bash

DOMAIN_NAME="je-le-trouve-beau-mon-domain-donc-il-est-beau.com"
ZONE_FILE_NAME="db.monbeaudomain"
ZONE_FILE_PATH="/etc/bind/$ZONE_FILE_NAME"
SERVER_IP="127.0.0.1"


cat <<EOF > "$ZONE_FILE_PATH"
\$TTL    604800
@       IN      SOA     ns1.$DOMAIN_NAME. admin.$DOMAIN_NAME. (
                          2026102601 ; Serial
                              604800 ; Refresh
                               86400 ; Retry
                             2419200 ; Expire
                              604800 ) ; Negative Cache TTL

; Enregistrements de la zone
@       IN      NS      ns1.$DOMAIN_NAME.
ns1     IN      A       $SERVER_IP
@       IN      A       $SERVER_IP
www     IN      A       $SERVER_IP
EOF

if ! grep -q "$DOMAIN_NAME" "/etc/bind/named.conf"; then
    cat <<EOF >> "/etc/bind/named.conf"

zone "je-le-trouve-beau-mon-domain-donc-il-est-beau.com" {
    type master;
    file "$ZONE_FILE_PATH";
};
EOF
fi

named-checkconf

named-checkzone "$DOMAIN_NAME" "$ZONE_FILE_PATH"

systemctl restart bind9

echo "nameserver 127.0.0.1" > /etc/resolv.conf