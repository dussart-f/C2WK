#!/bin/bash

CSV_FILE="users.csv"
OUTPUT_FILE="users_crees.txt"



# Vérifier que le fichier CSV existe
if [[ ! -f "$CSV_FILE" ]]; then
    echo "Erreur : fichier $CSV_FILE introuvable."
    exit 1
fi

{
    echo "Rapport de création des utilisateurs"
    echo "Date : $(date)"
    echo "------------------------------------"
} > "$OUTPUT_FILE"

# Lire le CSV en ignorant la première ligne
tail -n +2 "$CSV_FILE" |
while IFS=',' read -r id first_name last_name email gender group last_login
do
    # Construire le nom d'utilisateur à partir de l'e-mail
    username="${email%@*}"

    echo "Traitement de l'utilisateur : $username" >> "$OUTPUT_FILE"

    # Créer le groupe s'il n'existe pas
    if ! getent group "$group" > /dev/null; then
        groupadd "$group" || {
            echo "Erreur lors de la création du groupe $group" >> "$OUTPUT_FILE"
            continue
        }
    fi

    # Créer l'utilisateur uniquement s'il n'existe pas
    if id "$username" &>/dev/null; then
        echo "L'utilisateur $username existe déjà." >> "$OUTPUT_FILE"
        continue
    fi

    password="$(pwgen 12 1)"

    # Créer l'utilisateur avec son groupe principal
    if useradd -m -s /bin/bash -g "$group" \
        -c "$first_name $last_name" "$username"; then
        echo "$username:$password" | chpasswd
        echo "Utilisateur $username avec le mot de passe $password créé avec succès." >> "$OUTPUT_FILE"
    else
        echo "Erreur lors de la création de $username." >> "$OUTPUT_FILE"
    fi

done