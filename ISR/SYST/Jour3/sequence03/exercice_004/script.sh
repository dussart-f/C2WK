#!/bin/bash

SMB_CONF="/etc/samba/smb.conf"

awk -F: '($3 >= 1000 && $1 != "nobody") {print $1, $6}' /etc/passwd | while read -r username user_home; do
  
  # Si le champ home n'est pas défini, on prend par défaut /home/username
  [ -z "$user_home" ] && user_home="/home/$username"

  # Vérification et création du répertoire personnel s'il manque
  if [ ! -d "$user_home" ]; then
    mkdir -p "$user_home"
    echo "[INFO] Le répertoire '$user_home' pour l'utilisateur '$username' était absent. Création effectuée."
  else
    echo "[INFO] Le répertoire '$user_home' pour l'utilisateur '$username' existe déjà."
  fi

  # Attribution stricte des droits (propriétaire = utilisateur, permissions = 700)
  chown "$username:$username" "$user_home"
  chmod 700 "$user_home"

done


# Vérifier si la section [homes] existe déjà dans smb.conf
if ! grep -q "\[homes\]" "$SMB_CONF"; then
  cat << 'EOF' >> "$SMB_CONF"

[homes]
   comment = Répertoires personnels
   browseable = no
   read only = no
   create mask = 0700
   directory mask = 0700
   valid users = %S
EOF
  echo "[INFO] Section [homes] ajoutée à $SMB_CONF."
else
  echo "[INFO] La section [homes] existe déjà dans $SMB_CONF."
fi

systemctl restart smbd

if [ $? -eq 0 ]; then
  echo "[SUCCÈS] Le service smbd a été redémarré avec succès."
else
  echo "[ERREUR] Échec du redémarrage du service smbd." >&2
  exit 1
fi
