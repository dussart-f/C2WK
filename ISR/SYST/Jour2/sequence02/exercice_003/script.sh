#!/bin/bash

CSV_FILE="users.csv"

if [ ! -f "$CSV_FILE" ]; then
  echo "[Erreur : Le fichier CSV '$CSV_FILE' est introuvable."
  exit 1
fi

tail -n +2 "$CSV_FILE" | while IFS=',' read -r col1 col2; do

    USERNAME=$(echo "$col1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9._-]//g')
    EMAIL="$col2"

    if id "$USERNAME" &>/dev/null; then
        echo "L'utilisateur '$USERNAME' existe déjà."
        continue
    fi

    useradd -m -s /bin/bash "$USERNAME"
    DEFAULT_PASSWORD="Password123!"
    echo "$USERNAME:$DEFAULT_PASSWORD" | chpasswd

    chage -d 0 "$USERNAME"

    MAILBOX_PATH="/var/spool/mail/$USERNAME"
    touch "$MAILBOX_PATH"
    chown "$USERNAME":mail "$MAILBOX_PATH"
    chmod 660 "$MAILBOX_PATH"

    echo "Utilisateur créé : $USERNAME Email : $EMAIL"
    echo "Mot de passe par défaut : $DEFAULT_PASSWORD"

done