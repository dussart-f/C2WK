#!/bin/bash


# Tableau associatif ou liste des fichiers de log à analyser
LOGS=(
    "/var/log/syslog:Journal système global"
    "/var/log/auth.log:Journal des authentifications et sécurité"
    "/var/log/kern.log:Journal du noyau Linux"
    "/var/log/dpkg.log:Journal des paquets et installations APT"
)


for item in "${LOGS[@]}"; do
    FILE="${item%%:*}"
    DESC="${item##*:}"

    if [ -f "$FILE" ]; then
        # Utilisation de tail pour afficher les 20 dernières lignes
        tail -n 20 "$FILE"
    else
        echo "[!] Le fichier $FILE est introuvable."
        echo "    (Astuce : Vérifiez si rsyslog est installé ou utilisez journalctl)"
    fi
    echo ""
done
