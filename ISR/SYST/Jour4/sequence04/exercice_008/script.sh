#!/bin/bash


LOG_FILE="/var/log/auth.log"
DOSSIER_SORTIE="./rapports_securite"
CSV_FICHIER="$DOSSIER_SORTIE/rapport_ip_suspectes.csv"

if [ ! -f "$LOG_FILE" ]; then
    echo "[!] Le fichier source $LOG_FILE est introuvable."
    exit 1
fi

# Création du dossier de destination s'il n'existe pas
mkdir -p "$DOSSIER_SORTIE"

echo "====================================================="
echo "   GÉNÉRATION DU RAPPORT CSV DES IP SSH SUSPECTES    "
echo "====================================================="
echo "Analyse des journaux d'authentification en cours..."

# Création de l'en-tête du fichier CSV
# Colonnes : Adresse IP, Nombre de tentatives, Niveau de suspicion / Statut
echo "Adresse_IP,Tentatives_Echecs,Statut" > "$CSV_FICHIER"

# Extraction, comptage et formatage des IP issues de Failed password ou Invalid user
# Le format de sortie brut de (uniq -c) est : "   <compte> <IP>"
grep -E "Failed password|Invalid user" "$LOG_FILE" \
    | awk '{for(i=1;i<=NF;i++) if($i=="from") print $(i+1)}' \
    | sort \
    | uniq -c \
    | sort -nr \
    | while read -r count ip; do
        # Détermination d'un niveau de suspicion simple basé sur le nombre d'échecs
        if [ "$count" -ge 10 ]; then
            statut="Critique (Attaque probable)"
        elif [ "$count" -ge 5 ]; then
            statut="Suspect (À surveiller)"
        else
            statut="Faible"
        fi

        # Écriture de la ligne au format CSV (séparateur par virgule)
        echo "$ip,$count,\"$statut\"" >> "$CSV_FICHIER"
      done

echo ""
echo "-----------------------------------------------------"
echo " Rapport CSV généré avec succès !"
echo " Fichier de sortie : $CSV_FICHIER"
echo "-----------------------------------------------------"

# Affichage d'un aperçu du contenu CSV généré dans le terminal
echo "Aperçu du contenu :"
cat "$CSV_FICHIER"
echo "====================================================="