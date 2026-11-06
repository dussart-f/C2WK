#!/bin/bash

DOSSIER_LOGS="/var/log"
DOSSIER_SORTIE="./rapports_boucle"
DATE_JOUR=$(date "+%Y-%m-%d")
RAPPORT_FICHIER="$DOSSIER_SORTIE/rapport_boucle_$DATE_JOUR.txt"

# Création du dossier de destination s'il n'existe pas
mkdir -p "$DOSSIER_SORTIE"

{
    echo "================================================================="
    echo "       RAPPORT DE BOUCLE SUR LES LOGS (ACTIFS ET ARCHIVÉS)      "
    echo "       Date d'analyse : $(date)                                  "
    echo "================================================================="
    echo ""

    # Motif de recherche d'erreurs (insensible à la casse)
    MOTIF="error|fail|crit|fatal|alert"

    echo "--- [ANALYSE DES FICHIERS DE LOGS ACTIFS ] ---"
    echo ""

    # Boucle sur tous les fichiers réguliers non compressés dans /var/log
    for fichier in $(find "$DOSSIER_LOGS" -type f ! -name "*.gz" ! -name "*.old" ! -name "*.1" 2>/dev/null); do
        # Vérification si le fichier contient des erreurs
        if grep -q -i -E "$MOTIF" "$fichier" 2>/dev/null; then
            echo "[+] Fichier actif : $fichier"
            # Affichage des lignes correspondantes avec leur numéro de ligne
            grep -n -i -E "$MOTIF" "$fichier" 2>/dev/null | sed 's/^/    Ligne /'
            echo "-----------------------------------------------------------------"
        fi
    done

    echo ""
    echo "--- [ ANALYSE DES FICHIERS DE LOGS ARCHIVÉS (.gz) ] ---"
    echo ""

    # Boucle sur toutes les archives compressées dans /var/log
    for archive in $(find "$DOSSIER_LOGS" -type f -name "*.gz" 2>/dev/null); do
        # Vérification si l'archive contient des erreurs via zgrep
        if zgrep -q -i -E "$MOTIF" "$archive" 2>/dev/null; then
            echo "[+] Archive détectée : $archive"
            # Affichage d'un extrait des erreurs trouvées dans l'archive
            zgrep -i -E "$MOTIF" "$archive" 2>/dev/null | head -n 15 | sed 's/^/    [Extrait] /'
            echo "    (... extraction limitée à 15 lignes par archive ...)"
            echo "-----------------------------------------------------------------"
        fi
    done

    echo ""
    echo "================================================================="
    echo " Fin de la boucle d'analyse globale."
    echo "================================================================="

} | tee "$RAPPORT_FICHIER"

echo ""
echo "Rapport de boucle généré avec succès : $RAPPORT_FICHIER"