#!/bin/bash

REMOTE_USER="dussar_f"
REMOTE_HOST="172.16.250.153"
SSH_KEY="$HOME/.ssh/id_rsa"

LOCAL_DIR="/chemin/vers/dossier_local/"
REMOTE_DIR="/chemin/vers/dossier_distant/"


# Vérification de l'existence de la clé SSH
if [ ! -f "$SSH_KEY" ]; then
  echo "Erreur : La clé SSH '$SSH_KEY' est introuvable." >&2
  exit 1
fi

# Vérification de l'existence du répertoire local source
if [ ! -d "$LOCAL_DIR" ]; then
  echo "Erreur : Le répertoire local source '$LOCAL_DIR' n'existe pas." >&2
  exit 1
fi

# Exécution de Rsync en mode archive (-a), compressé (-z), avec affichage verbeux (-v) 
# et suppression des fichiers distants absents en local (--delete)
rsync -avz --delete -e "ssh -i $SSH_KEY -o StrictHostKeyChecking=accept-new" "$LOCAL_DIR" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}"

if [ $? -eq 0 ]; then
  echo "[SUCCÈS] La synchronisation Rsync s'est déroulée avec succès."
else
  echo "[ERREUR] Échec lors de la synchronisation Rsync." >&2
  exit 1
fi
