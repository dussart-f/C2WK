#!/bin/bash


# Fichier source à analyser
LOG_FILE="${1:-/var/log/syslog}"
DOSSIER_SORTIE="./logs_classes"

if [ ! -f "$LOG_FILE" ]; then
    echo "[!] Le fichier source $LOG_FILE est introuvable."
    exit 1
fi

# Création du dossier de destination pour les fichiers classés s'il n'existe pas
mkdir -p "$DOSSIER_SORTIE"

# Définition des fichiers de sortie
FICHIER_CRITIQUE="$DOSSIER_SORTIE/critique.log"
FICHIER_ERREUR="$DOSSIER_SORTIE/erreur.log"
FICHIER_AVERTISSEMENT="$DOSSIER_SORTIE/avertissement.log"
FICHIER_INFO="$DOSSIER_SORTIE/information.log"

# Nettoyage des anciens fichiers de sortie pour repartir sur du neuf
> "$FICHIER_CRITIQUE"
> "$FICHIER_ERREUR"
> "$FICHIER_AVERTISSEMENT"
> "$FICHIER_INFO"

echo "Analyse et répartition en cours depuis : $LOG_FILE ..."

# Utilisation d'awk pour filtrer et répartir les lignes selon la gravité détectée
awk -v crit="$FICHIER_CRITIQUE" \
    -v err="$FICHIER_ERREUR" \
    -v warn="$FICHIER_AVERTISSEMENT" \
    -v info="$FICHIER_INFO" '{
    
    # Conversion en minuscules pour une recherche insensible à la casse
    ligne_inf = tolower($0)

    # Classification selon les mots-clés de sévérité standard
    if (ligne_inf ~ /emerg|alert|crit/) {
        print $0 >> crit
    } else if (ligne_inf ~ /err|error|fail/) {
        print $0 >> err
    } else if (ligne_inf ~ /warn|warning/) {
        print $0 >> warn
    } else {
        print $0 >> info
    }
}' "$LOG_FILE"