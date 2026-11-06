#!/bin/bash

SMB_CONF="/etc/samba/smb.conf"

apt-get update -y
apt-get install -y logwatch

# Vérification si le paramètre 'log level' existe déjà dans la section [global]
if grep -q "log level" "$SMB_CONF"; then
  # Mise à jour de la valeur existante à 2 (niveau recommandé pour suivre les connexions/déconnexions)
  sed -i 's/^[[:space:]]*log level.*/   log level = 2/' "$SMB_CONF"
else
  # Insertion du niveau de log sous l'en-tête [global]
  sed -i '/\[global\]/a \   log level = 2' "$SMB_CONF"
fi

echo "[INFO] Niveau de log Samba défini à 2 dans $SMB_CONF."

# Redémarrage du service Samba pour appliquer la configuration
systemctl restart smbd

if [ $? -eq 0 ]; then
  echo "[SUCCÈS] Le service Samba a été redémarré avec succès."
else
  echo "[ERREUR] Échec du redémarrage du service Samba." >&2
  exit 1
fi
