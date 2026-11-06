#!/bin/bash

LOG_FILE="/var/log/auth.log"

# Définition du seuil d'alerte
SEUIL_ALERTE=5

if [ ! -f "$LOG_FILE" ]; then
    echo "[!] Le fichier $LOG_FILE est introuvable."
    exit 1
fi

# Extraction et comptage global des échecs SSH (Failed password ou Invalid user)
NB_ECHECS=$(grep -E "Failed password|Invalid user" "$LOG_FILE" | wc -l)

echo "Nombre total de tentatives SSH échouées détectées : $NB_ECHECS"
echo "Seuil d'alerte configuré : $SEUIL_ALERTE"
echo ""


# Extraction des adresses IP 
grep -E "Failed password|Invalid user" "$LOG_FILE" \
    | awk '{for(i=1;i<=NF;i++) if($i=="from") print $(i+1)}' \
    | sort \
    | uniq -c \
    | sort -nr

echo ""
echo "====================================================="

# Vérification du seuil et déclenchement de l'alerte
if [ "$NB_ECHECS" -ge "$SEUIL_ALERTE" ]; then
    echo "[!] ALERTE SÉCURITÉ : Le nombre d'échecs ($NB_ECHECS) dépasse le seuil critique ($SEUIL_ALERTE) !"
    exit 2
else
    echo "[INFO] Le système est stable. Aucun seuil d'alerte critique atteint."
    exit 0
fi