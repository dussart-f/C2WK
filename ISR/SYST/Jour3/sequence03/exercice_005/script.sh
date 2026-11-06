#!/bin/bash

GROUP_NAME="equipe"
SHARE_PATH="/srv/samba/equipe_partage"
SMB_CONF="/etc/samba/smb.conf"


# Création du groupe s'il n'existe pas
if ! getent group "$GROUP_NAME" &>/dev/null; then
  groupadd "$GROUP_NAME"
  echo "[INFO] Groupe '$GROUP_NAME' créé avec succès."
else
  echo "[INFO] Le groupe '$GROUP_NAME' existe déjà."
fi


for user in jdoe asmith; do
  if id "$user" &>/dev/null; then
    usermod -aG "$GROUP_NAME" "$user"
    echo "[INFO] Utilisateur '$user' ajouté au groupe '$GROUP_NAME'."
  fi
done

# Création du répertoire physique du partage
mkdir -p "$SHARE_PATH"
chown root:"$GROUP_NAME" "$SHARE_PATH"
chmod 2770 "$SHARE_PATH" # Le bit setgid (2) garantit que les nouveaux fichiers appartiendront au groupe
echo "[INFO] Répertoire '$SHARE_PATH' configuré avec le groupe '$GROUP_NAME'."


if ! grep -q "\[equipe\]" "$SMB_CONF"; then
  cat << EOF >> "$SMB_CONF"

[equipe]
   comment = Partage reserve au groupe $GROUP_NAME
   path = $SHARE_PATH
   browseable = yes
   read only = no
   valid users = @$GROUP_NAME
   create mask = 0660
   directory mask = 0770
EOF
  echo "[INFO] Partage [equipe] ajouté à $SMB_CONF."
else
  echo "[INFO] Le partage [equipe] existe déjà dans $SMB_CONF."
fi

systemctl restart smbd

if [ $? -eq 0 ]; then
  echo "[SUCCÈS] Le service smbd a été redémarré avec succès."
else
  echo "[ERREUR] Échec du redémarrage du service smbd." >&2
  exit 1
fi
