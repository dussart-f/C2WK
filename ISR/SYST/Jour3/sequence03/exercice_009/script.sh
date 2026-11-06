#!/bin/bash

SHARE_PATH="/srv/samba/lecture_seule"
SMB_CONF="/etc/samba/smb.conf"

# Création du répertoire s'il n'existe pas
mkdir -p "$SHARE_PATH"

chown root:root "$SHARE_PATH"
chmod 0755 "$SHARE_PATH"

chown root:root "$SHARE_PATH/notice.txt"
chmod 0644 "$SHARE_PATH/notice.txt"


if ! grep -q "\[archives\]" "$SMB_CONF"; then
  cat << EOF >> "$SMB_CONF"

[archives]
   comment = Partage en lecture seule pour les documents officiels
   path = $SHARE_PATH
   browseable = yes
   read only = yes
   valid users = jdoe asmith bwayne
EOF
  echo "[INFO] Section [archives] ajoutée à $SMB_CONF en mode lecture seule."
else
  echo "[INFO] La section [archives] existe déjà dans $SMB_CONF."
fi

systemctl restart smbd

if [ $? -eq 0 ]; then
  echo "[SUCCÈS] Le service smbd a été redémarré avec succès."
else
  echo "[ERREUR] Échec du redémarrage du service smbd." >&2
  exit 1
fi
