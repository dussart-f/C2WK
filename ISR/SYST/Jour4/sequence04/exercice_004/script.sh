#!/bin/bash


LOG_DIR="/var/log"
MOTIF_ERREUR="${1:-error|fail|crit|fatal}"

if [ ! -d "$LOG_DIR" ]; then
    echo "[!] Le répertoire $LOG_DIR est introuvable."
    exit 1
fi

echo "Analyse en cours (fichiers actifs et archives .gz)..."
echo ""


echo "--- [ 1. Logs actifs ] ---"
find "$LOG_DIR" -type f ! -name "*.gz" ! -name "*.old" ! -name "*.1" 2>/dev/null | while read -r fichier; do
    # Recherche insensible à la casse (-i) des erreurs
    if grep -q -i -E "$MOTIF_ERREUR" "$fichier" 2>/dev/null; then
        echo " > Fichier : $fichier"
        grep -n -i -E "$MOTIF_ERREUR" "$fichier" 2>/dev/null | sed 's/^/   [Ligne] /'
        echo ""
    fi
done

# 2. Traitement des fichiers de log archivés / compressés (.gz) avec zgrep
echo "--- [ 2. Logs archivés (.gz) ] ---"
find "$LOG_DIR" -type f -name "*.gz" 2>/dev/null | while read -r archive; do
    if zgrep -q -i -E "$MOTIF_ERREUR" "$archive" 2>/dev/null; then
        echo " > Archive : $archive"
        zgrep -i -E "$MOTIF_ERREUR" "$archive" 2>/dev/null | head -n 10 | sed 's/^/   [Extrait] /'
        echo "   (...)"
        echo ""
    fi
done
