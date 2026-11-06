#!/bin/bash

LOG_FILE="${1:-/var/log/syslog}"
DOSSIER_SORTIE="./rapports_statistiques"
DATE_JOUR=$(date "+%Y-%m-%d")
RAPPORT_FICHIER="$DOSSIER_SORTIE/rapport_stats_$DATE_JOUR.txt"

if [ ! -f "$LOG_FILE" ]; then
    echo "[!] Le fichier source $LOG_FILE est introuvable."
    exit 1
fi

# Création du dossier de destination s'il n'existe pas
mkdir -p "$DOSSIER_SORTIE"


{
    echo "================================================================="
    echo "       RAPPORT STATISTIQUE JOURNALIER - ÉVÉNEMENTS PAR HEURE     "
    echo "       Date du rapport : $(date)                                 "
    echo "       Source analysée : $LOG_FILE                               "
    echo "================================================================="
    echo ""

    TOTAL_LIGNES=$(wc -l < "$LOG_FILE")
    echo "[-] Nombre total de lignes dans le fichier source : $TOTAL_LIGNES"
    echo ""

    echo "-----------------------------------------------------------------"
    echo "  DISTRIBUTION GLOBALE DES ÉVÉNEMENTS PAR HEURE (00h - 23h)"
    echo "-----------------------------------------------------------------"
    echo "Heure | Nombre d'événements"
    echo "---------------------------"

    # Extraction de l'heure (sous le format "HH:MM:SS" -> on coupe à "HH")
    # Tri et comptage par heure
    awk '{
        split($3, time, ":");
        if (time[1] != "") print time[1] ":00";
    }' "$LOG_FILE" | sort | uniq -c | awk '{print "  " $2 "  | " $1 " événement(s)"}'

    echo ""
    echo "-----------------------------------------------------------------"
    echo " TOP DES SERVICES ET LEUR VOLUME HORAIRE MOYEN / GLOBAL"
    echo "-----------------------------------------------------------------"
    echo ""

    # Analyse multi-services : extraction du service et comptage global
    echo "Classement des services les plus actifs :"
    awk '{
        service = $5;
        sub(/\[[0-9]+\]:/, "", service);
        sub(/:$/, "", service);
        if (service != "") print service;
    }' "$LOG_FILE" | sort | uniq -c | sort -nr | head -n 15 | awk '{print "    - " $2 " : " $1 " événement(s)"}'

    echo ""
    echo "-----------------------------------------------------------------"
    echo " 3. STATISTIQUES DÉTAILLÉES PAR SERVICE (Heure par Heure)"
    echo "-----------------------------------------------------------------"
    
    # Liste des principaux services détectés automatiquement
    SERVICES=$(awk '{
        service = $5;
        sub(/\[[0-9]+\]:/, "", service);
        sub(/:$/, "", service);
        if (service != "") print service;
    }' "$LOG_FILE" | sort | uniq -c | sort -nr | head -n 5 | awk '{print $2}')

    for srv in $SERVICES; do
        echo ""
        echo " > Service : $srv"
        grep -w "$srv" "$LOG_FILE" | awk '{
            split($3, time, ":");
            if (time[1] != "") print time[1] ":00";
        }' | sort | uniq -c | awk '{print "      [ " $2 " ] -> " $1 " événement(s)"}'
    done

    echo ""
    echo "================================================================="
    echo " Fin du rapport statistique."
    echo "================================================================="

} | tee "$RAPPORT_FICHIER"

echo ""
echo " Rapport statistique généré avec succès : $RAPPORT_FICHIER"