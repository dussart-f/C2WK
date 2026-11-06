DOMAIN_NAME="je-le-trouve-beau-mon-domain-donc-il-est-beau.com"
ZONE_FILE_NAME="db.monbeaudomain"
ZONE_FILE_PATH="/etc/bind/$ZONE_FILE_NAME"

cat <<EOF >> "$ZONE_FILE_PATH"

; --- Ajouts automatiques (Fun & Redirections) ---
emperorprotect       IN A     127.0.0.1
omnissiah            IN CNAME emperorprotect
EOF

named-checkconf

named-checkzone "$DOMAIN_NAME" "$ZONE_FILE_PATH"

systemctl restart bind9