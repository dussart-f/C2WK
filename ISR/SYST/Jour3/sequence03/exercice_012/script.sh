#!/bin/bash

REMOTE_USER="dussar_f"
REMOTE_HOST="172.16.250.153"
SSH_KEY="$HOME/.ssh/id_rsa"

# Fichiers de test pour l'exemple
LOCAL_FILE="fichier_local.txt"
REMOTE_DEST_DIR="/home/$REMOTE_USER/destination/"

echo "Ceci est un fichier de test transféré via SCP le $(date)." > "$LOCAL_FILE"

# Vérification de l'existence de la clé SSH
if [ ! -f "$SSH_KEY" ]; then
  echo "Erreur : La clé SSH '$SSH_KEY' est introuvable." >&2
  exit 1
fi


# Utilisation de scp avec l'option -i pour spécifier la clé privée
scp -i "$SSH_KEY" -o StrictHostKeyChecking=accept-new "$LOCAL_FILE" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DEST_DIR}"


if [ $? -eq 0 ]; then
  echo "[SUCCÈS] Le fichier '$LOCAL_FILE' a été transféré avec succès vers ${REMOTE_HOST}:${REMOTE_DEST_DIR}."
else
  [ERREUR] "Échec du transfert SCP." >&2
  exit 1
fi
