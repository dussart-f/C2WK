#!/bin/bash

SHARE_PATH="/srv/samba/partage"
SMB_CONF="/etc/samba/smb.conf"

mkdir -p "$SHARE_PATH"
chown -R root:root "$SHARE_PATH"
chmod 0770 "$SHARE_PATH"
echo "[INFO] Répertoire '$SHARE_PATH' créé avec les permissions adaptées."


if ! grep -q "\[partage\]" "$SMB_CONF"; then
  cat << EOF >> "$SMB_CONF"

[partage]
   path = $SHARE_PATH
   browseable = yes
   read only = no
   valid users = @root jdoe asmith bwayne
   create mask = 0660
   directory mask = 0770
EOF
  echo "[INFO] Configuration du partage ajoutée à $SMB_CONF."
else
  echo "[INFO] Le partage [partage] existe déjà dans $SMB_CONF."
fi


systemctl restart smbd

if [ $? -eq 0 ]; then
  echo "[SUCCÈS] Le service smbd a été redémarré avec succès."
else
  echo "[ERREUR] Échec du redémarrage du service smbd." >&2
  exit 1
fi