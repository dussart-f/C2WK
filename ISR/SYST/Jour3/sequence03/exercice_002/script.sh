#!/bin/bash

apt-get update -y
apt-get install -y samba


# Vérification du succès de l'installation
if [ $? -eq 0 ]; then
  echo "[SUCCÈS] Samba a été installé avec succès."
else
  echo "[ERREUR] Échec lors de l'installation de Samba." >&2
  exit 1
fi

systemctl enable --now smbd
