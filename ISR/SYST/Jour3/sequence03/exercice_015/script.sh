#!/bin/bash

REMOTE_USER="dussar_f"
REMOTE_HOST="172.16.250.153"
SSH_KEY="$HOME/.ssh/id_rsa"


# Génération d'une paire de clés RSA 4096 bits sans passphrase (-N "") pour un accès totalement automatisé
ssh-keygen -t rsa -b 4096 -N "" -f "$SSH_KEY"
echo "[SUCCÈS] Nouvelle paire de clés SSH générée à l'emplacement : $SSH_KEY"


# Copie de la clé publique vers le serveur distant 
ssh-copy-id -i "${SSH_KEY}.pub" "${REMOTE_USER}@${REMOTE_HOST}"

if [ $? -eq 0 ]; then
  echo "[SUCCÈS] Clé publique déployée avec succès sur le serveur distant."
else
  [ERREUR] "Échec de la copie de la clé publique." >&2
  exit 1
fi

# Test d'une connexion SSH non interactive (en forçant l'utilisation de la clé et l'échec si le mot de passe est requis)
ssh -o BatchMode=yes -o ConnectTimeout=5 -i "$SSH_KEY" "${REMOTE_USER}@${REMOTE_HOST}" "echo 'Accès SSH sans mot de passe validé avec succès !'"

if [ $? -eq 0 ]; then
  echo "[SUCCÈS] L'authentification par clé fonctionne parfaitement et ne demande aucun mot de passe."
else
  [ERREUR] "Le test d'authentification sans mot de passe a échoué." >&2
  exit 1
fi
