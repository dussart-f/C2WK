#!/bin/bash

UTILISATEUR="${1:-root}"
LOG_FILE="/var/log/auth.log"


if [ ! -f "$LOG_FILE" ]; then
    echo "[!] Le fichier $LOG_FILE est introuvable."
    exit 1
fi

# Demande des bornes de la plage horaire à l'utilisateur (format HH:MM ou YYYY-MM-DD HH:MM:SS)
echo "Entrez la plage horaire (ex: format HH:MM ou 'YYYY-MM-DD HH:MM:SS')"
read -p "Heure de DÉBUT (ex: 14:00) : " DEBUT_STR
read -p "Heure de FIN   (ex: 16:30) : " FIN_STR

# Si l'utilisateur entre juste une heure, on complète avec la date du jour pour que 'date -d' comprenne
CURRENT_DATE=$(date "+%Y-%m-%d")
if [[ "$DEBUT_STR" =~ ^[0-9]{2}:[0-9]{2}$ ]]; then
    DEBUT_STR="$CURRENT_DATE $DEBUT_STR:00"
fi
if [[ "$FIN_STR" =~ ^[0-9]{2}:[0-9]{2}$ ]]; then
    FIN_STR="$CURRENT_DATE $FIN_STR:59"
fi

# Conversion des bornes en timestamps Unix (secondes)
TS_DEBUT=$(date -d "$DEBUT_STR" +%s 2>/dev/null)
TS_FIN=$(date -d "$FIN_STR" +%s 2>/dev/null)

if [ -z "$TS_DEBUT" ] || [ -z "$TS_FIN" ]; then
    echo "[-] Erreur : Format de date/heure invalide."
    exit 1
fi


# Analyse ligne par ligne du fichier de log
while IFS=read -r ligne; do
    # Extraction des 3 premiers champs du syslog (Mois, Jour, Heure)
    MOIS_LOG=$(echo "$ligne" | awk '{print $1}')
    JOUR_LOG=$(echo "$ligne" | awk '{print $2}')
    HEURE_LOG=$(echo "$ligne" | awk '{print $3}')
    ANNEE_COURANTE=$(date +%Y)

    # Reconstruction de la date complète de la ligne de log
    DATE_LIGNE_STR="$ANNEE_COURANTE $MOIS_LOG $JOUR_LOG $HEURE_LOG"
    TS_LIGNE=$(date -d "$DATE_LIGNE_STR" +%s 2>/dev/null)

    # Si le timestamp de la ligne est valide et compris dans la plage [Début, Fin]
    if [ -n "$TS_LIGNE" ] && [ "$TS_LIGNE" -ge "$TS_DEBUT" ] && [ "$TS_LIGNE" -le "$TS_FIN" ]; then
        # Vérifie si l'utilisateur recherché est présent dans la ligne
        if echo "$ligne" | grep -qw "$UTILISATEUR"; then
            echo "$ligne"
        fi
    fi
done < "$LOG_FILE"
