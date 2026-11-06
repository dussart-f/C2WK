#!/bin/bash

# Fichier de log cible (par défaut /var/log/syslog)
LOG_FILE="${1:-/var/log/syslog}"



if [ ! -f "$LOG_FILE" ]; then
    echo "[!] Le fichier $LOG_FILE est introuvable."
    exit 1
fi

# Saisie des bornes de la période
echo "Formats acceptés : 'HH:MM' (pour aujourd'hui) ou 'YYYY-MM-DD HH:MM:SS'"
read -p "Entrez l'heure/date de DÉBUT : " DEBUT_STR
read -p "Entrez l'heure/date de FIN   : " FIN_STR

# Normalisation des formats courts (HH:MM) en y ajoutant la date courante
CURRENT_DATE=$(date "+%Y-%m-%d")
if [[ "$DEBUT_STR" =~ ^[0-9]{2}:[0-9]{2}$ ]]; then
    DEBUT_STR="$CURRENT_DATE $DEBUT_STR:00"
elif [[ "$DEBUT_STR" =~ ^[0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]; then
    DEBUT_STR="$CURRENT_DATE $DEBUT_STR"
fi

if [[ "$FIN_STR" =~ ^[0-9]{2}:[0-9]{2}$ ]]; then
    FIN_STR="$CURRENT_DATE $FIN_STR:59"
elif [[ "$FIN_STR" =~ ^[0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]; then
    FIN_STR="$CURRENT_DATE $FIN_STR"
fi

# Conversion des bornes textuelles en timestamps Unix (secondes) via 'date'
TS_DEBUT=$(date -d "$DEBUT_STR" +%s 2>/dev/null)
TS_FIN=$(date -d "$FIN_STR" +%s 2>/dev/null)

if [ -z "$TS_DEBUT" ] || [ -z "$TS_FIN" ]; then
    echo "[-] Erreur : Format de date ou d'heure invalide."
    exit 1
fi


ANNEE_COURANTE=$(date +%Y)

# Lecture et filtrage ligne par ligne avec awk et date
while IFS=read -r ligne; do
    # Utilisation d'awk pour extraire les champs du syslog (Mois, Jour, Heure)
    MOIS_LOG=$(echo "$ligne" | awk '{print $1}')
    JOUR_LOG=$(echo "$ligne" | awk '{print $2}')
    HEURE_LOG=$(echo "$ligne" | awk '{print $3}')

    # Validation rapide du format horodaté syslog standard
    if [[ -n "$MOIS_LOG" && -n "$JOUR_LOG" && "$HEURE_LOG" =~ ^[0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]; then
        # Reconstruction de la date complète de la ligne de log
        DATE_LIGNE_STR="$ANNEE_COURANTE $MOIS_LOG $JOUR_LOG $HEURE_LOG"
        
        # Conversion du timestamp de la ligne
        TS_LIGNE=$(date -d "$DATE_LIGNE_STR" +%s 2>/dev/null)

        # Comparaison via les timestamps
        if [ -n "$TS_LIGNE" ]; then
            if [ "$TS_LIGNE" -ge "$TS_DEBUT" ] && [ "$TS_LIGNE" -le "$TS_FIN" ]; then
                echo "$ligne"
            fi
        fi
    fi
done < "$LOG_FILE"