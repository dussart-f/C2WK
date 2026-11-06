#!/bin/bash

REMOTE_USER="dussar_f"
REMOTE_HOST="172.16.250.153"
SSH_KEY="$HOME/.ssh/id_rsa"

# Paramètres du tunnel
LOCAL_PORT="8080"      # Port d'écoute sur votre machine locale
TARGET_HOST="localhost" # Hôte cible vu depuis le serveur distant
TARGET_PORT="80"       # Port du service sur l'hôte cible


# Vérification de l'existence de la clé SSH
if [ ! -f "$SSH_KEY" ]; then
  echo "Erreur : La clé SSH '$SSH_KEY' est introuvable." >&2
  exit 1
fi

# Vérification si le port local est déjà utilisé
if ss -tuln | grep -q ":$LOCAL_PORT "; then
  echo "[AVERTISSEMENT] Le port local $LOCAL_PORT est déjà en cours d'utilisation."
  echo "Veuillez libérer le port ou en choisir un autre."
  exit 1
fi

# Lancement du tunnel SSH en arrière-plan
# -f : Passe SSH en arrière-plan juste avant la connexion
# -N : Ne exécute pas de commande à distance (uniquement pour le tunneling)
# -o ExitOnForwardFailure=yes : Arrête le script si le port local est impossible à lier
ssh -i "$SSH_KEY" -f -N -L "${LOCAL_PORT}:${TARGET_HOST}:${TARGET_PORT}" "${REMOTE_USER}@${REMOTE_HOST}" -o ExitOnForwardFailure=yes

if [ $? -eq 0 ]; then
  echo "[SUCCÈS] Tunnel SSH établi avec succès !"
  echo "Vous pouvez désormais accéder au service distant via : http://localhost:$LOCAL_PORT"
else
  [ERREUR] "Échec de l'établissement du tunnel SSH." >&2
  exit 1
fi