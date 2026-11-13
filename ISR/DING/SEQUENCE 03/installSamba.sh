#!/bin/bash

apt-get update -y
apt-get install -y samba


# Vérification du succès de l'installation
if [ $? -eq 0 ]; then
  echo "[SUCCÈS] Samba a été installé avec succès."
else
  echo "[ERREUR] Échec lors de l'installation de Samba." >&2
  exit 1
fi

systemctl enable --now smbd


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
   valid users = @root debian
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


REMOTE_USER="debian"
SSH_KEY="$HOME/.ssh/id_rsa"


ssh-keygen -t rsa -b 4096 -N "" -f "$SSH_KEY"

ssh-copy-id -i "${SSH_KEY}.pub" "${REMOTE_USER}@192.168.10.100"
ssh-copy-id -i "${SSH_KEY}.pub" "${REMOTE_USER}@192.168.20.100"
ssh-copy-id -i "${SSH_KEY}.pub" "${REMOTE_USER}@192.168.30.100"
ssh-copy-id -i "${SSH_KEY}.pub" "${REMOTE_USER}@192.168.40.100"
