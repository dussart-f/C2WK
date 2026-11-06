#!/bin/bash

REMOTE_USER="dussar_f"
REMOTE_HOST="172.16.250.153"
SSH_KEY="$HOME/.ssh/id_rsa"


ssh-keygen -t rsa -b 4096 -N "" -f "$SSH_KEY"

ssh-copy-id -i "${SSH_KEY}.pub" "${REMOTE_USER}@${REMOTE_HOST}"

if [ $? -eq 0 ]; then
  echo "[SUCCÈS] Clé publique copiée avec succès sur le serveur distant."
else
  echo "[ERREUR] Échec de la copie de la clé publique." >&2
  exit 1
fi


ssh -o BatchMode=yes -o ConnectTimeout=5 "${REMOTE_USER}@${REMOTE_HOST}" "echo 'Connexion SSH réussie par clé publique !'"

if [ $? -eq 0 ]; then
  echo "[SUCCÈS] L'authentification par clé fonctionne parfaitement."
else
  echo "[ERREUR] Le test de connexion a échoué." >&2
  exit 1
fi