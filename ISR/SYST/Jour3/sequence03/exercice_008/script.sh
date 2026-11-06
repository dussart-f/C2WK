#!/bin/bash

# Exemple d'attribution automatisée d'un mot de passe par défaut sécurisé
awk -F: '($3 >= 1000 && $1 != "nobody") {print $1}' /etc/passwd | while read -r username; do

  # Définition d'un mot de passe temporaire ou par défaut
  DEFAULT_SMB_PASSWORD="MonSuperMotDePasseSecure123!"

  # Utilisation de smbpasswd en mode non-interactif (-s)
  (echo "$DEFAULT_SMB_PASSWORD"; echo "$DEFAULT_SMB_PASSWORD") | smbpasswd -s -a "$username"

  if [ $? -eq 0 ]; then
    echo "[SUCCÈS] Mot de passe Samba configuré pour l'utilisateur '$username'."
  else
    echo "[ERREUR] Échec de la configuration du mot de passe pour '$username'." >&2
  fi

done
