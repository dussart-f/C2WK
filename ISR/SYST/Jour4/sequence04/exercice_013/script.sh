#!/bin/bash


LOG_FILE="${1:-/var/log/syslog}"
# Motif Regex dynamique passé en second argument, ou motif par défaut (ex: erreurs IP, segfault, ou refus)
MOTIF_REGEX="${2:-([0-9]{1,3}\.){3}[0-9]{1,3}|segfault|authentication failure}"

DOSSIER_SORTIE="./rapports_parsing"
DATE_JOUR=$(date "+%Y-%m-%d")
RAPPORT_FICHIER="$DOSSIER_SORTIE/rapport_parsing_$DATE_JOUR.txt"

if [ ! -f "$LOG_FILE" ]; then
    echo "[!] Le fichier source $LOG_FILE est introuvable."
    exit 1
fi

# Création du dossier de destination s'il n'existe pas
mkdir -p "$DOSSIER_SORTIE"

echo "====================================================="
echo "   PARSING AVANCÉ PAR EXPRESSIONS RÉGULIÈRES         "
echo "====================================================="

{
    echo "================================================================="
    echo "       RAPPORT DE PARSING PAR REGEX                              "
    echo "       Date d'analyse : $(date)                                  "
    echo "       Source analysée : $LOG_FILE                               "
    echo "       Motif Regex     : $MOTIF_REGEX                            "
    echo "================================================================="
    echo ""

    # Fichier temporaire pour stocker les correspondances
    TEMP_MATCH=$(mktemp)

    # Utilisation de grep -E pour filtrer les lignes correspondant au motif dynamique
    grep -E -i "$MOTIF_REGEX" "$LOG_FILE" > "$TEMP_MATCH" 2>/dev/null

    NB_MATCHES=$(wc -l < "$TEMP_MATCH")
    echo " Nombre total de correspondances trouvées : $NB_MATCHES"
    echo ""

    if [ "$NB_MATCHES" -gt 0 ]; then
        echo "-----------------------------------------------------------------"
        echo " EXTRAITS DÉTAILLÉS DES CORRESPONDANCES"
        echo "-----------------------------------------------------------------"
        # Affichage des 30 premières lignes correspondantes numérotées
        head -n 30 "$TEMP_MATCH" | sed 's/^/    [Match] /'
        
        if [ "$NB_MATCHES" -gt 30 ]; then
            echo "    (... affichage limité aux 30 premières occurrences sur $NB_MATCHES ...)"
        fi
        echo ""

        echo "-----------------------------------------------------------------"
        echo " STATISTIQUES DES SERVICES CONCERNÉS PAR CE MOTIF"
        echo "-----------------------------------------------------------------"
        # Extraction du service émetteur pour les lignes correspondantes
        awk '{
            service = $5;
            sub(/\[[0-9]+\]:/, "", service);
            sub(/:$/, "", service);
            if (service != "") print service;
        }' "$TEMP_MATCH" | sort | uniq -c | sort -nr | awk '{print "    - " $2 " : " $1 " occurrence(s)"}'
    else
        echo "Aucune correspondance trouvée pour le motif spécifié."
    fi

    echo ""
    echo "================================================================="
    echo " Fin du rapport de parsing."
    echo "================================================================="

    # Nettoyage
    rm -f "$TEMP_MATCH"

} | tee "$RAPPORT_FICHIER"

echo ""
echo " Rapport de parsing généré avec succès : $RAPPORT_FICHIER"