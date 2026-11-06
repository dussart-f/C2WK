#!/bin/bash


# Configuration des chemins et fichiers
LOG_FILE="${1:-/var/log/syslog}"
DOSSIER_RAPPORTS="./rapports_logs"
DATE_JOUR=$(date "+%Y-%m-%d")
RAPPORT_FICHIER="$DOSSIER_RAPPORTS/rapport_erreurs_$DATE_JOUR.txt"

if [ ! -f "$LOG_FILE" ]; then
    echo "[!] Le fichier source $LOG_FILE est introuvable."
    exit 1
fi

# Création du dossier de rapports s'il n'existe pas
mkdir -p "$DOSSIER_RAPPORTS"

# Utilisation de 'tee' pour écrire dans le fichier tout en affichant à l'écran
{
    echo "================================================================="
    echo "          RAPPORT QUOTIDIEN DES ERREURS - SYSTÈME DEBIAN 12      "
    echo "          Date du rapport : $(date)                              "
    echo "          Source analysée : $LOG_FILE                            "
    echo "================================================================="
    echo ""

    # Fichier temporaire pour stocker les lignes d'erreurs/avertissements
    TEMP_ERRORS=$(mktemp)

    # Filtrage des erreurs et avertissements (insensible à la casse)
    grep -i -E "error|fail|crit|warn" "$LOG_FILE" > "$TEMP_ERRORS"

    TOTAL_LIGNES=$(wc -l < "$TEMP_ERRORS")
    echo "[-] Nombre total d'événements (erreurs + avertissements) : $TOTAL_LIGNES"
    echo ""

    echo "-----------------------------------------------------------------"
    echo " STATISTIQUES PAR SERVICE / PROGRAMME"
    echo "-----------------------------------------------------------------"
    echo "Top des services émettant le plus d'alertes :"
    echo ""

    # Extraction du nom du service
    # On nettoie les crochets et les deux-points pour regrouper proprement.
    awk '{
        # Le champ du service est souvent le 5ème. On enlève le PID entre crochets si présent.
        service = $5
        sub(/\[[0-9]+\]:/, "", service)
        sub(/:$/, "", service)
        if (service != "") print service
    }' "$TEMP_ERRORS" | sort | uniq -c | sort -nr | head -n 10 | awk '{print "    - " $2 " : " $1 " occurrence(s)"}'

    echo ""
    echo "-----------------------------------------------------------------"
    echo " EXTRAIT DES DERNIÈRES ERREURS CRITIQUES (15 max)"
    echo "-----------------------------------------------------------------"
    tail -n 15 "$TEMP_ERRORS"

    echo ""
    echo "================================================================="
    echo " Fin du rapport quotidien."
    echo "================================================================="

    # Suppression du fichier temporaire
    rm -f "$TEMP_ERRORS"

} | tee "$RAPPORT_FICHIER"

echo ""
echo "Le rapport a été sauvegardé avec succès dans : $RAPPORT_FICHIER"